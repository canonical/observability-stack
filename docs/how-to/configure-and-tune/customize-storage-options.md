# Customize storage options

## Configure custom storage class

You may want to use custom storage classes like ceph or cinder backed PVCs for your containers. List the available storage classes:

```bash
kubectl get sc
```
```
NAME                  PROVISIONER              RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE    
ceph-ext4             rbd.csi.ceph.com         Delete          Immediate              true                   2d22h  
ceph-xfs              rbd.csi.ceph.com         Delete          Immediate              true                   2d22h  
csi-rawfile-default   rawfile.csi.openebs.io   Delete          WaitForFirstConsumer   false                  3d1h   
```

For example, to have all the pods deployed with a PVC that is provisioned by `ceph-xfs` storage class, modify the `juju_model`
resource in the base file with a `workload-storage` config:

```diff
resource "juju_model" "cos" {                             
  name   = "cos"                                          
  config = { logging-config = "<root>=WARNING; unit=DEBUG"
  
+ workload-storage = "ceph-xfs"      
  }                                
}
```


## Configure custom storage sizes

Since COS components are storage intensive, it is recommended to modify the size of your PVC.

```{important}
If you don't specify a size, a PVC will be created with a default size of 1G backed by the storage class you configured. 
```

Add a `storage_directive` for each storage container in your terraform file. For COS Lite it may look like this:

```diff
module "cos-lite" {                                                                                    
  source     = "git::https://github.com/canonical/observability-stack//terraform/cos-lite?ref=track/2" 
  model_uuid = juju_model.cos.uuid
  channel    = "2/stable"
  ssc        = { channel = "1/stable" }
  traefik    = { channel = "latest/stable" }

+ # Adding storage for Prometheus
+ prometheus = {
+   storage_directives = { "database" = "200G" }
+ }      

+ # Adding storage for Loki
+ loki = {
+   storage_directives = { "loki-chunks" = "400G" }
+ }     

+ # Adding storage for Alertmanager (Note the key is usually "data")
+ alertmanager = {
+   storage_directives = { "data" = "100G" }
+ }
}
```

This shows 3 examples setting sizes for prometheus, loki and alertmanager using the syntax
`{storage_directives = {<storage_name> = "<size>"}}`

You can find the names of relevant storage volumes in the [storage reference](/reference/storage).

## External links

- [Example of using `storage_directives`](https://documentation.ubuntu.com/terraform-provider-juju/latest/reference/terraform-provider/resources/application/#juju-application-resource)
