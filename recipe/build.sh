#! /usr/bin/bash

./configure --prefix=$PREFIX --with-zlib=$PREFIX --with-hepmc3=$PREFIX

make -j$(nproc)
make install
