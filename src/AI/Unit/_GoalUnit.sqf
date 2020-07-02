#include "common.hpp"

// Class with predefined actions in initDatabase.sqf
#define OOP_CLASS_NAME GoalGroup
CLASS("GoalUnit", "Goal")

	// Must return a bool, true or false, if unit can talk while doing this goal
	// Default is false;
	STATIC_METHOD(canTalk)
		false;
	ENDMETHOD;

ENDCLASS;
