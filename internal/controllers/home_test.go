package controllers

import (
	"net/http"
	"net/http/httptest"
	"net/url"
	"testing"
)

func TestHomeRouterHandler(t *testing.T) {
	type args struct {
		w http.ResponseWriter
		r *http.Request
	}
	tests := []struct {
		name string
		args args
	}{
		{"test", args{
			w: httptest.NewRecorder(),
			r: &http.Request{
				Method: "GET",
				URL: &url.URL{
					Scheme:      "http",
					Opaque:      "",
					User:        nil,
					Host:        "",
					Path:        "/api",
					RawPath:     "",
					ForceQuery:  false,
					RawQuery:    "",
					Fragment:    "",
					RawFragment: "",
				},
				Proto:            "",
				ProtoMajor:       0,
				ProtoMinor:       0,
				Header:           http.Header{"Authorization": {"value"}},
				Body:             nil,
				GetBody:          nil,
				ContentLength:    0,
				TransferEncoding: nil,
				Close:            false,
				Host:             "",
				Form:             nil,
				PostForm:         nil,
				MultipartForm:    nil,
				Trailer:          nil,
				RemoteAddr:       "",
				RequestURI:       "",
				TLS:              nil,
				Cancel:           nil,
				Response:         nil,
			},
		}},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			HomeRouterHandler(tt.args.w, tt.args.r)
			if rec, ok := tt.args.w.(*httptest.ResponseRecorder); ok {
				if rec.Result().StatusCode != 200 {
					t.Error("wrong status code")
				}
			}
		})
	}
}
