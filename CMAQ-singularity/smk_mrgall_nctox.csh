#!/bin/csh -f
#SBATCH -p general -N 1 -n 1 -t 02:00:00
#
# Version @(#)$Id$
# Path    $Source$
# Date    $Date$
#
# This script sets up needed environment variables for merging
# emissions in SMOKE and calls the scripts that run the SMOKE programs. 
#
# Script created by : M. Houyoux, CEP Environmental Modeling Center 
#
# Adapted by C. COATS, UNC IE, for using Singularity to run on the 
#   CMAQ Singularity container on "longleaf" or "dogwood", which do not
#   allow Singularity on login-nodes
#*********************************************************************

#   Singularity host variables.
#   For debug, change "unsetenv" to "setenv" and set the "SINGUILARITY_ENV_RUN..." 
#   flags below to run the desired model-component only.

set HOSTDATA  = /work/SCRATCH/SMOKE_Benchmark
set CONTAINER = /work/cmaq.simg

unsetenv SINGULARITYENV_DEBUGMODE

## Set Assigns file basename
setenv SINGULARITYENV_ASSIGNS_FILE ASSIGNS.nctox.cmaq.cb05_soa.us12-nc

## Set source category
setenv SINGULARITYENV_SMK_SOURCE    E          # source category to process

## Set programs to run...

## For merging from previously generated gridded Smkmerge outputs
setenv SINGULARITYENV_RUN_MRGGRID   Y          # run gridded file merge program
#      NOTE: in sample script, Mrggrid used to create merged model-ready CMAQ files

## Program-specific controls...

## For Mrggrid
setenv SINGULARITYENV_MRG_DIFF_DAYS        N   # Y allows data from different days to be merged
#      MRGFILES         see "Script settings" below

## Script settings
setenv SINGULARITYENV_MRGFILES "AGTS_L NGTS_L BGTS_L PGTS_L RPDGTS_L RPVGTS_L RPPGTS_L RPHGTS_L" # logical file names to merge
setenv SINGULARITYENV_MRGGRID_MOLE         Y   # Y outputs mole-based file, musy be consistent with MRGFILES
setenv SINGULARITYENV_SRCABBR              abmp # abbreviation for naming log files
setenv SINGULARITYENV_PROMPTFLAG           N   # Y prompts for user input
setenv SINGULARITYENV_SMK_MAXERROR         100 # maximum number of error messages in log file
setenv SINGULARITYENV_SMK_MAXWARNING       100 # maximum number of warning messages in log file
setenv SINGULARITYENV_AUTO_DELETE          Y   # Y automatically deletes I/O API NetCDF output files
setenv SINGULARITYENV_AUTO_DELETE_LOG      Y   # Y automatically deletes log files
##############################################################################

## Loop through days to run Smkmerge and Mrggrid
#
setenv SINGULARITYENV_RUN_PART2 Y
setenv SINGULARITYENV_RUN_PART4 Y

set cnt = 0
set g_stdate_sav = $G_STDATE
while ( $cnt < $EPI_NDAY )

    @ cnt = $cnt + $NDAYS

    singularity exec \
       --bind ${HOSTDATA}:/opt/SMOKE/data \
       ${CONTAINER}  /opt/SMOKE/scripts/run/smk_run.csh     # Run programs
    set exitstat = $status
    if ( $exitstat != 0 ) then
        echo "ERROR in  smk_run.csh:  STATUS=$exitstat"
        exit( $exitstat )
    endif
    
    if ( $?DEBUGMODE )  exit( 999 )

    singularity exec \
       --bind ${HOSTDATA}:/opt/SMOKE/data \
       ${CONTAINER}  /opt/SMOKE/scripts/run/qa_run.csh      # Run QA for part 2
    set exitstat = $status
    if ( $exitstat != 0 ) then
        echo "ERROR in  qa_run.csh:  STATUS=$exitstat"
        exit( $exitstat )
    endif

    setenv SINGULARITYENV_G_STDATE_ADVANCE $cnt

end
setenv SINGULARITYENV_RUN_PART2 N
setenv SINGULARITYENV_RUN_PART4 N
unsetenv SINGULARITYENV_G_STDATE_ADVANCE

#
## Ending of script
#
exit( 0 )
