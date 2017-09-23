FROM postgres:9.6.5
MAINTAINER Michael Spitzer <professa@gmx.net>

#######################################################################
# DockerHub / GitHub:
# https://hub.docker.com/r/spitzenidee/postgresql_rdkit/
# https://github.com/spitzenidee/postgresql_rdkit/
#######################################################################

#######################################################################
# Prepare the build requirements for the rdkit compilation:
RUN apt-get update && apt-get install -y \
 postgresql-server-dev-all \
 postgresql-client \
 postgresql-plpython-9.6 \
 postgresql-plpython3-9.6 \
 git \
 cmake \
 build-essential \
 python-numpy \
 python-dev \
 sqlite3 \
 libsqlite3-dev \
 libboost-dev \
 libboost-system-dev \
 libboost-thread-dev \
 libboost-serialization-dev \
 libboost-python-dev \
 libboost-regex-dev \
 libeigen3-dev

#######################################################################
# Prepare the environment for the rdkit compilation:
ENV RDBASE="/opt/rdkit"
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$RDBASE/lib:/usr/lib/x86_64-linux-gnu"
ENV PYTHONPATH="$PYTHONPATH:$RDBASE"
ENV PostgreSQL_ROOT="/usr/lib/postgresql/9.6"
ENV PostgreSQL_TYPE_INCLUDE_DIR="/usr/include/postgresql/9.6/server"
ENV PGPASSWORD="$POSTGRES_PASSWORD"
ENV PGUSER="$POSTGRES_USER"

#######################################################################
# Pull the latest rdkit distribution (master branch) from github.
# Build with INCHI and AVALON support and directly install the pgsql
# cartridge. Then clean up:
ENV RDKIT_BRANCH="master"
WORKDIR /opt
RUN git clone \
      -b $RDKIT_BRANCH \
      --single-branch https://github.com/rdkit/rdkit.git && \
    mkdir $RDBASE/build
WORKDIR $RDBASE/build
RUN cmake \
      -DRDK_BUILD_INCHI_SUPPORT=ON \
      -DRDK_BUILD_PGSQL=ON \
      -DRDK_BUILD_AVALON_SUPPORT=ON \
      -DPostgreSQL_TYPE_INCLUDE_DIR="/usr/include/postgresql/9.6/server" \
      -DPostgreSQL_ROOT="/usr/lib/postgresql/9.6" .. && \
    make -j `nproc` && \
    make install && \
    sh Code/PgSQL/rdkit/pgsql_install.sh && \
    make clean && \
    apt-get clean && \
    apt-get purge

#######################################################################
# Does not work, so it's commented out until I figure out the correct
# way on how to do this.
# Create a standard schema "chemical", and create the rdkit extension
# within, so there is an example to directly start with:
#RUN psql -h localhost -U postgres -c "CREATE SCHEMA chemical"
#RUN psql -h localhost -U postgresql -c "CREATE EXTENSION rdkit WITH SCHEMA chemical"
