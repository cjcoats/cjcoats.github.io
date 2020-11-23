#! /bin/csh -f
#SBATCH -p general -N 1 -n 1 -t 00:20:00
#
# ===================== Singularity "Run appendwrf" Script ========================= 
# Script 6/2020  by C. COATS, UNC IE, for using Singularity to run on the 
#   CMAQ Singularity container on "longleaf" or "dogwood", which do not
#   allow Singularity on login-nodes
#*********************************************************************

# Data directory on host:  mounts onto container-directory "/opt/CMAQ_${CMAQ_VRSN}/data"

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

#   Set up run-control variablesenvironment variables such as START_DATE, below,
#   and optionally:
#   MISS_CHECK: set days with incomplete data coverage to missing when 
#       computing daily maximum 8-hr averages
#   SPECIES, UNITS: species label and units  to be used in overlay file

setenv SINGULARITYENV_START_DATE    "2016-07-01"
setenv SINGULARITYENV_END_DATE      "2016-07-02"
setenv SINGULARITYENV_APPL          2016_12SE1
setenv SINGULARITYENV_HOURS_8HRMAX  24

singularity exec \
 --bind ${HOSTDATA}:/opt/CMAQ_${CMAQ_VRSN}/data ${extradirs} \
 ${CONTAINER} /opt/CMAQ_${CMAQ_VRSN}/scripts/run_bldoverlay.csh

if ( ${err_status} != 0 ) then
    echo ""
    echo "****************************************************************"
    echo "** Error for /opt/CMAQ_${CMAQ_VRSN}/scripts/run_bldoverlay.csh        **"
    echo "**    STATUS=${err_status}                                    **"
    echo "****************************************************************"
endif

exit( ${err_status} )

