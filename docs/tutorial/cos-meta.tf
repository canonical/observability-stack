# [docs:cos]
resource "juju_model" "cos" {
  name = "cos"
  config = { logging-config = "<root>=WARNING; unit=DEBUG" }
}
# [docs:cos-end]

# [docs:cos-lite]
resource "juju_model" "cos" {
  name = "cos-lite"
  config = { logging-config = "<root>=WARNING; unit=DEBUG" }
}
# [docs:cos-lite-end]
