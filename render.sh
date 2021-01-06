#!/bin/bash
DECAPOD_BASE_URL=https://github.com/openinfradev/decapod-base-yaml.git
BRANCH="master"

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

for i in `ls ${APP_NAME}/site`
do

   OUTPUT_PATH="$APP_NAME/output/$i/$APP_NAME-manifest.yaml"
   echo "[$i] Clean up existing $APP_NAME-manifest.yaml"
   rm -f $OUTPUT_PATH
   mkdir -p $APP_NAME/output/$i/
   docker rm -f kustomize-build-$APP_NAME
   echo "[$i] Rendering $APP_NAME-manifest.yaml for $i site"
   docker run -it -v $(pwd)/$APP_NAME/site:/site -v $(pwd)/decapod-yaml/$APP_NAME/base:/base -v $(pwd)/$APP_NAME/output:/output --name kustomize-build-$APP_NAME sktdev/decapod-kustomize:alpha-v2.0 /site/$i -o /output/$i/$APP_NAME-manifest.yaml;

   if [ -f "$OUTPUT_PATH" ]; then
     echo "[$i] Successfully Completed!"
   else
     echo "[$i] Failed to render -manifest.yaml"
     break
   fi

done

rm -rf decapod-yaml
