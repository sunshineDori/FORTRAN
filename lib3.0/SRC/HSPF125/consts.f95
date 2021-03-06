module consts
implicit none
integer, parameter :: dpc = kind(1.d0)
!  --------------------------------------------------
!  Should be combined with enums.f95
!  --------------------------------------------------

!-----------------------------------------------------------------------------
!   consts.h
!
!   Project: EPA SWMM5
!   Version: 5.0
!   Date:    6/19/07   (Build 5.0.010)
!            1/21/09   (Build 5.0.014)
!            11/18/09  (Build 5.0.018)
!            09/30/10  (Build 5.0.021)
!   Author:  L. Rossman
!
!   Various Constants
!-----------------------------------------------------------------------------
!------------------
! General Constants
!------------------
integer, parameter :: VERSION = 50021                                             !(5.0.021 - LR)
integer, parameter :: MAGICNUMBER = 516114522
!real(kind=dpc), parameter :: EOFMARK = 0x1A)           ! Use 0x04 for UNIX systems
integer, parameter :: MAXTITLE = 3              ! Max. # title lines
integer, parameter :: MAXMSG = 1024           ! Max. # characters in message text
integer, parameter :: MAXLINE = 1024           ! Max. # characters per input line
integer, parameter :: MAXFNAME = 259            ! Max. # characters in file name
integer, parameter :: MAXTOKS = 40             ! Max. items per line of input
integer, parameter :: MAXSTATES = 10             ! Max. # computed hyd. variables
integer, parameter :: NA = -1             ! NOT APPLICABLE code
!real(kind=dpc), parameter :: TRUE = 1)              ! Value for TRUE state
!real(kind=dpc), parameter :: FALSE = 0)              ! Value for FALSE state
!real(kind=dpc), parameter :: TRUE = .true.)              ! Value for TRUE state
!real(kind=dpc), parameter :: FALSE = .false.)              ! Value for FALSE state
real(kind=dpc), parameter :: BIG = 1.E10          ! Generic large value
real(kind=dpc), parameter :: P_TINY = 1.E-6          ! Generic small value
real(kind=dpc), parameter :: ZERO = 1.E-10         ! Effective zero value            !(5.0.014 - LR)
real(kind=dpc), parameter :: MISSING = -1.E10         ! Missing value code
real(kind=dpc), parameter :: PI = 3.141592654    ! Value of pi
real(kind=dpc), parameter :: GRAVITY = 32.2           ! accel. of gravity in US units
real(kind=dpc), parameter :: SI_GRAVITY = 9.81           ! accel of gravity in SI units
integer, parameter :: MAXFILESIZE = 2147483647    ! largest file size in bytes

!-----------------------------
! Units factor in Manning Eqn.
!-----------------------------
real(kind=dpc), parameter :: PHI = 1.486

!----------------------------------------------
! Definition of measureable runoff flow & depth
!----------------------------------------------
real(kind=dpc), parameter :: MIN_RUNOFF_FLOW = 0.001          ! cfs
real(kind=dpc), parameter :: MIN_EXCESS_DEPTH = 0.0001         ! ft, = 0.03 mm
real(kind=dpc), parameter :: MIN_TOTAL_DEPTH = 0.004167       ! ft, = 0.05 inches
real(kind=dpc), parameter :: MIN_RUNOFF = 2.31481e-8     ! ft/sec = 0.001 in/hr

!----------------------------------------------------------------------
! Minimum flow, depth & volume used to evaluate steady state conditions
!----------------------------------------------------------------------
real(kind=dpc), parameter :: FLOW_TOL = 0.00001  ! cfs
real(kind=dpc), parameter :: DEPTH_TOL = 0.00001  ! ft
real(kind=dpc), parameter :: VOLUME_TOL = 0.01     ! ft3

!---------------------------------------------------
! Minimum depth for reporting non-zero water quality
!---------------------------------------------------
real(kind=dpc), parameter :: MIN_WQ_DEPTH = 0.01     ! ft (= 3 mm)
real(kind=dpc), parameter :: MIN_WQ_FLOW = 0.001    ! cfs

!-----------------------------------------------------
! Minimum flow depth and area for dynamic wave routing
!-----------------------------------------------------
real(kind=dpc), parameter :: FUDGE = 0.0001    ! ft or ft2

!---------------------------
! Various conversion factors
!---------------------------
real(kind=dpc), parameter :: GPMperCFS = 448.831
real(kind=dpc), parameter :: AFDperCFS = 1.9837
real(kind=dpc), parameter :: MGDperCFS = 0.64632
real(kind=dpc), parameter :: IMGDperCFS = 0.5382
real(kind=dpc), parameter :: LPSperCFS = 28.317
real(kind=dpc), parameter :: LPMperCFS = 1699.0
real(kind=dpc), parameter :: CMHperCFS = 101.94
real(kind=dpc), parameter :: CMDperCFS = 2446.6
real(kind=dpc), parameter :: MLDperCFS = 2.4466
real(kind=dpc), parameter :: M3perFT3 = 0.028317
real(kind=dpc), parameter :: LperFT3 = 28.317
real(kind=dpc), parameter :: MperFT = 0.3048
real(kind=dpc), parameter :: PSIperFT = 0.4333
real(kind=dpc), parameter :: KPAperPSI = 6.895
real(kind=dpc), parameter :: KWperHP = 0.7457
real(kind=dpc), parameter :: SECperDAY = 86400
real(kind=dpc), parameter :: MSECperDAY = 8.64e7
real(kind=dpc), parameter :: MMperINCH = 25.40

!---------------------------
! Token separator characters
!--------------------------- 
character(len=8), parameter :: SEPSTR = ' \t\n\r'

!newly added
integer, parameter :: MAX_NUM_POLLUTANTS = 6
end module
