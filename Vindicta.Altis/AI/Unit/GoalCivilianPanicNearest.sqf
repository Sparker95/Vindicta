#include "common.hpp"

#define pr private

/*
Unit will try to hide in some nearby spot
*/

#define OOP_CLASS_NAME GoalCivilianPanicNearest
CLASS("GoalCivilianPanicNearest", "GoalUnit")

	STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_MOVE_TARGET, [[], objNull, NULL_OBJECT]] ],	// Required parameters
			[ [TAG_MOVE_RADIUS, [0]] ]	// Optional parameters
		]
	ENDMETHOD;

	STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];

		// Panic if in danger
		pr _ws = GETV(_ai, "worldState");
		if (WS_GET(_ws, WSP_UNIT_HUMAN_IN_DANGER)) then {
			GETSV(_thisClass, "relevance");
		} else {
			0
		};
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		// Vehicle usage is forbidden
		CALLM1(_ai, "setAllowVehicleWSP", false);

		// Select a random waypoint, create action to move there
		pr _hO = CALLM0(GETV(_AI, "agent"), "getObjectHandle");
		pr _cp = GETV(_AI, "civPresence");
		pr _pos = CALLM1(_cp, "getNearestSafeSpot", getPos _hO);
		
		_goalParameters pushBack [TAG_MOVE_TARGET, _pos];
		_goalParameters pushBack [TAG_MOVE_RADIUS, 5];

		CALLM1(_ai, "setMoveTarget", _pos);
		CALLM1(_ai, "setMoveTargetRadius", 5);
		CALLM0(_ai, "updatePositionWSP");
	ENDMETHOD;

ENDCLASS;