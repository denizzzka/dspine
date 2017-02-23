#!/bin/bash

git clone --depth=1 https://github.com/EsotericSoftware/spine-runtimes
cd spine-runtimes/spine-c
cmake .
make
dub test --config=unit_test
