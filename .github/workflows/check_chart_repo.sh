#!/bin/bash
# set -e
set -ex

VALIDATE_TARGET_REPO='https://openinfradev.github.io'
EXCEPTION_LIST=
#'https://prometheus-community.github.io/helm-charts,https://grafana.github.io/helm-charts,https://kubernetes.github.io/ingress-nginx,https://charts.appscode.com/stable,https://kubernetes-sigs.github.io/metrics-server/'

for i in `find | grep resources.yaml`
do
  if [ $EXCEPTION_LIST ]; then
    .github/workflows/check_repo.py -m $i -r $VALIDATE_TARGET_REPO -t chart -e $EXCEPTION_LIST
  else 
    .github/workflows/check_repo.py -m $i -r $VALIDATE_TARGET_REPO -t chart
  fi
done
