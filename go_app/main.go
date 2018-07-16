package main

import (
	"os"
	"os/signal"
	"syscall"
	"time"

	"flag"

	"github.com/golang/glog"
)

func main() {
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt, os.Kill, syscall.SIGTERM)
	flag.Parse()
	go func() {
		for sig := range c {
			func(sig os.Signal) {
				glog.V(4).Infof("signal %+v is called", sig)
				defer func() {
					glog.Info("Exiting")
					glog.Flush()
					os.Exit(1)
				}()
				glog.Infof("cleanup started")
				time.Sleep(time.Second)
				glog.Infof("cleanup is finished")
			}(sig)
		}
	}()
	glog.Infof("started go app")
	time.Sleep(time.Hour)
	glog.Flush()
}
