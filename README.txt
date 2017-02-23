Esoteric Software Spine runtime binding for D

USAGE:

Clone into your project directory Spine runtimes:

$ git clone https://github.com/EsotericSoftware/spine-runtimes

Compile it:

$ cd spine-runtimes/
$ cmake .
$ cd spine-c
$ make
...
[100%] Linking C static library libspine-c.a
[100%] Built target spine-c
...

Then add path to Spine runtime into your DUB package file.
For linux and DUB SDL package file format path string will be:

sourceFiles "spine-runtimes/spine-c/libspine-c.a" platform="posix"

Then use "dub build" as usual.
