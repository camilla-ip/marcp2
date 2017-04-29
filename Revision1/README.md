# MARC Phase 2 analysis - Revision 1

The following instructions describe how to re-generate the analysis
presented in Revision 1 of the MARC Phase 2 study.

## System requirements

- System: Linux or Mac OSX
- Environment: BASH
- Disk: XXXX TB for raw data, XXXX TB for analysis
- CPU: Multi-core server or a cluster with Sun Grid Engine (SGE) scheduling

## Quick start

__1. Download third-party software__

Bioinformatics software:
- bwa 0.7.12-r1039
- marcoporo 1.0
- marginAlign XXXX
- nanook XXXX
- poretools 0.5.1
- SAMtools 0.1.19-44428cd

R packages:
- XXXX

Python packages:
- XXXX

__2. Download the raw experimental data__

Use ncftp (or similar) to download the raw FAST5 data for each experiment:
```
P1b-Lab2-R2-2D : URL
P2-Lab6-R1-2D : URL
P2-Lab7-R1-2D : URL
P2-Lab6-R1-1D : URL
P2-Lab7-R1-1D : URL
```

Unzip, rename and/or move the files around until the file hierarchy has structure:
```
/PATH/TO/DATA/EXPTID/reads/downloads/[fail|pass]/*.fast5
```

__3. Set up config and additional data files for analysis__

* Set up some environment variables to simplify the explanation below:
```
export MARCP2=/PATH/TO/MARCP2/DIR/
export MARCOPORO=/PATH/TO/MARCOPORO/v1.0/DIR/
export PHASE2=/PATH/TO/MARC/PHASE2/ANALYSIS/OUTPUT/DIR/
```

* Copy config file templates to a new local 01-config sub-directory and edit files as appropriate. The reference files for the analysis can refer to the references provided in the $MARCP2/Revision1 directory, which are a concatenation of the E. coli K-12 MG1665 strain and the entire lambda phage genome from Oxford Nanopore Technologies (which differs by a few nucleotides from XXXX in NCBI RefSeq).

```
cd $PHASE2/
mkdir 01-config
cp $MARCP2/Revision1/experiments_template.txt 01-config/experiments.txt
cp $MARCOPORO/config_example.txt 01-config/marcoporo_config.txt
```

Your analysis output directory should now contain:
```
$PHASE2/01-config
    /experiments.txt
    /marcoporo_config.txt
```

__4. Run the analysis__

```
${MARCP2}/run_marcp2_analysis.sh \
  ${PHASE2}/01-config/experiments.txt \
  ${PHASE2}/01-config/marcoporo-config.txt \
  ${PHASE2}
```

## Analysis output

XXXX

