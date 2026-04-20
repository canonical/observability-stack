
# How to reference a specific cloud to deploy COS

In situations where multiple clouds are registered in the controller, you must specify where to deploy the model,
Reference your cloud and credentials in the base Terraform plan. First, see what cloud and credentials are stored in the authenticated controller.
For example:

```bash
juju clouds
```
```
Clouds available on the controller:  
Cloud      Regions  Default     Type 
k8s-cloud  1        default     k8s  
```

```bash
juju credentials
```
```
Controller Credentials:  
Cloud      Credentials   
k8s-cloud  k8s-cloud     
```

Add a `cloud` block and a `credential` reference in the base Terraform file within the `juju_model` resource:

```diff
resource "juju_model" "cos" {
  name   = "cos"
  config = { logging-config = "<root>=WARNING; unit=DEBUG" }
  
+ cloud {                                                 
+   name   = "k8s-cloud"                                  
+   region = "default"                                    
+ }                                                       
+ credential = "k8s-cloud"     
}   
```

To read more about managing clouds, refer to the [Manage clouds](https://documentation.ubuntu.com/terraform-provider-juju/latest/howto/manage-clouds/#add-a-kubernetes-cloud) section of Terraform Provider for Juju.