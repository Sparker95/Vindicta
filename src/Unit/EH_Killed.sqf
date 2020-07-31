#include "..\common.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "..\AI\Stimulus\Stimulus.hpp"
#include "..\AI\StimulusTypes.hpp"
#include "Unit.hpp"

/*
Executed in unscheduled when a unit is destroyed.
*/

params ["_unit", "_killer", "_instigator", "_useEffects"];

OOP_INFO_1("EH_Killed: %1", _this);

// Fix for ACE
_killer = if (isNull _killer) then {
		_unit getVariable ["ace_medical_lastDamageSource", _killer];
	} else {
		_killer 
	};

_this set [1, _killer];

// make it possible to ace interact with the unit again
[objNull, _unit] call ace_common_fnc_claim;

CALLM2(gMessageLoopMainManager, "postMethodAsync", "EH_Killed", _this);