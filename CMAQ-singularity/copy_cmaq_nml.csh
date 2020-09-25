#!/bin/csh -f

#SBATCH -t 4:00:00
#SBATCH --mem=100000
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=8
#SBATCH -J CMAQ8
#SBATCH -p debug_queue
##SBATCH -p 528_queue
#SBATCH --exclusive
#SBATCH -o /proj/ie/apps/dogwood/singularity/LOGS/singularity-cctm.batch.Benchmark_2Day.8pe.log
#SBATCH -e /proj/ie/apps/dogwood/singularity/LOGS/singularity-cctm.batch.Benchmark_2Day.8pe.err

# ===================== Singularity "Copy Namelists to Host" Script ========================= 
# Script 9/2020  by C. COATS, UNC IE, for using Singularity to copy
#   the default CMAQ CCTM namelist-files to the indicated host-directory
#   -- Customize if you want to change from /tmp/CMAQ_nmldir
#*********************************************************************

set HOSTDATA  = /work/SCRATCH/CMAQv5.3.1_Benchmark_2Day
set CONTAINER = /work/cmaq.simg

set extradirs = ''
# set extradirs = '=B /foo'

setenv SINGULARITYENV_NMLDIR        /tmp/CMAQ_nmldir
mkdir -p ${SINGULARITYENV_NMLDIR}
set err_status = ${status}
if ( ${err_status} != 0 ) then    
    echo ""
    echo "ERROR:  Could not create ${SINGULARITYENV_NMLDIR}"
    echo ""
    exit( ${err_status} )
endif

singularity exec -B ${SINGULARITYENV_NMLDIR} ${extradirs}  \
 ${CONTAINER} /opt/CMAQ_REPO/scripts/cp_nmldir.csh
 
set err_status = ${status}

if ( ${err_status} != 0 ) then
    echo ""
    echo "****************************************************************"
    echo "** Error for /opt/CMAQ_REPO/scripts/CMAQ_nmldir.csh              **"
    echo "**    STATUS=${err_status}                                    **"
    echo "****************************************************************"
endif

exit( ${err_status} )

