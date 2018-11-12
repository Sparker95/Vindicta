/*
AI base class.

Author: Sparker 07.11.2018
*/

#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"

#define pr private

#define AI_TIMER_SERVICE gTimerServiceMain

CLASS("AI", "MessageReceiver")

	VARIABLE("agent"); // Pointer to the unit which holds this AI object
	VARIABLE("currentAction"); // The current action
	VARIABLE("currentGoal"); // The current goal
	VARIABLE("goalExtHigh"); // Goal suggested to this Agent by a high level AI
	VARIABLE("goalExtMedium"); // Goal suggested to this Agent by a medium level AI
	VARIABLE("goalExtLow"); // Goal suggested to this Agent by a low level AIVARIABLE("worldState"); // The world state relative to this Agent
	VARIABLE("worldState"); // The world state relative to this Agent
	VARIABLE("timer"); // The timer of this object
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
		SETV(_thisObject, "goalExtHigh", "");
		SETV(_thisObject, "goalExtMedium", "");
		SETV(_thisObject, "goalExtLow", "");
		pr _ws = [1] call ws_new; // todo WorldState size must depend on the agent
		SETV(_thisObject, "worldState", _ws);
		SETV(_thisObject, "sensors", []);
		SETV(_thisObject, "timer", "");
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
		//pr _goalNew = CALLM(_thisObject, )
		
		diag_log "AI:Process was called here!";
		
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
	// | Update values of all sensors, according to their settings, returns true if any of them have changed
	// ----------------------------------------------------------------------
	
	METHOD("getMostRelevantGoal") {
		params [["_thisObject", "", [""]]];
		
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
			private _args = [_thisObject, 5, _msg, AI_TIMER_SERVICE]; // message receiver, interval, message, timer service
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
	
ENDCLASS;