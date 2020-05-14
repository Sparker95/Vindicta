#include "common.hpp"

/*
Author: Sparker
Unit will dismount his vehicle and start following his leader
*/

#define pr private

#define OOP_CLASS_NAME GoalUnitInfantryRegroup
CLASS("GoalUnitInfantryRegroup", "Goal")

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];
		CALLM1(_ai, "setAllowVehicleWSP", false);
	ENDMETHOD;

ENDCLASS;