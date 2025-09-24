package main

import (
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Game Host Agent OK"))
	})

	log.Println("Game Host Agent in ascolto su :8090")
	log.Fatal(http.ListenAndServe(":8090", nil))
}
