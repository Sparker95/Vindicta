#include "common.hpp"

/*
Author: Sparker
*/

#define pr private

#define OOP_CLASS_NAME GoalUnitGetInVehicle
CLASS("GoalUnitGetInVehicle", "GoalUnit")

	STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET_VEHICLE_UNIT, [NULL_OBJECT]],  [TAG_VEHICLE_ROLE, [""]] ],	// Required parameters
			[ [TAG_TURRET_PATH, [[]]], [TAG_MOVE_RADIUS, [0]] ]	// Optional parameters
		]
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		// Vehicle usage is allowed
		CALLM1(_ai, "setAllowVehicleWSP", true);

		// Otherwise bots are not be able to move close to vehicle
		// when in combat
		_goalParameters pushBack [TAG_MOVE_RADIUS, 25];

		// Assign vehicle now
		pr _unitVeh = GET_PARAMETER_VALUE(_goalParameters, TAG_TARGET_VEHICLE_UNIT);
		pr _vehRole = GET_PARAMETER_VALUE(_goalParameters, TAG_VEHICLE_ROLE);
		pr _turretPath = GET_PARAMETER_VALUE_DEFAULT(_goalParameters, TAG_TURRET_PATH, []);
		CALLM3(_ai, "_assignVehicle", _vehRole, _turretPath, _unitVeh);

		// Force update of vehicle world state property
		CALLM0(_ai, "updateVehicleWSP");
	ENDMETHOD;

ENDCLASS;