---
title: "Docker para aplicações Node"
description: "Melhorando a configuração do Docker em aplicações Node"
date: 2020-02-02T17:57:24-03:00
draft: false
tags: [docker, node, docker-compose]
---

Algumas dicas para melhorar o desenvolvimento de aplicações Node
que utilizam o Docker.

- Arquivo .dockerignore:

É comum que na maioria das aplicações se adote esta prática,
porém a pasta node_modules aumenta de forma considerável o tamanho das imagens, e pode trazer problemas de compatibilidade entre máquina e container. Por isso colocá-los no arquivo .dockerignore é praticamente obrigatório.

_Antes_

```bash {hl_lines=[2]}
docker build . -t node-docker
Sending build context to Docker daemon  26.39MB
Step 1/6 : FROM node:12-alpine
 ---&gt; b0dc3a5e5e9e
Step 2/6 : WORKDIR /app
 ---&gt; Using cache
 ---&gt; 7cac4133ab5c
Step 3/6 : COPY package.json yarn.lock ./
 ---&gt; Using cache
 ---&gt; 87e948dbfba3
Step 4/6 : RUN yarn
 ---&gt; Using cache
 ---&gt; 05d0817ae728
Step 5/6 : COPY . .
 ---&gt; Using cache
 ---&gt; 4278e990be2f
Step 6/6 : CMD [&quot;yarn&quot;, &quot;start&quot;]
 ---&gt; Using cache
 ---&gt; 57e18f433874
Successfully built 57e18f433874
Successfully tagged node-docker:latest
```

_Depois_

```bash {hl_lines=[2]}
docker build . -t node-docker
Sending build context to Docker daemon  61.95kB
Step 1/6 : FROM node:12-alpine
 ---> b0dc3a5e5e9e
Step 2/6 : WORKDIR /app
 ---> Using cache
 ---> 7cac4133ab5c
Step 3/6 : COPY package.json yarn.lock ./
 ---> Using cache
 ---> 87e948dbfba3
Step 4/6 : RUN yarn
 ---> Using cache
 ---> 05d0817ae728
Step 5/6 : COPY . .
 ---> 3f7cbb6b132a
Step 6/6 : CMD ["yarn", "start"]
 ---> Running in 4aad47db651f
Removing intermediate container 4aad47db651f
 ---> 8002bf96db4a
Successfully built 8002bf96db4a
Successfully tagged node-docker:latest
```

- Dockerfile

_Dockerfile recomendado apenas para ambientes de desenvolvimento_

```dockerfile
# As versões do Linux Alpine são extremamente leves e seguras.
FROM node:12-alpine

# O Docker utiliza cache ao buildar linhas que não mudam
# É raro que a porta exposta mude,
# então busque colocá-la nas primeiras linhas do arquivo,
# ajuda a reduzir o tempo de build.
EXPOSE 3000

WORKDIR /app

# O wildcard * avisa ao docker para copiar o lockfile,
# mas não falhar caso esse não exista.
COPY package.json yarn.lock* ./

RUN yarn && yarn cache clean

COPY . .

CMD ["yarn", "start"]
```

- docker-compose.yml

```yml
# A versão 2.x do docker-compose.yml é a recomendada para
# ambientes de desenvolvimento.
version: "2.4"

services:
  app:
    build: .
    ports:
      - 3000:3000
    volumes:
      - .:/node/app
    depends_on:
      db:
        # Nessa versão (^2.4) é possível definir uma condição
        # para que o serviço de fato espere
        # até que o container de dependência esteja realmente pronto,
        # neste caso quando o postgres estiver disponível para
        # conexão.
        condition: service_healthy

  db:
    image: postgres:9.6
    volumes:
      # É recomendado fazer o uso de named-volumes para persistir
      # informações do banco de dados. Adicionar um volume diretamente
      # ao sistema operacional da máquina pode causar gargalos de
      # performance e até mesmo não funcionar.
      - db-data:/var/lib/postgresql/data
    healthcheck:
      # Teste para verificar a conexão.
      test: pg_isready -U postgres -h 127.0.0.1

volumes:
  db-data:
```
