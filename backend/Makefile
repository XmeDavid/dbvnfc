SHELL := /bin/bash

.PHONY: tidy build run migrate dev docker-up docker-down

tidy:
	go mod tidy

build:
	go build -o bin/server ./cmd/server

run:
	DATABASE_URL?=postgres://app:app@localhost:5432/app?sslmode=disable
	JWT_SECRET?=dev-secret
	CORS_ORIGINS?=*
	PORT?=4000
	DATABASE_URL=$(DATABASE_URL) JWT_SECRET=$(JWT_SECRET) CORS_ORIGINS=$(CORS_ORIGINS) PORT=$(PORT) go run ./cmd/server

migrate:
	go run ./cmd/server # migrations run at startup

dev:
	nodemon --exec 'go run ./cmd/server' --ext go,sql --signal SIGTERM

docker-up:
	docker compose up -d --build

docker-down:
	docker compose down
