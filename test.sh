#!/bin/bash


#Required Tools 
#FastQC - to dowload the tool - sudo apt-get install fastqc

#Before installing Trimmomatic make sure the system has "Java" installed
#Trimmomatic -- to download this tool -- use command -- wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.39.zip
#unzip the above file - unzip Timmomatic-0.39.zip
#after going to the file you can intall that using -- java - jar trimmomatic-0.39.jar

#HISAT2
#To download HISAT2 use cmd -- wget https://cloud.biohpc.swmed.edu/index.php/s/oTtGWbWjaxsQ2Ho/download -O hisat2.zip
#unzip hisat2.zip
#ls --> goto hisat2-2.2.1 -- sudo apt-get install hisat2

#featureCounts
#sudo apt-get install subread

#Code --------------------------

SECONDS=0

# change working directory
#cd /home/raj/Desktop/BioX


# STEP 1: Run fastqc
# Instead of demo.fastq we can add any fastq file here in the command which comes from the sequencer
fastqc data/demo.fastq -o data/


# run trimmomatic to trim reads with poor quality
java -jar ~/Desktop/demo/tools/Trimmomatic-0.39/trimmomatic-0.39.jar SE -threads 4 data/demo.fastq data/demo_trimmed.fastq TRAILING:10 -phred33
echo "Trimmomatic finished running!"

fastqc data/demo_trimmed.fastq -o data/

# STEP 2: Run HISAT2
# mkdir HISAT2
# get the genome indices
# wget https://genome-idx.s3.amazonaws.com/hisat/grch38_genome.tar.gz

# run alignment
#Output SAM File
hisat2 -q --rna-strandness R -x HISAT2/grch38/genome -U data/demo_trimmed.fastq -S HISAT2/demo_trimmed.sam
echo "HISAT2 finished running!"

#Output BAM File 
hisat2 -q --rna-strandness R -x HISAT2/grch38/genome -U data/demo_trimmed.fastq | samtools sort -o HISAT2/demo_trimmed.bam
echo "HISAT2 finished running!"

# STEP 3: Run featureCounts - Quantification
# get gtf
# wget http://ftp.ensembl.org/pub/release-106/gtf/homo_sapiens/Homo_sapiens.GRCh38.111.gtf.gz
featureCounts -S 2 -a ./quants/Homo_sapiens.GRCh38.111.gtf -o quants/demo_featurecounts.txt HISAT2/demo_trimmed.bam
echo "featureCounts finished running!"

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
