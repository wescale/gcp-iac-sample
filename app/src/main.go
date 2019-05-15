package main

import (
	"net/http"
	"os"

	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus/promhttp"

	opentracing "github.com/opentracing/opentracing-go"

	"github.com/jinzhu/gorm"

	log "github.com/sirupsen/logrus"
)

var (
	db *gorm.DB
)

func init() {
	// Log as JSON instead of the default ASCII formatter.
	log.SetFormatter(&log.TextFormatter{})

	// Output to stdout instead of the default stderr
	// Can be any io.Writer, see below for File example
	log.SetOutput(os.Stdout)

	// Only log the warning severity or above.
	log.SetLevel(log.InfoLevel)
}

func main() {

	/// Tracer
	tracer, closer, err := initJaeger()
	if err != nil {
		log.Info("Jaeger error")
		log.Fatal(err)
	}
	defer closer.Close()
	opentracing.SetGlobalTracer(tracer)
	histogram, promCounter := initPrometheus()

	//Database
	db = connectDB()
	defer db.Close()

	prefixPath := os.Getenv("PREFIX_PATH")
	router := mux.NewRouter().StrictSlash(true)

	/// Root
	var handlerStatus http.Handler
	handlerStatus = SimpleMiddleware(handlerStatusFunc)
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
	router.
		Methods("GET").
		Path(prefixPath + "ready").
		Name("ready").
		Handler(handlerHealth)

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

	router.Methods("GET").Path(prefixPath + "metrics").Name("Metrics").Handler(promhttp.Handler())

	// CORS
	headersOk := handlers.AllowedHeaders([]string{"authorization", "content-type"})
	originsOk := handlers.AllowedOrigins([]string{"*"})
	methodsOk := handlers.AllowedMethods([]string{"GET", "HEAD", "POST", "PUT", "OPTIONS"})

	log.Info("Start server... at 8080")
	http.ListenAndServe(":8080", handlers.CORS(originsOk, headersOk, methodsOk)(router))
}
