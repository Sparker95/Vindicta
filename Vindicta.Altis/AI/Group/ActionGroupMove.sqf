#include "common.hpp"

/*
Class: ActionGroup.ActionGroupMove
Handles moving of a group with multiple or single ground vehicles.

Tags:
TAG_POS
TAG_MOVE_RADIUS
TAG_MAX_SPEED_KMH
*/

// Needed vehicle separation in meters
#define SEPARATION 18
#define DEFAULT_SPEED_MAX 100
#define URBAN_SPEED_MAX 20
#define SPEED_MIN 5

#ifndef RELEASE_BUILD
#define DEBUG_FORMATION
#endif

CLASS("ActionGroupMove", "ActionGroup")

	VARIABLE("pos");
	VARIABLE("radius"); // Completion radius
	VARIABLE("speedLimit"); // The current speed limit
	VARIABLE("maxSpeed"); // The maximum speed in this action, can be received as parameter
	VARIABLE("time");
	VARIABLE("route"); // Optional route to use, or just give one waypoint if no route was given
	VARIABLE("ready"); // Activation tasks complete
	VARIABLE("leader");
	VARIABLE("followers");

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		private _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		T_SETV("pos", _pos);

		private _radius = CALLSM3("Action", "getParameterValue", _parameters, TAG_MOVE_RADIUS, 20);
		T_SETV("radius", _radius);

		private _maxSpeedKmh = CALLSM3("Action", "getParameterValue", _parameters, TAG_MAX_SPEED_KMH, DEFAULT_SPEED_MAX);
		T_SETV("maxSpeed", _maxSpeedKmh);

		// Route can be optionally passed or not
		private _route = CALLSM3("Action", "getParameterValue", _parameters, TAG_ROUTE, []);
		T_SETV("route", _route);

		T_SETV("time", time);
		T_SETV("speedLimit", SPEED_MIN);
		T_SETV("ready", false);
		T_SETV("leader", NULL_OBJECT);
		T_SETV("followers", []);
	} ENDMETHOD;

	// logic to run when the goal is activated
	/* protected override */ METHOD("activate") {
		params [P_THISOBJECT, P_BOOL("_instant")];

		T_SETV("ready", false);

		// Set time last called
		T_SETV("time", time);
		T_SETV("leader", NULL_OBJECT);
		T_SETV("followers", []);

		// Clear existing goals from the units
		T_CALLM1("clearUnitGoals", ["GoalUnitFollow" ARG "GoalUnitMove"]);

		private _AI = T_GETV("AI");
		private _group = GETV(_AI, "agent");
		private _vehicles = CALLM0(_group, "getVehicleUnits");

		// We apply sorting to the group, then set group goals in the callback
		private _continuation = ["completeActivation", [_instant], _thisObject];
		private _state = if (count _vehicles > 0) then {
			private _vehLead = _vehicles#0;
			private _vehLeadAI = CALLM0(_vehLead, "getAI");
			private _leader = CALLM0(_vehLeadAI, "getAssignedDriver");

			if(_leader == NULL_OBJECT || { !CALLM0(_leader, "isAlive") }) exitWith {
				ACTION_STATE_FAILED
			};

			// Turn on vehicle sirens if we have them
			{
				private _gar = CALLM0(_x, "getGarrison");
				private _t = CALLM0(_gar, "getTemplate");
				private _hO = CALLM0(_x, "getObjectHandle");
				[_t, T_API, T_API_fnc_VEH_siren, [_hO, true]] call t_fnc_callAPIOptional;
			} forEach _vehicles;

			{
				// Set the speed of all vehicles to unlimited
				_x limitSpeed 666666;
				_x setConvoySeparation SEPARATION;
				//_x forceFollowRoad true;
			} forEach (_vehicles apply {CALLM0(_x, "getObjectHandle")});

			private _vehLeadHandle = CALLM0(_vehLead, "getObjectHandle");
			_vehLeadHandle limitSpeed SPEED_MIN;

			private _vehLeadPos = CALLM0(_vehLead, "getPos");

			// Sort infantry units by distance to the lead vehicle
			private _distAndUnits = (CALLM0(_group, "getInfantryUnits") - [_leader]) apply {
				[CALLM0(_x, "getPos") distance _vehLeadPos, _x];
			};
			_distAndUnits sort ASCENDING;
			private _sortedUnits = [_leader] + (_distAndUnits apply { _x#1 });

			// Apply the sorting, this will also assign the _leader as the group leader
			CALLM3(_group, "postMethodAsync", "sort", [_sortedUnits], _continuation);

			ACTION_STATE_ACTIVE
		} else {
			// We can complete immediately
			T_CALLM1("completeActivation", _instant);
			ACTION_STATE_ACTIVE
		};

		T_SETV("state", _state);
		_state
	} ENDMETHOD;

	/* private */ METHOD("completeActivation") {
		params [P_THISOBJECT, P_BOOL("_instant")];

		private _AI = T_GETV("AI");
		private _group = GETV(_AI, "agent");

		T_CALLM0("clearWaypoints");

		if(count CALLM0(_group, "getVehicleUnits") > 0) then {
			T_CALLM4("applyGroupBehaviour", "COLUMN", "CARELESS", "YELLOW", "NORMAL");
		} else {
			T_CALLM4("applyGroupBehaviour", "STAG COLUMN", "AWARE", "YELLOW", "NORMAL");
		};

		private _leader = CALLM0(_group, "getLeader");

		// Add follow goals for units other than the leader
		private _followersAndAI = (CALLM0(_group, "getInfantryUnits") - [_leader]) apply {
			[_x, CALLM0(_x, "getAI")]
		} select {
			_x params ["_unit", "_AI"];
			CALLM0(_AI, "getAssignedVehicleRole") == "DRIVER"
		};
		private _followers = _followersAndAI apply { _x#0 };
		private _followersAI = _followersAndAI apply { _x#1 };
		{
			CALLM4(_x, "addExternalGoal", "GoalUnitFollow", 0, [[TAG_INSTANT ARG _instant]], _AI);
		} forEach _followersAI;

		// Add move goal to leader
		private _leaderAI = CALLM0(_leader, "getAI");
		private _parameters = [
			[TAG_POS, T_GETV("pos")],
			[TAG_MOVE_RADIUS, T_GETV("radius")],
			[TAG_ROUTE, T_GETV("route")],
			[TAG_INSTANT, _instant]
		];
		CALLM4(_leaderAI, "addExternalGoal", "GoalUnitMove", 0, _parameters, _AI);

		// Make sure crew get mounted and infantry are assigned as cargo
		T_CALLM0("updateVehicleAssignments");

		T_SETV("leader", _leader);
		T_SETV("followers", _followers);

		T_SETV("ready", true);
	} ENDMETHOD;

	// Logic to run each update-step
	/* protected override */ METHOD("process") {
		params [P_THISOBJECT];

		if(T_CALLM0("failIfNoInfantry") == ACTION_STATE_FAILED) exitWith {
			ACTION_STATE_FAILED
		};

		private _hG = T_GETV("hG");
		private _pos = T_GETV("pos");
		private _radius = T_GETV("radius");

		if (leader _hG distance _pos <= _radius) exitWith {
			T_SETV("state", ACTION_STATE_COMPLETED);
			ACTION_STATE_COMPLETED
		};

		private _state = T_CALLM0("activateIfInactive");

		if (T_GETV("ready") && _state == ACTION_STATE_ACTIVE) then {
			private _group = GETV(T_GETV("AI"), "agent");
			private _leader = T_GETV("leader");

			// Fail if there is no leader or the leader is dead
			if (_leader == NULL_OBJECT || { !CALLM0(_leader, "isAlive") }) exitWith {
				_state = ACTION_STATE_FAILED;
			};

			private _followers = T_GETV("followers");
			private _AI = T_GETV("AI");

			// If any units failed their goals
			if(CALLSM3("AI_GOAP", "anyAgentFailedExternalGoal", [_leader], "GoalUnitMove", _AI) ||
				CALLSM3("AI_GOAP", "anyAgentFailedExternalGoal", _followers, "GoalUnitFollow", _AI)) exitWith {
				_state = ACTION_STATE_FAILED;
			};

			// If goals are marked complete we reactivate because the position check at the top of this function didn't pass,
			// we need to try and get closer
			if(CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoalRequired", [_leader], "GoalUnitMove", _AI) &&
				CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoalRequired", _followers, "GoalUnitFollow", _AI)) exitWith {
				_state = ACTION_STATE_INACTIVE;
			};

			private _hasVehicles = count CALLM0(_group, "getVehicleUnits") > 0;
			if(_hasVehicles) then {
				// Check the separation of the vehicles if we have any
				private _sCur = T_CALLM0("getMaxSeparation"); //The current maximum separation between vehicles

				private _maxSpeed = T_GETV("maxSpeed"); 

				// Check for driving in a built up area, and slow down a lot if we are
				private _leaderPos = CALLM0(_leader, "getPos");
				// TODO: predict safe speed better, maybe look ahead for obstacles
				private _urbanArea = count (_leaderPos nearObjects ["House", 100]) > 50;
				if(_urbanArea) then { 
					_maxSpeed = MINIMUM(_maxSpeed, URBAN_SPEED_MAX);
				};

				private _dt = time - T_GETV("time") + 0.001;
				T_SETV("time", time);

				// Check for speed control based on convoy separation
				private _speedLimit = T_GETV("speedLimit");
				if(_sCur > 3 * SEPARATION) then
				{
					// We are driving too fast!
					_speedLimit = (_speedLimit - _dt*2);
				}
				else
				{
					// We are driving too slow?
					_speedLimit = (_speedLimit + _dt*4);
				};

				_speedLimit = CLAMP(_speedLimit, SPEED_MIN, _maxSpeed);
				T_SETV("speedLimit", _speedLimit);

				vehicle leader _hG limitSpeed _speedLimit;
			};
		};
		T_SETV("state", _state);
		_state
	} ENDMETHOD;

	/* protected override */ METHOD("handleUnitsAdded") {
		params [P_THISOBJECT, P_ARRAY("_units")];
		// Reactivate, as we need to reassign goals
		T_SETV("state", ACTION_STATE_INACTIVE);
	} ENDMETHOD;

	/* protected override */ METHOD("handleUnitsRemoved") {
		params [P_THISOBJECT, P_ARRAY("_units")];
		// Reactivate, as we need to reassign goals
		T_SETV("state", ACTION_STATE_INACTIVE);
	} ENDMETHOD;

	// logic to run when the action is satisfied
	/* protected override */ METHOD("terminate") {
		params [P_THISOBJECT];

		T_CALLM0("clearWaypoints");
		T_CALLM1("clearUnitGoals", ["GoalUnitFollow" ARG "GoalUnitMove"]);
	} ENDMETHOD;

	//Gets the maximum separation between vehicles in convoy
	/* private */ METHOD("getMaxSeparation") {
		params [P_THISOBJECT];

		private _group = T_GETV("group");

		private _allVehicles = CALLM0(_group, "getVehicleUnits") apply { CALLM0(_x, "getObjectHandle") };
		if(count _allVehicles <= 1) exitWith {
			0
		};

		private _vehLead = vehicle leader CALLM0(_group, "getGroupHandle");
		
		//diag_log format ["All vehicles: %1", _allVehicles];
		//diag_log format ["Lead vehicle: %1", _vehLead];
		private _vehArraySort = _allVehicles apply {[_x distance _vehLead, _x]};

		//diag_log format ["Unsorted array: %1", _vehArraySort];
		_vehArraySort sort ASCENDING;

		_allVehicles = _vehArraySort apply { _x#1 };
		//diag_log format ["Sorted array: %1", _vehArraySort];
		//Get the max separation
		private _dMax = 0;
		private _prev = _allVehicles deleteAt 0;
		{
			_dMax = MAXIMUM(_x distance _prev, _dMax);
			_prev = _x;
		} forEach _allVehicles;
		_dMax
	} ENDMETHOD;

ENDCLASS;
