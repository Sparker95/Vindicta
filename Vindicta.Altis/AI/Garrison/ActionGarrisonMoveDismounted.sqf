#include "common.hpp"

/*
Everyone moves on foot
*/

#define pr private

#define THIS_ACTION_NAME "ActionGarrisonMoveDismounted"

CLASS(THIS_ACTION_NAME, "ActionGarrison")

	VARIABLE("pos");
	VARIABLE("time");

	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
		// Unpack position
		pr _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
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
		T_SETV("pos", _pos);

		// Mark time of last call as uninitialized
		T_SETV("time", -1);
		
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];		
		
		pr _gar = T_GETV("gar");
		pr _pos = T_GETV("pos");
		pr _AI = T_GETV("AI");
		
		// Give goals to groups
		pr _args = ["GoalGroupInfantryMove", 0, [[TAG_POS, _pos]], _AI];
		{
			pr _groupAI = CALLM0(_x, "getAI");
			CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);
		} forEach CALLM0(_gar, "getGroups");
		
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
		pr _AI = T_GETV("AI");

		if (!CALLM0(_gar, "isSpawned")) then {
			// If not spawned, move in a straight line for now

			if (T_GETV("state") == ACTION_STATE_INACTIVE) then {
				CALLM0(_gar, "detachFromLocation");
			};

			pr _state = ACTION_STATE_ACTIVE;

			// Get a normalized vector heading towards destination
			pr _pos = CALLM0(_gar, "getPos");
			pr _posDest = T_GETV("pos");
			pr _vectorDir = _posDest vectorDiff _pos;
			_vectorDir set [2, 0];
			_vectorDir = vectorNormalized _vectorDir;

			// Increase position
			pr _timeLastCall = T_GETV("time");
			if (_timeLastCall == -1) then {_timeLastCall = time;};
			pr _dt = time - _timeLastCall;
			_pos = _pos vectorAdd (_vectorDir vectorMultiply (_dt*3));
			CALLM1(_AI, "setPos", _pos);

			// Succeed if the garrison is close enough
			if (_pos distance2D _posDest < 66.6) then {
				_state = ACTION_STATE_COMPLETED;
			};

			T_SETV("time", time);

			T_SETV("state", _state);
			_state
		} else {
			pr _state = CALLM0(_thisObject, "activateIfInactive");
		
			if (_state == ACTION_STATE_ACTIVE) then {
				// Update position
				pr _infUnits = CALLM0(_gar, "getInfantryUnits");
				pr _index = _infUnits findIf {CALLM0(_x, "isAlive")};
				if (_index != -1) then {
					pr _unit = _infUnits select _index;
					pr _hO = CALLM0(_unit, "getObjectHandle");
					pr _pos = getPos _hO;
					CALLM1(_AI, "setPos", _pos);
				};

				pr _groups = CALLM0(_gar, "getGroups");
				if (CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoal", _groups, "GoalGroupInfantryMove", _AI)) then {
					_state = ACTION_STATE_COMPLETED;
				};
			};
			
			// Return the current state
			T_SETV("state", _state);
			_state
		};
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		// Bail if not spawned
		pr _gar = T_GETV("gar");
		if (!CALLM0(_gar, "isSpawned")) exitWith {};

		// Delete goals given to groups
		
		// Delete goals from groups
		pr _args = ["GoalGroupInfantryMove", ""];
		{
			pr _groupAI = CALLM0(_x, "getAI");
			CALLM2(_groupAI, "postMethodAsync", "deleteExternalGoal", _args);
		} forEach CALLM0(_gar, "getGroups");
		
	} ENDMETHOD;
	

	METHOD("onGarrisonSpawned") {
		params ["_thisObject"];

		// Reset action state so that it reactivates
		T_SETV("state", ACTION_STATE_INACTIVE);
	} ENDMETHOD;
	
	METHOD("onGarrisonDespawned") {
		params ["_thisObject"];
		
		// Reset action state so that it reactivates
		T_SETV("state", ACTION_STATE_INACTIVE);
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