Esoteric Software Spine runtime binding for D

USAGE:

Clone into your project directory source of Spine runtimes:

$ git clone --depth=1 https://github.com/EsotericSoftware/spine-runtimes

Compile spine-c library:

$ cd spine-runtimes/spine-c
$ cmake .
$ make
...
[100%] Linking C static library libspine-c.a
[100%] Built target spine-c
...

Then add path to Spine runtime C library into your DUB package file.
For linux and DUB SDL package file format path string will be:

sourceFiles "spine-runtimes/spine-c/libspine-c.a" platform="posix"

Then use "dub build" as usual.
