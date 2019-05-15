package main

import (
	"net/http"
	"time"
	"strings"
	"context"

	"github.com/prometheus/client_golang/prometheus"

	"github.com/opentracing/opentracing-go/ext"
	opentracing "github.com/opentracing/opentracing-go"
	"github.com/smacker/opentracing-gorm"
	"github.com/jinzhu/gorm"

	log "github.com/sirupsen/logrus"
)

// ComposeHandle to test
type ComposeHandle func(http.ResponseWriter, *http.Request, *gorm.DB) (error)


// LoggerMiddleware add logger and metrics
func LoggerMiddleware(inner ComposeHandle, name string, histogram *prometheus.HistogramVec, counter *prometheus.CounterVec) http.Handler {

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		start := time.Now()

		ctx := context.Background()

		if strings.Compare(name,"healthz") != 0 && strings.Compare(name,"ready") != 0 {
			var span opentracing.Span
			wireContext, err := opentracing.GlobalTracer().Extract(
				opentracing.HTTPHeaders,
				opentracing.HTTPHeadersCarrier(r.Header))
			if err != nil {
				log.Warn(err)
				log.Info(r.Header)
			}

			// Create the span referring to the RPC client if available.
			// If wireContext == nil, a root span will be created.
			span = opentracing.StartSpan(
				name,
				ext.RPCServerOption(wireContext))

			defer span.Finish()

			ctx = opentracing.ContextWithSpan(ctx, span)
		}

		tdb := otgorm.SetSpanToGorm(ctx, db)
		err := inner(w, r.WithContext(ctx), tdb)

		if err != nil {
			log.WithFields(log.Fields{
				"method": r.Method,
				"uri": r.RequestURI,
				"name": name,
			  }).Warn(err)
		}

		if strings.Compare(name,"healthz") != 0  && strings.Compare(name,"ready") != 0 {
			time := time.Since(start)
			log.WithFields(log.Fields{
				"method": r.Method,
				"uri": r.RequestURI,
				"name": name,
				"time": time,
			  }).Info("call")

			histogram.WithLabelValues(r.RequestURI).Observe(time.Seconds())
			if counter != nil {
				counter.WithLabelValues(r.RequestURI).Inc()
			}
		}
	})
}


// SimpleMiddleware for simple handler
func SimpleMiddleware(inner http.HandlerFunc) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		inner.ServeHTTP(w, r)
	})
}
