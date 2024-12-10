#! /usr/bin/bash

./configure --prefix=$PREFIX --with-zlib=$PREFIX

make -j$(nproc)
make install
