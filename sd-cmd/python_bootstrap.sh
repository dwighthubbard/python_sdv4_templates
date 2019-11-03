#!/bin/bash

# setup_environment

export PATH=/opt/python/cp38-cp38m/bin:/opt/python/cp37-cp37m/bin:/opt/python/cp36-cp36m/bin:$PATH
export BINDIR="`dirname ${BASE_PYTHON}`"
if [ "$BINDIR" != "" ]; then
    export PATH="${BINDIR}:${PATH}"
fi

# init_os
PYTHON=`basename $BASE_PYTHON|sed "s/\.//"`
if [ ! -e "$BASE_PYTHON" ]; then
    if [ -e "/usr/bin/apt-get" ]; then
        echo "Updating the apt package list"
        apt-get update
        apt-get install -y ${PYTHON} ${PYTHON}-venv ${PYTHON}-pip python3-venv python3-pip
    fi
    if [ -e "/usr/bin/apk" ]; then
        apk --update add python3 python3-dev py3-pip openssl ca-certificates
    fi
    if [ -e "/usr/bin/yum" ]; then
        yum install -y python3 python3-devel
    fi
    if [ "$BASE_PYTHON" = "" ]; then
        BASE_PYTHON="`which python3`"
    fi
fi

export BINDIR="`dirname ${BASE_PYTHON}`"
if [ "$BINDIR" != "" ]; then
    export PATH="${BINDIR}:${PATH}"
fi

# Update pip
$BASE_PYTHON -m pip install -q -U pip
$BASE_PYTHON -m pip install -q -U setuptools

# install_pyrun
$BASE_PYTHON -m pip install -q pypirun

cat << EOF > "/tmp/python_bootstrap.env"
export BINDIR="$BINDIR"
export BASE_PYTHON="$BASE_PYTHON"
export PATH=\$PATH:\$BINDIR
EOF
