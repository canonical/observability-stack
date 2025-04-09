# Testing with Minio

```{warning}
The Minio charm is not suited for production usage. If that is what you are after, you should have a look at [Charmed Ceph](https://ubuntu.com/ceph/docs) and then follow [this guide](https://discourse.charmhub.io/t/tempo-ha-docs-how-to-use-ceph-backed-s3-storage-for-ha-charms/15740) instead.
```

[Minio](https://min.io/) is a lightweight S3-compatible object storage system. In its 
single-node configuration, it is suitable for providing s3 storage backends for 
**testing purposes** for certain HA COS addons such as Tempo, Loki and Mimir. 

## Single-node Minio deployment

### Deploy Minio

Deploy the `minio` charm. Tailor the strength of both the access key and the secret key to how exposed your environment is.

```{note}
The secret-key must be at least 8 characters long. If not, Minio will crash.
```

```bash
$ juju deploy minio \
    --channel edge \
    --trust \
    --config access-key=accesskey \
    --config secret-key=mysoverysecretkey
```

And wait for it to go to `active/idle`.

### Deploy the S3 integrator

The `minio` charm does not directly provide an `s3` endpoint. For that, we need to deploy an `s3-integrator` app to act as intermediary.


```{note}
We deploy `s3-integrator` as `s3`, but feel free to give the app a different name.
```

```bash
$ juju deploy s3-integrator s3 \
    --channel edge \
    --trust 
```

And wait for it to go to `blocked/idle`.
The `s3` app will go into `blocked` status until you run the `sync-s3-credentials` action to give it access to `minio`.

```bash
$ juju run s3/leader sync-s3-credentials \
    access-key=accesskey \
    secret-key=mysoverysecretkey
```


### Add a bucket

#### Using the Minio UI

The simplest way to create a bucket is to use the Minio console. Obtain the Minio IP from the `juju status` output and then open `http://MINIO_IP:9001` in a browser using the access key and secret key you configured earlier as user and password respectively.

From there you should be able to create a bucket with a few clicks. See [this guide](https://thenewstack.io/how-to-create-an-object-storage-bucket-with-minio-object-storage/) for a step-by-step tutorial.


#### Using the Python SDK

Alternatively, you can use the Python SDK.

```bash
$ pip install minio
```

Then execute:

```python
from minio import Minio

address = <minio/0 unit IP>
bucket_name = "mybucket"  # replace with your bucket name

mc_client = Minio(
    f"{address}:9000",
    access_key="accesskey",
    secret_key="secretkey",
    secure=False,
)

found = mc_client.bucket_exists(bucket_name)
if not found:
    mc_client.make_bucket(bucket_name)
```

### Integrate s3

Now grant the s3 integrator access to the bucket. Replace `<JUJU MODEL NAME>` with the name of the juju model `minio` is deployed in, and `mybucket` with the name of the bucket you just created.


```
$ juju config s3 \
    endpoint=minio-0.minio-endpoints.<JUJU MODEL NAME>.svc.cluster.local:9000 \
    bucket=mybucket
```

Now the s3 integrator is ready to provide the `s3` integration to any charm requiring it.


```{warning}
As of `rev 41` of `s3-integrator`, if multiple charms each require integration with different S3 buckets, you would need to deploy multiple `s3-integrator` applications — one per unique bucket, as each `s3-integrator` application can only have **one** set of unique bucket configurations. [see more](https://github.com/canonical/s3-integrator/issues/48)
```

## A handy script to do it all

We have written [a small python script](https://raw.githubusercontent.com/canonical/tempo-coordinator-k8s-operator/main/scripts/deploy_minio.py) that does all of the above, for internal development purposes. And, as it happens, you can use it too!

```bash
$ juju switch cos  # select the model where you have COS-lite deployed
$ sudo pip3 install minio  # install the script's only dependency
$ curl https://raw.githubusercontent.com/canonical/tempo-coordinator-k8s-operator/main/scripts/deploy_minio.py -o deploy_minio.py

# review the script prior to executing it, then:
$ python3 deploy_minio.py
```

The script will install the `minio` charm, the `s3-integrator` charm and configure them to create and use a `tempo` bucket where traces will be stored. Once the script finishes, you should see the following message:

```text
Waiting for task 2...
ok: Credentials successfully updated.

all done! have fun.
```

Your storage is now ready, and you can integrate the `s3` app to whatever needs a bucket.