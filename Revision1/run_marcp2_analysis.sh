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

marcoporo_prog=`cat ${marcoporoconfigfile} | grep "^marcoporo=" | cut -f2 -d'='`
bwa_prog=`cat ${marcoporoconfigfile} | grep "^bwa=" | cut -f2 -d'='`
poremapstats_prog=`cat ${marcoporoconfigfile} | grep "^poremapstats=" | cut -f2 -d'='`
samtools_prog=`cat ${marcoporoconfigfile} | grep "^samtools=" | cut -f2 -d'='`
reffasta=`cat ${marcoporoconfigfile} | grep "^refpath=" | cut -f2 -d'='`
targetfasta=`cat ${marcoporoconfigfile} | grep "^targetpath=" | cut -f2 -d'='`
controlfasta=`cat ${marcoporoconfigfile} | grep "^controlpath=" | cut -f2 -d'='`

SAMPLESIZE=250
THREADS=1
OVERWRITE=False
MAXRUNLEN=48
TIMEBUCKET=0.25
FASTALINEWIDTH=100
READLENMAX=40000

readtypeL=(1T 1C 2D)
readclassL=(pass fail)

# ===== FUNCTIONS =====

function PrintMsg
{
    printf "run_marcp2_analysis.sh `date +\"%Y-%m-%d %H:%M:%S\"` : ${*}\n"
}

function CheckRawDirStructure
{
  # Check that each of the experimental raw data directories has the correct
  # sub-dir structure. Exit on error.
    PrintMsg "Info : CheckRawDirStructure : Started"
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

function ExtractExptConstants
{
    PrintMsg "Info : ExtractExptConstants : Started"
    outpath1=${odir}/exptconstants.txt
    outpath2=${odir}/exptconstantfields.txt
    if [ -s "$outpath1"  -a  -s "$outpath2" ]; then return ; fi
    cmd="${marcoporo_prog} exptconstants \
      -config ${marcoporoconfigfile} \
      -experiments ${exptfile} \
      -samplesize ${SAMPLESIZE} \
      -outdir ${outdir}/02-exptconstants \
      -overwrite ${OVERWRITE}"
    cmd=`echo ${cmd} | sed 's/  */ /g'`
    $cmd
    retval=`echo $?`
    if [[ ${retval} -ne 0 ]]; then exit ${retval} ; fi
    PrintMsg "Info : ExtractExptConstants : Finished"
}

function ExtractBasecalls
{
    PrintMsg "Info : ExtractBasecalls : Started"
    cmd="${marcoporo_prog} extract \
      -bin ${bindir} \
      -profile None \
      -config ${marcoporoconfigfile} \
      -exptconstants ${outdir}/02-exptconstants/exptconstants.txt \
      -exptconstantfields ${outdir}/02-exptconstants/exptconstantfields.txt \
      -experiments ${exptfile} \
      -extractdir ${outdir}/03-extract \
      -fastq True \
      -pairs False \
      -stats True \
      -overwrite ${OVERWRITE}"
    cmd=`echo ${cmd} | sed 's/  */ /g'`
    echo "Running ${cmd}"
    $cmd
    retval=`echo $?`
    if [[ ${retval} -ne 0 ]]; then exit ${retval} ; fi

    PrintMsg "Info : ExtractBasecalls : Finished"
}

function MapWithBwa
{
    PrintMsg "Info : MapWithBwa : Started"
    cmd="${marcoporo_prog} mapwithbwa \
      -bin ${bindir} \
      -profile None \
      -config ${marcoporoconfigfile} \
      -experiments ${exptfile} \
      -extractdir ${outdir}/03-extract \
      -bwamemdir ${outdir}/04-bwamem \
      -overwrite ${OVERWRITE}"
    cmd=`echo ${cmd} | sed 's/  */ /g'`
    echo "Running $cmd"
    $cmd
    retval=`echo $?`
    if [[ ${retval} -ne 0 ]]; then exit ${retval} ; fi
    PrintMsg "Info : MapWithBwa : Finished"
}

function AggregateStats
{
    PrintMsg "Info : AggregateStats : Started"
    cmd="${marcoporo_prog} aggregate \
      -bin ${bindir} \
      -profile None \
      -config ${marcoporoconfigfile} \
      -experiments ${exptfile} \
      -extractdir ${outdir}/03-extract \
      -bwamemdir ${outdir}/04-bwamem \
      -aggregatedir ${outdir}/05-aggregate \
      -maxrunlen ${MAXRUNLEN} \
      -timebucket ${TIMEBUCKET} \
      -outdir ${outdir}/05-aggregate \
      -overwrite ${OVERWRITE}"
    cmd=`echo ${cmd} | sed 's/  */ /g'`
    echo "Running ${cmd}"
    $cmd
    retval=`echo $?`
    if [[ ${retval} -ne 0 ]]; then exit ${retval} ; fi
    PrintMsg "Info : AggregateStats : Finished"
}

function AggregateStats-Old
{
    PrintMsg "Info : AggregateStats : Started"
    tail -n +2 ${exptfile} | while read exptid phase lab replicate libtype dirpath instanceN ; do
        PrintMsg "Info : AggregateStats : Processing ${exptid}"
        cmd="${marcoporo_prog} aggregateone \
          -bin ${bindir} \
          -profile None \
          -config ${marcoporoconfigfile} \
          -exptid ${exptid} \
          -extractdir ${outdir}/03-extract \
          -bwamemdir ${outdir}/04-bwamem \
          -maxrunlen ${MAXRUNLEN} \
          -timebucket ${TIMEBUCKET} \
          -outdir ${outdir}/05-aggregate"
        cmd=`echo ${cmd} | sed 's/  */ /g'`
        $cmd
        retval=`echo $?`
        if [[ ${retval} -ne 0 ]]; then exit ${retval} ; fi
    done
    PrintMsg "Info : AggregateStats : Finished"
}

function MarginAlign
{
    # Run marginAlign 
    PrintMsg "Info : marginalign : Started"
    if [ ! -d ${outdir}/06-marginalign ] ; then mkdir -p ${outdir}/06-marginalign ; fi
    cmd="${marcoporo_prog} marginalign \
        -bin ${bindir} \
        -profile None \
        -config ${marcoporoconfigfile} \
        -experiments ${exptfile} \
        -threads ${THREADS} \
        -extractdir ${outdir}/03-extract \
        -outdir ${outdir}/06-marginalign \
        -overwrite ${OVERWRITE}"
    cmd=`echo ${cmd} | sed 's/  */ /g'`
    echo ${cmd}
    $cmd
    retval=`echo $?`
    if [[ ${retval} -ne 0 ]]; then exit ${retval} ; fi
    PrintMsg "Info : marginalign : Finished"
}

function NanookReports
{
    PrintMsg "Info : NanookReports : Started"
    if [ ! -d ${outdir}/07-nanookreports ] ; then mkdir -p ${outdir}/07-nanookreports ; fi
    cmd="${marcoporo_prog} nanookreports \
        -bin ${bindir} \
        -profile None \
        -config ${marcoporoconfigfile} \
        -experiments ${exptfile} \
        -threads ${THREADS} \
        -extractdir ${outdir}/03-extract \
        -outdir ${outdir}/07-nanookreports \
        -overwrite ${OVERWRITE}"
    cmd=`echo ${cmd} | sed 's/  */ /g'`
    echo ${cmd}
    $cmd
    retval=`echo $?`
    if [[ ${retval} -ne 0 ]]; then exit ${retval} ; fi
    PrintMsg "Info : NanookReports : Finished"
}

function GenerateFigure1
{
    PrintMsg "Info : GenerateFigure1 : Started"
    # Create output dir
    if [ ! -d ${outdir}/08-analysis ] ; then mkdir -p ${outdir}/08-analysis ; fi
    # Generate data file plot
    datafile=${outdir}/08-analysis/Figure_readlengths.txt
    pngfile=${outdir}/08-analysis/Figure_readlengths.png
    if [[ ${OVERWRITE} == "True" ]] || [[ ! -s ${pngfile} ]] ; then
        cmd="${bindir}/Figure_readlengths.sh \
            ${exptfile} \
            ${outdir}/03-extract \
            > ${datafile}"
        cmd=`echo ${cmd} | sed 's/  */ /g'`
        echo ${cmd}
        ${bindir}/Figure_readlengths.sh \
            ${exptfile} \
            ${outdir}/03-extract \
            > ${datafile}
        retval=`echo $?`
        if [[ ${retval} -ne 0 ]]; then exit ${retval} ; fi
        # Generate plot
        cmd="Rscript ${bindir}/Figure_readlengths.R \
            ${datafile} \
            ${bindir}/Figure_style.R \
            ${READLENMAX} \
            ${outdir}/08-analysis \
            Figure_readlengths"
        cmd=`echo ${cmd} | sed 's/  */ /g'`
        echo ${cmd}
        Rscript ${bindir}/Figure_readlengths.R \
            ${datafile} \
            ${bindir}/Figure_style.R \
            ${READLENMAX} \
            ${outdir}/08-analysis \
            Figure_readlengths
        retval=`echo $?`
        if [[ ${retval} -ne 0 ]]; then exit ${retval} ; fi
    else
        PrintMsg "Info : GenerateFigure1 : Skipping as outfiles already exists ${pngfile}"
    fi
    PrintMsg "Info : GenerateFigure1 : Finished"
}

function GenerateFigure2
{
    PrintMsg "Info : GenerateFigure2 : Started"
    # Create output dir
    if [ ! -d ${outdir}/08-analysis ] ; then mkdir -p ${outdir}/08-analysis ; fi
    # Generate data file plot
    datafile=${outdir}/08-analysis/Figure_performancemetrics.txt
    pngfile=${outdir}/08-analysis/Figure_performancemetrics.png
    if [[ ${OVERWRITE} == "True" ]] || [[ ! -s ${pngfile} ]] ; then
        cmd="${bindir}/Figure_performancemetrics.sh \
            ${exptfile} \
            ${outdir}/05-extract \
            > ${datafile}"
        cmd=`echo ${cmd} | sed 's/  */ /g'`
        echo ${cmd}
        ${bindir}/Figure_performancemetrics.sh \
            ${exptfile} \
            ${outdir}/05-aggregate \
            > ${datafile}
        retval=`echo $?`
        if [[ ${retval} -ne 0 ]]; then exit ${retval} ; fi
        # Generate plot
        cmd="Rscript ${bindir}/Figure_performancemetrics.R \
            ${datafile} \
            ${bindir}/Figure_style.R \
            ${outdir}/08-analysis \
            Figure_performancemetrics"
        cmd=`echo ${cmd} | sed 's/  */ /g'`
        echo ${cmd}
        Rscript ${bindir}/Figure_performancemetrics.R \
            ${datafile} \
            ${bindir}/Figure_style.R \
            ${outdir}/08-analysis \
            Figure_performancemetrics
        retval=`echo $?`
        if [[ ${retval} -ne 0 ]]; then exit ${retval} ; fi
    else
        PrintMsg "Info : GenerateFigure2 : Skipping as outfiles already exists ${pngfile}"
    fi
    PrintMsg "Info : GenerateFigure2 : Finished"
}

# ===== MAIN =====

PrintMsg "Info : run_marcp2_analysis.sh"
PrintMsg "Info : Started"

CheckRawDirStructure
ExtractExptConstants
ExtractBasecalls
MapWithBwa
AggregateStats
MarginAlign
NanookReports
GenerateFigure1
GenerateFigure2

PrintMsg "Info : Finished"
