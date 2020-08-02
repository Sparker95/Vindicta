#include "common.hpp"

/*
Class: ActionGroup.ActionGroupPatrol
*/

#define pr private

#define OOP_CLASS_NAME ActionGroupPatrol
CLASS("ActionGroupPatrol", "ActionGroup")

	VARIABLE("route");

	public override METHOD(getPossibleParameters)
		[
			[ ],	// Required parameters
			[ [TAG_ROUTE, [[]] ] ]	// Optional parameters
		]
	ENDMETHOD;

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		// Route can be optionally passed or not
		// We add the target position to the end
		private _route = +CALLSM3("Action", "getParameterValue", _parameters, TAG_ROUTE, []);
		T_SETV("route", _route);
	ENDMETHOD;

	// logic to run when the goal is activated
	protected override METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];
		
		pr _hG = T_GETV("hG");

		T_CALLM3("applyGroupBehaviour", "COLUMN", "SAFE", "RED");
		T_CALLM0("clearWaypoints");
		T_CALLM0("regroup");

		// Assign patrol waypoints
		pr _AI = T_GETV("AI");
		pr _group = GETV(_AI, "agent");
		pr _type = CALLM0(_group, "getType");
		OOP_INFO_1("Started for AI: %1", _AI);
		pr _gar = CALLM0(_group, "getGarrison");
		pr _loc = CALLM0(_gar, "getLocation");
		
		pr _useDefaultPatrolWaypoints = true;
		pr _waypoints = T_GETV("route");

		// Override behaviour for non-static vehicle groups
		// They must walk around their vehicles
		if (_type == GROUP_TYPE_VEH) then {
			// Crew of vehicle groups stays around their vehicle
			pr _vehUnits = CALLM0(_group, "getVehicleUnits");
			if (count _vehUnits > 0) then {
				pr _vehUnit = selectRandom _vehUnits;
				pr _pos = CALLM0(_vehUnit, "getPos");

				if (! (_pos isEqualTo [0, 0, 0])) then { // Better to be safe here, we don't want to be in the sea
					_waypoints pushBack (_pos getPos [10 + random 20, random 360]);
					_useDefaultPatrolWaypoints = false;
				};
			};
		};

		// Default waypoints
		// If at a location, takes waypoints from location border
		// If in field, adds some circular waypoints
		// Check if there is a location
		if (count _waypoints == 0 && _useDefaultPatrolWaypoints) then {
			if (_loc != NULL_OBJECT) then {
				_waypoints = CALLM0(_loc, "getPatrolWaypoints");
			} else {
				// Generate some random patrol waypoints
				pr _angle = 0;
				pr _leaderPos = leader _hG;
				while { _angle < 360 } do {
					pr _newPos = _leaderPos getPos [100 + random 40, _angle];
					while { surfaceIsWater _newPos && _newPos distance2D _leaderPos > 50 } do {
						_newPos = _leaderPos getPos [(_newPos distance2D _leaderPos) * 0.75, _angle];
					};
					if(!surfaceIsWater _newPos) then {
						_waypoints pushBack _newPos;
					};
					_angle = _angle + 30;
				};
			};
		};

		// Give waypoints to the group
		pr _direction = selectRandom [false, true];
		pr _count = count _waypoints;
		pr _indexStart = floor (random _count);
		pr _index = _indexStart;
		pr _i = 0;
		pr _wpIDs = []; // Array with waypoint IDs
		private _closestWPID = 0;
		private _minDist = 666666;
		while {_i < _count} do {
			private _wayPointPos = ZERO_HEIGHT(_waypoints select _index);
			pr _wp = _hG addWaypoint [AGLToASL _wayPointPos, -1];
			_wp setWaypointType "MOVE";
			_wp setWaypointBehaviour "SAFE"; //"AWARE"; //"SAFE";
			//_wp setWaypointForceBehaviour true; //"AWARE"; //"SAFE";
			_wp setWaypointSpeed "LIMITED"; //"FULL"; //"LIMITED";
			_wp setWaypointFormation "WEDGE";
			_wpIDs pushback (_wp select 1);
			
			// Also find the closest waypoint
			private _dist = leader _hG distance2D _wayPointPos;
			if(_dist < _minDist) then {
				_closestWPID = (_wp select 1);
				_minDist = _dist;
			};
			
			if(_direction) then	{ // Clockwise
				_index = _index + 1;
				if(_index == _count) then{_index = 0;};
			} else { //Counterclockwise
				_index = _index - 1;
				if(_index  < 0) then {_index = _count-1;};
			};
			_i = _i + 1;
		};
		
		// Add cycle waypoint
		if (count _waypoints > 1) then {
			pr _wp = _hG addWaypoint [AGLToASL ZERO_HEIGHT(_waypoints select _indexStart), -1]; //Cycle the waypoints
			_wp setWaypointType "CYCLE";
			_wp setWaypointBehaviour "SAFE";
			_wp setWaypointSpeed "LIMITED";
			_wp setWaypointFormation "WEDGE";
		};

		pr _activeWP = if(_instant) then {
			// Teleport to a random patrol waypoint
			pr _rndWP = selectRandom waypoints _hG;
			T_CALLM1("teleport", getWPPos _rndWP);
			_rndWP
		} else {
			[_hG, _closestWPID]
		};

		// Set the closest WP as current
		_hG setCurrentWaypoint _activeWP;

		// Give a goal to units
		pr _units = CALLM0(_group, "getInfantryUnits");
		{
			pr _unitAI = CALLM0(_x, "getAI");
			private _parameters = [[TAG_INSTANT, _instant]];
			private _args = ["GoalUnitInfantryRegroup", 0, _parameters, _AI, true, false, true]; // Will be always active, even when completed
			CALLM(_unitAI, "addExternalGoal", _args);
		} forEach _units;

		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	ENDMETHOD;
	
	// Logic to run each update-step
	public override METHOD(process)
		params [P_THISOBJECT];
		
		T_CALLM0("failIfEmpty");
		
		T_CALLM0("activateIfInactive");
		
		// Return the current state
		ACTION_STATE_ACTIVE
	ENDMETHOD;
	
	// logic to run when the action is satisfied
	public override METHOD(terminate)
		params [P_THISOBJECT];
		
		T_CALLCM0("ActionGroup", "terminate");

		// Delete all waypoints
		T_CALLM0("clearWaypoints");
		
	ENDMETHOD;

ENDCLASS;