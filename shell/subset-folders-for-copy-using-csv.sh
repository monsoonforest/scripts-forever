#!/bin/bash

a=(`jnk.csv`);
b=("${a[@]:$1:$2}");

for i in "${b[@]}"
do
    cp -r /home/csheth/documents/work/arunachal_pradesh/2016/Frogs/images/xenophrys/"$i"/ /home/csheth/jnk/;
done