#! /bin/csh -f
#SBATCH -p general -N 1 -n 1 -t 01:00:00
#
# ===================== Singularity "Run BCON" Script ========================= 
# Script 6/2020  by C. COATS, UNC IE, for using Singularity to run on the 
#   CMAQ Singularity container on "longleaf" or "dogwood", which do not
#   allow Singularity on login-nodes
#*********************************************************************

# Data directory on host:  must have subdirectories:
#       ${CTM_APPL} for coarse-grid inputs
#       ${FIN_APPL} for   fine-grid inputs and BCON outputs

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

# Set up primary environment variables for controlling MCIP:

setenv SINGULARITYENV_APPL              160702
setenv SINGULARITYENV_CoordName         LamCon_40N_97W 
setenv SINGULARITYENV_GridName          2016_12SE1
setenv SINGULARITYENV_MCIP_START        2016-07-02-00:00:00.0000  # [UTC]
setenv SINGULARITYENV_MCIP_END          2016-07-03-00:00:00.0000  # [UTC]
setenv SINGULARITYENV_INTVL             60 # [min]
setenv SINGULARITYENV_BTRIM              0
setenv SINGULARITYENV_WRF_LC_REF_LAT    40.0

# Set up additional environment variables, if needed.
# These variables (and their default values) are:
#
# setenv SINGULARITYENV_LPV        0
# setenv SINGULARITYENV_LWOUT      0
# setenv SINGULARITYENV_LUVBOUT    1
# setenv SINGULARITYENV_IfGeo     "F"
# setenv SINGULARITYENV_IOFORM     1
# setenv SINGULARITYENV_X0        13
# setenv SINGULARITYENV_Y0        94
# setenv SINGULARITYENV_NCOLS     89
# setenv SINGULARITYENV_NROWS    104
# setenv SINGULARITYENV_LPRT_COL   0
# setenv SINGULARITYENV_LPRT_ROW   0

singularity exec \
 --bind ${HOSTDATA}:/opt/CMAQ_${CMAQ_VRSN}/data ${extradirs} \
 ${CONTAINER} /opt/CMAQ_${CMAQ_VRSN}/scripts/run_mcip.csh

if ( ${err_status} != 0 ) then
    echo ""
    echo "****************************************************************"
    echo "** Error for /opt/CMAQ_${CMAQ_VRSN}/scripts/run_mcip.csh              **"
    echo "**    STATUS=${err_status}                                    **"
    echo "****************************************************************"
endif

exit( ${err_status} )

