FROM spitzenidee/postgresql_rdkit_precursor:latest
MAINTAINER Michael Spitzer <professa@gmx.net>

#######################################################################
# WARNING this may take about an hour to build.
# We will be using two (2) parallel threads for "cmake".
#######################################################################

#######################################################################
# Ubuntu build environment was prepared already in
# "spitzenidee/postgresql_rdkit_precursor:latest"
WORKDIR $RDBASE/build
RUN cmake -DRDK_BUILD_INCHI_SUPPORT=ON -DRDK_BUILD_PGSQL=ON -DRDK_BUILD_AVALON_SUPPORT=ON -DPostgreSQL_TYPE_INCLUDE_DIR="/usr/include/postgresql/9.6/server" -DPostgreSQL_ROOT="/usr/lib/postgresql/9.6" .. && make -j 2 && make install && sh Code/PgSQL/rdkit/pgsql_install.sh

#######################################################################
# Create a standard schema "chemical", and create the rdkit extension within, so there is an example to directly start with
#RUN psql -h localhost -U postgresql -c "CREATE SCHEMA chemical"
#RUN psql -h localhost -U postgresql -c "CREATE EXTENSION rdkit WITH SCHEMA chemical"

#######################################################################
# Clean up
RUN apt-get clean && apt-get purge

#######################################################################
# Finishing
WORKDIR $RDBASE
USER postgres
