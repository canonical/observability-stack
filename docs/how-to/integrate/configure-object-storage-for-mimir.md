---
myst:
  html_meta:
    description: "Connect S3-compatible object storage to a Mimir on Juju deployment through s3-integrator, with production planning notes and Minio-based testing links."
---

# How to connect object storage to Mimir on Juju

Mimir on Juju needs an S3-compatible object store for durable storage. The
Juju deployment does **not** create that object store for you; it expects you
to bring an existing one and connect it through the `s3-integrator` charm.

Use this guide to connect an existing object store to a Mimir on Juju
deployment.

## Before you begin

You should already have:

- A Mimir on Juju deployment (at minimum the `mimir-coordinator-k8s`
  application). If you do not have one yet, follow
  [How to deploy Mimir on Juju](/how-to/deploy-and-manage/deploy-mimir-on-juju) first.
- Access to an S3-compatible object store, with:
  - endpoint
  - bucket name
  - access key
  - secret key
  - optional region
  - optional custom CA chain for HTTPS

If you still need a local test object store, see
[How to deploy Minio and S3 Integrator](deploy-s3-integrator-and-minio).

## Plan your object storage

Do this **before** wiring anything into Mimir; changing the answer to any of
these later is disruptive.

- **Use a dedicated bucket.** Keep Mimir in its own bucket unless you have a
  clear reason to share one.
- **Use dedicated credentials** for that bucket, scoped so they can only
  access what Mimir needs.
- **Prefer HTTPS** for the S3 endpoint in shared or production environments,
  and know in advance whether the endpoint uses a private CA (you will need
  to supply the CA chain during configuration).
- **Do not use Minio in production.** The Minio charm is only for local or
  disposable test environments; production planning is covered in
  [Storage best practices](/reference/storage).
- **Plan capacity** around your retention and ingestion rates, and avoid
  local-only or node-bound storage for production deployments. Sizing details
  are in [Storage best practices](/reference/storage).
- **Keep the S3 endpoint stable** before you start wiring producers to
  `receive-remote-write`; changing it later forces a reconfiguration of
  Mimir workers.

```{warning}
The Minio charm is useful for testing, but not as a production storage
strategy. For production planning, review
[Storage best practices](/reference/storage).
```

## 1. Deploy the S3 integrator

```bash
juju deploy s3-integrator mimir-s3 --channel latest/stable --trust
```

The application will remain blocked until you give it credentials and a
target bucket.

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

If you are still building the deployment, integrate storage **before**
joining Mimir workers to the coordinator. That keeps the storage
configuration in place before the workers read their cluster settings.

## 5. Verify the relation

```bash
juju status --relations
```

You should see an `s3` integration between `mimir` and `mimir-s3`, and both
applications should reach `active/idle`.
