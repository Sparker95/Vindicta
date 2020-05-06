#include "common.hpp"

#define pr private

#define OOP_CLASS_NAME GoalCivilianWander
CLASS("GoalCivilianWander", "Goal")

	/* override */ STATIC_METHOD(createPredefinedAction)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		// Force speed, stance, ...
		pr _hO = CALLM0(GETV(_AI, "agent"), "getObjectHandle");
		_hO forcespeed -1;
		_hO forceWalk true;
		_hO setUnitPosWeak "UP";
		//_hO switchAction "Default";

		// Select a random waypoint, create action to move there
		pr _cp = GETV(_AI, "civPresence");
		pr _pos = CALLM0(_cp, "getRandomWaypoint");
		pr _args = [_AI, [[TAG_POS, _pos], [TAG_MOVE_RADIUS, 10]]];
		pr _actionMove = NEW("ActionUnitInfantryMove", _args);

		_actionMove
	ENDMETHOD;

ENDCLASS;