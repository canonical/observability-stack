.. _tutorial:

Tutorial
********

If you want to learn the basics from experience, then our tutorial will help
you acquire the necessary competencies from real-life examples with fully
reproducible steps.

Installation
============

Get COS up and running on your MicroK8s environment with ease. Each of these 
paths of the tutorial will walk you through the steps required to deploy COS
or COS Lite, Juju-based observability stacks running on Kubernetes.

.. toctree::
   :maxdepth: 1

   1. Deploying the observability stack <installation/index>

Configuration
=============

In this part of the tutorial you will learn how to make COS automatically sync
the alert rules of your git repository to your metrics backend using the COS Configuration
charm.

.. toctree::
   :maxdepth: 1

   2. Sync alert rules from Git <sync-alert-rules-from-git>

Instrumentation
===============

Bridge the gap between COS Lite running in Kubernetes and your application 
running on a machine. Discover how to collect telemetry data from your charmed 
application using the Grafana Agent machine charm.

.. toctree::
   :maxdepth: 1

   3. Instrument machine charms <instrument-machine-charms>