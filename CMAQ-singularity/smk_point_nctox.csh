#!/bin/csh -f
#SBATCH -p general -N 1 -n 1 -t 02:00:00
#
# Version @(#)$Id$
# Path    $Source$
# Date    $Date$
#
# This script sets up needed environment variables for processing point source
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
setenv SINGULARITYENV_SMK_SOURCE    P          # source category to process
setenv SINGULARITYENV_MRG_SOURCE    P          # source category to merge

## Set programs to run...

## Time-independent programs
setenv SINGULARITYENV_RUN_SMKINVEN  Y          # run inventory import program
setenv SINGULARITYENV_RUN_SPCMAT    Y          # run speciation matrix program
setenv SINGULARITYENV_RUN_GRDMAT    Y          # run gridding matrix program

## Time-dependent programs
setenv SINGULARITYENV_RUN_TEMPORAL  Y          # run temporal allocation program
setenv SINGULARITYENV_RUN_ELEVPOINT Y          # run elevated/PinG sources selection program
setenv SINGULARITYENV_RUN_LAYPOINT  N          # run layer fractions program
setenv SINGULARITYENV_RUN_SMKMERGE  Y          # run merge program

## Quality assurance
setenv SINGULARITYENV_RUN_SMKREPORT Y          # run emissions reporting program

## Program-specific controls...

## For Smkinven
setenv SINGULARITYENV_CHECK_STACKS_YN      Y   # Y checks if stack parameters are missing or invalid
setenv SINGULARITYENV_FILL_ANNUAL          N   # Y fills annual data with average-day data
setenv SINGULARITYENV_FLOW_RATE_FACTOR     15878 # factor to calculate hourly flow rates from CEM data
setenv SINGULARITYENV_HOURLY_TO_DAILY      N   # Y treats hour-specific input as day-specific data
setenv SINGULARITYENV_HOURLY_TO_PROFILE    N   # Y treats hour-specific input as hour-specific temporal profiles
setenv SINGULARITYENV_IMPORT_AVEINV_YN     Y   # Y imports annual inventory data
setenv SINGULARITYENV_RAW_DUP_CHECK        N   # Y checks for duplicate records
setenv SINGULARITYENV_SMK_BASEYR_OVERRIDE  0   # year to override the base year of the inventory
setenv SINGULARITYENV_SMK_DEFAULT_TZONE    5   # default time zone for sources not in the COSTCY file
setenv SINGULARITYENV_SMK_NHAPEXCLUDE_YN   N   # Y uses NHAPEXCLUDE file when integrating toxic sources
setenv SINGULARITYENV_NONHAP_TYPE          TOG # VOC or TOG for nonhap calculation 
setenv SINGULARITYENV_SMKINVEN_FORMULA     "PMC=PM10-PM2_5" # formula for computing emissions value
setenv SINGULARITYENV_WEST_HSPHERE         Y   # Y converts longitudes to negative values
setenv SINGULARITYENV_WKDAY_NORMALIZE      N   # Y treats average-day emissions as weekday only
setenv SINGULARITYENV_WRITE_ANN_ZERO       N   # Y writes zero emission values to intermediate inventory
setenv SINGULARITYENV_ALLOW_NEGATIVE       N   # Y allow negative output emission data
#      DAY_SPECIFIC_YN  see "Multiple-program controls" below
#      HOUR_SPECIFIC_YN see "Multiple-program controls" below
#      INVNAME1         set by make_invdir.csh script
#      INVNAME2         set by make_invdir.csh scripts
#      OUTZONE          see "Multiple-program controls" below
#      SMK_MAXERROR     see "Multiple-program controls" below
#      SMK_MAXWARNING   see "Multiple-program controls" below
#      SMK_TMPDIR       set by assigns/set_dirs.scr script
#      VELOC_RECALC     see "Multiple-program controls" below

## For Grdmat
#      IOAPI_ISPH       set by Assigns file

## For Spcmat
setenv SINGULARITYENV_POLLUTANT_CONVERSION Y   # Y uses the GSCNV pollutant conversion file
#      REPORT_DEFAULTS  see "Multiple-program controls" below

## For Elevpoint
setenv SINGULARITYENV_SMK_ELEV_METHOD      2   # 2 uses PELVCONFIG file to determine elevated sources for CMAQ inline processing
#      IOAPI_ISPH       set by Assigns file
#      SMK_PING_METHOD  see "Multiple-program controls" below

## For Temporal
setenv SINGULARITYENV_RENORM_TPROF         Y   # Y normalizes the temporal profiles
setenv SINGULARITYENV_UNIFORM_TPROF_YN     N   # Y uses uniform temporal profiles for all sources
setenv SINGULARITYENV_ZONE4WM              Y   # Y applies temporal profiles using time zones
#      DAY_SPECIFIC_YN  see "Multiple-program controls" below
#      HOUR_SPECIFIC_YN see "Multiple-program controls" below
#      OUTZONE          see "Multiple-program controls" below
#      REPORT_DEFAULTS  see "Multiple-program controls" below
#      SMK_AVEDAY_YN    see "Multiple-program controls" below
#      SMK_MAXERROR     see "Multiple-program controls" below
#      SMK_MAXWARNING   see "Multiple-program controls" below

# For Laypoint
setenv SINGULARITYENV_FIRE_AREA            0.  # daily area burned; only needed when processing fires
setenv SINGULARITYENV_FIRE_HFLUX           0.  # hourly heat flux; only needed when processing fires
setenv SINGULARITYENV_FIRE_PLUME_YN        N   # Y uses fire-specific plume rise calculations
setenv SINGULARITYENV_HOUR_PLUMEDATA_YN    N   # Y reads hourly plume rise data from the PHOUR file
setenv SINGULARITYENV_HOURLY_FIRE_YN       N   # Y reads fire data from the PTMP and PDAY files
setenv SINGULARITYENV_REP_LAYER_MAX        -1  # layer number for reporting high plume rise
setenv SINGULARITYENV_SMK_SPECELEV_YN      Y   # Y uses the PELV file to set elevated sources
setenv SINGULARITYENV_VERTICAL_SPREAD      0   # sets the vertical spread method for plume heights
setenv SINGULARITYENV_USE_EDMS_DATA_YN     N   # Y treat EDMS aircraft elevation height as plume rise
setenv SINGULARITYENV_PLUME_GTEMP_NAME  TEMP1P5 # Ground temp. variable name for plume rise computation. 
#      EXPLICIT_PLUMES_YN see "Multiple-program controls" below
#      IOAPI_ISPH       set by Assigns file
#      SMK_EMLAYS       see "Multiple-program controls" below
#      VELOC_RECALC     see "Multiple-program controls" below

## For Smkmerge
setenv SINGULARITYENV_MRG_LAYERS_YN        N   # Y produces layered output
setenv SINGULARITYENV_MRG_SPCMAT_YN        Y   # Y produces speciated output 
setenv SINGULARITYENV_MRG_TEMPORAL_YN      Y   # Y produces temporally allocated output
setenv SINGULARITYENV_MRG_GRDOUT_YN        Y   # Y produces a gridded output file
setenv SINGULARITYENV_MRG_REPCNY_YN        Y   # Y produces a report of emission totals by county
setenv SINGULARITYENV_MRG_REPSTA_YN        Y   # Y produces a report of emission totals by state
setenv SINGULARITYENV_MRG_GRDOUT_UNIT      moles/s   # units for the gridded output file
setenv SINGULARITYENV_MRG_TOTOUT_UNIT      moles/day # units for the state and county reports
setenv SINGULARITYENV_SMK_ASCIIELEV_YN     N   # Y creates an ASCII elevated point sources file
setenv SINGULARITYENV_SMK_REPORT_TIME      230000    # hour for reporting daily emissions
#      EXPLICIT_PLUMES_YN see "Multiple-program controls" below
#      SMK_AVEDAY_YN    see "Multiple-program controls" below
#      SMK_EMLAYS       see "Multiple-program controls" below
#      SMK_PING_METHOD  see "Multiple-program controls" below

## For Smkreport
setenv SINGULARITYENV_REPORT_ZERO_VALUES   N   # Y outputs entries with all zero values

# Multiple-program controls
setenv SINGULARITYENV_DAY_SPECIFIC_YN      N   # Y imports and uses day-specific inventory data
setenv SINGULARITYENV_EXPLICIT_PLUME_YN    N   # Y processes only sources using explicit plume rise
setenv SINGULARITYENV_HOUR_SPECIFIC_YN     N   # Y imports and uses hour-specific inventory data
setenv SINGULARITYENV_OUTZONE              0   # time zone of output emissions
setenv SINGULARITYENV_REPORT_DEFAULTS      N   # Y reports sources that use default cross-reference
setenv SINGULARITYENV_SMK_EMLAYS           12  # number of emissions layers
setenv SINGULARITYENV_SMK_AVEDAY_YN        N   # Y uses average-day emissions instead of annual emissions
setenv SINGULARITYENV_SMK_MAXERROR         100 # maximum number of error messages in log file
setenv SINGULARITYENV_SMK_MAXWARNING       100 # maximum number of warning messages in log file
setenv SINGULARITYENV_SMK_PING_METHOD      1   # 1 processes and outputs PinG sources
setenv SINGULARITYENV_VELOC_RECALC         N   # Y recalculates stack velocity using flow and diameter

## Script settings
setenv SINGULARITYENV_SRCABBR           point  # abbreviation for naming log files
setenv SINGULARITYENV_QA_TYPE             all  # type of QA to perform [none, all, part1, part2, or custom]
setenv SINGULARITYENV_PROMPTFLAG           N   # Y prompts for user input
setenv SINGULARITYENV_AUTO_DELETE          Y   # Y automatically deletes I/O API NetCDF output files
setenv SINGULARITYENV_AUTO_DELETE_LOG      Y   # Y automatically deletes log files
setenv SINGULARITYENV_DEBUGMODE            N   # Y runs program in debugger
setenv SINGULARITYENV_DEBUG_EXE            pgdbg # debugger to use when DEBUGMODE = Y

## Assigns file override settings
# setenv SINGULARITYENV_SPC_OVERRIDE  cmaq.cb4p25  # chemical mechanism override
# setenv SINGULARITYENV_YEAR_OVERRIDE              # base year override
# setenv SINGULARITYENV_INVTABLE_OVERRIDE          # inventory table override

##############################################################################

## Run Smkinven, Spcmat, and Grdmat
#
setenv SINGULARITYENV_RUN_PART1 Y

# Reset NHAPEXCLUDE file to exclude all sources
# This is needed for now because the stationary area criteria and non-point 
#    toxics inventories are not consistent and should not be integrated.
setenv SINGULARITYENV_NHAPEXCLUDE nhapexclude.all.txt


singularity exec \
   --bind ${HOSTDATA}:/opt/SMOKE/data \
   ${CONTAINER}  /opt/SMOKE/scripts/run/smk_run.csh     # Run programs
if ( $exitstat != 0 ) then
    echo "ERROR in  smk_run.csh:  STATUS=$exitstat"
    exit( $exitstat )
endif

if ( $?DEBUGMODE )  exit( 999 )

singularity exec \
   --bind ${HOSTDATA}:/opt/SMOKE/data \
   ${CONTAINER}  /opt/SMOKE/scripts/run/qa_run.csh      # Run QA for part 2
if ( $exitstat != 0 ) then
    echo "ERROR in  qa_run.csh:  STATUS=$exitstat"
    exit( $exitstat )
endif

setenv SINGULARITYENV_RUN_PART1 N

## Loop through days to run Temporal
#
setenv SINGULARITYENV_RUN_PART2 Y
set cnt = 0
set g_stdate_sav = $G_STDATE
while ( $cnt < $EPI_NDAY )

    @ cnt = $cnt + $NDAYS

    singularity exec \
       --bind ${HOSTDATA}:/opt/SMOKE/data \
       ${CONTAINER}  /opt/SMOKE/scripts/run/smk_run.csh     # Run programs
    if ( $exitstat != 0 ) then
        echo "ERROR in  smk_run.csh:  STATUS=$exitstat"
        exit( $exitstat )
    endif
    
    if ( $?DEBUGMODE )  exit( 999 )

    singularity exec \
       --bind ${HOSTDATA}:/opt/SMOKE/data \
       ${CONTAINER}  /opt/SMOKE/scripts/run/qa_run.csh      # Run QA for part 2
    if ( $exitstat != 0 ) then
        echo "ERROR in  qa_run.csh:  STATUS=$exitstat"
        exit( $exitstat )
    endif

    setenv SINGULARITYENV_G_STDATE_ADVANCE $cnt

end
setenv   SINGULARITYENV_RUN_PART2 N
unsetenv SINGULARITYENV_G_STDATE_ADVANCE

## Run Elevpoint
#
setenv SINGULARITYENV_RUN_PART3 Y
setenv SINGULARITYENV_G_STDATE  $g_stdate_sav
setenv SINGULARITYENV_ESDATE    `$IOAPIDIR/datshift $G_STDATE 0`
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

setenv SINGULARITYENV_RUN_PART3 N

## Loop through dats to run Laypoint and Smkmerge
setenv SINGULARITYENV_RUN_PART4 Y
set cnt = 0
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
setenv   SINGULARITYENV_RUN_PART4 N
unsetenv SINGULARITYENV_G_STDATE_ADVANCE

#
## Ending of script
#
exit( 0 )

