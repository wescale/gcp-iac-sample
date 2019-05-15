package main

import (
	"io"

	opentracing "github.com/opentracing/opentracing-go"
	jaegercfg "github.com/uber/jaeger-client-go/config"

	"github.com/prometheus/client_golang/prometheus"
	log "github.com/sirupsen/logrus"
)

func initJaeger() (opentracing.Tracer, io.Closer, error){
	cfg, err := jaegercfg.FromEnv()
	if err != nil {
		// parsing errors might happen here, such as when we get a string where we expect a number
		log.Info("Could not parse Jaeger env vars")
		log.Fatal(err)
		return nil, nil, err
	}

	tracer, closer, err := cfg.NewTracer()
	if err != nil {
		log.Info("Could not initialize jaeger tracer")
		log.Fatal(err)
		return nil, nil, err
	}

	return tracer, closer, nil
}

func initPrometheus()(*prometheus.HistogramVec, *prometheus.CounterVec){
	histogram := prometheus.NewHistogramVec(prometheus.HistogramOpts{
		Name: "webservice_uri_duration_seconds",
		Help: "Time to respond",
	}, []string{"uri"})

	promCounter := prometheus.NewCounterVec(prometheus.CounterOpts{
		Name: "webservice_count",
		Help: "counter for api",
	}, []string{"uri"})

	// add prometheus
	prometheus.Register(histogram)
	prometheus.Register(promCounter)
	
	return histogram, promCounter
}