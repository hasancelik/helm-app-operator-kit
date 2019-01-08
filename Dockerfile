FROM golang:1.10 as builder
ARG HELM_CHART
ARG API_VERSION
ARG KIND
WORKDIR /go/src/github.com/operator-framework/helm-app-operator-kit/helm-app-operator
COPY helm-app-operator .
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
RUN dep ensure -v
RUN CGO_ENABLED=0 GOOS=linux go build -o bin/operator cmd/manager/main.go
RUN chmod +x bin/operator

FROM  registry.access.redhat.com/rhel-atomic
LABEL name="Hazelcast-Operator" \
      maintainer="connect-tech@redhat.com" \
      vendor="RHC" \
      version="0.1.3" \
      release="v1" \
      summary="Hazelcast Operator" \
      description="Helm App Operator for Hazelcast"
ARG HELM_CHART
ARG API_VERSION
ARG KIND
ENV API_VERSION $API_VERSION
ENV KIND $KIND
WORKDIR /
COPY --from=builder \
/go/src/github.com/operator-framework/helm-app-operator-kit/helm-app-operator/bin/operator /operator
COPY LICENSE /licenses/
ADD $HELM_CHART /chart
ENV HELM_CHART /chart/hazelcast

CMD ["/operator"]
