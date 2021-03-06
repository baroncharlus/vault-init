FROM golang:1.10.2
WORKDIR /go/src/app
COPY . .
RUN CGO_ENABLE=0 GOOS=linux go build -o vault-init -v .

FROM debian:latest
COPY --from=0 /go/src/app/vault-init .
ENTRYPOINT ["/vault-init"]
