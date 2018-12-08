#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\Action\Action.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\goalRelevance.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\goalRelevance.hpp"
#include "AI.hpp"

/*
AI base class.

Author: Sparker 07.11.2018
*/

#define pr private

#define AI_TIMER_SERVICE gTimerServiceMain
#define STIMULUS_MANAGER gStimulusManager

CLASS("AI", "MessageReceiverEx")

	VARIABLE("agent"); // Pointer to the unit which holds this AI object
	VARIABLE("currentAction"); // The current action
	VARIABLE("currentGoal"); // The current goal
	VARIABLE("currentGoalSource"); // The source of the current goal (who gave us this goal)
	VARIABLE("currentGoalParameter"); // The parameter of the current goal
	VARIABLE("goalsExternal"); // Goal suggested to this Agent by another agent
	VARIABLE("worldState"); // The world state relative to this Agent
	VARIABLE("worldFacts"); // Array with world facts
	VARIABLE("timer"); // The timer of this object
	VARIABLE("processInterval"); // The update interval for the timer, in seconds
	VARIABLE("sensorStimulusTypes"); // Array with stimulus types of the sensors of this AI object
	VARIABLE("sensors"); // Array with sensors
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_agent", "", [""]]];
		
		// Make sure the required global objects exist
		ASSERT_GLOBAL_OBJECT(AI_TIMER_SERVICE);
		ASSERT_GLOBAL_OBJECT(STIMULUS_MANAGER);
		
		SETV(_thisObject, "agent", _agent);
		SETV(_thisObject, "currentAction", "");
		SETV(_thisObject, "currentGoal", "");
		SETV(_thisObject, "currentGoalSource", "");
		SETV(_thisObject, "currentGoalParameter", 0);
		SETV(_thisObject, "goalsExternal", []);
		pr _ws = [1] call ws_new; // todo WorldState size must depend on the agent
		SETV(_thisObject, "worldState", _ws);
		SETV(_thisObject, "worldFacts", []);
		SETV(_thisObject, "sensors", []);
		SETV(_thisObject, "sensorStimulusTypes", []);
		SETV(_thisObject, "timer", "");
		SETV(_thisObject, "processInterval", 10);
		
		// Add this AI to the stimulus manager
		pr _args = ["addSensingAI", [_thisObject]];
		CALLM(STIMULUS_MANAGER, "postMethodAsync", _args);
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		// Stop the AI if it is currently running
		CALLM(_thisObject, "stop", []);
		
		// Remove this AI from the stimulus manager
		pr _args = ["removeSensingAI", [_thisObject]];
		CALLM(STIMULUS_MANAGER, "postMethodSync", _args);
		
		// Delete all sensors
		pr _sensors = GETV(_thisObject, "sensors");
		{
			DELETE(_x);
		} forEach _sensors;
		
		// Delete the current action
		pr _action = GETV(_thisObject, "currentAction");
		if (_action != "") then {
			CALLM(_action, "terminate", []);
			DELETE(_action);
		};
		
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                              P R O C E S S
	// | Must be called every update interval
	// ----------------------------------------------------------------------
	
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		//diag_log format ["AI:Process is called for AI: %1", _thisObject];
		
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
		
		// Update all world facts (delete old facts)
		CALLM(_thisObject, "updateWorldFacts", []);
		
		//Calculate most relevant goal
		pr _goalNewArray = CALLM(_thisObject, "getMostRelevantGoal", []);
		
		// If we have chosen some goal
		if (count _goalNewArray != 0) then {
			_goalNewArray params ["_goalClassName", "_goalParameter", "_goalBias", "_goalSource"]; // Goal class name, bias, parameter, source
			//diag_log format ["  most relevant goal: %1", _goalClassName];
			
			// Check if the new goal is the same as the current goal
			pr _currentGoal = GETV(_thisObject, "currentGoal");
			pr _currentGoalSource = GETV(_thisObject, "currentGoalSource");
			pr _currentGoalParameter = GETV(_thisObject, "currentGoalParameter");
			if (_currentGoal == _goalClassName && _currentGoalSource == _goalSource && _currentGoalParameter isEqualTo _goalParameter) then {
				// We have the same goal. Do nothing.
			} else {
				// We have a new goal! Time to replan.
				SETV(_thisObject, "currentGoal", _goalClassName);
				SETV(_thisObject, "currentGoalSource", _goalSource);
				SETV(_thisObject,"currentGoalParameter", _goalParameter);
				diag_log format ["[AI:Process] AI: %1, new goal: %2", _thisObject, _goalClassName];
				
				// Make a new Action Plan
				// First check if the goal assumes a predefined plan
				pr _newAction = CALL_STATIC_METHOD(_goalClassName, "createPredefinedAction", [_thisObject]);
				if (_newAction != "") then {
				} else {
					// todo run planner
				};
				
				// Set a new action
				SETV(_thisObject, "currentAction", _newAction);
			};
		} else {
			// We don't pursue a goal any more
			
			// End the previous goal if we had it
			pr _currentGoal = GETV(_thisObject, "currentGoal");
			if (_currentGoal != "") then {
				diag_log format ["[AI:Process] AI: %1 ending the current goal: %2", _thisObject, _currentGoal];
				SETV(_thisObject, "currentGoal", "");
				
				// Terminate the current action
				pr _currentAction = GETV(_thisObject, "currentAction");
				if (_currentAction != "") then {
					CALLM(_currentAction, "terminate", []);
					DELETE(_currentAction);
					SETV(_thisObject, "currentAction", "");
				};
			};
			
			//diag_log format ["  most relevant goal: %1", _goalClassName];
		};
		
		// Process the current action if we have it
		pr _currentAction = GETV(_thisObject, "currentAction");
		if (_currentAction != "") then {
			pr _actionState = CALLM(_currentAction, "process", []);
			switch (_actionState) do {
				case ACTION_STATE_COMPLETED : {
					// Mark the current goal as completed?
				};
				
				case ACTION_STATE_FAILED : {
					// Probably we should replan our goal at the next iteration
					SETV(_thisObject, "currentGoal", "");
				};
			};
		};
		
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
	
	METHOD("handleMessageEx") { //Derived classes must implement this method
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
	
	
	
	
	
	
	
	// ------------------------------------------------------------------------------------------------------
	// -------------------------------------------- S E N S O R S -------------------------------------------
	// ------------------------------------------------------------------------------------------------------
	
	
	
	
	// ----------------------------------------------------------------------
	// |                A D D   S E N S O R
	// | Adds a given sensor to the AI object
	// ----------------------------------------------------------------------
	
	METHOD("addSensor") {
		params [["_thisObject", "", [""]], ["_sensor", "ERROR_NO_SENSOR", [""]]];
		// Add the sensor to the sensor list
		pr _sensors = GETV(_thisObject, "sensors");
		_sensors pushBackUnique _sensor;
		
		// Check the stimulus types this sensor responds to
		pr _stimTypesSensor = CALLM(_sensor, "getStimulusTypes", []);
		pr _stimTypesThis = GETV(_thisObject, "sensorStimulusTypes");
		// Add the stimulus types to the stimulus type array
		{
			_stimTypesThis pushBackUnique _x;
		} forEach _stimTypesSensor;
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    U P D A T E   S E N S O R S
	// | Update values of all sensors, according to their settings
	// ----------------------------------------------------------------------
	
	METHOD("updateSensors") {
		params [["_thisObject", "", [""]]];
		pr _sensors = GETV(_thisObject, "sensors");
		{
			pr _sensor = _x;
			// Update the sensor if it's time to update it
			pr _timeNextUpdate = GETV(_sensor, "timeNextUpdate");
			// If timeNextUpdate is 0, we never update this sensor
			if (_timeNextUpdate != 0 && time > _timeNextUpdate) then {
				CALLM(_sensor, "update", []);
				pr _interval = CALLM(_sensor, "getUpdateInterval", []);
				SETV(_sensor, "timeNextUpdate", time + _interval);
			};
		} forEach _sensors;
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    H A N D L E   S T I M U L U S
	// | Handles external stimulus.
	// ----------------------------------------------------------------------
	
	METHOD("handleStimulus") {
		params [["_thisObject", "", [""]], ["_stimulus", [], [[]]] ];
		pr _type = _stimulus select STIMULUS_ID_TYPE;
		pr _sensors = GETV(_thisObject, "sensors");
		{
			pr _stimTypes = CALLM(_x, "getStimulusTypes", []);
			if (_type in _stimTypes) then {
				CALLM(_x, "stimulate", [_stimulus]);
			};
		} foreach _sensors;
	} ENDMETHOD;	
	
	
	
	
	
	
	
	
	// ------------------------------------------------------------------------------------------------------
	// -------------------------------------------- G O A L S -----------------------------------------------
	// ------------------------------------------------------------------------------------------------------
	
	
	
	
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
		pr _mostRelevantGoal = [];
		_possibleGoals = _possibleGoals apply {[_x, 0, 0, _thisObject]}; // Goal class name, bias, parameter, source
		{
			pr _goalClassName = _x select 0;
			pr _bias = _x select 1;
			pr _relevance = CALL_STATIC_METHOD(_goalClassName, "calculateRelevance", [_thisObject]);
			//diag_log format ["   Calculated relevance for goal %1: %2", _goalClassName, _relevance];
			_relevance = _relevance + _bias;
			
			if (_relevance > _relevanceMax) then {
				_relevanceMax = _relevance;
				_mostRelevantGoal = _x;
			};
		} forEach _possibleGoals;
		
		// Return the most relevant goal if its relevance is above 0
		if (_relevanceMax > GOAL_RELEVANCE_BIAS_LOWER) exitWith {
			pr _return = +_mostRelevantGoal; // Make a deep copy
			_return
		};
		
		[]
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                A D D   E X T E R N A L   G O A L
	// | Adds a goal to the list of external goals of this agent
	// | Parameters: _goalClassName, _bias, _parameters
	// | _bias - a number to be added to the relevance of the goal once it is calculated
	// | _parameters - the parameters to be passed to the goal if it's activated, can be anything goal-specific
	// ----------------------------------------------------------------------
	
	METHOD("addExternalGoal") {
		params [["_thisObject", "", [""]], ["_goalClassName", "", [""]], ["_bias", 0, [0]], "_parameter", ["_source", "ERROR_NO_SOURCE", [""]] ];
		
		pr _goalsExternal = GETV(_thisObject, "goalsExternal");
		_goalsExternal pushBack [_goalClassName, _parameter, _bias, _source];
		
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
	
	
	
	
	
	
	// ------------------------------------------------------------------------------------------------------
	// -------------------------------------------- A C T I O N S -------------------------------------------
	// ------------------------------------------------------------------------------------------------------
	
	
	
	
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
	
	
	
	
	// ------------------------------------------------------------------------------------------------------
	// -------------------------------------------- W O R L D   F A C T S -----------------------------------
	// ------------------------------------------------------------------------------------------------------
	
	// Adds a world fact
	METHOD("addWorldFact") {
		params [["_thisObject", "", [""]], ["_fact", [], [[]]]];
		pr _facts = GETV(_thisObject, "worldFacts");
		_facts pushBack _fact;
	} ENDMETHOD;
	
	// Finds a world fact that matches a query
	// Returns the found world fact or nil if nothing was found
	METHOD("findWorldFact") {
		params [["_thisObject", "", [""]], ["_query", [], [[]]]];
		pr _facts = GETV(_thisObject, "worldFacts");
		pr _i = 0;
		pr _c = count _facts;
		pr _return = nil;
		while {_i < _c} do {
			pr _fact = _facts select _i;
			if ([_fact, _query] call wf_fnc_matchesQuery) exitWith {_return = _fact;};
			_i = _i + 1;
		};
		if (!isNil "_return") then {_return} else {nil};
	} ENDMETHOD;
	
	// Finds all world facts that match a query
	// Returns array with facts that satisfy criteria or []
	METHOD("findWorldFacts") {
		params [["_thisObject", "", [""]], ["_query", [], [[]]]];
		pr _facts = GETV(_thisObject, "worldFacts");
		pr _i = 0;
		pr _c = count _facts;
		pr _return = [];
		while {_i < _c} do {
			pr _fact = _facts select _i;
			if ([_fact, _query] call wf_fnc_matchesQuery) then {_return pushBack _fact;};
			_i = _i + 1;
		};
		_return
	} ENDMETHOD;
	
	// Deletes all facts that match query
	METHOD("deleteWorldFacts") {
		params [["_thisObject", "", [""]], ["_query", [], [[]]]];
		pr _facts = GETV(_thisObject, "worldFacts");
		pr _i = 0;
		while {_i < count _facts} do {
			pr _fact = _facts select _i;
			if ([_fact, _query] call wf_fnc_matchesQuery) then {_facts deleteAt _i} else {_i = _i + 1;};
		};
	} ENDMETHOD;
	
	// Maintains the array of world facts
	// Deletes world facts that have exceeded their lifetime
	METHOD("updateWorldFacts") {
		params [["_thisObject", "", [""]]];
		pr _facts = GETV(_thisObject, "worldFacts");
		pr _i = 0;
		while {_i < count _facts} do {
			pr _fact = _facts select _i;
			if ([_fact] call wf_fnc_hasExpired) then {
				diag_log format ["[AI:updateWorldFacts] AI: %1, deleted world fact: %2", _thisObject, _fact];
				_facts deleteAt _i;
			} else {
				_i = _i + 1;
			};
		};
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
	
	
	
	
	
	
	
	/* ------------------------------------------------------------------------------------------------------------
		   ###                    ###    ##        ######    #######  ########  #### ######## ##     ## ##     ## 
		  ## ##    ##   ##       ## ##   ##       ##    ##  ##     ## ##     ##  ##     ##    ##     ## ###   ### 
		 ##   ##    ## ##       ##   ##  ##       ##        ##     ## ##     ##  ##     ##    ##     ## #### #### 
		##     ## #########    ##     ## ##       ##   #### ##     ## ########   ##     ##    ######### ## ### ## 
		#########   ## ##      ######### ##       ##    ##  ##     ## ##   ##    ##     ##    ##     ## ##     ## 
		##     ##  ##   ##     ##     ## ##       ##    ##  ##     ## ##    ##   ##     ##    ##     ## ##     ## 
		##     ##              ##     ## ########  ######    #######  ##     ## ####    ##    ##     ## ##     ##
		
		https://en.wikipedia.org/wiki/A*_search_algorithm
		
	---------------------------------------------------------------------------------------------------------------*/
	/*
	Performs backwards search of actions to connect current world state and goal world state, starting search from goal world state.
	*/
	
	#define ASTAR_DEBUG
	
	STATIC_METHOD("AStar") {
		params [["_currentWS", [], [[]]], ["_goalWS", [], [[]]], ["_possibleActions", [], [[]]], ["_AI", "ASTAR_ERROR_NO_AI"] ];
		
		// Copy the array of possible actions becasue we are going to modify it
		pr _availableActions = +_possibleActions;
		
		#ifdef ASTAR_DEBUG
		diag_log "";
		diag_log "[AI:AStar] Info: ---------- Starting A* ----------";
		diag_log format ["[AI:AStar] Info: currentWS: %1,  goalWS: %2,  possibleActions: %3", [_currentWS] call ws_toString, [_goalWS] call ws_toString, _possibleActions];
		#endif
		
		// Set of nodes already evaluated
		pr _closeSet = [];
		
		// Set of discovered nodes to evaluate
		pr _goalNode = ASTAR_NODE_NEW(_goalWS);
		_goalNode set [ASTAR_NODE_ID_F, [_goalWS, _currentWS] call ws_getNumUnsatisfiedProps]; // Calculate heuristic for the goal node
		//ade_dumpCallstack;
		pr _openSet = [_goalNode];
		
		// Main loop of the algorithm
		pr _path = []; // Return value of the algorithm
		pr _count = 10; // A safety counter, in case it freezes.
		while {count _openSet > 0 && _count > 0} do {
			
			// Set current node to the node in open set with lowest f value
			pr _node = _openSet select 0;
			pr _lowestF = _openSet select 0 select ASTAR_NODE_ID_F;
			{
				pr _f = _x select ASTAR_NODE_ID_F;
				if (_f < _lowestF) then {
					_lowestF = _f;
					_node = _x;
				};
			} forEach _openSet;
			
			// Debug output
			// Print the node we currently analyze
			#ifdef ASTAR_DEBUG
				diag_log "";
				diag_log "[AI:AStar] Info: Open set:";
				// Print the open and closed set
				{
					pr _nodeString = CALL_STATIC_METHOD("AI", "AStarNodeToString", [_x]);
					diag_log ("  " + _nodeString);
				} forEach _openSet;
				
				// Print the selected node
				pr _nodeString = CALL_STATIC_METHOD("AI", "AStarNodeToString", [_node]);
				diag_log format ["[AI:AStar] Info: Analyzing node: %1", _nodeString];
			#endif
			
			// Remove the current node from the open set, add it to the close set
			_openSet deleteAt (_openSet find _node);
			_closeSet pushBack _node;
			
			// World state of this node
			pr _nodeWS = _node select ASTAR_NODE_ID_WS;
			
			// Terminate if we have reached the current world state
			if (([_nodeWS, _currentWS] call ws_getNumUnsatisfiedProps) == 0) exitWith {
				#ifdef ASTAR_DEBUG
					diag_log "[AI:AStar] Info: Reached current state!";
				#endif
				
				// Recunstruct path
				pr _n = _node;
				while {true} do {
					_path pushBack [_n select ASTAR_NODE_ID_ACTION, _n select ASTAR_NODE_ID_ACTION_PARAMETER];
					if ((_n select ASTAR_NODE_ID_NEXT_NODE) isEqualTo _goalNode) exitWith{};
					_n = _n select ASTAR_NODE_ID_NEXT_NODE;
				};
			};
			
			// Discover neighbour nodes of this node
			// We can reach neighbour nodes only through available actions
			
			// Debug text
			#ifdef ASTAR_DEBUG
				diag_log format ["[AI:AStar] Info: Discovered neighbours:", _nodeString];
			#endif
			
			pr _usedActions = [];
			{ // forEach _availableActions;
				pr _effects = GET_STATIC_VAR(_x, "effects");
				pr _connParams = [_effects, _nodeWS] call ws_connectionParameters;
				_connParams params ["_connected", "_parameterID", "_parameterValue"];
				
				// If there is connection, create a new node
				if (_connected) then {
					// Calculate world state before executing this action
					// It depends on action effects, preconditions and world state of current node
					pr _preconditions = (GET_STATIC_VAR(_x, "preconditions"));
					pr _effects = GET_STATIC_VAR(_x, "effects");
					pr _WSBeforeAction = +_nodeWS;
					[_WSBeforeAction, _effects] call ws_substract;
					[_WSBeforeAction, _preconditions] call ws_add;					
					
					pr _n = ASTAR_NODE_NEW(_WSBeforeAction);
					_n set [ASTAR_NODE_ID_ACTION, _x];
					_n set [ASTAR_NODE_ID_ACTION_PARAMETER, _parameterValue];
					_n set [ASTAR_NODE_ID_NEXT_NODE, _node];
					
					// Calculate H, G and F values of the new node
					
					// Calculate G value
					// G = G(_node) + cost of this action
					pr _args = [_AI, _preconditions, _nodeWS];
					pr _cost = CALL_STATIC_METHOD(_x, "getCost", _args);
					pr _g = (_node select ASTAR_NODE_ID_G) + _cost;
					_n set [ASTAR_NODE_ID_G, _g];
					
					// Calculate F and H values
					// F = G + Heuristic
					// We need to store H only for debug
					pr _h = [_WSBeforeAction, _currentWS] call ws_getNumUnsatisfiedProps;
					pr _f = _g + _h;
					_n set [ASTAR_NODE_ID_H, _h];
					_n set [ASTAR_NODE_ID_F, _f];
					
					// Add the new node to the open set
					_openSet pushBack _n;
					
					// Remove the action from action list, we don't want to use it many times
					_usedActions pushBack _x;
					
					// Print debug text: neighbour node
					#ifdef ASTAR_DEBUG
						pr _nodeString = CALL_STATIC_METHOD("AI", "AStarNodeToString", [_n]);
						diag_log ("  " + _nodeString);
					#endif
				};
			} forEach _availableActions;
			
			// Remove the action from action list, we don't want to use it many times
			//_availableActions = _availableActions - _usedActions;
			
			_count = _count - 1;
		}; // while {}
		
		#ifdef ASTAR_DEBUG
			diag_log format ["[AI:AStar] Info: Generated plan: %1", _path];
		#endif
		
		// Return the reconstructed path
		_path
	} ENDMETHOD;
	
	// Converts an A* node to string for debug purposes
	STATIC_METHOD("AStarNodeToString") {
		params [["_node", [], [[]]]];
		
		// Next field might be a node or a special number indicating that next node doesn't exist (i.e. for a goal node)
		
		pr _nextNodeStr = "";
		if ((_node select ASTAR_NODE_ID_NEXT_NODE) isEqualTo ASTAR_NODE_DOES_NOT_EXIST) then {
			_nextNodeStr = "<no node>";
		} else {
			_nextNodeStr = (_node select ASTAR_NODE_ID_NEXT_NODE) select ASTAR_NODE_ID_ACTION;
		};
		
		// Convert world state to string
		pr _str = format ["[ WS: %1  Action: %2(%3)  H: %4  G: %5  F: %6  Next: %7 ]",
			[_node select ASTAR_NODE_ID_WS] call ws_toString,
			_node select ASTAR_NODE_ID_ACTION,
			_node select ASTAR_NODE_ID_ACTION_PARAMETER,
			_node select ASTAR_NODE_ID_H,
			_node select ASTAR_NODE_ID_G,
			_node select ASTAR_NODE_ID_F,
			_nextNodeStr];
		
		// Return
		_str
	} ENDMETHOD;
	
	
ENDCLASS;