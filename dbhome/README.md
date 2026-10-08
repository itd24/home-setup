# dbhome

PostgreSQL instance of the home server, based on the `pgvector/pgvector:pg18` image.

## Two ways of initialising

`init/0-create-base-schemas-and-users.sql` runs automatically, but only when the data
folder is still empty. It creates one database and one owner role per service. Replace
every `change-me` password in that file and in `.env` before the first start, they have to
match. The value of `POSTGRES_ADMIN_USER` has to be the same role name that the script
grants privileges to, `admin` in the shipped example.

The scripts in `manual-initialisation/` have to be run by hand. They create a single
database in an already running instance and they need to be connected to a specific
database, which the automatic init step cannot do. Connect with `psql` and run them one by
one:

```bash
docker exec -i dbhome psql -U postgres -d firefly < manual-initialisation/1-create-matching-database.sql
```
