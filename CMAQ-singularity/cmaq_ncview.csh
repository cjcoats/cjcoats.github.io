#! /bin/csh -f
#SBATCH -p general -N 1 -n 1 -t 00:20:00
#
# ===================== Singularity "Run ncview" Script ========================= 
# Script 6/2020  by C. COATS, UNC IE, for using Singularity to run on the 
#   CMAQ Singularity container on "longleaf" or "dogwood", which do not
#   allow Singularity on login-nodes

set HOSTDATA  = /work/SCRATCH/CMAQv5.3.1_Benchmark_2Day
set CONTAINER = /work/cmaq.simg
set CMAQ_VRSN = 5.3.1

set extradirs = ''
# set extradirs = '-B /foo'

singularity exec \
 --bind ${HOSTDATA}:/opt/CMAQ_${CMAQ_VRSN}/data ${extradirs} \
 ${CONTAINER} /opt/bin/ncview

if ( ${err_status} != 0 ) then
    echo ""
    echo "****************************************************************"
    echo "** Error for /opt/CMAQ_${CMAQ_VRSN}/scripts/run_verdi.csh              **"
    echo "**    STATUS=${err_status}                                    **"
    echo "****************************************************************"
endif

exit( ${err_status} )

