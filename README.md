Note: `DECAPOD (DEClarative APplication Orchestration & Delivery)` is a pilot project leveraging Kustomize, Helm Operator, Argo Workflow to deploy applications on Kubernetes. 

# decapod-yaml
`decapod-yaml` helps templating Kubernetes yaml files according to your environment.  
Currently, it provides `LMA` and `OpenStack` templates.

Prerequisite
------------
- Install [Docker](https://docs.docker.com/get-docker/)


## Features
_Provide `Easily Identifiable` and `Easily Configurable` Templates_


OpenStack Structures:
```
.
 ├── base
 │   ├── kustomization.yaml
 │   ├── resources.yaml
 │   └── site-values.yaml
 └── network
     ├── linuxbridge-flat-vlan.yaml
     ├── linuxbridge-flat-vlan-vxlan.yaml
     ├── openvswitch-flat-vlan.yaml
     └── openvswitch-flat-vlan-vxlan.yaml
```

Usage
=============
> FYI, Below example is based on OpenStack.
### 1) Build your own site
First, you should choose image, network site-values in LMA/OpenStack and write own `kustomization.yaml`.
Feel free to use sample yaml. [Here](https://github.com/jabbukka/site-yaml/) it is.

> ```
> $ mkdir -p lma/site/dev/
> $ touch lma/site/dev/kustomization.yaml  
> ```

lma/site/dev/kustomization.yaml:
> ```
>resources:
>  - ../../base
>    
>transformers:
>  - site-values.yaml
>```

### 2) Override site-values.yaml
Copy site-values.yaml and update the values.
> ```
> $ cp base/site-values.yaml site/dev/
> $ vi site/dev/site-values.yaml
> ```

### 3) Build OpenStack templates with `kustomize-plugin`
Option 1. Using docker image
> ```
> $ docker run -it -v $(pwd)/site:/site -v $(pwd)/decapod-yaml/$APP_NAME/base:/base -v $(pwd)/$APP_NAME/output:/output sktdev/decapod-kustomize:alpha-v2.0 /site/dev -o output-manifest.yaml
> ```

Option 2. Using a [render.sh](https://github.com/openinfradev/decapod-yaml/blob/master/render.sh) script
> ```
> $ # ./render.sh APP_NAME SITE_NAME
> $ ./render.sh lma dev
> ```
