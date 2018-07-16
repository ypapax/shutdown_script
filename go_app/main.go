package main

import (
	"os"
	"os/signal"
	"syscall"
	"time"

	"flag"

	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"

	"github.com/golang/glog"
)

var AppName string

func main() {
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt, os.Kill, syscall.SIGTERM)
	appName := flag.String("name", "", "application name")
	flag.Parse()
	if len(*appName) == 0 {
		glog.Error("empty -name")
		flag.Usage()
		return
	}
	AppName = *appName
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
				postListenerLog("cleanup started")

				time.Sleep(time.Second)
				glog.Infof("cleanup is finished")
				postListenerLog("cleanup is finished")
			}(sig)
		}
	}()
	glog.Infof("started go app %+v", AppName)
	postListenerLog("started go app")
	time.Sleep(time.Hour)
	glog.Flush()
}

func postListenerLog(msg string) error {
	h, err := os.Hostname()
	if err != nil {
		glog.Error(err)
		return err
	}
	glog.Infof("sending msg to postlistener: %+v", msg)
	if err := post("http://trap_exit.requestcatcher.com/test", nil, map[string]string{
		"msg":    msg,
		"time":   time.Now().Format(time.RFC3339),
		"source": h + "_golang_" + AppName,
	}, nil); err != nil {
		glog.Error(err)
		return err
	}
	return nil
}

func post(url string, headers, body map[string]string, result interface{}) error {
	client := &http.Client{}
	payload, err := json.Marshal(body)
	if err != nil {
		glog.Error(err)
		return err
	}
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(payload))
	if err != nil {
		glog.Error(err)
		return err
	}
	for h, v := range headers {
		req.Header.Set(h, v)
	}
	glog.V(4).Infof("%+v", curlPostStr(url, payload, headers))
	res, err := client.Do(req)
	if err != nil {
		glog.Error(err)
		return err
	}
	defer res.Body.Close()
	b, err := ioutil.ReadAll(res.Body)
	if err != nil {
		glog.Error(err)
		return err
	}
	glog.V(4).Info(string(b))
	if result == nil {
		return nil
	}
	if err := json.Unmarshal(b, result); err != nil {
		glog.Error(err)
		return err
	}
	return nil
}

func curlPostStr(url string, payload []byte, headers map[string]string) string {
	return fmt.Sprintf("curl -XPOST -d'%+v' %+v %+v", string(payload), url, headersCurlStr(headers))
}

func headersCurlStr(headers map[string]string) string {
	headersStr := ""
	for h, v := range headers {
		headersStr += fmt.Sprintf(" -H '%+v: %+v' ", h, v)
	}
	return headersStr
}
