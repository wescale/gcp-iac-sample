FROM golang:1.11-alpine AS build-env
RUN apk add --no-cache bash ca-certificates git gcc g++ libc-dev git
RUN mkdir -p $GOPATH/src/app
ENV GO111MODULE=on
WORKDIR $GOPATH/src/app
COPY go.mod .
COPY go.sum .
RUN go mod download

FROM build-env AS build-stage
WORKDIR $GOPATH/src/app
COPY . .
RUN go install

# final stage
FROM alpine
RUN apk add --no-cache curl
ENV PREFIX_PATH /
WORKDIR /app
COPY --from=build-stage /go/bin/app /app/
HEALTHCHECK --interval=5s --retries=3 --timeout=5s CMD curl -f http://localhost:8080/healthz || exit 1
ENTRYPOINT ./app
EXPOSE 8080