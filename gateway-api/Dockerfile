FROM golang:1.22 AS build

WORKDIR /app
COPY . .

RUN go mod init gateway-api && go mod tidy
RUN go build -o gateway-api main.go

FROM gcr.io/distroless/base
COPY --from=build /app/gateway-api /gateway-api

CMD ["/gateway-api"]
