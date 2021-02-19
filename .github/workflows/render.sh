#!/bin/bash
if [ $# -eq 0 ]; then
  echo 'Error: Missing Arguments "application name"'
  exit 1
fi
APP_NAME=$1

echo "Start to build for $APP_NAME"
docker run --rm -i -v $(pwd)/$APP_NAME:/$APP_NAME --name kustomize-build-$APP_NAME sktdev/decapod-kustomize:latest kustomize build --enable_alpha_plugins /$APP_NAME/base -o $APP_NAME-manifest.yaml
build_result=$?

if [ $build_result != 0 ]; then
  exit $build_result
fi