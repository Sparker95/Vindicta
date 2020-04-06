#include "common.hpp"

#define pr private

CLASS("ActionGarrisonDefend", "ActionGarrisonBehaviour")

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI")];
		T_SETV("buildingsAttack", []);
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [P_THISOBJECT, P_BOOL("_instant")];
		
		OOP_INFO_0("ACTIVATE");

		pr _AI = T_GETV("AI");
		pr _gar = GETV(_AI, "agent");
		pr _loc = CALLM0(_gar, "getLocation");
		pr _buildings = if (_loc != "") then {+CALLM0(_loc, "getOpenBuildings")} else {[]}; // Buildings into which groups will be ordered to move
		// Sort buildings by their height (or maybe there is a better criteria, but higher is better, right?)
		_buildings = _buildings apply {[abs ((boundingBoxReal _x) select 1 select 2), _x]};
		_buildings sort false;
		pr _groups = CALLM0(_gar, "getGroups");
		pr _groupsInf = _groups select { CALLM0(_x, "getType") in [GROUP_TYPE_BUILDING_SENTRY, GROUP_TYPE_IDLE, GROUP_TYPE_PATROL]};

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
		{ // foreach _groups
			pr _type = CALLM0(_x, "getType");
			pr _groupAI = CALLM0(_x, "getAI");
			
			if (_groupAI != "") then {
				pr _args = [];
				switch (_type) do {
					case GROUP_TYPE_IDLE: {
						_args = ["GoalGroupRegroup", 0, _commonParams, _AI];
					};
					
					case GROUP_TYPE_VEH_STATIC: {
						_args = ["GoalGroupGetInVehiclesAsCrew", 0, _commonParams, _AI];
					};
					
					case GROUP_TYPE_VEH_NON_STATIC: {
						_args = ["GoalGroupGetInVehiclesAsCrew", 0, [["onlyCombat", true]] + _commonParams, _AI]; // Occupy only combat vehicles
					};
					
					case GROUP_TYPE_PATROL: {
						_args = ["GoalGroupRegroup", 0, [[TAG_COMBAT_MODE, "RED"]] + _commonParams, _AI];
					};
					
					case GROUP_TYPE_BUILDING_SENTRY: {
						_args = ["GoalGroupRegroup", 0, _commonParams, _AI];
					};
				};
				
				if (count _args > 0) then {
					CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);
					// Poke group AI to switch mode faster
					CALLM2(_groupAI, "postMethodAsync", "process", []);
				};
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
	
	// // logic to run when the action is satisfied
	// METHOD("terminate") {
	// 	params [P_THISOBJECT];
		
	// 	// Bail if not spawned
	// 	pr _gar = T_GETV("gar");
	// 	if (!CALLM0(_gar, "isSpawned")) exitWith {T_GETV("state")};

	// 	// Remove assigned goals
	// 	pr _gar = GETV(T_GETV("AI"), "agent");
	// 	pr _loc = CALLM0(_gar, "getLocation");
	// 	pr _groups = CALLM0(_gar, "getGroups");
	// 	pr _AI = T_GETV("AI");
	// 	{ // foreach _groups
	// 		//pr _type = CALLM0(_x, "getType");
	// 		pr _groupAI = CALLM0(_x, "getAI");
	// 		if (_groupAI != "") then {
	// 			pr _args = ["", _AI]; // Just clear all given goals so far
	// 			CALLM2(_groupAI, "postMethodAsync", "deleteExternalGoal", _args);
	// 		};
	// 	} forEach _groups;
		
	// } ENDMETHOD;

ENDCLASS;