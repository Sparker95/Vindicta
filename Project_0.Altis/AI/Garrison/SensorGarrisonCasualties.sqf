#include "common.hpp"

/*
This sensor gets stimulated by destroyed units. It keeps track of those who were destroyed between update intervals. On update it relays losses to commander.
*/

#define pr private

#define UPDATE_INTERVAL 5

CLASS("SensorGarrisonCasualties", "SensorGarrisonStimulatable")

	VARIABLE("destroyedUnits");
	
	METHOD("new") {
		params [["_thisObject", "", [""]]];
		T_SETV("destroyedUnits", []);
	} ENDMETHOD;

	METHOD("update") {
		params [["_thisObject", "", [""]]];
		
		pr _destroyedUnits = T_GETV("destroyedUnits");
		// Don't send anything if noone was destroyed
		if (count _destroyedUnits == 0) exitWith {};
		
		pr _gar = T_GETV("gar");
		pr _side = CALLM0(_gar, "getSide");
		pr _commanderAI = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_side]);
		
		// Send stimulus with data about destroyed units to commander
		pr _stim = STIMULUS_NEW();
		STIMULUS_SET_SOURCE(_stim, _gar);
		STIMULUS_SET_TYPE(_stim, STIMULUS_TYPE_UNITS_DESTROYED);
		STIMULUS_SET_VALUE(_stim, _destroyedUnits);
		CALLM2(_commanderAI, "postMethodAsync", "handleStimulus", [_stim]);
		
		T_SETV("destroyedUnits", []);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                           H A N D L E   S T I M U L U S
	// | Performs sensor-specific actions if doComplexCheck has returned true
	// ----------------------------------------------------------------------
	
	METHOD("handleStimulus") {
		params [["_thisObject", "", [""]], ["_stimulus", [], [[]]]];
		
		// Add the data about destroyed unit to the array, which will be sent to commander on next update
		pr _value = STIMULUS_GET_VALUE(_stimulus);
		_value params ["_unit", "_hOKiller"];
		if (!isNull _hOKiller) then {
			pr _mainData = CALLM0(_unit, "getMainData");
			_mainData params ["_catID", "_subcatID"];
			pr _destroyedUnits = T_GETV("destroyedUnits");
			_destroyedUnits pushBack [_catID, _subcatID, _hOKiller];
		};
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  S T I M U L U S   T Y P E S
	// | Returns the array with stimulus types this sensor can be stimulated by
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("getStimulusTypes") {
		[STIMULUS_TYPE_UNIT_DESTROYED]
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                          D O   C O M P L E X  C H E C K
	// | Performs complex sensor-specific check to determine if the sensor is sensitive to the stimulus
	// ----------------------------------------------------------------------
	
	METHOD("doComplexCheck") {
		params [["_thisObject", "", [""]], ["_stimulus", [], [[]]]];
		
		// Return true only if garrison is in combat state
		pr _garAI = T_GETV("AI");
		pr _ws = GETV(_garAI, "worldState");
		pr _ret = [_ws, WSP_GAR_AWARE_OF_ENEMY] call ws_getPropertyValue;
		
		_ret
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  U P D A T E   I N T E R V A L
	// | Must return the desired update rate of this sensor
	// | If it returns 0, the sensor will not be updated
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("getUpdateInterval") {
		//params [ ["_thisObject", "", [""]]];
		UPDATE_INTERVAL
	} ENDMETHOD;

ENDCLASS;