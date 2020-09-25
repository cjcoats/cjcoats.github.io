#!/bin/csh -f
#SBATCH -p general -N 1 -n 1 -t 02:00:00
#
# Version @(#)$Id$
# Path    $Source$
# Date    $Date$
#
# This script sets up needed environment variables for processing biogenic source
# emissions in SMOKE using BEIS3 and calls the scripts that run the SMOKE programs. 
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
setenv SINGULARITYENV_SMK_SOURCE    B          # source category to process
setenv SINGULARITYENV_MRG_SOURCE    B          # source category to merge

setenv SINGULARITYENV_BEIS_VERSION  3.61       # version of BEIS3 to use (currently 3.14 or 3.60)

## Set programs to run...

## Time-independent programs
setenv SINGULARITYENV_RUN_NORMBEIS3 Y          # run normalized biogenic emissions program

## Time-dependent programs
setenv SINGULARITYENV_RUN_TMPBEIS3  Y          # run temporal adjustments and speciation program
setenv SINGULARITYENV_RUN_SMKMERGE  Y          # run merge program

## Program-specific controls...

## For Normbeis3
#      BEIS_VERSION     already set above

## For Tmpbeis3.60 and 3.14
setenv SINGULARITYENV_BG_CLOUD_TYPE        1     # method used to calculate PAR
setenv SINGULARITYENV_BIOG_SPRO            B10C5 # speciation profile code to use for biogenics
setenv SINGULARITYENV_BIOMET_SAME          Y     # Y indicates temperature and radiation data in same file
setenv SINGULARITYENV_BIOSW_YN             N     # Y uses BIOSEASON file to set winter or summer factors (for annual simulations)
setenv SINGULARITYENV_SUMMER_YN            Y     # Y assumes summer factors (for short episodic simulations)
setenv SINGULARITYENV_OUTZONE              0     # time zone of output emissions
setenv SINGULARITYENV_TMPR_VAR             TEMP2 # name of temperature variable
setenv SINGULARITYENV_PRES_VAR             PRSFC # name of surface pressure variable
setenv SINGULARITYENV_OUT_UNITS            2     # molar output units (1 = moles/hr, 2 = moles/s)
setenv SINGULARITYENV_PX_VERSION           Y     # Y indicates that met data is from PX version of MM5 or WRF
setenv SINGULARITYENV_SOILT_VAR            SOIT1 # name of soil temperature variable if using PX version
setenv SINGULARITYENV_ISLTYP_VAR           SLTYP # name of soil type variable if using PX version
setenv SINGULARITYENV_SOILM_VAR            SOIM1 # name of soil moisture variable if using PX version
setenv SINGULARITYENV_RN_VAR               RN    # name of non-convective rainfall variable
setenv SINGULARITYENV_RC_VAR               RC    # name of convective rainfall variable
setenv SINGULARITYENV_INITIAL_RUN          Y     # Y: running first day of scenario, N for subsequent days

## For BEIS3.60 only
setenv SINGULARITYENV_RGRND_VAR           RGRND  # solar radiation reaching the surface variable (WATTS/M**2)
setenv SINGULARITYENV_RADYNI_VAR          RADYNI # aerodynamic resistance variable     (s/m)
setenv SINGULARITYENV_LAI_VAR             LAI    # leaf area index variable from met model (non dimensional)
setenv SINGULARITYENV_Q2_VAR              Q2     # 2 meter water vapor mixing ratio variable  (kg/kg)
setenv SINGULARITYENV_RSTOMI_VAR          RSTOMI # inverse of the stomatal resistance variable (M/S)
setenv SINGULARITYENV_USTAR_VAR           USTAR  # surface friction velocity variable  (M/S)
setenv SINGULARITYENV_TEMPG_VAR           TEMPG  # skin temperature at ground variable (K)

## For BEIS3.14 only
setenv SINGULARITYENV_RAD_VAR              RGRND # name of radiation/cloud variable for BEI3.14 (see RGRND_VAR for BEIS 3.60)

## For Smkmerge
#      NOTE: Smkmerge run to create state and county emission total reports
setenv SINGULARITYENV_AREA_SURROGATE_NUM   340 # surrogate code number for land-area surrogate
setenv SINGULARITYENV_MRG_SPCMAT_YN        Y   # Y produces speciated output 
setenv SINGULARITYENV_MRG_TEMPORAL_YN      Y   # Y produces temporally allocated output
setenv SINGULARITYENV_MRG_GRDOUT_YN        Y   # Y produces a gridded output file
setenv SINGULARITYENV_MRG_REPCNY_YN        Y   # Y produces a report of emission totals by county
setenv SINGULARITYENV_MRG_REPSTA_YN        Y   # Y produces a report of emission totals by state
setenv SINGULARITYENV_MRG_GRDOUT_UNIT      tons/day # units for the gridded output file
setenv SINGULARITYENV_MRG_TOTOUT_UNIT      tons/day # units for the state and county reports
setenv SINGULARITYENV_SMK_REPORT_TIME      230000   # hour for reporting daily emissions

## Script settings
setenv SINGULARITYENV_SRCABBR              bg  # abbreviation for naming log files
setenv SINGULARITYENV_PROMPTFLAG           N   # Y prompts for user input
setenv SINGULARITYENV_AUTO_DELETE          Y   # Y automatically deletes I/O API NetCDF output files
setenv SINGULARITYENV_AUTO_DELETE_LOG      Y   # Y automatically deletes log files
setenv SINGULARITYENV_DEBUGMODE            N   # Y runs program in debugger
setenv SINGULARITYENV_DEBUG_EXE            pgdbg # debugger to use when DEBUGMODE = Y

## Assigns file override settings
# setenv SINGULARITYENV_SPC_OVERRIDE  cmaq.cb4p25  # chemical mechanism override
# setenv SINGULARITYENV_INVTABLE_OVERRIDE          # inventory table override

##############################################################################

## Run Normbeis3
#
setenv SINGULARITYENV_RUN_PART1 Y

# Reset NHAPEXCLUDE file to exclude all sources
# This is needed for now because the stationary area criteria and non-point 
#    toxics inventories are not consistent and should not be integrated.
setenv SINGULARITYENV_NHAPEXCLUDE nhapexclude.all.txt


singularity exec \
   --bind ${HOSTDATA}:/opt/SMOKE/data ${extradirs} \
   ${CONTAINER}  /opt/SMOKE/scripts/run/smk_run.csh     # Run programs
if ( $exitstat != 0 ) then
    echo "ERROR in  smk_run.csh:  STATUS=$exitstat"
    exit( $exitstat )
endif

if ( $?DEBUGMODE )  exit( 999 )

singularity exec \
   --bind ${HOSTDATA}:/opt/SMOKE/data ${extradirs} \
   ${CONTAINER}  /opt/SMOKE/scripts/run/qa_run.csh      # Run QA for part 2
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
#
## Ending of script
#
exit( 0 )
