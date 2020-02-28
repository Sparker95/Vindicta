#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#define OFSTREAM_FILE "AI.rpt"
#define PROFILER_COUNTERS_ENABLE
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\CriticalSection\CriticalSection.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\Action\Action.hpp"
#include "..\..\defineCommon.inc"
#include "..\goalRelevance.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "AI.hpp"

/*
Class: AI_GOAP
This is the central class of AI framework.
It handles arbitration of goals, receives data from sensors,
stores world facts, runs an A* action planner.

It is also often used to store general data which is only needed for spawned units.

Lots of the code and architecture is derived from F.E.A.R. AI made by Jeff Orkin.

Author: Sparker 07.11.2018
*/

#define pr private

#ifndef RELEASE_BUILD
// Will output to .rpt which goals each AI is choosing from
//#define DEBUG_POSSIBLE_GOALS
#endif

#define AI_TIMER_SERVICE gTimerServiceMain

CLASS("AI_GOAP", "AI")

	/* Variable: currentAction */
				VARIABLE("currentAction"); // The current action
	/* Variable: currentGoal*/
				VARIABLE("currentGoal"); // The current goal
	/* save */	VARIABLE_ATTR("currentGoalSource", [ATTR_SAVE]); // The source of the current goal (who gave us this goal)
	/* save */	VARIABLE_ATTR("currentGoalParameters", [ATTR_SAVE]); // The parameter of the current goal
	//VARIABLE("currentGoalState"); // State of the action
	/* save */	VARIABLE_ATTR("goalsExternal", [ATTR_SAVE]); // Goal suggested to this Agent by another agent
	/* save */	VARIABLE_ATTR("worldState", [ATTR_SAVE]); // The world state relative to this Agent
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_agent", "", [""]]];
		
		SETV(_thisObject, "currentAction", "");
		SETV(_thisObject, "currentGoal", "");
		SETV(_thisObject, "currentGoalSource", "");
		SETV(_thisObject, "currentGoalParameters", []);
		//SETV(_thisObject, "currentGoalState", ACTION_STATE_INACTIVE);
		SETV(_thisObject, "goalsExternal", []);
		pr _ws = [1] call ws_new; // todo WorldState size must depend on the agent
		SETV(_thisObject, "worldState", _ws);
		SETV(_thisObject, "worldFacts", []);

	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		
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
		params [["_thisObject", "", [""]], ["_accelerate", false]];
		
		//OOP_INFO_0("PROCESS");
		
		pr _agent = GETV(_thisObject, "agent");
		
		/*
		updateSensors();
		goalNew = calculateMostRelevantGoal();
		if (goalNew != currentGoal)
			if(currentAction != "")
				setCurrentAction("");
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
		CALLM1(_thisObject, "updateSensors", _accelerate);

		OOP_INFO_1("PROCESS: world state: %1", [GETV(_thisObject, "worldState")] call ws_toString);
		
		// Update all world facts (delete old facts)
		CALLM0(_thisObject, "updateWorldFacts");
		
		//Calculate most relevant goal
		pr _goalNewArray = CALLM(_thisObject, "getMostRelevantGoal", []);
		
		// If we have chosen some goal
		if (count _goalNewArray != 0) then {
			_goalNewArray params ["_goalClassName", "_goalBias", "_goalParameters", "_goalSource", "_goalActionState"]; // Goal class name, bias, parameter, source
			//diag_log format ["  most relevant goal: %1", _goalClassName];
			
			// Check if the new goal is the same as the current goal
			pr _currentGoal = T_GETV("currentGoal");
			//pr _currentGoalSource = T_GETV("currentGoalSource");
			pr _currentGoalParameters = T_GETV( "currentGoalParameters");
			//pr _currentGoalActionState = T_GETV("currentGoalState");
			pr _currentAction = T_GETV("currentAction");
			if (	_currentGoal == _goalClassName &&
					//_currentGoalSource == _goalSource &&
					_currentGoalParameters isEqualTo _goalParameters
					//_currentGoalActionState == ACTION_STATE_ACTIVE
					|| _goalActionState == ACTION_STATE_COMPLETED // If we have already completed it, no need to do it again
					) then {
				// We have the same goal. Do nothing.
				OOP_INFO_2("PROCESS: SAME GOAL: %1, %2", _currentGoal, _currentGoalParameters);
			} else {
				// We have a new goal! Time to replan.
				
				// Delete the current action if we had it
				CALLM0(_thisObject, "deleteCurrentAction");
				
				T_SETV("currentGoal", _goalClassName);
				T_SETV("currentGoalSource", _goalSource);
				T_SETV("currentGoalParameters", _goalParameters);
				//T_SETV("currentGoalState", _goalActionState);
				OOP_INFO_4("PROCESS: NEW GOAL: %1, parameters: %2, source: %3, state: %4",
					_goalClassName, _goalParameters, _goalSource, _goalActionState);
				
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

					CALL_STATIC_METHOD("AI_GOAP", "planActions", _args) params ["_foundPlan", "_actionPlan"];
					
					// Did the planner succeed?
					if (_foundPlan) then {
						// Unpack the plan
						_newAction = CALLM(_thisObject, "createActionsFromPlan", [_actionPlan]);
						// Set a new action from the plan
						CALLM1(_thisObject, "setCurrentAction", _newAction);
					} else {
						// Terminate the current action (if it exists)
						CALLM0(_thisObject, "deleteCurrentAction");
						pr _wsCurr = GETV(_thisObject, "worldState");
						OOP_ERROR_2("PROCESS: Failed to generate an action plan. Current WS: %1,  Goal WS: %2", _wsCurr, _wsGoal);
					};
				} else {
					// Set a new action from the predefined action
					CALLM1(_thisObject, "setCurrentAction", _newAction);
				};
				
			};
		} else {
			// We don't pursue a goal any more
			OOP_INFO_0("PROCESS: NO GOAL");
			
			// End the previous goal if we had it
			pr _currentGoal = GETV(_thisObject, "currentGoal");
			if (_currentGoal != "") then {
				OOP_INFO_1("PROCESS: ENDING CURRENT GOAL: %1", _currentGoal);
				T_SETV("currentGoal", "");
				T_SETV("currentGoalSource", "");
				T_SETV("currentGoalParameters", []);
				//T_SETV("currentGoalState", -1); // -1 means there is no goal
			};
			
			// Delete the current action if we had it
			CALLM0(_thisObject, "deleteCurrentAction");
			
			//diag_log format ["  most relevant goal: %1", _goalClassName];
		};
		
		// Process the current action if we have it
		pr _currentAction = GETV(_thisObject, "currentAction");
		if (_currentAction != "") then {
			pr _actionState = CALLM(_currentAction, "process", []);
			
			pr _subaction = CALLM0(_currentAction, "getFrontSubaction");
			if (_subaction == _currentAction) then { // If it's not a composite action
				OOP_INFO_2("CURRENT ACTION: %1, state: %2", _currentAction, _actionState);
			} else {
				OOP_INFO_3("CURRENT ACTION: %1, subaction: %2, state: %3", _currentAction, _subaction, _actionState);
			};
			
			// Set goal state			
			//T_SETV("currentGoalState", _actionState);
			
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
					OOP_ERROR_1("PROCESS: can't set external goal action state: %1", _goalClassName);
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
					T_SETV("currentGoal", "");
					T_SETV("currentGoalSource", "");
					T_SETV("currentGoalParameters", []);
				};
				
				case ACTION_STATE_FAILED : {
					// Probably we should replan our goal at the next iteration
					SETV(_thisObject, "currentGoal", "");
					T_SETV("currentGoal", "");
					T_SETV("currentGoalSource", "");
					T_SETV("currentGoalParameters", []);
				};

				case ACTION_STATE_REPLAN : {
					// Probably we should replan our goal at the next iteration
					SETV(_thisObject, "currentGoal", "");
					T_SETV("currentGoal", "");
					T_SETV("currentGoalSource", "");
					T_SETV("currentGoalParameters", []);
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
		_possibleGoals = _possibleGoals apply {[_x, 0, [], _thisObject, ACTION_STATE_INACTIVE]}; // Goal class name, bias, parameter, source, state
		pr _extGoals = GETV(_thisObject, "goalsExternal");
		_possibleGoals append _extGoals;
		#ifdef DEBUG_POSSIBLE_GOALS
			OOP_INFO_1("getMostRelevantGoals possible goals: %1", _possibleGoals);
		#endif
		{
			pr _goalState = _x select 4;
			
			// Sanity check if goal state is nil because action didn't return it...
			if (isNil "_goalState") then {
				_goalState = ACTION_STATE_INACTIVE;
				_x set [4, _goalState];
				OOP_ERROR_1("Goal state is nil: %1", _x);
				DUMP_CALLSTACK;
			};

			// Don't return completed goals
			if (_goalState != ACTION_STATE_COMPLETED) then {
				pr _goalClassName = _x select 0;
				pr _bias = _x select 1;
				pr _parameters = _x select 2;
				pr _relevance = CALL_STATIC_METHOD(_goalClassName, "calculateRelevance", [_thisObject ARG _parameters]);
				//diag_log format ["   Calculated relevance for goal %1: %2", _goalClassName, _relevance];
				_relevance = _relevance + _bias;
				
				#ifdef DEBUG_POSSIBLE_GOALS
					OOP_INFO_2("getMostRelevantGoals goal: %1, relevance: %2", _goalClassName, _relevance);
				#endif
				
				if (_relevance > _relevanceMax) then {
					_relevanceMax = _relevance;
					_mostRelevantGoal = _x;
				};
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
	Adds a goal to the list of external goals of this agent. By default it also deletes goals with same _goalClassName irrelevant of its source!
	
	Parameters: _goalClassName, _bias, _parameters
	
	_goalClassName - <Goal> class name
	_bias - a number to be added to the relevance of the goal once it is calculated
	_parameters - the array with parameters to be passed to the goal if it's activated, can be anything goal-specific
	_sourceAI - <AI> object that gave this goal or "", can be used to identify who gave this goal, for example, when deleting it through <deleteExternalGoal>
	_deleteSimilarGoals - Bool, optional default true. If true, will automatically delete all goals with the same _goalClassName.
	_callProcess - Bool, optional default true. If true, also calls process method inside this function call to accelerate goal arbitration.

	Returns: nil
	*/
	
	METHOD("addExternalGoal") {
		params [["_thisObject", "", [""]], ["_goalClassName", "", [""]], ["_bias", 0, [0]], ["_parameters", [], [[]]], ["_sourceAI", "", [""]], ["_deleteSimilarGoals", true], ["_callProcess", true]];
		
		OOP_INFO_3("ADDED EXTERNAL GOAL: %1, parameters: %2, source: %3", _goalClassName, _parameters, _sourceAI);
		
		/*
		if (_sourceAI != "") then {
			ASSERT_OBJECT_CLASS(_sourceAI, "AI");
		};
		*/
		
		pr _goalsExternal = GETV(_thisObject, "goalsExternal");
		
		if (_deleteSimilarGoals) then {
			pr _i = 0;
			pr _goalDeleted = false;
			while {_i < count _goalsExternal} do {
				pr _cg = _goalsExternal select _i;
				if (	(((_cg select 0) == _goalClassName)) ) then {
					pr _deletedGoal = _goalsExternal deleteAt _i;
					OOP_INFO_1("AUTOMATICALLY DELETED EXTERNAL GOAL: %1", _deletedGoal);
				} else {
					_i = _i + 1;
				};
			};
		};
		
		_goalsExternal pushBackUnique [_goalClassName, _bias, _parameters, _sourceAI, ACTION_STATE_INACTIVE];
		
		// Call the "onGoalAdded" static method
		CALLSM(_goalClassName, "onGoalAdded", [_thisObject ARG _parameters]);

		// Call process method to accelerate goal arbitration
		if (_callProcess) then {
			CALLM0(_thisObject, "process");
		};

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
	_goalParameters - parameter array, if specified then the function will only delete goals which have all tags set to specified values

	Returns: nil
	*/
	METHOD("deleteExternalGoal") {
		params [["_thisObject", "", [""]], ["_goalClassName", "", [""]], ["_goalSourceAI", ""], ["_goalParameters", []]];

		/*
		if (_goalSourceAI != "") then {
			ASSERT_OBJECT_CLASS(_goalSourceAI, "AI");
		};
		*/

		CRITICAL_SECTION_START
		// [_goalClassName, _bias, _parameters, _source, ACTION_STATE_INACTIVE]
		pr _goalsExternal = GETV(_thisObject, "goalsExternal");
		pr _i = 0;
		pr _goalDeleted = false;
		while {_i < count _goalsExternal} do {
			pr _cg = _goalsExternal select _i;
			if (	(((_cg select 0) == _goalClassName) || (_goalClassName == "")) &&
					( ((_cg select 3) == _goalSourceAI) || (_goalSourceAI == ""))) then {
				
				// Ensure external goal parameters
				/*
				pr _nParamMismatch = 0;
				scopeName "__s1";
				if (count _goalParameters > 0) then {
					_nParamMismatch = count _goalParameters;
					{
						_x params ["_tag", "_value"];
						pr _extGoalParams = _cg select 2;
						pr _index = _extGoalParams findIf {_x#0 == _tag};
						if (_index != -1) then {
							if ( ((_extGoalParams#_index#1) isEqualTo _value)) then {
								_nParamMismatch = _nParamMismatch - 1;
							};
						};
					} forEach _goalParameters;
				};
				*/
				
				//if (_nParamMismatch == 0) then {
					// Call the "onGoalDeleted" static method
					private _thisGoalClassName = _cg select 0;
					CALLSM(_cg select 0, "onGoalDeleted", [_thisObject ARG _cg select 2]);

					// Delete this goal
					pr _deletedGoal = _goalsExternal deleteAt _i;
					OOP_INFO_1("DELETED EXTERNAL GOAL: %1", _deletedGoal);
					_goalDeleted = true;
				//};
			} else {
				_i = _i + 1;
			};
		};
		
		if (!_goalDeleted) then {
			OOP_WARNING_2("couldn't delete external goal: %1, %2", _goalClassName, _goalSourceAI);
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

	/*
	Method: hasExternalGoal
	Returns true if this agent has specified external goal from specified source
	
	Parameters: _goalClassName, _source
	
	_goalClassName - <Goal> class name
	_source - string, source of the goal, or "" to ignore this field. If "" is provided, source field will be ignored.
	
	Returns: Bool
	*/
	METHOD("hasExternalGoal") {
		params [["_thisObject", "", [""]], ["_goalClassName", "", [""]], ["_goalSource", ""]];

		pr _return = false;
		CRITICAL_SECTION_START
		// [_goalClassName, _bias, _parameters, _source, action state];
		pr _goalsExternal = GETV(_thisObject, "goalsExternal");
		pr _index = if (_goalSource == "") then {
			_goalsExternal findIf {(_x select 0) == _goalClassName}
		} else {
			_goalsExternal findIf {((_x select 0) == _goalClassName) && (_x select 3 == _goalSource)}
		};
		if (_index != -1) then {
			_return = true
		};
		CRITICAL_SECTION_END
		
		_return
	} ENDMETHOD;
	
	/*
	Method: (static)anyAgentHasExternalGoal
	Returns true if any agent has in the array has the specified external goal.
	
	Parameters: _agents, _goalClassName, _goalSource
	
	_agents - array of agent objects (Unit, Garrison, Group - must support getAI method)
	_goalClassName - <Goal> class name
	_source - string, source of the goal, or "" to ignore this field. If "" is provided, source field will be ignored.
	
	Returns: Bool
	*/	
	STATIC_METHOD("anyAgentHasExternalGoal") {
		params ["_thisClass", ["_agents", [], [[]]], ["_goalClassName", "", [""]], ["_goalSource", ""]];
		(_agents findIf {
			pr _AI = CALLM0(_x, "getAI");
			CALLM2(_AI, "hasExternalGoal", _goalClassName, _goalSource)
		}) != -1
	} ENDMETHOD;

	// --------------------------------------------------------------------------------
	// |                G E T   E X T E R N A L   G O A L   P A R A M E T E R S
	// --------------------------------------------------------------------------------
	/*
	Method: getExternalGoalParameters
	Returns the parameters array of the external goal.
	
	Parameters: _goalClassName, _source
	
	_goalClassName - <Goal> class name
	_source - string, source of the goal, or "" to ignore this field. If "" is provided, source field will be ignored.
	
	Returns: Array with goal parameters passed to it, or [] if this goal was not found.
	*/
	METHOD("getExternalGoalParameters") {
		params [["_thisObject", "", [""]], ["_goalClassName", "", [""]], ["_goalSource", ""]];

		pr _return = [];
		CRITICAL_SECTION_START
		// [_goalClassName, _bias, _parameters, _source, action state];
		pr _goalsExternal = GETV(_thisObject, "goalsExternal");
		pr _index = if (_goalSource == "") then {
			_goalsExternal findIf {(_x select 0) == _goalClassName}
		} else {
			_goalsExternal findIf {((_x select 0) == _goalClassName) && (_x select 3 == _goalSource)}
		};
		if (_index != -1) then {
			_return = _goalsExternal select _index select 2;
		//} else {
			//OOP_WARNING_2("can't find external goal: %1, external goals: %2", _goalClassName, _goalsExternal);
		};
		CRITICAL_SECTION_END
		
		_return
	} ENDMETHOD;
	
	/*
	Method: (static)allAgentsCompletedExternalGoal
	Returns true if all provided AI objects have completed an external goal.
	
	Parameters: _agents, _goalClassName, _goalSource
	
	_agents - array of agent objects (Unit, Garrison, Group - must support getAI method)
	_goalClassName - <Goal> class name
	_source - string, source of the goal, or "" to ignore this field. If "" is provided, source field will be ignored.
	
	Returns: Bool
	*/
	STATIC_METHOD("allAgentsCompletedExternalGoal") {
		params ["_thisClass", ["_agents", [], [[]]], ["_goalClassName", "", [""]], ["_goalSource", ""]];
		OOP_INFO_2("allAgentsCompletedExternalGoal: %1, Source: %2", _goalClassName, _goalSource);

		private _completedCount = ({
			pr _AI = CALLM0(_x, "getAI");
			pr _actionState = CALLM2(_AI, "getExternalGoalActionState", _goalClassName, _goalSource);
			pr _completed = (_actionState == ACTION_STATE_COMPLETED);
			OOP_INFO_3("    AI: %1, State: %2, Completed: %3", _AI, _actionState, _completed ); // || (_actionState == -1));
			_completed  // || (_actionState == -1)
		} count _agents);

		_completedCount == (count _agents)
	} ENDMETHOD;

	/*
	Method: (static)anyAgentFailedExternalGoal
	Returns true if any agent has failed the external goal.
	
	Parameters: _agents, _goalClassName, _goalSource
	
	_agents - array of agent objects (Unit, Garrison, Group - must support getAI method)
	_goalClassName - <Goal> class name
	_source - string, source of the goal, or "" to ignore this field. If "" is provided, source field will be ignored.
	
	Returns: Bool
	*/	
	STATIC_METHOD("anyAgentFailedExternalGoal") {
		params ["_thisClass", ["_agents", [], [[]]], ["_goalClassName", "", [""]], ["_goalSource", ""]];
		(_agents findIf {
			pr _AI = CALLM0(_x, "getAI");
			pr _actionState = CALLM2(_AI, "getExternalGoalActionState", _goalClassName, _goalSource);
			(_actionState == ACTION_STATE_FAILED)
		}) != -1
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
	// |                G E T   C U R R E N T   A C T I O N
	// |
	// ----------------------------------------------------------------------
	

	METHOD("getCurrentAction") {
		params [["_thisObject", "", [""]]];
		T_GETV("currentAction")
	} ENDMETHOD;
	

	// ----------------------------------------------------------------------
	// |            D E L E T E   C U R R E N T   A C T I O N
	// |
	// ----------------------------------------------------------------------
	
	METHOD("deleteCurrentAction") {
		params [["_thisObject", "", [""]]];
		pr _currentAction = GETV(_thisObject, "currentAction");
		if (_currentAction != "") then {
			pr _state = GETV(_currentAction, "state");
			OOP_INFO_2("DELETING CURRENT ACTION: %1, state: %2", _currentAction, _state);
		
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
			(_plan select 0) params ["_actionPrecedence", "_actionClassName", "_actionParameters"];
			pr _args = [_thisObject, _actionParameters];
			pr _action = NEW(_actionClassName, _args);
			
			// Return the action
			_action
		} else {
		
			// If there are multiple actions in the plan, create an ActionCompositeSerial and add subactions to it 
			pr _actionSerial = NEW("ActionCompositeSerial", [_thisObject]);

			{ // foreach _plan
				_x params ["_actionPrecedence", "_actionClassName", "_actionParameters"];
				
				// Create an action
				pr _args = [_thisObject, _actionParameters];
				pr _action = NEW(_actionClassName, _args);
				
				// Add it to the subactions list
				CALLM1(_actionSerial, "addSubactionToBack", _action);
			} forEach _plan;

			// Return the serial action
			_actionSerial
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
	
	#ifndef RELEASE_BUILD
	// Will print useful data about generated plan and how it was achieved
	#define ASTAR_DEBUG
	#endif
	
	#ifdef OFSTREAM_ENABLE
	#define ASTAR_LOG(text) (ofstream_new "A-star.rpt") ofstream_write text
	#else
	#define ASTAR_LOG(text)
	#endif
	
	STATIC_METHOD("planActions") {
		pr _paramsGood = params [ ["_thisClass", "", [""]], ["_currentWS", [], [[]]], ["_goalWS", [], [[]]], ["_possibleActions", [], [[]]], ["_goalParameters", [], [[]]], ["_AI", "ASTAR_ERROR_NO_AI", [""]] ];
		
		if (!_paramsGood) then {
			DUMP_CALLSTACK;
		};
		
		// Copy the array of possible actions becasue we are going to modify it
		pr _availableActions = +_possibleActions;
		
		#ifdef ASTAR_DEBUG
		OOP_INFO_0("");
		OOP_INFO_0("[AI:AStar] Info: ---------- Starting A* ----------");
		OOP_INFO_4("[AI:AStar] Info: currentWS: %1,  goalWS: %2,  goal parameters: %3  possibleActions: %4", [_currentWS] call ws_toString, [_goalWS] call ws_toString, _goalParameters, _possibleActions);
		#endif
		
		pr _initialNumUnsatisfiedProps = [_goalWS, _currentWS] call ws_getNumUnsatisfiedProps;

		// We are already there!
		if(_initialNumUnsatisfiedProps == 0) exitWith { 
			#ifdef ASTAR_DEBUG
			OOP_INFO_0("[AI:AStar] Info: No search required we are already at our goal!");
			#endif
			[true, []]
		};

		// Set of nodes already evaluated
		pr _closeSet = [];
		
		// Set of discovered nodes to evaluate
		pr _goalNode = ASTAR_NODE_NEW(_goalWS);
		_goalNode set [ASTAR_NODE_ID_F, _initialNumUnsatisfiedProps]; // Calculate heuristic for the goal node
		pr _openSet = [_goalNode];
		
		// Main loop of the algorithm
		pr _foundPath = false;
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
				OOP_INFO_0("");
				OOP_INFO_1("[AI:AStar] Info: Step: %1,  Open set:", _count);
				// Print the open and closed set
				{
					pr _nodeString = CALL_STATIC_METHOD("AI_GOAP", "AStarNodeToString", [_x]);
					OOP_INFO_0("[AI:AStar]  " + _nodeString);
				} forEach _openSet;
				
				// Print the selected node
				pr _nodeString = CALL_STATIC_METHOD("AI_GOAP", "AStarNodeToString", [_node]);
				OOP_INFO_1("[AI:AStar] Info: Analyzing node: %1", _nodeString);
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
					OOP_INFO_0("[AI:AStar] Info: Reached current state!");
				#endif
				_foundPath = true;
				// Recunstruct path
				pr _n = _node;
				while {true} do {
					if (! ((_n select ASTAR_NODE_ID_ACTION) isEqualTo ASTAR_ACTION_DOES_NOT_EXIST)) then {
						pr _actionClassName = _n select ASTAR_NODE_ID_ACTION;
						pr _precedence = CALLSM0(_actionClassName, "getPrecedence");
						_path pushBack [_precedence, _actionClassName, _n select ASTAR_NODE_ID_ACTION_PARAMETERS];
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
				OOP_INFO_1("[AI:AStar] Info: Discovering neighbours:", _nodeString);
			#endif
			
			{ // forEach _availableActions;
				pr _action = _x;
				//OOP_INFO_1("Analyzing action: %1", _action);
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
						_x params ["_tag", "_value"];
						
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
								OOP_WARNING_4("[AI:AStar] Warning: can't find a parameter for action: %1,  tag:  %2,  goal: %3,  goal parameters: %4",	_action, _tag, [_goalWS] call ws_toString, _goalParameters);
								//_parametersResolved = false;
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
						OOP_WARNING_1("[AI:AStar] Warning: can't resolve all parameters for action: %1", _action);
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
								OOP_INFO_2("[AI:AStar]  Found in close set:  [ WS: %1  Action: %2]", [_WSBeforeAction] call ws_toString, _x);
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
									pr _nodeString = CALL_STATIC_METHOD("AI_GOAP", "AStarNodeToString", [_n]);
									OOP_INFO_0("[AI:AStar]  New node:            " + _nodeString);
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
										pr _nodeString = CALL_STATIC_METHOD("AI_GOAP", "AStarNodeToString", [_nodeOpen]);
										//        "  Found in close set:  "
										OOP_INFO_1("[AI:AStar]  Updated in open set: %1", _nodeString);
									#endif
								} else {
									
									// Print debug text
									#ifdef ASTAR_DEBUG
										pr _nodeString = CALL_STATIC_METHOD("AI_GOAP", "AStarNodeToString", [_nodeOpen]);
										OOP_INFO_1("[AI:AStar]  Found in open set:   %1", _nodeString);
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
		

		// Sort the plan by precedence
		_path sort true; // Ascending
		
		#ifdef ASTAR_DEBUG
			OOP_INFO_1("[AI:AStar] Info: Generated plan: %1", _path);
		#endif
		
		// Return the reconstructed sorted path 
		[_foundPath, _path]
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
	
	
	// - - - - - - STORAGE - - - - -
	/* override */ METHOD("postDeserialize") {
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		//diag_log "AI_GOAP postDeserialize";

		// Call method of all base classes
		CALL_CLASS_METHOD("AI", _thisObject, "postDeserialize", [_storage]);

		// Restore variables
		SETV(_thisObject, "currentAction", "");
		SETV(_thisObject, "currentGoal", "");

		true
	} ENDMETHOD;

ENDCLASS;