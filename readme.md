# What todo when adding new tenant
When adding a new tennant u need to do the following things:
1. The helm-chart is run using a values-files - This values file needs to be extended with the new user
1. A new namespace will be created in the cluster for each user in the values-file. When using argo, the namespace needs to be added to 'destinations' under your project

And thats it! You now have a new tennant with limitations!


# Values file
The values file could look like this:

```yml
tennants:
- test:
  ns: test
  limits:
    cpu: 1000
    memory: 200Gi
    gold.storageclass.storage.k8s.io/requests.storage: 100Gi
- Jens:
  ns: Jens
  limits:
    cpu: 1000
    memory: 200Gi
    gold.storageclass.storage.k8s.io/requests.storage: 100Gi
```

# Testing the values-file
```sh
helm template   --values values.yaml   --output-dir ./manifests     ./
```