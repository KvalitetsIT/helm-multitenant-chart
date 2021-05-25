# What todo when adding new tenant
When adding a new tennant u need to do the following things:
1. The helm-chart is run using a values-files - This values file needs to be extended with the new user
1. A new namespace will be created in the cluster for each user in the values-file. When using argo, the namespace needs to be added to 'destinations' under your project

And thats it! You now have a new tennant with limitations!
