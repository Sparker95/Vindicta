#include "common.hpp"

CLASS("Phase1CmdrStrategy", "PassiveCmdrStrategy")
	METHOD("new") {
		params [P_THISOBJECT];

		T_SETV("takeLocOutpostPriority", 0);
		T_SETV("takeLocOutpostPriorityActivityCoeff", 0);
		T_SETV("takeLocBasePriority", 0);
		T_SETV("takeLocBasePriorityActivityCoeff", 0);
		T_SETV("takeLocRoadBlockPriority", 0);
		T_SETV("takeLocRoadBlockPriorityActivityCoeff", 0);
		T_SETV("takeLocCityPriority", 0);
		T_SETV("takeLocCityPriorityActivityCoeff", 0);
	} ENDMETHOD;
ENDCLASS;
