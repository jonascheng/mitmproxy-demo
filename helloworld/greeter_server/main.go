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

// Package main implements a server for Greeter service.
package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"net/http"
	"strings"

	"github.com/jonascheng/mitmproxy-demo/helloworld/greeter_server/util"

	"github.com/grpc-ecosystem/grpc-gateway/v2/runtime"
	pb "github.com/jonascheng/mitmproxy-demo/helloworld/proto"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/peer"
)

// server is used to implement helloworld.GreeterServer.
type server struct {
	pb.UnimplementedGreeterServer
}

// SayHello implements helloworld.GreeterServer
func (s *server) SayHello(ctx context.Context, in *pb.HelloRequest) (*pb.HelloReply, error) {
	// client IP from metadata
	var clientIP string
	if md, ok := metadata.FromIncomingContext(ctx); ok {
		log.Printf("metadata: %v", md)
	}

	if md, ok := metadata.FromIncomingContext(ctx); ok {
		clientIP = ""
		rips := md.Get("x-real-ip")
		if len(rips) != 0 {
			log.Printf("x-real-ip: %v", rips)
			clientIP = rips[0]
		}
		log.Println("Received from client IP (x-real-ip): ", clientIP)
	}

	if md, ok := metadata.FromIncomingContext(ctx); ok {
		clientIP = ""
		fwdAddress := md.Get("x-forwarded-for")
		if len(fwdAddress) != 0 {
			rips := strings.Split(fwdAddress[0], ", ")
			if len(rips) != 0 {
				log.Printf("Received x-forwarded-for: %v", rips)
				clientIP = rips[0]
			}
		}
		log.Println("Received from client IP (x-forwarded-for[0]): ", clientIP)
	}

	// peer IP
	var peerIP string
	if pr, ok := peer.FromContext(ctx); ok {
		if tcpAddr, ok := pr.Addr.(*net.TCPAddr); ok {
			peerIP = tcpAddr.IP.String()
		} else {
			peerIP = pr.Addr.String()
		}
		log.Println("Received from peer IP: ", peerIP)
	}

	log.Printf("Received: %v", in.GetName())
	return &pb.HelloReply{Message: "Hello " + in.GetName()}, nil
}

func main() {
	config, err := util.LoadConfig(".")
	if err != nil {
		log.Fatal("cannot load config:", err)
	}

	// Create a listener on TCP port
	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", config.ServerListenPort))
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	// Create a gRPC server
	s := grpc.NewServer()
	// Greeter service
	pb.RegisterGreeterServer(s, &server{})

	// Create a gRPC-Gateway mux
	gwmux := runtime.NewServeMux()
	dops := []grpc.DialOption{grpc.WithTransportCredentials(insecure.NewCredentials())}
	err = pb.RegisterGreeterHandlerFromEndpoint(context.Background(), gwmux, fmt.Sprintf("0.0.0.0:%d", config.ServerListenPort), dops)
	if err != nil {
		log.Fatalln("Failed to register gwmux:", err)
	}

	mux := http.NewServeMux()
	mux.Handle("/", gwmux)

	// Define HTTP server configuration
	gwServer := &http.Server{
		Addr:    fmt.Sprintf("0.0.0.0:%d", config.ServerListenPort),
		Handler: grpcHandlerFunc(s, mux), // unified request entry
	}
	log.Println("Serving on http://0.0.0.0:", config.ServerListenPort)
	log.Fatalln(gwServer.Serve(lis)) // start http server
}

// grpcHandlerFunc to distinguish gPRC and HTTP requests
func grpcHandlerFunc(grpcServer *grpc.Server, otherHandler http.Handler) http.Handler {
	return h2c.NewHandler(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.ProtoMajor == 2 && strings.Contains(r.Header.Get("Content-Type"), "application/grpc") {
			log.Printf("Received a grpc request")
			grpcServer.ServeHTTP(w, r)
		} else {
			log.Printf("Received a http request, forward to gRPC-Gateway")
			otherHandler.ServeHTTP(w, r)
		}
	}), &http2.Server{})
}
