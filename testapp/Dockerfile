FROM golang:1.13

WORKDIR /src/

COPY ./ /src/

RUN go build -o bin/testapp

FROM debian:10-slim

COPY --from=0 /src/bin/testapp /usr/local/bin/testapp

CMD ["/usr/local/bin/testapp"]
