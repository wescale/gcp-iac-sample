package main

import (
	"log"
	"net/http"
	"os"
	"time"
	"strings"
	"context"

	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"

	"github.com/opentracing/opentracing-go/ext"
	opentracing "github.com/opentracing/opentracing-go"
	jaegercfg "github.com/uber/jaeger-client-go/config"

	"github.com/jinzhu/gorm"
)

var db *gorm.DB

// LoggerMiddleware add logger and metrics
func LoggerMiddleware(inner http.HandlerFunc, name string, histogram *prometheus.HistogramVec, counter *prometheus.CounterVec) http.Handler {

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		start := time.Now()

		ctx := context.Background()

		if strings.Compare(name,"healthz") != 0 && strings.Compare(name,"ready") != 0 {
			var span opentracing.Span
			wireContext, err := opentracing.GlobalTracer().Extract(
				opentracing.HTTPHeaders,
				opentracing.HTTPHeadersCarrier(r.Header))
			if err != nil {
				log.Println(err)
				log.Println(r.Header)
			}

			// Create the span referring to the RPC client if available.
			// If wireContext == nil, a root span will be created.
			span = opentracing.StartSpan(
				name,
				ext.RPCServerOption(wireContext))

			defer span.Finish()

			ctx = opentracing.ContextWithSpan(ctx, span)
		}

		inner.ServeHTTP(w, r.WithContext(ctx))

		if strings.Compare(name,"healthz") != 0  && strings.Compare(name,"ready") != 0 {
			time := time.Since(start)
			log.Printf(
				"%s\t%s\t%s\t%s",
				r.Method,
				r.RequestURI,
				name,
				time,
			)

			histogram.WithLabelValues(r.RequestURI).Observe(time.Seconds())
			if counter != nil {
				counter.WithLabelValues(r.RequestURI).Inc()
			}
		}
	})
}

func main() {

	prefixPath := os.Getenv("PREFIX_PATH")

	/// Tracer
	cfg, err := jaegercfg.FromEnv()
	if err != nil {
		// parsing errors might happen here, such as when we get a string where we expect a number
		log.Printf("Could not parse Jaeger env vars: %s", err.Error())
		return
	}

	tracer, closer, err := cfg.NewTracer()
	if err != nil {
		log.Printf("Could not initialize jaeger tracer: %s", err.Error())
		return
	}
	defer closer.Close()

	opentracing.SetGlobalTracer(tracer)

	//Database
	db = connectDB()
	defer db.Close()

	router := mux.NewRouter().StrictSlash(true)

	histogram := prometheus.NewHistogramVec(prometheus.HistogramOpts{
		Name: "webservice_uri_duration_seconds",
		Help: "Time to respond",
	}, []string{"uri"})

	promCounter := prometheus.NewCounterVec(prometheus.CounterOpts{
		Name: "webservice_count",
		Help: "counter for api",
	}, []string{"uri"})

	/// Root
	var handlerStatus http.Handler
	handlerStatus = LoggerMiddleware(handlerStatusFunc, "root", histogram, nil)
	router.
		Methods("GET").
		Path(prefixPath).
		Name("root").
		Handler(handlerStatus)

	/// Métier
	var handlerFacture http.Handler
	handlerFacture = LoggerMiddleware(handlerFactureFunc, "facture_get", histogram, promCounter)
	router.
		Methods("GET").
		Path(prefixPath + "facture").
		Name("facture_get").
		Handler(handlerFacture)

	var handlerClient http.Handler
	handlerClient = LoggerMiddleware(handlerClientFunc, "client_get", histogram, promCounter)
	router.
		Methods("GET").
		Path(prefixPath + "client").
		Name("client_get").
		Handler(handlerClient)

	/// Monitoring
	var handlerIP http.Handler
	handlerIP = LoggerMiddleware(handlerIPFunc, "ips_get", histogram, nil)
	router.
		Methods("GET").
		Path(prefixPath + "ips").
		Name("ips_get").
		Handler(handlerIP)

	var handlerHealth http.Handler
	handlerHealth = LoggerMiddleware(handlerHealthFunc, "healthz", histogram, nil)
	router.
		Methods("GET").
		Path(prefixPath + "healthz").
		Name("healthz").
		Handler(handlerHealth)

	var readyHealth http.Handler
	readyHealth = LoggerMiddleware(handlerHealthFunc, "ready", histogram, nil)
	router.
		Methods("GET").
		Path(prefixPath + "ready").
		Name("ready").
		Handler(readyHealth)

	//Hack
	var putLatencyHealth http.Handler
	putLatencyHealth = LoggerMiddleware(putLatencyFunc, "latency", histogram, nil)
	router.
		Methods("PUT").
		Path(prefixPath + "hack/latency/{latency_ms}").
		Name("latency").
		Handler(putLatencyHealth)

	var postFileHealth http.Handler
	postFileHealth = LoggerMiddleware(postFileFunc, "create_file", histogram, nil)
	router.
		Methods("POST").
		Path(prefixPath + "hack/file").
		Name("create_file").
		Handler(postFileHealth)

	// add prometheus
	prometheus.Register(histogram)
	prometheus.Register(promCounter)
	router.Methods("GET").Path(prefixPath + "metrics").Name("Metrics").Handler(promhttp.Handler())

	// CORS
	headersOk := handlers.AllowedHeaders([]string{"authorization", "content-type"})
	originsOk := handlers.AllowedOrigins([]string{"*"})
	methodsOk := handlers.AllowedMethods([]string{"GET", "HEAD", "POST", "PUT", "OPTIONS"})

	http.ListenAndServe(":8080", handlers.CORS(originsOk, headersOk, methodsOk)(router))
}
