---
myst:
  html_meta:
    description: "Deploy Catalogue in COS and integrate existing charms so their application links, descriptions, API docs, and API endpoints are shown in one service catalogue."
---

# How to use Catalogue

[Catalogue](https://charmhub.io/catalogue-k8s) provides a simple web UI for
discovering applications in a Juju model. Charms that support the `catalogue`
relation can publish their application name, URL, icon, description, API
documentation link, and API endpoints to Catalogue.

## Deploy Catalogue

Deploy `catalogue-k8s` and the applications that you want to list. This example
uses Prometheus and Grafana, which already support the `catalogue` relation:

```bash
juju deploy catalogue-k8s catalogue
juju deploy prometheus-k8s prometheus --trust
juju deploy grafana-k8s grafana --trust
```

Integrate Catalogue with each application:

```bash
juju integrate catalogue:catalogue prometheus
juju integrate catalogue:catalogue grafana
```

Get the Catalogue URL and open it in a browser:

```bash
juju run catalogue/leader get-url
```

The Catalogue UI now shows the related applications.

## Integrate an existing charm with Catalogue

To make your own charm appear in Catalogue, add the `catalogue` relation and use
the `CatalogueConsumer` class from the
[`catalogue-k8s` charm library](https://github.com/canonical/catalogue-k8s-operator/blob/main/charm/lib/charms/catalogue_k8s/v1/catalogue.py).

Fetch the library into your charm:

```bash
charmcraft fetch-lib charms.catalogue_k8s.v1.catalogue
```

Declare the relation in your charm metadata:

```yaml
requires:
  catalogue:
    interface: catalogue
```

Instantiate `CatalogueConsumer` in your charm and pass it a `CatalogueItem`.
The `icon` value is an
[Iconify Material Design Icon](https://icon-sets.iconify.design/mdi/) name,
such as `web` or Grafana's `bar-chart`. The `api_endpoints` value is an
optional dictionary where each key is the endpoint label shown in Catalogue and
each value is the full endpoint address.

```python
from charms.catalogue_k8s.v1.catalogue import CatalogueConsumer, CatalogueItem
from ops import CharmBase


class MyCharm(CharmBase):
    def __init__(self, *args):
        super().__init__(*args)

        api_endpoints = {
            "Search": "/api/search",
            "Data Sources": "/api/datasources",
        }

        self.catalogue = CatalogueConsumer(
            charm=self,
            relation_name="catalogue",
            item=CatalogueItem(
                name="My application",
                url="https://my-application.example.com",
                icon="bar-chart",
                description="Web UI for my application.",
                api_docs="https://my-application.example.com/docs",
                api_endpoints={
                    key: f"https://my-application.example.com{path}"
                    for key, path in api_endpoints.items()
                },
            ),
        )
```

For example, `grafana-k8s` builds a dictionary of API endpoint paths, then
prefixes each path with `self.external_url` so Catalogue receives full URLs such
as `https://grafana.example.com/api/search`.

If the URL or metadata changes after charm startup, call `update_item()` with a
new `CatalogueItem`:

```python
self.catalogue.update_item(
    CatalogueItem(
        name="My application",
        url=self.external_url,
        icon="web",
        description="Web UI for my application.",
    )
)
```

After the updated charm is deployed, relate it to Catalogue:

```bash
juju integrate catalogue:catalogue my-application:catalogue
```

Catalogue reads the relation data from the application leader, so the item is
published automatically when the relation is created or changed.
