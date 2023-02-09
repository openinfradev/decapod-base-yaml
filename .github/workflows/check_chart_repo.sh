#!/bin/bash
# set -e
set -ex

VALIDATE_TARGET_REPO='https://harbor-cicd.taco-cat.xyz/tks'
#'https://openinfradev.github.io'
EXCEPTION_LIST=
#'https://argoproj.github.io/argo-helm,https://bitnami-labs.github.io/sealed-secrets,https://charts.appscode.com/stable,https://charts.appscode.com/stable/,https://charts.bitnami.com/bitnami,https://codecentric.github.io/helm-charts,https://grafana.github.io/helm-charts,https://helm-charts.wikimedia.org/stable/,https://helm.elastic.co,https://kiali.org/helm-charts,https://kubernetes-sigs.github.io/metrics-server/,https://kubernetes.github.io/ingress-nginx,https://prometheus-community.github.io/helm-charts'
#'https://kubernetes.github.io/ingress-nginx,https://charts.appscode.com/stable,https://kubernetes-sigs.github.io/metrics-server/'

DOCKER_IMAGE_REPO="docker.io"
GITHUB_IMAGE_REPO="ghcr.io"

for i in `find | grep resources.yaml | grep -v deprecated`
do
  if [ $EXCEPTION_LIST ]; then
    docker run --rm -i  -v $(pwd):/tmp --name validate ${DOCKER_IMAGE_REPO}/sktcloud/decapod-render:v3.1.0 helm2yaml/check_repo.py -m /tmp/$i -r $VALIDATE_TARGET_REPO -t chart -e $EXCEPTION_LIST
  else
    docker run --rm -i  -v $(pwd):/tmp --name validate ${DOCKER_IMAGE_REPO}/sktcloud/decapod-render:v3.1.0 helm2yaml/check_repo.py -m /tmp/$i -r $VALIDATE_TARGET_REPO -t chart
  fi
done