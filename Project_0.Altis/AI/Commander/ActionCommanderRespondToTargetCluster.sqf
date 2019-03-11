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
	VARIABLE("allocatedGarrisons");
	VARIABLE("clusterGoalPos");

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_clusterID", 0, [0]] ];

		T_SETV("clusterID", _clusterID);
		T_SETV("timeNextActivation", 0); // To force instant replan/reallocation
		T_SETV("allocatedGarrisons", []);
		T_SETV("clusterIDChanged", false);
	} ENDMETHOD;

	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_to", "", [""]]];

		OOP_INFO_0("ACTIVATE");

		// If the timer to replan hasn't expired yet, leave
		if (! (time > T_GETV("timeNextActivation"))) exitWith {
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
		pr _newGar = NEW("Garrison", [GETV(_AI, "side")]);
		
		// Allocate units and split garrison in a loop, until there is a successfull allocation
		pr _success = false;
		while {!_success} do {
			// Try to allocate the selected units
			pr _eff = +(_tc select TARGET_CLUSTER_ID_EFFICIENCY);
			_eff set [0, 7];
			OOP_INFO_2("RESPOND TO TARGET: Trying to allocate units, pos: %1, eff: %2", _center, _eff);
			pr _alloc = CALLM2(_AI, "allocateUnitsGroundQRF", _center, _eff);
			// If we have failed to allocate units, break the loop
			if (count _alloc == 0) exitWith {
				_success = false;
				OOP_WARNING_2("RESPOND TO TARGET: Failed to allocate units to pos: %1, eff: %2", _center, _eff);
			};
			
			OOP_INFO_0("RESPOND TO TARGET: Successfully allocated units!");
			
			_alloc params ["_locationSrc", "_garrisonSrc", "_units", "_groupsAndUnits"];
			
			CALLM1(_newGar, "setLocation", _locationSrc); // This garrison will spawn here if needed
			CALLM0(_newGar, "spawn");
			
			// Try to move the units
			pr _args = [_garrisonSrc, _units, _groupsAndUnits];
			pr _moveSuccess = CALLM2(_newGar, "postMethodSync", "addUnitsAndGroups", _args);
			if (_moveSuccess) then {
				OOP_INFO_0("RESPOND TO TARGET: Successfully moved units!");
				
				// Detach from the location
				CALLM2(_newGar, "postMethodAsync", "setLocation", [""]);
				
				// Give the goal to the garrison
				pr _cSize = _cluster call cluster_fnc_getSize;
				pr _radius = ((selectMax _cSize) + 300) max 300; // 300 meters from cluster border, but not less than 300 meters
				pr _parameters = [[TAG_G_POS, _center], [TAG_RADIUS, _radius], [TAG_DURATION, 60*20]]; 
				pr _garAI = CALLM0(_newGar, "getAI");
				pr _args = ["GoalGarrisonClearArea", 0, _parameters, _AI];
				CALLM2(_garAI, "postMethodAsync", "addExternalGoal", _args);
				
				// Give goal to RTB when there's nothing to do
				
				// Find nearest location which belongs to this side
				// Find locations controled by this side
				pr _thisSide = GETV(_AI, "side");
				private _friendlyLocations = CALLSM0("Location", "getAll") select {
					CALLM0(_x, "getSide") == _thisSide
				};
				
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
		
		
		pr _state = if (_success) then {			
			ACTION_STATE_ACTIVE
		} else {
			// Set timer for future replan
			OOP_WARNING_0("RESPOND TO TARGET: Next replan in 20 seconds!");
			T_SETV("timeNextActivation", time + 20);
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
			// Check cluster position
			pr _ID = T_GETV("clusterID");
			pr _AI = T_GETV("AI");
			pr _tc = CALLM1(_AI, "getTargetCluster", _ID);
			// Fail if there is no cluster with this ID
			if (count _tc == 0) then {
				OOP_ERROR_1("Target cluster with ID %1 doesn't exist!", _ID);
				_state = ACTION_STATE_FAILED
			} else {
				pr _cluster = _tc select TARGET_CLUSTER_ID_CLUSTER;
				pr _center = _cluster call cluster_fnc_getCenter;
				_center append [0]; // Originally center is 2D vector, now we make it 3D to be safe
				pr _size = ((selectMax (_cluster call cluster_fnc_getSize)) + 300) max 300;
				// If cluster position has changed significantly, or this action has been redirected to another cluster
				if (_center distance2D T_GETV("clusterGoalPos") > _size || T_GETV("clusterIDChanged")) then {

					OOP_INFO_1("---- Retargeting assign garrisons to new position: %1", _center);

					// Loop through all garrisons and give them a new goal with proper coordinates
					{
						OOP_INFO_1("   Retargeted garrison: %1", _x);
						pr _garAI = CALLM0(_x select 0, "getAI");
						pr _parameters = [[TAG_G_POS, _center], [TAG_RADIUS, _size], [TAG_DURATION, 60*20]];
						pr _args = ["GoalGarrisonClearArea", 0, _parameters, _AI];
						CALLM2(_garAI, "postMethodAsync", "addExternalGoal", _args);
					} forEach T_GETV("allocatedGarrisons");
					
					// Reset the 'cluster ID changed' flag
					T_SETV("clusterIDChanged", false);
					
					// Update the position where we have assigned goals to
					T_SETV("clusterGoalPos", _center);
				};
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

ENDCLASS;