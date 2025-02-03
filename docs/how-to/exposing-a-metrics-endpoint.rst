.. _exposing-a-metrics-endpoint:

Exposing a Metrics Endpoint
***************************

Integrating with the metrics endpoint interface allows you to, through a minimal amount of code, enable your charm to get scraped by a charm like `prometheus-k8s <https://charmhub.io/prometheus-k8s>`_ or `grafana-agent-k8s <https://charmhub.io/grafana-agent-k8s>`_.

Prerequisites
=============

- A charm with a workload that exposes a metrics endpoint.
- A Juju deployment with COS Lite deployed.

Fetch the Library
=================

Fetch the `prometheus_scrape` library using  the `charmcraft` command:

.. code-block::
   
    $ charmcraft fetch-lib charms.prometheus_k8s.v0.prometheus_scrape

Import the Library
==================

At the top of your charm's `src/charm.py` source file, add an import of the charm library you just imported.

.. code-block::

    from charms.prometheus_k8s.v0.prometheus_scrape import MetricsEndpointProvider


Using the constructor
=====================

In the `__init__` function of your charm class, instantiate the `MetricsEndpointProvider`. In its simplest form, where the workload exposes its metrics endpoint over port `80`, with the path `/metrics`.

.. code-block::

    class ScrapableCharm:
        # ...
        def __init__(self, *args):
            # ...
            self.metrics_endpoint = MetricsEndpointProvider(self)


To override the default targets or the metrics path, you may then supply them as additional arguments while doing the instantiation.

.. code-block::

    class ScrapableCharm:
        # ...
        def __init__(self, *args):
            # ...
            self.metrics_endpoint_provider = MetricsEndpointProvider(
                    self,                                  
                    jobs=[{
                        "metrics_path": "/my/strange/metrics/path",
                        "static_configs": [{"targets": ["*:8080"]}],
                    }])

Declaring the relation
======================

As a last step, you need to declare the relation in your charms `metadata.yaml` file.

.. code-block::

    provides:
    metrics-endpoint:
        interface: prometheus_scrape


Congratulations! You will now be able to add an integration between your charm and a scraper!