#include "common.hpp"

#define OOP_CLASS_NAME GoalUnitIdle
CLASS("GoalUnitIdle", "GoalUnit")

	// Must return a bool, true or false, if unit can talk while doing this goal
	// Default is false;
	STATIC_METHOD(canTalk)
		true;
	ENDMETHOD;

ENDCLASS;