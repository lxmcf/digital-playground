#!/bin/bash

clang -Wall -Wextra -Werror -std=c99 -pedantic -g main.c -lm -lraylib -o a.out
./a.out
