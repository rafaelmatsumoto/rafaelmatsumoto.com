---
title: "Docker for Node apps"
description: "Improving Docker configuration in Node apps"
date: 2020-02-02T17:57:24-03:00
draft: false
tags: [docker, node, docker-compose]
---

Here are some tips to improve Docker in Node applications.

-  The `.dockerignore` file:

You should never add the `node_modules` folder straight you machine, it makes the image insanely larger and makes the build much slower. 
For that reason, `node_modules` should be added to your `.dockerignore` file.

_Before_

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
Step 6/6 : CMD ["yarn", "start"
 ---&gt; Using cache
 ---&gt; 57e18f433874
Successfully built 57e18f433874
Successfully tagged node-docker:latest
```

_After_

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

_Dockerfile recommended for development environments only_

```dockerfile
# Alpine images are known for being lightweight and secure.
FROM node:12-alpine

# Docker caches layers that don't change when you run builds multiple times,
# since it is rare that the exposed port changes, it is worth to place this command
# on the top of the file.
EXPOSE 3000

WORKDIR /app

# The wildcard (*) tells Docker that it should copy the lockfile,
# but not to throw an error if it doesn't exist.
COPY package.json yarn.lock* ./

RUN yarn && yarn cache clean

COPY . .

CMD ["yarn", "start"]
```

- docker-compose.yml

```yml
# The version 2.* of Docker Compose is recommended for development environments
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
        # In versions 2.*, it is possible to set a healthcheck, 
        # so that your container waits for another one to be fully ready
        # to start.
        condition: service_healthy

  db:
    image: postgres:9.6
    volumes:
      # It is highly recommended to use named-volumes to persist database information.
      # Mapping the volume straight to the OS may cause performance bottlenecks and it might not work
      # at all.
      - db-data:/var/lib/postgresql/data
    healthcheck:
      # Test if the database is ready to connect.
      test: pg_isready -U postgres -h 127.0.0.1

volumes:
  db-data:
```
