#!/usr/bin/env bash

# VARIABLES
MP2_DIR=`cat config.txt | grep MP2_DIR | cut -f2 -d'='`
MP2_BIN=`cat config.txt | grep MP2_BIN | cut -f2 -d'='`
MP2_DAT=`cat config.txt | grep MP2_DAT | cut -f2 -d'='`
subdirs="01-fast5 02-fastq 03-bwamem 04-marginalign 05-nanook 06-readstats 07-analysis 08-manuscript"

# FUNCTIONS
function makedir()
{
    dir=${1}
    if [ ! -d ${dir} ] ; then
        mkdir -p ${dir}
        if [ -d ${dir} ] ; then
            echo "mkdir ok : ${dir}"
        else
            echo "mkdir failed : ${dir}"
            exit 1
        fi
    else
        echo "mkdir notneeded : ${dir}"
    fi
}

# MAIN
echo "Started `date`"
makedir ${MP2_DAT}
for subdir in `echo $subdirs` ; do
    path=${MP2_DAT}/${subdir}
    makedir ${path}
done
echo "Finished `date`"
exit 0
