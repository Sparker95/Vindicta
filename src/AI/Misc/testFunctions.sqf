#include "..\..\common.h"
#include "..\..\Message\Message.hpp"
#include "..\Action\Action.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\defineCommon.inc"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"

#define pr private

// Makes a unit with objectHandle stop its AI brain and switch to specified action immediately
AI_misc_fnc_forceUnitAction = {
	params [ P_OBJECT("_objectHandle"), P_STRING("_actionClassName"), ["_parameters", []], ["_updateInterval", 1, [1]] ];

	// Find the AI of this objectHandle
	pr _unit = _objectHandle getVariable "__u";
	if (isNil "_unit") exitWith { diag_log "Error: object handle is not a unit!"; };

	// Get the unit's group
	pr _group = CALLM0(_unit, "getGroup");
	pr _unitAI = CALLM0(_unit, "getAI");
	pr _groupAI = CALLM0(_group, "getAI");
	if (isNil "_unitAI") exitWith {diag_log "Error: unit AI is not found!";};
	if (isNil "_groupAI") exitWith {diag_log "Error: group AI is not found!";};

	// Stop the AI brain of this unit's group
	CALLM0(_groupAI, "stop");

	// Create an action for this AI
	pr _args = [_unitAI, _parameters];
	pr _action = NEW(_actionClassName, _args);

	// Make this action autonomous
	CALLM1(_action, "setAutonomous", _updateInterval);

	// Return the created action
	_action
};

/*
Example:
_unit = cursorObject;
_actionClassName = "ActionUnitSalute";
_parameters = player;
_interval = 1;
CALL_COMPILE_COMMON("AI\Misc\testFunctions.sqf");
_Action = [_unit, _actionClassName, _parameters, _interval] call AI_misc_fnc_forceUnitAction;
_action
*/







// Makes a group which has a unit with objectHandle stop its AI brain and switch to specified action immediately
AI_misc_fnc_forceGroupAction = {
	params [ P_OBJECT("_objectHandle"), P_STRING("_actionClassName"), ["_parameters", []], ["_updateInterval", 3, [1]] ];

	// Find the AI of this objectHandle
	pr _unit = _objectHandle getVariable "__u";
	if (isNil "_unit") exitWith { diag_log "Error: object handle is not a unit!"; };

	// Get the unit's group
	pr _group = CALLM0(_unit, "getGroup");
	pr _unitAI = CALLM0(_unit, "getAI");
	pr _groupAI = CALLM0(_group, "getAI");
	if (isNil "_unitAI") exitWith {diag_log "Error: unit AI is not found!";};
	if (isNil "_groupAI") exitWith {diag_log "Error: group AI is not found!";};

	// Stop the AI brain of this unit's group
	CALLM0(_groupAI, "stop");

	// Create an action for this group AI
	pr _args = [_groupAI, _parameters];
	pr _action = NEW(_actionClassName, _args);

	// Make this action autonomous
	CALLM1(_action, "setAutonomous", _updateInterval);

	// Return the created action
	_action
};
/*
_unit = cursorObject;
_actionClassName = "ActionGroupGetInVehiclesAsCrew";
_parameters = [];
_interval = 2;
CALL_COMPILE_COMMON("AI\Misc\testFunctions.sqf");
_Action = [_unit, _actionClassName, _parameters, _interval] call AI_misc_fnc_forceGroupAction;
_action
*/





// Adds a goal to the group of the unit with given object handle
AI_misc_fnc_addGroupGoal = {
	params [ P_OBJECT("_objectHandle"), P_STRING("_goalClassName"), ["_parameters", []]];

	// Find the AI of this objectHandle
	pr _unit = _objectHandle getVariable "__u";
	if (isNil "_unit") exitWith { diag_log "Error: object handle is not a unit!"; };

	// Get the unit's group
	pr _group = CALLM0(_unit, "getGroup");
	pr _unitAI = CALLM0(_unit, "getAI");
	pr _groupAI = CALLM0(_group, "getAI");
	if (isNil "_unitAI") exitWith {diag_log "Error: unit AI is not found!";};
	if (isNil "_groupAI") exitWith {diag_log "Error: group AI is not found!";};

	CALLM4(_groupAI, "addExternalGoal", _goalClassName, 0, _parameters, gAICommanderEast);
};
/*
_unit = cursorObject;
_goalClassName = "GoalGroupGetInVehiclesAsCrew";
_parameters = [];
CALL_COMPILE_COMMON("AI\Misc\testFunctions.sqf");
[_unit, _goalClassName, _parameters] call AI_misc_fnc_addGroupGoal;
*/


AI_misc_fnc_addGarrisonGoal = {
	params [ P_OBJECT("_objectHandle"), P_STRING("_goalClassName"), ["_parameters", []]];

	pr _unit = _objectHandle getVariable "__u";
	if (isNil "_unit") exitWith { diag_log "Error: object handle is not a unit!"; };

	// Get the unit's garrison
	pr _gar = CALLM0(_unit, "getGarrison");
	pr _goalSource = gAICommanderWest;
	pr _garAI = CALLM0(_gar, "getAI");
	if (isNil "_garAI") exitWith {diag_log "Error: garrison AI is not found!";};

	// Delete previously given external goals
	//CALLM2(_garAI, "deleteExternalGoal", "", _goalSource);

	CALLM(_garAI, "postMethodAsync", ["addExternalGoal" ARG [_goalClassName ARG 0 ARG _parameters ARG _goalSource]]);

	_gar
};

/*
_unit = cursorObject;
_goalClassName = "GoalGarrisonMove";
_parameters = [];
CALL_COMPILE_COMMON("AI\Misc\testFunctions.sqf");
[_unit, _goalClassName, _parameters] call AI_misc_fnc_addGarrisonGoal;
*/
