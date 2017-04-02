#!/bin/bash

echo $((`cat ../buildnum.txt` + 1)) > ../buildnum.txt
NUM=`cat ../buildnum.txt`
echo "#define __VERSION__ \"#$NUM\"" > ../include/version.h
