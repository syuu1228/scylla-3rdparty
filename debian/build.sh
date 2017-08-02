#!/bin/bash -e

. /etc/os-release
print_usage() {
    echo "build.sh --target <dist> --name <name> --email <mail>"
    echo "  --target    specify target distribution"
    echo "  --name  maintainer name"
    echo "  --email  maintainer email"
    exit 1
}

TARGET=
while [ $# -gt 0 ]; do
    case "$1" in
        "--target")
            TARGET=$2
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

if [ "$TARGET" = "jessie" ]; then
    cp -a debian/antlr3-3.5.2 build/
    cd build/antlr3-3.5.2
    wget http://www.antlr3.org/download/antlr-3.5.2-complete-no-st3.jar
    debuild -r fakeroot --no-tgz-check -S -sa
    cd -

    cp -a common/scylla-env-1.0 build/
    cp -a debian/scylla-env-1.0/debian build/scylla-env-1.0/
    cd build/scylla-env-1.0
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
    cp -a debian/gdb-7.11/debian build/gdb-7.11/
    cd build/gdb-7.11
    debuild -r fakeroot --no-tgz-check -S -sa
    cd -
fi

wget -O build/3.5.2.tar.gz https://github.com/antlr/antlr3/archive/3.5.2.tar.gz
cd build
tar xpf 3.5.2.tar.gz
cp -a antlr3-3.5.2 antlr3-c++-dev-3.5.2
cd -
cp -a debian/antlr3-c++-dev-3.5.2/debian build/antlr3-c++-dev-3.5.2
cd build/antlr3-c++-dev-3.5.2
debuild -r fakeroot --no-tgz-check -S -sa
cd -

wget -O build/thrift-0.10.0.tar.gz http://archive.apache.org/dist/thrift/0.10.0/thrift-0.10.0.tar.gz
cd build
tar xpf thrift-0.10.0.tar.gz
cd -
cp -a debian/thrift-0.10.0/debian build/thrift-0.10.0/
cd build/thrift-0.10.0
debuild -r fakeroot --no-tgz-check -S -sa
cd -

if [ "$TARGET" = "jessie" ]; then
    cd build
    wget https://launchpad.net/debian/+archive/primary/+files/gcc-5_5.4.1-5.dsc
    wget https://launchpad.net/debian/+archive/primary/+files/gcc-5_5.4.1.orig.tar.gz
    wget https://launchpad.net/debian/+archive/primary/+files/gcc-5_5.4.1-5.diff.gz
    dpkg-source -x gcc-5_5.4.1-5.dsc
    cd -
    cp -a debian/gcc-5-5.4.1/debian build/gcc-5-5.4.1/
    cd build/gcc-5-5.4.1
    # resolve build time dependencies manually, since mk-build-deps doesn't works for gcc package
    sudo apt-get install -y g++-multilib libc6-dev-i386 lib32gcc1 libc6-dev-x32 libx32gcc1 libc6-dbg m4 libtool autoconf2.64 autogen gawk zlib1g-dev systemtap-sdt-dev gperf bison flex gdb texinfo locales sharutils libantlr-java libffi-dev gnat-4.9 libisl-dev libmpc-dev libmpfr-dev libgmp-dev dejagnu realpath chrpath quilt doxygen graphviz ghostscript texlive-latex-base xsltproc libxml2-utils docbook-xsl-ns
    ./debian/rules control
    debuild -r fakeroot --no-tgz-check -S -sa
    cd -
fi
