FROM postgres:9.6.8
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
ENV PostgreSQL_ROOT="/usr/lib/postgresql/9.6"
ENV PostgreSQL_TYPE_INCLUDE_DIR="/usr/include/postgresql/9.6/server"
ENV PGPASSWORD="$POSTGRES_PASSWORD"
ENV PGUSER="$POSTGRES_USER"

#######################################################################
# Specify the RDKit release from github we want to pull.
ENV RDKIT_BRANCH="2017_09_3"

#######################################################################
# Prepare the build requirements for the RDKit compilation:
WORKDIR $RDBASE
RUN apt-get update && \
    apt-get install -y \
    postgresql-server-dev-all \
    postgresql-client \
    postgresql-plpython-9.6 \
    postgresql-plpython3-9.6 \
    git \
    cmake \
    wget \
    build-essential \
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
      -DPostgreSQL_TYPE_INCLUDE_DIR="/usr/include/postgresql/9.6/server" \
      -DPostgreSQL_ROOT="/usr/lib/postgresql/9.6" .. && \
# Now make / build and use all available cores / threads via "nproc":
    make -j `nproc` && \
    make install && \
# Installing RDKit Postgresql extension:
    sh Code/PgSQL/rdkit/pgsql_install.sh && \
# Cleaning up:
    make clean && \
    cd $RDBASE && \
    rm -r $RDBASE/build && \
    apt-get remove -y git wget cmake build-essential && \
    apt-get autoremove --purge -y && \
    apt-get clean && \
    apt-get purge && \
    rm -rf /var/lib/apt/lists/*
# Done.
