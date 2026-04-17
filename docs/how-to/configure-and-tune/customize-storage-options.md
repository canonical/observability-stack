# Customize storage options

## Configure custom storage class

You may want to use custom storage classes like ceph or cinder backed PVCs for your containers. List the available storage classes if needed:
```
$ kubectl get sc
```
For example, I want all the pods to be deployed with a PVC that is provisioned by `ceph-xfs` storage class:
```
NAME                  PROVISIONER              RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE    
ceph-ext4             rbd.csi.ceph.com         Delete          Immediate              true                   2d22h  
ceph-xfs              rbd.csi.ceph.com         Delete          Immediate              true                   2d22h  
csi-rawfile-default   rawfile.csi.openebs.io   Delete          WaitForFirstConsumer   false                  3d1h   
```
Modify the `juju_model` resource in the base file with a `workload-storage` config:
```
resource "juju_model" "cos" {                             
  name   = "cos"                                          
  config = { logging-config = "<root>=WARNING; unit=DEBUG"
  
  # Add this line  
  workload-storage = "ceph-xfs"      
  }                                
}
```



## Configure custom storage sizes 

Additionally, it is recommended to modify the size of your PVC, specially since components like loki and prometheus are storage intensive. 

```{important}
If you don't specify a size, a PVC will be created with a default size of 1G backed by the storage class you configured. 
```

Add a `storage_directive` for each storage container under the `cos-lite` module in the same base terraform file:
```
module "cos-lite" {                                                                                    
  source     = "git::https://github.com/canonical/observability-stack//terraform/cos-lite?ref=track/2" 
  model_uuid = juju_model.cos.uuid
  channel    = "2/stable"
  ssc        = { channel = "1/stable" }
  traefik    = { channel = "latest/stable" }

  # Adding storage for Prometheus
  prometheus = {
    storage_directives = { "database" = "200G" }
  }      

  # Adding storage for Loki
  loki = {
    storage_directives = { "loki-chunks" = "400G" }
  }     

  # Adding storage for Alertmanager (Note the key is usually "data")
  alertmanager = {
    storage_directives = { "data" = "100G" }
  }
}
```
This shows 3 examples setting sizes for prometheus, loki and alertmanager using the syntax
`{storage_directives = {<storage_name> = "<size>"}}`

To know the key names for other components, refer to the table below:

|Component|Storage name|
|---|---|
|Prometheus|database|
|loki|loki-chunks|
|loki|active-index-directory|
|alertmanager|data|
|grafana|database|
|traefik|configurations|

It is good to know that `storage_directives` can also take `pool` and `count` values, providing additional flexibility when configuring storage classes. Here are a couple of more examples:
```
storage_directives = {
    "pgdata" = "4G" # 4 gigabytes of storage for pgdata using the model's default storage pool
    # or
    "pgdata" = "2,4G" # 2 instances of 4 gigabytes of storage for pgdata using the model's default storage pool
    # or
    "pgdata" = "ebs,2,4G" # 2 instances of 4 gigabytes of storage for pgdata on the ebs storage pool
  }
```
## Reference

[Example of using `storage_directives`](https://documentation.ubuntu.com/terraform-provider-juju/latest/reference/terraform-provider/resources/application/#juju-application-resource)