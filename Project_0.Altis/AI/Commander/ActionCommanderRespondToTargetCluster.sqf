#include "common.hpp"
/*
Responds to every spotted cluster with targets.
*/

#define pr private

CLASS("ActionCommanderRespondToTargetCluster", "Action")

	// ID of the cluster we are responding to
	VARIABLE("clusterID");
	VARIABLE("clusterIDChanged");
	VARIABLE("timeNextActivation");
	VARIABLE("allocatedGarrisons"); // Array with [_garrison, _location]
	VARIABLE("clusterGoalPos");

	// Last time we send new info to the other garrison
	VARIABLE("timeAssignedTargetsUpdate");

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_clusterID", 0, [0]] ];

		T_SETV("clusterID", _clusterID);
		T_SETV("timeNextActivation", 0); // To force instant replan/reallocation
		T_SETV("allocatedGarrisons", []);
		T_SETV("clusterIDChanged", false);

		T_SETV("timeAssignedTargetsUpdate", TIME_NOW);
	} ENDMETHOD;

	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];

		OOP_INFO_0("ACTIVATE");

		// If the timer to replan hasn't expired yet, leave
		if (! (TIME_NOW > T_GETV("timeNextActivation"))) exitWith {
			ACTION_STATE_INACTIVE
		};

		pr _ID = T_GETV("clusterID");
		pr _AI = T_GETV("AI");
		pr _tc = CALLM1(_AI, "getTargetCluster", _ID);
		// Fail if there is no cluster with this ID
		if (count _tc == 0) exitWith {
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		};
		
		// Get position of the target cluster
		pr _cluster = _tc select TARGET_CLUSTER_ID_CLUSTER;
		pr _center = _cluster call cluster_fnc_getCenter;
		_center append [0]; // Originally center is 2D vector, now we make it 3D to be safe
		T_SETV("clusterGoalPos", +_center);
		
		// Make a new garrison
		pr _args = [GETV(_AI, "side")];
		pr _newGar = NEW("Garrison", _args);
		CALLM1(_AI, "registerGarrison", _newGar);
		
		// Allocate units and split garrison in a loop, until there is a successfull allocation
		pr _success = false;
		while {!_success} do {
			// Try to allocate the selected units
			pr _eff = +(_tc select TARGET_CLUSTER_ID_EFFICIENCY);
			
			// Change cluster efficiency before allocation
			// Ensure allocatin of a bit more units than needed
			_eff set [T_EFF_soft, 1.6*(_eff select T_EFF_soft) max 5]; // +60% to the amount of troops, but no less than 5
			_eff set [T_EFF_medium, 1.6*(_eff select T_EFF_medium)];
			
			OOP_INFO_2("RESPOND TO TARGET: Trying to allocate units, pos: %1, eff: %2", _center, _eff);
			pr _alloc = CALLM2(_AI, "allocateUnitsGroundQRF", _center, _eff);
			// If we have failed to allocate units, break the loop
			if (count _alloc == 0) exitWith {
				_success = false;
				OOP_WARNING_2("RESPOND TO TARGET: Failed to allocate units to pos: %1, eff: %2", _center, _eff);
			};
			
			_alloc params ["_locationSrc", "_garrisonSrc", "_units", "_groupsAndUnits"];
			
			OOP_INFO_2("RESPOND TO TARGET: Successfully allocated units! Units: %1, Groups and units: %2", _units, _groupsAndUnits);
			
			if (_locationSrc != "") then {
				CALLM1(_newGar, "setLocation", _locationSrc); // This garrison will spawn here if needed
			};

			// Set position of the new garrison and call its process method again to set it to spawned state if needed
			pr _newPos = CALLM0(_garrisonSrc, "getPos");
			CALLM1(_newGar, "setPos", _newPos);
			CALLM0(_newGar, "process");
			//CALLM0(_newGar, "spawn");
			
			// Try to move the units
			pr _args = [_garrisonSrc, _units, _groupsAndUnits];
			pr _moveSuccess = CALLM2(_newGar, "postMethodSync", "addUnitsAndGroups", _args);
			if (_moveSuccess) then {
				OOP_INFO_0("RESPOND TO TARGET: Successfully moved units!");
				
				// Detach from the location
				CALLM2(_newGar, "postMethodAsync", "setLocation", [""]);
				
				// Give the goal to the garrison
				pr _cSize = _cluster call cluster_fnc_getSize;
				// In this case radius is the distance where the Move action is going to be completed and the ClearArea action will start
				// But currently ClearArea action uses a fixed radius of 100 meters (as I remember)
				pr _radius = ((selectMax _cSize) + 300) max 300; // 300 meters from cluster border, but not less than 300 meters
				pr _parameters = [[TAG_G_POS, _center], [TAG_MOVE_RADIUS, _radius], [TAG_CLEAR_RADIUS, selectMax _cSize], [TAG_DURATION, 60*20]]; 
				pr _garAI = CALLM0(_newGar, "getAI");
				pr _args = ["GoalGarrisonClearArea", 0, _parameters, _AI];
				CALLM2(_garAI, "postMethodAsync", "addExternalGoal", _args);
				
				// Give goal to RTB when there's nothing to do
				
				// Find nearest location which belongs to this side
				// Find locations controled by this side
				pr _thisSide = GETV(_AI, "side");
				private _friendlyLocations = CALLM0(_AI, "getFriendlyLocations");
				
				// Sort friendly locations by distance
				_friendlyDistLoc = _friendlyLocations apply {
					pr _locPos = CALLM0(_x, "getPos");
					[_locPos distance2D _center, _x]
				};
				_friendlyDistLoc sort true; // Ascending
				
				_parameters = [[TAG_LOCATION, _friendlyDistLoc select 0 select 1]];
				_args = ["GoalGarrisonJoinLocation", 0, _parameters, _AI];
				CALLM2(_garAI, "postMethodAsync", "addExternalGoal", _args);
				
				// Add the allocated garrison to the array
				pr _array = T_GETV("allocatedGarrisons");
				_array pushBack [_newGar, _locationSrc]; // new garrison, original location
				
				_success = true;
			} else {
				OOP_WARNING_0("RESPOND TO TARGET: Failed to move units!");
			};
			// If move was not successfull, do the allocation and movement again
		};
		
		// Send data with assigned targets to allocated garrisons
		CALLM1(_thisObject, "assignTargetsToGarrisons", _cluster);
		T_SETV("timeAssignedTargetsUpdate", TIME_NOW);
		
		pr _state = if (_success) then {			
			ACTION_STATE_ACTIVE
		} else {
			// Set timer for future replan
			OOP_WARNING_0("RESPOND TO TARGET: Next replan in 20 seconds!");
			T_SETV("timeNextActivation", TIME_NOW + 20);
			ACTION_STATE_INACTIVE
		};
		
		// Set state
		T_SETV("state", _state);
		_state
	} ENDMETHOD;

	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];

		pr _state = CALLM0(_thisObject, "activateIfInactive");
		
		if (_state == ACTION_STATE_ACTIVE) then {
			// Delete destroyed garrisons
			pr _allocatedGarrisons = T_GETV("allocatedGarrisons");
			pr _i = 0;
			while {_i < count _allocatedGarrisons} do {
				pr _gar = _allocatedGarrisons select _i select 0;
				if (CALLM0(_gar, "isEmpty")) then {
					OOP_INFO_1("---- Unreferensing a destroyed garrison: %1", _x);
					_allocatedGarrisons deleteAt _i;
					CALLM2(_gar, "postMethodAsync", "unref", []);
				} else {
					_i = _i + 1;
				};
			};
			
			// Check cluster position
			pr _ID = T_GETV("clusterID");
			pr _AI = T_GETV("AI");
			pr _tc = CALLM1(_AI, "getTargetCluster", _ID);
			// Fail if there is no cluster with this ID
			if (count _tc == 0) then {
				OOP_ERROR_1("Target cluster with ID %1 doesn't exist!", _ID);
				_state = ACTION_STATE_FAILED
			} else {
				
				// Check if allocated garrisons still can destroy the target
				pr _allocatedGarsEff = +T_EFF_null;
				{
					_x params ["_gar", "_loc"];
					pr _garEff = CALLM0(_gar, "getEfficiencyTotal");
					_allocatedGarsEff = EFF_ADD(_allocatedGarsEff, _garEff); // Sum up all efficiencies
				} forEach _allocatedGarrisons;
				// If can't destroy the threat, allocate more units
				if (!([_allocatedGarsEff, _tc select TARGET_CLUSTER_ID_EFFICIENCY] call t_fnc_canDestroy == T_EFF_CAN_DESTROY_ALL)) then {
					OOP_INFO_0("---- Allocating more units to respond to target cluster!");
					CALLM0(_thisObject, "activate");
				};
			
				pr _cluster = _tc select TARGET_CLUSTER_ID_CLUSTER;
				pr _center = _cluster call cluster_fnc_getCenter;
				_center append [0]; // Originally center is 2D vector, now we make it 3D to be safe
				pr _cSize = _cluster call cluster_fnc_getSize;
				pr _radius = ((selectMax _cSize) + 300) max 300; // 300 meters from cluster border, but not less than 300 meters
				// If cluster position has changed significantly, or this action has been redirected to another cluster
				if (_center distance2D T_GETV("clusterGoalPos") > 150 || T_GETV("clusterIDChanged")) then {

					OOP_INFO_1("---- Retargeting assigned garrisons to new position: %1", _center);

					// Loop through all garrisons and give them a new goal with proper coordinates
					{
						OOP_INFO_1("   Retargeted garrison: %1", _x);
						pr _garAI = CALLM0(_x select 0, "getAI");
						pr _parameters = [[TAG_G_POS, _center], [TAG_MOVE_RADIUS, _radius], [TAG_CLEAR_RADIUS, selectMax _cSize], [TAG_DURATION, 60*20]];
						pr _args = ["GoalGarrisonClearArea", 0, _parameters, _AI];
						CALLM2(_garAI, "postMethodAsync", "addExternalGoal", _args);
					} forEach T_GETV("allocatedGarrisons");
					
					// Reset the 'cluster ID changed' flag
					T_SETV("clusterIDChanged", false);
					
					// Update the position where we have assigned goals to
					T_SETV("clusterGoalPos", _center);
					
					// Assign targets to garrisons again
					CALLM1(_thisObject, "assignTargetsToGarrisons", _cluster);
					T_SETV("timeAssignedTargetsUpdate", TIME_NOW);
				};
			};
			
			// Assign targets periodycally
			if (TIME_NOW - T_GETV("timeAssignedTargetsUpdate") > 30 && (count _tc > 0)) then {
				CALLM1(_thisObject, "assignTargetsToGarrisons", _tc select TARGET_CLUSTER_ID_CLUSTER);
				T_SETV("timeAssignedTargetsUpdate", TIME_NOW);
			};
		};


		// Return the current state
		_state
	} ENDMETHOD;

	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		OOP_INFO_0("TERMINATE");
		
		pr _AI = T_GETV("AI");
		
		// Give goals to allocated garrisons to move back
		pr _array = T_GETV("allocatedGarrisons");
		{
			_x params ["_gar", "_loc"];
			pr _garAI = CALLM0(_gar, "getAI");
			// Delete the old goal
			pr _args = ["GoalGarrisonClearArea", _AI];
			CALLM2(_garAI, "postMethodAsync", "deleteExternalGoal", _args);
			
			// Unassign targets
			_args = [[], [0, 0, 0]];
			CALLM2(_garAI, "postMethodAsync", "assignTargets", _args);
			
		} forEach _array;
		
	} ENDMETHOD;

	// Returns the ID of the target cluster this action is targeted at
	METHOD("getTargetClusterID") {
		params ["_thisObject"];
		T_GETV("clusterID")
	} ENDMETHOD;
	
	// Called by AICommander when this action has to be redirected to another target cluster
	METHOD("setTargetClusterID") {
		params ["_thisObject", ["_newClusterID", 0, [0]]];
		OOP_INFO_1("SET TARGET CLUSTER ID: %1", _newClusterID);
		T_SETV("clusterID", _newClusterID);
		T_SETV("clusterIDChanged", true);
	} ENDMETHOD;
	
	// Sends data with assigned targets to all allocated garrisons
	METHOD("assignTargetsToGarrisons") {
		params ["_thisObject", ["_cluster", [], [[]]]];
		
		pr _pos = _cluster call cluster_fnc_getCenter;
		pr _targetsToAssign = (_cluster select CLUSTER_ID_OBJECTS) apply {_x select TARGET_COMMANDER_ID_OBJECT_HANDLE};
		
		pr _garrisons = T_GETV("allocatedGarrisons");
		pr _args = [_targetsToAssign, _pos];
		{
			pr _garAI = CALLM0(_x select 0, "getAI");
			CALLM2(_garAI, "postMethodAsync", "assignTargets", _args);
		} forEach _garrisons;
	} ENDMETHOD;

ENDCLASS;