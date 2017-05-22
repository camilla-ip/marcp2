# MARC Phase 2 analysis - Revision 1

The following instructions describe how to re-generate the analysis
presented in Revision 1 of the MARC Phase 2 study.

## System requirements

- System: Linux or Mac OSX
- Environment: BASH
- Disk: 1.5 TB (1.1 TB for raw data and another 0.4 TB for analysis)
- CPU: Multi-core server or a cluster with Sun Grid Engine (SGE) scheduling

## Step 1. Download third-party software

Bioinformatics software:
- bwa 0.7.12-r1039
- marcoporo 1.0
- marginAlign 0.1
- nanook 0.95
- poretools 0.5.1
- SAMtools 0.1.19-44428cd

R packages:
- ggplot2
- grid
- methods
- plyr
- reshape2
- RColorBrewer

Python packages:
- h5py
- Bio

## Step 2. Download raw experimental data

Use ncftp (or similar) to download the raw FAST5 data for each experiment from the
European Nucleotide Archive (ENA) at https://www.ebi.ac.uk/ena

The Phase 1 data for experiment P1b-Lab2-R2-2D is available under Project ID PRJEB11008.

The Phase 2 data for experiments P2-Lab6-R1-2D, P2-Lab6-R1-2D, P2-Lab6-R1-1D and P2-Lab7-R1-1D
are available under Project ID PRJEB18053.

Unzip, rename and/or move the files around until the file hierarchy has structure:
```
/PATH/TO/DATA/EXPTID/reads/downloads/[fail|pass]/*.fast5
```

## Step 3. Set up config files and references

Set up some environment variables to simplify the explanation below:
```
export MARCP2=/PATH/TO/MARCP2/DIR/
export MARCOPORO=/PATH/TO/MARCOPORO/v1.0/DIR/
export PHASE2=/PATH/TO/MARC/PHASE2/ANALYSIS/OUTPUT/DIR/
```

Copy config file templates to a new local 01-config sub-directory and edit files as appropriate.
```
cd $PHASE2/
mkdir 01-config
cp $MARCP2/Revision1/experiments_template.txt 01-config/experiments.txt
cp $MARCOPORO/config_example.txt 01-config/marcoporo_config.txt
```

Set up the E. coli and lambda phage references. The FASTA files are copied from the scripts release directory and database indices created locally. The references.fasta file contains a concatenation of the E. coli K-12 MG1665 strain (NC_000913.3) and the entire lambda phage genome from Oxford Nanopore Technologies. The target.fasta file contains only the E. coli genome. The ONT lambda reference differs at four sites from NC_001416.1 in NCBI RefSeq (37589:C->T, 37742:C->T, 43082:G->A, 45352:G->A).

```
cd ${PHASE2}
zcat $MARCP2/Revision1/references.fasta.gz > 01-config/references.fasta
makeblastdb -in=01-config/references.fasta -dbtype=nucl
bwa index 01-config/references.fasta
zcat $MARCP2/Revision1/target.fasta.gz > 01-config/target.fasta
makeblastdb -in=01-config/target.fasta -dbtype=nucl
bwa index 01-config/target.fasta
zcat $MARCP2/Revision1/target.fasta.gz > 01-config/control.fasta
makeblastdb -in=01-config/control.fasta -dbtype=nucl
bwa index 01-config/control.fasta
```

Your analysis output directory should now contain:
```
$PHASE2
  /01-config
    /control.fasta
    /control.fasta.amb
    /control.fasta.ann
    /control.fasta.bwt
    /control.fasta.nhr
    /control.fasta.nin
    /control.fasta.nsq
    /control.fasta.pac
    /control.fasta.sa
    /experiments.txt
    /marcoporo_config.txt
    /references.fasta
    /references.fasta.amb
    /references.fasta.ann
    /references.fasta.bwt
    /references.fasta.nhr
    /references.fasta.nin
    /references.fasta.nsq
    /references.fasta.pac
    /references.fasta.sa
    /target.fasta
    /target.fasta.amb
    /target.fasta.ann
    /target.fasta.bwt
    /target.fasta.nhr
    /target.fasta.nin
    /target.fasta.nsq
    /target.fasta.pac
    /target.fasta.sa
```

## Step 4. Run the analysis

```
${MARCP2}/Revision1/run_marcp2_analysis.sh \
  ${PHASE2}/01-config/experiments.txt \
  ${PHASE2}/01-config/marcoporo_config.txt \
  ${MARCP2}/Revision1 \
  ${PHASE2}
```

## Analysis output

```
${PHASE2}
  /02-exptcontstants
    /exptconstantfields.txt
    /exptconstants.txt
  /03-extract
    /EXPTID_[1T|1C|2D]_[fail|pass].fastq
    /EXPTID_batch.txt
    /EXPTID_exptstats.txt
    /EXPTID_read1dstats.txt
    /EXPTID_read2dstats.txt
    /EXPTID_readeventstats.txt
    /EXPTID_readstats.txt
  /04-bwamem
    /EXPTID_[1T|1C|2D]_[fail|pass].bam
    /EXPTID_[1T|1C|2D]_[fail|pass].bam.bai
    /EXPTID_[1T|1C|2D]_[fail|pass].err
    /EXPTID_[1T|1C|2D]_[fail|pass]_initstats.txt
    /EXPTID_[1T|1C|2D]_[fail|pass]_readstats.txt
    /EXPTID_[1T|1C|2D]_[fail|pass]_runstats.txt
    /EXPTID_[1T|1C|2D]_[fail|pass]_poremapstats.log
  /05-aggregate
    /EXPTID_aggregate_[read1d|read2d]_basespersecond.txt
    /EXPTID_aggregate_[read1d|read2d]_bqmean.txt
    /EXPTID_aggregate_[read1d|read2d]_gcpct.txt
    /EXPTID_aggregate_[read1d|read2d]_meanqscore.txt
    /EXPTID_aggregate_[read1d|read2d]_seqlen.txt
    /EXPTID_aggregate_[read1d|read2d]_basespersecond.txt
    /EXPTID_aggregate_readevent.txt
    /EXPTID_merged1dstats.txt
    /EXPTID_merged2dstats.txt
  /06-marginalign
    /EXPTID_[fail|pass]_[BWANoRealign|BWAMEM10M].[sam|stats]
  /07-nanookreports
    /EXPTID
        /latex_bwa_failonly/EXPTID_failonly.pdf
        /latex_bwa_passonly/EXPTID_passonly.pdf
        /latex_bwa_passfail/EXPTID_passfail.pdf
  /08-analysis
    Figure_readlengths.[txt|png]
    Figure_performancemetrics.[txt|png]
```

