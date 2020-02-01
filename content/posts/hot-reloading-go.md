---
title: "Hot Reloading Go"
description: "Utilizando Docker e reflex para desenvolver um web server em Go"
date: 2020-02-01T10:37:56-03:00
draft: false
tags: [docker, go, docker-compose]
---

*O exemplo utilizado nesse post foi baseado na seção 1.7 do livro 'The Go Programming Language'*

Ao realizar leitura do capítulo citado anteriormente, que mencionava a facilidade de se implementar
um web server em Go, tive a ideia de
implementar um hot-reloader do zero.

Segue um passo-a-passo de como realizei essa implementação.

Código: https://github.com/rafaelmatsumoto/hotreloading-go

## Pré-requisitos:

- Docker
- Docker Compose
- Go

## Guia

Primeiro passo, criar um script básico para rodar a aplicação:

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

Para rodar a aplicação é preciso executar o comando:

<pre>go run main.go &</pre>

Ao realizar uma requisição GET:

<pre>http localhost:8000
<font color="#0087FF">HTTP</font><font color="#8A8A8A">/</font><font color="#00AFAF">1.1</font><font color="#8A8A8A"> </font><font color="#00AFAF">200</font><font color="#8A8A8A"> </font><font color="#AF8700">OK</font>
<font color="#8A8A8A">Content-Length: </font><font color="#00AFAF">15</font>
<font color="#8A8A8A">Content-Type: </font><font color="#00AFAF">text/plain; charset=utf-8</font>
<font color="#8A8A8A">Date: </font><font color="#00AFAF">Sat, 01 Feb 2020 16:55:20 GMT</font>

<font color="#8A8A8A">URL.Path = &quot;/&quot;</font></pre>

### Implementando a funcionalidade de hot reloading

É necessário criar um Dockerfile com a seguinte configuração:

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

A biblioteca reflex permite adicionar um listener para executar um comando sempre que algum tipo de arquivo
for alterado, a configuração que utilizei foi:

./reflex.conf
```txt
-r '(\.go$|go\.mod)' -s go run main.go &
```

A partir dessa configuração, toda vez que um arquivo com a extensão .go ou o go.mod for alterado, o servidor é
derrubado e reinicializado.

Após essa etapa, definimos um docker-compose.yml para facilitar a utilização do Docker:

```yml
# ./docker-compose.yml
version: '2.4'
services:
  app:
    build: .
    volumes:
      - .:/app
    working_dir: /app
    ports:
      - 8000:8000
```

E alterar o script principal para o servidor aceitar requisições externas:

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

E então rodamos o comando <pre>docker-compose up -d</pre> e pronto, toda nova alteração será automaticamente implementada.

Exemplo na prática:

<script id="asciicast-1lIUUTqHHKZuQi50OOQUQ3G66" src="https://asciinema.org/a/1lIUUTqHHKZuQi50OOQUQ3G66.js" async></script>

