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
#define GROUP_SEPARATION 50
#define DEFAULT_COMBINED_SPEED_MAX 12
#define DEFAULT_SPEED_MAX 100
#define URBAN_SPEED_MAX 20
#define SPEED_MIN 5
#define SPEED_SLOW_AIR 50 // speed to slow down to at target (to avoid bad flaring)

#ifndef RELEASE_BUILD
#define DEBUG_FORMATION
#endif
FIX_LINE_NUMBERS()

#define OOP_CLASS_NAME ActionGroupMove
CLASS("ActionGroupMove", "ActionGroup")

	VARIABLE("pos");
	VARIABLE("radius"); // Completion radius
	VARIABLE("speedLimit"); // The current speed limit
	VARIABLE("maxSpeed"); // The maximum speed in this action, can be received as parameter
	VARIABLE("followingGroups"); // Following groups, to make sure this group waits for them
	VARIABLE("time");
	VARIABLE("route"); // Optional route to use, or just give one waypoint if no route was given
	VARIABLE("ready"); // Activation tasks complete
	VARIABLE("leader");
	VARIABLE("followers");

	public override METHOD(getPossibleParameters)
		[
			[ [TAG_POS, [[]]], [TAG_MOVE_RADIUS, [0]] ],	// Required parameters
			[ [TAG_FOLLOWERS, [[]]], [TAG_ROUTE, [[]]], [TAG_MAX_SPEED_KMH, [0]] ]	// Optional parameters
		]
	ENDMETHOD;

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		private _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		T_SETV("pos", _pos);

		private _radius = CALLSM3("Action", "getParameterValue", _parameters, TAG_MOVE_RADIUS, 20);
		T_SETV("radius", _radius);

		private _followingGroups = CALLSM3("Action", "getParameterValue", _parameters, TAG_FOLLOWERS, []);
		T_SETV("followingGroups", _followingGroups);

		private _defaultMaxSpeed = if(count _followingGroups > 0 && { (_followingGroups findIf { CALLM0(_x, "getType") == GROUP_TYPE_INF }) != NOT_FOUND }) then {
			DEFAULT_COMBINED_SPEED_MAX
		} else {
			DEFAULT_SPEED_MAX
		};

		private _maxSpeedKmh = CALLSM3("Action", "getParameterValue", _parameters, TAG_MAX_SPEED_KMH, _defaultMaxSpeed);
		T_SETV("maxSpeed", _maxSpeedKmh);


		// Route can be optionally passed or not
		private _route = CALLSM3("Action", "getParameterValue", _parameters, TAG_ROUTE, []);
		T_SETV("route", _route);

		T_SETV("time", GAME_TIME);
		T_SETV("speedLimit", SPEED_MIN);
		T_SETV("ready", false);
		T_SETV("leader", NULL_OBJECT);
		T_SETV("followers", []);
	ENDMETHOD;

	// logic to run when the goal is activated
	protected override METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];

		T_SETV("ready", false);

		// Set time last called
		T_SETV("time", GAME_TIME);
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

			if(!CALLM0(_group, "isAirGroup")) then {
				{
					// Set the speed of all vehicles to unlimited
					_x limitSpeed -1;
					_x setConvoySeparation SEPARATION;
					//_x forceFollowRoad true;
				} forEach (_vehicles apply {CALLM0(_x, "getObjectHandle")});

				private _vehLeadHandle = CALLM0(_vehLead, "getObjectHandle");
				_vehLeadHandle limitSpeed SPEED_MIN;
			};

			private _vehLeadPos = CALLM0(_vehLead, "getPos");

			// Sort infantry units by distance to the selected leader
			private _followers = CALLM0(_group, "getInfantryUnits") - [_leader];
			private _sortedFollowers =  [_followers, { CALLM0(_x, "getPos") distance2D _vehLeadPos }, ASCENDING] call vin_fnc_sortBy;

			// Apply the sorting, this will also assign the _leader as the group leader
			CALLM3(_group, "postMethodAsync", "sort", [[_leader] + _sortedFollowers], _continuation);

			ACTION_STATE_ACTIVE
		} else {
			// We can complete immediately
			T_CALLM1("completeActivation", _instant);
			ACTION_STATE_ACTIVE
		};

		T_SETV("state", _state);
		_state
	ENDMETHOD;

	/* private */ METHOD(completeActivation)
		params [P_THISOBJECT, P_BOOL("_instant")];

		private _AI = T_GETV("AI");
		private _group = GETV(_AI, "agent");

		T_CALLM0("clearWaypoints");
		
		private _vehUnits = CALLM0(_group, "getVehicleUnits");
		private _infUnits = CALLM0(_group, "getInfantryUnits");
		if(count _vehUnits > 0) then {
			T_CALLM4("applyGroupBehaviour", "COLUMN", "CARELESS", "YELLOW", "NORMAL");
		} else {
			T_CALLM4("applyGroupBehaviour", "STAG COLUMN", "AWARE", "YELLOW", "NORMAL");
		};

		private _leader = CALLM0(_group, "getLeader");

		// Add move goal to leader
		private _leaderAI = CALLM0(_leader, "getAI");
		if (count _vehUnits > 0) then {

			// Add follow goals for units other than the leader
			private _followersAndAI = (_infUnits - [_leader]) apply {
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

			// Move with vehicle
			private _parameters = [
				[TAG_POS, T_GETV("pos")],
				[TAG_MOVE_RADIUS, T_GETV("radius")],
				[TAG_ROUTE, T_GETV("route")],
				[TAG_INSTANT, _instant]
			];
			CALLM4(_leaderAI, "addExternalGoal", "GoalUnitMove", 0, _parameters, _AI);
		} else {
			// Just move on foot
			private _parameters = [
				[TAG_MOVE_TARGET, T_GETV("pos")],
				[TAG_MOVE_RADIUS, T_GETV("radius")],
				[TAG_INSTANT, _instant]
			];
			CALLM4(_leaderAI, "addExternalGoal", "GoalUnitInfantryMove", 0, _parameters, _AI);

			// Everyone else must regroup
			{
				private _ai = CALLM0(_x, "getAI");
				private _parameters = [[TAG_INSTANT, _instant]];
				private _args = ["GoalUnitInfantryRegroup", 0, _parameters, _AI, true, false, true]; // Will be always active, even when completed
				CALLM(_ai, "addExternalGoal", _args);
			} forEach (_infUnits - [_leader]);
		};

		// Make sure crew get mounted and infantry are assigned as cargo
		T_CALLM0("updateVehicleAssignments");

		T_SETV("leader", _leader);
		T_SETV("followers", _followers);

		T_SETV("ready", true);
	ENDMETHOD;

	// Logic to run each update-step
	public override METHOD(process)
		params [P_THISOBJECT];

		if(T_CALLM0("failIfNoInfantry") == ACTION_STATE_FAILED) exitWith {
			ACTION_STATE_FAILED
		};

		private _hG = T_GETV("hG");
		private _ai = T_GETV("ai");
		private _pos = T_GETV("pos");
		private _radius = T_GETV("radius");

		if (leader _hG distance2D _pos <= _radius) exitWith {
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

				private _maxSpeed = T_GETV("maxSpeed"); 


				private _dt = GAME_TIME - T_GETV("time") + 0.001;
				T_SETV("time", GAME_TIME);

				// Check for speed control based on vehicle and follow group separation
				private _speedLimit = T_GETV("speedLimit");
				if(!CALLM0(_group, "isAirGroup")) then {
					if(T_CALLM0("getMaxSeparation") > 3 * SEPARATION || {T_CALLM0("getMaxFollowSeparation") > 3 * GROUP_SEPARATION}) then
					{
						// We are driving too fast!
						_speedLimit = (_speedLimit - _dt*2);
					}
					else
					{
						// We are driving too slow?
						_speedLimit = (_speedLimit + _dt*4);
					};

					// Check for driving in a built up area, and slow down a lot if we are
					private _leaderPos = CALLM0(_leader, "getPos");
					// TODO: predict safe speed better, maybe look ahead for obstacles
					private _urbanArea = count (_leaderPos nearObjects ["House", 100]) > 50;
					if(_urbanArea) then { 
						_maxSpeed = MINIMUM(_maxSpeed, URBAN_SPEED_MAX);
					};
					_speedLimit = CLAMP(_speedLimit, SPEED_MIN, _maxSpeed);
				} else {
					// Check distance to target, and slow down when getting closer
					_speedLimit = MAXIMUM(SPEED_SLOW_AIR, 0.25 * ((_pos distance2D leader _hG) - _radius));
				};
				T_SETV("speedLimit", _speedLimit);
				vehicle leader _hG limitSpeed _speedLimit;
			} else {
				private _nUnits = count units _hG;
				private _infantrySeparation = T_CALLM0("getInfantrySeparation");
				if((T_CALLM0("getMaxFollowSeparation") > 3 * GROUP_SEPARATION) ||
					_infantrySeparation > ((_nUnits * 6) max 35)) then {
					// Set reduced group speed
					private _speedMode = T_GETV("speedMode");
					CALLM1(_ai, "setSpeedMode", "LIMITED");
				} else {
					// Restore default group speed
					private _speedMode = T_GETV("speedMode");
					private _newSpeedMode = [_speedMode, "NORMAL"] select (_speedMode isEqualTo "");
					CALLM1(_ai, "setSpeedMode", _newSpeedMode);
				};
			};
		};
		T_SETV("state", _state);
		_state
	ENDMETHOD;

	public override METHOD(handleUnitsAdded)
		params [P_THISOBJECT, P_ARRAY("_units")];
		// Reactivate, as we need to reassign goals
		T_SETV("state", ACTION_STATE_INACTIVE);
	ENDMETHOD;

	public override METHOD(handleUnitsRemoved)
		params [P_THISOBJECT, P_ARRAY("_units")];

		// Turn off vehicle sirens for removed units
		{
			private _t = CALLM0(CALLM0(_x, "getGarrison"), "getTemplate");
			private _hO = CALLM0(_x, "getObjectHandle");
			[_t, T_API, T_API_fnc_VEH_siren, [_hO, false]] call t_fnc_callAPIOptional;
		} forEach (_units select { CALLM0(_x, "isVehicle") });

		// Reactivate, as we need to reassign goals
		T_SETV("state", ACTION_STATE_INACTIVE);
	ENDMETHOD;

	// logic to run when the action is satisfied
	public override METHOD(terminate)
		params [P_THISOBJECT];

		T_CALLCM0("ActionGroup", "terminate");
		// Turn off vehicle sirens, and reset speed limits
		{
			private _t = CALLM0(CALLM0(_x, "getGarrison"), "getTemplate");
			private _hO = CALLM0(_x, "getObjectHandle");
			[_t, T_API, T_API_fnc_VEH_siren, [_hO, false]] call t_fnc_callAPIOptional;
			_hO limitSpeed 666666;
		} forEach CALLM0(T_GETV("group"), "getVehicleUnits");

		T_CALLM0("clearWaypoints");
	ENDMETHOD;

	//Gets the maximum separation between vehicles in convoy
	METHOD(getMaxSeparation)
		params [P_THISOBJECT];

		private _group = T_GETV("group");

		private _allVehicles = CALLM0(_group, "getVehicleUnits") apply { CALLM0(_x, "getPos") };
		if(count _allVehicles <= 1) exitWith {
			0
		};

		private _vehLead = vehicle leader CALLM0(_group, "getGroupHandle");
		// Sort vehicles by distance from lead vehicle
		_allVehicles = [_allVehicles, { _x distance2D _vehLead }, ASCENDING] call vin_fnc_sortBy;
		private _dMax = 0;
		private _prev = _allVehicles deleteAt 0;
		{
			_dMax = MAXIMUM(_x distance2D _prev, _dMax);
			_prev = _x;
		} forEach _allVehicles;
		_dMax
	ENDMETHOD;

	//Gets the maximum separation between following groups
	METHOD(getMaxFollowSeparation)
		params [P_THISOBJECT];

		private _followingGroups = T_GETV("followingGroups") apply { CALLM0(_x, "getGroupHandle") };
		if(count _followingGroups < 1) exitWith {
			0
		};

		private _hG = T_GETV("hG");

		// Sort following groups by distance from this group
		_followingGroups = [_followingGroups, { leader _x distance2D leader _hG }, ASCENDING] call vin_fnc_sortBy;
		private _dMax = 0;
		private _unitsByDistance = [ units _hG, { _x distance2D leader _hG }, DESCENDING] call vin_fnc_sortBy;
		private _lastUnitPrevGroup = _unitsByDistance#0;
		{
			private _followGrp = _x;
			// Distance from last unit in previous group to leader of this group
			_dMax = MAXIMUM(leader _followGrp distance2D _lastUnitPrevGroup, _dMax);
			private _otherUnitsByDistance = [ units _followGrp, { _x distance2D _lastUnitPrevGroup }, DESCENDING] call vin_fnc_sortBy;
			_lastUnitPrevGroup = _otherUnitsByDistance#0;
		} forEach _followingGroups;
		_dMax
	ENDMETHOD;

	// Gets max distance between leader and any of its subordinates
	/* private */ METHOD(getInfantrySeparation)
		params [P_THISOBJECT];

		private _hG = T_GETV("hG");
		private _leader = leader _hG;
		private _distances = ((units _hG) - [_leader]) apply {_x distance _leader};
		
		// Bail if noone is following
		if (count _distances == 0) exitWith {
			return 0;
		};

		private _maxDistance = selectMax _distances;
		return _maxDistance;
	ENDMETHOD;
ENDCLASS;
