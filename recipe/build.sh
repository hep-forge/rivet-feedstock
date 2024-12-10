#! /usr/bin/bash

./configure --prefix=$PREFIX --without-zlib

make -j$(nproc)
make install
