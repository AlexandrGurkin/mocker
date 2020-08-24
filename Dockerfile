FROM golang:1.15 AS builder
ADD . /mocker
WORKDIR /mocker
#ENV GODEBUG netdns=cgo
ENV CGO_ENABLED=0
RUN make build

#
FROM alpine
# ENV GODEBUG netdns=cgo
WORKDIR /mocker
COPY --from=builder /mocker/mocker /usr/local/bin/mocker
CMD /usr/local/bin/mocker