#!/bin/bash
set -ex

VALIDATE_TARGET_REPO='https://harbor-cicd.taco-cat.xyz/tks'
EXCEPTION_LIST=
#'appscode/kubed:v0.12.0,appscode/kubed:v0.12.0-rc.3,busybox:1.31,busybox:1.31.1,calico/cni:v3.15.5,calico/kube-controllers:v3.15.5,calico/node:v3.15.5,calico/pod2daemon-flexvol:v3.15.5,directxman12/k8s-prometheus-adapter-amd64:v0.7.0,docker.elastic.co/eck/eck-operator:1.8.0,docker.elastic.co/elasticsearch/elasticsearch:7.5.1,docker.elastic.co/kibana/kibana:7.5.1,docker.io/bitnami/kube-state-metrics:1.9.7-debian-10-r143,docker.io/bitnami/minio:2021.6.14-debian-10-r0,docker.io/bitnami/postgresql:11.7.0-debian-10-r98,docker.io/bitnami/postgresql:15.1.0-debian-11-r0,docker.io/bitnami/thanos:0.17.2-scratch-r1,docker.io/grafana/loki:2.6.1,docker.io/grafana/promtail:2.4.1,docker.io/jboss/keycloak:10.0.0,docker.io/ncabatoff/process-exporter:0.2.11,docker.io/nginxinc/nginx-unprivileged:1.19-alpine,docker:19.03,ghcr.io/openinfradev/fluentbit:25bc31cd4333f7f77435561ec70bc68e0c73a194,ghcr.io/resmoio/kubernetes-event-exporter:v1.0,grafana/grafana:8.3.3,istio/pilot:1.13.1,istio/proxyv2:1.13.1,jaegertracing/jaeger-operator:1.29.1,k8s.gcr.io/autoscaling/cluster-autoscaler:v1.22.2,k8s.gcr.io/hyperkube:v1.18.8,k8s.gcr.io/ingress-nginx/controller:v1.1.1@sha256:0bc88eb15f9e7f84e8e56c14fa5735aaa488b840983f87bd79b1054190e660de,k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.0@sha256:f3b6b39a6062328c095337b4cadcefd1612348fdd5190b1dcbcb9b9e90bd8068,k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.1.1@sha256:64d8c73dca984af206adf9d6d7e46aa550362b1d7a01f3a0a91b20cc67868660,k8s.gcr.io/metrics-server/metrics-server:v0.6.1,kubesphere/fluent-operator:v1.5.0,prom/pushgateway:v1.3.0,quay.io/airshipit/kubernetes-entrypoint:v1.0.0,quay.io/argoproj/argocli:v3.2.6,quay.io/argoproj/workflow-controller:v3.2.6,quay.io/bitnami/sealed-secrets-controller:v0.16.0,quay.io/keycloak/keycloak-operator:17.0.0,quay.io/kiali/kiali-operator:v1.45.1,quay.io/kiwigrid/k8s-sidecar:1.14.2,quay.io/prometheus-operator/prometheus-operator:v0.52.0,quay.io/prometheus/alertmanager:v0.23.0,quay.io/prometheus/node-exporter:v1.0.1,quay.io/prometheus/prometheus:v2.31.1,rancher/local-path-provisioner:v0.0.22,siim/logalert-exporter:v0.1.1,sktdev/cloud-console:v1.0.4,sktdev/os-eventrouter:69a58b'

DECAPOD_BASE_URL=https://github.com/openinfradev/decapod-base-yaml.git
BRANCH="main"
DOCKER_IMAGE_REPO="docker.io"
GITHUB_IMAGE_REPO="ghcr.io"
outputdir="output"

rm -rf decapod-base-yaml

function usage {
        echo -e "\nUsage: $0 [--site TARGET_SITE] [--base_url DECAPOD_BASE_URL] [--registry REGISTRY_URL]"
        exit 1
}

# We use "$@" instead of $* to preserve argument-boundary information
ARGS=$(getopt -o 'b:s:r:h' --long 'base-url:,site:,registry:,help' -- "$@") || usage
eval "set -- $ARGS"

while true; do
    case $1 in
      (-h|--help)
            usage; shift 2;;
      (-b|--base-url)
            DECAPOD_BASE_URL=$2; shift 2;;
      (-r|--registry)
            DOCKER_IMAGE_REPO=$2
            GITHUB_IMAGE_REPO=$2; shift 2;;
      (--)  shift; break;;
      (*)   exit 1;;           # error
    esac
done

echo "[validate image repositories] dacapod branch=$BRANCH, output target=$outputdir.\n\n"
for app in `ls -d */ | egrep -v "docs|deprecated"`
do
  # helm-release file name rendered on 1st phase
  hr_file="$app/${app/\//}-manifest.yaml"

  echo "Rendering $hr_file"
  docker run --rm -i -v $(pwd)/$app:/$app --name kustomize-build ${DOCKER_IMAGE_REPO}/sktcloud/decapod-render:v3.1.0  kustomize build --enable-alpha-plugins /${app}/base -o /$hr_file
  build_result=$?

  if [ $build_result != 0 ]; then
    exit $build_result
  fi

  if [ -f "$hr_file" ]; then
    echo "[$app] Successfully Generate Helm-Release Files!"
  else
    echo "[$app] Failed to render $app-manifest.yaml"
    exit 1
  fi

  if [  -z "$EXCEPTION_LIST" ]; then
    # .github/workflows/check_repo.py -m $hr_file -r $VALIDATE_TARGET_REPO -t image
    docker run --rm -i --net=host -v $(pwd)/:/tmp --name generate ${DOCKER_IMAGE_REPO}/sktcloud/decapod-render:v3.1.0 helm2yaml/check_repo.py -m /tmp/$hr_file -r $VALIDATE_TARGET_REPO -t image
  else
    # .github/workflows/check_repo.py -m $hr_file -r $VALIDATE_TARGET_REPO -t image -e $EXCEPTION_LIST
    docker run --rm -i --net=host -v $(pwd)/:/tmp --name generate ${DOCKER_IMAGE_REPO}/sktcloud/decapod-render:v3.1.0 helm2yaml/check_repo.py -m /tmp/$hr_file -r $VALIDATE_TARGET_REPO -t image -e $EXCEPTION_LIST
  fi

  rm -f $hr_file

done

## Coner-case handling section begins

## Coner-case handling section ends