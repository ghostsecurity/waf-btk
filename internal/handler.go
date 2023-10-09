package internal

import (
	"bytes"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"strconv"
	"strings"

	"github.com/AdguardTeam/gomitmproxy"
)

const (
	PROXY_HOST     = "waf-btk"
	PADDING_HEADER = "waf-btk-padding"
)

func RequestHandler(session *gomitmproxy.Session) (*http.Request, *http.Response) {
	req := session.Request()

	log.Printf("onRequest: %s %s", req.Method, req.URL.String())

	// add a custom tracking header
	req.Header.Add("x-ghost-method", "mitm")

	if req.Method == http.MethodPost {
		switch req.Header.Get("Content-Type") {
		case "application/json":
			PadRequestJSON(req)
		default:
			PadRequest(req)
		}
	}

	return nil, nil
}

// padRequestJSON pads a JSON POST request
func PadRequestJSON(req *http.Request) {
	log.Println("[*] received JSON POST request")
	if padding, ok := shouldPad(req); ok {
		originalBody, _ := io.ReadAll(req.Body)

		if len(originalBody) == 0 {
			return
		}

		// decode to json
		var data map[string]interface{}
		decoder := json.NewDecoder(strings.NewReader(string(originalBody)))
		_ = decoder.Decode(&data)

		// map will be empty if json is invalid
		if len(data) == 0 {
			return
		}

		// add padding to the json with a key that is unlikely to be used
		data["__waf_bypass"] = strings.Repeat("A", padding*1024)

		// marshall the new request body back into json
		newBody, _ := json.Marshal(data)
		rewriteAndCloseBody(req, newBody)
	}
}

// padRequest pads a POST request
func PadRequest(req *http.Request) {
	log.Println("[*] received POST request")
	if padding, ok := shouldPad(req); ok {
		originalBody, _ := io.ReadAll(req.Body)

		if len(originalBody) == 0 {
			return
		}

		newBody := append([]byte(strings.Repeat("A", padding*1024)), originalBody...)
		rewriteAndCloseBody(req, newBody)
	}
}

// shouldPad checks if the request should be padded
func shouldPad(req *http.Request) (int, bool) {
	h := req.Header.Get(PADDING_HEADER)
	if h != "" {
		pad, _ := strconv.Atoi(h)
		log.Println("[*] removing " + PADDING_HEADER + " header")
		req.Header.Del(PADDING_HEADER)
		return pad, true
	}
	return 0, false
}

func rewriteAndCloseBody(req *http.Request, newBody []byte) {
	originalContentLength := req.ContentLength
	req.ContentLength = int64(len(newBody))
	log.Printf("[*] content length changed from: %d to %d\n", originalContentLength, req.ContentLength)
	req.Body = io.NopCloser(bytes.NewBuffer(newBody))
}
