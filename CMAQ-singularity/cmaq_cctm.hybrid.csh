#!/bin/csh -f

#SBATCH -t 4:00:00
#SBATCH --mem=10000
#SBATCH --nodes=8
#SBATCH --ntasks-per-node=8
#SBATCH -J HYB8
#SBATCH -p debug_queue
##SBATCH -p 528_queue
##SBATCH --exclusive
#SBATCH -o /proj/ie/apps/dogwood/singularity/Scripts/Logs-dogwood-64/cctm.mvapich.hybrid.2016_12SE1.log
#SBATCH -e /proj/ie/apps/dogwood/singularity/Scripts/Logs-dogwood-64/cctm.mvapich.hybrid.2016_12SE1.err

# ===================== Singularity "Run CCTM in hybrid mode" Script ===========
# Script 2/2021  by C. COATS, UNC IE, for using Singularity to run on the
#   CMAQ CCTM from Singularity container in "brute-force hybrid" mode
#   on "longleaf" or "dogwood", which do not allow Singularity on login-nodes
#*******************************************************************************
# NOTE:
#   shell-variables ("set foo = ...") are used by this script, on the host.
#   SINGULARITYENV_ environment variables ("setenv SINGULARITYENV_foo ...")
#   are used to generate matching environment variables on the container.
#
#   Environment variables and user-set run-control variables are in ALL CAPS;
#   following UNIX conventions, other shell variables are in lower case.
#*******************************************************************************
#  HOST-CUSTOMIZATION VARIABLES:
#   host-path CONTAINER to container
#   host-directory hostdirs for DATA on host:  mounts onto container-directory "/opt/CMAQ_${CMAQ_VRSN}/data"
#   Specify MPI-version MPIVERSION (mpich, mvapich, or openmpi)
#   Host-directory CMAQ_HOME for script etc.
#   Host-directory CMAQ_DATA for input and output data for run
#>  Toggle Diagnostic Mode CTM_VERBOSE which will print verbose information
#>  to standard output:  ==0:  no extra diagnostics,
#                        ==1:  echo environment; 
#                        ==2:  full echo
#   Enable debugging if DEBUG defined
#   container-path EXEC for executable

set bar = '-=-=--=-=-=-=--=-=-=-=--=-=-=-=--=-=-=-=--=-=-=-=--=-=-=-=--=-=-=-=-=-=-'

set CONTAINER   = /proj/ie/apps/dogwood/singularity/cmaq.sif
set MPIVERSION  = mvapich
set CMAQ_HOME   = /proj/ie/proj/staff/cjcoats/work
set CMAQ_DATA   = /proj/ie/proj/staff/cjcoats/CMAQv5.3.1_Benchmark_2Day/2016_12SE1
set CTM_VERBOSE = 0
set CMAQ_VRSN   = 532           #  or 532_ISAM or 532_DDM3D

# set DEBUG     = 1
# set EXEC      = <container-path to user-supplied executable>
# set NMLPATH   = <container-path for CMAQ namelist files>

unset DEBUG
unset EXEC

if ( ! $?EXEC ) then

    if ( $?DEBUG ) then
        set compiler = gccdbg
    else
        set compiler = gcc
    endif

    switch ( ${MPIVERSION} )    # BLD-directory on container:
        case mvapich*:
            set bld = /opt/CMAQ_${CMAQ_VRSN}/CCTM/scripts/BLD_CCTM_v${CMAQ_VRSN}_${compiler}-mvapich2
            breaksw
        case mpich*:
            set bld = /opt/CMAQ_${CMAQ_VRSN}/CCTM/scripts/BLD_CCTM_v${CMAQ_VRSN}_${compiler}-mpich3
            breaksw
        case openmpi*:
            set bld = /opt/CMAQ_${CMAQ_VRSN}/CCTM/scripts/BLD_CCTM_v${CMAQ_VRSN}_${compiler}-openmpi
            breaksw
        default:
            echo ${bar}
            echo "ERROR:  MPIVERSION = ${MPIVERSION} not supported"
            exit( 2 )
    endsw

    set EXEC = ${bld}/CCTM_v${CMAQ_VRSN}.exe

else

    set bld = `dirname ${EXEC}`     # for namelists, etc.

endif

if ( $CTM_VERBOSE == 2 ) set echo

# =====================================================================
#> CCTM Configuration Options
# =====================================================================
#> Set General Prameters for Configuring the Simulation
#> Define RUNID as any combination of parameters above or others. By default,
#> this information will be collected into this one string, $RUNID, for easy
#> referencing in output binaries and log files as well as in other scripts.

set MECH         = cb6r3_ae7_aq
set PROC         = mpi
set APPL         = 2016_12SE1
set EMIS         = 2016ff

set START_DATE   = "2016-07-01"
set END_DATE     = "2016-07-02"
set START_TIME   = 000000
set RUN_LENGTH   = 240000
set TIME_STEP    =  10000
set GRID_NAME    = 2016_12SE1           #> check GRIDDESC file for GRID_NAME options
set CLOBBER_DATA = TRUE                 #> Keep or Delete Existing Output Files
set NEW_START    =  TRUE
set RUNID        = ${CMAQ_VRSN}_gcc_${END_DATE}

#> Set Working, Input, and Output Directories

set rundir = ${CMAQ_HOME}/CCTM/scripts           #> host-Directory for run-script, etc.
set outdir = ${CMAQ_DATA}/output/CCTM_${APPL}    #> host-Directory for output
set inpdir = ${CMAQ_DATA}                        #> host-Directory for input
set logdir = ${CMAQ_HOME}                        #> host-Directory for logs

# set NMLPATH to container-path for namelists if you're not using the default
# from the CCTM-build directory:
# set NMLPATH = ...
if ( ! $?NMLPATH ) set NMLPATH = ${bld}          #> container-directory for Namelists.

set hostdirs = "-B ${CMAQ_DATA},${CMAQ_HOME},${rundir}"    # = "${CMAQ_DATA},${CMAQ_HOME},${rundir},${NMLPATH}" for non-${bld} NMLPATH

# =====================================================================
#> Input Directories and Filenames
# =====================================================================

set ICpath    = ${inpdir}/icbc                  #> initial conditions input directory
set BCpath    = ${inpdir}/icbc                  #> boundary conditions input directory
set EMISpath  = ${inpdir}/emis/gridded_area/gridded     #> gridded emissions input directory
set IN_PTpath = ${inpdir}/emis/inln_point       #> point source emissions input directory
set IN_LTpath = ${inpdir}/lightning             #> lightning NOx input directory
set METpath   = ${inpdir}/met/mcip              #> meteorology input directory
#set JVALpath = ${inpdir}/jproc                 #> offline photolysis rate table directory
set LUpath    = ${inpdir}/land                  #> BELD landuse data for windblown dust model
set SZpath    = ${inpdir}/land                  #> surf zone file for in-line seaspray emissions
set OMIpath   = ${NMLPATH}                      #> ozone column data for the photolysis model

if ( ! -d ${logdir} ) mkdir -p ${logdir}
if ( ! -d ${outdir} ) mkdir -p ${outdir}

echo ""
echo "Working   Directory is $rundir"
echo "Build     Directory is $bld"
echo "Output    Directory is $outdir"
echo "Namnelist Directory is NMLPATH"
echo "Log       Directory is ${logdir}"
echo "Starting date       is $START_DATE"
echo "Ending date         is $END_DATE"
echo "Executable Name     is ${EXEC}"

singularity exec echo "Executable Name   is ${EXEC}"

#> Print attributes of the executable
if ( $CTM_VERBOSE != 0 ) then
    singularity exec ${CONTAINER} ls -l ${EXEC}
    singularity exec ${CONTAINER} size  ${EXEC}
    singularity exec ${CONTAINER} limit
endif

#>      Horizontal domain decomposition
if ( $PROC == serial ) then
    set npcol = 1
    set nprow = 1
else
    set npcol = 8
    set nprow = 8
endif
set npcol_nprow = "${npcol} ${nprow}"
@ nprocs        = $npcol * $nprow

#> Ozone column data; Optics file
set OMIfile   = OMI_1979_to_2017.dat
set OPTfile   = PHOT_OPTICS.dat
set GRIDDESC  = $METpath/GRIDDESC   #> grid description file

#> Retrieve the number of columns, rows, and layers in this simulation
set nz   = 35
set nx   = `grep -A 1 ${GRID_NAME} ${GRIDDESC} | tail -1 | sed 's/  */ /g' | cut -d' ' -f6`
set ny   = `grep -A 1 ${GRID_NAME} ${GRIDDESC} | tail -1 | sed 's/  */ /g' | cut -d' ' -f7`
@ ncells = ${nx} * ${ny} * ${nz}

setenv SINGULARITYENV_APPL          "${APPL}"
setenv SINGULARITYENV_PROC          "${PROC}"
setenv SINGULARITYENV_VRSN          "${CMAQ_VRSN}"
setenv SINGULARITYENV_MECH          "${MECH}"
setenv SINGULARITYENV_GRID_NAME     "${GRID_NAME}"
setenv SINGULARITYENV_GRIDDESC      "${GRIDDESC}"
setenv SINGULARITYENV_NPCOL         "${npcol}"
setenv SINGULARITYENV_NPROW         "${nprow}"
setenv SINGULARITYENV_NPCOL_NPROW   "${npcol_nprow}"
setenv SINGULARITYENV_NPROCS        "${nprocs}"
setenv SINGULARITYENV_EXECUTION_ID  "CMAQ_CCTM${CMAQ_VRSN}_`id -u -n`_`date -u +%Y%m%d_%H%M%S_%N`"    #> Inform I/O API of the Execution ID

setenv SINGULARITYENV_PRINT_PROC_TIME  Y    #> Print timing for all science subprocesses to Logfile
                                            #>   [ default: TRUE or Y ]
setenv SINGULARITYENV_STDOUT           Y    #> Override I/O-API trying to write information to both the processor
                                            #>   logs and STDOUT [ options: Y | N ]

#> Output Species and Layer Options
#> CONC file species; comment or set to "ALL" to write all species to CONC
setenv SINGULARITYENV_CONC_SPCS         "O3 NO ANO3I ANO3J NO2 FORM ISOP NH3 ANH4I ANH4J ASO4I ASO4J"
setenv SINGULARITYENV_CONC_BLEV_ELEV    " 1 1"  #> CONC file layer range; comment to write all layers to CONC

#> ACONC file species; comment or set to "ALL" to write all species to ACONC
#setenv SINGULARITYENV_AVG_CONC_SPCS    "O3 NO CO NO2 ASO4I ASO4J NH3"
setenv SINGULARITYENV_AVG_CONC_SPCS     "ALL"
setenv SINGULARITYENV_ACONC_BLEV_ELEV   " 1 1"  #> ACONC file layer range; comment to write all layers to ACONC
setenv SINGULARITYENV_AVG_FILE_ENDTIME      N   #> override default beginning ACONC timestamp [ default: N ]

#> Synchronization Time Step and Tolerance Options
setenv SINGULARITYENV_CTM_MAXSYNC   300       	#> max sync time step (sec) [ default: 720 ]
setenv SINGULARITYENV_CTM_MINSYNC    60       	#> min sync time step (sec) [ default: 60 ]
setenv SINGULARITYENV_SIGMA_SYNC_TOP  0.7    	#> top sigma level thru which sync step determined [ default: 0.7 ]
#setenv SINGULARITYENV_ADV_HDIV_LIM   0.95    	#> maximum horiz. div. limit for adv step adjust [ default: 0.9 ]
setenv SINGULARITYENV_CTM_ADV_CFL     0.95      #> max CFL [ default: 0.75]
#setenv SINGULARITYENV_RB_ATOL        1.0E-09   #> global ROS3 solver absolute tolerance [ default: 1.0E-07 ]

#> Science Options
setenv SINGULARITYENV_CTM_OCEAN_CHEM       Y    #> Flag for ocean halogen chemistry and sea spray aerosol emissions [ default: Y ]
setenv SINGULARITYENV_CTM_WB_DUST          Y    #> use inline windblown dust emissions [ default: Y ]
setenv SINGULARITYENV_CTM_WBDUST_BELD  BELD3    #> landuse database for identifying dust source regions
                                                #>    [ default: UNKNOWN ]; ignore if CTM_WB_DUST = N
setenv SINGULARITYENV_CTM_LTNG_NO          N    #> turn on lightning NOx [ default: N ]
setenv SINGULARITYENV_KZMIN                Y    #> use Min Kz option in edyintb [ default: Y ],
                                                #>    otherwise revert to Kz0UT
setenv SINGULARITYENV_CTM_MOSAIC           N    #> landuse specific deposition velocities [ default: N ]
setenv SINGULARITYENV_CTM_FST              N    #> mosaic method to get land-use specific stomatal flux
                                                #>    [ default: N ]
setenv SINGULARITYENV_PX_VERSION           Y    #> WRF PX LSM
setenv SINGULARITYENV_CLM_VERSION          N    #> WRF CLM LSM
setenv SINGULARITYENV_NOAH_VERSION         N    #> WRF NOAH LSM
setenv SINGULARITYENV_CTM_ABFLUX           Y    #> ammonia bi-directional flux for in-line deposition
                                                #>    velocities [ default: N ]
setenv SINGULARITYENV_CTM_BIDI_FERT_NH3    Y    #> subtract fertilizer NH3 from emissions because it will be handled
                                                #>    by the BiDi calculation [ default: Y ]
setenv SINGULARITYENV_CTM_HGBIDI           N    #> mercury bi-directional flux for in-line deposition
                                                #>    velocities [ default: N ]
setenv SINGULARITYENV_CTM_SFC_HONO         Y    #> surface HONO interaction [ default: Y ]
setenv SINGULARITYENV_CTM_GRAV_SETL        Y    #> vdiff aerosol gravitational sedimentation [ default: Y ]
setenv SINGULARITYENV_CTM_BIOGEMIS         Y    #> calculate in-line biogenic emissions [ default: N ]

#> Vertical Extraction Options
setenv SINGULARITYENV_VERTEXT              N
setenv SINGULARITYENV_VERTEXT_COORD_PATH   /opt/CMAQ_${CMAQ_VRSN}/CCTM/scripts/lonlat.csv # container-path...

#> I/O Controls
setenv SINGULARITYENV_IOAPI_LOG_WRITE 	    N   #> turn on excess WRITE3 logging [ options: Y | N ]
setenv SINGULARITYENV_FL_ERR_STOP 	        N   #> stop on inconsistent input files
setenv SINGULARITYENV_PROMPTFLAG 	        N   #> turn on I/O-API PROMPT*FILE interactive mode [ options: Y | N ]
setenv SINGULARITYENV_IOAPI_OFFSET_64 	    Y   #> support large timestep records (>2GB/timestep record) [ options: YES | NO ]
setenv SINGULARITYENV_IOAPI_CHECK_HEADERS   N   #> check file headers [ options: Y | N ]
setenv SINGULARITYENV_CTM_EMISCHK           Y   #> Abort CMAQ if missing surrogates from emissions Input files
setenv SINGULARITYENV_EMISDIAG              N   #> Print Emission Rates at the output time step after they have been
                                                #>   scaled and modified by the user Rules [options: N | Y or 2D | 3D | 2DSUM ]
                                                #>   Individual streams can be modified using the variables:
                                                #>       GR_EMIS_DIAG_## | STK_EMIS_DIAG_## | BIOG_EMIS_DIAG
                                                #>       MG_EMIS_DIAG    | LTNG_EMIS_DIAG   | DUST_EMIS_DIAG
                                                #>       SEASPRAY_EMIS_DIAG
                                                #>   Note that these diagnostics are different than other emissions diagnostic
                                                #>   output because they occur after scaling.
setenv SINGULARITYENV_EMIS_DATE_OVRD       N    #> Master switch for allowing CMAQ to use the date from each Emission file
                                                #>   rather than checking the emissions date against the internal model date.
                                                #>   [options: Y | N or Y | N]. If false (F/N), then the date from CMAQ's internal
                                                #>   time will be used and an error check will be performed (recommended). Users
                                                #>   may switch the behavior for individual emission files below using the variables:
                                                #>       GR_EM_SYM_DATE_## | STK_EM_SYM_DATE_## [default : N ]
setenv SINGULARITYENV_EMISDIAG_SUM         N    #> Print Sum of Emission Rates to Gridded Diagnostic File

#> Diagnostic Output Flags
setenv SINGULARITYENV_CTM_CKSUM            Y    #> checksum report [ default: Y ]
setenv SINGULARITYENV_CLD_DIAG             N    #> cloud diagnostic file [ default: N ]

setenv SINGULARITYENV_CTM_PHOTDIAG         N    #> photolysis diagnostic file [ default: N ]
setenv SINGULARITYENV_NLAYS_PHOTDIAG      "1"   #> Number of layers for PHOTDIAG2 and PHOTDIAG3 from
                                                #>     Layer 1 to NLAYS_PHOTDIAG  [ default: all layers ]
#setenv SINGULARITYENV_NWAVE_PHOTDIAG     "294 303 310 316 333 381 607"  #> Wavelengths written for variables
                                                #>   in PHOTDIAG2 and PHOTDIAG3
                                                #>   [ default: all wavelengths ]

setenv SINGULARITYENV_CTM_PMDIAG           N    #> Instantaneous Aerosol Diagnostic File [ default: Y ]
setenv SINGULARITYENV_CTM_APMDIAG          Y    #> Hourly-Average Aerosol Diagnostic File [ default: Y ]
setenv SINGULARITYENV_APMDIAG_BLEV_ELEV "1 1"   #> layer range for average pmdiag = NLAYS

setenv SINGULARITYENV_CTM_SSEMDIAG         N    #> sea-spray emissions diagnostic file [ default: N ]
setenv SINGULARITYENV_CTM_DUSTEM_DIAG      N    #> windblown dust emissions diagnostic file [ default: N ];
                                                #>     Ignore if CTM_WB_DUST = N
setenv SINGULARITYENV_CTM_DEPV_FILE        N    #> deposition velocities diagnostic file [ default: N ]
setenv SINGULARITYENV_VDIFF_DIAG_FILE      N    #> vdiff & possibly aero grav. sedimentation diagnostic file [ default: N ]
setenv SINGULARITYENV_LTNGDIAG             N    #> lightning diagnostic file [ default: N ]
setenv SINGULARITYENV_B3GTS_DIAG           N    #> BEIS mass emissions diagnostic file [ default: N ]
setenv SINGULARITYENV_CTM_WVEL             Y    #> save derived vertical velocity component to conc
setenv SINGULARITYENV_CTM_PROCAN           N    #> use process analysis [ default: N]
setenv SINGULARITYENV_CTM_ISAM             N    #> Integrated Source Apportionment Method (ISAM) Options
setenv SINGULARITYENV_STM_SO4TRACK         N    #> sulfur tracking [ default: N ]

if ( $SINGULARITYENV_STM_SO4TRACK == 'Y' || $SINGULARITYENV_STM_SO4TRACK == 'T' ) then
    setenv SINGULARITYENV_STM_ADJSO4       Y        #> option to normalize sulfate tracers [ default: Y ]
endif

#> species defn & photolysis
setenv SINGULARITYENV_gc_matrix_nml ${NMLPATH}/GC_${MECH}.nml
setenv SINGULARITYENV_ae_matrix_nml ${NMLPATH}/AE_${MECH}.nml
setenv SINGULARITYENV_nr_matrix_nml ${NMLPATH}/NR_${MECH}.nml
setenv SINGULARITYENV_tr_matrix_nml ${NMLPATH}/Species_Table_TR_0.nml
setenv SINGULARITYENV_CSQY_DATA     ${NMLPATH}/CSQY_DATA_${MECH}
setenv SINGULARITYENV_OMI           ${OMIpath}/$OMIfile
setenv SINGULARITYENV_OPTICS_DATA   ${OMIpath}/$OPTfile
#setenv SINGULARITYENV_XJ_DATA      $JVALpath/$JVALfile

# singularity exec  ${hostdirs} ${CONTAINER} ls ${SINGULARITYENV_CSQY_DATA} >& /dev/null
# if ( ! ${status} ) then
#     echo "EXITING:  ${SINGULARITYENV_CSQY_DATA}  not found "
#     exit 1
# endif
# 
# singularity exec  ${hostdirs} ${CONTAINER} ls ${SINGULARITYENV_OPTICS_DATA} >& /dev/null
# if ( ! ${status} ) then
#     echo "EXITING:  ${SINGULARITYENV_OPTICS_DATA}  not found "
#     exit 1
# endif

# ===================================================================
#> Runtime Environment Options
# ===================================================================

echo 'Start Model Run At ' `date`
echo "---CMAQ EXECUTION ID: $SINGULARITYENV_EXECUTION_ID ---"

# =====================================================================
#> Begin Loop Through Simulation Days
# =====================================================================
set pid      = $$
set rtarray  = ""
set todayg   = ${START_DATE}
set yyyyjjj  = `date -ud "${START_DATE}" +%Y%j`    #> Convert YYYY-MM-DD to yyyyjjj
set stop_day = `date -ud "${END_DATE}"   +%Y%j`      #> Convert YYYY-MM-DD to yyyyjjj
set ndays    = 0

while ( ${yyyyjjj} <= ${stop_day} )                       #>Compare dates in terms of yyyyjjj

    @ ndays = ${ndays} + 1

    #> Retrieve Calendar day Information
    #> Calculate Yesterday's Date
    set yyyymmdd = `date -ud "${todayg}"       +%Y%m%d` #> Convert YYYY-MM-DD to yyyymmdd
    set yyyymm   = `date -ud "${todayg}"       +%Y%m`   #> Convert YYYY-MM-DD to yyyymm
    set yymmdd   = `date -ud "${todayg}"       +%y%m%d` #> Convert YYYY-MM-DD to yymmdd
    set yesterg  = `date -ud "${todayg}-1days" +%Y%m%d` #> Convert YYYY-MM-DD to YYYYMMDD

    # =====================================================================
    #> Set Output String and Propagate Model Configuration Documentation
    # =====================================================================
    echo ""
    echo "Set up input and output files for Day ${todayg}."

    #> set output file name extensions
    #> Copy Model Configuration To Output Folder
    set ctm_appl = ${RUNID}_${yyyymmdd}
    singularity exec  ${hostdirs} ${CONTAINER}  cp ${bld}/CCTM_v${CMAQ_VRSN}.cfg ${outdir}/CCTM_${ctm_appl}.cfg

    #setenv SINGULARITYENV_LOGFILE $CMAQ_HOME/$RUNID.log

    # =====================================================================
    #> Input Files (Some are Day-Dependent)
    # =====================================================================

    #> Initial conditions
    if (${NEW_START} == true || ${NEW_START} == TRUE ) then
        set ICFILE = ICON_20160630_bench.nc
        setenv SINGULARITYENV_INIT_MEDC_1   notused
        setenv SINGULARITYENV_INITIAL_RUN   Y       #related to restart soil information file
    else
        set ICpath = $outdir
        set ICFILE = CCTM_CGRID_${RUNID}_${yesterg}.nc
        setenv SINGULARITYENV_INIT_MEDC_1   $ICpath/CCTM_MEDIA_CONC_${RUNID}_${yesterg}.nc
        setenv SINGULARITYENV_INITIAL_RUN   N
    endif

    #> Boundary conditions
    set BCFILE = BCON_${yyyymmdd}_bench.nc

    #> Off-line photolysis rates
    #set JVALfile  = JTABLE_${yyyyjjj}

    #> MCIP meteorology files
    setenv SINGULARITYENV_GRID_BDY_2D  $METpath/GRIDBDY2D_${yymmdd}.nc  # GRID files are static, not day-specific
    setenv SINGULARITYENV_GRID_CRO_2D  $METpath/GRIDCRO2D_${yymmdd}.nc
    setenv SINGULARITYENV_GRID_CRO_3D  $METpath/GRIDCRO3D_${yymmdd}.nc
    setenv SINGULARITYENV_GRID_DOT_2D  $METpath/GRIDDOT2D_${yymmdd}.nc
    setenv SINGULARITYENV_MET_CRO_2D   $METpath/METCRO2D_${yymmdd}.nc
    setenv SINGULARITYENV_MET_CRO_3D   $METpath/METCRO3D_${yymmdd}.nc
    setenv SINGULARITYENV_MET_DOT_3D   $METpath/METDOT3D_${yymmdd}.nc
    setenv SINGULARITYENV_MET_BDY_3D   $METpath/METBDY3D_${yymmdd}.nc
    setenv SINGULARITYENV_LUFRAC_CRO   $METpath/LUFRAC_CRO_${yymmdd}.nc

    #> Emissions Control File
    #>
    #> IMPORTANT NOTE
    #>
    #> The emissions control file defined below is an integral part of controlling the behavior of the model simulation.
    #> Among other things, it controls the mapping of species in the emission files to chemical species in the model and
    #> several aspects related to the simulation of organic aerosols.
    #> Please carefully review the emissions control file to ensure that it is configured to be consistent with the assumptions
    #> made when creating the emission files defined below and the desired representation of organic aerosols.
    #> For further information, please see:
    #> + AERO7 Release Notes section on 'Required emission updates':
    #>   https://github.com/USEPA/CMAQ/blob/master/DOCS/Release_Notes/aero7_overview.md
    #> + CMAQ User's Guide section 6.9.3 on 'Emission Compatability':
    #>   https://github.com/USEPA/CMAQ/blob/master/DOCS/Users_Guide/CMAQ_UG_ch06_model_configuration_options.md#6.9.3_Emission_Compatability
    #> + Emission Control (DESID) Documentation in the CMAQ User's Guide:
    #>   https://github.com/USEPA/CMAQ/blob/master/DOCS/Users_Guide/Appendix/CMAQ_UG_appendixB_emissions_control.md
    #>
    setenv SINGULARITYENV_EMISSCTRL_NML ${NMLPATH}/EmissCtrl_${MECH}.nml

    #> Spatial Masks For Emissions Scaling
    setenv SINGULARITYENV_CMAQ_MASKS $SZpath/12US1_surf_bench.nc #> horizontal grid-dependent surf zone file

    #> Gridded Emissions Files
    setenv SINGULARITYENV_N_EMIS_GR            1
    setenv SINGULARITYENV_GR_EMIS_001          ${EMISpath}/emis_mole_all_${yyyymmdd}_cb6_bench.nc
    setenv SINGULARITYENV_GR_EMIS_LAB_001      GRIDDED_EMIS
    setenv SINGULARITYENV_GR_EM_SYM_DATE_001   F

    #> In-line point emissions configuration
    setenv SINGULARITYENV_N_EMIS_PT 5          #> Number of elevated source groups

    set STKCASEG = 12US1_2016ff_16j			# Stack Group Version Label
    set STKCASEE = 12US1_cmaq_cb6_2016ff_16j		# Stack Emission Version Label

    # Time-Independent Stack Parameters for Inline Point Sources
    setenv SINGULARITYENV_STK_GRPS_001 $IN_PTpath/stack_groups/stack_groups_ptnonipm_${STKCASEG}.nc
    setenv SINGULARITYENV_STK_GRPS_002 $IN_PTpath/stack_groups/stack_groups_ptegu_${STKCASEG}.nc
    setenv SINGULARITYENV_STK_GRPS_003 $IN_PTpath/stack_groups/stack_groups_othpt_${STKCASEG}.nc
    setenv SINGULARITYENV_STK_GRPS_004 $IN_PTpath/stack_groups/stack_groups_ptfire_${yyyymmdd}_${STKCASEG}.nc
    setenv SINGULARITYENV_STK_GRPS_005 $IN_PTpath/stack_groups/stack_groups_pt_oilgas_${STKCASEG}.nc
    setenv SINGULARITYENV_LAYP_STTIME  $START_TIME
    setenv SINGULARITYENV_LAYP_NSTEPS  $RUN_LENGTH

    # Emission Rates for Inline Point Sources
    setenv SINGULARITYENV_STK_EMIS_001 $IN_PTpath/ptnonipm/inln_mole_ptnonipm_${yyyymmdd}_${STKCASEE}.nc
    setenv SINGULARITYENV_STK_EMIS_002 $IN_PTpath/ptegu/inln_mole_ptegu_${yyyymmdd}_${STKCASEE}.nc
    setenv SINGULARITYENV_STK_EMIS_003 $IN_PTpath/othpt/inln_mole_othpt_${yyyymmdd}_${STKCASEE}.nc
    setenv SINGULARITYENV_STK_EMIS_004 $IN_PTpath/ptfire/inln_mole_ptfire_${yyyymmdd}_${STKCASEE}.nc
    setenv SINGULARITYENV_STK_EMIS_005 $IN_PTpath/pt_oilgas/inln_mole_pt_oilgas_${yyyymmdd}_${STKCASEE}.nc
    setenv SINGULARITYENV_LAYP_STDATE  ${yyyyjjj}

    # Label Each Emissions Stream
    setenv SINGULARITYENV_STK_EMIS_LAB_001 PT_NONEGU
    setenv SINGULARITYENV_STK_EMIS_LAB_002 PT_EGU
    setenv SINGULARITYENV_STK_EMIS_LAB_003 PT_OTHER
    setenv SINGULARITYENV_STK_EMIS_LAB_004 PT_FIRES
    setenv SINGULARITYENV_STK_EMIS_LAB_005 PT_OILGAS

    # Stack emissions diagnostic files
    #setenv SINGULARITYENV_STK_EMIS_DIAG_001 2DSUM
    #setenv SINGULARITYENV_STK_EMIS_DIAG_002 2DSUM
    #setenv SINGULARITYENV_STK_EMIS_DIAG_003 2DSUM
    #setenv SINGULARITYENV_STK_EMIS_DIAG_004 2DSUM
    #setenv SINGULARITYENV_STK_EMIS_DIAG_005 2DSUM

    # Allow CMAQ to Use Point Source files with dates that do not
    # match the internal model date
    setenv SINGULARITYENV_STK_EM_SYM_DATE_001 T
    setenv SINGULARITYENV_STK_EM_SYM_DATE_002 T
    setenv SINGULARITYENV_STK_EM_SYM_DATE_003 T
    setenv SINGULARITYENV_STK_EM_SYM_DATE_004 T
    setenv SINGULARITYENV_STK_EM_SYM_DATE_005 T

    #> Lightning NOx configuration
    if ( $SINGULARITYENV_CTM_LTNG_NO == 'Y' ) then
        setenv SINGULARITYENV_LTNGNO "InLine"    #> set LTNGNO to "Inline" to activate in-line calculation

        #> In-line lightning NOx options
        setenv SINGULARITYENV_USE_NLDN  N        #> use hourly NLDN strike file [ default: Y ]
        if ( $SINGULARITYENV_USE_NLDN == Y ) then
            setenv SINGULARITYENV_NLDN_STRIKES ${IN_LTpath}/NLDN.12US1.${yyyymmdd}_bench.nc
        endif
        setenv SINGULARITYENV_LTNGPARMS_FILE ${IN_LTpath}/LTNG_AllParms_12US1_bench.nc #> lightning parameter file
    endif

    #> In-line biogenic emissions configuration
    if ( $SINGULARITYENV_CTM_BIOGEMIS == 'Y' ) then
        set IN_BEISpath = ${inpdir}/land
        setenv SINGULARITYENV_GSPRO      ${NMLPATH}/gspro_biogenics.txt
        setenv SINGULARITYENV_B3GRD      $IN_BEISpath/b3grd_bench.nc
        setenv SINGULARITYENV_BIOSW_YN   Y      #> use frost date switch [ default: Y ]
        setenv SINGULARITYENV_BIOSEASON  $IN_BEISpath/bioseason.cmaq.2016_12US1_full_bench.ncf
                                                #> ignore season switch file if BIOSW_YN = N
        setenv SINGULARITYENV_SUMMER_YN  Y      #> Use summer normalized emissions? [ default: Y ]
        setenv SINGULARITYENV_PX_VERSION Y      #> MCIP is PX version? [ default: N ]
        setenv SINGULARITYENV_SOILINP    ${outdir}/CCTM_SOILOUT_${RUNID}_${yesterg}.nc
                                                #> Biogenic NO soil input file; ignore if INITIAL_RUN = Y
    endif

    #> Windblown dust emissions configuration
    if ( $SINGULARITYENV_CTM_WB_DUST == 'Y' ) then
        # Input variables for BELD3 Landuse option
        setenv SINGULARITYENV_DUST_LU_1 $LUpath/beld3_12US1_459X299_output_a_bench.nc
        setenv SINGULARITYENV_DUST_LU_2 $LUpath/beld4_12US1_459X299_output_tot_bench.nc
    endif

    #> In-line sea spray emissions configuration
    setenv SINGULARITYENV_OCEAN_1 $SZpath/12US1_surf_bench.nc #> horizontal grid-dependent surf zone file

    #> Bidirectional ammonia configuration
    if ( $SINGULARITYENV_CTM_ABFLUX == 'Y' ) then
        setenv SINGULARITYENV_E2C_SOIL        ${LUpath}/epic_festc1.4_20180516/2016_US1_soil_bench.nc
        setenv SINGULARITYENV_E2C_CHEM        ${LUpath}/epic_festc1.4_20180516/2016_US1_time${yyyymmdd}_bench.nc
        setenv SINGULARITYENV_E2C_CHEM_YEST   ${LUpath}/epic_festc1.4_20180516/2016_US1_time${yesterg}_bench.nc
        setenv SINGULARITYENV_E2C_LU          ${LUpath}/beld4_12kmCONUS_2011nlcd_bench.nc
    endif

    #> Inline Process Analysis
    if ( $SINGULARITYENV_CTM_PROCAN == 'Y' || $SINGULARITYENV_CTM_PROCAN == 'T' ) then
        #> process analysis global column, row and layer ranges
        #       setenv SINGULARITYENV_PA_BCOL_ECOL "10 90"  # default: all columns
        #       setenv SINGULARITYENV_PA_BROW_EROW "10 80"  # default: all rows
        #       setenv SINGULARITYENV_PA_BLEV_ELEV "1  4"   # default: all levels
        setenv SINGULARITYENV_PACM_INFILE ${NMLPATH}/pa_${MECH}.ctl
        setenv SINGULARITYENV_PACM_REPORT ${outdir}/"PA_REPORT".${yyyymmdd}
    endif

    #> Integrated Source Apportionment Method (ISAM) Options
    if ( $SINGULARITYENV_CTM_ISAM == 'Y' || $SINGULARITYENV_CTM_ISAM == 'T' ) then
        setenv SINGULARITYENV_SA_IOLIST         ${rundir}/isam_control.txt
        setenv SINGULARITYENV_ISAM_BLEV_ELEV    " 1 1"
        setenv SINGULARITYENV_AISAM_BLEV_ELEV   " 1 1"

        #> Set Up ISAM Initial Condition Flags
        if ($NEW_START == true || $NEW_START == TRUE ) then
           setenv SINGULARITYENV_ISAM_NEW_START Y
           setenv SINGULARITYENV_ISAM_PREVDAY
        else
           setenv SINGULARITYENV_ISAM_NEW_START N
           setenv SINGULARITYENV_ISAM_PREVDAY   "${outdir}/CCTM_SA_CGRID_${RUNID}_${yesterg}.nc"
        endif

        #> Set Up ISAM Output Filenames
        setenv SINGULARITYENV_SA_ACONC_1      "${outdir}/CCTM_SA_ACONC_${ctm_appl}.nc -v"
        setenv SINGULARITYENV_SA_CONC_1       "${outdir}/CCTM_SA_CONC_${ctm_appl}.nc -v"
        setenv SINGULARITYENV_SA_DD_1         "${outdir}/CCTM_SA_DRYDEP_${ctm_appl}.nc -v"
        setenv SINGULARITYENV_SA_WD_1         "${outdir}/CCTM_SA_WETDEP_${ctm_appl}.nc -v"
        setenv SINGULARITYENV_SA_CGRID_1      "${outdir}/CCTM_SA_CGRID_${ctm_appl}.nc -v"

        #> Set optional ISAM regions files
        # setenv SINGULARITYENV_ISAM_REGIONS /work/MOD3EVAL/nsu/isam_v53/CCTM/scripts/RGN_ISAM.nc

    endif

    # =====================================================================
    #> Output Files
    # =====================================================================

    #> set output file names
    setenv SINGULARITYENV_S_CGRID         "${outdir}/CCTM_CGRID_${ctm_appl}.nc"         #> 3D Inst. Concentrations
    setenv SINGULARITYENV_CTM_CONC_1      "${outdir}/CCTM_CONC_${ctm_appl}.nc -v"       #> On-Hour Concentrations
    setenv SINGULARITYENV_A_CONC_1        "${outdir}/CCTM_ACONC_${ctm_appl}.nc -v"      #> Hourly Avg. Concentrations
    setenv SINGULARITYENV_MEDIA_CONC      "${outdir}/CCTM_MEDIA_CONC_${ctm_appl}.nc -v" #> NH3 Conc. in Media
    setenv SINGULARITYENV_CTM_DRY_DEP_1   "${outdir}/CCTM_DRYDEP_${ctm_appl}.nc -v"     #> Hourly Dry Deposition
    setenv SINGULARITYENV_CTM_DEPV_DIAG   "${outdir}/CCTM_DEPV_${ctm_appl}.nc -v"       #> Dry Deposition Velocities
    setenv SINGULARITYENV_B3GTS_S         "${outdir}/CCTM_B3GTS_S_${ctm_appl}.nc -v"    #> Biogenic Emissions
    setenv SINGULARITYENV_SOILOUT         "${outdir}/CCTM_SOILOUT_${ctm_appl}.nc"       #> Soil Emissions
    setenv SINGULARITYENV_CTM_WET_DEP_1   "${outdir}/CCTM_WETDEP1_${ctm_appl}.nc -v"    #> Wet Dep From All Clouds
    setenv SINGULARITYENV_CTM_WET_DEP_2   "${outdir}/CCTM_WETDEP2_${ctm_appl}.nc -v"    #> Wet Dep From SubGrid Clouds
    setenv SINGULARITYENV_CTM_PMDIAG_1    "${outdir}/CCTM_PMDIAG_${ctm_appl}.nc -v"     #> On-Hour Particle Diagnostics
    setenv SINGULARITYENV_CTM_APMDIAG_1   "${outdir}/CCTM_APMDIAG_${ctm_appl}.nc -v"    #> Hourly Avg. Particle Diagnostics
    setenv SINGULARITYENV_CTM_RJ_1        "${outdir}/CCTM_PHOTDIAG1_${ctm_appl}.nc -v"  #> 2D Surface Summary from Inline Photolysis
    setenv SINGULARITYENV_CTM_RJ_2        "${outdir}/CCTM_PHOTDIAG2_${ctm_appl}.nc -v"  #> 3D Photolysis Rates
    setenv SINGULARITYENV_CTM_RJ_3        "${outdir}/CCTM_PHOTDIAG3_${ctm_appl}.nc -v"  #> 3D Optical and Radiative Results from Photolysis
    setenv SINGULARITYENV_CTM_SSEMIS_1    "${outdir}/CCTM_SSEMIS_${ctm_appl}.nc -v"     #> Sea Spray Emissions
    setenv SINGULARITYENV_CTM_DUST_EMIS_1 "${outdir}/CCTM_DUSTEMIS_${ctm_appl}.nc -v"   #> Dust Emissions
    setenv SINGULARITYENV_CTM_IPR_1       "${outdir}/CCTM_PA_1_${ctm_appl}.nc -v"       #> Process Analysis
    setenv SINGULARITYENV_CTM_IPR_2       "${outdir}/CCTM_PA_2_${ctm_appl}.nc -v"       #> Process Analysis
    setenv SINGULARITYENV_CTM_IPR_3       "${outdir}/CCTM_PA_3_${ctm_appl}.nc -v"       #> Process Analysis
    setenv SINGULARITYENV_CTM_IRR_1       "${outdir}/CCTM_IRR_1_${ctm_appl}.nc -v"      #> Chem Process Analysis
    setenv SINGULARITYENV_CTM_IRR_2       "${outdir}/CCTM_IRR_2_${ctm_appl}.nc -v"      #> Chem Process Analysis
    setenv SINGULARITYENV_CTM_IRR_3       "${outdir}/CCTM_IRR_3_${ctm_appl}.nc -v"      #> Chem Process Analysis
    setenv SINGULARITYENV_CTM_DRY_DEP_MOS "${outdir}/CCTM_DDMOS_${ctm_appl}.nc -v"      #> Dry Dep
    setenv SINGULARITYENV_CTM_DRY_DEP_FST "${outdir}/CCTM_DDFST_${ctm_appl}.nc -v"      #> Dry Dep
    setenv SINGULARITYENV_CTM_DEPV_MOS    "${outdir}/CCTM_DEPVMOS_${ctm_appl}.nc -v"    #> Dry Dep Velocity
    setenv SINGULARITYENV_CTM_DEPV_FST    "${outdir}/CCTM_DEPVFST_${ctm_appl}.nc -v"    #> Dry Dep Velocity
    setenv SINGULARITYENV_CTM_VDIFF_DIAG  "${outdir}/CCTM_VDIFF_DIAG_${ctm_appl}.nc -v" #> Vertical Dispersion Diagnostic
    setenv SINGULARITYENV_CTM_VSED_DIAG   "${outdir}/CCTM_VSED_DIAG_${ctm_appl}.nc -v"  #> Particle Grav. Settling Velocity
    setenv SINGULARITYENV_CTM_LTNGDIAG_1  "${outdir}/CCTM_LTNGHRLY_${ctm_appl}.nc -v"   #> Hourly Avg Lightning NO
    setenv SINGULARITYENV_CTM_LTNGDIAG_2  "${outdir}/CCTM_LTNGCOL_${ctm_appl}.nc -v"    #> Column Total Lightning NO
    setenv SINGULARITYENV_CTM_VEXT_1      "${outdir}/CCTM_VEXT_${ctm_appl}.nc -v"       #> On-Hour 3D Concs at select sites

    #> set floor file (neg concs)
    setenv SINGULARITYENV_FLOOR_FILE ${outdir}/FLOOR_${ctm_appl}.txt

    set OUT_FILES = ( ${SINGULARITYENV_FLOOR_FILE}      ${SINGULARITYENV_S_CGRID}         \
                      ${SINGULARITYENV_CTM_CONC_1}      ${SINGULARITYENV_A_CONC_1}        \
                      ${SINGULARITYENV_MEDIA_CONC}      ${SINGULARITYENV_CTM_DRY_DEP_1}   \
                      ${SINGULARITYENV_CTM_DEPV_DIAG}   ${SINGULARITYENV_B3GTS_S}         \
                      ${SINGULARITYENV_SOILOUT}         ${SINGULARITYENV_CTM_WET_DEP_1}   \
                      ${SINGULARITYENV_CTM_WET_DEP_2}   ${SINGULARITYENV_CTM_PMDIAG_1}    \
                      ${SINGULARITYENV_CTM_APMDIAG_1}   ${SINGULARITYENV_CTM_RJ_1}        \
                      ${SINGULARITYENV_CTM_RJ_2}        ${SINGULARITYENV_CTM_RJ_3}        \
                      ${SINGULARITYENV_CTM_SSEMIS_1}    ${SINGULARITYENV_CTM_DUST_EMIS_1} \
                      ${SINGULARITYENV_CTM_IPR_1}       ${SINGULARITYENV_CTM_IPR_2}       \
                      ${SINGULARITYENV_CTM_IPR_3}       ${SINGULARITYENV_CTM_IRR_1}       \
                      ${SINGULARITYENV_CTM_IRR_2}       ${SINGULARITYENV_CTM_IRR_3}       \
                      ${SINGULARITYENV_CTM_DRY_DEP_MOS} ${SINGULARITYENV_CTM_DRY_DEP_FST} \
                      ${SINGULARITYENV_CTM_DEPV_MOS}    ${SINGULARITYENV_CTM_DEPV_FST}    \
                      ${SINGULARITYENV_CTM_VDIFF_DIAG}  ${SINGULARITYENV_CTM_VSED_DIAG}   \
                      ${SINGULARITYENV_CTM_LTNGDIAG_1}  ${SINGULARITYENV_CTM_LTNGDIAG_2}  \
                      ${SINGULARITYENV_CTM_VEXT_1} )

    if ( $SINGULARITYENV_CTM_ISAM == 'Y' || $SINGULARITYENV_CTM_ISAM == 'T' ) then
        set OUT_FILES = (${OUT_FILES} ${SINGULARITYENV_SA_ACONC_1} ${SINGULARITYENV_SA_CONC_1} \
                              ${SINGULARITYENV_SA_DD_1} ${SA_WD_1} ${SINGULARITYENV_SA_CGRID_1} )
    endif


    #> delete previous logs and output if requested
    if ( $CLOBBER_DATA == true || $CLOBBER_DATA == TRUE  ) then

        echo "\nExisting Logs and Output Files for Day ${todayg} Will Be Deleted"
       
        rm -f  CTM_LOG_???.${ctm_appl} ${logdir}/CTM_LOG_???.${ctm_appl} ${logdir}/CTM_LOG_???.${ctm_appl}
        /bin/rm -f ${OUT_FILES} ${outdir}/CCTM_EMDIAG*${RUNID}_${yyyymmdd}.nc

    else        #> error if previous log or output files exist

        ls CTM_LOG_???.${ctm_appl}  ${logdir}/CTM_LOG_???.${ctm_appl} >& /dev/null
        
        if ( ! ${status ) then
            echo "*** Logs exist - run ABORTED ***"
            echo "*** To overide, set CLOBBER_DATA = TRUE in run_cctm.csh ***"
            echo "*** and these files will be automatically deleted. ***"
            exit 1
        endif

        ls ${OUT_FILES} ${outdir}/CCTM_EMDIAG*${RUNID}_${yyyymmdd}.nc >& /dev/null
        if ( ! ${status} ) then
            echo "\n*** Output Files Exist - run will be ABORTED ***"
            foreach file ( $out_test )
                echo " cannot delete $file"
            end
            echo "*** To overide, set CLOBBER_DATA = TRUE in run_cctm.csh ***"
            echo "*** and these files will be automatically deleted. ***"
            exit 1
        endif

    endif

    #> for the run control ...
    setenv SINGULARITYENV_NEW_START     ${NEW_START}
    setenv SINGULARITYENV_CTM_STDATE    ${yyyyjjj}
    setenv SINGULARITYENV_CTM_STTIME    ${START_TIME}
    setenv SINGULARITYENV_CTM_RUNLEN    ${RUN_LENGTH}
    setenv SINGULARITYENV_CTM_TSTEP     ${TIME_STEP}
    setenv SINGULARITYENV_INIT_CONC_1   ${ICpath}/$ICFILE
    setenv SINGULARITYENV_BNDY_CONC_1   ${BCpath}/$BCFILE

    # ===================================================================
    #> Execution Portion
    # ===================================================================

    #> Print Startup Dialogue Information to Standard Out
    echo ${bar}
    echo "\n CMAQ Processing of Day $yyyymmdd Began at `date`"
    echo ${bar}
    if ( ${CTM_VERBOSE} > 0 ) then
        env | sort
        echo ${bar}
    endif

    unset errstat
    set echo

    #> Executable call for single PE, uncomment to invoke
    #>( /usr/bin/time -p $bld/${EXEC} ) |& tee buff_${EXECUTION_ID}.txt
    #>
    #> Executable call for multi PE, configure for your system

    if ( $?DEBUG ) then
        mpirun -np ${nprocs} \
        singularity exec  ${hostdirs} ${CONTAINER} /usr/bin/ddd ${EXEC}
        echo "${bar}"
        echo "EXITING:  Debug run complete.\n"
        exit( 0 )
    endif

    ( /usr/bin/time -p mpirun -np ${nprocs} \
        singularity exec  ${hostdirs} ${CONTAINER} ${EXEC} ) \
        |& tee buff_${pid}.txt
    set errstat = ${status}
    if ( $CTM_VERBOSE < 2 ) unset echo

    #> Harvest Timing Output so that it may be reported below
    set rtarray = "${rtarray} `tail -3 buff_${pid}.txt | grep -Eo '[+-]?[0-9]+([.][0-9]+)?' | head -1` "
    rm -rf buff_${pid}.txt

    #> Abort script if abnormal termination
    if ( ${errstat} != 0 ) then
        echo ""
        echo "**************************************************************"
        echo "** Error: CMAQ failed for day $yyyymmdd                     **"
        echo "** Error STATUS = ${errstat}                                **"
        echo "**   The runscript will now abort rather than proceeding    **"
        echo "**   to subsequent days.                                    **"
        echo "**************************************************************"
        break
    endif

    singularity exec ${CONTAINER}  ls ${SINGULARITYENV_S_CGRID}  >& /dev/null
    if ( ${status} ) then
        echo ""
        echo "**************************************************************"
        echo "** Error: CMAQ failed for day $yyyymmdd                     **"
        echo "** Runscript Detected an Error: CGRID file was not written. **"
        echo "**   This indicates that CMAQ was interrupted or an issue   **"
        echo "**   exists with writing output. The runscript will now     **"
        echo "**   abort rather than proceeding to subsequent days.       **"
        echo "**************************************************************"
        break
    endif

    #> Print Concluding Text
    echo
    echo "CMAQ Processing of Day $yyyymmdd Finished at `date`"
    echo
    echo "\\\\\=====\\\\\=====\\\\\=====\\\\\=====/////=====/////=====/////=====/////"
    echo

    # ===================================================================
    #> Finalize Run for This Day and Loop to Next Day
    # ===================================================================

    #> Save Log Files and Move on to Next Simulation Day
    mv CTM_LOG_???.${ctm_appl} ${logdir}
    if ( $CTM_VERBOSE != 0 ) then
        mv CTM_DIAG_???.${ctm_appl} ${logdir}
    endif

    #> The next simulation day will, by definition, be a restart;
    #> Increment both Gregorian and Julian Days
    set NEW_START = FALSE
    set todayg    = `date -ud "${todayg}+1days" +%Y-%m-%d`     #> Add a day for tomorrow
    set yyyyjjj   = `date -ud "${todayg}" +%Y%j`               #> Convert YYYY-MM-DD to yyyyjjj

end  #Loop to the next Simulation Day


# ===================================================================
#> Generate Timing Report
# ===================================================================
set RTMTOT = 0
foreach it ( `seq ${ndays}` )
    set rt     = `echo ${rtarray} | cut -d' ' -f${it}`
    set RTMTOT = `echo "${RTMTOT} + ${rt}" | bc -l`
end

set RTMAVG = `echo "scale=2; ${RTMTOT} / ${ndays}" | bc -l`
set RTMTOT = `echo "scale=2; ${RTMTOT} / 1" | bc -l`

echo
echo "=================================="
echo "  ***** CMAQ TIMING REPORT *****"
echo "=================================="
echo "Start Day: ${START_DATE}"
echo "End Day:   ${END_DATE}"
echo "Number of Simulation Days: ${ndays}"
echo "Domain Name:               ${GRID_NAME}"
echo "Number of Grid Cells:      ${ncells}  (ROW x COL x LAY)"
echo "Number of Layers:          ${nz}"
echo "Number of Processes:       ${nprocs}"
echo "   All times are in seconds."
echo
echo "Num  Day        Wall Time"
set d = 0
set day = ${START_DATE}
foreach it ( `seq ${ndays}` )
    # Set the right day and format it
    set d = `echo "${d} + 1"  | bc -l`
    set n = `printf "%02d" ${d}`

    # Choose the correct time variables
    set rt = `echo ${rtarray} | cut -d' ' -f${it}`

    # Write out row of timing data
    echo "${n}   ${day}   ${rt}"

    # Increment day for next loop
    set day = `date -ud "${day}+1days" +%Y-%m-%d`
end
echo "     Total Time = ${RTMTOT}"
echo "      Avg. Time = ${RTMAVG}"

exit
