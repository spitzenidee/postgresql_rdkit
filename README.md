# A Postgresql Image including the RDKit chemical cartridge...
...as well as some base extensions (pg_cron, pgsql_http, POWA).

Versions currently in this image:
* RDKIT (https://github.com/rdkit/rdkit): 2017.09.3
* PG_CRON (https://github.com/citusdata/pg_cron): 1.0.2
* PGSQL_HTTP (): 1.2.2
* POWA (https://github.com/powa-team/powa): 1.2.2 / 3.1.1 (POWA archivist)

You can find the image on Dockerhub here:
* https://hub.docker.com/r/spitzenidee/postgresql_rdkit/
* Pull via: `docker pull spitzenidee/postgresql_rdkit`

In order to look at query stats and hypothetical index generation, you can deploy POWA-Web (https://github.com/powa-team/powa-web) alongside of this container.
