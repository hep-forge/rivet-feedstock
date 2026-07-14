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

# CXX/CC/CXXFLAGS/CFLAGS explicitly, not relying on autoconf's PATH
# search: rivet's meta.yaml previously declared no compiler()/stdlib('c')
# requirements at all, so nothing exported these in the build environment
# and a plain `./configure` would fall back to whatever g++/cc resolves
# to on the runner -- same GLIBC-symbol-leak failure mode documented for
# fastjet-contrib's own custom configure script.
./configure --prefix=$PREFIX --with-zlib=$PREFIX --with-hepmc3=$PREFIX \
  CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" CC="${CC}" CFLAGS="${CFLAGS}"

NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu)
make -j$NPROC
make install
