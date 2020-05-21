#include "common.hpp"
FIX_LINE_NUMBERS()
/*
Author: Sparker
Unit will dismount his vehicle if he's in one, walk to a vehicle and repair it.

parameters: "vehicle" - <Unit> of the vehicle that needs repairs
*/

#define pr private

#define OOP_CLASS_NAME GoalUnitRepairVehicle
CLASS("GoalUnitRepairVehicle", "Goal")

	// ----------------------------------------------------------------------
	// |            C R E A T E   P R E D E F I N E D   A C T I O N
	// ----------------------------------------------------------------------
	// By default it gets predefined action from database if it is defined and creates it, passing a goal parameter to action parameter, if it exists
	// This method must be redefined for goals that have predefined actions that require parameters not from goal parameters

	/* virtual */ STATIC_METHOD(createPredefinedAction)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		pr _vehicleUnit = CALLSM2("Action", "getParameterValue", _parameters, "vehicle");

		pr _hO = GETV(_AI, "hO");

		// Create a serial action to add other actions to
		pr _actionSerial = NEW("ActionCompositeSerial", [_AI]);

		// Check if the unit has been assigned to any vehicle
		pr _vehicle = CALLM0(_AI, "getAssignedVehicle");

		// Add dismount action
		if (_vehicle != NULL_OBJECT || !(vehicle _hO isEqualTo _hO)) then {
			pr _actionDismount = NEW("ActionUnitDismountCurrentVehicle", [_AI ARG _parameters]);
			CALLM1(_actionSerial, "addSubactionToBack", _actionDismount);
		};

		// Add move to unit action
		pr _params = [
			["unit", _vehicleUnit],
			["teleport", true]
		];
		CALLSM2("Action", "mergeParameterValues", _params, _parameters);
		pr _actionMove = NEW("ActionUnitInfantryMoveToUnit", [_AI ARG _params]);
		CALLM1(_actionSerial, "addSubactionToBack", _actionMove);

		// Add repair vehicle action
		pr _params = [
			["vehicle", _vehicleUnit]
		];
		CALLSM2("Action", "mergeParameterValues", _params, _parameters);
		pr _actionRepair = NEW("ActionUnitRepairVehicle", [_AI ARG _params]);
		CALLM1(_actionSerial, "addSubactionToBack", _actionRepair);

		_actionSerial

	ENDMETHOD;

ENDCLASS;