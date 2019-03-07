#include "common.hpp"
/*
Responds to every spotted cluster with targets.
*/

#define pr private

CLASS("ActionCommanderRespondToTargetCluster", "Action")

	// ID of the cluster we are responding to
	VARIABLE("clusterID");
	VARIABLE("timeNextActivation");

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_clusterID", 0, [0]] ];

		T_SETV("clusterID", _clusterID);
		T_SETV("timeNextActivation", 0); // To force instant replan/reallocation
	} ENDMETHOD;

	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_to", "", [""]]];

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
		
		// Make a new garrison
		pr _newGar = NEW("Garrison", [GETV(_AI, "side")]);
		
		// Allocate units and split garrison in a loop, until there is a successfull allocation
		pr _success = false;
		while {!_success} do {
			// Try to allocate the selected units
			pr _eff = _tc select TARGET_CLUSTER_ID_EFFICIENCY;
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
				_success = true;
			} else {
				OOP_WARNING_0("RESPOND TO TARGET: Failed to move units!");
			};
			// If move was not successfull, do the allocation and movement again
		};
		
		
		pr _state = if (_success) then {
			// Give the goal to the garrison
			pr _cSize = _cluster call cluster_fnc_getSize;
			pr _radius = (selectMax _cSize) min 200;
			pr _parameters = [[TAG_G_POS, _center], [TAG_RADIUS, _radius], [TAG_DURATION, 60*20]]; 
			pr _garAI = CALLM0(_newGar, "getAI");
			pr _args = ["GoalGarrisonClearArea", 0, _parameters, _AI];
			CALLM2(_garAI, "postMethodAsync", "addExternalGoal", _args);
			
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

		pr _state = CALLM(_thisObject, "activateIfInactive", []);

		// Return the current state
		_state
	} ENDMETHOD;

	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
	} ENDMETHOD;

	// Returns the ID of the target cluster this action is targeted at
	METHOD("getTargetClusterID") {
		params ["_thisObject"];
		T_GETV("clusterID")
	} ENDMETHOD;

ENDCLASS;