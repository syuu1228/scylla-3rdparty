#!/bin/bash -e

RPMBUILD=`pwd`/build/rpmbuild
TARGET=epel-7-x86_64

is_redhat_variant() {
    [ -f /etc/redhat-release ]
}
pkg_install() {
    if is_redhat_variant; then
        sudo yum install -y $1
    else
        echo "Requires to install following command: $1"
        exit 1
    fi
}

if [ ! -f /usr/bin/mock ]; then
    pkg_install mock
fi
if [ ! -f /usr/bin/rpm ]; then
    pkg_install rpm
fi
if [ ! -f /usr/bin/wget ]; then
    pkg_install wget
fi
if [ ! -f /usr/bin/patch ]; then
    pkg_install patch
fi

mkdir -p $RPMBUILD
mkdir -p build/downloads
cd build/downloads

if [ ! -f binutils-2.25-15.fc23.src.rpm ]; then
    wget https://kojipkgs.fedoraproject.org//packages/binutils/2.25/15.fc23/src/binutils-2.25-15.fc23.src.rpm
fi

if [ ! -f isl-0.14-4.fc23.src.rpm ]; then
    wget https://kojipkgs.fedoraproject.org//packages/isl/0.14/4.fc23/src/isl-0.14-4.fc23.src.rpm
fi

if [ ! -f gcc-5.3.1-2.fc23.src.rpm ]; then
    wget https://kojipkgs.fedoraproject.org//packages/gcc/5.3.1/2.fc23/src/gcc-5.3.1-2.fc23.src.rpm
fi 
if [ ! -f boost-1.58.0-11.fc23.src.rpm ]; then
    wget https://kojipkgs.fedoraproject.org//packages/boost/1.58.0/11.fc23/src/boost-1.58.0-11.fc23.src.rpm
fi

if [ ! -f ragel-6.8-5.fc23.src.rpm ]; then
   wget https://kojipkgs.fedoraproject.org//packages/ragel/6.8/5.fc23/src/ragel-6.8-5.fc23.src.rpm
fi

if [ ! -f gdb-7.10.1-30.fc23.src.rpm ]; then
   wget https://kojipkgs.fedoraproject.org//packages/gdb/7.10.1/30.fc23/src/gdb-7.10.1-30.fc23.src.rpm
fi

if [ ! -f pyparsing-2.0.3-2.fc23.src.rpm ]; then
   wget https://kojipkgs.fedoraproject.org//packages/pyparsing/2.0.3/2.fc23/src/pyparsing-2.0.3-2.fc23.src.rpm
fi

cd -

if [ ! -f build/srpms/scylla-env-1.0-1.el7*.src.rpm ]; then
    cd common
    tar cpf ../build/scylla-env-1.0.tar scylla-env-1.0
    cd -
    sudo mock --buildsrpm --root=$TARGET --resultdir=`pwd`/build/srpms --spec=redhat/scylla-env.spec --sources=build/
fi

if [ ! -f build/srpms/scylla-binutils-2.25-15.el7*.src.rpm ]; then
    rpm --define "_topdir $RPMBUILD" -ivh build/downloads/binutils-2.25-15.fc23.src.rpm
    sudo mock --buildsrpm --root=$TARGET --resultdir=`pwd`/build/srpms --spec=redhat/scylla-binutils225.spec --sources=$RPMBUILD/SOURCES
fi

if [ ! -f build/srpms/scylla-isl-0.14-4.el7*.src.rpm ]; then
    rpm --define "_topdir $RPMBUILD" -ivh build/downloads/isl-0.14-4.fc23.src.rpm
    sudo mock --buildsrpm --root=$TARGET --resultdir=`pwd`/build/srpms --spec=redhat/scylla-isl014.spec --sources=$RPMBUILD/SOURCES
fi

if [ ! -f build/srpms/scylla-gcc-5.3.1-2.el7*.src.rpm ]; then
    rpm --define "_topdir $RPMBUILD" -ivh build/downloads/gcc-5.3.1-2.fc23.src.rpm
    sudo mock --buildsrpm --root=$TARGET --resultdir=`pwd`/build/srpms --spec=redhat/scylla-gcc531.spec --sources=$RPMBUILD/SOURCES
fi

if [ ! -f build/srpms/scylla-boost-1.58.0-11.el7*.src.rpm ]; then
    rpm --define "_topdir $RPMBUILD" -ivh build/downloads/boost-1.58.0-11.fc23.src.rpm
    sudo mock --buildsrpm --root=$TARGET --resultdir=`pwd`/build/srpms --spec=redhat/scylla-boost158.spec --sources=$RPMBUILD/SOURCES
fi

if [ ! -f build/srpms/scylla-ragel-6.8-5.el7*.src.rpm ]; then
    rpm --define "_topdir $RPMBUILD" -ivh build/downloads/ragel-6.8-5.fc23.src.rpm
    sudo mock --buildsrpm --root=$TARGET --resultdir=`pwd`/build/srpms --spec=redhat/scylla-ragel68.spec --sources=$RPMBUILD/SOURCES
fi

if [ ! -f build/srpms/scylla-gdb-7.10.1-30.el7*.src.rpm ]; then
    rpm --define "_topdir $RPMBUILD" -ivh build/downloads/gdb-7.10.1-30.fc23.src.rpm
    sudo mock --buildsrpm --root=$TARGET --resultdir=`pwd`/build/srpms --spec=redhat/scylla-gdb7101.spec --sources=$RPMBUILD/SOURCES
fi

if [ ! -f build/srpms/pyparsing-2.0.3-2.el7*.src.rpm ]; then
    rpm --define "_topdir $RPMBUILD" -ivh build/downloads/pyparsing-2.0.3-2.fc23.src.rpm
    sudo mock --buildsrpm --root=$TARGET --resultdir=`pwd`/build/srpms --spec=redhat/pyparsing203.spec --sources=$RPMBUILD/SOURCES
fi

if [ ! -f build/srpms/scylla-antlr3-tool-3.5.2-1.el7*.src.rpm ]; then
    cp -a common/antlr3-3.5.2 build/scylla-antlr352-tool-3.5.2
    cd build/scylla-antlr352-tool-3.5.2
    wget http://www.antlr3.org/download/antlr-3.5.2-complete-no-st3.jar
    cd -
    cd build
    tar cJpf scylla-antlr352-tool-3.5.2.tar.xz scylla-antlr352-tool-3.5.2
    cd -
    sudo mock --buildsrpm --root=$TARGET --resultdir=`pwd`/build/srpms --spec=redhat/scylla-antlr352-tool.spec --sources=build/
fi

if [ ! -f build/srpms/scylla-antlr3-C++-devel-3.5.2-1.el7*.src.rpm ];then
    wget -O build/3.5.2.tar.gz https://github.com/antlr/antlr3/archive/3.5.2.tar.gz
    sudo mock --buildsrpm --root=$TARGET --resultdir=`pwd`/build/srpms --spec=redhat/scylla-antlr352-C++-devel.spec --sources=build/
fi
