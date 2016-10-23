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

### Step 01 : Set up analysis directories and environment

```shell
cd /path/to/scripts
cp config_template.txt config.txt
# Update paths in config.txt for your file system
Step01_makedirs.sh
```

### Step 02 : Download and set up the FAST5 data and experiment directories

1. cd /PATH/TO/MARC/PHASE2/data/01-fast5
2. Download the tarball of FAST5 data for each experiment from the EBI (using ncftp or similar).
3. Extract the files from the tar.gz files, creating directories and moving files until you have the files for each experiment in the structure:

```shell
/PATH/TO/MARC/PHASE2/data/01-fast5/EXPTNAME/*.log
/PATH/TO/MARC/PHASE2/data/01-fast5/EXPTNAME/reads/downloads/fail/*.fast5
/PATH/TO/MARC/PHASE2/data/01-fast5/EXPTNAME/reads/downloads/pass/*.fast5
```
4. Decide on a consistent naming convention for each experiment. We used the names: P1-LabX-R1, P2-Lab6-R1-1D, P2-Lab6-R1-2D, P2-Lab7-R1-1D, P2-Lab7-R1-2D.
5. Create symbolic links from the actual experiment directories with the preferred names.

XXXX CAMILLA DID THE FOLLOWING, BUT THIS WILL NEED TO BE UPDATED WHEN THE FINAL DATA IS AVAILABLE ON THE EBI PUBLIC WEBSITE.

```shell
# Change into download directory
cd /PATH/TO/MARC/PHASE2/data/01-fast5

# Typical MARC Phase 1 2D run
ncftp -u dcc_marc XXXX
ln -s /path/to/P1b-Lab2-R2 P1b-Lab2-R2-2D

# Lab6 (UBC) 1D and 2D run
ncftp -u dcc_marc ftp://ftp.dcc-private.ebi.ac.uk/data/ERA716/ERA716428/oxfordnanopore_native/
ls -l
mget *.tar.gz
quit
tar -zxvf UBC_MARC_1D_R9_107_Called.tar.gz
ln -s Chip93_MARC_1D_UBC_Called_107 P2-Lab6-R1-1D
tar -zxvf UBC_MARC_2D_R9_107_Called.tar.gz
ln -s UBC_MARC_2D_R9_107_Called P2-Lab6-R1-2D

# Lab7 (Nottingham) 1D and 2D run
ncftp -u dcc_marc ftp://ftp.dcc-private.ebi.ac.uk/data/ERA706/ERA706812/oxfordnanopore_native/
ls -l
mget *.tar.gz
quit
tar -zxvf Nott_R9_run2_1D.tar.gz
mkdir Nott_R9_run2_1D
mv -i reads Nott_R9_run2_1D
chmod -R a+r *
chmod a+rwx Nott_R9_run2_1D
chmod a+rwx Nott_R9_run2_1D/reads
chmod a+rwx Nott_R9_run2_1D/reads/downloads
chmod a+rwx Nott_R9_run2_1D/read/downloads/fail
chmod a+rwx Nott_R9_run2_1D/reads/downlloads/pass
ln -s Nott_R9_run2_1D P2-Lab7-R1-1D
tar -zxvf Nott_R92_2D.tar.gz
chmod -R a+r marc_bridging_2D_run
chmod a+rwx marc_bridging_2D_run
chmod a+rwx marc_bridging_2D_run/downloads
chmod a+rwx marc_bridging_2D_run/downloads/fail
chmod a+rwx marc_bridging_2D_run/downloads/pass
ln -s marc_bridging_2D_run P2-Lab7-R1-2D
```

Your data/01-fast5 directory should now contain files:
```shell
/PATH/TO/data/01-fast5/P1b-Lab2-R2-2D/reads/downloads/pass/*.fast5
/PATH/TO/data/01-fast5/P1b-Lab2-R2-2D/reads/downloads/fail/*.fast5
/PATH/TO/data/01-fast5/P2-Lab6-R1-1D/reads/downloads/fail/*.fast5
/PATH/TO/data/01-fast5/P2-Lab6-R1-1D/reads/downloads/pass/*.fast5
/PATH/TO/data/01-fast5/P2-Lab6-R1-2D/reads/downloads/fail/*.fast5
/PATH/TO/data/01-fast5/P2-Lab6-R1-2D/reads/downloads/pass/*.fast5
/PATH/TO/data/01-fast5/P2-Lab7-R1-1D/reads/downloads/fail/*.fast5
/PATH/TO/data/01-fast5/P2-Lab7-R1-1D/reads/downloads/pass/*.fast5
/PATH/TO/data/01-fast5/P2-Lab7-R1-2D/reads/downloads/fail/*.fast5
/PATH/TO/data/01-fast5/P2-Lab7-R1-2D/reads/downloads/pass/*.fast5
```

Make a copy of the scripts/expt_template.txt file called 'expt.txt', and change the paths to reflect your data hierarchy.
