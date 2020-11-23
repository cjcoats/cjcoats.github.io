#! /bin/csh -f
#SBATCH -p general -N 1 -n 1 -t 00:20:00
#
# ===================== Singularity "Run BLOCK_EXTRACT" Script ========================= 
# Script 6/2020  by C. COATS, UNC IE, for using Singularity to run on the 
#   CMAQ Singularity container on "longleaf" or "dogwood", which do not
#   allow Singularity on login-nodes
#*********************************************************************

#   Data directory on host:  mounts onto container-directory "/opt/CMAQ_${CMAQ_VRSN}/data"
#   must have subdirectories:
#       ${CRS_APPL} for conc-file and gridded met inputs
#       ${FIN_APPL} for bdy met-file inputs and BCON outputs

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

#   Set up environment variables to control "block_extract":
#       Note in particular that INFILES is an *array of basenames*
#       for input files, all of which should be  in directory
#       ${HOSTDATA)/${APPL}/POST

setenv SINGULARITYENV_APPL            2016_12SE1
setenv SINGULARITYENV_SPECLIST        "( O3 NO2 )"
setenv SINGULARITYENV_TIME_ZONE       GMT
setenv SINGULARITYENV_OUTFORMAT       IOAPI
setenv SINGULARITYENV_LOCOL           44
setenv SINGULARITYENV_HICOL           46
setenv SINGULARITYENV_LOROW           55
setenv SINGULARITYENV_HIROW           57
setenv SINGULARITYENV_LOLEV           1
setenv SINGULARITYENV_HILEV           1
setenv SINGULARITYENV_RUNID           "gcc_5.3.1_${APPL}"
setenv SINGULARITYENV_INFILES         "( COMBINE_ACONC_${RUNID}_201607.nc )"


singularity exec \
 --bind ${HOSTDATA}:/opt/CMAQ_${CMAQ_VRSN}/data ${extradirs} \
 ${CONTAINER} /opt/CMAQ_${CMAQ_VRSN}/scripts/run_block_extract.csh

if ( ${err_status} != 0 ) then
    echo ""
    echo "****************************************************************"
    echo "** Error for /opt/CMAQ_${CMAQ_VRSN}/scripts/run_block_extract.csh     **"
    echo "**    STATUS=${err_status}                                    **"
    echo "****************************************************************"
endif

exit( ${err_status} )

