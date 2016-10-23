## MARC Phase 2 analysis manual

### Overview

The following instructions will describe how to re-generate the analysis
presented in the MARC Phase 2 data release paper from the MinION data
generated

### Pre-requisites

Third-party software (specified version or higher):
- poretools  XXXX 
- SAMtools  XXXX
- bwa XXXX

Disk storage:
- XXXX TB for raw data
- XXXX TB for analysis output files

CPUs:
- We assume you have access to a multi-core server or a cluster with Sun Grid Engine (SGE) scheduling.

Environment
- A linux system with bash environment.

### Step 1 : Set up analysis directories and environment

Environment variables:

```shell
export MP2_DIR=/path/to/marcp2
export MP2_BIN=${MP2_DIR}/scripts
export MP2_DATIN=${MP2_DIR}/data/in
export MP2_DATOUT=${MP2_DIR}/data/out
```

We assume that you will download the complete set of 

export $MP2=
