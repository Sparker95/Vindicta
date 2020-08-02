#include "common.hpp"

#define OOP_CLASS_NAME GoalGarrisonRebalanceVehicleGroups
CLASS("GoalGarrisonRebalanceVehicleGroups", "Goal")
	public STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];

		private _ws = GETV(_AI, "worldState");

		private _allHaveDrivers = [_ws, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_DRIVERS, true] call ws_propertyExistsAndEquals;
		private _enoughHumansToDrive = [_ws, WSP_GAR_ENOUGH_HUMANS_TO_DRIVE_ALL_VEHICLES, true] call ws_propertyExistsAndEquals;
		private _allHaveTurretOperators = [_ws, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_TURRET_OPERATORS, true] call ws_propertyExistsAndEquals;
		private _enoughHumansToTurret = [_ws, WSP_GAR_ENOUGH_HUMANS_TO_TURRET_ALL_VEHICLES, true] call ws_propertyExistsAndEquals;

		private _isBalanced = [_ws, WSP_GAR_GROUPS_BALANCED, true] call ws_propertyExistsAndEquals;
		private _isAtLocation = CALLM0(GETV(_AI, "agent"), "getLocation") != NULL_OBJECT;

		if (!_allHaveDrivers && _enoughHumansToDrive ||
			!_allHaveTurretOperators && _enoughHumansToTurret ||
			// When at a location we will rebalance groups as required to make sure incoming reinforements are distributed appropriated
			!_isBalanced && _isAtLocation
		) then {
			GETSV(_thisClass, "relevance");
		} else {
			0
		};
	ENDMETHOD;
ENDCLASS;