#! /usr/bin/env bash
set -e
set -x
brew update # Needed to sidestep bintray brownout
brew install opam pkg-config coreutils
opam init --no-setup --bare;
#coupling: this should be the same version than in our Dockerfile
opam switch create 4.14.0 --debug
opam switch 4.14.0;
eval "$(opam env)"
which ocamlc
file "$(which ocamlc)"
git submodule update --init --recursive --depth 1


# Remove pcre dynamically linked to force MacOS to use static
# This needs to be done before make setup since it is used there
rm /usr/local/opt/pcre/lib/libpcre.1.dylib

make setup

# Remove dynamically linked libraries to force MacOS to use static ones
# This needs to be done after make setup but before make build-*
TREESITTER_LIBDIR=semgrep-core/src/ocaml-tree-sitter-core/tree-sitter/lib
echo "TREESITTER_LIBDIR is $TREESITTER_LIBDIR and contains:"
ls -l "$TREESITTER_LIBDIR"

echo "Deleting all the tree-sitter dynamic libraries to force static linking."
rm -f "$TREESITTER_LIBDIR"/libtree-sitter.0.0.dylib
rm -f "$TREESITTER_LIBDIR"/libtree-sitter.0.dylib
rm -f "$TREESITTER_LIBDIR"/libtree-sitter.dylib

make build-core

mkdir -p artifacts
cp ./semgrep-core/_build/install/default/bin/semgrep-core artifacts
zip -r artifacts.zip artifacts
