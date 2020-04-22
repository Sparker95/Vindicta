#include "..\config\global_config.hpp"

call compile preprocessFileLineNumbers "AI\Misc\initFunctions.sqf";

call compile preprocessFileLineNumbers "AI\Action\Action.sqf";

call compile preprocessFileLineNumbers "AI\ActionComposite\ActionComposite.sqf";
call compile preprocessFileLineNumbers "AI\ActionCompositeParallel\ActionCompositeParallel.sqf";
call compile preprocessFileLineNumbers "AI\ActionCompositeSerial\ActionCompositeSerial.sqf";

call compile preprocessFileLineNumbers "AI\AI\AI.sqf";
call compile preprocessFileLineNumbers "AI\AI\AI_GOAP.sqf";

call compile preprocessFileLineNumbers "AI\Goal\Goal.sqf";

call compile preprocessFileLineNumbers "AI\Sensor\Sensor.sqf";
call compile preprocessFileLineNumbers "AI\SensorStimulatable\SensorStimulatable.sqf";

call compile preprocessFileLineNumbers "AI\WorldState\WorldState.sqf";

call compile preprocessFileLineNumbers "AI\WorldFact\WorldFact.sqf";

call compile preprocessFileLineNumbers "AI\StimulusManager\StimulusManager.sqf";

call compile preprocessFileLineNumbers "AI\Misc\databaseFunctions.sqf";

call compile preprocessFileLineNumbers "AI\Misc\repairFunctions.sqf";

call compile preprocessFileLineNumbers "AI\Misc\testFunctions.sqf";



// *Commander* AI
call compile preprocessFileLineNumbers "AI\Commander\initClasses.sqf";

// Garrison AI classes
call compile preprocessFileLineNumbers "AI\Garrison\initClasses.sqf";


// Group AI classes
call compile preprocessFileLineNumbers "AI\Group\initClasses.sqf";

// Unit AI classes
call compile preprocessFileLineNumbers "AI\Unit\initClasses.sqf";

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
call compile preprocessFileLineNumbers "AI\VirtualRoute\init.sqf";
#endif
