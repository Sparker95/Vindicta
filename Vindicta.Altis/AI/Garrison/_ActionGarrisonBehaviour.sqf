#include "common.hpp"

/*
Class: ActionGarrisonBehaviour
Serves as a base class for behaviour-like garrison actions (relax, defend, clear area, ...)
Garrison action.
*/

#define pr private

#define OOP_CLASS_NAME ActionGarrisonBehaviour
CLASS("ActionGarrisonBehaviour", "ActionGarrison")

	// Array of buildings we are currently attacking
	VARIABLE("buildingsAttack");

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("buildingsAttack", []);
	ENDMETHOD;

	// Gives goals to groups to attack enemy buildings
	METHOD(attackEnemyBuildings)
		params [P_THISOBJECT, ["_groups", 0, [0, []]]];

		pr _AI = T_GETV("AI");
		pr _gar = T_GETV("gar");

		if(_groups isEqualTo 0) then {
			_groups = CALLM0(_gar, "getGroups");
		};

		// Try to attack buildings in which enemies are hiding
		pr _garPos = CALLM0(_AI, "getPos");
		pr _buildingsWeAreAttacking = T_GETV("buildingsAttack");
		pr _buildingsWithTargets = GETV(_AI, "buildingsWithTargets") select {(_garPos distance2D _garPos < 250) && (!(_x in _buildingsWeAreAttacking))}; // Select only buildings reasonably close
		if (count _buildingsWithTargets > 0) then {

			OOP_INFO_0("Processing buildings with targets...");

			//OOP_INFO_1("  Buildings with targets: %1", _buildingsWithTargets);

			pr _loc = CALLM0(_gar, "getLocation");
			pr _locBuildings = [];
			if (_loc != NULL_OBJECT) then { _locBuildings = CALLM0(_loc, "getOpenBuildings"); };

			// Select groups which can be given this goal
			// They must not be guarding/attempting to enter another building already
			// They must not be assigned to one of the important buildings at this location
			pr _freeGroups = CALLM0(_gar, "getGroups") select {
				if ( CALLM0(_x, "getType") == GROUP_TYPE_INF ) then {
					pr _groupAI = CALLM0(_x, "getAI");
					pr _goalState = CALLM2(_groupAI, "getExternalGoalActionState", "GoalGroupGetInBuilding", _AI);
					OOP_INFO_2("   %1 goal state: %2", _groupAI, _goalState);
					if (_goalState in [ACTION_STATE_COMPLETED, ACTION_STATE_FAILED, -1]) then { // Goal is either completed, failed, or not given
						pr _goalParams = CALLM2(_groupAI, "getExternalGoalParameters", "GoalGroupGetInBuilding", _AI);
						OOP_INFO_2("   %1 goal params: %2", _groupAI, _goalParams);
						if (count _goalParams > 0) then {
							!(_goalParams#0#1 in _locBuildings) // The building guarded by this group is not one of the location's buildings
						} else {
							true // This action wasn't given
						};
					} else {
						false
					};
				} else {
					false
				};
			};

			OOP_INFO_1("  Free groups: %1", _freeGroups);

			// Try to give goals for groups to attack these buildings
			pr _i = 0;
			while { (count _freeGroups > 0) && (count _buildingsWithTargets > 0)} do {
				pr _group = _freeGroups#0;
				pr _groupAI = CALLM0(_group, "getAI");
				pr _goalParameters = [[TAG_TARGET, _buildingsWithTargets#0]];
				// Bias the goal higher so we ensure it is high priority than move orders etc.
				pr _args = ["GoalGroupGetInBuilding", 100, _goalParameters, _AI]; // Get in the house!
				CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);

				OOP_INFO_2("  Assigned group %1 to building %2", _group, _buildingsWithTargets#0);

				T_GETV("buildingsAttack") pushBackUnique (_buildingsWithTargets select 0);
				_buildingsWithTargets deleteAt 0;
				_freeGroups deleteAt 0;
			};
		};

		// Clear array of buildings we are attacking, by removing buildings without enemies
		pr _buildingsWeAreAttacking = T_GETV("buildingsAttack");
		pr _buildingsWithTargets = GETV(_AI, "buildingsWithTargets");
		pr _i = 0;
		while {_i < (count _buildingsWeAreAttacking)} do {
			if (_buildingsWeAreAttacking#_i in _buildingsWithTargets) then {
				_i = _i + 1;
			} else {
				_buildingsWeAreAttacking deleteAt _i;
			};
		};

	ENDMETHOD;

ENDCLASS;