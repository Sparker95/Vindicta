#include "common.hpp"
/*
Garrison moves on available vehicles
*/

#define pr private

#define THIS_ACTION_NAME "ActionGarrisonMoveCombined"

CLASS(THIS_ACTION_NAME, "ActionGarrison")


	VARIABLE("pos"); // The destination position
	VARIABLE("radius"); // Completion radius
	VARIABLE("virtualRoute"); // VirtualRoute object

	// ------------ N E W ------------
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
		// Unpack position
		pr _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		pr _loc = "";
		if (_pos isEqualType []) then {
			T_SETV("pos", _pos); // Set value if array if passed
			pr _locAndDist = CALLSM1("Location", "getNearestLocation", _pos);
			_loc = _locAndDist select 0;
		} else {
			// Otherwise the location object was passed probably, get pos from location object
			_loc = _pos;
			pr _locPos = CALLM0(_loc, "getPos");
			T_SETV("pos", _locPos);
		};
		
		// Unpack radius
		pr _radius = CALLSM2("Action", "getParameterValue", _parameters, TAG_MOVE_RADIUS);
		if (isNil "_radius") then {
			// todo Try to figure out completion radius from location
			//pr _radius = CALLM0(_loc, "getBoundingRadius"); // there is no such function
			// Just use 100 meters for now
			T_SETV("radius", 100);
		} else {
			T_SETV("radius", _radius);
		};

		T_SETV("virtualRoute", "");
		// Create a VirtualRoute in advance
		if(!CALLM0(_AI, "isSpawned")) then {
			CALLM0(_thisObject, "createVirtualRoute");
		};
		
	} ENDMETHOD;

	METHOD("delete") {
		params ["_thisObject"];

		// Delete the virtual route object
		pr _vr = T_GETV("virtualRoute");
		if (_vr != "") then {
			DELETE(_vr);
		};

	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		
		OOP_INFO_0("ACTIVATE");
		
		// Give waypoint to the vehicle group
		pr _gar = T_GETV("gar");
		pr _AI = T_GETV("AI");
		pr _pos = T_GETV("pos");
		pr _radius = T_GETV("radius");
		
		pr _vehGroups = CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_NON_STATIC) + CALLM1(_gar, "findGroupsByType", GROUP_TYPE_VEH_STATIC);
		if (count _vehGroups > 1) then {
			OOP_ERROR_0("More than one vehicle group in the garrison!");
		};
		
		{
			pr _group = _x;
			pr _groupAI = CALLM0(_x, "getAI");
			
			// Add new goal to move
			pr _args = ["GoalGroupMoveGroundVehicles", 0, [[TAG_POS, _pos], [TAG_MOVE_RADIUS, _radius], [TAG_MAX_SPEED_KMH, 11]], _AI];
			CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);			
			
		} forEach _vehGroups;

		// Give goals to infantry groups
		pr _infGroups = CALLM1(_gar, "findGroupsByType", [GROUP_TYPE_IDLE ARG GROUP_TYPE_PATROL]);
		{
			pr _groupAI = CALLM0(_x, "getAI");
			CALLM(_groupAI, "postMethodAsync", ["addExternalGoal" ARG ["GoalGroupInfantryFollowGroundVehicles" ARG 0 ARG [] ARG _AI]]);
		} forEach _infGroups;
		
		// Reset current location of this garrison
		CALLM0(_gar, "detachFromLocation");
		pr _ws = GETV(_AI, "worldState");
		[_ws, WSP_GAR_LOCATION, ""] call ws_setPropertyValue;
		pr _pos = CALLM0(_gar, "getPos");
		[_ws, WSP_GAR_POSITION, _pos] call ws_setPropertyValue;
		
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;

	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];

		pr _gar = T_GETV("gar");
		if (!CALLM0(_gar, "isSpawned")) then {
			pr _state = T_GETV("state");

			// Create a Virtual Route if it doesnt exist yet
			pr _vr = T_GETV("virtualRoute");
			if (_vr == "") then {
				_vr = CALLM0(_thisObject, "createVirtualRoute");
			};

			if (_state == ACTION_STATE_INACTIVE) then {
				CALLM0(_vr, "start");
				CALLM0(_gar, "detachFromLocation");
				_state = ACTION_STATE_ACTIVE;
			};

			// Process the virtual convoy
			if (_state == ACTION_STATE_ACTIVE) then {
				// Run process of the virtual route and update position of the garrison
				CALLM0(_vr, "process");
				if(GETV(_vr, "calculated")) then {
					pr _pos = CALLM0(_vr, "getPos");
					pr _AI = T_GETV("AI");
					CALLM1(_AI, "setPos", _pos);

					// Succeed the action if the garrison is close enough to its destination
					if (_pos distance2D T_GETV("pos") < T_GETV("radius") or {GETV(_vr, "complete")}) then {
						_state = ACTION_STATE_COMPLETED;
					};
				} else { 
					if(GETV(_vr, "failed")) then {
						T_PRVAR(gar);
						pr _garPos = CALLM0(_gar, "getPos");
						T_PRVAR(pos);
						OOP_WARNING_MSG("Virtual Route from %1 to %2 failed, distance remaining : %3", [_garPos]+[_pos]+[_pos distance _garPos]);
						// TODO: maybe we want to do something else here?
						_state = ACTION_STATE_COMPLETED;
					};
				};
			};

			T_SETV("state", _state);
			_state
		} else {
			// Delete the Virtual Route object if it exists, we don't need it any more
			pr _vr = T_GETV("virtualRoute");
			if (_vr != "") then {
				DELETE(_vr);
				T_SETV("virtualRoute", "");
			};

			// Fail if not everyone is in vehicles
			pr _crewIsMounted = CALLM0(_thisObject, "isCrewInVehicle");
			OOP_INFO_1("Crew is in vehicles: %1", _crewIsMounted);
			if (! _crewIsMounted) exitWith {
				OOP_INFO_0("ACTION FAILED because crew is not in vehicles");
				T_SETV("state", ACTION_STATE_FAILED);
				ACTION_STATE_FAILED
			};
			
			pr _state = CALLM0(_thisObject, "activateIfInactive");
			
			scopeName "s0";
			
			if (_state == ACTION_STATE_ACTIVE) then {
			
				pr _gar = T_GETV("gar");
				pr _AI = T_GETV("AI");

				// Update position of this garrison object
				pr _units = CALLM0(_gar, "getUnits");
				pr _pos = T_GETV("pos");
				pr _index = _units findIf {CALLM0(_x, "isAlive")};
				if (_index != -1) then {
					pr _unit = _units select _index;
					pr _hO = CALLM0(_unit, "getObjectHandle");
					_pos = getPos _hO;
				};
				CALLM1(_AI, "setPos", _pos);
			
				pr _args = [GROUP_TYPE_VEH_NON_STATIC, GROUP_TYPE_VEH_STATIC];
				pr _vehGroups = CALLM1(_gar, "findGroupsByType", _args);
				pr _infGroups = CALLM(_gar, "findGroupsByType", [GROUP_TYPE_IDLE ARG GROUP_TYPE_PATROL]);
				
				// Fail if any group has failed
				if (CALLSM3("AI_GOAP", "anyAgentFailedExternalGoal", _vehGroups, "GoalGroupMoveGroundVehicles", "")) then {
					_state = ACTION_STATE_FAILED;
					breakTo "s0";
				};
				if (CALLSM3("AI_GOAP", "anyAgentFailedExternalGoal", _infGroups, "GoalGroupInfantryFollowGroundVehicles", "")) then {
					_state = ACTION_STATE_FAILED;
					breakTo "s0";
				};
				
				// Succede if all groups have completed the goal
				if (CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoal", _vehGroups, "GoalGroupMoveGroundVehicles", "")) then {
					OOP_INFO_0("All groups have arrived");
					
					// Set pos world state property
					// todo fix this, implement AIGarrison.setVehiclesPos function
					//pr _ws = GETV(_AI, "worldState");
					//[_ws, WSP_GAR_POSITION, _pos] call ws_setPropertyValue;
					//[_ws, WSP_GAR_VEHICLES_POSITION, _pos] call ws_setPropertyValue;
					
					_state = ACTION_STATE_COMPLETED;
					breakTo "s0";
				};
			};
			
			// Return the current state
			T_SETV("state", _state);
			_state
		};
	} ENDMETHOD;
	
	// Returns true if everyone is in vehicles
	METHOD("isCrewInVehicle") {
		params ["_thisObject"];
		pr _AI = T_GETV("AI");
		pr _ws = GETV(_AI, "worldState");
		
		pr _return = 	([_ws, WSP_GAR_ALL_CREW_MOUNTED] call ws_getPropertyValue);
		
		_return
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		pr _gar = T_GETV("gar");

		// Bail if not spawned
		if (!CALLM0(_gar, "isSpawned")) exitWith {};

		// Terminate given goals
		pr _allGroups = CALLM0(_gar, "getGroups");
		{
			pr _groupAI = CALLM0(_x, "getAI");
			CALLM(_groupAI, "postMethodAsync", ["deleteExternalGoal" ARG [ "GoalGroupMoveGroundVehicles" ARG ""]]);
			CALLM(_groupAI, "postMethodAsync", ["deleteExternalGoal" ARG [ "GoalGroupInfantryFollowGroundVehicles" ARG ""]]);
		} forEach _allGroups;
		
	} ENDMETHOD;

	METHOD("onGarrisonSpawned") {
		params ["_thisObject"];

		// Reset action state so that it reactivates
		T_SETV("state", ACTION_STATE_INACTIVE);
	} ENDMETHOD;
	
	METHOD("onGarrisonDespawned") {
		params ["_thisObject"];

		// Create a new VirtualRoute since old one might be invalid
		CALLM0(_thisObject, "createVirtualRoute");

		// Reset action state so that it reactivates
		T_SETV("state", ACTION_STATE_INACTIVE);
	} ENDMETHOD;

	// Creates a new VirtualRoute object, deletes the old one
	METHOD("createVirtualRoute") {
		params ["_thisObject"];

		pr _gar = T_GETV("gar");

		// Delete old virtual route if we had it
		pr _vr = T_GETV("virtualRoute");
		if (_vr != "") then {
			DELETE(_vr);
		};

		// Create a new virtual route
		pr _gar = T_GETV("gar");
		pr _args = [CALLM0(_gar, "getPos"), T_GETV("pos"), -1, "", {3}, false]; // Set 3m/s speed
		_vr = NEW("VirtualRoute", _args);
		T_SETV("virtualRoute", _vr);

		_vr
	} ENDMETHOD;

	METHOD("spawn") {
		params ["_thisObject"];

		pr _gar = T_GETV("gar");

		// Spawn vehicle groups on the road according to convoy positions
		pr _vr = T_GETV("virtualRoute");
		if (_vr == "") exitWith {false}; // Perform standard spawning if there is no virtual route for some reason (why???)

		// Count all vehicles in garrison
		pr _nVeh = count CALLM0(_gar, "getVehicleUnits");
		pr _posAndDir = if(!GETV(_vr, "calculated") || GETV(_vr, "failed")) then {
			pr _vals = [];
			pr _garPos = CALLM0(_gar, "getPos");
			for "_i" from 1 to _nVeh do {
				_vals pushBack [_garPos, 0];
			};
			_vals
		} else {
			CALLM1(_vr, "getConvoyPositions", _nVeh)
		};
		//reverse _posAndDir;

		// Bail if we have failed to get positions
		if ((count _posAndDir) != _nVeh) exitWith {false};

		// Iterate through all groups
		pr _currentIndex = 0;
		pr _groups = CALLM0(_gar, "getGroups");
		{
			pr _nVehThisGroup = count CALLM0(_x, "getVehicleUnits");
			if (_nVehThisGroup > 0) then {
				pr _posAndDirThisGroup = _posAndDir select [_currentIndex, _nVehThisGroup];
				CALLM1(_x, "spawnVehiclesOnRoad", _posAndDirThisGroup);

				// Make leader the first human in the group
				pr _units = CALLM0(_x, "getUnits");
				pr _index = _units findIf {CALLM0(_x, "isInfantry")};
				if (_index != -1) then {
					CALLM1(_x, "setLeader", _units select _index);
				};
				_currentIndex = _currentIndex + _nVehThisGroup;
			} else {
				pr _posAndDirThisGroup = _posAndDir select [0, 1];
				CALLM1(_x, "spawnVehiclesOnRoad", _posAndDirThisGroup);
			};
		} forEach _groups;

		// todo what happens with ungrouped units?? Why are there even ungrouped units at this point???

		true
	} ENDMETHOD;

		// Handle units/groups added/removed

	METHOD("handleGroupsAdded") {
		params [["_thisObject", "", [""]], ["_groups", [], [[]]]];
		
		T_SETV("state", ACTION_STATE_REPLAN);
	} ENDMETHOD;

	METHOD("handleGroupsRemoved") {
		params [["_thisObject", "", [""]], ["_groups", [], [[]]]];
		
		T_SETV("state", ACTION_STATE_REPLAN);
	} ENDMETHOD;
	
	METHOD("handleUnitsRemoved") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]]];
		
		T_SETV("state", ACTION_STATE_REPLAN);
	} ENDMETHOD;
	
	METHOD("handleUnitsAdded") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]]];
		
		T_SETV("state", ACTION_STATE_REPLAN);
	} ENDMETHOD;

ENDCLASS;