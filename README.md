# Workflow
  - bowtie.sh -- parallelized read alignment and local re-alignment
     - align reads to reference using bowtie
     - use GATK to perform local realignment of reads around indels
       - this last step may work better on a merged alignment
   - merge.sh -- merge realigned bam files into one file
   - call1.sh -- perform initial calling of SNPs, and conduct BQSR recalibration of raw file
   - call2.sh -- final SNP calling, with VQSR 