#!/usr/bin/env bash

juju add-model istio-system
juju deploy istio-k8s istio --channel dev/edge --trust
juju switch cos
juju remove-application traefik
juju deploy istio-beacon-k8s istio-beacon --channel dev/edge --trust
juju integrate istio-beacon:service-mesh alertmanager
juju integrate istio-beacon:service-mesh catalogue
juju integrate istio-beacon:service-mesh grafana
juju integrate istio-beacon:service-mesh loki
juju integrate istio-beacon:service-mesh mimir
juju integrate istio-beacon:service-mesh otelcol
juju integrate istio-beacon:service-mesh tempo
juju deploy istio-ingress-k8s istio-ingress --channel dev/edge --trust
juju relate istio-ingress:ingress alertmanager
juju relate istio-ingress:ingress catalogue
juju relate istio-ingress:ingress grafana
juju relate istio-ingress:ingress loki
juju relate istio-ingress:ingress mimir
juju relate istio-ingress:istio-ingress-route otelcol
juju relate istio-ingress:istio-ingress-route tempo
