package main

import (
    "fmt"
    "net/http"
)

func main() {
    http.HandleFunc("/auth", AuthServer)
    http.ListenAndServe("localhost:8080", nil)
}

func AuthServer(w http.ResponseWriter, r *http.Request) {	
	if (r.Method == "POST") {
		fmt.Printf("API Key Value: %s\n", r.Header.Get("X-API-KEY"))	
		auth_header := r.Header.Get("X-API-KEY")
		if (auth_header == "PERMITTED_API_KEY") {
			w.WriteHeader(http.StatusOK)
			w.Write([]byte("200 - API Key is valid!\n"))
			return
		}
	}
	w.WriteHeader(http.StatusForbidden)
	w.Write([]byte("403 - API Key is Invalid!\n"))	
}