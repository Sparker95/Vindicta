#define OOP_ERROR
#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "..\AI\Stimulus\Stimulus.hpp"
#include "..\AI\StimulusTypes.hpp"
#include "Unit.hpp"

/*
Killed EH for units. Its main job is to send messages to objects. 
*/

#define pr private

params ["_objectHandle", "_killer", "_instigator", "_useEffects"];

// Is this object an instance of Unit class?
private _thisObject = CALL_STATIC_METHOD("Unit", "getUnitFromObjectHandle", [_objectHandle]);

diag_log format ["[Unit::EH_killed] Info: %1 %2", _thisObject, GETV(_thisObject, "data")];

if (_thisObject != "") then {
	// Since this code is run in event handler context, we can't delete the unit from the group and garrison directly.
	
	// Post a message to the garrison of the unit
	pr _data = GETV(_thisObject, "data");
	pr _garrison = _data select UNIT_DATA_ID_GARRISON;
	if (_garrison != "") then {	// Sanity check	
		CALLM2(_garrison, "postMethodAsync", "handleUnitKilled", [_thisObject]);
		
		// Send stimulus to garrison's casualties sensor
		pr _garAI = CALLM0(_garrison, "getAI");
		if (_garAI != "") then {
			if (!isNull _killer) then { // If there is an existing killer
				pr _stim = STIMULUS_NEW();
				STIMULUS_SET_TYPE(_stim, STIMULUS_TYPE_thisObject_DESTROYED);
				pr _value = [_thisObject, _killer];
				STIMULUS_SET_VALUE(_stim, _value);
				CALLM2(_garAI, "postMethodAsync", "handleStimulus", [_stim]);
			};
		};
	} else {
		diag_log format ["[Unit::EH_killes.sqf] Error: Unit is not attached to a garrison: %1, %2", _thisObject, _data];
	};
};