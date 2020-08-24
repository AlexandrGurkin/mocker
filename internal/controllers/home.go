// Package controllers is internal package with handlers.
package controllers

import (
	"fmt"
	"net/http"
	"strings"
)

// HomeRouterHandler is handler for printing incoming request.
func HomeRouterHandler(w http.ResponseWriter, r *http.Request) {
	_ = r.ParseForm()
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)
	fmt.Println("scheme", r.URL.Scheme)
	fmt.Println("auth", r.Header.Values("Authorization"))
	fmt.Println(r.Form["url_long"])

	for k, v := range r.Form {
		fmt.Println("key:", k)
		fmt.Println("val:", strings.Join(v, ""))
	}

	fmt.Fprintf(w, "Hello World!") // отправляем данные на клиентскую сторону
}
