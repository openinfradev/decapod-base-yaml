# Quick Start

## Prerequisite
- Install [Docker](https://docs.docker.com/get-docker/)


## Render decapod-base-yaml
```console
$ git clone https://github.com/openinfradev/decapod-base-yaml.git

$ # build lma
$ docker run --rm -i -v $(pwd)/decapod-base-yaml:/decapod-base-yaml sktdev/decapod-kustomize:latest kustomize build --enable_alpha_plugins /decapod-base-yaml/lma/base

$ # build openstack
$ docker run --rm -i -v $(pwd)/decapod-base-yaml:/decapod-base-yaml sktdev/decapod-kustomize:latest kustomize build --enable_alpha_plugins /decapod-base-yaml/openstack/base
```

## Render decapod-site
`decapod-site` is a sample site YAML.  
```console
$ git clone https://github.com/openinfradev/decapod-site.git
$ cd decapod-site
$ .github/workflows/render.sh <base_branch> # replace base_branch to the proper branch what you want to use. Default branch is 'main'.
Fetch base with main branch/tag........
Cloning into 'decapod-base-yaml'...
remote: Enumerating objects: 139, done.
remote: Counting objects: 100% (139/139), done.
remote: Compressing objects: 100% (102/102), done.
remote: Total 526 (delta 51), reused 95 (delta 26), pack-reused 387
Receiving objects: 100% (526/526), 184.05 KiB | 1.06 MiB/s, done.
Resolving deltas: 100% (183/183), done.

Starting build manifests for 'hanu-deploy-apps' site
Rendering lma-manifest.yaml for hanu-deploy-apps site
2021/03/22 01:26:59 Attempting plugin load from '/root/.config/kustomize/plugin/openinfradev.github.com/v1/helmvaluestransformer/HelmValuesTransformer.so'
[hanu-deploy-apps] Successfully Completed!
Rendering openstack-manifest.yaml for hanu-deploy-apps site
2021/03/22 01:27:00 Attempting plugin load from '/root/.config/kustomize/plugin/openinfradev.github.com/v1/helmvaluestransformer/HelmValuesTransformer.so'
[hanu-deploy-apps] Successfully Completed!
Rendering service-mesh-manifest.yaml for hanu-deploy-apps site
2021/03/22 01:27:02 Attempting plugin load from '/root/.config/kustomize/plugin/openinfradev.github.com/v1/helmvaluestransformer/HelmValuesTransformer.so'
[hanu-deploy-apps] Successfully Completed!

$ head hanu-deploy-apps/lma/lma-manifest.yaml
apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
metadata:
  labels:
    name: addons
  name: addons
spec:
  chart:
    name: lma-addons
    repository: https://openinfradev.github.io/hanu-helm-repo
```

## Make your own site-yaml
1. Fork [decapod-site](https://github.com/openinfradev/decapod-site) to your repository.
2. Clone decapod-site from your repository.
3. Make your site directory
   ```console
   $ # In case of LMA
   $ mkdir -p decapod-site/YOUR_SITE_NAME/lma
   ```
4. Copy [site-values.yaml](https://github.com/openinfradev/decapod-base-yaml/blob/main/lma/base/site-values.yaml) and overlays (image, network ...) into your site directory.  
   ```console
   $ cp decapod-base-yaml/lma/base/site-values.yaml decapod-site/YOUR_SITE_NAME/lma
   $ # (Optional)
   $ cp decapod-base-yaml/lma/image/image-values.yaml decapod-site/YOUR_SITE_NAME/lma
   ```
5. Write kustomization.yaml into `decapod-site/YOUR_SITE_NAME/lma`.
   ```yaml
   resources:
     - ../../base
      
   transformers:
     - site-values.yaml
     #- image-values.yaml
   ```
6. run render.sh
   ```console
   $ .github/workflows/render.sh
   ```
