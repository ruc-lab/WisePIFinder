#!/bin/bash
# usage: ./p4_build.sh /absolute/path/to/your_program.p4

if [ $# -ne 1 ]; then
    echo "Usage: $0 /absolute/path/to/your_program.p4"
    exit 1
fi

P4_PATH=$1

if [ ! -f "$P4_PATH" ]; then
    echo "ERROR: File is not exist!!!! -> $P4_PATH"
    exit 1
fi

P4_NAME=$(basename "$P4_PATH" .p4)

cd $SDE/pkgsrc/p4-build || { echo "ERROR: Cannot access $SDE/pkgsrc/p4-build"; exit 1; }

sh ./autogen.sh

./configure \
    --prefix=$SDE_INSTALL \
    --with-tofino \
    P4_NAME=$P4_NAME \
    P4_PATH=$P4_PATH \
    P4_VERSION=p4-16 \
    P4C=p4c \
    --enable-thrift

make clean 

make

make install

