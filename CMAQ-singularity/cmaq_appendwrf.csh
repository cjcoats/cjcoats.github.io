#! /bin/csh -f
#SBATCH -p general -N 1 -n 1 -t 00:20:00
#
# ===================== Singularity "Run appendwrf" Script ========================= 
# Script 6/2020  by C. COATS, UNC IE, for using Singularity to run on the 
#   CMAQ Singularity container on "longleaf" or "dogwood", which do not
#   allow Singularity on login-nodes
#*********************************************************************

#   Data directory on host:  mounts onto container-directory "/opt/CMAQ_REPO/data"

set HOSTDATA  = /work/SCRATCH/CMAQv5.3.1_Benchmark_2Day
set CONTAINER = /work/cmaq.simg

set extradirs = ''
# set extradirs = '-B /foo'

# Set up environment for verbose-level and/or debug:

setenv SINGULARITYENV_CTM_DIAG_LVL  0

unsetenv SINGULARITYENV_DEBUG
unsetenv SINGULARITYENV_EXEC

# setenv SINGULARITYENV_DEBUG   1
# setenv SINGULARITYENV_EXEC    <path to debug-executable>

# Set up environment variables, below.
#  Set up basenames for the input files.  Since we will be using the
#  already-established directory-structure on the container, we do not
#  need the directory-part, just the basename, i.e., the part _after_
#  the directory:

setenv SINGULARITYENV_INFILE1  <basename>
setenv SINGULARITYENV_INFILE2  <basename>
setenv SINGULARITYENV_INFILE3  <basename>

setenv SINGULARITYENV_OUTFILE  <basename>

singularity exec \
 --bind ${HOSTDATA}:/opt/CMAQ_REPO/data ${extradirs} \
 ${CONTAINER} /opt/CMAQ_REPO/scripts/run_appendwrf.csh

if ( ${err_status} != 0 ) then
    echo ""
    echo "****************************************************************"
    echo "** Error for /opt/CMAQ_REPO/scripts/run_appendwrf.csh         **"
    echo "**    STATUS=${err_status}                                    **"
    echo "****************************************************************"
endif

exit( ${err_status} )

