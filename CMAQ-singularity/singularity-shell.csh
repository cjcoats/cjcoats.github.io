#!/bin/csh -f
# ===================== Script to Invoke Singularity-Shell =========================
#   Not for batch use on "longleaf.unc.edu" etc. servers (see ../Scripts-BATCH)
#*********************************************************************
#   Data directories on host:  
#       HOSTDATA mounts onto container-directory "/opt/CMAQ_531/data"
#       and must have subdirectories:
#           ${CRS_APPL} for conc-file and gridded met inputs
#           ${FIN_APPL} for bdy met-file inputs and BCON outputs 
#       SMOKEDATA mounts onto container-directory "/opt/SMOKE/data"
#   Comment out un-used directories and the matching "--bind" directives.

set CMAQDATA  = /work/SCRATCH/CMAQv5.3.1_Benchmark_2Day
set SMOKEDATA = /work/SCRATCH/SMOKE
set CONTAINER = /work/cmaq.simg

set extradirs = ''
# set extradirs = '-B /foo'

# #   Set up environment variables such as START_DATE, below.
# 
# setenv SINGULARITYENV_START_DATE    "2016-07-01"
# setenv SINGULARITYENV_START_TIME    0000000
# setenv SINGULARITYENV_RUN_LENGTH    2400000
# setenv SINGULARITYENV_TIME_STEP      100000
# setenv SINGULARITYENV_END_DATE      "2016-07-02"
# setenv SINGULARITYENV_APPL          2016_12SE1
# setenv SINGULARITYENV_EMIS          2016ff
# setenv SINGULARITYENV_PROC          mpi
# setenv SINGULARITYENV_NPCOL         1
# setenv SINGULARITYENV_NPROW         3

#  invoke "singularity shell" using bindings of host-directories to
#  container-directories, and starting at mount-point of ${CMAQDATA}

cd ${CMAQDATA}

singularity shell -s /usr/bin/tcsh  ${extradirs}\
 --bind ${CMAQDATA}:/opt/CMAQ_532/data \
 --bind ${SMOKEDATA}:/opt/SMOKE/data \
 ${CONTAINER}
