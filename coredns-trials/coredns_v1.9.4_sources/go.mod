module github.com/coredns/coredns

go 1.17

require (
	github.com/Azure/azure-sdk-for-go v66.0.0+incompatible
	github.com/Azure/go-autorest/autorest v0.11.28
	github.com/Azure/go-autorest/autorest/azure/auth v0.5.11
	github.com/apparentlymart/go-cidr v1.1.0
	github.com/aws/aws-sdk-go v1.44.91
	github.com/coredns/caddy v1.1.1
	github.com/dnstap/golang-dnstap v0.4.0
	github.com/farsightsec/golang-framestream v0.3.0
	github.com/go-logr/logr v1.2.3
	github.com/grpc-ecosystem/grpc-opentracing v0.0.0-20180507213350-8e809c8a8645
	github.com/infobloxopen/go-trees v0.0.0-20200715205103-96a057b8dfb9
	github.com/matttproud/golang_protobuf_extensions v1.0.1
	github.com/miekg/dns v1.1.50
	github.com/opentracing/opentracing-go v1.2.0
	github.com/openzipkin-contrib/zipkin-go-opentracing v0.4.5
	github.com/openzipkin/zipkin-go v0.4.0
	github.com/oschwald/geoip2-golang v1.8.0
	github.com/prometheus/client_golang v1.13.0
	github.com/prometheus/client_model v0.2.0
	github.com/prometheus/common v0.37.0
	go.etcd.io/etcd/api/v3 v3.5.4
	go.etcd.io/etcd/client/v3 v3.5.4
	golang.org/x/crypto v0.0.0-20220722155217-630584e8d5aa
	golang.org/x/sys v0.0.0-20220804214406-8e32c043e418
	google.golang.org/api v0.94.0
	google.golang.org/grpc v1.49.0
	google.golang.org/protobuf v1.28.1
	gopkg.in/DataDog/dd-trace-go.v1 v1.41.0
	k8s.io/api v0.25.0
	k8s.io/apimachinery v0.25.0
	k8s.io/client-go v0.24.4
	k8s.io/klog/v2 v2.80.0
)

require (
	github.com/Azure/go-autorest/autorest/to v0.2.0 // indirect
	github.com/imdario/mergo v0.3.12 // indirect
	go.uber.org/atomic v1.9.0 // indirect
)
