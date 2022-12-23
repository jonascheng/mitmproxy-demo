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

Client (10.1.0.20) > [(opt) Proxy (10.1.0.30) >] Server (10.1.0.10)

| Use Case    | peer        | x-real-ip   | x-forwarded-host | x-forwarded-for  |
| ----------- | ----------- | ----------- | ---------------- | ---------------- |
| DIRECT GRPC | 10.1.0.20   | N/A         | N/A              | N/A              |
| DIRECT HTTP | 127.0.0.1   | N/A         | 10.1.0.10:8080   | 10.1.0.20        |
| FWProxy GRPC| 10.1.0.30   | N/A         | N/A              | N/A              |
| FWProxy HTTP| 127.0.0.1   | N/A         | 10.1.0.10:8080   | 10.1.0.30        |
| MITM GRPC   | 10.1.0.30   | N/A         | N/A              | N/A              |
| MITM HTTP   | 127.0.0.1   | N/A         | 10.1.0.10:8080   | 10.1.0.30        |
