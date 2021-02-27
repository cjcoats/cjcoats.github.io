#! /bin/csh -f
#SBATCH -p debug -N 1 -n 1 -t 00:20:00
#
# ===================== Singularity "Run BCON" Script ========================= 
# Script 6/2020  by C. COATS, UNC IE, for using Singularity to run on the 
#   CMAQ Singularity container on "longleaf" or "dogwood", which do not
#   allow Singularity on login-nodes
#*********************************************************************
#
#   Data directory on host:  mounts onto container-directory "/opt/CMAQ_531/data"
#   must have subdirectories:
#       ${CRS_APPL} for conc-file and gridded met inputs
#       ${FIN_APPL} for bdy met-file inputs and BCON outputs

set CMAQDATA  = /work/SCRATCH/CMAQv5.3.1_Benchmark_2Day
set SMOKEDATA = /work/SCRATCH/SMOKE.git/data
set CONTAINER = /work/cmaq.simg

set extradirs = ''
# set extradirs = '-B /foo'

# This controls the geometry of the terminal to be launched;
# without this, the default is 80x96
# setenv SINGULARITYENV_GEOM 80x80

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

singularity exec  ${extradirs} \
 --bind ${CMAQDATA}:/opt/CMAQ_532/data \
 --bind ${SMOKEDATA}:/opt/SMOKE/data \
 ${CONTAINER} /opt/bin/open_terminal.csh

if ( ${err_status} != 0 ) then
    echo ""
    echo "****************************************************************"
    echo "** Error for /opt/CMAQ_531/scripts/run_bcon.csh              **"
    echo "**    STATUS=${err_status}                                    **"
    echo "****************************************************************"
endif

exit( ${err_status} )

