#include "common.hpp"

#define pr private

#define OOP_CLASS_NAME GoalCivilianWander
CLASS("GoalCivilianWander", "Goal")

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		// Vehicle usage is forbidden
		CALLM1(_ai, "setAllowVehicleWSP", false);

		// Force speed, stance, ...
		pr _hO = CALLM0(GETV(_AI, "agent"), "getObjectHandle");
		_hO forcespeed -1;
		_hO forceWalk true;
		_hO setUnitPosWeak "UP";
		//_hO switchAction "Default";

		// Select a random waypoint, create action to move there
		pr _cp = GETV(_AI, "civPresence");
		pr _pos = CALLM0(_cp, "getRandomWaypoint");

		_goalParameters pushBack [TAG_MOVE_TARGET, _pos];
		_goalParameters pushBack [TAG_MOVE_RADIUS, 5];

		CALLM1(_ai, "setMoveTarget", _pos);
		CALLM1(_ai, "setMoveTargetRadius", 5);
		CALLM0(_ai, "updatePositionWSP");
	ENDMETHOD;

ENDCLASS;