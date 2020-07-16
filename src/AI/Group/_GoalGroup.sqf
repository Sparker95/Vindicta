#include "common.hpp"

// Class with predefined actions in initDatabase.sqf
#define OOP_CLASS_NAME GoalGroup
CLASS("GoalGroup", "Goal")
	STATIC_METHOD(getCommonParameters)
		[
			[],	// Required parameters
			[ [TAG_BEHAVIOUR, [""]], [TAG_COMBAT_MODE, [""]], [TAG_FORMATION, [""]], [TAG_SPEED_MODE, [""]], [TAG_INSTANT, [false]] ]	// Optional parameters
		]
	ENDMETHOD;
ENDCLASS;
