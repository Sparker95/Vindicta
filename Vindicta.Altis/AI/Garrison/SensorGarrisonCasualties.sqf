#include "common.hpp"

/*
This sensor gets stimulated by destroyed units. It keeps track of those who were destroyed between update intervals. On update it relays losses to commander.
*/

#define pr private

#define UPDATE_INTERVAL 5

#define OOP_CLASS_NAME SensorGarrisonCasualties
CLASS("SensorGarrisonCasualties", "SensorGarrisonStimulatable")

	VARIABLE("destroyedUnits");
	
	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("destroyedUnits", []);
	ENDMETHOD;

	METHOD(update)
		params [P_THISOBJECT];

		// Bail if not spawned
		pr _gar = T_GETV("gar");
		if (!CALLM0(_gar, "isSpawned")) exitWith {};
		
		pr _destroyedUnits = T_GETV("destroyedUnits");
		// Don't send anything if noone was destroyed
		if (count _destroyedUnits == 0) exitWith {};
		
		pr _side = CALLM0(_gar, "getSide");
		pr _commanderAI = CALL_STATIC_METHOD("AICommander", "getAICommander", [_side]);
		
		// Send stimulus with data about destroyed units to commander
		pr _stim = STIMULUS_NEW();
		STIMULUS_SET_SOURCE(_stim, _gar);
		STIMULUS_SET_TYPE(_stim, STIMULUS_TYPE_UNITS_DESTROYED);
		STIMULUS_SET_VALUE(_stim, _destroyedUnits);
		CALLM2(_commanderAI, "postMethodAsync", "handleStimulus", [_stim]);
		
		T_SETV("destroyedUnits", []);
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                           H A N D L E   S T I M U L U S
	// | Performs sensor-specific actions if doComplexCheck has returned true
	// ----------------------------------------------------------------------
	
	METHOD(handleStimulus)
		params [P_THISOBJECT, P_ARRAY("_stimulus")];
		
		// Add the data about destroyed unit to the array, which will be sent to commander on next update
		pr _value = STIMULUS_GET_VALUE(_stimulus);
		_value params ["_unit", "_hOKiller"];
		//if (!isNull _hOKiller) then {
			pr _mainData = CALLM0(_unit, "getMainData");
			_mainData params ["_catID", "_subcatID"];
			pr _pos = CALLM0(_unit, "getPos");
			pr _destroyedUnits = T_GETV("destroyedUnits");
			_destroyedUnits pushBack [_catID, _subcatID, _hOKiller, _pos];
		//};
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  S T I M U L U S   T Y P E S
	// | Returns the array with stimulus types this sensor can be stimulated by
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD(getStimulusTypes)
		[STIMULUS_TYPE_UNIT_DESTROYED]
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                          D O   C O M P L E X  C H E C K
	// | Performs complex sensor-specific check to determine if the sensor is sensitive to the stimulus
	// ----------------------------------------------------------------------
	
	METHOD(doComplexCheck)
		params [P_THISOBJECT, P_ARRAY("_stimulus")];

		// Return true only if garrison is in combat state
		pr _AI = T_GETV("AI");

		CALLM0(_AI, "isAlerted")
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  U P D A T E   I N T E R V A L
	// | Must return the desired update rate of this sensor
	// | If it returns 0, the sensor will not be updated
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD(getUpdateInterval)
		//params [P_THISOBJECT];
		UPDATE_INTERVAL
	ENDMETHOD;

ENDCLASS;