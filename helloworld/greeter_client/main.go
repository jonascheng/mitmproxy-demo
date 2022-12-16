/*
 *
 * Copyright 2015 gRPC authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

// Package main implements a client for Greeter service.
package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net"
	"net/url"
	"time"

	"github.com/jonascheng/mitmproxy-demo/helloworld/greeter_client/util"

	pb "github.com/jonascheng/mitmproxy-demo/helloworld/proto"
	http_dialer "github.com/mwitkow/go-http-dialer"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

const (
	defaultName = "world"
)

var (
	addr = flag.String("addr", "localhost:50051", "the address to connect to")
	name = flag.String("name", defaultName, "Name to greet")
)

func main() {
	config, err := util.LoadConfig(".")
	if err != nil {
		log.Fatal("cannot load config:", err)
	}

	// Set up a connection to the server.
	dialOptions := []grpc.DialOption{
		grpc.WithTransportCredentials(insecure.NewCredentials())}
	if config.ServerProxy != "" {
		dialer := grpc.WithContextDialer(func(c context.Context, s string) (net.Conn, error) {
			proxyURL, err := url.Parse(config.ServerProxy)

			if err != nil {
				return nil, err
			}

			dialer := http_dialer.New(proxyURL)
			log.Printf("Proxy: %s", proxyURL)

			return dialer.Dial("tcp", s)
		})
		dialOptions = append(dialOptions, dialer)
	}

	conn, err := grpc.Dial(
		fmt.Sprintf("%s:%d", config.ServerIp, config.ServerPort),
		dialOptions...)
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()
	c := pb.NewGreeterClient(conn)

	// Contact the server and print out its response.
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()
	r, err := c.SayHello(ctx, &pb.HelloRequest{Name: config.ClientName})
	if err != nil {
		log.Fatalf("could not greet: %v", err)
	}
	log.Printf("Greeting: %s", r.GetMessage())

	// pause on purpose
	fmt.Println("Press the Enter Key to terminate the console screen!")
	fmt.Scanln() // wait for Enter Key
}
