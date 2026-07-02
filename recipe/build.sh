#! /usr/bin/bash
set -e

mkdir build-scripts
cd build-scripts

cmake $RECIPE_DIR/scripts
cd ..

# Bundled config.sub/config.guess predate aarch64 triplets -- replace with
# the current ones from the gnuconfig package before configuring.
for f in config.sub config.guess; do
  find . -name "$f" -exec cp "$BUILD_PREFIX/share/gnuconfig/$f" {} \;
done

./configure --prefix=$PREFIX --with-zlib=$PREFIX --with-hepmc3=$PREFIX

NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu)
make -j$NPROC
make install
