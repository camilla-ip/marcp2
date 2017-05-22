#!/usr/bin/env bash

if [ $# -lt 2 ] ; then
    echo "Usage: Figure_readlengths_getdata.sh exptfile aggregatedir"
    exit 1
fi
exptfile=${1}
aggregatedir=${2}

function extract_1T_values
{
    indir=${aggregatedir}
    valuetype_mean=Mean
    valuetype_count=Count
    readtype=1T
    readclass=pass
    exptid=${1}
    metricsuffix=${2}
    metricname=${3}
    cut -f1-2,11,14 ${indir}/${exptid}_aggregate_read1d_${metricsuffix}.txt | tail -n +2 | while read exptid timepoint meanval countval ; do
        phase=`echo ${exptid} | cut -f1 -d'-'` ; lab=`echo ${exptid} | cut -f2 -d'-'`
        replicate=`echo ${exptid} | cut -f3 -d'-'` ; libtype=`echo ${exptid} | cut -f4 -d'-'`
        printf "${exptid}\t${phase}\t${lab}\t${replicate}\t${libtype}\t${metricname}\t${valuetype_mean}\t${readtype}\t${readclass}\t${timepoint}\t${meanval}\n"
        printf "${exptid}\t${phase}\t${lab}\t${replicate}\t${libtype}\t${metricname}\t${valuetype_count}\t${readtype}\t${readclass}\t${timepoint}\t${countval}\n"
    done
}

function extract_ReadCount_values
{
    indir=${aggregatedir}
    valuetype_mean=Mean
    valuetype_count=Count
    readtype=1T
    readclass=pass
    exptid=${1}
    metricsuffix=${2}
    metricname=${3}
    cut -f1-2,11,14 ${indir}/${exptid}_aggregate_read1d_${metricsuffix}.txt | tail -n +2 | while read exptid timepoint meanval countval ; do
        phase=`echo ${exptid} | cut -f1 -d'-'` ; lab=`echo ${exptid} | cut -f2 -d'-'`
        replicate=`echo ${exptid} | cut -f3 -d'-'` ; libtype=`echo ${exptid} | cut -f4 -d'-'`
      # This is the row that enables you to have a row at the bottom for "read count over time"
        printf "${exptid}\t${phase}\t${lab}\t${replicate}\t${libtype}\tCount\t${valuetype_mean}\t${readtype}\t${readclass}\t${timepoint}\t${countval}\n"
    done
}

function extract_2D_values
{
    indir=${aggregatedir}
    valuetype_mean=Mean
    valuetype_count=Count
    readtype=2D
    readclass=pass
    exptid=${1}
    metricsuffix=${2}
    metricname=${3}
    cut -f1-2,11,14 ${indir}/${exptid}_aggregate_read2d_${metricsuffix}.txt | tail -n +2 | while read exptid timepoint meanval countval ; do
        phase=`echo ${exptid} | cut -f1 -d'-'` ; lab=`echo ${exptid} | cut -f2 -d'-'`
        replicate=`echo ${exptid} | cut -f3 -d'-'` ; libtype=`echo ${exptid} | cut -f4 -d'-'`
        printf "${exptid}\t${phase}\t${lab}\t${replicate}\t${libtype}\t${metricname}\t${valuetype_mean}\t${readtype}\t${readclass}\t${timepoint}\t${meanval}\n"
        printf "${exptid}\t${phase}\t${lab}\t${replicate}\t${libtype}\t${metricname}\t${valuetype_count}\t${readtype}\t${readclass}\t${timepoint}\t${countval}\n"
    done
}

function create_input_data_table
{
  # Header
    printf "Experiment\tphase\tlab\treplicate\tlibtype\tmetric\tvaluetype\treadtype\treadclass\ttime\tvalue\n"
  # Each metric, then each expt
    tail -n +2 ${exptfile} | while read exptid phase lab replicate libtype dirpath instanceN ; do
        if [ $libtype = "2D" ] ; then
            extract_2D_values ${exptid} seqlen "Length"
        else
            extract_1T_values ${exptid} seqlen "Length"
        fi
    done
    tail -n +2 ${exptfile} | while read exptid phase lab replicate libtype dirpath instanceN ; do
        if [ $libtype = "2D" ] ; then
            extract_2D_values ${exptid} meanqscore "Q-score"
        else
            extract_1T_values ${exptid} meanqscore "Q-score"
        fi
    done
    tail -n +2 ${exptfile} | while read exptid phase lab replicate libtype dirpath instanceN ; do
        if [ $libtype = "2D" ] ; then
            extract_2D_values ${exptid} bqmean "BQ"
        else
            extract_1T_values ${exptid} bqmean "BQ"
        fi
    done
    tail -n +2 ${exptfile} | while read exptid phase lab replicate libtype dirpath instanceN ; do
        if [ $libtype = "2D" ] ; then
            extract_2D_values ${exptid} gcpct "GC"
        else
            extract_1T_values ${exptid} gcpct "GC"
        fi
    done
    tail -n +2 ${exptfile} | while read exptid phase lab replicate libtype dirpath instanceN ; do
        if [ $libtype = "2D" ] ; then
            extract_2D_values ${exptid} gcpct "GC (1T)"
        else
            extract_1T_values ${exptid} gcpct "GC (1T)"
        fi
    done
    tail -n +2 ${exptfile} | while read exptid phase lab replicate libtype dirpath instanceN ; do
        if [ $libtype = "2D" ] ; then
            extract_2D_values ${exptid} basespersecond "Speed (1T)"
        else
            extract_1T_values ${exptid} basespersecond "Speed (1T)"
        fi
    done
    tail -n +2 ${exptfile} | while read exptid phase lab replicate libtype dirpath instanceN ; do
        if [ $libtype = "2D" ] ; then
            extract_ReadCount_values ${exptid} gcpct "GC"
        else
            extract_ReadCount_values ${exptid} gcpct "GC"
        fi
    done
}

create_input_data_table
