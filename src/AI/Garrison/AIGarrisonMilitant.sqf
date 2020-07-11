#include "common.hpp"

#define OOP_CLASS_NAME AIGarrisonMilitant
CLASS("AIGarrisonMilitant", "AIGarrison")

    public override METHOD(getPossibleGoals)
        [
			"GoalGarrisonDefendActive",
			"GoalGarrisonDefendPassive",
			"GoalGarrisonRelax"
        ];
	ENDMETHOD;

	public override METHOD(getPossibleActions)
        [
			"ActionGarrisonClearArea",
			"ActionGarrisonJoinLocation",
			"ActionGarrisonMergeVehicleGroups",
			"ActionGarrisonMountCrew",
			"ActionGarrisonMountInfantry",
			"ActionGarrisonMoveCombined",
			"ActionGarrisonMoveDismounted",
			"ActionGarrisonMoveMounted",
			"ActionGarrisonRebalanceGroups",
			"ActionGarrisonRepairAllVehicles",
			"ActionGarrisonSplitVehicleGroups"
		]
	ENDMETHOD;

ENDCLASS;