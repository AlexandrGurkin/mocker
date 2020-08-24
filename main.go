package main

import (
	"log"
	"net/http"

	"github.com/AlexandrGurkin/mocker/internal/controllers"
)

func main() {
	http.HandleFunc("/", controllers.HomeRouterHandler) // установим роутер
	err := http.ListenAndServe(":9000", nil)            // задаем слушать порт

	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
