#! /bin/csh -f
#SBATCH -p general -N 1 -n 1 -t 00:20:00
#
# ===================== Singularity "Run COMBINE" Script ========================= 
# Script by C. COATS, UNC IE, for using Singularity to run on the 
#   CMAQ Singularity container on "longleaf" or "dogwood", which do not
#   allow Singularity on login-nodes

#   Data directory on host:  mounts onto container-directory "/opt/CMAQ_${CMAQ_VRSN}/data"

set HOSTDATA  = /work/SCRATCH/CMAQv5.3.1_Benchmark_2Day
set CONTAINER = /work/cmaq.simg
set CMAQ_VRSN = 5.3.1

set extradirs = ''
# set extradirs = '-B /foo'

# Set up environment for verbose-level and/or debug:

setenv SINGULARITYENV_CTM_DIAG_LVL  0

unsetenv SINGULARITYENV_DEBUG
unsetenv SINGULARITYENV_EXEC

# setenv SINGULARITYENV_DEBUG   1
# setenv SINGULARITYENV_EXEC    <path to debug-executable>

# Set up environment variables such as START_DATE, below.

setenv SINGULARITYENV_APPL          2016_12SE1
setenv SINGULARITYENV_RUNID         "gcc_${VRSN}_${APPL}"
setenv SINGULARITYENV_START_DATE    "2016-07-01"
setenv SINGULARITYENV_END_DATE      "2016-07-02"
setenv SINGULARITYENV_USELOCAL      N
setenv SINGULARITYENV_TIME_SHIFT    0
setenv SINGULARITYENV_USECOLROW     N
setenv SINGULARITYENV_LAYER         1
setenv SINGULARITYENV_SITE_FILE     ALL
setenv SINGULARITYENV_PRTHEAD       Y
setenv SINGULARITYENV_PRT_XY        Y
setenv SINGULARITYENV_SPECIES_1     O3
setenv SINGULARITYENV_IN_FILE       COMBINE_ACONC_${RUNID}_201607.nc

singularity exec \
 --bind ${HOSTDATA}:/opt/CMAQ_${CMAQ_VRSN}/data ${extradirs} \
 ${CONTAINER} /opt/CMAQ_${CMAQ_VRSN}/scripts/run_combine.csh

if ( ${err_status} != 0 ) then
    echo ""
    echo "****************************************************************"
    echo "** Error for /opt/CMAQ_${CMAQ_VRSN}/scripts/run_combine.csh           **"
    echo "**    STATUS=${err_status}                                    **"
    echo "****************************************************************"
endif

exit( ${err_status} )

