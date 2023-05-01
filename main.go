package main

import (
	"crypto/x509"
	"net"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/AdguardTeam/golibs/log"
	"github.com/AdguardTeam/gomitmproxy"
	"github.com/AdguardTeam/gomitmproxy/mitm"

	btk "github.com/ghostsecurity/waf-btk/internal"

	_ "net/http/pprof"
)

func main() {
	// log.SetLevel(log.DEBUG)

	// mitmproxy will generate it's own self-signed cert,
	// but we need to provide a CA cert and private key
	tlsCert, caPrivateKey, _ := btk.GenerateCACert()

	caCert, err := x509.ParseCertificate(tlsCert)
	if err != nil {
		log.Fatal(err)
	}

	mitmConfig, err := mitm.NewConfig(caCert, caPrivateKey, nil)
	if err != nil {
		log.Fatal(err)
	}

	// sets the validity window of the proxy cert
	// from: time.Now() - period
	// to: time.Now() + period
	// a 7 day period results in a 14 day validity window
	mitmConfig.SetValidity(time.Hour * 24 * 7)
	mitmConfig.SetOrganization(btk.PROXY_HOST)

	// Prepare the proxy.
	addr := &net.TCPAddr{
		IP:   net.IPv4(127, 0, 0, 1),
		Port: 8888,
	}

	proxy := gomitmproxy.NewProxy(gomitmproxy.Config{
		ListenAddr: addr,
		APIHost:    btk.PROXY_HOST,
		MITMConfig: mitmConfig,
		OnRequest:  btk.RequestHandler,
		// not used
		// OnResponse: ResponseHandler,
		// not used
		// OnConnect: ConnectHandler,
	})

	err = proxy.Start()
	if err != nil {
		log.Fatal(err)
	}

	signalChannel := make(chan os.Signal, 1)
	signal.Notify(signalChannel, syscall.SIGINT, syscall.SIGTERM)
	<-signalChannel

	// Stop the proxy.
	proxy.Close()
}
