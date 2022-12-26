To find a common way to get source IP no matter direct connection, via forward proxy, via MITM proxy, or NAT

# How to test?

1. `vagrant up`

2. ssh to server

    ```console
    cd /vagrant
    make setup-server-key
    make run-greeter-server
    ```

3. ssh to proxy

    * Forward proxy
    ```console
    cd /vagrant
    make run-squidproxy
    ```

    * MITM proxy

    ```console
    cd /vagrant
    make run-mitmproxy
    ```

4. ssh to client

    ```console
    cd /vagrant
    make setup-server-key
    make run-greeter-server
    ```

# Test result

## Bridge Network

Client (172.31.1.10) > [(opt) Proxy (172.31.1.20) >] Server (192.168.1.10)

| Use Case    | peer        | x-real-ip   | x-forwarded-host | x-forwarded-for  | authority        |
| ----------- | ----------- | ----------- | ---------------- | ---------------- | ---------------- |
| DIRECT GRPC | 192.168.1.1 | N/A         | N/A              | N/A              | 192.168.1.10:8081|
| DIRECT HTTP | 127.0.0.1   | N/A         | 192.168.1.10:8080| 192.168.1.1      | 192.168.1.10     |
| FWProxy GRPC| 192.168.1.1 | N/A         | N/A              | N/A              | 192.168.1.10:8081|
| FWProxy HTTP| 127.0.0.1   | N/A         | 192.168.1.10:8080| 192.168.1.1      | 192.168.1.10     |
| MITM GRPC   | 192.168.1.1 | N/A         | N/A              | N/A              | 192.168.1.10:8081|
| MITM HTTP   | 127.0.0.1   | N/A         | 192.168.1.10:8080| 192.168.1.1      | 192.168.1.10     |

## NAT Network (1.160.105.176)

Client (172.31.1.10) > [(opt) Proxy (172.31.1.20) >] Server (44.204.136.57)

| Use Case    | peer          | x-real-ip   | x-forwarded-host  | x-forwarded-for  | authority         |
| ----------- | ------------- | ----------- | ----------------- | ---------------- | ----------------- |
| DIRECT GRPC | 1.160.105.176 | N/A         | N/A               | N/A              | 44.204.136.57:8081|
| DIRECT HTTP | 127.0.0.1     | N/A         | 44.204.136.57:8080| 1.160.105.176    | 44.204.136.57     |
| FWProxy GRPC| 1.160.105.176 | N/A         | N/A               | N/A              | 44.204.136.57:8081|
| FWProxy HTTP| 127.0.0.1     | N/A         | 44.204.136.57:8080| 1.160.105.176     | 44.204.136.57    |
| MITM GRPC   | 1.160.105.176 | N/A         | N/A               | N/A              | 44.204.136.57:8081|
| MITM HTTP   | 127.0.0.1     | N/A         | 44.204.136.57:8080| 1.160.105.176     | 44.204.136.57    |
