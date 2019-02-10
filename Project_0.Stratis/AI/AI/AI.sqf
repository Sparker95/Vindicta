#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\CriticalSection\CriticalSection.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\Action\Action.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\goalRelevance.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\goalRelevance.hpp"
#include "AI.hpp"

/*
Class: AI
This is the central class of AI framework.
It handles arbitration of goals, receives data from sensors,
stores world facts, runs an A* action planner.

It is also often used to store general data which is only needed for spawned units.

Lots of the code and architecture is derived from F.E.A.R. AI made by Jeff Orkin.

Author: Sparker 07.11.2018
*/

#define pr private

// Will output to .rpt which goals each AI is choosing from
//#define DEBUG_POSSIBLE_GOALS

#define AI_TIMER_SERVICE gTimerServiceMain
#define STIMULUS_MANAGER gStimulusManager

CLASS("AI", "MessageReceiverEx")

	/* Variable: agent
	Holds a reference to the unit/group/whatever that owns this AI object*/
	VARIABLE("agent"); // Pointer to the unit which holds this AI object
	/* Variable: currentAction */
	VARIABLE("currentAction"); // The current action
	/* Variable: currentGoal*/
	VARIABLE("currentGoal"); // The current goal
	VARIABLE("currentGoalSource"); // The source of the current goal (who gave us this goal)
	VARIABLE("currentGoalParameters"); // The parameter of the current goal
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
		SETV(_thisObject, "currentGoalParameters", []);
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
		CALLM0(_thisObject, "updateSensors");
		
		// Update all world facts (delete old facts)
		CALLM0(_thisObject, "updateWorldFacts");
		
		//Calculate most relevant goal
		pr _goalNewArray = CALLM(_thisObject, "getMostRelevantGoal", []);
		
		// If we have chosen some goal
		if (count _goalNewArray != 0) then {
			_goalNewArray params ["_goalClassName", "_goalBias", "_goalParameters", "_goalSource"]; // Goal class name, bias, parameter, source
			//diag_log format ["  most relevant goal: %1", _goalClassName];
			
			// Check if the new goal is the same as the current goal
			pr _currentGoal = GETV(_thisObject, "currentGoal");
			pr _currentGoalSource = GETV(_thisObject, "currentGoalSource");
			pr _currentGoalParameters = GETV(_thisObject, "currentGoalParameters");
			if (_currentGoal == _goalClassName && _currentGoalSource == _goalSource && _currentGoalParameters isEqualTo _goalParameters) then {
				// We have the same goal. Do nothing.
				//OOP_INFO_0("PROCESS: Goal is the same...");
			} else {
				// We have a new goal! Time to replan.
				SETV(_thisObject, "currentGoal", _goalClassName);
				SETV(_thisObject, "currentGoalSource", _goalSource);
				SETV(_thisObject,"currentGoalParameters", _goalParameters);
				diag_log format ["[AI:Process] AI: %1, NEW GOAL: %2", _thisObject, _goalClassName];
				
				// Make a new Action Plan
				// First check if the goal assumes a predefined plan
				private _args = [_thisObject, _goalParameters];
				pr _newAction = CALL_STATIC_METHOD(_goalClassName, "createPredefinedAction", _args);
				
				if (_newAction == "") then {
					// Predefined action was not supplied, so we must run the planner
					
					// Get desired world state
					pr _args = [/* AI */ _thisObject, _goalParameters];
					pr _wsGoal = CALL_STATIC_METHOD(_goalClassName, "getEffects", _args);
					
					// Get actions this agent can do
					pr _possActions = CALLM0(_agent, "getPossibleActions");
					
					// Run the A* planner to generate a plan
					pr _args = [GETV(_thisObject, "worldState"), _wsGoal, _possActions, _goalParameters, _thisObject];
					pr _actionPlan = CALL_STATIC_METHOD("AI", "planActions", _args);
					
					// Did the planner return anything?
					if (count _actionPlan > 0) then {
						// Unpack the plan
						_newAction = CALLM(_thisObject, "createActionsFromPlan", [_actionPlan]);
						// Set a new action from the plan
						CALLM1(_thisObject, "setCurrentAction", _newAction);
					} else {
						// Terminate the current action (if it exists)
						CALLM0(_thisObject, "deleteCurrentAction");
						diag_log format ["[AI::Process] Error: Failed to generate an action plan. AI: %1,  Current WS: %1,  Goal WS: %3", _thisObject, GETV(_thisObject, worldState), _wsGoal];
					};
				} else {
					// Set a new action from the predefined action
					CALLM1(_thisObject, "setCurrentAction", _newAction);
				};
				
			};
		} else {
			// We don't pursue a goal any more
			
			// End the previous goal if we had it
			pr _currentGoal = GETV(_thisObject, "currentGoal");
			if (_currentGoal != "") then {
				diag_log format ["[AI:Process] AI: %1 ending the current goal: %2", _thisObject, _currentGoal];
				SETV(_thisObject, "currentGoal", "");
			};
			
			// Delete the current action if we had it
			CALLM0(_thisObject, "deleteCurrentAction");
			
			//diag_log format ["  most relevant goal: %1", _goalClassName];
		};
		
		// Process the current action if we have it
		pr _currentAction = GETV(_thisObject, "currentAction");
		if (_currentAction != "") then {
			pr _actionState = CALLM(_currentAction, "process", []);
			
			// If it's an external goal, set its action state in the external goal array
			pr _goalSource = T_GETV("currentGoalSource");
			if (_goalSource != _thisObject) then {
				pr _goalsExternal = GETV(_thisObject, "goalsExternal");
				pr _goalClassName = T_GETV("currentGoal");
				pr _index = _goalsExternal findIf {(_goalClassName == (_x select 0)) && (_goalSource == (_x select 3))};
				if (_index != -1) then {
					pr _arrayElement = _goalsExternal select _index;
					_arrayElement set [4, _actionState];
				} else {
					diag_log format ["[AI::process] Error: can't set external goal action state: %1, %2", _thisObject, _goalClassName];
				};
			};
			
			switch (_actionState) do {
				case ACTION_STATE_COMPLETED : {
					// Mark the current goal as completed
					//pr _currentGoal = GETV(_thisObject, "currentGoal");
					//pr _currentGoalParameters = GETV(_thisObject, "currentGoalParameters");
					//CALLM2(_thisObject, "deleteExternalGoal", _currentGoal, _currentGoalParameters); 
					
					// Delete the current action
					CALLM0(_thisObject, "deleteCurrentAction");
				};
				
				case ACTION_STATE_FAILED : {
					// Probably we should replan our goal at the next iteration
					SETV(_thisObject, "currentGoal", "");
					CALLM0(_thisObject, "deleteCurrentAction");
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
	/*
	Method: addSensor
	Adds a sensor to this AI object.
	
	Parameters: _sensor
	
	_sensor - <Sensor> or <SensorStimulatable>
	
	Returns: nil
	*/
	METHOD("addSensor") {
		params [["_thisObject", "", [""]], ["_sensor", "ERROR_NO_SENSOR", [""]]];
		
		ASSERT_OBJECT_CLASS(_sensor, "Sensor");
		
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
	// | Return value: ["_goalClassName", "_goalBias", "_goalParameters", "_goalSource"]
	// | 
	// ----------------------------------------------------------------------
	
	METHOD("getMostRelevantGoal") {
		params [["_thisObject", "", [""]]];
		
		pr _agent = GETV(_thisObject, "agent");
		
		// Get the list of goals available to this agent
		pr _possibleGoals = CALLM(_agent, "getPossibleGoals", []);
		pr _relevanceMax = -1000;
		pr _mostRelevantGoal = [];
		_possibleGoals = _possibleGoals apply {[_x, 0, [], _thisObject]}; // Goal class name, bias, parameter, source
		pr _extGoals = GETV(_thisObject, "goalsExternal");
		#ifdef DEBUG_POSSIBLE_GOALS
			diag_log format ["[AI::getMostRelevantGoals] Info: AI: %1,  possible goals: %2", _thisObject, _possibleGoals];
		#endif
		_possibleGoals append _extGoals;
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
	// | 
	// ----------------------------------------------------------------------
	
	/*
	Method: addExternalGoal
	Adds a goal to the list of external goals of this agent
	
	Parameters: _goalClassName, _bias, _parameters
	
	_goalClassName - <Goal> class name
	_bias - a number to be added to the relevance of the goal once it is calculated
	_parameters - the array with parameters to be passed to the goal if it's activated, can be anything goal-specific
	_sourceAI - <AI> object that gave this goal or "", can be used to identify who gave this goal, for example, when deleting it through <deleteExternalGoal>
	
	Returns: nil
	*/
	
	METHOD("addExternalGoal") {
		params [["_thisObject", "", [""]], ["_goalClassName", "", [""]], ["_bias", 0, [0]], ["_parameters", [], [[]]], ["_sourceAI", "", [""]] ];
		
		OOP_INFO_2("Added external goal: %1, %2", _goalClassName, _parameters);
		
		if (_sourceAI != "") then {
			ASSERT_OBJECT_CLASS(_sourceAI, "AI");
		};
		
		pr _goalsExternal = GETV(_thisObject, "goalsExternal");
		_goalsExternal pushBackUnique [_goalClassName, _bias, _parameters, _sourceAI, ACTION_STATE_INACTIVE];
		
		nil
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                D E L E T E   E X T E R N A L   G O A L
	// ----------------------------------------------------------------------
	/*
	Method: deleteExternalGoal
	Deletes an external goal having the same goalClassName and goalSource
	
	Parameters: _goalClassName, _goalSource
	
	_goalClassName - <Goal> class name
	_goalSourceAI - <AI> object that gave this goal or "" to ignore this field. If "" is provided, source field will be ignored.
	
	Returns: nil
	*/
	METHOD("deleteExternalGoal") {
		params [["_thisObject", "", [""]], ["_goalClassName", "", [""]], ["_goalSourceAI", ""]];

		if (_goalSourceAI != "") then {
			ASSERT_OBJECT_CLASS(_goalSourceAI, "AI");
		};

		CRITICAL_SECTION_START
		// [_goalClassName, _bias, _parameters, _source, ACTION_STATE_INACTIVE]
		pr _goalsExternal = GETV(_thisObject, "goalsExternal");
		pr _i = 0;
		pr _goalDeleted = false;
		while {_i < count _goalsExternal} do {
			pr _cg = _goalsExternal select _i;
			if (	(((_cg select 0) == _goalClassName) || (_goalClassName == "")) &&
					( ((_cg select 3) == _goalSourceAI) || (_goalSourceAI == ""))) then {
				pr _deletedGoal = _goalsExternal deleteAt _i;
				OOP_INFO_1("DELETED EXTERNAL GOAL: %1", _deletedGoal);
			} else {
				_i = _i + 1;
			};
		};
		
		if (!_goalDeleted) then {
			OOP_WARNING_2("couldn't delete external goal: %1, %2", _goalClassName, _goalSource);
		};
		CRITICAL_SECTION_END
		
		nil
	} ENDMETHOD;
	
	
	
	// --------------------------------------------------------------------------------
	// |                G E T   E X T E R N A L   G O A L   A C T I O N   S T A T E
	// --------------------------------------------------------------------------------
	/*
	Method: getExternalGoalActionState
	Returns the state of <Action> which is executed in response to specified external <Goal>, or -1 if specified goal was not found.
	
	Parameters: _goalClassName, _source
	
	_goalClassName - <Goal> class name
	_source - string, source of the goal, or "" to ignore this field. If "" is provided, source field will be ignored.
	
	Returns: Number, one of <ACTION_STATE>
	*/
	METHOD("getExternalGoalActionState") {
		params [["_thisObject", "", [""]], ["_goalClassName", "", [""]], ["_goalSource", ""]];

		pr _return = -1;
		CRITICAL_SECTION_START
		// [_goalClassName, _bias, _parameters, _source, action state];
		pr _goalsExternal = GETV(_thisObject, "goalsExternal");
		pr _index = if (_goalSource == "") then {
			_goalsExternal findIf {(_x select 0) == _goalClassName}
		} else {
			_goalsExternal findIf {((_x select 0) == _goalClassName) && (_x select 3 == _goalSource)}
		};
		if (_index != -1) then {
			_return = _goalsExternal select _index select 4;
		} else {
			//OOP_WARNING_2("can't find external goal: %1, external goals: %2", _goalClassName, _goalsExternal);
		};
		CRITICAL_SECTION_END
		
		_return
	} ENDMETHOD;
	
	
	// ------------------------------------------------------------------------------------------------------
	// -------------------------------------------- A C T I O N S -------------------------------------------
	// ------------------------------------------------------------------------------------------------------
	
	// ----------------------------------------------------------------------
	// |                S E T   C U R R E N T   A C T I O N
	// |
	// ----------------------------------------------------------------------
	
	METHOD("setCurrentAction") {
		params [["_thisObject", "", [""]], ["_newAction", "", [""]]];
		
		// Make sure previous action is deleted
		pr _currentAction = GETV(_thisObject, "currentAction");
		
		// Do we currently already have an action?
		if (_currentAction != "") then {
			CALLM(_currentAction, "terminate", []);
			DELETE(_currentAction);
		};
		
		SETV(_thisObject, "currentAction", _newAction);
	} ENDMETHOD;
	

	// ----------------------------------------------------------------------
	// |            D E L E T E   C U R R E N T   A C T I O N
	// |
	// ----------------------------------------------------------------------
	
	METHOD("deleteCurrentAction") {
		params [["_thisObject", "", [""]]];
		pr _currentAction = GETV(_thisObject, "currentAction");
		if (_currentAction != "") then {
			CALLM(_currentAction, "terminate", []);
			DELETE(_currentAction);
			SETV(_thisObject, "currentAction", "");
		};
	} ENDMETHOD;
	
	
	// ----------------------------------------------------------------------
	// |            C R E A T E   A C T I O N S   F R O M   P L A N
	// |
	// ----------------------------------------------------------------------
	// Creates actions from plan generated by the planActions method	
	METHOD("createActionsFromPlan") {
		params [["_thisObject", "", [""]], ["_plan", [], [[]]]];
		if (count _plan == 1) then {
		
			// If there is only one action in the plan, just create this action
			(_plan select 0) params ["_actionClassName", "_actionParameters"];
			pr _args = [_thisObject, _actionParameters];
			pr _action = NEW(_actionClassName, _args);
			
			// Return the action
			_action
		} else {
		
			// If there are multiple actions in the plan, create an ActionCompositeSerial and add subactions to it 
			pr _actionSerial = NEW("ActionCompositeSerial", [_thisObject]);
			{ // foreach _plan
				_x params ["_actionClassName", "_actionParameters"];
				
				// Create an action
				pr _args = [_thisObject, _actionParameters];
				pr _action = NEW(_actionClassName, _args);
				
				// Add it to the subactions list
				CALLM1(_actionSerial, "addSubactionToBack", _action);
				
				// Return the serial action
				_actionSerial
			} forEach _plan;
		};
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
	/*
	Method: start
	Starts the AI brain. From now process method will be called periodically.
	*/
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
	/*
	Method: stop
	Stops the periodic call of process function.
	*/
	METHOD("stop") {
		params [["_thisObject", "", [""]]];
		pr _timer = GETV(_thisObject, "timer");
		if (_timer != "") then {
			SETV(_thisObject, "timer", "");
			DELETE(_timer);
		};
	} ENDMETHOD;
	
	
	
	// ----------------------------------------------------------------------
	// |               S E T   P R O C E S S   I N T E R V A L
	// | Sets the process interval of this AI object
	// ----------------------------------------------------------------------
	/*
	Method: setProcessInterval
	Sets the process interval of this AI object.
	
	Parameters: _interval
	
	_interval - Number, interval in seconds.
	
	Returns: nil
	*/
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
	
	// Will print useful data about generated plan and how it was achieved
	#define ASTAR_DEBUG
	
	STATIC_METHOD("planActions") {
		pr _paramsGood = params [ ["_thisClass", "", [""]], ["_currentWS", [], [[]]], ["_goalWS", [], [[]]], ["_possibleActions", [], [[]]], ["_goalParameters", [], [[]]], ["_AI", "ASTAR_ERROR_NO_AI", [""]] ];
		
		if (!_paramsGood) then {
			ade_dumpCallstack;
		};
		
		// Copy the array of possible actions becasue we are going to modify it
		pr _availableActions = +_possibleActions;
		
		#ifdef ASTAR_DEBUG
		diag_log "";
		diag_log "[AI:AStar] Info: ---------- Starting A* ----------";
		diag_log format ["[AI:AStar] Info: currentWS: %1,  goalWS: %2,  goal parameters: %3  possibleActions: %4", [_currentWS] call ws_toString, [_goalWS] call ws_toString, _goalParameters, _possibleActions];
		#endif
		
		// Set of nodes already evaluated
		pr _closeSet = [];
		
		// Set of discovered nodes to evaluate
		pr _goalNode = ASTAR_NODE_NEW(_goalWS);
		_goalNode set [ASTAR_NODE_ID_F, [_goalWS, _currentWS] call ws_getNumUnsatisfiedProps]; // Calculate heuristic for the goal node
		pr _openSet = [_goalNode];
		
		// Main loop of the algorithm
		pr _path = []; // Return value of the algorithm
		pr _count = 0; // A safety counter, in case it freezes.
		while {count _openSet > 0 && _count < 50} do {
			
			// ----------------------------------------------------------------------------
			// Set current node to the node in open set with lowest f value
			// ----------------------------------------------------------------------------
			
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
				diag_log format ["[AI:AStar] Info: Step: %1,  Open set:", _count];
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
			pr _nodeAction = _node select ASTAR_NODE_ID_ACTION;
			
			// ----------------------------------------------------------------------------
			// Terminate if we have reached the current world state
			// ----------------------------------------------------------------------------
			
			if (([_nodeWS, _currentWS] call ws_getNumUnsatisfiedProps) == 0) exitWith {
				#ifdef ASTAR_DEBUG
					diag_log "[AI:AStar] Info: Reached current state!";
				#endif
				
				// Recunstruct path
				pr _n = _node;
				while {true} do {
					
					if (! ((_n select ASTAR_NODE_ID_ACTION) isEqualTo ASTAR_ACTION_DOES_NOT_EXIST)) then {
						_path pushBack [_n select ASTAR_NODE_ID_ACTION, _n select ASTAR_NODE_ID_ACTION_PARAMETERS];
					};
					
					if (((_n select ASTAR_NODE_ID_NEXT_NODE) isEqualTo _goalNode) ||
							((_n select ASTAR_NODE_ID_NEXT_NODE) isEqualTo ASTAR_NODE_DOES_NOT_EXIST)) exitWith{};
					_n = _n select ASTAR_NODE_ID_NEXT_NODE;
				};
			};
			
			// ----------------------------------------------------------------------------
			// Discover neighbour nodes of this node
			// We can reach neighbour nodes only through available actions
			// ----------------------------------------------------------------------------
			
			// Debug text
			#ifdef ASTAR_DEBUG
				diag_log format ["[AI:AStar] Info: Discovering neighbours:", _nodeString];
			#endif
			
			{ // forEach _availableActions;
				pr _action = _x;
				pr _effects = GET_STATIC_VAR(_x, "effects");
				pr _args = [[], []]; //
				
				// At this point we get static preconditions because action parameters are unknown
				// Properties that will be overwritten by getPreconditions must be set to some values to resolve conflicts!
				pr _preconditions = GET_STATIC_VAR(_x, "preconditions");
				// Safety check
				pr _connected = if (!isNil "_preconditions") then { [_preconditions, _effects, _nodeWS] call ws_isActionSuitable; } else {
					false;
				};
				
				// If there is connection, create a new node
				if (_connected) then {
				
					// Array with parameters for this action we are currently considering
					pr _parameters = GET_STATIC_VAR(_x, "parameters");
					if (isNil "_parameters") then {_parameters = [];} else {
						_parameters = +_parameters; // Make a deep copy
					};
					
					// ----------------------------------------------------------------------------
					// Try to resolve action parameters
					// ----------------------------------------------------------------------------
					
					pr _parametersResolved = true;
					// Resolve parameters which are derived from goal
					{ // foreach parameters of this action
						pr _tag = _x select 0;
						pr _value = _x select 1;
						
						// If the value has not been resolved yet
						if (isNil "_value") then {
						
							// Find a parameter with the same tag in goal parameters
							pr _idSameTag = _goalParameters findIf {(_x select 0) == _tag};
							//ade_dumpCallstack;
							if (_idSameTag != -1) then {
								// Copy the value from goal parameter to the action parameter
								_x set [1, (_goalParameters select _idSameTag) select 1];
							} else {
								// This parameter is required by action to be retrieved from a goal parameter
								// But it wasn't found in the goal parameter array
								// Print an error
								diag_log format ["[AI:AStar] Warning: can't find a parameter for action: %1,  tag:  %2,  goal: %3,  goal parameters: %4",
									_action, _tag, [_goalWS] call ws_toString, _goalParameters];
								_parametersResolved = false;
							};
						};
					} forEach _parameters;
					
					// Have parameters from the goal been resolved so far, if they existed?
					if (_parametersResolved) then {
						// Resolve parameters which are passed from effects
						if (!([_effects, _parameters, _nodeWS] call ws_applyEffectsToParameters)) then {
							_parametersResolved = false;
						};
					};
					
					if (!_parametersResolved) then {
						diag_log format ["[AI:AStar] Warning: can't resolve all parameters for action: %1", _action];
					} else {
						#ifdef ASTAR_DEBUG
						//	diag_log format ["[AI:AStar] Info: Connected world states: action: %1,  effects: %2,  WS:  %3", _x, [_effects] call ws_toString, [_nodeWS] call ws_toString];
						#endif
						
						// ----------------------------------------------------------------------------
						// Find which node this action came from
						// ----------------------------------------------------------------------------
						
						// Calculate world state before executing this action
						// It depends on action effects, preconditions and world state of current node
						pr _WSBeforeAction = +_nodeWS;
						[_WSBeforeAction, _effects] call ws_substract;
						// Fully resolve preconditions since we now know all the parameters of this action
						pr _args = [_goalParameters, _parameters]; //
						pr _preconditions = CALL_STATIC_METHOD(_x, "getPreconditions", _args);
						[_WSBeforeAction, _preconditions] call ws_add;
						
						// Check if this world state is in close set already
						pr _possibleAction = _x;
						if ( (_closeSet findIf { /* ((_x select ASTAR_NODE_ID_ACTION) isEqualTo _possibleAction) && */ ((_x select ASTAR_NODE_ID_WS) isEqualTo _WSBeforeAction) }) != -1) then {
							// Print debug text
							#ifdef ASTAR_DEBUG
								diag_log format ["  Found in close set:  [ WS: %1  Action: %2]", [_WSBeforeAction] call ws_toString, _x];
							#endif
						} else {
							pr _n = ASTAR_NODE_NEW(_WSBeforeAction);
							_n set [ASTAR_NODE_ID_ACTION, _x];
							_n set [ASTAR_NODE_ID_ACTION_PARAMETERS, _parameters];
							_n set [ASTAR_NODE_ID_NEXT_NODE, _node];
							
							
							// ----------------------------------------------------------------------------
							// Calculate H, G and F values of the new node
							// ----------------------------------------------------------------------------
							
							// Calculate G value
							// G = G(_node) + cost of this action
							pr _args = [_AI, _parameters];
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
							
							// ----------------------------------------------------------------------------
							// If node is not in open set
							// ----------------------------------------------------------------------------
							
							pr _foundID = _openSet findIf { /* ( (_x select ASTAR_NODE_ID_ACTION) == _possibleAction) &&*/ ((_x select ASTAR_NODE_ID_WS) isEqualTo _WSBeforeAction)};
							if (_foundID == -1) then {
								
								// ----------------------------------------------------------------------------
								// New node is not in open set
								// Add the new node to the open set
								// ----------------------------------------------------------------------------
								
								_openSet pushBack _n;
								
								// Print debug text: neighbour node
								#ifdef ASTAR_DEBUG
									pr _nodeString = CALL_STATIC_METHOD("AI", "AStarNodeToString", [_n]);
									diag_log ("  New node:            " + _nodeString);
								#endif
							} else {
							
								// New discovered node is in open set already
								pr _nodeOpen = _openSet select _foundID;
								
								// ----------------------------------------------------------------------------
								// Check if the new node has lower score than existing node
								// ----------------------------------------------------------------------------
								
								if (_g < (_nodeOpen select ASTAR_NODE_ID_G)) then {
									// If we can come to neighbour node faster through current node, than through another node, update this data
									_nodeOpen set [ASTAR_NODE_ID_ACTION, _x];
									_nodeOpen set [ASTAR_NODE_ID_ACTION_PARAMETERS, _parameters];
									_nodeOpen set [ASTAR_NODE_ID_G, _g];
									_nodeOpen set [ASTAR_NODE_ID_F, _f];
									_nodeOpen set [ASTAR_NODE_ID_H, _h];
									_nodeOpen set [ASTAR_NODE_ID_NEXT_NODE, _node];
									
									// Print debug text
									#ifdef ASTAR_DEBUG
										pr _nodeString = CALL_STATIC_METHOD("AI", "AStarNodeToString", [_nodeOpen]);
										//        "  Found in close set:  "
										diag_log format ["  Updated in open set: %1", _nodeString];
									#endif
								} else {
									
									// Print debug text
									#ifdef ASTAR_DEBUG
										pr _nodeString = CALL_STATIC_METHOD("AI", "AStarNodeToString", [_nodeOpen]);
										diag_log format ["  Found in open set:   %1", _nodeString];
									#endif
								};
							}; // in open set?
						}; // in close set?
					}; // paramters resolved?
				};
			} forEach _availableActions;
			
			// Remove the action from action list, we don't want to use it many times
			// Disabled it because it prevents discovery of useful nodes
			//_availableActions = _availableActions - _usedActions;
			
			_count = _count + 1;
		};
		
		#ifdef ASTAR_DEBUG
			diag_log format ["[AI:AStar] Info: Generated plan: %1", _path];
		#endif
		
		// Return the reconstructed path
		_path
	} ENDMETHOD;
	
	// Converts an A* node to string for debug purposes
	STATIC_METHOD("AStarNodeToString") {
		params [ ["_thisClass", "", [""]], ["_node", [], [[]]]];
		
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
			_node select ASTAR_NODE_ID_ACTION_PARAMETERS,
			_node select ASTAR_NODE_ID_H,
			_node select ASTAR_NODE_ID_G,
			_node select ASTAR_NODE_ID_F,
			_nextNodeStr];
		
		// Return
		_str
	} ENDMETHOD;
	
	
ENDCLASS;