#!/usr/bin/env bash

# ===== ARGUMENTS =====

if [ $# -lt 2 ] ; then
    printf "Usage: run_marcp2_analysis.sh exptfile outdir\n"
    printf "       Given an exptfile containing experiment identifiers and raw sequence data paths,\n"
    printf "       perform data pre-processing and output the tables and figures of experimental\n"
    printf "       statistics as seen in the MARC Phase 2 Revision 1 paper.\n"
    exit 1
fi
exptfile=${1}
outdir=${2}

# ===== FUNCTIONS =====



# ===== MAIN =====

printf "`date +\"%Y-%m-%d %H:%M:%S\"` : run_marcp2_analysis.sh\n"
printf "`date +\"%Y-%m-%d %H:%M:%S\"` : Started\n"



printf "`date +\"%Y-%m-%d %H:%M:%S\"` : Finished\n"
