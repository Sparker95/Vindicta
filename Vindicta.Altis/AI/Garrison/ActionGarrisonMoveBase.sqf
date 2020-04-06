#include "common.hpp"

CLASS("ActionGarrisonMoveBase", "ActionGarrison")

	VARIABLE("pos"); // The destination position
	VARIABLE("radius"); // Completion radius
	VARIABLE("virtualRoute"); // VirtualRoute object
	VARIABLE("time");
	VARIABLE("leadGroup");
	VARIABLE("followGroups");

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		// Unpack position/location
		private _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		private _loc = "";
		if (_pos isEqualType []) then {
			T_SETV("pos", _pos); // Set value if array if passed
			private _locAndDist = CALLSM1("Location", "getNearestLocation", _pos);
			_loc = _locAndDist # 0;
		} else {
			// Otherwise the location object was passed probably, get pos from location object
			_loc = _pos;
			private _locPos = CALLM0(_loc, "getPos");
			T_SETV("pos", _locPos);
		};
		
		// Unpack radius
		private _radius = CALLSM3("Action", "getParameterValue", _parameters, TAG_MOVE_RADIUS, -1);
		if (_radius == -1) then {
			_radius = CALLSM1("GoalGarrisonMove", "getLocationMoveRadius", _loc);
			T_SETV("radius", _radius);
		} else {
			T_SETV("radius", _radius);
		};

		T_SETV("time", -1);

		T_SETV("leadGroup", NULL_OBJECT);
		T_SETV("followGroups", []);

		// Create a VirtualRoute in advance
		// We will use it both when spawned and despawned
		T_CALLM0("createVirtualRoute");
		
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

		// Delete the virtual route object
		private _vr = T_GETV("virtualRoute");
		if (_vr != NULL_OBJECT) then {
			DELETE(_vr);
		};

	} ENDMETHOD;

	// Default implementation has a lead group (defaults to vehicle group, of which there should be only one),
	// other groups follow in a chain.
	/* private virtual */  METHOD("assignMoveGoals") {
		params [P_THISOBJECT, P_POSITION("_pos"), P_NUMBER("_radius"), P_ARRAY("_route"), P_BOOL("_instant")];

		private _AI = T_GETV("AI");
		private _gar = T_GETV("gar");

		private _vehGroups = CALLM1(_gar, "findGroupsByType", [GROUP_TYPE_VEH_NON_STATIC ARG GROUP_TYPE_VEH_STATIC]);
		if (count _vehGroups > 1) exitWith {
			OOP_WARNING_0("More than one vehicle group in the garrison!");
			ACTION_STATE_FAILED
		};
		private _infGroups = CALLM1(_gar, "findGroupsByType", [GROUP_TYPE_IDLE ARG GROUP_TYPE_PATROL]);
		if(count _vehGroups == 0 && count _infGroups == 0) exitWith {
			OOP_WARNING_0("No groups in the garrison!");
			ACTION_STATE_FAILED
		};
		private _infGroupsSortable = _infGroups apply { [ count CALLM0(_x, "getInfantryUnits"), _x ] };
		_infGroupsSortable sort DESCENDING;
		_infGroups = _infGroupsSortable apply { _x#1 };

		private _leadFollowGroups = if(count _vehGroups > 0) then {
			[_vehGroups#0, _infGroups]
		} else {
			[_infGroups#0, _infGroups select [1, count _infGroups]]
		};
		_leadFollowGroups params ["_leadGroup", "_followGroups"];

		// No instant move for this action we track unspawned progress already, and groups should be formed up and 
		// mounted already before it is called.
		private _args = ["GoalGroupMove", 0, [
			[TAG_POS, _pos],
			[TAG_MOVE_RADIUS, _radius],
			[TAG_ROUTE, _route]
		], _AI];
		private _leadGroupAI = CALLM0(_leadGroup, "getAI");
		CALLM2(_leadGroupAI, "postMethodAsync", "addExternalGoal", _args);

		// Reset current location of this garrison
		CALLM0(_gar, "detachFromLocation");

		private _prevGroup = _leadGroup;
		{
			private _args = ["GoalGroupFollow", 0, [
				[TAG_TARGET, CALLM0(_prevGroup, "getGroupHandle")]
			], _AI];
			private _groupAI = CALLM0(_x, "getAI");
			CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);
			_prevGroup = _x;
		} forEach _followGroups;

		T_SETV("leadGroup", _leadGroup);
		T_SETV("followGroups", _followGroups);

		ACTION_STATE_ACTIVE
	} ENDMETHOD;

	/* private virtual */  METHOD("checkMoveGoals") {
		params [P_THISOBJECT];

		private _AI = T_GETV("AI");

		private _leadGroup = T_GETV("leadGroup");
		private _followGroups = T_GETV("followGroups");

		if (CALLSM3("AI_GOAP", "anyAgentFailedExternalGoal", [_leadGroup], "GoalGroupMove", _AI)) exitWith {
			ACTION_STATE_FAILED
		};

		if (CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoalRequired", [_leadGroup], "GoalGroupMove", _AI)) exitWith {
			ACTION_STATE_COMPLETED
		};

		ACTION_STATE_ACTIVE
	} ENDMETHOD;

	// logic to run when the goal is activated
	METHOD("activate") {
		params [P_THISOBJECT, P_BOOL("_instant")];

		OOP_INFO_0("ACTIVATE");

		// Check if virtual route is ready
		private _vr = T_GETV("virtualRoute");

		private _state = if(_vr == NULL_OBJECT || { GETV(_vr, "calculated") }) then {
			// Give waypoint to the vehicle group
			private _AI = T_GETV("AI");
			private _pos = T_GETV("pos");
			private _radius = T_GETV("radius");

			private _route = if(_vr != NULL_OBJECT) then {
				CALLM0(_vr, "stop"); // Stop the virtual route (we don't use its process method any more)
				private _garPos = CALLM0(_AI, "getPos");
				CALLM1(_vr, "setPos", _garPos); // Update the virtual route with the proper garrison position
				CALLM0(_vr, "getAIWaypoints")
			} else {
				[]
			};

			T_SETV("time", TIME_NOW);

			T_CALLM0("clearGroupGoals");
			T_CALLM4("assignMoveGoals", _pos, _radius, _route, _instant)
		} else {
			ACTION_STATE_INACTIVE
		};

		T_SETV("state", _state);
		_state
	} ENDMETHOD;

	// logic to run each update-step
	METHOD("process") {
		params [P_THISOBJECT];

		private _gar = T_GETV("gar");
		private _AI = T_GETV("AI");
		private _garPos = CALLM0(_AI, "getPos");

		// Succeed the action if the garrison is close enough to its destination
		if (_garPos distance2D T_GETV("pos") <= T_GETV("radius")) exitWith {
			T_SETV("state", ACTION_STATE_COMPLETED);
			ACTION_STATE_COMPLETED
		};

		if (!CALLM0(_gar, "isSpawned")) then {
			private _state = T_GETV("state");
			private _vr = T_GETV("virtualRoute");

			if (_state == ACTION_STATE_INACTIVE) then {
				if(_vr == NULL_OBJECT || {GETV(_vr, "calculated")}) then {
					if(_vr != NULL_OBJECT) then {
						CALLM1(_vr, "setPos", _garPos);
						CALLM0(_vr, "start");
					};
					CALLM0(_gar, "detachFromLocation");
					_state = ACTION_STATE_ACTIVE;
				} else { 
					if(GETV(_vr, "failed")) then {
						private _pos = T_GETV("pos");
						OOP_WARNING_2("VirtualRoute failed from %1 to %2", _garPos, _pos);
						// If distance is reasonable then we can revert to straight line movement
						if(_pos distance2D _garPos < 2000) then {
							_vr = NULL_OBJECT;
							T_SETV("virtualRoute", _vr);
							_state = ACTION_STATE_ACTIVE;
						} else {
							_state = ACTION_STATE_FAILED;
						};
					};
				};
			};

			// Process the virtual convoy
			if (_state == ACTION_STATE_ACTIVE) then {
				private _newPos = if(_vr != NULL_OBJECT) then {
					// Run process of the virtual route and update position of the garrison
					CALLM0(_vr, "process");
					CALLM0(_vr, "getPos")
				} else {
					
					// Get a normalized vector heading towards destination
					private _vectorDir = _garPos vectorFromTo _posDest;
					private _vectorDist = _garPos distance _posDest;
					_vectorDir = ZERO_HEIGHT(_vectorDir);

					// Increase position
					private _dt = TIME_NOW - T_GETV("time");
					T_SETV("time", TIME_NOW);
					_garPos vectorAdd (_vectorDir vectorMultiply MINIMUM(_dt*3, _vectorDist))
				};
				CALLM1(_AI, "setPos", _newPos);
			};

			T_SETV("state", _state);
			_state
		} else {
			private _state = T_CALLM0("activateIfInactive");

			if (_state == ACTION_STATE_ACTIVE) then {
				_state = T_CALLM0("checkMoveGoals");
			};
			
			// Return the current state
			T_SETV("state", _state);
			_state
		};
	} ENDMETHOD;
	
	// Returns true if everyone is in vehicles
	METHOD("isEveryoneInVehicle") {
		params [P_THISOBJECT];
		private _AI = T_GETV("AI");
		private _ws = GETV(_AI, "worldState");
		
		private _return = 	([_ws, WSP_GAR_ALL_CREW_MOUNTED] call ws_getPropertyValue) &&
						([_ws, WSP_GAR_ALL_INFANTRY_MOUNTED] call ws_getPropertyValue);
		
		_return
	} ENDMETHOD;

	METHOD("onGarrisonDespawned") {
		params [P_THISOBJECT];

		// Create a new VirtualRoute since old one might be invalid
		T_CALLM0("createVirtualRoute");

		// Call base function, this will trigger reactivation
		T_CALLCM0("ActionGarrison", "onGarrisonDespawned");
	} ENDMETHOD;

	// Creates a new VirtualRoute object, deletes the old one
	METHOD("createVirtualRoute") {
		params [P_THISOBJECT];

		// Delete it if it exists already
		private _vr = T_GETV("virtualRoute");
		if(!isNil "_vr" && {_vr != NULL_OBJECT}) then {
			DELETE(_vr);
		};

		// Create a new virtual route
		private _gar = T_GETV("gar");

		private _side = CALLM(_gar, "getSide", []);
		private _cmdr = CALL_STATIC_METHOD("AICommander", "getAICommander", [_side]);

		private _threatCostFn = {
			params ["_base_cost", "_current", "_next", "_startRoute", "_goalRoute", "_callbackArgs"];
			_callbackArgs params ["_cmdr"];
			private _threat = CALLM(_cmdr, "getThreat", [getPos _next]);
			_base_cost + _threat * 20
		};

		private _args = [CALLM0(_gar, "getPos"), T_GETV("pos"), -1, _threatCostFn, "", [_cmdr], true, true];
		_vr = NEW("VirtualRoute", _args);
		T_SETV("virtualRoute", _vr);

		_vr
	} ENDMETHOD;

	METHOD("spawn") {
		params [P_THISOBJECT];

		private _gar = T_GETV("gar");

		// Spawn vehicle groups on the road according to convoy positions
		private _vr = T_GETV("virtualRoute");
		if (_vr == NULL_OBJECT || !GETV(_vr, "calculated")) exitWith { false }; // Perform standard spawning if there is no virtual route for some reason (why???)

		// Count all vehicles in garrison
		private _nVeh = count CALLM0(_gar, "getVehicleUnits");
		// We only provide custom spawning for vehicles
		if(_nVeh == 0) exitWith {false};
		private _posAndDir = if(!GETV(_vr, "calculated") || GETV(_vr, "failed")) then {
			private _vals = [];
			private _garPos = CALLM0(_gar, "getPos");
			for "_i" from 1 to _nVeh do {
				_vals pushBack [_garPos, 0];
			};
			_vals
		} else {
			CALLM2(_vr, "getConvoyPositions", _nVeh, 30)
		};

		// Bail if we have failed to get positions
		if (count _posAndDir != _nVeh) exitWith {false};

		// Iterate through all groups
		private _currentIndex = 0;
		private _groups = CALLM0(_gar, "getGroups");
		{
			private _nVehThisGroup = count CALLM0(_x, "getVehicleUnits");
			if (_nVehThisGroup > 0) then {
				private _posAndDirThisGroup = _posAndDir select [_currentIndex, _nVehThisGroup];
				CALLM1(_x, "spawnVehiclesOnRoad", _posAndDirThisGroup);

				// Make leader the first human in the group
				CALLM0(_x, "_selectNextLeader");

				_currentIndex = _currentIndex + _nVehThisGroup;
			} else {
				private _posAndDirThisGroup = _posAndDir select [0, 1];
				CALLM1(_x, "spawnVehiclesOnRoad", _posAndDirThisGroup);
			};
		} forEach _groups;

		// Spawn single units
		private _units = CALLM0(_gar, "getUnits");
		private _garPos = CALLM0(_gar, "getPos");
		{
			private _unit = _x;
			if (CALL_METHOD(_x, "getGroup", []) == "") then {
				private _className = CALLM0(_unit, "getClassName");

				private _posAndDir = CALLSM3("Location", "findSafePos", _garPos, _className, 400);

				// After a good place has been found, spawn it
				CALL_METHOD(_unit, "spawn", _posAndDir);
			};
		} forEach _units;

		true
	} ENDMETHOD;

ENDCLASS;