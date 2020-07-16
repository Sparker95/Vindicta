#include "common.hpp"

#define OOP_CLASS_NAME AIGarrisonAir
CLASS("AIGarrisonAir", "AIGarrison")

    public override METHOD(getPossibleGoals)
        [
            "GoalGarrisonDefendActive",
            "GoalGarrisonDefendPassive",
            "GoalGarrisonRebalanceVehicleGroups",
            "GoalGarrisonRelax",
            "GoalGarrisonLand",
            "GoalGarrisonAirRtB"
        ];
	ENDMETHOD;

	public override METHOD(getPossibleActions)
        [
            "ActionGarrisonClearArea",
            "ActionGarrisonJoinLocation",
            "ActionGarrisonMergeVehicleGroups",
            "ActionGarrisonMountCrew",
            "ActionGarrisonMountInfantry",
            "ActionGarrisonMoveDismounted",
            "ActionGarrisonMoveMounted",
            "ActionGarrisonRebalanceGroups",
            "ActionGarrisonRepairAllVehicles",
            "ActionGarrisonSplitVehicleGroups"
        ];
	ENDMETHOD;

ENDCLASS;