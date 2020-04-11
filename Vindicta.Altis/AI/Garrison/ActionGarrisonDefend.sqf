#include "common.hpp"

#define pr private

// Base for defensive actions (active, passive, relax)
// 
// Specify group behaviors in derived classes
//
// Number of road patrols -- prefers vehicles
// Number of overwatch groups -- same as clear area action
// Fraction of idle vs patrol for general inf
// Fraction of idle vs patrol for general vehicles
// Inf behavior -- behavior, speed, combat mode, formation
// Vic behavior -- behavior, speed, combat mode, formation
// Static group goal
// Idle group goals -- array of possible goals with weights

CLASS("ActionGarrisonDefend", "ActionGarrisonBehaviour")

	VARIABLE("nRoadPatrols");
	VARIABLE("nOverwatch");
	VARIABLE("idleFractionInf");
	VARIABLE("idleFractionVeh");
	VARIABLE("infBehavior");
	VARIABLE("vehBehavior");
	VARIABLE("staticGroupGoal");
	VARIABLE("idleGroupGoals");

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI")];
	} ENDMETHOD;

	METHOD("activate") {
		params [P_THISOBJECT, P_BOOL("_instant")];
		
		OOP_INFO_0("ACTIVATE");

		// Give goals to groups
		private _AI = T_GETV("AI");
		private _gar = GETV(_AI, "agent");

		CALLM0(_gar, "rebalanceGroups");

		private _loc = CALLM0(_gar, "getLocation");
		// Buildings into which groups will be ordered to move
		private _buildings = if (_loc != NULL_OBJECT) then {+
			CALLM0(_loc, "getOpenBuildings")
		} else {
			[]
		};

		// Sort buildings by their height (or maybe there is a better criteria, but higher is better, right?)
		_buildings = _buildings apply {[abs ((boundingBoxReal _x)#1#2), _x]};
		_buildings sort DESCENDING;
		pr _groups = CALLM0(_gar, "getGroups");
		pr _groupsInf = _groups select { CALLM0(_x, "getType") == GROUP_TYPE_INF };

		pr _commonParams = [[TAG_INSTANT, _instant]];
		// Order to some groups to occupy buildings
		// This is obviously ignored if the garrison is not at a location
		pr _i = 0;
		while {(count _groupsInf > 0) && (count _buildings > 0)} do {
			pr _group = _groupsInf#0;
			pr _groupAI = CALLM0(_group, "getAI");
			pr _goalParameters = [
				["building", _buildings#0#1]
			] + _commonParams;
			pr _args = ["GoalGroupGetInBuilding", 0, _goalParameters, _AI]; // Get in the house!
			CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);

			_buildings deleteAt 0;
			_groupsInf deleteAt 0;
			_groups deleteAt (_groups find _group);
		};

		// Give goals to remaining groups
		private _nPatrolGroups = 0;
		{// foreach _groups
			private _groupAI = CALLM0(_x, "getAI");
			
			if (_groupAI != NULL_OBJECT) then {
				private _args = switch (CALLM0(_x, "getType")) do {
					case GROUP_TYPE_STATIC: {
						["GoalGroupGetInVehiclesAsCrew", 0, [[TAG_COMBAT_MODE, "RED"]] + _commonParams, _AI]
					};
					case GROUP_TYPE_VEH: {
						["GoalGroupGetInVehiclesAsCrew", 0, [[TAG_COMBAT_MODE, "RED"], ["onlyCombat", true]] + _commonParams, _AI]
					};
					//case GROUP_TYPE_INF:
					default {
						["GoalGroupRegroup", 0, [[TAG_COMBAT_MODE, "RED"]] + _commonParams, _AI]
					};
				};
				CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);
			};
		} forEach _groups;
		
		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [P_THISOBJECT];
		
		// Bail if not spawned
		pr _gar = T_GETV("gar");
		if (!CALLM0(_gar, "isSpawned")) exitWith {};

		pr _state = T_CALLM0("activateIfInactive");

		if (_state == ACTION_STATE_ACTIVE) then {
			T_CALLM0("attackEnemyBuildings"); // It will try to give goals to free groups to attack nearby enemy buildings
		};

		// Return the current state
		_state
	} ENDMETHOD;

ENDCLASS;