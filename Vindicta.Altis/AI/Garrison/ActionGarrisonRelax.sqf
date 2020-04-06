#include "common.hpp"

/*
Relax action
*/

#define pr private

CLASS("ActionGarrisonRelax", "ActionGarrisonBehaviour")
	
	// ------------ N E W ------------
	/*
	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI") ];
		T_SETV("AI", _AI);
	} ENDMETHOD;
	*/
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [P_THISOBJECT, P_BOOL("_instant")];
		
		OOP_INFO_0("ACTIVATE");
		
		// Give goals to groups
		pr _gar = GETV(T_GETV("AI"), "agent");
		pr _loc = CALLM0(_gar, "getLocation");
		pr _buildings = if (_loc != "") then {+CALLM0(_loc, "getOpenBuildings")} else {[]}; // Buildings into which groups will be ordered to move
		// Sort buildings by their height (or maybe there is a better criteria, but higher is better, right?)
		_buildings = _buildings apply {[2 * (abs ((boundingBoxReal _x) select 1 select 2)), _x]};
		_buildings sort false;
		pr _AI = T_GETV("AI");
		pr _groups = +CALLM0(_gar, "getGroups");
		pr _groupsInf = _groups select { CALLM0(_x, "getType") in [GROUP_TYPE_BUILDING_SENTRY, GROUP_TYPE_IDLE, GROUP_TYPE_PATROL]};

		// Order to some groups to occupy buildings
		pr _i = 0;
		pr _nGroupsPatrolReserve = 0;
		pr _atPoliceStation = false;
		pr _atRoadblock = false;
		// We absolutely want at least some bots inside police stations
		if (_loc != "") then { // If garrison is at location...
			switch (CALLM0(_loc, "getType")) do {
				case LOCATION_TYPE_POLICE_STATION: {
					_atPoliceStation = true;
				};
				case LOCATION_TYPE_ROADBLOCK: {
					_atRoadblock = true;
				};
			};
		};

		if (_atPoliceStation) then {
			// First of all assign groups to guard the police station
			// If there are more groups, they will be on patrol
			_nGroupsPatrolReserve = 0;
		} else {
			if (_atRoadblock) then {
				// At roadblock we want all groups to patrol if possible
				// Otherwise they will stand inside not being able to detect anything
				_nGroupsPatrolReserve = 100;
			} else {
				// For non-police stations, we must reserve at least 1...2 groups to perform patrol
				// Otherwise they all will stay in houses
				_nGroupsPatrolReserve = (1 + ceil (random 1)); // Reserve some groups for patrol
			};
		};

		pr _extraParams = [[TAG_INSTANT, _instant]];
		// Give orders to some groups to get into building
		while {(count _groupsInf > _nGroupsPatrolReserve) && (count _buildings > 0)} do {
			pr _group = _groupsInf#0;
			pr _groupAI = CALLM0(_group, "getAI");
			pr _goalParameters = [["building", _buildings#0#1]] + _extraParams;
			pr _args = ["GoalGroupGetInBuilding", 0, _goalParameters, _AI]; // Get in the house!
			CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);

			_buildings deleteAt 0;
			_groupsInf deleteAt 0;
			_groups deleteAt (_groups find _group);
		};

		// Give goals to remaining groups
		pr _nPatrolGroups = 0;
		{ // foreach _groups
			pr _type = CALLM0(_x, "getType");
			pr _groupAI = CALLM0(_x, "getAI");
			
			if (_groupAI != "") then {
				pr _args = [];
				switch (_type) do {
					case GROUP_TYPE_IDLE: {
						// We need at least two patrol groups
						if (_nPatrolGroups < 2) then {
							_args = ["GoalGroupPatrol", 0, _extraParams, _AI];
							_nPatrolGroups = _nPatrolGroups + 1;
						} else {
							if (random 10 < 5) then {
								_args = ["GoalGroupRelax", 0, _extraParams, _AI];
							} else {
								_args = ["GoalGroupPatrol", 0, _extraParams, _AI];
								_nPatrolGroups = _nPatrolGroups + 1;
							};
						};
					};
					
					case GROUP_TYPE_VEH_STATIC: {
						if (_atRoadblock) then {
							// Get into vehicles at roadblocks
							_args = ["GoalGroupGetInVehiclesAsCrew", 0, _extraParams, _AI];
						} else {
							_args = ["GoalGroupRelax", 0, _extraParams, _AI];
						};
					};
					
					case GROUP_TYPE_VEH_NON_STATIC: {
						if (_atRoadblock) then {
							// Get into vehicles at roadblocks
							_args = ["GoalGroupGetInVehiclesAsCrew", 0, [["onlyCombat", true]] + _extraParams, _AI]; // Occupy only combat vehicles
						} else {
							_args = ["GoalGroupPatrol", 0, _extraParams, _AI]; // They will patrol next to their vehicles
						};
					};
					
					case GROUP_TYPE_PATROL: {
						_args = ["GoalGroupPatrol", 0, _extraParams, _AI];
					};

					case GROUP_TYPE_BUILDING_SENTRY: {
						_args = ["GoalGroupPatrol", 0, _extraParams, _AI];
					};
				};
				
				if (count _args > 0) then {
					CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);
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
		if (!CALLM0(_gar, "isSpawned")) exitWith {T_GETV("state")};

		pr _state = T_CALLM0("activateIfInactive");

		T_SETV("state", _state);
		_state
	} ENDMETHOD;

ENDCLASS;