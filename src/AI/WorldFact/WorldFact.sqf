#include "WorldFact.hpp"
#include "..\..\common.h"

#define pr private

/*
Routines to work with world facts

Author: Sparker 24.11.2018
*/

wf_fnc_matchesQuery = {
	params [P_ARRAY("_fact"), P_ARRAY("_query") ];
	
	scopeName "s";
	
	_fact params ["_ftype", "_fval", "_fimp", "_fsrc", "_fpos"];
	_query params ["_qtype", "_qval", "_qimp", "_qsrc", "_qpos"];
	
	// Check type
	if (! (_qtype isEqualTo WF_TYPE_DEFAULT)) then {
		if (! (_qtype isEqualTo _ftype)) then {false breakOut "s";};
	};
	
	// Check value
	if (! (_qval isEqualTo WF_VALUE_DEFAULT)) then {
		if (! (_qval isEqualTo _fval)) then {false breakOut "s";};
	};
	
	// Check source
	if (! (_qsrc isEqualTo WF_SOURCE_DEFAULT)) then {
		if (! (_qsrc isEqualTo _fsrc)) then {false breakOut "s";};
	};
	
	// Check pos
	if (! (_qpos isEqualTo WF_SOURCE_DEFAULT)) then {
		if (! (_qpos isEqualTo _fpos)) then {false breakOut "s";};
	};
	
	// A perfect match
	true
};

// Returns true if the fact's lifetime has exceeded the current time
wf_fnc_hasExpired = {
	params [P_ARRAY("_fact")];
	pr _lifetime = _fact select WF_ID_LIFETIME;
	
	// Facts with lifetime of 0 live infinitely
	if (_lifetime == 0) exitWith {false};
	
	pr _lut = _fact select WF_ID_LAST_UPDATE_TIME; // Last Update Time
	// Return true if time between last update and current time is more than lifetime of this fact
	(GAME_TIME - _lut) > _lifetime
};

wf_fnc_setType = {
	params [P_ARRAY("_fact"), ["_type", 0, [WF_TYPE_DEFAULT]] ];
	_fact set [WF_ID_TYPE, _type];
};

wf_fnc_setValue = {
	params [P_ARRAY("_fact"), ["_value", 0, WF_VALUE_TYPES] ];
	_fact set [WF_ID_VALUE, _value];
};

wf_fnc_setRelevance = {
	params [P_ARRAY("_fact"), ["_importance", 0, [WF_RELEVANCE_DEFAULT]] ];
	_fact set [WF_ID_RELEVANCE, _importance];
};

wf_fnc_setSource = {
	params [P_ARRAY("_fact"), ["_source", 0, [WF_SOURCE_DEFAULT]] ];
	_fact set [WF_ID_SOURCE, _source];
};

wf_fnc_setPos = {
	params [P_ARRAY("_fact"), ["_POS", 0, [[]]] ];
	_fact set [WF_ID_POS, _POS];
};

wf_fnc_resetLastUpdateTime = {
	params [P_ARRAY("_fact")];
	_fact set [WF_ID_LAST_UPDATE_TIME, GAME_TIME];
};

wf_fnc_setLifetime = {
	params [P_ARRAY("_fact"), P_NUMBER("_lifetime") ];
	_fact set [WF_ID_LIFETIME, _lifetime];
};