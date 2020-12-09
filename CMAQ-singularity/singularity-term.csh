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

set HOSTDATA  = /work/SCRATCH/CMAQv5.3.1_Benchmark_2Day
set SMOKEDATA = /work/SCRATCH/SMOKE.git/data
set CONTAINER = /work/cmaq.simg

set extradirs = ''
# set extradirs = '=B /foo'

# setenv SINGULARITYENV_GEOM 80x80

setenv 

singularity exec  ${extradirs} \
 --bind ${HOSTDATA}:/opt/CMAQ_531/data \
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

