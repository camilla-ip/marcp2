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
bwa_prog=`cat ${marcoporoconfigfile} | grep "^bwa=" | cut -f2 -d'='`
samtools_prog=`cat ${marcoporoconfigfile} | grep "^samtools=" | cut -f2 -d'='`
reffasta=`cat ${marcoporoconfigfile} | grep "^refpath=" | cut -f2 -d'='`
THREADS=1
OVERWRITE=False

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
      -overwrite ${OVERWRITE}"
    cmd=`echo ${cmd} | sed 's/  */ /g'`
    #PrintMsg "Info : ExtractExptConstants : $cmd"
    $cmd
    retval=`echo $?`
    if [[ ${retval} -ne 0 ]]; then exit ${retval} ; fi
    PrintMsg "Info : ExtractExptConstants : Finished"
}

function ExtractBasecalls {
  # Need to implement overwrite feature
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
        $cmd
        retval=`echo $?`
        if [[ ${retval} -ne 0 ]]; then exit ${retval} ; fi
    done
    PrintMsg "Info : ExtractBasecalls : Finished"
}

 # /well/bsg/microbial/soft/rescomp/src/bwa/v0.7.5a-r405/bwa mem -x ont2d -M -t 1 /well/bsg/microbial/marc/phase2/Revision1/testing/01-config/references.fasta ./03-extract/TP2-Lab7-R1-2D_2D_pass.fastq | samtools view -b -S - | samtools sort > 04-bwamem/TP2-Lab7-R1-2D_2D_pass.bam

function MapReadsWithBwaMem {
  # Map reads from each non-empty FASTQ file in the extract dir
    PrintMsg "Info : MapReadsWithBwaMem : Started"
    if [ ! -d ${outdir}/04-bwamem ] ; then mkdir -p ${outdir}/04-bwamem ; fi
    ls ${outdir}/03-extract/*.fastq | while read fastqpath ; do
        if [ -s ${fastqpath} ] ; then
            outfilestem=`basename ${fastqpath} | sed "s,.fastq,,g"`
            outbampathstem=${outdir}/04-bwamem/${outfilestem}
            outsampath=${outdir}/04-bwamem/${outfilestem}.sam
            outbampath=${outdir}/04-bwamem/${outfilestem}.bam
            if [[ ${OVERWRITE} = "True" || ! -s ${outbampath} ]] ; then
                cmd="${bwa_prog} mem -x ont2d -M -t ${THREADS} ${reffasta} ${fastqpath} \
                  | ${samtools_prog} view -b -S - \
                  | ${samtools_prog} sort - ${outbampathstem} \
                  2> ${outbampathstem}.err"
                cmd=`echo ${cmd} | sed 's/  */ /g'`
                PrintMsg "Info : MapReadsWithBwamem : Running ${cmd}"
                (${bwa_prog} mem -x ont2d -M -t ${THREADS} ${reffasta} ${fastqpath} \
                  | ${samtools_prog} view -b -S - \
                  | ${samtools_prog} sort - ${outbampathstem}) 2> ${outbampathstem}.err
                retval=`echo $?`
                if [[ ${retval} -ne 0 ]]; then
                    PrintMsg "Warn : MapReadsWithBwamem : Cmd with return code ${retval} : ${cmd}"
                    exit ${retval}
                fi
                cmd="${samtools_prog} index ${outbampath}"
                PrintMsg "Info : MapReadsWithBwamem : Running ${cmd}"
                ${samtools_prog} index ${outbampath}
                retval=`echo $?`
                if [[ ${retval} -ne 0 ]]; then
                    PrintMsg "Warn : MapReadsWithBwamem : Cmd with return code ${retval} : ${cmd}"
                    exit ${retval}
                fi
            else
                PrintMsg "Info : MapReadsWithBwamem : Output already exists ${outbampath}"
            fi
        else
            PrintMsg "Info : MapReadsWithBwamem : Ignoring empty file ${fastqpath}"
        fi
    done
    PrintMsg "Info : MapReadsWithBwaMem : Finished"
}

function AggregateStats {
    PrintMsg "Info : AggregateStats : Started"
    tail -n +2 ${exptfile} | while read exptid phase lab replicate libtype dirpath instanceN ; do
        PrintMsg "Info : AggregateStats : Processing ${exptid}"
        cmd="${marcoporo_prog} aggregateone \
          -bin ${bindir} \
          -profile None \
          -config ${marcoporoconfigfile} \
          -exptid ${exptid} \
          -extractdir ${outdir}/data/03-extract \
          -bwamemdir ${outdir}/04-bwamem \
          -maxrunlen 48 \
          -timebucket 0.25 \
          -outdir ${outdir}/05-aggregate"
        cmd=`echo ${cmd} | sed 's/  */ /g'`
        $cmd
        retval=`echo $?`
        if [[ ${retval} -ne 0 ]]; then exit ${retval} ; fi
    done
    PrintMsg "Info : AggregateStats : Finished"
}

# ===== MAIN =====

PrintMsg "Info : run_marcp2_analysis.sh"
PrintMsg "Info : Started"

#CheckRawDirStructure ${exptfile}
#ExtractExptConstants
#ExtractBasecalls

MapReadsWithBwaMem

#AggregateStats

PrintMsg "Info : Finished"

