# Set up a development environment using Minio

[Minio](https://min.io/) is a lightweight S3-compatible object storage system.
In its single-node configuration, it is suitable for providing s3 storage backends 
for **testing purposes** for distributed COS components such as Tempo, Loki 
and Mimir. 

```{warning} 
In production, you will probably want to deploy Ceph and then follow [this guide](https://discourse.charmhub.io/t/tempo-ha-docs-how-to-use-ceph-backed-s3-storage-for-ha-charms/15740).
```

The Minio charm does not directly provide an `s3` endpoint. For that, we need 
to deploy an `s3-integrator` app to act as intermediary.

## Single-node Minio deployment

### Deploy Minio

Deploy the `minio` charm using the command below. Depending on how exposed your environment is, you might want to consider using stronger access and secret keys. 

```bash
$ juju deploy minio \
    --channel edge \
    --trust \
    --config access-key=accesskey \
    --config secret-key=mysoverysecretkey
```

```{note}
The secret key must be at least 8 characters long or Minio will refuse to start.
```

Then wait for it to go to `active/idle`.

### Deploy the S3 integrator

```bash    
    $ juju deploy s3-integrator --channel edge --trust s3
```

```{note}     
We deploy `s3-integrator` as `s3`, but feel free to give the app a different name.
```

Then wait for it to go to `blocked/idle`. The app will stay `blocked` until you 
run the `sync-s3-credentials` action to give it access to `minio`:

```bash
$ juju run s3/leader sync-s3-credentials \
    access-key=accesskey \
    secret-key=mysoverysecretkey
```

### Add a bucket

#### Using the Minio UI

The simplest way to create a bucket is by using the Minio console. To do this, 
you first need to obtain the Minio IP from the `juju status` output, and then 
open `http://MINIO_IP:9001` in a browser using the access key and secret key 
you configured earlier as user and password respectively.

From there you will be able to create a bucket with a few clicks. See 
[this guide](https://thenewstack.io/how-to-create-an-object-storage-bucket-with-minio-object-storage/) for a step-by-step tutorial.


#### Using the Python SDK

```bash
$ pip install minio
```

Save the following snippet in a file named `create_bucket.py`:

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

Then execute it using the following command

```bash
$ python3 ./create_bucket.py
```

#### Integrate S3

Now grant the s3 integrator access to the bucket by doing:

```bash
$ JUJU_MODEL=your-model-name    
$ juju config s3 \
    endpoint=minio-0.minio-endpoints.$JUJU_MODEL.svc.cluster.local:9000 bucket=mybucket
```

Now the s3 integrator is ready to provide the `s3` integration to any charm 
requiring it.

```{warning}
    
Note that, as of revision 41 of the S3 Integrator, each `s3-integrator` can only have 
**one** unique bucket configuration.
    
[See more](https://github.com/canonical/s3-integrator/issues/48)
```

## A handy script to do it all

If you would rather have this all done for you, see this 
[small python script](https://raw.githubusercontent.com/canonical/tempo-coordinator-k8s-operator/main/scripts/deploy_minio.py) that does all of the above, for internal development purposes. As it happens, you can use it too!

To use the script to deploy Minio, execute the following commands.

```bash
$ juju switch cos  # select the model where you have COS-lite deployed
$ sudo pip3 install minio  # install the script's only dependency
$ curl https://raw.githubusercontent.com/canonical/tempo-coordinator-k8s-operator/main/scripts/deploy_minio.py | python3
```

The script will install the `minio` and `s3-integrator` charms, and configure them to 
create and use `tempo` as the bucket name where traces will be stored. Once 
the script finishes, you should see the following message:

```
Waiting for task 2...
ok: Credentials successfully updated.

all done! have fun.
```

Your storage is now ready, and you can integrate the `s3` app to whatever 
needs a bucket.