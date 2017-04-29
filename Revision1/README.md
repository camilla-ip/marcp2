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

Download the raw FAST5 data files for each experiment from the European Nucleotide Archive (ENA):
```
* P1b-Lab2-R2-2D : URL
* P2-Lab6-R1-2D : URL
* P2-Lab7-R1-2D : URL
* P2-Lab6-R1-1D : URL
* P2-Lab7-R1-1D : URL
```

Rename and move the data until the file hierarchy is:
```
/PATH/TO/DATA/EXPTID/reads/downloads/[fail|pass]/*.fast5
```

__3. Set up references and configure scripts__

Set up an environment variable for the analysis output directory:
```
export MARCP2=/PATH/TO/MARC/PHASE2/ANALYSIS/OUTPUT/DIR
```

__4. Run the analysis__

XXXX

## Analysis output

XXXX
