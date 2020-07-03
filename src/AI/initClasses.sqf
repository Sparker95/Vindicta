#include "..\config\global_config.hpp"
#include "..\common.h"

CALL_COMPILE_COMMON("AI\Misc\initFunctions.sqf");

CALL_COMPILE_COMMON("AI\Action\Action.sqf");

CALL_COMPILE_COMMON("AI\ActionComposite\ActionComposite.sqf");
CALL_COMPILE_COMMON("AI\ActionCompositeParallel\ActionCompositeParallel.sqf");
CALL_COMPILE_COMMON("AI\ActionCompositeSerial\ActionCompositeSerial.sqf");

CALL_COMPILE_COMMON("AI\AI\AI.sqf");
CALL_COMPILE_COMMON("AI\AI\AI_GOAP.sqf");

CALL_COMPILE_COMMON("AI\Goal\Goal.sqf");

CALL_COMPILE_COMMON("AI\Sensor\Sensor.sqf");
CALL_COMPILE_COMMON("AI\SensorStimulatable\SensorStimulatable.sqf");

CALL_COMPILE_COMMON("AI\WorldState\WorldState.sqf");

CALL_COMPILE_COMMON("AI\WorldFact\WorldFact.sqf");

CALL_COMPILE_COMMON("AI\StimulusManager\StimulusManager.sqf");

CALL_COMPILE_COMMON("AI\Misc\databaseFunctions.sqf");

CALL_COMPILE_COMMON("AI\Misc\repairFunctions.sqf");

CALL_COMPILE_COMMON("AI\Misc\testFunctions.sqf");



// *Commander* AI
CALL_COMPILE_COMMON("AI\Commander\initClasses.sqf");

// Garrison AI classes
CALL_COMPILE_COMMON("AI\Garrison\initClasses.sqf");


// Group AI classes
CALL_COMPILE_COMMON("AI\Group\initClasses.sqf");

// Unit AI classes
CALL_COMPILE_COMMON("AI\Unit\initClasses.sqf");

// Virtual Route
// We only want to initialize it if game mode is enabled
// Because it takes much time 
#ifndef _SQF_VM
#define __INIT_VR
#endif

#ifdef GAME_MODE_DISABLE
#undef __INIT_VR
#endif

#ifdef __INIT_VR
CALL_COMPILE_COMMON("AI\VirtualRoute\init.sqf");
#endif
