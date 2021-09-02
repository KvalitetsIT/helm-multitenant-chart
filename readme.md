
# What todo when adding new tenant
1. Extend values.yaml with new tennant (this will create a new namespace)
1. Create new Argo-project
    *The new tenant will need a new project in Argo. This project should be called the same as the namespace, which should be called the same as the tenant.*
    This application should have the following properties:
    1. Update argo-destinations (settings => projects => infrastructure) with a new entry containing the new namespace fx ``https://kubernetes.default.svc | tenant ``
    2. Add source repositories
    3. Add * to Cluster Resource Allow list
    4. Add `infrastructure` to destinations
 
1. Make sure that all namespaces (that you wish to whitelist) has a label called `name` (value should be same name as namespace-name)
1. Make sure that `kube-system`-namespace has a label called `name` with value; `kube-system`
1. Syncronize in Argo!

And thats it! You now have a new isolated tennant with the limitations you provided!


### What is created?
The following is created pr tennant:
- Namespace
  - Labels is set to `navn=[tennant-name]` and `type=tenant` (this makes it easy to reference it in networkpolicies)
- Network policy (ingress and egress)
  - Deny all traffic as default
  - Allow from same namespace
  - Allow from/to namespaces specified in `ingressAllowedNamespaces`/`egressAllowedNamespaces`
  - Allow outbound traffic to internet (if `allowInternetAccess` is true)
- RessourceQuota
  - This makes it mandatory for all apps to allocate ressources under the given namespace
  - To have no limits, simply dont make a limits-list

# What todo when adding new shared services project
1. Extend the values.yaml with the new sharedservice, in the list `sharedServices` - And the github-repo in a property called `repository`
1. Sync in argo

And thats it! You now have a new shared service!
### What is created?
1. Namespace with exact name of the service you added to the list
 - Labels is set to `navn=[service-name]` and `type=shared-service` (this makes it easy to reference it in networkpolicies)
3. Project with exact name of the service you added to the list - Created in the namespace `appnamespace` from values file
    1.  Destinations: The newly created namespace, and whatever namespace that is in the value `appnamespace`
    2.  ClusterResourceWhiteList; all is allowed
    3.  sourceRepo: The repo you put it `repository` in the values file
    4.  labels: Will have the label `type=shared-service`

    

# Values file
Every item in the list tennants will be a dictionary, and the `key` will be the name of the namespace.

The values file could look like this:
```yaml
appnamespace: infrastructure
egressNetworksToBlock: #If allowInternetAccess is true, what networks should we not allow traffic to (this should be the ranges for other pods in other namespaces)
  - 10.0.0.0/20
  - 10.0.16.0/20
tennants: 
- test-from-helm-multitenant-repo: #This will be the name of the namespace
    limits: #Can be removed to remove limits
      cpu: 1000 #This is the number of allocated VCPU's (1000 is alot of vcpu's)
      memory: 200Gi
      longhorn.storageclass.storage.k8s.io/requests.storage: 100Gi
    allowInternetAccess : true #True if tennant should be able to reach internet
    ingressAllowedNamespaces: #Namespaces that should be able to reach this namespace
      - DataStorageServices
      - ingress-nginx
    egressAllowedNamespaces: #Namespaces that this tennant needs to be able to reach
      - ingress-nginx

sharedServices:
- data-storage-services: # This will be the name of the namespace
    repository: "https://github.com/KvalitetsIT/kithosting-LoginServices.git"
- login-services:
    repository: "https://github.com/KvalitetsIT/kithosting-LoginServices.git"
    
dockerconfigjson: sdfsjhfjshrghesg...
    
```
### `ingressAllowedNamespaces` and `egressAllowedNamespaces`
```yml
ingressAllowedNamespaces: #Namespaces that should be able to reach this namespace
  - ingress-nginx
egressAllowedNamespaces: #Namespaces that this tennant needs to be able to reach
  - ingress-nginx
```
The values-file contains two lists; egressAllowedNamespaces and ingressAllowedNamespaces. Networkpolicies do not support namespace-whitelisting yet, so theese are **not** actually namespace-names, but the value of a label called "name". So in the example above we are saying that namespaces, containing the label name, with the value 'ingress-nginx' are whitelisted.

**Important notice** : Because of this, you will need to make sure that all your namespaces that you wish to whitelist, has a label with the same name as namespace-name

### `allowInternetAccess`
```yml
allowInternetAccess : true #True if tennant should be able to reach internet

```
For the tennant to be able to reach the world wide web, it needs to have this attribute set to true

### `defalut limits and request`
```yml
default:
  limits:
    cpu: 50m
    memory: 128Mi
  request:
    cpu: 50m
    memory: 64Mi
```
For the tenant there is a default resources limit and request on CPU and memory. The default are used for pods whits no resources defined.

### `dockerconfigjson`
```yml
dockerconfigjson: sdfsjhfjshrghesg...
```
If an image pull secret is needed in all namespaces. Then a sealed secret with the dockerconfigjson is created with the value in dockerconfigjson.

# Deployments - Provide ressources!
All deployments belonging to a namespace, that is limited by ressourceQuotas, needs to be allocated ressources. If this is not provided, the deployment will not go well.

# Generate from template
```sh
helm template   --values values.yaml   --output-dir ./manifests     ./
```

### How to edit label
A label is edited by using command `kubectl edit ns <<namespace>>` you will get something like:

```yml
apiVersion: v1
kind: Namespace
metadata:
  creationTimestamp: "2021-05-17T08:27:47Z"
  labels: #This should be present
    name: kube-system #This should be present
  name: kube-system
  resourceVersion: "5752263"
  uid: f611c9ad-8b6d-4f86-aabd-baa4f987c0e9
spec:
  finalizers:
  - kubernetes
status:
  phase: Active
```
you add the label `name` with value corresponding to the name of the namespace
