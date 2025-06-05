.. _installation:

Deploying the observability stack
*********************************

.. toctree::
   :maxdepth: 1
   
   A. COS Lite on MicroK8s <getting-started-with-cos-lite>
   B. COS Lite on Canonical K8s <cos-lite-canonical-k8s-sandbox>


.. list-table:: Installation tutorials
   :widths: auto
   :header-rows: 1

   * - Grade
     - Tutorial
     - Distribution
     - Kubernetes
     - Storage
     - Resource requirements
     - Reproducer
   * - Sandbox
     - :doc:`COS Lite on MicroK8s <getting-started-with-cos-lite>`
     - COS Lite
     - MicroK8s
     - hostPath
     - 4cpu8gb
     - 
   * - Sandbox
     - :doc:`COS Lite on Canonical K8s <cos-lite-canonical-k8s-sandbox>`
     - COS Lite
     - Canonical K8s (snap)
     - hostPath
     - 4cpu8gb
     - :download:`cloud-config <cos-lite-canonical-k8s-sandbox.conf>`
