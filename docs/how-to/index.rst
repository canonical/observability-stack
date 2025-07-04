.. _how-to:

How-to guides
*************

These guides accompany you through the complete COS stack operations life cycle.


.. note::

   If you are looking for instructions on how to get started with COS Lite, see
   :ref:`the tutorial section <tutorial>`.

Migrating
=========

These guides till assist existing users of other observability stacks offered by
Canonical in migrating to COS Lite or the full COS.

.. toctree::
   :maxdepth: 1

   Migrate from LMA to COS Lite <migrate-lma-to-cos-lite>
   Migrate from COS Lite to COS <migrate-cos-lite-to-cos>
   Migrate from Grafana Agent to OpenTelemetry Collector <migrate-gagent-to-otelcol>

Configuring
=============

Once COS has been deployed, the next natural step would be to integrate your charms and workloads
with COS to actually observe them.

.. toctree::
   :maxdepth: 1

   Evaluate telemetry volume <evaluate-telemetry-volume>
   Add tracing to COS Lite <add-tracing-to-cos-lite>
   Add alert rules <adding-alert-rules>
   Configure scrape jobs <configure-scrape-jobs>
   Expose a metrics endpoint <exposing-a-metrics-endpoint>
   Integrate COS Lite with uncharmed applications <integrating-cos-lite-with-uncharmed-applications>
   Disable built-in charm alert rules <disable-charmed-rules>
   Testing with Minio <deploy-s3-integrator-and-minio>
   Configure TLS encryption <configure-tls-encryption>
   
Troubleshooting
===============

During continuous operations, you might sometimes run into issues that you need to resolve. These
how-to guides will assist you in troubleshooting COS in an effective manner.   

.. toctree::
   :maxdepth: 1
   :hidden:

   Troubleshooting <troubleshooting/index.rst>

- `Troubleshoot "Gateway Address Unavailable" in Traefik <troubleshooting/troubleshoot-gateway-address-unavailable>`_
- `Troubleshoot "socket: too many open files" <troubleshooting/troubleshoot-socket-too-many-open-files>`_
- `Troubleshoot integrations <troubleshooting/troubleshoot-integrations>`_
