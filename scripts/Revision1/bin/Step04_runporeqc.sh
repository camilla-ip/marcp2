#!/usr/bin/env bash

# VARIABLES
MP2_DIR=`cat config.txt | grep MP2_DIR | cut -f2 -d'='`
MP2_BIN=`cat config.txt | grep MP2_BIN | cut -f2 -d'='`
MP2_DAT=`cat config.txt | grep MP2_DAT | cut -f2 -d'='`

# Create one shell script of poreqc commands for each experiment
tail -n +2 expt.txt | while read exptid phase lab replicate libtype dirpath ; do
    # Create outdir
    outdir=${MP2_DAT}/04-poreqc/${exptid}
    if [ ! -d ${outdir} ] ; then
        mkdir -p ${outdir}
    fi
    # Create shell script containing poreqc commands
    shfile=${outdir}/${exptid}_poreqc.sh
    if [ -f ${shfile} ] ; then
        rm ${shfile}
        touch ${shfile}
    fi
    echo "#!/usr/bin/env bash" >> ${shfile}
    echo >> ${shfile}
    echo "echo \"Started\"" >> ${shfile}
    echo >> ${shfile}
    echo "${MP2_BIN}/poreqc_extractreadstats.py \\" >> ${shfile}
    echo "--inreadsdir ${MP2_DIR}/data/01-fast5/${exptid}/reads/downloads/pass \\" >> ${shfile}
    echo "--outstatdir ${MP2_DIR}/data/04-poreqc/${exptid} \\" >> ${shfile}
    echo "--outprefix ${exptid}-pass \\" >> ${shfile}
    echo "--inreadsarecalled" >> ${shfile}
    echo >> ${shfile}
    echo "${MP2_BIN}/poreqc_extractreadstats.py \\" >> ${shfile}
    echo "--inreadsdir ${MP2_DIR}/data/01-fast5/${exptid}/reads/downloads/fail \\" >> ${shfile}
    echo "--outstatdir ${MP2_DIR}/data/04-poreqc/${exptid} \\" >> ${shfile}
    echo "--outprefix ${exptid}-fail \\" >> ${shfile}
    echo "--inreadsarecalled" >> ${shfile}
    echo >> ${shfile}
    echo "cp ${MP2_DIR}/data/04-poreqc/${exptid}/${exptid}-pass_readstats_simplified.txt \\" >> ${shfile}
    echo "   ${MP2_DIR}/data/04-poreqc/${exptid}/${exptid}_readstats_simplified.txt" >> ${shfile}
    echo "tail -n +2 ${MP2_DIR}/data/04-poreqc/${exptid}/${exptid}-fail_readstats_simplified.txt \\" >> ${shfile}
    echo "   >> ${MP2_DIR}/data/04-poreqc/${exptid}/${exptid}_readstats_simplified.txt" >> ${shfile}
    echo >> ${shfile}
    echo "${MP2_BIN}/poreqc_extractcallstats.py \\" >> ${shfile}
    echo "--incallsdir ${MP2_DAT}/04-poreqc/${exptid}/reads/downloads \\" >> ${shfile}
    echo "--inreadstatssimpfile ${MP2_DAT}/04-poreqc/${exptid}/${exptid}_readstats_simplified.txt \\" >> ${shfile}
    echo "--outstatdir ${MP2_DAT}/04-poreqc/${exptid} \\" >> ${shfile}
    echo "--outprefix ${exptid}" >> ${shfile}
    echo >> ${shfile}
    echo "echo \"Finished\"" >> ${shfile}
    chmod a+x ${shfile}
    # Print the commands to be executed
    echo "nohup nice ${shfile} &> ${shfile}.nohup.out &"
done
