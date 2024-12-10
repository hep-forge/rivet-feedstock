#! /usr/bin/bash

./configure --prefix=$PREFIX --with-zlib=$CONDA_PREFIX

make -j$(nproc)
make install
