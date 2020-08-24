package main

import (
	"github.com/AlexandrGurkin/mocker/internal/controllers"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", controllers.HomeRouterHandler) // установим роутер
	err := http.ListenAndServe(":9000", nil)            // задаем слушать порт
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
