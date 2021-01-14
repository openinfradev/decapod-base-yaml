#!/bin/bash
DECAPOD_BASE_URL=https://github.com/openinfradev/decapod-base-yaml.git
BRANCH="main"

if [ $# -eq 0 ]; then
  echo 'Error: Missing Arguments "application name"'
  exit 1
fi
APP_NAME=$1

if [ $# -eq 2 ]; then
  BRANCH=$2
fi

echo "Fetch base with $BRANCH branch/tag........"
git clone -b $BRANCH $DECAPOD_BASE_URL
if [ $? -ne 0 ]; then
  exit $?
fi

echo "Start to build for $APP_NAME"
cp -r decapod-base-yaml/$APP_NAME/base $APP_NAME/
for i in `ls ${APP_NAME}/site`
do

   OUTPUT_PATH="$APP_NAME/output/$i/$APP_NAME-manifest.yaml"
   echo "[$i] Clean up existing $APP_NAME-manifest.yaml"
   rm -f $OUTPUT_PATH
   mkdir -p $APP_NAME/output/$i/

   echo "[$i] Rendering $APP_NAME-manifest.yaml for $i site"
   docker run --rm -i -v $(pwd)/$APP_NAME:/$APP_NAME --name kustomize-build-$APP_NAME sktdev/decapod-kustomize:latest kustomize build --enable_alpha_plugins /$APP_NAME/site/$i -o /$APP_NAME/output/$i/$APP_NAME-manifest.yaml
   build_result=$?

   if [ $build_result != 0 ]; then
     exit $build_result
   fi

   if [ -f "$OUTPUT_PATH" ]; then
     echo "[$i] Successfully Completed!"
   else
     echo "[$i] Failed to render $APP_NAME-manifest.yaml"
     rm -rf $APP_NAME/base
     rm -rf decapod-yaml
     exit 1
   fi

done

rm -rf $APP_NAME/base
rm -rf decapod-base-yaml
