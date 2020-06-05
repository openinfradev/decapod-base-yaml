Note: `DECAPOD (DEClarative APplication Orchestration & Delivery)` is a pilot project leveraging Kustomize, Helm Operator, Argo Workflow to deploy applications on Kubernetes. 

# decapod-yaml
`decapod-yaml` helps templating Kubernetes yaml files according to your environment.  
Currently, it provides `LMA` and `OpenStack` templates.

Prerequisite
------------
- Install [Kustomize++](https://github.com/keleustes/kustomize)

## Features
_Provide `Easily Identifiable` and `Easily Configurable` Templates_


OpenStack Structures:
```
.
 ├── baremetal
 │   ├── kustomization.yaml
 │   ├── overlay1.yaml
 │   └── resources.yaml
 ├── base
 │   ├── kustomization.yaml
 │   ├── resources.yaml
 │   └── site-values.yaml
 ├── network
 │   ├── linuxbridge-flat-vlan
 │   │   ├── kustomization.yaml
 │   │   └── overlay1.yaml
 │   ├── linuxbridge-flat-vlan-vxlan
 │   │   ├── kustomization.yaml
 │   │   └── overlay1.yaml
 │   ├── openvswitch-flat-vlan
 │   │   ├── kustomization.yaml
 │   │   ├── overlay1.yaml
 │   │   └── resources.yaml
 │   ├── openvswitch-flat-vlan-vxlan
 │   │   ├── kustomization.yaml
 │   │   ├── overlay1.yaml
 │   │   └── resources.yaml
 ├── os_release
 │   ├── queens
 │   │   ├── kustomization.yaml
 │   │   └── values.yaml
 │   └── stein
 │       ├── kustomization.yaml
 │       └── values.yaml
 └── storage
     ├── ceph
     │   ├── kustomization.yaml
     │   ├── overlay1.yaml
     │   └── resources.yaml
     └── nfs
         ├── kustomization.yaml
         ├── overlay1.yaml
         └── resources.yaml
```

Usage
=============
> FYI, Below example is based on OpenStack.
### 1) Write site specific files
First, you should choose network, storage overlay in OpenStack and write own kustomization.yaml.

create own site files below `site/${your_site}`.
> ```
> $ mkdir site/sample/
> $ touch site/sample/kustomization.yaml
> $ cp site/
> ```

openstack/site/sample/kustomization.yaml:
> ```
> resources:
> - ../../base
> - ../../os_release/stein
> - ../../storage/ceph
> 
> patchStrategicMerge:
> - ./../../storage/ceph/overlay1.yaml
> - ./../network/linuxbridge-flat-vlan-vxlan/overlay1.yaml
> ```

### 2) Override site-values.yaml
Copy site-values.yaml and update the values.
> ```
> $ cp base/site-values.yaml site/sample/
> $ vi site/sample/site-values.yaml
> ```

### 3) Build OpenStack templates using `kustomize`
> ```
> $ kustomize build site/sample/ --load_restrictor=none --reorder=kubectlapply -o output/sample/openstack.yaml
> ```

