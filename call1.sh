#!/bin/bash
#$ -q long
#$ -j y
#$ -cwd
#$ -N fly
#$ -l h_vmem=10G
#$ -l virtual_free=10G

. $HOME/.bashrc
export TEMPDIR=/genefs/MikheyevU/temp
export TEMP=/genefs/MikheyevU/temp
export TMP=/genefs/MikheyevU/temp

MAXMEM=8
ref=../../ref/dmel.fa
alias GA="java -Xmx"$MAXMEM"g -Djava.io.tmpdir=/genefs/MikheyevU/temp -jar /apps/MikheyevU/sasha/GATK/GenomeAnalysisTK.jar"
alias picard="java -Xmx"$MAXMEM"g -Djava.io.tmpdir=/genefs/MikheyevU/temp -jar /apps/MikheyevU/picard-tools-1.66/"

#old_IFS=$IFS
#IFS=$'\n'
#a=($(cat data/scaffolds.txt))
#a=($(cat data/scaffolds_long.txt))
#IFS=$old_IFS
#limit=${a[$SGE_TASK_ID-1]}

#GA -nct 6\
#    -T HaplotypeCaller\
#    -R $ref \
#    -I data/fly1.bam \
#    --genotyping_mode DISCOVERY \
#    --heterozygosity 0.005 \
#    -o data/raw1.vcf

#    -A QualByDepth -A RMSMappingQuality -A FisherStrand -A HaplotypeScore -A InbreedingCoeff -A MappingQualityRankSumTest -A Coverage -A ReadPosRankSumTest -A BaseQualityRankSumTest -A ClippingRankSumTest \

#samtools mpileup -ugf $ref data/fly1.bam | bcftools view -vcg - | vcfutils.pl varFilter -Q 20 > data/samtools.vcf

#(grep ^# data/raw1.vcf ;  intersectBed -wa -a data/samtools.vcf -b data/raw1.vcf ) > data/samtools_gatk1.vcf


#(grep ^# data/raw1.vcf ;  intersectBed -wa -a data/samtools.vcf -b data/raw1.vcf ) > data/samtools_gatk1.vcf

# GA \
#    -nct 6 \
#    -T BaseRecalibrator \
#    -I data/fly1.bam   \
#    -R $ref \
#    -knownSites data/samtools_gatk1.vcf \
#    -o data/recal_data.table

 GA \
    -nct 6 \
    -T PrintReads \
    -I data/fly1.bam   \
    -R $ref  \
    -BQSR data/recal_data.table \
    -o data/merged.recal.bam

GA \
   -nct 6 \
   -T BaseRecalibrator \
   -I data/merged.recal.bam  \
   -R $ref \
    -knownSites data/samtools_gatk1.vcf \
   -BQSR data/recal_data.table \
   -o data/post_recal_data.table

GA \
    -T AnalyzeCovariates \
    -R $ref \
    -before data/recal_data.table \
    -after data/post_recal_data.table \
    -plots recalibration_plots.pdf
