#!/bin/sh
cat << 'SHAR_EOF' > Makefile
all: 
		cc -O asc2bin.c -o asc2bin 
				cc -O bin2asc.c -o bin2asc
						cc -O showpreamble.c -o showpreamble

						SHAR_EOF
						cat << 'SHAR_EOF' > README.binformat

