#!/bin/csh -f
#SBATCH -p general -N 1 -n 1 -t 02:00:00
#
# Version @(#)$Id$
# Path    $Source$
# Date    $Date$
#
# This script sets up needed environment variables for processing area source
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

set extradirs = ''
# set extradirs = '=B /foo'

## Set Assigns file basename
setenv SINGULARITYENV_ASSIGNS_FILE ASSIGNS.nctox.cmaq.cb05_soa.us12-nc

## Set source category
setenv SINGULARITYENV_SMK_SOURCE    A          # source category to process
setenv SINGULARITYENV_MRG_SOURCE    A          # source category to merge

## Set programs to run...

## Time-independent programs
setenv SINGULARITYENV_RUN_SMKINVEN  Y          # run inventory import program
setenv SINGULARITYENV_RUN_SPCMAT    Y          # run speciation matrix program
setenv SINGULARITYENV_RUN_GRDMAT    Y          # run gridding matrix program

## Time-dependent programs
setenv SINGULARITYENV_RUN_TEMPORAL  Y          # run temporal allocation program
setenv SINGULARITYENV_RUN_SMKMERGE  Y          # run merge program

## Quality assurance
setenv SINGULARITYENV_RUN_SMKREPORT Y          # run emissions reporting program

## Program-specific controls...

## For Smkinven
setenv SINGULARITYENV_FILL_ANNUAL          N   # Y fills annual data with average-day data
setenv SINGULARITYENV_IMPORT_GRDIOAPI_YN   N   # Y imports gridded I/O API NetCDF inventory data
setenv SINGULARITYENV_RAW_DUP_CHECK        N   # Y checks for duplicate records
setenv SINGULARITYENV_SMK_ARTOPNT_YN       N   # Y uses the ARTOPNT file to assign coordinates
setenv SINGULARITYENV_SMK_BASEYR_OVERRIDE  0   # year to override the base year of the inventory
setenv SINGULARITYENV_SMK_DEFAULT_TZONE    5   # default time zone for sources not in the COSTCY file
setenv SINGULARITYENV_SMK_NHAPEXCLUDE_YN   N   # Y uses NHAPEXCLUDE file when integrating toxic sources
setenv SINGULARITYENV_SMKINVEN_FORMULA     "EXH__PMC=EXH__PM10-EXH__PM2_5" # formula for computing emissions value
setenv SINGULARITYENV_WEST_HSPHERE         Y   # Y converts longitudes to negative values
setenv SINGULARITYENV_WKDAY_NORMALIZE      N   # Y treats average-day emissions as weekday only
setenv SINGULARITYENV_WRITE_ANN_ZERO       N   # Y writes zero emission values to intermediate inventory
setenv SINGULARITYENV_ALLOW_NEGATIVE       N   # Y allow negative output emission data
#      INVNAME1         set by make_invdir.csh script
#      INVNAME2         set by make_invdir.csh scripts
#      OUTZONE          see "Multiple-program controls" below
#      SMK_MAXERROR     see "Multiple-program controls" below
#      SMK_MAXWARNING   see "Multiple-program controls" below
#      SMK_TMPDIR       set by assigns/set_dirs.scr script

## For Grdmat
setenv SINGULARITYENV_SMK_USE_FALLBACK     Y   # Y use fallback surrogate code
setenv SINGULARITYENV_SMK_DEFAULT_SRGID    100 # surrogate code number to use as fallback
#      IOAPI_ISPH       set by Assigns file
#      REPORT_DEFAULTS  see "Multiple-program controls" below

## For Spcmat
setenv SINGULARITYENV_POLLUTANT_CONVERSION Y   # Y uses the GSCNV pollutant conversion file
#      REPORT_DEFAULTS  see "Multiple-program controls" below

## For Temporal
setenv SINGULARITYENV_RENORM_TPROF         Y   # Y normalizes the temporal profiles
setenv SINGULARITYENV_UNIFORM_TPROF_YN     N   # Y uses uniform temporal profiles for all sources
setenv SINGULARITYENV_ZONE4WM              Y   # Y applies temporal profiles using time zones
#      OUTZONE          see "Multiple-program controls" below
#      REPORT_DEFAULTS  see "Multiple-program controls" below
#      SMK_AVEDAY_YN    see "Multiple-program controls" below
#      SMK_MAXERROR     see "Multiple-program controls" below
#      SMK_MAXWARNING   see "Multiple-program controls" below

## For Smkmerge
setenv SINGULARITYENV_MRG_SPCMAT_YN        Y   # Y produces speciated output 
setenv SINGULARITYENV_MRG_TEMPORAL_YN      Y   # Y produces temporally allocated output
setenv SINGULARITYENV_MRG_GRDOUT_YN        Y   # Y produces a gridded output file
setenv SINGULARITYENV_MRG_REPCNY_YN        Y   # Y produces a report of emission totals by county
setenv SINGULARITYENV_MRG_REPSTA_YN        Y   # Y produces a report of emission totals by state
setenv SINGULARITYENV_MRG_GRDOUT_UNIT      moles/s   # units for the gridded output file
setenv SINGULARITYENV_MRG_TOTOUT_UNIT      moles/day # units for the state and county reports
setenv SINGULARITYENV_SMK_REPORT_TIME      230000    # hour for reporting daily emissions
#      SMK_AVEDAY_YN    see "Multiple-program controls" below

## For Smkreport
setenv SINGULARITYENV_REPORT_ZERO_VALUES   N   # Y outputs entries with all zero values

## Multiple-program controls
setenv SINGULARITYENV_OUTZONE              0   # time zone of output emissions
setenv SINGULARITYENV_REPORT_DEFAULTS      N   # Y reports sources that use default cross-reference
setenv SINGULARITYENV_SMK_AVEDAY_YN        Y   # Y uses average-day emissions instead of annual emissions
setenv SINGULARITYENV_SMK_MAXERROR         100 # maximum number of error messages in log file
setenv SINGULARITYENV_SMK_MAXWARNING       100 # maximum number of warning messages in log file

## Script settings
setenv SINGULARITYENV_SRCABBR         nonroad  # abbreviation for naming log files
setenv SINGULARITYENV_NONROAD              Y   # Y uses nonroad files
setenv SINGULARITYENV_QA_TYPE              all # type of QA to perform [none, all, part1, part2, or custom]
setenv SINGULARITYENV_PROMPTFLAG           N   # Y prompts for user input
setenv SINGULARITYENV_AUTO_DELETE          Y   # Y automatically deletes I/O API NetCDF output files
setenv SINGULARITYENV_AUTO_DELETE_LOG      Y   # Y automatically deletes log files
setenv SINGULARITYENV_DEBUGMODE            N   # Y runs program in debugger
setenv SINGULARITYENV_DEBUG_EXE            idb # debugger to use when DEBUGMODE = Y

## Assigns file override settings
# setenv SINGULARITYENV_SPC_OVERRIDE  cmaq.cb4p25  # chemical mechanism override
# setenv SINGULARITYENV_YEAR_OVERRIDE              # base year override
# setenv SINGULARITYENV_INVTABLE_OVERRIDE          # inventory table override

##############################################################################

## Run Smkinven, Spcmat, and Grdmat
#
setenv SINGULARITYENV_RUN_PART1 Y


singularity exec \
   --bind ${HOSTDATA}:/opt/SMOKE/data ${extradirs} \
   ${CONTAINER}  /opt/SMOKE/scripts/run/smk_run.csh     # Run programs
set exitstat = $status
if ( $exitstat != 0 ) then
    echo "ERROR in  smk_run.csh:  STATUS=$exitstat"
    exit( $exitstat )
endif

if ( $?DEBUGMODE )  exit( 999 )

singularity exec \
   --bind ${HOSTDATA}:/opt/SMOKE/data ${extradirs} \
   ${CONTAINER}  /opt/SMOKE/scripts/run/qa_run.csh      # Run QA for part 2
set exitstat = $status
if ( $exitstat != 0 ) then
    echo "ERROR in  qa_run.csh:  STATUS=$exitstat"
    exit( $exitstat )
endif

setenv SINGULARITYENV_RUN_PART1 N

## Loop through days to run Temporal and Smkmerge
#
setenv SINGULARITYENV_RUN_PART2 Y
setenv SINGULARITYENV_RUN_PART4 Y

set cnt = 0
set g_stdate_sav = $G_STDATE
while ( $cnt < $EPI_NDAY )

    @ cnt = $cnt + $NDAYS

    singularity exec \
       --bind ${HOSTDATA}:/opt/SMOKE/data ${extradirs} \
       ${CONTAINER}  /opt/SMOKE/scripts/run/smk_run.csh     # Run programs
    set exitstat = $status
    if ( $exitstat != 0 ) then
        echo "ERROR in  smk_run.csh:  STATUS=$exitstat"
        exit( $exitstat )
    endif
    
    if ( $?DEBUGMODE )  exit( 999 )

    singularity exec \
       --bind ${HOSTDATA}:/opt/SMOKE/data ${extradirs} \
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

#
## Ending of script
#
exit( 0 )
