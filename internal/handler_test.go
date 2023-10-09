package internal

import (
	"bytes"
	"io"
	"net/http"
	"strconv"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestShouldPad(t *testing.T) {
	// make headers map
	headers := http.Header{}
	headers.Add(PADDING_HEADER, "1")

	r := &http.Request{
		Method: http.MethodPost,
		Header: headers,
	}

	p, ok := shouldPad(r)

	assert.Equal(t, p, 1, "shouldPad should return 1 when "+PADDING_HEADER+" is set to 1")
	assert.Equal(t, ok, true, "shouldPad should return true when "+PADDING_HEADER+" header is set")
}

func TestPadRequestJSON(t *testing.T) {
	testBody := `{"foo":"bar"}`
	originalContentLength := len(testBody)
	paddingMultiple := 1
	// newContentLength := int64((paddingMultiple * 1024) + originalContentLength)

	// make headers map
	headers := http.Header{}
	headers.Add("Content-Length", strconv.Itoa(originalContentLength))
	headers.Add(PADDING_HEADER, strconv.Itoa(paddingMultiple))

	r := &http.Request{
		Method: http.MethodPost,
		Header: headers,
		Body:   io.NopCloser(bytes.NewBufferString(testBody)),
	}

	PadRequestJSON(r)

	assert.Empty(t, r.Header.Get(PADDING_HEADER))
	assert.GreaterOrEqual(t, r.ContentLength, int64(originalContentLength))
}

func TestPadRequest(t *testing.T) {
	testBody := "test"
	originalContentLength := len(testBody)
	paddingMultiple := 1
	newContentLength := int64((paddingMultiple * 1024) + originalContentLength)

	// make headers map
	headers := http.Header{}
	headers.Add("Content-Length", strconv.Itoa(originalContentLength))
	headers.Add(PADDING_HEADER, strconv.Itoa(paddingMultiple))

	r := &http.Request{
		Method: http.MethodPost,
		Header: headers,
		Body:   io.NopCloser(bytes.NewBufferString(testBody)),
	}

	PadRequest(r)

	assert.Empty(t, r.Header.Get(PADDING_HEADER))
	assert.Equal(t, newContentLength, r.ContentLength)
}
