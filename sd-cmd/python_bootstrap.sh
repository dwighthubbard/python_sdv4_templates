#!/bin/sh

# setup_environment

export PATH=/opt/python/cp38-cp38m/bin:/opt/python/cp37-cp37m/bin:/opt/python/cp36-cp36m/bin:/opt/python/cp35-cp35m/bin:$PATH

if [ "$BASE_PYTHON" = "" ]; then
    BASE_PYTHON="python3"
fi

export BINDIR="`dirname ${BASE_PYTHON} 2>/dev/null`"
if [ "$BINDIR" != "" ]; then
    export PATH="${BINDIR}:${PATH}"
fi

# init_os
PYTHON=`basename $BASE_PYTHON 2>/dev/null|sed "s/\.//"`
BASE_PYTHON_BASENAME="`basename $BASE_PYTHON 2>/dev/null`"

if [ "$BASE_PYTHON_BASENAME" = "" ]; then
    BASE_PYTHON_BASENAME="python3"
fi


if [ -z "$BASE_PYTHON" ]; then
    echo "BASE_PYTHON is not set, looking for a working python3 interpreter"
    # No BASE_PYTHON declared, see if there is a working python3 interpreter in the path
    python3 -m venv --help > /dev/null 2>&1
    RC="$?"
    if [ "$RC" = "0" ]; then
        export BASE_PYTHON="`$BASE_PYTHON_BASENAME -c "import sys;print(sys.executable)"`"
        echo "    Found working python interpreter: $BASE_PYTHON"
    fi
else
    if [ ! -e "$BASE_PYTHON" ]; then
        echo "$BASE_PYTHON interpreter does not exist, trying to use it to find the full path"
        FULL_BASE_PYTHON="`$BASE_PYTHON -c "import sys;print(sys.executable)" 2>/dev/null`"
        RC="$?"
        if [ "$RC" = "0" ]; then
            echo "    Checking to see if the pip module is available"
            $FULL_BASE_PYTHON -m pip --help > /dev/null 2>&1
            RC="$?"
            if [ "$RC" = "0" ]; then
                export BASE_PYTHON="$FULL_BASE_PYTHON"
                echo "    Updated BASE_PYTHON to $BASE_PYTHON"
            else
                echo "    The pip module for $FULL_BASE_PYTHON is broken or missing, not using that interpreter"
            fi
        fi
    fi
fi

if [ ! -e "$BASE_PYTHON" ]; then
    if [ -e "/usr/bin/apt-get" ]; then
        echo "Installing debian/ubuntu python"
        echo "    Updating the apt package list"
        apt-get update
        
        echo "    Installing ${PYTHON} ${PYTHON}-venv ${PYTHON}-pip python3-venv python3-pip"
        apt-get install -y ${PYTHON} ${PYTHON}-venv ${PYTHON}-pip python3-venv python3-pip
    fi
    if [ -e "/sbin/apk" ]; then
        echo "Alpine python"
        apk --update add python3 python3-dev py3-pip py3-cffi py3-cparser py3-openssl py3-lxml gcc musl-dev libc-dev libffi libffi-dev libxml2-dev libxslt-dev openssl openssl-dev ca-certificates
    fi
    if [ -e "/usr/bin/yum" ]; then
        echo "Installing redhat python3"

        # Try installing python3 without adding/enabling repos
        if [ ! -e "/usr/bin/python3" ]; then
            yum install -y python3 python3-devel python3-pip || /bin/true
        fi
        
        if [ ! -e "/usr/bin/python3" ]; then
            # Add the epel-release repo which has the interpreter on older rhel releases
            yum install -y epel-release || /bin/true
            yum install -y --enablerepo epel python3 python3-devel python3-pip || /bin/true
        fi

        if [ ! -e "/usr/bin/python3" ]; then
            # Add the epel-release repo which has the interpreter on older rhel releases
            yum install -y --enablerepo epel python38 python38-devel python38-pip || /bin/true
        fi

        if [ ! -e "/usr/bin/python3" ]; then
            # Add the epel-release repo which has the interpreter on older rhel releases
            yum install -y --enablerepo epel python37 python37-devel python37-pip || /bin/true
        fi

        if [ ! -e "/usr/bin/python3" ]; then
            # Add the epel-release repo which has the interpreter on older rhel releases
            yum install -y --enablerepo epel python36 python36-devel python36-pip || /bin/true
        fi
        
        if [ ! -e "/usr/bin/python3" ]; then
            # Add the epel-release repo which has the interpreter on older rhel releases
            yum install -y --enablerepo epel python35 python35-devel python35-pip || /bin/true
        fi

        if [ ! -e "/usr/bin/python3" ]; then
            # Add the epel-release repo which has the interpreter on older rhel releases
            yum install -y --enablerepo epel python34 python34-devel python34-pip || /bin/true
        fi

        if [ -e /usr/bin/python ]; then
            /usr/bin/python3 -m pip install -U pip
        fi
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
        if [ ! -e "/usr/bin/wget" ]; then
        /usr/bin/apt-get install -y wget
    fi
    wget -O /usr/share/python-wheels/pip-9.0.1-py2.py3-none-any.whl https://files.pythonhosted.org/packages/30/db/9e38760b32e3e7f40cce46dd5fb107b8c73840df38f0046d8e6514e675a1/pip-19.2.3-py2.py3-none-any.whl
    $BASE_PYTHON -m pip install -U pip
fi

export BINDIR="`dirname ${BASE_PYTHON} 2>/dev/null`"
if [ "$BINDIR" != "" ]; then
    export PATH="${BINDIR}:${PATH}"
fi

export BASE_PYTHON_BIN="${BINDIR}"

# Update pip
$BASE_PYTHON -c "import pip,sys;sys.exit(int(int(pip.__version__.split('.')[0])<19))" >/dev/null 2>&1
RC="$?"
if [ "$RC" != "0" ]; then
    $BASE_PYTHON -m pip install -q -U pip
fi

$BASE_PYTHON -c "import setuptools,sys;sys.exit(int(int(setuptools.__version__.split('.')[0])<40))" >/dev/null 2>&1
RC="$?"
if [ "$RC" != "0" ]; then
    $BASE_PYTHON -m pip install -q -U setuptools
fi

# install_pyrun
$BASE_PYTHON -c "import pypirun" >/dev/null 2>&1
RC="$?"
if [ "$RC" != "0" ]; then
    echo "Installing pypirun"
    $BASE_PYTHON -m pip install -q -U pypirun
fi

# install_screwdrivercd
$BASE_PYTHON -c "import screwdrivercd" >/dev/null 2>&1
RC="$?"
if [ "$RC" != "0" ]; then
    echo "Installing screwdrivercd"
    $BASE_PYTHON -m pip install -q -U screwdrivercd
fi

cat << EOF > "/tmp/python_bootstrap.env"
export BINDIR="$BINDIR"
export BASE_PYTHON="$BASE_PYTHON"
export BASE_PYTHON_BIN="$BASE_PYTHON_BIN"
export PATH=$PATH
echo "BASE_PYTHON=\"$BASE_PYTHON\""
echo "BASE_PYTHON_BIN=\"$BASE_PYTHON_BIN\""
echo "BINDIR=\"$BINDIR\""
echo "PATH=\"$PATH\""
EOF
