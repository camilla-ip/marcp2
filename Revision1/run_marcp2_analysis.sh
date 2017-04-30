#!/usr/bin/env bash

# ===== ARGUMENTS =====

if [ $# -lt 3 ] ; then
    printf "Usage: run_marcp2_analysis.sh exptfile marcoporoconfigfile outdir\n"
    printf "\n"
    printf "       Given an exptfile containing experiment identifiers and raw sequence data paths,\n"
    printf "       perform data pre-processing and output the tables and figures of experimental\n"
    printf "       statistics as seen in the MARC Phase 2 Revision 1 paper.\n"
    printf "\n"
    exit 1
fi
exptfile=${1}
marcoporoconfigfile=${2}
outdir=${3}

# ===== CONSTANTS =====

SAMPLESIZE=250
marcoporo_prog=`cat ${marcoporoconfigfile} | grep "^marcoporo=" | cut -f2 -d'='`
echo $marcoporo_prog

# ===== FUNCTIONS =====

function PrintMsg {
    printf "`date +\"%Y-%m-%d %H:%M:%S\"` : ${*}\n"
}

function CheckRawDirStructure {
  # Check that each of the experimental raw data directories has the correct
  # sub-dir structure. Exit on error.
    exptfile=${1}

    founderror=0
    tail -n +2 ${exptfile} | while read exptid phase lab replicate libtype dirpath instanceN ; do
        if [ ! -d ${dirpath} ] ; then PrintMsg "Erro : Missing dir ${dirpath}" ; founderor=1 ; fi
        if [ ! -d ${dirpath}/reads ] ; then PrintMsg "Erro : Missing dir ${dirpath}/reads" ; founderor=1 ; fi
        if [ ! -d ${dirpath}/reads/downloads ] ; then PrintMsg "Erro : Missing dir ${dirpath}/reads/downloads" ; founderor=1 ; fi
        if [ ! -d ${dirpath}/reads/downloads/fail ] ; then PrintMsg "Erro : Missing dir ${dirpath}/reads/downloads/fail" ; founderor=1 ; fi
        if [ ! -d ${dirpath}/reads/downloads/pass ] ; then PrintMsg "Erro : Missing dir ${dirpath}/reads/downloads/pass" ; founderor=1 ; fi
    done

    if [ ${founderror} -eq 1 ] ; then
       exit 1
    fi
    PrintMsg "Info : Raw experiment dir hierarchy ok"
}

# ===== MAIN =====

PrintMsg "Info : run_marcp2_analysis.sh"
PrintMsg "Info : Started"

CheckRawDirStructure ${exptfile}

${marcoporo_prog} exptconstants \
  -config ${marcoporoconfigfile} \
  -experiments ${exptfile} \
  -samplesize ${SAMPLESIZE} \
  -outdir ${outdir}/02-extract

PrintMsg "Info : Finished"

