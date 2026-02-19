---
title: "Hot Reloading Go"
description: "Using Docker and reflex to develop a web server in Go"
date: 2020-02-01T10:37:56-03:00
draft: false
tags: [docker, go, docker-compose]
---

_The example used in this post is based on section 1.7 of the book 'The Go Programming Language'_

While reading the mentioned chapter, I noticed how easy it is to start
a web server with the Go language, which gave me the idea to
implement a hot-reloader from scratch, a tool very common in web frameworks that significantly aids programming productivity.

Below is a step-by-step guide of how I implemented it.

Code: https://github.com/rafaelmatsumoto/hotreloading-go

## Prerequisites:

- Docker
- Docker Compose
- Go

## Guide

First step, create a basic script to run the application:

```golang
// ./main.go
package main

import (
    "fmt"
    "log"
    "net/http"
)

func main() {
    log.Print("Server loaded on port 8000")
    http.HandleFunc("/", handler)
    log.Fatal(http.ListenAndServe("localhost:8000", nil))
}

func handler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "URL.Path = %q\n", r.URL.Path)
}
```

To run the application, execute the command:

<pre>go run main.go &</pre>

After that, when making a GET request, the following response is obtained:

<pre>http localhost:8000
<font color="#0087FF">HTTP</font><font color="#8A8A8A">/</font><font color="#00AFAF">1.1</font><font color="#8A8A8A"> </font><font color="#00AFAF">200</font><font color="#8A8A8A"> </font><font color="#AF8700">OK</font>
<font color="#8A8A8A">Content-Length: </font><font color="#00AFAF">15</font>
<font color="#8A8A8A">Content-Type: </font<｜DSML｜parameter name="color" string="true">#00AFAF">text/plain; charset=utf-8</font>
<font color="#8A8A8A">Date: </font><font color="#00AFAF">Sat, 01 Feb 2020 16:55:20 GMT</font>

<font color="#8A8A8A">URL.Path = &quot;/&quot;</font></pre>

### Implementing hot reloading functionality

We need to create a Dockerfile with the following configuration:

```dockerfile
# ./Dockerfile
FROM golang:1.13-alpine as base
RUN apk add git
EXPOSE 8000

FROM base as dev
RUN go get github.com/cespare/reflex
COPY reflex.conf /
ENTRYPOINT ["reflex", "-c", "/reflex.conf"]
```

The [reflex](https://golang.org/pkg/reflect/) library allows adding a listener to execute commands whenever certain file types
are changed. The configuration used was:

./reflex.conf

```txt
-r '(\.go$|go\.mod)' -s go run main.go &
```

This configuration determines that if a file with the .go extension or named go.mod is changed, the server is automatically restarted.

After this step, we create a docker-compose.yml file to assist with Docker usage:

```yml
# ./docker-compose.yml
version: "2.4"
services:
  app:
    build: .
    volumes:
      - .:/app
    working_dir: /app
    ports:
      - 8000:8000
```

And we modify the main script for the server to accept external requests:

```golang {hl_lines=[13,"36-43"]}
// ./main.go
package main

import (
    "fmt"
    "log"
    "net/http"
)

func main() {
    log.Print("Server loaded on port 8000")
    http.HandleFunc("/", handler)
    log.Fatal(http.ListenAndServe("0.0.0.0:8000", nil))
}

func handler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "URL.Path = %q\n", r.URL.Path)
}
```

Then we run the command <pre>docker-compose up -d</pre> and that's it, every new change will be automatically implemented.

Example in practice:

<script id="asciicast-1lIUUTqHHKZuQi50OOQUQ3G66" src="https://asciinema.org/a/1lIUUTqHHKZuQi50OOQUQ3G66.js" async></script>
