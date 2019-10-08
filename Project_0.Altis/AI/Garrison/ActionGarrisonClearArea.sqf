#include "common.hpp"

/*
All crew of vehicles mounts assigned vehicles.
*/

#define pr private

#define THIS_ACTION_NAME "ActionGarrisonClearArea"

// Duration of this action

CLASS(THIS_ACTION_NAME, "ActionGarrisonBehaviour")

	VARIABLE("pos");
	VARIABLE("radius");
	VARIABLE("lastCombatTime");
	VARIABLE("duration");

	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
		pr _pos = CALLSM2("Action", "getParameterValue", _parameters, TAG_POS);
		pr _radius = CALLSM2("Action", "getParameterValue", _parameters, TAG_CLEAR_RADIUS);
		if (isNil "_radius") then {_radius = 100;};
		pr _duration = CALLSM2("Action", "getParameterValue", _parameters, TAG_DURATION);
		if (isNil "_duration") then {_duration = 60*30;};
		T_SETV("pos", _pos);
		T_SETV("radius", _radius);
		T_SETV("duration", _duration);
		
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		
		OOP_INFO_0("ACTIVATE");
		
		pr _gar = GETV(T_GETV("AI"), "agent");
		//pr _AI = T_GETV("AI");
		//pr _pos = T_GETV("pos");
		T_PRVAR(AI);
		T_PRVAR(pos);
		T_PRVAR(radius);
		
		// Split vehicle groups
		CALLM1(_gar, "mergeVehicleGroups", false);
		
		// Give goals to groups
		pr _groups = CALLM0(_gar, "getGroups");
		{ // foreach _groups
			pr _groupAI = CALLM0(_x, "getAI");
			pr _args = ["GoalGroupClearArea", 0, [[TAG_POS, _pos], [TAG_CLEAR_RADIUS, _radius]], _AI];
			CALLM2(_groupAI, "postMethodAsync", "addExternalGoal", _args);
		} forEach _groups;
		
		// Set last combat time
		T_SETV("lastCombatTime", time);
		
		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		pr _gar = T_GETV("gar");

		// Succeed after timeout if not spawned.
		if (!CALLM0(_gar, "isSpawned")) exitWith {
			pr _lastCombatTime = T_GETV("lastCombatTime");
			if(isNil "_lastCombatTime") exitWith {
				T_SETV("lastCombatTime", time);
				ACTION_STATE_ACTIVE
			};
			if ((time - _lastCombatTime) > T_GETV("duration") ) then {
				T_SETV("state", ACTION_STATE_COMPLETED);
				ACTION_STATE_COMPLETED
			} else {
				ACTION_STATE_ACTIVE
			};
		};

		pr _state = CALLM0(_thisObject, "activateIfInactive");
		if (_state == ACTION_STATE_ACTIVE) then {
			pr _AI = T_GETV("AI");
			
			// Check if we know about enemies
			pr _ws = GETV(_AI, "worldState");
			pr _awareOfEnemy = [_ws, WSP_GAR_AWARE_OF_ENEMY] call ws_getPropertyValue;
			
			if (_awareOfEnemy) then {
				T_SETV("lastCombatTime", time); // Reset the timer

				T_CALLM0("attackEnemyBuildings"); // Attack buildings occupied by enemies
			} else {
				if ((time - T_GETV("lastCombatTime")) > T_GETV("duration") ) then {
					_state = ACTION_STATE_COMPLETED;
				};
			};
		};

		// Return the current state
		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		// Bail if not spawned
		pr _gar = T_GETV("gar");
		if (!CALLM0(_gar, "isSpawned")) exitWith {};

		pr _AI = T_GETV("AI");
		pr _gar = T_GETV("gar");
		
		// Remove assigned goals
		pr _groups = CALLM0(_gar, "getGroups");
		{ // foreach _groups
			pr _groupAI = CALLM0(_x, "getAI");
			pr _args = ["",_AI];
			CALLM2(_groupAI, "postMethodAsync", "deleteExternalGoal", _args);
		} forEach _groups;
		
	} ENDMETHOD; 
	
	
	
	// procedural preconditions
	// POS world state property comes from action parameters
	/*
	// Don't have these preconditions any more, they are supplied by goal instead
	STATIC_METHOD("getPreconditions") {
		params [ ["_thisClass", "", [""]], ["_goalParameters", [], [[]]], ["_actionParameters", [], [[]]]];
		
		pr _pos = CALLSM2("Action", "getParameterValue", _actionParameters, TAG_POS);
		pr _ws = [WSP_GAR_COUNT] call ws_new;
		[_ws, WSP_GAR_POSITION, _pos] call ws_setPropertyValue;
		
		_ws			
	} ENDMETHOD;
	*/
	
ENDCLASS;