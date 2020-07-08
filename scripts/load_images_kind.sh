#!/usr/bin/env bash
set -euo errexit
# List of images generated from following command after successful kind creation build, removing duplicates
# kubectl get pods --all-namespaces -o jsonpath="{..image}" | tr -s '[[:space:]]' '\n' | sort -u
images=(
    "docker.io/coredns/coredns:1.6.5"
    "docker.io/grafana/grafana:6.4.3"
    "docker.io/prom/prometheus:v2.12.0"
    "docker.io/jaegertracing/all-in-one:1.14"
    "quay.io/kiali/kiali:v1.15"
    "docker.io/istio/citadel:1.4.7"
    "docker.io/istio/galley:1.4.7"
    "docker.io/istio/kubectl:1.4.7"
    "docker.io/istio/mixer:1.4.7"
    "docker.io/istio/node-agent-k8s:1.4.7"
    "docker.io/istio/pilot:1.4.7"
    "docker.io/istio/proxyv2:1.4.7"
    "docker.io/istio/sidecar_injector:1.4.7"
    "kubernetesui/metrics-scraper:v1.0.1"
    "kubernetesui/dashboard:v2.0.0-beta8"
    "istio/examples-bookinfo-productpage-v1:1.15.0"
    "istio/examples-bookinfo-details-v1:1.15.0"
    "istio/examples-bookinfo-ratings-v1:1.15.0"
    "istio/examples-bookinfo-ratings-v2:1.15.0"
    "istio/examples-bookinfo-reviews-v1:1.15.0"
    "istio/examples-bookinfo-reviews-v2:1.15.0"
    "istio/examples-bookinfo-reviews-v3:1.15.0"
    "istio/examples-bookinfo-mongodb:1.15.0"
    "jettech/kube-webhook-certgen:v1.2.0"
    "quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.32.0"
    "gcr.io/google-samples/hello-app:1.0"
    # "docker.io/rancher/metrics-server:v0.3.3"
    # "docker.io/weaveworks/flagger-loadtester:0.6.1"
    # "docker.io/weaveworks/flagger:0.18.4"
    # "gcr.io/google_containers/defaultbackend:1.4"
    # "k8s.gcr.io/kube-apiserver:v1.18.2"
    # "k8s.gcr.io/kube-controller-manager:v1.18.2"
    # "k8s.gcr.io/kube-proxy:v1.18.2"
    # "k8s.gcr.io/kube-scheduler:v1.18.2"
    # "quay.io/open-policy-agent/gatekeeper:v3.0.4-beta.2"
    # "quay.io/spotahome/redis-operator:latest"
    )
for image in "${images[@]}"; do
    image_log="$(echo "${image}" | sed 's/\///g')"
    # This is faster then checking via the internet if the image is present using just docker pull
    # run the downloads and load in parallel in the background to reduce time by ~30%
    ( if ! docker inspect --type=image "${image}" > /dev/null 2>&1  ; then
        docker pull "${image}" 2>&1
    fi
     kind load docker-image --name kind --nodes kind-control-plane "${image}" 2>&1
    # minikube cache add "${image}" 2>&1
    echo "${image} load complete" ) 2>&1 &
done
wait