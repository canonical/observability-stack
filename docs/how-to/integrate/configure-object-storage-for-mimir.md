---
myst:
  html_meta:
    description: "Configure S3-compatible object storage for standalone Mimir on Juju, including s3-integrator setup, production considerations, and Minio-based testing links."
---

# How to configure object storage for Mimir

Mimir on Juju needs an S3-compatible object store for durable storage.
The Juju deployment does **not** create that object store for you; it expects
you to provide one and then connect it through `s3-integrator`.

Use this guide when you already have an object store and want to wire it into a
standalone Mimir deployment.

## Before you begin

Have the following details ready:

- S3 endpoint
- bucket name
- access key
- secret key
- optional region
- optional custom CA chain for HTTPS

If you still need a local test object store, see
[How to deploy Minio and S3 Integrator](deploy-s3-integrator-and-minio).

```{warning}
The Minio charm is useful for testing, but not as a production storage
strategy. For production planning, also review
[Storage best practices](/reference/storage).
```

## 1. Deploy the S3 integrator

```bash
juju deploy s3-integrator mimir-s3 --channel latest/stable --trust
```

The application will remain blocked until you give it credentials and a target
bucket.

## 2. Create and grant the S3 credentials secret

Create a Juju secret holding the access key and secret key, then grant that
secret to the `mimir-s3` application:

```bash
juju add-secret mimir-s3-credentials \
    access-key=<access-key> \
    secret-key=<secret-key>

juju grant-secret secret:<secret-ID> mimir-s3
```

## 3. Configure the object-store location

Set the endpoint and bucket:

```bash
juju config mimir-s3 \
    credentials=secret:<secret-ID> \
    endpoint=<s3-endpoint> \
    bucket=<bucket-name>
```

Depending on your object-store implementation, you may also need additional
options such as:

- `region=<region>`
- `path=<prefix>`
- `s3-uri-style=path`

If the endpoint uses a private CA, provide it as base64:

```bash
juju config mimir-s3 tls-ca-chain="$(base64 -w0 ca-chain.pem)"
```

## 4. Integrate Mimir with the S3 integrator

```bash
juju integrate mimir:s3 mimir-s3:s3-credentials
```

If you are still building the deployment, integrate storage **before** joining
Mimir workers to the coordinator. That keeps the storage configuration in place
before the workers read their cluster settings.

## 5. Verify the relation

```bash
juju status --relations
```

You should see an `s3` integration between `mimir` and `mimir-s3`.

## Recommended bucket layout

Keep Mimir in its own bucket unless you have a clear reason to share one.

A simple starting point is:

| Purpose | Recommendation |
|---|---|
| Bucket | Dedicated bucket per Mimir deployment |
| Credentials | Dedicated credentials per deployment |
| TLS | Prefer HTTPS in shared or production environments |
| Testing | Use Minio only for local or disposable environments |

## Production notes

- Plan object-store capacity around your retention and ingestion rates.
- Avoid local-only or node-bound storage for production-grade deployments.
- Keep the S3 endpoint stable before you start wiring producers to
  `receive-remote-write`.

For broader sizing and storage guidance, see [Storage best practices](/reference/storage).
