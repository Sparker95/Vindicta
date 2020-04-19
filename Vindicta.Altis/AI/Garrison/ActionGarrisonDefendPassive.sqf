#include "common.hpp"

// Passive defense:
// Assign patrol and idle groups.
// Patrol groups patrol
// - patrol speed to normal, formation to staggered column
// - mount all vehicles
// - move idle groups inside
// - patrol roads with vehicle groups
// - set vehicle gunners to scan their sectors

CLASS("ActionGarrisonDefendPassive", "ActionGarrisonDefend")

	// METHOD("activate") {
	// 	params [P_THISOBJECT];

	// 	OOP_INFO_0("ACTIVATE");

	// 	// Give goals to groups
	// 	private _AI = T_GETV("AI");
	// 	private _gar = GETV(_AI, "agent");

	// 	// Rebalance groups, ensure all the vehicle groups have drivers, balance the infantry groups
	// 	// We do this explictly and not as an action precondition because we will be unbalancing the groups
	// 	// when we assign inf protection squads to vehicle groups
	// 	// TODO: add group protect action so we can use separate inf groups
	// 	CALLM0(_gar, "rebalanceGroups");


	// 	private _loc = CALLM0(_gar, "getLocation");
	// 	// Buildings into which groups will be ordered to move
	// 	private _buildings = if (_loc != NULL_OBJECT) then {+
	// 		CALLM0(_loc, "getOpenBuildings")
	// 	} else {
	// 		[]
	// 	};

	// 	// Sort buildings by their height (or maybe there is a better criteria, but higher is better, right?)
	// 	_buildings = _buildings apply { [2 * (abs ((boundingBoxReal _x)#1#2)), _x] };
	// 	_buildings sort DESCENDING;

	// 	private _groups = +CALLM0(_gar, "getGroups");
	// 	private _groupsInf = _groups select { CALLM0(_x, "getType") == GROUP_TYPE_INF };

	// 	// Order to some groups to occupy buildings
	// 	private _i = 0;
	// 	private _nGroupsPatrolReserve = 0;
	// 	private _atPoliceStation = false;
	// 	private _atRoadblock = false;
	// 	// We absolutely want at least some bots inside police stations
	// 	if (_loc != NULL_OBJECT) then { // If garrison is at location...
	// 		switch (CALLM0(_loc, "getType")) do {
	// 			case LOCATION_TYPE_POLICE_STATION: {
	// 				_atPoliceStation = true;
	// 			};
	// 			case LOCATION_TYPE_ROADBLOCK: {
	// 				_atRoadblock = true;
	// 			};
	// 		};
	// 	};

		
	// 	if (_atPoliceStation) then {
	// 		// First of all assign groups to guard the police station
	// 		// If there are more groups, they will be on patrol
	// 		_nGroupsPatrolReserve = 0;
	// 	} else {
	// 		if (_atRoadblock) then {
	// 			// At roadblock we want all groups to patrol if possible
	// 			// Otherwise they will stand inside not being able to detect anything
	// 			_nGroupsPatrolReserve = 100;
	// 		} else {
	// 			// For non-police stations, we must reserve at least 1...2 groups to perform patrol
	// 			// Otherwise they all will stay in houses
	// 			_nGroupsPatrolReserve = (1 + ceil (random 1)); // Reserve some groups for patrol
	// 		};
	// 	};

	// 	// Give orders to some groups to get into building
	// 	while {(count _groupsInf > _nGroupsPatrolReserve) && (count _buildings > 0)} do {
	// 		private _group = _groupsInf#0;
	// 		private _groupAI = CALLM0(_group, "getAI");
	// 		private _goalParameters = [[TAG_TARGET, _buildings#0#1]];
	// 		private _args = ["GoalGroupGetInBuilding", 0, _goalParameters, _AI]; // Get in the house!
	// 		CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);

	// 		_buildings deleteAt 0;
	// 		_groupsInf deleteAt 0;
	// 		_groups deleteAt (_groups find _group);
	// 	};

	// 	// Give goals to remaining groups
	// 	private _nPatrolGroups = 0;
	// 	{ // foreach _groups
	// 		private _type = CALLM0(_x, "getType");
	// 		private _groupAI = CALLM0(_x, "getAI");
			
	// 		if (_groupAI != NULL_OBJECT) then {
	// 			private _args = [];
	// 			switch (_type) do {
	// 				case GROUP_TYPE_INF: {
	// 					// We need at least two patrol groups
	// 					if (_nPatrolGroups < 2) then {
	// 						_args = ["GoalGroupPatrol", 0, [], _AI];
	// 						_nPatrolGroups = _nPatrolGroups + 1;
	// 					} else {
	// 						if (random 10 < 5) then {
	// 							_args = ["GoalGroupRelax", 0, [], _AI];
	// 						} else {
	// 							_args = ["GoalGroupPatrol", 0, [], _AI];
	// 							_nPatrolGroups = _nPatrolGroups + 1;
	// 						};
	// 					};
	// 				};
					
	// 				case GROUP_TYPE_STATIC: {
	// 					if (_atRoadblock) then {
	// 						// Get into vehicles at roadblocks
	// 						_args = ["GoalGroupGetInVehiclesAsCrew", 0, [], _AI];
	// 					} else {
	// 						_args = ["GoalGroupRelax", 0, [], _AI];
	// 					};
	// 				};
					
	// 				case GROUP_TYPE_VEH: {
	// 					if (_atRoadblock) then {
	// 						// Get into vehicles at roadblocks
	// 						_args = ["GoalGroupGetInVehiclesAsCrew", 0, [["onlyCombat", true]], _AI]; // Occupy only combat vehicles
	// 					} else {
	// 						_args = ["GoalGroupPatrol", 0, [], _AI]; // They will patrol next to their vehicles
	// 					};
	// 				};
	// 			};
				
	// 			if (count _args > 0) then {
	// 				CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);
	// 			};
	// 		};
	// 	} forEach _groups;
		
	// 	// Set state
	// 	T_SETV("state", ACTION_STATE_ACTIVE);
		
	// 	// Return ACTIVE state
	// 	ACTION_STATE_ACTIVE
		
	// } ENDMETHOD;
	
	// // logic to run each update-step
	// METHOD("process") {
	// 	params [P_THISOBJECT];
		
	// 	// Bail if not spawned
	// 	private _gar = T_GETV("gar");
	// 	if (!CALLM0(_gar, "isSpawned")) exitWith {T_GETV("state")};

	// 	T_CALLM0("activateIfInactive");
		
	// 	// Return the current state
	// 	ACTION_STATE_ACTIVE
	// } ENDMETHOD;

ENDCLASS;