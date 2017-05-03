#!/usr/bin/env bash

# ===== ARGUMENTS =====

if [ $# -lt 4 ] ; then
    printf "Usage: run_marcp2_analysis.sh exptfile marcoporoconfigfile bindir outdir\n"
    printf "\n"
    printf "       Given an exptfile containing experiment identifiers and raw sequence data paths,\n"
    printf "       perform data pre-processing and output the tables and figures of experimental\n"
    printf "       statistics as seen in the MARC Phase 2 Revision 1 paper.\n"
    printf "\n"
    exit 1
fi
exptfile=${1}
marcoporoconfigfile=${2}
bindir=${3}
outdir=${4}

# ===== CONSTANTS =====

SAMPLESIZE=250
marcoporo_prog=`cat ${marcoporoconfigfile} | grep "^marcoporo=" | cut -f2 -d'='`

# ===== FUNCTIONS =====

function PrintMsg {
    printf "run_marcp2_analysis.sh `date +\"%Y-%m-%d %H:%M:%S\"` : ${*}\n"
}

function CheckRawDirStructure {
  # Check that each of the experimental raw data directories has the correct
  # sub-dir structure. Exit on error.
    PrintMsg "Info : CheckRawDirStructure : Started"
    exptfile=${1}
    founderror=0
    tail -n +2 ${exptfile} | while read exptid phase lab replicate libtype dirpath instanceN ; do
        if [ ! -d ${dirpath} ] ; then PrintMsg "Erro : Missing dir ${dirpath}" ; founderor=1 ; fi
        if [ ! -d ${dirpath}/reads ] ; then PrintMsg "Erro : Missing dir ${dirpath}/reads" ; founderor=1 ; fi
        if [ ! -d ${dirpath}/reads/downloads ] ; then PrintMsg "Erro : Missing dir ${dirpath}/reads/downloads" ; founderor=1 ; fi
        if [ ! -d ${dirpath}/reads/downloads/fail ] ; then PrintMsg "Erro : Missing dir ${dirpath}/reads/downloads/fail" ; founderor=1 ; fi
        if [ ! -d ${dirpath}/reads/downloads/pass ] ; then PrintMsg "Erro : Missing dir ${dirpath}/reads/downloads/pass" ; founderor=1 ; fi
    done
    if [[ ${founderror} -eq 1 ]] ; then exit 1 ; fi
    PrintMsg "Info : CheckRawDirStructure : Finished"
}

function ExtractExptConstants {
    PrintMsg "Info : ExtractExptConstants : Started"
    outpath1=${odir}/exptconstants.txt
    outpath2=${odir}/exptconstantfields.txt
    if [ -s "$outpath1"  -a  -s "$outpath2" ]; then return ; fi
    cmd="${marcoporo_prog} exptconstants \
      -config ${marcoporoconfigfile} \
      -experiments ${exptfile} \
      -samplesize ${SAMPLESIZE} \
      -outdir ${outdir}/02-exptconstants \
      -overwrite False"
    cmd=`echo ${cmd} | sed 's/  */ /g'`
    #PrintMsg "Info : ExtractExptConstants : $cmd"
    $cmd
    retval=`echo $?`
    if [[ ${retval} -ne 0 ]]; then exit ${retval} ; fi
    PrintMsg "Info : ExtractExptConstants : Finished"
}

function ExtractBasecalls {
    PrintMsg "Info : ExtractBasecalls : Started"
    tail -n +2 ${exptfile} | while read exptid phase lab replicate libtype dirpath instanceN ; do
        PrintMsg "Info : ExtractBasecalls : Processing ${exptid}"
        cmd="${marcoporo_prog} extractone
          -exptid ${exptid} \
          -bin ${bindir} \
          -profile None \
          -config ${marcoporoconfigfile} \
          -exptconstants ${outdir}/02-exptconstants/exptconstants.txt \
          -exptconstantfields ${outdir}/02-exptconstants/exptconstantfields.txt \
          -indir ${dirpath} \
          -instanceN ${instanceN} \
          -outdir ${outdir}/03-extract \
          -fastq True \
          -pairs False \
          -stats True"
        cmd=`echo ${cmd} | sed 's/  */ /g'`
        #PrintMsg "Info : ExtractBasecalls : $cmd"
        $cmd
        retval=`echo $?`
        if [[ ${retval} -ne 0 ]]; then exit ${retval} ; fi
    done
    PrintMsg "Info : ExtractBasecalls : Finished"
}

# ===== MAIN =====

PrintMsg "Info : run_marcp2_analysis.sh"
PrintMsg "Info : Started"

CheckRawDirStructure ${exptfile}
ExtractExptConstants
ExtractBasecalls

PrintMsg "Info : Finished"

