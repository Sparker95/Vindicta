#include "common.hpp"

#define OOP_CLASS_NAME AIGroupAir
CLASS("AIGroupAir", "AIGroup")
	METHOD(getPossibleGoals)
		["GoalGroupAirLand"]
	ENDMETHOD;
ENDCLASS;