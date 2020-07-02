#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#include "..\common.h"

#define pr private

/*
	Retrieves a number of OOP unit variables from a unit.

	Returns empty array if failed.
*/


params["_object"];

if (side _object == civilian) exitWith {};
if !(alive _object) exitWith {};

pr _return = [];

// get current action/goal 
pr _unit = CALLSM1("Unit", "getUnitFromObjectHandle", _object);
pr _unitAI = CALLM0(_unit, "getAI");
pr _currentGoal = "";
pr _currentAction = "";

// group
pr _groupUnit = CALLM0(_unit, "getGroup");
pr _groupAI = CALLM0(_groupUnit, "getAI");
pr _currentGoalGroup = "";
pr _currentActionGroup = "";

if (_unitAI != "") then {
	_currentGoal = GETV(_unitAI, "currentGoal");
	if (_currentGoal == "") then { _currentGoal = "NO GOAL"; };
	_currentAction = CALLM0(_unitAI, "getCurrentAction");
	if (_currentAction == "") then { _currentAction = "NO ACTION"; };
};

if (_groupAI != "") then {
	_currentGoalGroup = GETV(_groupAI, "currentGoal");
	if (_currentGoalGroup == "") then { _currentGoalGroup = "NO GROUP GOAL"; };
	_currentActionGroup = CALLM0(_groupAI, "getCurrentAction");
	if (_currentActionGroup == "") then { _currentActionGroup = "NO GROUP ACTION"; };
};

_return = [_currentGoal, _currentAction, _currentGoalGroup, _currentActionGroup];

_return