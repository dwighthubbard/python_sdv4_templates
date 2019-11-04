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
        echo "Installing debian/ubuntu python"
        echo "    Updating the apt package list"
        apt-get update
        
        echo "    Installing ${PYTHON} ${PYTHON}-venv ${PYTHON}-pip python3-venv python3-pip"
        apt-get install -y ${PYTHON} ${PYTHON}-venv ${PYTHON}-pip python3-venv python3-pip
    fi
    if [ -e "/usr/bin/apk" ]; then
        echo "Alpine python"
        apk --update add python3 python3-dev py3-pip openssl ca-certificates
    fi
    if [ -e "/usr/bin/yum" ]; then
        echo "Installing redhat python3"
        yum install -y python3 python3-devel
    fi
    if [ "$BASE_PYTHON" = "" ]; then
        BASE_PYTHON="`which python3`"
    fi
fi

if [ -e "/usr/bin/apt-get" ]; then
    # Debian removes the pip package bundled in the Python interpreter ensurepip module and instead uses
    # the old pip command from the deb packages.  Which happens to have broken handling of multiple repo
    # configurations.
    # The following overwrites the broken pip with a version close to what is normally bundled with the Python
    # interpreter.
    # This is done using wget because if the pip configuration in the base container has multiple indexes it is
    # not possible to do this with the pip command.
    echo "Replacing debian broken pip wheel package"
    wget -O /usr/share/python-wheels/pip-9.0.1-py2.py3-none-any.whl https://files.pythonhosted.org/packages/30/db/9e38760b32e3e7f40cce46dd5fb107b8c73840df38f0046d8e6514e675a1/pip-19.2.3-py2.py3-none-any.whl
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
