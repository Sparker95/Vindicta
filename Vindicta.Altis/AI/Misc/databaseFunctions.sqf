#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#define OFSTREAM_FILE "AI.rpt"
#include "..\..\common.h"
#include "..\AI\AI.hpp"

/*
These functions help initialize various properties of goals and actions from a single file in a more human-readable way.
*/

#define pr private

AI_misc_fnc_setGoalIntrinsicRelevance = {
	params [P_STRING("_goalClass"), P_NUMBER("_relevance")];
	SETSV(_goalClass, "relevance", _relevance);
};

AI_misc_fnc_setGoalPredefinedAction = {
	params [P_STRING("_goalClass"), P_STRING("_actionClass")];
	SETSV(_goalClass, "predefinedAction", _actionClass);
};

AI_misc_fnc_setGoalEffects = {
	params [P_STRING("_goalClass"), P_NUMBER("_size"), P_ARRAY("_effectsArray")];
	
	// Create a new world state
	// Mark values as originating from goal
	pr _ws = [_size, ORIGIN_GOAL_WS] call ws_new;
	
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
	SETSV(_goalClass, "effects", _ws);
};

AI_misc_fnc_setActionEffects = {
	params [P_STRING("_actionClass"), P_NUMBER("_size"), P_ARRAY("_effectsArray")];

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
	SETSV(_actionClass, "effects", _ws);
};

AI_misc_fnc_setActionPreconditions = {
	params [P_STRING("_actionClass"), P_NUMBER("_size"), P_ARRAY("_preconditionsArray")];
	
	// Create a new world state
	// Precondition values are static
	pr _ws = [_size, ORIGIN_STATIC_VALUE] call ws_new;
	
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
	SETSV(_actionClass, "preconditions", _ws);
};

AI_misc_fnc_setActionParametersFromGoalRequired = {
	params [P_STRING("_actionClass"), P_ARRAY("_goalParameterTagsArray")];
	pr _parameters = [];
	{
		_parameters pushBack [_x, _x, ORIGIN_GOAL_PARAMETER];
	} forEach _goalParameterTagsArray;
	SETSV(_actionClass, "parametersFromGoal", _parameters);
};

AI_misc_fnc_setActionParametersFromGoalOptional = {
	params [P_STRING("_actionClass"), P_ARRAY("_goalParameterTagsArray")];
	pr _parameters = [];
	{
		_parameters pushBack [_x, _x, ORIGIN_GOAL_PARAMETER];
	} forEach _goalParameterTagsArray;
	SETSV(_actionClass, "parametersFromGoalOptional", _parameters);
};

AI_misc_fnc_setActionPrecedence = {
	params [P_STRING("_actionClass"), P_NUMBER("_precedence") ];
	SETSV(_actionClass, "precedence", _precedence);
};

AI_misc_fnc_setActionNonInstant = {
	params [P_STRING("_actionClass")];
	SETSV(_actionClass, "nonInstant", true);
};

AI_misc_fnc_setActionCost = {
	params [P_STRING("_actionClass"), P_NUMBER("_cost")];
	
	// Set the static variable
	SETSV(_actionClass, "cost", _cost);
};

AI_misc_fnc_setActionCostAndPrecedence = {
	params [P_STRING("_actionClass"), P_NUMBER("_cost"), P_NUMBER("_precedence")];
	
	// Set the static variable
	SETSV(_actionClass, "cost", _cost);
	SETSV(_actionClass, "precedence", _precedence);
};