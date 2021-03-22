# decapod-base-yaml
This project provides an easy way to create/maintain complex YAML files using kustomize and kustomize plugin.  
It works with [decapod-site](https://github.com/openinfradev/decapod-site) which contain differences between each environment (_e.g. development, staging and production environment_).  

## Features
* `base-yaml` and `site-yaml` structure
  * `base-yaml` is containig YAML resources and [overlays](https://kubectl.docs.kubernetes.io/references/kustomize/glossary/#overlay).
  * `site-yaml` contains a [site value](docs/glossary#site-value) and [variant](https://kubectl.docs.kubernetes.io/references/kustomize/glossary/#variant).
* Qualified [product](docs/glossary.md#product)
  * LMA(Logging, Monitoring, Alert)
  * OpenStack
  * Cloud Console

## Documents
* [Quick start](docs/quickstart.md)
* [Concept](docs/concept.md)
* [Glossary](docs/glossary.md)
* [Contribution](docs/contribution.md)

## Layout 
An example of decapod-base-yaml:
```
 openstack
 ├── base
 │   ├── kustomization.yaml
 │   ├── resources.yaml
 │   └── site-values.yaml
 ├── image
 │   └── image-values.yaml 
 └── storage
     ├── ceph.yaml
     └── local-path.yaml
```

An example of decapod-site:
```
 dev // site name
 ├── openstack
     ├── kustomization.yaml
     ├── ceph.yaml
     └── site-values.yaml
```
## Example

base(1) + site(2) => [variant](https://kubectl.docs.kubernetes.io/references/kustomize/glossary/#variant)(3)

1. _decapod-base-yaml/lma/base/resources.yaml_:
   ```yaml
   apiVersion: helm.fluxcd.io/v1
   kind: HelmRelease
   metadata:
   name: elasticsearch-operator
   spec:
   chart:
      repository: https://openinfradev.github.io/hanu-helm-repo
      name: elasticsearch-operator
      version: 1.0.3
   releaseName: elasticsearch-operator
   targetNamespace: elastic-system
   values:
      elasticsearchOperator:
         nodeSelector: {} # TO_BE_FIXED
   ```

2. _decapod-site/dev/lma/site-values.yaml_:
   ```yaml
   apiVersion: openinfradev.github.com/v1
   kind: HelmValuesTransformer
   metadata:
   name: site

   global:
   nodeSelector:
      taco-lma: enabled

   charts:
   - name: elasticsearch-operator
   override:
      elasticsearchOperator.nodeSelector: $(nodeSelector)
   ```

3. _decapod-site/dev/lma/lma-manifest.yaml_:
   ```yaml
   apiVersion: helm.fluxcd.io/v1
   kind: HelmRelease
   metadata:
   name: elasticsearch-operator
   spec:
   chart:
      repository: https://openinfradev.github.io/hanu-helm-repo
      name: elasticsearch-operator
      version: 1.0.3
   releaseName: elasticsearch-operator
   targetNamespace: elastic-system
   values:
      elasticsearchOperator:
         nodeSelector:
         taco-lma: enabled
   ```