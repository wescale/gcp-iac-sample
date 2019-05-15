package main

import (
	"encoding/json"
	"net/http"
	"os"
	"time"

	"github.com/jinzhu/gorm"
	_ "github.com/go-sql-driver/mysql"
	"github.com/smacker/opentracing-gorm"

	log "github.com/sirupsen/logrus"
)

func connectDB() *gorm.DB {
	var err error

	myhost := os.Getenv("MYSQL_HOST")
	myport := os.Getenv("MYSQL_PORT")
	myuser := os.Getenv("MYSQL_USER")
	mypwd  := os.Getenv("MYSQL_PASSWORD")
	mydata := os.Getenv("MYSQL_DATABASE")

	db, err = gorm.Open("mysql", myuser+":"+mypwd+"@tcp("+myhost+":"+myport+")/"+mydata+"?charset=utf8mb4&parseTime=True&loc=Local")
	if err != nil {
		log.Fatal(err)
	}
	// register callbacks must be called for a root instance of your gorm.DB
    otgorm.AddGormCallbacks(db)

	// Migrate the schema
  	db.AutoMigrate(&Facture{})
	db.AutoMigrate(&Client{})
	
	db.Create(&Facture{Contrat: "Gemalto", Days: 1.5, Cost: 22.2})
	db.Create(&Client{Name: "Gemalto", Service: "Formation"})

	return db
}

// Facture a test facture struct
type Facture struct {
	gorm.Model
	Contrat string  `json:"contrat" gorm:"contrat"`
	Days    float32 `json:"days" gorm:"days"`
	Cost    float32 `json:"cost" gorm:"cost"`
}

// Client a test client struct
type Client struct {
	gorm.Model
	Name    string `json:"name" gorm:"name"`
	Service string `json:"service" gorm:"service"`
}

func handlerFactureFunc(w http.ResponseWriter, r *http.Request, tdb *gorm.DB) error {
	var fct Facture

	tdb.First(&fct, "contrat = ?", "Gemalto")

	// wait for latency
	time.Sleep(time.Duration(latency) * time.Millisecond)

	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(http.StatusOK)

	return json.NewEncoder(w).Encode(fct)
}

func handlerClientFunc(w http.ResponseWriter, r *http.Request, tdb *gorm.DB) error {
	var clt Client

	tdb.First(&clt, "name = ?", "Gemalto")

	// wait for latency
	time.Sleep(time.Duration(latency) * time.Millisecond)

	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(http.StatusOK)

	return json.NewEncoder(w).Encode(clt)
}
