---
myst:
  html_meta:
    description: "Migrate Grafana data in PostgreSQL before refreshing grafana-k8s to a revision that includes the database naming change from grafana-k8s-operator#543."
---

# How to migrate Grafana PostgreSQL data before refreshing grafana-k8s

Refreshing `grafana-k8s` to a revision that includes
[canonical/grafana-k8s-operator#543](https://github.com/canonical/grafana-k8s-operator/pull/543)
changes the PostgreSQL database name that Grafana expects.

Before that change, Grafana used this database name:

`<grafana-application-name>-grafana-k8s-<model-uuid>`

After that change, Grafana uses this database name:

`<model-uuid>-<grafana-application-name>`

If the new name is longer than 54 characters, it is truncated to 54
characters.

If you refresh without migrating the data first, Grafana will start using a
new, empty database. Dashboards, users, plugins, alerting state, and other
Grafana data stored in PostgreSQL will remain in the old database.

```{warning}
This procedure requires operator-level access to the PostgreSQL primary, as
provided by the `postgresql-k8s` charm. If your deployment uses a managed
database service and you cannot access PostgreSQL directly, use your provider's
backup and restore workflow instead.

```

## Before you begin

Use a short maintenance window for this procedure.

### 1. Create a verification resource

Log into your current Grafana UI and create a distinct test resource. This can an alert rule named `migration-check` or a test dashboard. After the migration, you will look for this resource to instantly verify that your data successfully carried over without needing to manually inspect the database tables.

### 2. Example environment topology

For reference, this guide assumes an environment similar to the topology below. Note that all revisions more recent than revision 187 on track `12.4` will contain the DB naming change. Since revision 187 was the last revision of track `12.4` to not contain this change, this guide begins with Grafana revision 187 as a starting point and later refreshes it to a more recent revision.

```{mermaid}
graph LR

subgraph model["Juju model"]
  grafana["grafana<br/>grafana-k8s<br/>revision 187"]
  pgbouncer["pgbouncer-k8s"]
  postgresql["postgresql-k8s"]
  traefik["traefik-k8s"]

  grafana --- |pgsql to database| pgbouncer
  pgbouncer --- |backend-database to database| postgresql
  grafana --- |ingress| traefik
end
```

---

## 1. Compute the old and new database names

Run `juju show-model` and note the `model-uuid` value.

Then set these shell variables in your terminal to calculate the source and target database names:

```bash
APP_NAME=grafana
MODEL_UUID=<model-uuid>

OLD_DB="${APP_NAME}-grafana-k8s-${MODEL_UUID}"
NEW_DB="${MODEL_UUID}-${APP_NAME}"
NEW_DB="${NEW_DB:0:54}"

echo "Old Database: $OLD_DB"
echo "New Database: $NEW_DB"
```

If your Grafana application is not named `grafana`, replace `APP_NAME` with your deployed application name.

## 2. Unrelate Grafana and PgBouncer

Before renaming the database, you must remove the relations to disconnect Grafana and PgBouncer. This ensures that no active connections hold a lock on the old database.

Run the following commands to break the relations:

```bash
juju remove-relation grafana:pgsql pgbouncer:database
```

Wait until the applications finish updating and show no active connections.

## 3. Connect to PostgreSQL and rename the database

Now that the database is completely isolated and free of active locks, gather your credentials, access the PostgreSQL primary unit, and perform the database rename.

First, find the PostgreSQL primary unit address (using the application name from your bundle, e.g., `pg`):

```bash
juju status pg
```

Retrieve the `operator` password:

```bash
juju run pg/leader get-password
```

Enter the PostgreSQL container shell:

```bash
juju ssh --container postgresql pg/leader bash
```

From inside the container shell, open a psql session using the primary IP address you found earlier. For more structured details on interacting with the database CLI or working with internal user roles, consult the [Charmed PostgreSQL K8s Tutorial](https://documentation.ubuntu.com/charmed-postgresql-k8s/14/tutorial/).

```bash
psql --host=<postgresql-primary-ip> --username=operator --password postgres
```

Inside the `psql` session, rename the database directly to its new expected name using the strings you computed in Step 1:

```sql
ALTER DATABASE "<old-db-name>" RENAME TO "<new-db-name>";
```

Type `\q` to exit `psql`, then type `exit` to leave the container container shell.

## 4. Deploy or Refresh the Grafana Bundle

Apply your updated bundle configuration to deploy the new revision of Grafana and re-establish the relations.

```bash
juju refresh grafana
```

Wait for the deployment process to complete and ensure all units return to an active, idle state.

## 5. Verify the migration

The change should now be in effect. Open the Grafana UI in your browser and log in.

Navigate to your resource dashboards or alert lists. Confirm that the test resource (e.g., the `migration-check` alert rule) you created before the migration exists and is intact. If the resource is visible, your historical data has migrated to the new database configuration successfully.
