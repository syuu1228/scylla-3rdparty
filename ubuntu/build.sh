#!/bin/bash -e

. /etc/os-release
print_usage() {
    echo "build.sh --target <dist> --name <name> --email <mail> --suffix-count <n>"
    echo "  --target    specify target distribution"
    echo "  --name  maintainer name"
    echo "  --email  maintainer email"
    echo "  --suffix-count  the number append to local version"
    echo "  --upload-to-ppa    upload packages to the PPA"
    exit 1
}

COUNT=1
PPA=0
TARGET=
while [ $# -gt 0 ]; do
    case "$1" in
        "--target")
            TARGET=$2
            shift 2
            ;;
        "--suffix-count")
            COUNT=$2
            shift 2
            ;;
        "--name")
            export NAME=$2
            shift 2
            ;;
        "--email")
            export EMAIL=$2
            shift 2
            ;;
        "--upload-to-ppa")
            PPA=1
            shift 1
            ;;
        *)
            print_usage
            ;;
    esac
done

if [ ! -f /usr/bin/mk-build-deps ]; then
    sudo apt-get -y install devscripts
fi
if [ ! -f /usr/bin/wget ]; then
    sudo apt-get -y install wget
fi
if [ ! -f /usr/bin/lsb_release ]; then
    sudo apt-get -y install lsb-release
fi
if [ ! -f /usr/bin/gdebi ]; then
    sudo apt-get -y install gdebi-core
fi
if [ ! -f /usr/bin/debuild ]; then
    sudo apt-get -y install devscripts
fi
if [ ! -f /usr/bin/dh ]; then
    sudo apt-get -y install debhelper
fi
if [ ! -f /usr/bin/cdbs-edit-patch ]; then
    sudo apt-get -y install cdbs
fi
CODENAME=`lsb_release -c|awk '{print $2}'`

if [ -z "$TARGET" ]; then
    TARGET=$CODENAME
fi

rm -rf build
mkdir -p build

if [ "$TARGET" = "trusty" ]; then
    cp -a ubuntu/antlr3-3.5.2 build/
    cd build/antlr3-3.5.2
    wget http://www.antlr3.org/download/antlr-3.5.2-complete-no-st3.jar
    for ((i=0; i < $COUNT; i++)); do
        dch --distribution $TARGET -l ~${TARGET}ppa "generate ppa package for $TARGET."
    done
    debuild -r fakeroot --no-tgz-check -S -sa
    cd -

    wget -O build/gdb_7.11-0ubuntu1.dsc http://archive.ubuntu.com/ubuntu/pool/main/g/gdb/gdb_7.11-0ubuntu1.dsc
    wget -O build/gdb_7.11.orig.tar.xz http://archive.ubuntu.com/ubuntu/pool/main/g/gdb/gdb_7.11.orig.tar.xz
    wget -O build/gdb_7.11-0ubuntu1.debian.tar.xz http://archive.ubuntu.com/ubuntu/pool/main/g/gdb/gdb_7.11-0ubuntu1.debian.tar.xz
    cd build
    dpkg-source -x gdb_7.11-0ubuntu1.dsc
    mv gdb_7.11.orig.tar.xz scylla-gdb_7.11.orig.tar.xz
    cd -
    rm -rf build/gdb-7.11/debian
    cp -a ubuntu/gdb-7.11/debian build/gdb-7.11/
    cd build/gdb-7.11
    for ((i=0; i < $COUNT; i++)); do
        dch --distribution $TARGET -l ~${TARGET}ppa "generate ppa package for $TARGET."
    done
    debuild -r fakeroot --no-tgz-check -S -sa
    cd -
fi

cp -a ubuntu/scylla-env-1.1 build/
cd build/scylla-env-1.1
for ((i=0; i < $COUNT; i++)); do
    dch --distribution $TARGET -l ~${TARGET}ppa "generate ppa package for $TARGET."
done
debuild -r fakeroot --no-tgz-check -S -sa
cd -

wget -O build/3.5.2.tar.gz https://github.com/antlr/antlr3/archive/3.5.2.tar.gz
cd build
tar xpf 3.5.2.tar.gz
cp -a antlr3-3.5.2 antlr3-c++-dev-3.5.2
cd -
cp -a ubuntu/antlr3-c++-dev-3.5.2/debian build/antlr3-c++-dev-3.5.2
cd build/antlr3-c++-dev-3.5.2
for ((i=0; i < $COUNT; i++)); do
    dch --distribution $TARGET -l ~${TARGET}ppa "generate ppa package for $TARGET."
done
debuild -r fakeroot --no-tgz-check -S -sa
cd -

wget -O build/thrift-0.10.0.tar.gz http://archive.apache.org/dist/thrift/0.10.0/thrift-0.10.0.tar.gz
cd build
tar xpf thrift-0.10.0.tar.gz
cd -
cp -a ubuntu/thrift-0.10.0/debian build/thrift-0.10.0/
cd build/thrift-0.10.0
for ((i=0; i < $COUNT; i++)); do
    dch --distribution $TARGET -l ~${TARGET}ppa "generate ppa package for $TARGET."
done
debuild -r fakeroot --no-tgz-check -S -sa
cd -

if [ $PPA = 1 ]; then
    for i in build/*.changes; do
        dput ppa:scylladb/ppa $i
    done
fi
