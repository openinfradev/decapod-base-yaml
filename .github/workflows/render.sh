#!/bin/bash
if [ $# -eq 0 ]; then
  echo 'Error: Missing Arguments "application name"'
  exit 1
fi
APP_NAME=$1
BUILD_PATH=/$APP_NAME/base

if [ $# -eq 2 ]; then
  BUILD_PATH=/$APP_NAME/$2
fi

echo "Start to build for $APP_NAME"
docker run --rm -i -v $(pwd)/$APP_NAME:/$APP_NAME --name kustomize-build-$APP_NAME sktdev/decapod-kustomize:latest kustomize build --enable_alpha_plugins $BUILD_PATH -o $APP_NAME-manifest.yaml
build_result=$?

if [ $build_result != 0 ]; then
  exit $build_result
fi