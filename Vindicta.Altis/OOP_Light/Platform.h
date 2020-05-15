/*
Redefinitions of different functions which are not implemented on different platforms (SQF-VM for instance)
*/

#ifdef _SQF_VM

// ___ SQF-VM ___
#define TEXT_
#undef ASP_ENABLE
//#define ASP_ENABLE
#undef PROFILER_COUNTERS_ENABLE
#undef ADE
#undef OFSTREAM_ENABLE
#undef OFSTREAM_FILE
#define VM_LOG(t) diag_log t
#define VM_LOG_FMT(t, args) diag_log format ([t] + args)
#define OOP_ASSERT
#define OOP_ASSERT_ACCESS
//#undef OOP_ASSERT
//#undef OOP_ASSERT_ACCESS
#undef OOP_DEBUG
#undef OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#undef OOP_PROFILE
#undef UNIT_ALLOCATOR_DEBUG
#undef DEBUG_GOAL_MARKERS

#define TIME_NOW 0
#define GAME_TIME 0
#define PROCESS_TIME 0
#define DATE_NOW [0,0,0,0,0]
#define UI_SLEEP(t)
#define SET_DATE(d)

#define CLIENT_OWNER 0
#define IS_SERVER true
#define IS_DEDICATED true
#define HAS_INTERFACE true
#define IS_HEADLESSCLIENT false
#define IS_MULTIPLAYER false
#define PUBLIC_VARIABLE isNil

#define IS_LOCAL_ADMIN true
#define IS_ADMIN_ON_DEDI true

#define START_LOADING_SCREEN __null =  
#define PROGRESS_LOADING_SCREEN __null = 
#define END_LOADING_SCREEN

#define PROFILE_NAME "PROFILE_NAME"
#define SCRIPT_NULL objNull
#define saveProfileNamespace

#define HEADLESS_CLIENTS []
#define HUMAN_PLAYERS []
#define PLAYABLE_UNITS []
#define ALL_VEHICLES []

#define SIMULATION_ENABLED(obj) true
#define ENABLE_SIMULATION_GLOBAL(obj, state)
#define ENABLE_DYNAMIC_SIMULATION_SYSTEM(enabled)

#define DISTANCE_2D distance
#define IS_SIMPLE_OBJECT isNull
// #define 
// ^^^ SQF-VM ^^^


#else


// ___ ARMA ___

#define TEXT_ text

#define VM_LOG(t)
#define VM_LOG_FMT(t, args)

#define TIME_NOW time
#define GAME_TIME (time - gGameFreezeTime)
#define PROCESS_TIME time
#define DATE_NOW date
#define UI_SLEEP(t) uisleep (t)
#define SET_DATE(d) setDate (d)

#define CLIENT_OWNER clientOwner
#define IS_SERVER isServer
#define IS_DEDICATED isDedicated
#define HAS_INTERFACE hasInterface
#define IS_HEADLESSCLIENT (!hasInterface && !isDedicated)
#define IS_MULTIPLAYER isMultiplayer
#define PUBLIC_VARIABLE publicVariable

#define IS_LOCAL_ADMIN (call BIS_fnc_admin != 0)
#define IS_ADMIN_ON_DEDI (IS_DEDICATED && { HUMAN_PLAYERS findIf { admin owner _x != 0 } != NOT_FOUND })

#define START_LOADING_SCREEN startLoadingScreen
#define PROGRESS_LOADING_SCREEN progressLoadingScreen
#define END_LOADING_SCREEN endLoadingScreen

#define PROFILE_NAME profileName
#define SCRIPT_NULL scriptNull

#define HEADLESS_CLIENTS (entities "HeadlessClient_F")
#define HUMAN_PLAYERS (allPlayers - HEADLESS_CLIENTS)
#define PLAYABLE_UNITS playableunits
#define ALL_VEHICLES vehicles

#define SIMULATION_ENABLED(obj) simulationEnabled (obj)
#define ENABLE_SIMULATION_GLOBAL(obj, state) (obj) enableSimulationGlobal (state);
#define ENABLE_DYNAMIC_SIMULATION_SYSTEM(enabled) enableDynamicSimulationSystem enabled

#define DISTANCE_2D distance2D
#define IS_SIMPLE_OBJECT isSimpleObject

#endif
// ^^^ ARMA ^^^
