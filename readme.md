# What todo when adding new tenant
When adding a new tennant u need to do the following things:
1. Extend values.yaml with new tennant (this will create a new namespace)
1. Update argo-destinations (settings => projects => infrastructure) with a new entry containing the new namespace fx ``https://kubernetes.default.svc
 | tenant ``
1. Label all namespaces (that you wish to whitelist) with a label called `name`, this should be same name as namespace

1. Syncronize in Argo!

And thats it! You now have a new tennant with limitations!


# Values file
Every item in the list tennants will be a dictionary, and the `key` will be the name of the namespace.

The values file could look like this:
```yml
tennants:
- test-from-helm-multitenant-repo:
    allowInternetAccess : true #True if tennant should be able to reach internet
    limits:
      cpu: 1000
      memory: 200Gi
      longhorn.storageclass.storage.k8s.io/requests.storage: 100Gi
    ingressAllowedNamespaces: #Namespaces that should be able to reach this namespace
      - ingress-nginx
    egressAllowedNamespaces: #Namespaces that this tennant needs to be able to reach
      - ingress-nginx
```
### ingressAllowedNamespaces and egressAllowedNamespaces
```yml
ingressAllowedNamespaces:
  - ingress-nginx
egressAllowedNamespaces: #Namespaces that this tennant needs to be able to reach
  - ingress-nginx
```
The values-file contains two lists; egressAllowedNamespaces and ingressAllowedNamespaces. Networkpolicies do not support namespace-whitelisting yet, so theese are **not** actually namespace-names, but the value of a label called "name". So in the example above we are saying that namespaces, containing the label name, with the value 'ingress-nginx' are whitelisted.

**Important notice** : Because of this, you will need to make sure that all your namespaces that you wish to whitelist, has a label with the same name as namespace-name

### allowInternetAccess
```yml
allowInternetAccess : true #True if tennant should be able to reach internet

```
For the tennant to be able to reach the world wide web, it needs to have this attribute set to true

# Testing the values-file
```sh
helm template   --values values.yaml   --output-dir ./manifests     ./
```
