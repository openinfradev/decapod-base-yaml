#!/bin/bash
set -ex

VALIDATE_TARGET_REPO='https://openinfradev.github.io'
EXCEPTION_LIST=
#'https://prometheus-community.github.io/helm-charts,https://grafana.github.io/helm-charts,https://kubernetes.github.io/ingress-nginx,https://charts.appscode.com/stable,https://kubernetes-sigs.github.io/metrics-server/'

DECAPOD_BASE_URL=https://github.com/openinfradev/decapod-base-yaml.git
BRANCH="main"
DOCKER_IMAGE_REPO="docker.io"
GITHUB_IMAGE_REPO="ghcr.io"
outputdir="output"

rm -rf decapod-base-yaml
site_list=$(ls -d */ | sed 's/\///g' | grep -v 'docs' | grep -v $outputdir | grep -v 'offline')

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
      (-s|--site)
            site_list=$2; shift 2;;
      (-r|--registry)
            DOCKER_IMAGE_REPO=$2
            GITHUB_IMAGE_REPO=$2; shift 2;;
      (--)  shift; break;;
      (*)   exit 1;;           # error
    esac
done

echo "[render-cd] dacapod branch=$BRANCH, output target=$outputdir ,target site(s)=${site_list}\n\n"

for app in `ls -d */ | egrep -v docs`
do
  # helm-release file name rendered on 1st phase
  hr_file="$app/${app/\//}-manifest.yaml"

  echo "Rendering $hr_file"
  docker run --rm -i -v $(pwd)/$app:/$app --name kustomize-build ${DOCKER_IMAGE_REPO}/sktcloud/decapod-render:v2.0.0  kustomize build --enable-alpha-plugins /${app}/base -o /$hr_file
  build_result=$?

  if [ $build_result != 0 ]; then
    exit $build_result
  fi

  if [ -f "$hr_file" ]; then
    echo "[render-cd] [$site, $app] Successfully Generate Helm-Release Files!"
  else
    echo "[render-cd] [$site, $app] Failed to render $app-manifest.yaml"
    exit 1
  fi


  if [ $EXCEPTION_LIST ]; then
    .github/workflows/check_repo.py -m $hr_file -r $VALIDATE_TARGET_REPO -t image -e $EXCEPTION_LIST
  else 
    .github/workflows/check_repo.py -m $hr_file -r $VALIDATE_TARGET_REPO -t image
  fi

  # docker run --rm -i --net=host -v $(pwd)/decapod-base-yaml:/decapod-base-yaml -v $(pwd)/$outputdir:/out --name generate ${DOCKER_IMAGE_REPO}/sktcloud/decapod-render:v2.0.0 helm2yaml/helm2yaml -m /$hr_file -t -o /out/$site/$app

  rm $hr_file

done