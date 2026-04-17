
# Reference a specific cloud to deploy COS

In situations where multiple clouds are registered in the controller, you must specify where to deploy the model,
Reference your cloud and credentials in the base terraform plan. First, see what cloud and credentials are stored in the authenticated controller using:
```
$ juju clouds
$ juju credentials
```
For example:
```
Clouds available on the controller:  
Cloud      Regions  Default     Type 
k8s-cloud  1        default     k8s  

Controller Credentials:  
Cloud      Credentials   
k8s-cloud  k8s-cloud     
```
Add a `cloud` block and a `credential` reference in the base terraform file within the `juju_model` resource:
```
resource "juju_model" "cos" {
  name   = "cos"
  config = { logging-config = "<root>=WARNING; unit=DEBUG" }
  
  # Add this block
  cloud {                                                 
    name   = "k8s-cloud"                                  
    region = "default"                                    
  }                                                       
  credential = "k8s-cloud"     
}   
```
Save and exit. 

To read more about managing clouds, refer to the [Manage clouds](https://documentation.ubuntu.com/terraform-provider-juju/latest/howto/manage-clouds/#add-a-kubernetes-cloud) section of Terraform Provider for Juju