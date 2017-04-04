#!/bin/bash

git clone -b 2.1 --depth=1 https://github.com/Jebbs/DSFMLC.git
git clone --depth=1 https://github.com/EsotericSoftware/spine-runtimes

Xvfb -shmem -screen 0 1280x1024x24

cd DSFMLC
cmake .
make
sudo make install
cd -

sudo ldconfig

cd spine-runtimes/spine-c
cmake .
make
cd -
dub test
