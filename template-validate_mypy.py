namespace: python
name: validate_type
description: Run the mypy type validator
images:
    manylinux2010: quay.io/pypa/manylinux2010_x86_64
    ubuntu: ubuntu:latest
version: 1.0.0
maintainer: python-devel@oath.com
config:
    image: manylinux2010
    environment:
        BASE_PYTHON: ""
        PACKAGE_DIR: ""
        GIT_SHALLOW_CLONE: false
        LANG: en_US.UTF-8
    steps:
    -   begin: echo "Starting ${SD_TEMPLATE_FULLNAME}"
    -   motd: |
            cat << EOF
            This step will run unittests using the tox tool
            EOF
    -   display_environment: printenv|sort
    -   setup_environment: |
            export PATH=/opt/python/cp37-cp37m/bin:/opt/python/cp36-cp36m/bin:/opt/python/cp27-cp27m/bin:$PATH
            if [ "$BASE_PYTHON" = "" ]; then
                BASE_PYTHON="`which python3`"
            fi
            export BINDIR="`dirname ${BASE_PYTHON}`"
            if [ "$BINDIR" != "" ]; then
                export PATH="${BINDIR}:${PATH}"
            fi
    -   init_os: |
            PYTHON=`basename $BASE_PYTHON|sed "s/\.//"`
            if [ -e "/usr/bin/apt-get" ]; then
                echo "Updating the apt package list"
                apt-get update
            fi
            if [ ! -e "$BASE_PYTHON" ]; then
                if [ -e "/usr/bin/apt-get" ]; then
                    echo "Found apt-get, configuring for debian distro"
                    apt-get install -y ${PYTHON} ${PYTHON}-venv python3-pip
                fi
            fi
    -   install_utility: |
            $BASE_PYTHON -m pip install mypy 
            $BASE_PYTHON -m pip install .[mypy]
    -   update_version: echo "Update version"
    -   validate_code: |
            if [ -z "$PACKAGE_DIR"  ]; then
                PACKAGE_DIR="`$BASE_PYTHON setup.py --name`"
            fi
            $BIN_DIR/mypy $PACKAGE_DIR
    -   disable_sonarqube: rm sonar-project.properties || true  
    -   end: echo "Ending ${SD_TEMPLATE_FULLNAME}"
