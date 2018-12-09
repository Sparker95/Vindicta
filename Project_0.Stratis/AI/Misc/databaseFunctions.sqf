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
		_x params ["_key", "_value", ["_isParameter", false]];
		if (_isParameter) then {
			[_ws, _key, _value] call ws_setPropertyParameterID;
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
		_x params ["_key", "_value", ["_isParameter", false]];
		if (_isParameter) then {
			[_ws, _key, _value] call ws_setPropertyParameterID;
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
		_x params ["_key", "_value", ["_isParameter", false]];
		if (_isParameter) then {
			[_ws, _key, _value] call ws_setPropertyParameterID;
		} else {
			[_ws, _key, _value] call ws_setPropertyValue;
		};
	} forEach _preconditionsArray;
	
	// Set static variable for the goal
	SET_STATIC_VAR(_actionClass, "preconditions", _ws);
};

AI_misc_fnc_setActionCost = {
	params [["_actionClass", "", [""]], ["_cost", 0, [0]]];
	
	// Set the static variable
	SET_STATIC_VAR(_actionClass, "cost", _cost);
};