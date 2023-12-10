./MinUI/makefile:
    1. clones toolchains into ./MinUI/toolchains
    2. builds toolchains via toolchain/PLATFORM/makefile(.build)

./MinUI/makefile.toolchain:
    1. build PLATFORM via makefile.toolchain(build)
    2. which invokes workspace/PLATFORM/makefile(all)
    3. which invokes workspace/PLATFORM/show/makefile(all)