#!/bin/bash
#$ -q genomics
#$ -j y
#$ -cwd
#$ -N fly
#$ -l h_vmem=70G
#$ -l virtual_free=70G

. $HOME/.bashrc
export TEMPDIR=/genefs/MikheyevU/temp
export TEMP=/genefs/MikheyevU/temp
export TMP=/genefs/MikheyevU/temp

MAXMEM=65
ref=../../ref/dmel.fa
alias GA="java -Xmx"$MAXMEM"g -Djava.io.tmpdir=/genefs/MikheyevU/temp -jar /apps/MikheyevU/sasha/GATK/GenomeAnalysisTK.jar"
alias picard="java -Xmx"$MAXMEM"g -Djava.io.tmpdir=/genefs/MikheyevU/temp -jar /apps/MikheyevU/picard-tools-1.66/"

#GA -nct 6\
#    -T HaplotypeCaller\
#    -R $ref \
#    -A QualByDepth -A RMSMappingQuality -A FisherStrand -A HaplotypeScore -A InbreedingCoeff -A MappingQualityRankSumTest -A Coverage -A ReadPosRankSumTest -A BaseQualityRankSumTest -A ClippingRankSumTest \
#    -I data/merged.recal.bam \
#    --genotyping_mode DISCOVERY \
#    --heterozygosity 0.005 \
#    -o data/raw.vcf

GA \
   -T VariantRecalibrator \
   -R $ref \
   -input data/raw.vcf \
   -resource:samtools,known=false,training=true,truth=true,prior=12.0 data/samtools_gatk1.vcf \
   -an QD -an FS -an DP -an MQRankSum -an ReadPosRankSum  -an ClippingRankSum -an BaseQRankSum -an MQ -an InbreedingCoeff\
   -mode both \
   -tranche 99.0 -tranche 90.0 -tranche 80.0 -tranche 70.0 \
   -recalFile data/output.recal \
   -tranchesFile data/output.tranches \
   -rscriptFile data/plots.R

GA \
  -T ApplyRecalibration \
   -R $ref \
   -input data/raw.vcf \
   --ts_filter_level 90.0 \
   -tranchesFile data/output.tranches \
   -recalFile data/output.recal \
   -mode BOTH \
   -o data/recalibrated.filtered.vcf
 

