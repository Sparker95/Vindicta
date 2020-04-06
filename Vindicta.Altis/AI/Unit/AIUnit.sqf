#include "common.hpp"

/*
AI class for the group

Author: Sparker 12.11.2018
*/

#define pr private

CLASS("AIUnit", "AI_GOAP")

	METHOD("new") {
		params [P_THISOBJECT];

		// Make sure that the needed MessageLoop exists
		ASSERT_GLOBAL_OBJECT(gMessageLoopGroupAI);

		// Initialize the world state
		//pr _ws = [WSP_GAR_COUNT] call ws_new; // todo WorldState size must depend on the agent
		//[_ws, WSP_GAR_AWARE_OF_ENEMY, false] call ws_setPropertyValue;

		// Initialize sensors
		pr _sensorSalute = NEW("SensorUnitSalute", [_thisObject]);
		T_CALLM("addSensor", [_sensorSalute]);

		pr _sensorCivNear = NEW("SensorUnitCivNear", [_thisObject]);
		T_CALLM("addSensor", [_sensorCivNear]);

		//T_SETV("worldState", _ws);
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                    G E T   M E S S A G E   L O O P
	// | The group AI resides in its own thread
	// ----------------------------------------------------------------------

	METHOD("getMessageLoop") {
		gMessageLoopGroupAI
	} ENDMETHOD;

	// Common interface
	/* virtual */ METHOD("getCargoUnits") {
		[]
	} ENDMETHOD;

ENDCLASS;
