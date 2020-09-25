#! /bin/csh -f
#SBATCH -p general -N 1 -n 1 -t 02:00:00

# This script sets up environment variables and runs the Metmoves utility 
# Metmoves processes meteorology files preprocessed by Metcombine utility
# to create custom met files needed by MOVES Driver Scripts and SMOKE-Movesmrg. 
#
# This script assumes that the meteorology files are preprocessed and named with
# the following convention:
#
#     METCOMBO_<YYYYDDD>
#     METCOMBO_<YYYYDDD>
#
# Script created by B.H. Baek, CEMPD (9/20/2011)
#
# Adapted by C. COATS, UNC IE, for using Singularity to run on the 
#   CMAQ Singularity container on "longleaf" or "dogwood", which do not
#   allow Singularity on login-nodes
#*****************************************************************************

#   Singularity host variables.
#   For debug, change "unsetenv" to "setenv" and set the "SINGUILARITY_ENV_RUN..." 
#   flags below to run the desired model-component only.

set HOSTDATA  = /work/SCRATCH/SMOKE_Benchmark
set CONTAINER = /work/cmaq.simg

unsetenv SINGULARITYENV_DEBUGMODE

set extradirs = ''
# set extradirs = '=B /foo'

## Set Assigns file basename
setenv SINGULARITYENV_ASSIGNS_FILE ASSIGNS.nctox.cmaq.cb05_soa.us12-nc

# Configuration variables:
# list of surrogates to retrieve a list of counties
# chosen temperature variable name
# Define the modeling period

if ( ! $?SRG_LIST  ) setenv SRG_LIST  "100, 240"          
if ( ! $?SRCABBR   ) setenv SRCABBR   rateperprofile 
if ( ! $?TVARNAME  ) setenv TVARNAME          TEMP2       # chosen temperature variable name
if ( ! $?STDATE    ) setenv STDATE 2005182                # Starting date in Julian
if ( ! $?ENDATE    ) setenv ENDATE 2005213                # Ending date in Julian 


# Define output file names for MOVES and SMOKE models
setenv SMOKE_OUTFILE $METDAT/SMOKE_${GRID}_${STDATE}-${ENDATE}.txt
setenv MOVES_OUTFILE $METDAT/MOVES_${GRID}_${STDATE}-${ENDATE}.txt


singularity exec \
   --bind ${HOSTDATA}:/opt/SMOKE/data ${extradirs} \
   ${CONTAINER}  /opt/SMOKE/scripts/run/smk_met4moves_nctox.csh     # Run programs
set exitstat = $status
if ( $exitstat != 0 ) then
    echo "ERROR in  smk_met4moves_nctox.csh:  STATUS=$exitstat"
endif

exit( $exitstat )
