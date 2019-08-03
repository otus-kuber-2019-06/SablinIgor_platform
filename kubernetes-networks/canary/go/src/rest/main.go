package main

import (
	"fmt"
	"net/http"
	"os"
	"github.com/gorilla/mux"
	"github.com/joho/godotenv"
)

var GetVersion = func(w http.ResponseWriter, r *http.Request) {
	resp := "Version: 0.1"

	fmt.Fprintf(w, resp)
}

func main()  {
	err := godotenv.Load()
	if err != nil {
		fmt.Println("Error loading .env file")
	}

	router := mux.NewRouter()

	router.HandleFunc("/", GetVersion).Methods("Get")

	port := os.Getenv("PORT")

	if port == "" {
		port = "8000"
	}

	fmt.Println(port)

	err = http.ListenAndServe(":" + port, router)

	if err != nil {
		fmt.Println(err)
	}
}
