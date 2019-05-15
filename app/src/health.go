package main

import (
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	"os"
	"strconv"

	"github.com/gorilla/mux"
	"github.com/jinzhu/gorm"
)

// Status a test status struct
type Status struct {
	Name string `json:"name"`
	Code int    `json:"code"`
}

// FileCreation for test unhealthy
type FileCreation struct {
	Path string `json:"path"`
}

func handlerHealthFunc(w http.ResponseWriter, r *http.Request, tdb *gorm.DB) error {
	var stt Status
	var statusCode int
	if _, err := os.Stat("/tmp/health_KO"); err == nil {
		stt.Name = "KO"
		stt.Code = 500
		statusCode = http.StatusInternalServerError
	} else {
		stt.Name = "OK"
		stt.Code = 200
		statusCode = http.StatusOK
	}
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(statusCode)

	return json.NewEncoder(w).Encode(stt)
}

func handlerStatusFunc(w http.ResponseWriter, r *http.Request) {
	stt := Status{Name: "OK", Code: 200}
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(http.StatusOK)

	if err := json.NewEncoder(w).Encode(stt); err != nil {
		panic(err)
	}
}

var latency int64

func putLatencyFunc(w http.ResponseWriter, r *http.Request, tdb *gorm.DB) error {
	vars := mux.Vars(r)
	latency, _ = strconv.ParseInt(vars["latency_ms"], 10, 64)

	stt := Status{Name: "Latency", Code: 200}
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(http.StatusOK)

	return json.NewEncoder(w).Encode(stt)
}

func postFileFunc(w http.ResponseWriter, r *http.Request, tdb *gorm.DB) error {

	decoder := json.NewDecoder(r.Body)

	var t FileCreation
	err := decoder.Decode(&t)
	fmt.Println(t)

	f, err := os.Create(t.Path)
	if err != nil {
		fmt.Println(err)
		panic(err)
	}
	defer f.Close()
	fmt.Println(t)

	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(http.StatusOK)

	return json.NewEncoder(w).Encode(t)
}

func handlerIPFunc(w http.ResponseWriter, r *http.Request, tdb *gorm.DB) error {
	var clt []string

	addrs, err := net.InterfaceAddrs()
	if err != nil {
		os.Stderr.WriteString("Oops: " + err.Error() + "\n")
		os.Exit(1)
	}

	for _, a := range addrs {
		if ipnet, ok := a.(*net.IPNet); ok && !ipnet.IP.IsLoopback() {
			if ipnet.IP.To4() != nil {
				clt = append(clt, ipnet.IP.String())
				os.Stdout.WriteString(ipnet.IP.String() + "\n")
			}
		}
	}

	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(http.StatusOK)

	return json.NewEncoder(w).Encode(clt)
}
