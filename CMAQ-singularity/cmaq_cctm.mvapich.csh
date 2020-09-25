#!/bin/csh -f

#SBATCH -t 4:00:00
#SBATCH --mem=100000
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=8
#SBATCH -J CMAQ8
#SBATCH -p debug_queue
##SBATCH -p 528_queue
#SBATCH -o /proj/ie/apps/dogwood/singularity/LOGS/singularity-cctm.batch.Benchmark_2Day.8pe.log
#SBATCH -e /proj/ie/apps/dogwood/singularity/LOGS/singularity-cctm.batch.Benchmark_2Day.8pe.err

# ===================== Singularity "Run CCTM" Script ========================= 
# Script 6/2020  by C. COATS, UNC IE, for using Singularity to run on the 
#   CMAQ Singularity container on "longleaf" or "dogwood", which do not
#   allow Singularity on login-nodes
#*********************************************************************
#  HOST-CUSTOMIZATION VARIABLES:
#   Data directory on host:  mounts onto container-directory "/opt/CMAQ_REPO/data"
#   must have subdirectories:
#       ${CRS_APPL} for conc-file and gridded met inputs
#       ${FIN_APPL} for bdy met-file inputs and BCON outputs

set HOSTDATA  = /proj/ie/proj/staff/cjcoats/CMAQv5.3.1_Benchmark_2Day
set CONTAINER = /proj/ie/apps/dogwood/singularity/cmaq.sif


#*********************************************************************
#   For CMAQ-option control-variables such as CONC_SPCS, CTM_MAXSYNC, KZMIN, etc.,
#   you should follow the pattern below, which has the effect of doing a
#   "setenv FOO BAR" within the container-environment:
#
# setenv SINGULARITYENV_FOO  BAR
#
#   "Normal" run-control variables follow a similar pattern:
#
#   Set up environment for MPI-version (mpich, mvapich, or openmpi),
#   verbose-level and/or debug:

setenv   SINGULARITYENV_MPIVERSION    mvapich
unsetenv SINGULARITYENV_DEBUG
unsetenv SINGULARITYENV_EXEC

# setenv SINGULARITYENV_DEBUG   1
# setenv SINGULARITYENV_EXEC    <path to debug-executable>
# setenv SINGULARITYENV_NMLDIR  <path>                      #> directory for CMAQ namelist files
# setenv SINGULARITYENV_BLDDIR  <path to build-directory>   #> directory for CMAQ build

# extra directories to be mounted:

set extradirs = ''
if ( $? SINGULARITYENV_NMLDIR ) set extradirs = "${extra} -B ${SINGULARITYENV_NMLDIR}"
if ( $? SINGULARITYENV_BLDDIR ) set extradirs = "${extra} -B ${SINGULARITYENV_BLDDIR}"

setenv SINGULARITYENV_START_DATE    "2016-07-01"
setenv SINGULARITYENV_END_DATE      "2016-07-02"
setenv SINGULARITYENV_START_TIME    000000
setenv SINGULARITYENV_RUN_LENGTH    240000
setenv SINGULARITYENV_TIME_STEP      10000
setenv SINGULARITYENV_APPL          2016_12SE1
setenv SINGULARITYENV_EMIS          2016ff
setenv SINGULARITYENV_PROC          mpi
setenv SINGULARITYENV_NPCOL         4
setenv SINGULARITYENV_NPROW         8
setenv SINGULARITYENV_CTM_DIAG_LVL  0

#*********************************************************************
#  Additional CCTM options:
##########> Output Species and Layer Options
#    #> CONC file species; comment or set to "ALL" to write all species to CONC
#    setenv SINGULARITYENV_CONC_SPCS "O3 NO ANO3I ANO3J NO2 FORM ISOP NH3 ANH4I ANH4J ASO4I ASO4J"
#    setenv SINGULARITYENV_CONC_BLEV_ELEV " 1 1" #> CONC file layer range; comment to write all layers to CONC
# 
#    #> ACONC file species; comment or set to "ALL" to write all species to ACONC
#    #setenv SINGULARITYENV_AVG_CONC_SPCS "O3 NO CO NO2 ASO4I ASO4J NH3"
#    setenv SINGULARITYENV_AVG_CONC_SPCS "ALL"
#    setenv SINGULARITYENV_ACONC_BLEV_ELEV " 1 1" #> ACONC file layer range; comment to write all layers to ACONC
#    setenv SINGULARITYENV_AVG_FILE_ENDTIME N     #> override default beginning ACONC timestamp [ default: N ]
# 
##########> Synchronization Time Step and Tolerance Options
# setenv SINGULARITYENV_CTM_MAXSYNC 300       #> max sync time step (sec) [ default: 720 ]
# setenv SINGULARITYENV_CTM_MINSYNC  60       #> min sync time step (sec) [ default: 60 ]
# setenv SINGULARITYENV_SIGMA_SYNC_TOP 0.7    #> top sigma level thru which sync step determined [ default: 0.7 ]
# #setenv SINGULARITYENV_ADV_HDIV_LIM 0.95    #> maximum horiz. div. limit for adv step adjust [ default: 0.9 ]
# setenv SINGULARITYENV_CTM_ADV_CFL 0.95      #> max CFL [ default: 0.75]
# #setenv SINGULARITYENV_RB_ATOL 1.0E-09      #> global ROS3 solver absolute tolerance [ default: 1.0E-07 ]
# 
##########> Science Options
# setenv SINGULARITYENV_CTM_OCEAN_CHEM Y      #> Flag for ocean halgoen chemistry and sea spray aerosol emissions [ default: Y ]
# setenv SINGULARITYENV_CTM_WB_DUST N         #> use inline windblown dust emissions [ default: Y ]
# setenv SINGULARITYENV_CTM_WBDUST_BELD BELD3 #> landuse database for identifying dust source regions
#                                             #>    [ default: UNKNOWN ]; ignore if CTM_WB_DUST = N
# setenv SINGULARITYENV_CTM_LTNG_NO N         #> turn on lightning NOx [ default: N ]
# setenv SINGULARITYENV_KZMIN Y               #> use Min Kz option in edyintb [ default: Y ],
#                                             #>    otherwise revert to Kz0UT
# setenv SINGULARITYENV_CTM_MOSAIC N          #> landuse specific deposition velocities [ default: N ]
# setenv SINGULARITYENV_CTM_FST N             #> mosaic method to get land-use specific stomatal flux
#                                             #>    [ default: N ]
# setenv SINGULARITYENV_PX_VERSION Y          #> WRF PX LSM
# setenv SINGULARITYENV_CLM_VERSION N         #> WRF CLM LSM
# setenv SINGULARITYENV_NOAH_VERSION N        #> WRF NOAH LSM
# setenv SINGULARITYENV_CTM_ABFLUX Y          #> ammonia bi-directional flux for in-line deposition
#                                             #>    velocities [ default: N ]
# setenv SINGULARITYENV_CTM_BIDI_FERT_NH3 T   #> subtract fertilizer NH3 from emissions because it will be handled
#                                             #>    by the BiDi calculation [ default: Y ]
# setenv SINGULARITYENV_CTM_HGBIDI N          #> mercury bi-directional flux for in-line deposition
#                                             #>    velocities [ default: N ]
# setenv SINGULARITYENV_CTM_SFC_HONO Y        #> surface HONO interaction [ default: Y ]
# setenv SINGULARITYENV_CTM_GRAV_SETL Y       #> vdiff aerosol gravitational sedimentation [ default: Y ]
# setenv SINGULARITYENV_CTM_BIOGEMIS Y        #> calculate in-line biogenic emissions [ default: N ]
# 
##########> Vertical Extraction Options
# setenv SINGULARITYENV_VERTEXT N
# setenv SINGULARITYENV_VERTEXT_COORD_PATH ${WORKDIR}/lonlat.csv
# 
##########> I/O Controls
# setenv SINGULARITYENV_IOAPI_LOG_WRITE F     #> turn on excess WRITE3 logging [ options: T | F ]
# setenv SINGULARITYENV_FL_ERR_STOP N         #> stop on inconsistent input files
# setenv SINGULARITYENV_PROMPTFLAG F          #> turn on I/O-API PROMPT*FILE interactive mode [ options: T | F ]
# setenv SINGULARITYENV_IOAPI_OFFSET_64 YES   #> support large timestep records (>2GB/timestep record) [ options: YES | NO ]
# setenv SINGULARITYENV_IOAPI_CHECK_HEADERS N #> check file headers [ options: Y | N ]
# setenv SINGULARITYENV_CTM_EMISCHK N         #> Abort CMAQ if missing surrogates from emissions Input files
# setenv SINGULARITYENV_EMISDIAG F            #> Print Emission Rates at the output time step after they have been
#                                             #>   scaled and modified by the user Rules [options: F | T or 2D | 3D | 2DSUM ]
#                                             #>   Individual streams can be modified using the variables:
#                                             #>       GR_EMIS_DIAG_## | STK_EMIS_DIAG_## | BIOG_EMIS_DIAG
#                                             #>       MG_EMIS_DIAG    | LTNG_EMIS_DIAG   | DUST_EMIS_DIAG
#                                             #>       SEASPRAY_EMIS_DIAG
#                                             #>   Note that these diagnostics are different than other emissions diagnostic
#                                             #>   output because they occur after scaling.
# setenv SINGULARITYENV_EMISDIAG_SUM F        #> Print Sum of Emission Rates to Gridded Diagnostic File
# 
# setenv SINGULARITYENV_EMIS_SYM_DATE N       #> Master switch for allowing CMAQ to use the date from each Emission file
#                                             #>   rather than checking the emissions date against the internal model date.
#                                             #>   [options: T | F or Y | N]. If false (F/N), then the date from CMAQ's internal
#                                             #>   time will be used and an error check will be performed (recommended). Users
#                                             #>   may switch the behavior for individual emission files below using the variables:
#                                             #>       GR_EM_SYM_DATE_## | STK_EM_SYM_DATE_## [ default : N ]
##########> Diagnostic Output Flags
# setenv SINGULARITYENV_CTM_CKSUM Y           #> checksum report [ default: Y ]
# setenv SINGULARITYENV_CLD_DIAG N            #> cloud diagnostic file [ default: N ]
# 
# setenv SINGULARITYENV_CTM_PHOTDIAG N        #> photolysis diagnostic file [ default: N ]
# setenv SINGULARITYENV_NLAYS_PHOTDIAG "1"    #> Number of layers for PHOTDIAG2 and PHOTDIAG3 from
#                                             #>     Layer 1 to NLAYS_PHOTDIAG  [ default: all layers ]
# #setenv SINGULARITYENV_NWAVE_PHOTDIAG "294 303 310 316 333 381 607"  #> Wavelengths written for variables
#                                             #>   in PHOTDIAG2 and PHOTDIAG3
#                                             #>   [ default: all wavelengths ]
# 
# setenv SINGULARITYENV_CTM_PMDIAG N          #> Instantaneous Aerosol Diagnostic File [ default: Y ]
# setenv SINGULARITYENV_CTM_APMDIAG Y         #> Hourly-Average Aerosol Diagnostic File [ default: Y ]
# setenv SINGULARITYENV_APMDIAG_BLEV_ELEV "1 1"  #> layer range for average pmdiag = NLAYS
# 
# setenv SINGULARITYENV_CTM_SSEMDIAG N        #> sea-spray emissions diagnostic file [ default: N ]
# setenv SINGULARITYENV_CTM_DUSTEM_DIAG N     #> windblown dust emissions diagnostic file [ default: N ];
#                                             #>     Ignore if CTM_WB_DUST = N
# setenv SINGULARITYENV_CTM_DEPV_FILE N       #> deposition velocities diagnostic file [ default: N ]
# setenv SINGULARITYENV_VDIFF_DIAG_FILE N     #> vdiff & possibly aero grav. sedimentation diagnostic file [ default: N ]
# setenv SINGULARITYENV_LTNGDIAG N            #> lightning diagnostic file [ default: N ]
# setenv SINGULARITYENV_B3GTS_DIAG N          #> BEIS mass emissions diagnostic file [ default: N ]
# setenv SINGULARITYENV_CTM_WVEL Y            #> save derived vertical velocity component to conc
#                                             #>    file [ default: Y ]
#*********************************************************************

singularity exec \
 --bind ${HOSTDATA}:/opt/CMAQ_REPO/data ${extradirs} \
 ${CONTAINER} /opt/CMAQ_REPO/scripts/run_cctm.csh
 
set err_status = ${status}

if ( ${err_status} != 0 ) then
    echo ""
    echo "****************************************************************"
    echo "** Error for /opt/CMAQ_REPO/scripts/run_cctm.csh              **"
    echo "**    STATUS=${err_status}                                    **"
    echo "****************************************************************"
endif

exit( ${err_status} )

