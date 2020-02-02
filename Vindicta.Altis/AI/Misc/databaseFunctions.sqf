#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#define OFSTREAM_FILE "AI.rpt"
#include "..\..\OOP_Light\OOP_Light.h"

/*
These functions help initialize various properties of goals and actions from a single file in a more human-readable way.
*/

#define pr private

AI_misc_fnc_setGoalIntrinsicRelevance = {
	params [["_goalClass", "", [""]], ["_relevance", 0, [0]]];
	SET_STATIC_VAR(_goalClass, "relevance", _relevance);
};

AI_misc_fnc_setGoalPredefinedAction = {
	params [["_goalClass", "", [""]], ["_actionClass", "", [""]]];
	SET_STATIC_VAR(_goalClass, "predefinedAction", _actionClass);
};

AI_misc_fnc_setGoalEffects = {
	params [["_goalClass", "", [""]], ["_size", 0, [0]], ["_effectsArray", [], [[]]]];
	
	// Create a new world state
	pr _ws = [_size] call ws_new;
	
	// Set world state parameters from the effects array
	{
		if (count _x == 0) exitWith {
			OOP_ERROR_1("setGoalEffects: wrong parameters: %1", _this);
		};

		_x params ["_key", "_value", ["_isParameter", false]];
		if (_isParameter) then {
			[_ws, _key, _value] call ws_setPropertyGoalParameterTag;
		} else {
			[_ws, _key, _value] call ws_setPropertyValue;
		};
	} forEach _effectsArray;
	
	// Set static variable for the goal
	SET_STATIC_VAR(_goalClass, "effects", _ws);
};

AI_misc_fnc_setActionEffects = {
	params [["_actionClass", "", [""]], ["_size", 0, [0]], ["_effectsArray", [], [[]]]];

	// Create a new world state
	pr _ws = [_size] call ws_new;
	
	// Set world state parameters from the effects array
	{
		if (count _x == 0) exitWith {
			OOP_ERROR_1("setActionEffects: wrong parameters: %1", _this);
		};

		_x params ["_key", "_value", ["_isParameter", false]];
		if (_isParameter) then {
			[_ws, _key, _value] call ws_setPropertyActionParameterTag;
		} else {
			[_ws, _key, _value] call ws_setPropertyValue;
		};
	} forEach _effectsArray;
	
	// Set static variable for the goal
	SET_STATIC_VAR(_actionClass, "effects", _ws);
};

AI_misc_fnc_setActionPreconditions = {
	params [["_actionClass", "", [""]], ["_size", 0, [0]], ["_preconditionsArray", [], [[]]]];
	
	// Create a new world state
	pr _ws = [_size] call ws_new;
	
	// Set world state parameters from the effects array
	{
		if (count _x == 0) exitWith {
			OOP_ERROR_1("setActionPreconditions: wrong parameters: %1", _this);
		};

		_x params ["_key", "_value", ["_isParameter", false]];
		if (_isParameter) then {
			[_ws, _key, _value] call ws_setPropertyActionParameterTag;
		} else {
			[_ws, _key, _value] call ws_setPropertyValue;
		};
	} forEach _preconditionsArray;
	
	// Set static variable for the goal
	SET_STATIC_VAR(_actionClass, "preconditions", _ws);
};

AI_misc_fnc_setActionParametersFromGoal = {
	params [["_actionClass", "", [""]], ["_goalParameterTagsArray", [], [[]]]];
	pr _parameters = [];
	{
		_parameters pushBack [_x, nil];
	} forEach _goalParameterTagsArray;
	SET_STATIC_VAR(_actionClass, "parameters", _parameters);
};

AI_misc_fnc_setActionPrecedence = {
	params [["_actionClass", "", [""]], ["_precedence", 0, [0]] ];
	SET_STATIC_VAR(_actionClass, "precedence", _precedence);
};

AI_misc_fnc_setActionCost = {
	params [["_actionClass", "", [""]], ["_cost", 0, [0]]];
	
	// Set the static variable
	SET_STATIC_VAR(_actionClass, "cost", _cost);
};

AI_misc_fnc_setActionCostAndPrecedence = {
	params [["_actionClass", "", [""]], ["_cost", 0, [0]], ["_precedence", 0, [0]]];
	
	// Set the static variable
	SET_STATIC_VAR(_actionClass, "cost", _cost);
	SET_STATIC_VAR(_actionClass, "precedence", _precedence);
};