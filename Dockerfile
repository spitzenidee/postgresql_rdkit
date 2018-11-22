FROM spitzenidee/postgresql_base:11
MAINTAINER Michael Spitzer <professa@gmx.net>

#######################################################################
# DockerHub / GitHub:
# https://hub.docker.com/r/spitzenidee/postgresql_rdkit/
# https://github.com/spitzenidee/postgresql_rdkit/
#######################################################################

#######################################################################
# Prepare the environment for the rdkit compilation:
ENV RDBASE="/opt/rdkit"
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$RDBASE/lib:/usr/lib/x86_64-linux-gnu"
ENV PYTHONPATH="$PYTHONPATH:$RDBASE"
ENV PostgreSQL_ROOT="/usr/lib/postgresql/11"
ENV PostgreSQL_TYPE_INCLUDE_DIR="/usr/include/postgresql/11/server"
ENV PGPASSWORD="$POSTGRES_PASSWORD"
ENV PGUSER="$POSTGRES_USER"
#######################################################################
# Specify the RDKit release from github we want to pull.
ENV RDKIT_BRANCH="2018_09_1"

#######################################################################
# Prepare the build requirements for the RDKit compilation:
WORKDIR $RDBASE
RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake wget build-essential ca-certificates \
    postgresql-server-dev-all \
    postgresql-client \
    postgresql-plpython-10 \
    postgresql-plpython3-10 \
    python-numpy \
    python-dev \
    sqlite3 \
    libsqlite3-dev \
    libboost-all-dev \
    libboost-dev \
    libboost-system-dev \
    libboost-thread-dev \
    libboost-serialization-dev \
    libboost-python-dev \
    libboost-regex-dev \
    libeigen3-dev && \
# Cloning RDKit git repo:
    wget https://github.com/rdkit/rdkit/archive/Release_$RDKIT_BRANCH.tar.gz && \
    tar xzf Release_$RDKIT_BRANCH.tar.gz -C . --strip-components=1 && \
    mkdir $RDBASE/build && \
    cd $RDBASE/build && \
# Compiling and installing RDKit (incl. INCHI / AVALON / PGSQL support):
    cmake \
      -DRDK_BUILD_INCHI_SUPPORT=ON \
      -DRDK_BUILD_PGSQL=ON \
      -DRDK_BUILD_AVALON_SUPPORT=ON \
      -DPostgreSQL_TYPE_INCLUDE_DIR=$PostgreSQL_TYPE_INCLUDE_DIR \
      -DPostgreSQL_ROOT=$PostgreSQL_ROOT .. && \
# Now make / build and use all available cores / threads via "nproc":
    make -j `nproc` && \
    make install && \
# Installing RDKit Postgresql extension:
    sh Code/PgSQL/rdkit/pgsql_install.sh && \
# Cleaning up:
    make clean && \
    cd $RDBASE && \
    rm -r $RDBASE/build && \
    apt-get remove -y cmake wget build-essential ca-certificates && \
    apt-get autoremove --purge -y && \
    apt-get clean && \
    apt-get purge && \
    rm -rf /var/lib/apt/lists/*
# Done.
