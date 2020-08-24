package main

import (
	"log"
	"net/http"

	"github.com/AlexandrGurkin/mocker/internal/controllers"
)

func main() {
	http.HandleFunc("/", controllers.HomeRouterHandler)

	err := http.ListenAndServe(":9000", nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
