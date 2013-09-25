#!/bin/bash
#$ -q short
#$ -j y
#$ -cwd
#$ -N fassst
#$ -l h_vmem=5G
#$ -l virtual_free=1G
. $HOME/.bashrc
#SGE_TASK_ID=1
#a=(./lane?/*_1.fq)
#b=(./lane?/*_2.fq)

# raw fastq files located in fly1 directory

a=(fly1/*_1.fq)

alias GA="java -Xmx4g -jar /apps/MikheyevU/sasha/GATK/GenomeAnalysisTK.jar"

#location of bowtie2 aligner index
ref=ref/dmel
base=$(basename ${a["SGE_TASK_ID"-1]} "_1.fq")
dir=$(dirname ${a["SGE_TASK_ID"-1]})
f=${a["SGE_TASK_ID"-1]}
r=$dir/$(basename $f 1.fq)2.fq

#align raw reads to the reference genome
bowtie2 -p 2 --sam-rg ID:$base --sam-rg LB:FASSST --sam-rg SM:$base --sam-rg PL:ILLUMINA -x $ref -1 $f -2 $r | samtools view  -Su -F 4 - | novosort -t /genefs/MikheyevU/temp -i -o  $dir/$base".bam" -

#find regions for local realignment of reads around indels
GA -U \
   -I $dir/$base.bam \
   -R ref/dmel.fa \
   -T RealignerTargetCreator \
   -o $dir/$base"_IndelRealigner.intervals" 

#re-align reads
GA  -U \
   -I $dir/$base.bam \
   -R ref/dmel.fa \
   -T IndelRealigner \
   -targetIntervals $dir/$base"_IndelRealigner.intervals" \
   --maxReadsInMemory 1000000 \
   --maxReadsForRealignment 100000 \
   -o $dir/$base.realigned.bam

#create an index for the resulting bam file (may not be necessary)
samtools index $dir/$base.realigned.bam
