# Quick Start

## Prerequisite
- Install [Docker](https://docs.docker.com/get-docker/)


## Render decapod-base-yaml
```console
$ git clone https://github.com/openinfradev/decapod-base-yaml.git

$ # build lma
$ docker run --rm -i -v decapod-base-yaml:/decapod-base-yaml sktdev/decapod-kustomize:latest kustomize build --enable_alpha_plugins /decapod-base-yaml/lma/base

$ # build openstack
$ docker run --rm -i -v decapod-base-yaml:/decapod-base-yaml sktdev/decapod-kustomize:latest kustomize build --enable_alpha_plugins /decapod-base-yaml/openstack
```

## Render decapod-site-yaml
`decapod-site-yaml` is a sample site YAML.  
```console
$ git clone https://github.com/openinfradev/decapod-site-yaml.git
$ cd decapod-site-yaml
$ .github/workflows/render.sh <product_name> # replace product_name to lma or openstack or cloud-console.
Fetch base with main branch/tag........
Cloning into 'decapod-base-yaml'...
remote: Enumerating objects: 35, done.
remote: Counting objects: 100% (35/35), done.
remote: Compressing objects: 100% (23/23), done.
remote: Total 254 (delta 19), reused 21 (delta 11), pack-reused 219
Receiving objects: 100% (254/254), 81.52 KiB | 397.00 KiB/s, done.
Resolving deltas: 100% (75/75), done.
Start to build for lma
[hanu-deploy-apps] Clean up existing lma-manifest.yaml
[hanu-deploy-apps] Rendering lma-manifest.yaml for hanu-deploy-apps site
2021/01/14 07:23:02 Attempting plugin load from '/root/.config/kustomize/plugin/openinfradev.github.com/v1/helmvaluestransformer/HelmValuesTransformer.so'
[hanu-deploy-apps] Successfully Completed!

$ ls lma/output/hanu-deploy-apps
lma-manifest.yaml
```

## Make your own site-yaml
1. Fork [decapod-site-yaml](https://github.com/openinfradev/decapod-site-yaml) to your repository.
2. Clone decapod-site-yaml from your repository.
3. Make your site directory
   ```console
   $ # In case of LMA
   $ mkdir -p decapod-site-yaml/lma/site/YOUR_SITE_NAME
   ```
4. Copy [site-values.yaml](https://github.com/openinfradev/decapod-base-yaml/blob/main/lma/base/site-values.yaml) and overlays (image, network ...) into your site directory.  
   ```console
   $ cp decapod-base-yaml/lma/base/site-values.yaml decapod-site-yaml/lma/site/YOUR_SITE_NAME
   $ # (Optional)
   $ cp decapod-base-yaml/lma/image/image-values.yaml decapod-site-yaml/lma/site/YOUR_SITE_NAME
   ```
5. Write kustomization.yaml into `decapod-site-yaml/lma/site/YOUR_SITE_NAME`.
   ```yaml
   resources:
     - ../../base
      
   transformers:
     - site-values.yaml
     #- image-values.yaml
   ```
6. run render.sh
   ```console
   $ .github/workflows/render.sh lma
   ```
