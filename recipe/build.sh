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
# macOS: newer clang makes "template" without an argument list after it an
# error by default (-Wmissing-template-arg-list-after-template-kw); Rivet's
# Analysis.cc has one. Keep it a warning.
if [[ "$(uname)" == "Darwin" ]]; then
  CXXFLAGS="${CXXFLAGS} -Wno-error=missing-template-arg-list-after-template-kw"
fi
# Linux: configure adds -Werror=uninitialized, and GCC 16 (conda-forge's
# root_base needs it) raises a false -Wmaybe-uninitialized inside
# std::vector's copy constructor in AnalysisHandler.cc on aarch64. Keep that
# one a warning; CXXFLAGS come after configure's own flags on each compile.
if [[ "$(uname)" == "Linux" ]]; then
  CXXFLAGS="${CXXFLAGS} -Wno-error=maybe-uninitialized"
fi

./configure --prefix=$PREFIX --with-zlib=$PREFIX --with-hepmc3=$PREFIX \
  CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" CC="${CC}" CFLAGS="${CFLAGS}"

NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu)
make -j$NPROC
make install
