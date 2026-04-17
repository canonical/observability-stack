module "cos" {
  # Use the right source value depending on whether you are using cos or cos-lite
  source                          = "git::https://github.com/canonical/observability-stack//terraform/cos?ref=track/2"
  channel                         = "2/stable"
  
  # ... other inputs ...

  # Configure a component's storage directives
  prometheus = {
    backend_storage_directives = {
      database: "kubernetes,1,50G",  # sizes are just examples, adjust as needed
    }
  }
  mimir_worker = {
    backend_storage_directives = {
      data: "kubernetes,1,50G",  # sizes are just examples, adjust as needed
      recovery-data: "kubernetes,1,10G"  # sizes are just examples, adjust as needed
    }
  }
}
