#! /usr/bin/bash

mkdir build-scripts
cd build-scripts

cmake $RECIPE_DIR/scripts
cd ..

./configure --prefix=$PREFIX --with-zlib=$PREFIX --with-hepmc3=$PREFIX

make -j$(nproc)
make install
