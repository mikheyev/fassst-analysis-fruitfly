#!/bin/bash
#$ -q genomics
#$ -j y
#$ -cwd
#$ -N merge
#$ -l h_vmem=50G
#$ -l virtual_free=50G

. $HOME/.bashrc

export TEMPDIR=/genefs/MikheyevU/temp
export TEMP=/genefs/MikheyevU/temp
export TMP=/genefs/MikheyevU/temp


novosort -t $TMP -i -o fly1.bam --ram 48G -c 6 *realigned.bam