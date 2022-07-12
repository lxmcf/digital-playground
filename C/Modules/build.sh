#!/bin/bash

# Cleanup
rm -r build
mkdir build

# Build module executable
echo -n 'Building Executable: '

gcc -ldl main.c -Wl,-rpath,./ -o build/modules

echo 'DONE!'

# Build modules
echo -n 'Building Modules: '

gcc -shared -fPIC module.c -o build/test.so

echo 'DONE!'