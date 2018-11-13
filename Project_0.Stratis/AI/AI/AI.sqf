/*
AI base class.

Author: Sparker 07.11.2018
*/

#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\goalRelevance.hpp"

#define pr private

#define AI_TIMER_SERVICE gTimerServiceMain

CLASS("AI", "MessageReceiver")

	VARIABLE("agent"); // Pointer to the unit which holds this AI object
	VARIABLE("currentAction"); // The current action
	VARIABLE("currentGoal"); // The current goal
	VARIABLE("goalsExternal"); // Goal suggested to this Agent by another agent
	VARIABLE("worldState"); // The world state relative to this Agent
	VARIABLE("timer"); // The timer of this object
	VARIABLE("processInterval"); // The update interval for the timer, in seconds
	VARIABLE("sensors"); // Array with sensors
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_agent", "", [""]]];
		
		// Make sure the required global objects exist
		ASSERT_GLOBAL_OBJECT(AI_TIMER_SERVICE);
		
		SETV(_thisObject, "agent", _agent);
		SETV(_thisObject, "currentAction", "");
		SETV(_thisObject, "currentGoal", "");
		SETV(_thisObject, "goalsExternal", []);
		pr _ws = [1] call ws_new; // todo WorldState size must depend on the agent
		SETV(_thisObject, "worldState", _ws);
		SETV(_thisObject, "sensors", []);
		SETV(_thisObject, "timer", "");
		SETV(_thisObject, "processInterval", 10);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		// Stop the AI if it is currently running
		CALLM(_thisObject, "stop", []);
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                              P R O C E S S
	// | Must be called every update interval
	// ----------------------------------------------------------------------
	
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		diag_log format ["AI:Process is called for AI: %1", _thisObject];
		
		pr _agent = GETV(_thisObject, "agent");
		
		/*
		updateSensors();
		goalNew = calculateMostRelevantGoal();
		if (goalNew != currentGoal)
			[action, planIsValid] = planActions(goalNew);
			if (planIsValid) {
				setCurrentAction(action);
				currentGoal = goalNew;
			} else
				setCurrentAction("");
		}
		if(currentAction != "") // If the current action exists
			currentAction.process();
		if (count agent.getSubagents > 0)
			{ _x.AI.process(); } forEach subagents;
		*/
		// Update all sensors
		CALLM(_thisObject, "updateSensors", []);
		
		//Calculate most relevant goal
		pr _goalNewAndParameter = CALLM(_thisObject, "getMostRelevantGoal", []);
		_goalNewAndParameter params ["_goalClassName", "_goalParameter"];
		diag_log format ["  most relevant goal: %1", _goalClassName];
		
		// Call process method of subagents
		pr _subagents = CALLM(_agent, "getSubagents", []);
		{
			pr _agentAI = CALLM(_x, "getAI", []);
			if (_agentAI != "") then {
				CALLM(_agentAI, "process", []);
			};
		} forEach _subagents;
				
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    H A N D L E   M E S S A G E
	// | 
	// ----------------------------------------------------------------------
	
	METHOD("handleMessage") { //Derived classes must implement this method
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		pr _msgType = _msg select MESSAGE_ID_TYPE;
		switch (_msgType) do {
			case AI_MESSAGE_PROCESS: {
				CALLM(_thisObject, "process", []);
				true
			};
			
			case AI_MESSAGE_DELETE: {
				DELETE(_thisObject);
				true
			};
			
			default {false}; // Message not handled
		};
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    U P D A T E   S E N S O R S
	// | Update values of all sensors, according to their settings, returns true if any of them have changed
	// ----------------------------------------------------------------------
	
	METHOD("updateSensors") {
		params [["_thisObject", "", [""]]];
		pr _sensors = GETV(_thisObject, "sensors");
		{
			pr _sensor = _x;
			// Update the sensor if it's time to update it
			pr _timeNextUpdate = GETV(_sensor, "timeNextUpdate");
			if (time > _timeNextUpdate) then {
				CALLM(_sensor, "update", []);
				pr _interval = CALLM(_sensor, "getUpdateInterval", []);
				SETV(_sensor, "timeNextUpdate", time + _interval);
			};
		} forEach _sensors;
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                G E T   M O S T   R E L E V A N T   G O A L
	// | Return value: [goal, parameter]
	// | 
	// ----------------------------------------------------------------------
	
	METHOD("getMostRelevantGoal") {
		params [["_thisObject", "", [""]]];
		
		pr _agent = GETV(_thisObject, "agent");
		
		// Get the list of goals available to this agent
		pr _possibleGoals = CALLM(_agent, "getPossibleGoals", []);
		pr _relevanceMax = -1000;
		pr _mostRelevantGoal = "";
		pr _mostRelevantGoalParameter = 0;
		_possibleGoals = _possibleGoals apply {[_x, 0, 0]}; // Goal class name, bias, parameter
		{
			pr _goalClassName = _x select 0;
			pr _bias = _x select 1;
			pr _relevance = CALL_STATIC_METHOD(_goalClassName, "calculateRelevance", [_thisObject]);
			diag_log format ["   Calculated relevance for goal %1: %2", _goalClassName, _relevance];
			_relevance = _relevance + _bias;
			
			if (_relevance > _relevanceMax) then {
				_relevanceMax = _relevance;
				_mostRelevantGoal = _goalClassName;
				_mostRelevantGoalParameter = _x select 2;
			};
		} forEach _possibleGoals;
		
		// Return
		[_mostRelevantGoal, _mostRelevantGoalParameter]
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                A D D   E X T E R N A L   G O A L
	// | Adds a goal to the list of external goals of this agent
	// | Parameters: _goalClassName, _bias, _parameters
	// | _bias - a number to be added to the relevance of the goal once it is calculated
	// | _parameters - the parameters to be passed to the goal if it's activated, can be anything goal-specific
	// ----------------------------------------------------------------------
	
	METHOD("addExternalGoal") {
		params [["_thisObject", "", [""]], ["_goalClassName", "", [""]], ["_bias", 0, [0]], "_parameter"];
		
		pr _goalsExternal = GETV(_thisObject, "goalsExternal");
		_goalsExternal pushBack [_goalClassName, _parameter, _bias];
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                D E L E T E   E X T E R N A L   G O A L
	// | Deletes an external goal having the same goalClassName and parameter
	// |
	// ----------------------------------------------------------------------
	
	METHOD("deleteExternalGoal") {
		params [["_thisObject", "", [""]], ["_goalClassName", "", [""]], "_parameter"];
		
		pr _goalsExternal = GETV(_thisObject, "goalsExternal");
		pr _i = 0;
		while {_i < count _goalsExternal} do {
			pr _cg = _goalsExternal select _i;
			if ((_cg select 0 == _goalClassName) && (_cg select 1 isEqualTo _parameter)) then {
				_goalsExternal deleteAt _i;
			} else {
				_i = _i + 1;
			};
		};
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                S E T   C U R R E N T   A C T I O N
	// |
	// ----------------------------------------------------------------------
	
	METHOD("setCurrentAction") {
		params [["_thisObject", "", [""]]];
		/*
		delete(currentAction);
		currentAction = action;
		*/
	} ENDMETHOD;
	
	
	// ----------------------------------------------------------------------
	// |                P L A N   A C T I O N S
	// | Plans a way towards specified goal, returns a single action, which can be serial action or an atomic action
	// | Return value: [action, planIsValid]
	// ----------------------------------------------------------------------
	
	METHOD("planActions") {
		params [["_thisObject", "", [""]]];
		// Put your A* implementation here
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                S T A R T
	// | Starts the AI brain
	// ----------------------------------------------------------------------
	
	METHOD("start") {
		params [["_thisObject", "", [""]]];
		if (GETV(_thisObject, "timer") == "") then {
			// Starts the timer
			private _msg = MESSAGE_NEW();
			_msg set [MESSAGE_ID_DESTINATION, _thisObject];
			_msg set [MESSAGE_ID_SOURCE, ""];
			_msg set [MESSAGE_ID_DATA, 0];
			_msg set [MESSAGE_ID_TYPE, AI_MESSAGE_PROCESS];
			pr _processInterval = GETV(_thisObject, "processInterval");
			private _args = [_thisObject, _processInterval, _msg, AI_TIMER_SERVICE]; // message receiver, interval, message, timer service
			private _timer = NEW("Timer", _args);
			SETV(_thisObject, "timer", _timer);
		};
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                S T O P
	// | Stops the AI brain
	// ----------------------------------------------------------------------
	
	METHOD("stop") {
		params [["_thisObject", "", [""]]];
		pr _timer = GETV(_thisObject, "timer");
		if (_timer != "") then {
			DELETE(_timer);
		};
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |               S E T   P R O C E S S   I N T E R V A L
	// | Sets the process interval of this AI object
	// ----------------------------------------------------------------------
	
	METHOD("setProcessInterval") {
		params [["_thisObject", "", [""]], ["_interval", 5, [5]]];
		SETV(_thisObject, "processInterval", _interval);
		
		// If the AI object is already running, also change the interval of the timer which is already started
		pr _timer = GETV(_thisObject, "timer");
		if (_timer != "") then {
			CALLM(_timer, "setInterval", [_interval]);
		};
	} ENDMETHOD;
	
ENDCLASS;