#!/usr/bin/env bash

if [ $# -lt 2 ] ; then
    echo "Usage: Figure_readlengths_getdata.sh exptfile extractdir"
    exit 1
fi
exptfile=${1}
extractdir=${2}

# FUNCTIONS

function extract_1T_values
{
    indir=${extractdir}
    readtypearg=1T
    readclass=pass
    exptid=${1}
    metricname=${2}
    cat ${indir}/${exptid}_read1dstats.txt | cut -f1,6,7,20 | grep ${readclass} | grep ${readtypearg} | while read exptid readtype readclass value ; do
        phase=`echo ${exptid} | cut -f1 -d'-'` ; lab=`echo ${exptid} | cut -f2 -d'-'`
        replicate=`echo ${exptid} | cut -f3 -d'-'` ; libtype=`echo ${exptid} | cut -f4 -d'-'`
        printf "${exptid}\t${phase}\t${lab}\t${replicate}\t${libtype}\t${metricname}\tTemplate\t${readclass}\t${value}\n"
    done
}

function extract_2D_values
{
    indir=${extractdir}
    readtypearg=2D
    readclass=pass
    exptid=${1}
    metricname=${2}
    cat ${indir}/${exptid}_read2dstats.txt | cut -f1,7,14 | grep ${readclass} | while read exptid readclass value ; do
        phase=`echo ${exptid} | cut -f1 -d'-'` ; lab=`echo ${exptid} | cut -f2 -d'-'`
        replicate=`echo ${exptid} | cut -f3 -d'-'` ; libtype=`echo ${exptid} | cut -f4 -d'-'`
        printf "${exptid}\t${phase}\t${lab}\t${replicate}\t${libtype}\t${metricname}\t${readtypearg}\t${readclass}\t${value}\n"
    done
}

function create_input_data_table
{
  # Header
    printf "Experiment\tphase\tlab\treplicate\tlibtype\tmetric\treadtype\treadclass\tvalue\n"
  # Constants

  # Each metric, then each expt
    #extract_1T_values TP1b-Lab2-R2-2D "Length"
    #extract_1T_values TP2-Lab6-R1-1D "Length"
    #extract_1T_values TP2-Lab7-R1-1D "Length"
    #extract_1T_values TP2-Lab6-R1-2D "Length"
    #extract_1T_values TP2-Lab7-R1-2D "Length"
    #extract_2D_values TP1b-Lab2-R2-2D "Length"
    #extract_2D_values TP2-Lab6-R1-2D "Length"
    #extract_2D_values TP2-Lab7-R1-2D "Length"

    tail -n +2 experiments.txt | while read exptid phase lab replicate libtype dirpath instanceN ; do
        extract_1T_values ${exptid} "Length"
    done
    tail -n +2 experiments.txt | while read exptid phase lab replicate libtype dirpath instanceN ; do
        if [ $libtype = "2D" ] ; then
            extract_2D_values ${exptid} "Length"
        fi
    done
}

function make_plot
{
    Rscript Figure1_readlengths.R
}

# MAIN

create_input_data_table
#make_plot

