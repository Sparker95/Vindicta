#include "common.hpp"

/*
Author: Sparker
Unit will dismount his vehicle and start following his leader
*/

#define pr private

#define OOP_CLASS_NAME GoalUnitInfantryRegroup
CLASS("GoalUnitInfantryRegroup", "GoalUnit")

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];
		CALLM1(_ai, "setAllowVehicleWSP", false);

		// We will have to move to leader, so prepare move coordinates
		pr _unit = GETV(_ai, "agent");
		pr _group = CALLM0(_unit, "getGroup");
		pr _leaderUnit = CALLM0(_group, "getLeader");
		pr _hLeader = CALLM0(_leaderUnit, "getObjectHandle");
		pr _moveRadius = 40;

		_goalParameters pushBack [TAG_MOVE_TARGET, _hLeader];
		_goalParameters pushBack [TAG_MOVE_RADIUS, _moveRadius];

		CALLM1(_ai, "setMoveTarget", _hLeader);
		CALLM1(_ai, "setMoveTargetRadius", _moveRadius);
		CALLM0(_ai, "updatePositionWSP");
	ENDMETHOD;

	// Must return a bool, true or false, if unit can talk while doing this goal
	// Default is false;
	STATIC_METHOD(canTalk)
		true;
	ENDMETHOD;

ENDCLASS;