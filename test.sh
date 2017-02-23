#!/bin/bash

git clone -b 2.1 --depth=1 https://github.com/Jebbs/DSFMLC.git
git clone --depth=1 https://github.com/EsotericSoftware/spine-runtimes

cd DSFMLC
cmake .
make
sudo make install
cd -

cd spine-runtimes/spine-c
cmake .
make
cd -
dub test
