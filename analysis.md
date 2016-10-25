## MARC Phase 2 analysis manual

### Overview

The following instructions will describe how to re-generate the analysis
presented in the MARC Phase 2 data release paper from the MinION data
generated

### Pre-requisites

Third-party software (specified version or higher):
- bwa 0.7.12-r1039
- git
- marcoporo 1.0.0
- marginAlign XXXX
- nanook XXXX
- poretools 0.5.1
- SAMtools 0.1.19-44428cd

Disk storage:
- XXXX TB for raw data
- XXXX TB for analysis output files

CPUs / cores:
- As many as possible. The scripts will run on a multi-core server or a cluster with Sun Grid Engine (SGE) scheduling.

Environment
- A linux system with bash environment.
- If you have access to an SGE cluster, the scripts must be executed on an SGE submit node.

### Step 0 : Download scripts & set up analysis parameters

To download the marcoporo package:
```shell
cd /YOUR/PATH/TO/PACKAGES
git clone git@github.com:camilla-ip/marcoporo.git
export PATH=${PATH}:/YOUR/PATH/TO/PACKAGES/marcoporo
```

To download the scripts:
```shell
mkdir -p /YOUR/PATH/TO/ANALYSES/MYSTUDY
cd ${MP2}
git clone git@github.com:camilla-ip/marcp2.git
export MP2=/YOUR/PATH/TO/ANALYSES/MYSTUDY/marcp2
```

To set up the analysis parameters:
1. export MARCOPORO=/YOUR/PATH/TO/PACKAGES/marcoporo
2. mkdir ${MP2}/data/00-config
3. cp ${MARCOPORO}/v1/config_example.txt ${MP2}/data/00-config/config.txt
4. Edit config.txt for your file system and computing resources, setting up a new top-level 'dirpath' for each experiment called /PATH/TO/ANALYSIS/MYDIR/marcp2/data/00-fast5/EXPTID
5. cp ${MARCOPORO}/v1/experiment_example.txt ${MP2}/data/00-config/experiment.txt
6. Edit experiment.txt for your data sets.

### Step 1 : Download experiment data (as FAST5)

1. Use ncftp (or similar) to download the FAST5 and log files for each experiment.

Your data/01-fast5 directory should now contain files:
```shell
/PATH/TO/ANALYSIS/MYDIR/marcp2/data/01-fast5/P1b-Lab2-R2-2D/reads/downloads/pass/*.fast5
/PATH/TO/ANALYSIS/MYDIR/marcp2/data/01-fast5/P1b-Lab2-R2-2D/reads/downloads/fail/*.fast5
/PATH/TO/data/01-fast5/P2-Lab6-R1-1D/reads/downloads/fail/*.fast5
/PATH/TO/data/01-fast5/P2-Lab6-R1-1D/reads/downloads/pass/*.fast5
/PATH/TO/data/01-fast5/P2-Lab6-R1-2D/reads/downloads/fail/*.fast5
/PATH/TO/data/01-fast5/P2-Lab6-R1-2D/reads/downloads/pass/*.fast5
/PATH/TO/data/01-fast5/P2-Lab7-R1-1D/reads/downloads/fail/*.fast5
/PATH/TO/data/01-fast5/P2-Lab7-R1-1D/reads/downloads/pass/*.fast5
/PATH/TO/data/01-fast5/P2-Lab7-R1-2D/reads/downloads/fail/*.fast5
/PATH/TO/data/01-fast5/P2-Lab7-R1-2D/reads/downloads/pass/*.fast5
```

### Step 2 : Extract experiment metadata (marcoporo parameters)

### Step 3 : Extract experiment-level statistics (marcoporo runstats)

### Step 4 : Extract read-level statistics (marcoporo callstats)

### Step 5 : Extract basecalls (poretools)

### Step 6 : Map basecalls (bwa mem)

### Step 7 : Improve basecall alignments (marginAlign) 

### Step 8 : Generate QC reports (nanook)

### Step 9 : Generate comparison tables and plots

### Step 10 : Generate MARC Phase 2 files


### ===

### Step 00 : Set up analysis directories and environment

```shell
cd /path/to/scripts
cp config_template.txt config.txt
# Update paths in config.txt for your file system
Step01_makedirs.sh
```

### Step 01 : Download and set up the FAST5 data and experiment directories

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

### Step 02 : Extract FASTQ files

1. Change directory to data/02-fastq.
2. Use poretools to extract the fastq records from each set of FAST5 files, then create symbolic links to each file according to phase-lab-replicate-library-readtype-readclass.fastq naming convention.

Dir data/02-fastq should now contain:

```shell
P1b-Lab2-R2-2D-1C-fail.fastq
P1b-Lab2-R2-2D-1C-pass.fastq
P1b-Lab2-R2-2D-1T-fail.fastq
P1b-Lab2-R2-2D-1T-pass.fastq
P1b-Lab2-R2-2D-2D-fail.fastq
P1b-Lab2-R2-2D-2D-pass.fastq
P2-Lab6-R1-1D-1D-fail.fastq
P2-Lab6-R1-1D-1D-pass.fastq
P2-Lab6-R1-2D-1D-fail.fastq
P2-Lab6-R1-2D-1D-pass.fastq
P2-Lab6-R1-2D-2D-fail.fastq
P2-Lab6-R1-2D-2D-pass.fastq
P2-Lab7-R1-1D-1D-fail.fastq
P2-Lab7-R1-1D-1D-pass.fastq
P2-Lab7-R1-2D-1D-fail.fastq
P2-Lab7-R1-2D-1D-pass.fastq
P2-Lab7-R1-2D-2D-fail.fastq
P2-Lab7-R1-2D-2D-pass.fastq
```

### Step 03 : Map reads with bwa mem

To set up the reference files:

1. Download the Escherichia coli str. K-12 substr. MG1655 target genome from RefSeq  at https://www.ncbi.nlm.nih.gov/nuccore/NC_000913.3 in FASTA format, and set the contigid to be "NC_000913.3".
2. Download the ONT lambda phage genome, which differs at a few positions from the version in RefSeq, from XXXX in FASTA format.
3. Concatenate the two input files into a single file called "data/03-bwamem/references.fasta".
5. Ensure there is a newline on the last line of the file and the file contains Unix-style newline characters.
4. Generate the bwa indices with command "bwa index references.fasta".

The data/03-bwamem directory should now contain files:

```shell
references.fasta
references.fasta.amb
references.fasta.ann
references.fasta.bwt
references.fasta.pac
references.fasta.sa
```

iXXXX NEED TO FILL THIS IN LATER

### Step 04 : Generate per-read statistics with poreqc

Run the Step04_runporeqc.sh script to generate the output directories, shell script, and execute them using nohup.

