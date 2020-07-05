#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#define OFSTREAM_FILE "AI.rpt"
#define PROFILER_COUNTERS_ENABLE
#include "..\..\common.h"
#include "..\..\Message\Message.hpp"
#include "..\parameterTags.hpp"
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

#ifdef ENABLE_LOG_GOAP
// Will output to .rpt which goals each AI is choosing from
#define DEBUG_POSSIBLE_GOALS
vin_fnc_logAction = {
	params ["_AI", "_msg", "_prev", "_new"];
	if(_prev isEqualTo _new) exitWith {};
	private _ownerAndPath = switch GET_OBJECT_CLASS(_AI) do {
		case "AIUnit";
		case "AIUnitInfantry";
		case "AIUnitVehicle": {
			private _unit = GETV(_AI, "agent");
			private _group = CALLM0(_unit, "getGroup");
			private _garrison = CALLM0(_unit, "getGarrison");
			//format["%1>%2>%3", _garrison, _group, _unit]
			[CALLM0(_garrison, "getAI"), format["%1>%2", CALLM0(_group, "getAI"), _AI]]
		};
		case "AIUnitCivilian": {
			private _unit = GETV(_AI, "agent");
			[_AI, ""]
		};
		case "AIGroup": {
			private _group = GETV(_AI, "agent");
			private _garrison = CALLM0(_group, "getGarrison");
			//format["%1>%2", _garrison]
			[CALLM0(_garrison, "getAI"), CALLM0(_group, "getAI")]
		};
		default {
			[_AI, ""]
		};
	};

	_ownerAndPath params ["_owner", "_path"];

	if(!isNil "_owner") then {
		OOP_LOGF_4("goap_" + _owner + ".rpt", "%1: %2 .. %3 (prev %4)", _path, _msg, _new, _prev)
	};
};

vin_fnc_getLogState = {
	params [P_THISOBJECT];
	private _goal = T_GETV("currentGoal");
	private _action = T_GETV("currentAction");
	private _subaction = if(_action != NULL_OBJECT) then { CALLM0(_action, "getFrontSubaction") } else { NULL_OBJECT };
	private _state = if(_subaction != NULL_OBJECT) then { gDebugActionStateText select GETV(_subaction, "state") } else { "(NONE)" };
	private _actionClass = if(_action != NULL_OBJECT) then { GET_OBJECT_CLASS(_action) } else { "" };
	private _subActionClass = if(_subaction != NULL_OBJECT) then { GET_OBJECT_CLASS(_subaction) } else { "" };
	[_goal, _actionClass, _subActionClass, _state];
};
#define LOG_GOAP(ai, msg, prev, new) ([ai, msg, prev, new] call vin_fnc_logAction)
//#define LOG_GOAP_GOAL(ai, act, prev, new) ([ai, act, "GOAL", prev, new] call vin_fnc_logAction)
// #define LOG_GOAP_STATE(ai, act, prev, new) ([ai, act, "STATE", gDebugActionStateText select prev, gDebugActionStateText select new] call vin_fnc_logAction)
#else
#define LOG_GOAP(ai, msg, prev, new)
// #define LOG_GOAP_GOAL(ai, act, prev, new)
// #define LOG_GOAP_STATE(ai, act, prev, new)
#endif
FIX_LINE_NUMBERS()

#define AI_TIMER_SERVICE gTimerServiceMain

// Array of AIs which are requested to halt
if (isNil "g_AI_GOAP_haltArray") then {
	g_AI_GOAP_haltArray = [];
};

// Cache for planner
#ifdef _SQF_VM
gAIPlannerCache = "PlannerCache" createVehicle [0,0,0];
#else
gAIPlannerCache = [false] call CBA_fnc_createNamespace;
#endif

#ifdef DEBUG_GOAP
AIPlannerCacheNHit = 0;
AIPlannerCacheNMiss = 0;
#endif

#define OOP_CLASS_NAME AI_GOAP
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
	
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_agent")];
		
		T_SETV("currentAction", "");
		T_SETV("currentGoal", "");
		T_SETV("currentGoalSource", "");
		T_SETV("currentGoalParameters", []);
		//T_SETV("currentGoalState", ACTION_STATE_INACTIVE);
		T_SETV("goalsExternal", []);
		pr _ws = [1] call ws_new; // todo WorldState size must depend on the agent
		T_SETV("worldState", _ws);
		T_SETV("worldFacts", []);

	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD(delete)
		params [P_THISOBJECT];
		
		// Delete the current action
		pr _action = T_GETV("currentAction");
		if (_action != "") then {
			CALLM0(_action, "terminate");
			DELETE(_action);
		};
		
	ENDMETHOD;




	// -------------------------------------------------------------------------------------------------------------
	// VIRTUAL METHODS
	// These can be overriden in child AI classes
	// -------------------------------------------------------------------------------------------------------------

	/*
	Method: setUrgentPriorityOnAddGoal
	Returning true from this will cause this AI to be marked as high priority when external goal is added.
	Override in derived classes!
	*/
	public virtual METHOD(setUrgentPriorityOnAddGoal)
		false
	ENDMETHOD;

	//                        G E T   P O S S I B L E   G O A L S
	/*
	Method: getPossibleGoals
	Returns the list of goals this AI evaluates on its own.
	Override in derived classes!!
	*/
	public virtual METHOD(getPossibleGoals)
		params [P_THISOBJECT];
		OOP_ERROR_0("getPossibleGoals is not implemented!");
		0 // Will cause error
	ENDMETHOD;

	//                      G E T   P O S S I B L E   A C T I O N S
	/*
	Method: getPossibleActions
	Returns: Array with action class names
	Override in derived classes!!
	*/
	public virtual METHOD(getPossibleActions)
		params [P_THISOBJECT];
		OOP_ERROR_0("getPossibleActions is not implemented!");
		0 // Will cause error
	ENDMETHOD;

	// Returns array of class-specific additional variable names to be transmitted to debug UI
	// Override to show debug data in debug UI for specific class
	public virtual METHOD(getDebugUIVariableNames)
		[]
	ENDMETHOD;

	/*
	Method: onGoalChosen
	Called when new goal is chosen.
	Override to set up some world state properties in AI or alter the goal parameters.
	Passed goal parameters array is a copy of actual goal parameters.
	Returns: nothing
	*/
	public virtual METHOD(onGoalChosen)
		//params [P_THISOBJECT, P_ARRAY("_goalParameters")];
	ENDMETHOD;

	// ------------------------------------------------------------------------------------------------------




	

	// ----------------------------------------------------------------------
	// |                              P R O C E S S
	// | Must be called every update interval
	// ----------------------------------------------------------------------
	
	public override METHOD(process)
		params [P_THISOBJECT, P_BOOL("_spawning")];
		
		#ifdef ASP_ENABLE
		private _className = GET_OBJECT_CLASS(_thisObject);
		private __scopeProcess1 = createProfileScope ([format ["%1_process", _className]] call misc_fnc_createStaticString);
		#endif
		FIX_LINE_NUMBERS()

		// Halt here if requested for debug
		if (_thisObject in g_AI_GOAP_haltArray) then {
			halt;
			g_AI_GOAP_haltArray deleteAt (g_AI_GOAP_haltArray find _thisObject);
		};

		//OOP_INFO_0("PROCESS");
		
		pr _agent = T_GETV("agent");
		
		#ifdef ENABLE_LOG_GOAP 
		private __prevState = [_thisObject] call vin_fnc_getLogState;
		#endif
		FIX_LINE_NUMBERS()

		// If we are spawning in a garrison then reset its action (the action onSpawn event will have been called already).
		// This ensures that _instant behavior can be applied cleanly to the garrison in one go.
		if(_spawning) then {
			T_CALLM0("deleteCurrentAction");
			T_SETV("currentGoal", NULL_OBJECT);
			T_SETV("currentGoalSource", NULL_OBJECT);
			T_SETV("currentGoalParameters", []);
		};

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
		T_CALLM1("updateSensors", _spawning);

		OOP_INFO_1("PROCESS: world state: %1", [T_GETV("worldState")] call ws_toString);
		
		// Update all world facts (delete old facts)
		T_CALLM0("updateWorldFacts");

		//Calculate most relevant goal
		pr _goalNewArray = T_CALLM0("getMostRelevantGoal");
		
		// If we have chosen some goal
		if (count _goalNewArray != 0) then {
			_goalNewArray params ["_goalClassName", "_goalBias", "_goalParameters", "_goalSourceAI", "_goalActionState"]; // Goal class name, bias, parameter, source
			//diag_log format ["  most relevant goal: %1", _goalClassName];
			
			// Check if the new goal is the same as the current goal
			pr _currentGoal = T_GETV("currentGoal");
			pr _currentGoalParameters = T_GETV( "currentGoalParameters");
			if (_currentGoal == _goalClassName
				// && _currentGoalParameters isEqualTo _goalParameters // Disabled for now, because it causes a goal restart after first process of goal with instant tag, because value changes from true to false
			) then {
				// We have the same goal. Do nothing.
				OOP_INFO_2("PROCESS: SAME GOAL: %1, %2", _currentGoal, _currentGoalParameters);
			} else {
				// We have a new goal! Time to replan.

				// Delete the current action if we had it
				T_CALLM0("deleteCurrentAction");
				
				//T_SETV("currentGoalState", _goalActionState);
				OOP_INFO_4("PROCESS: NEW GOAL: %1, parameters: %2, source: %3, state: %4",
					_goalClassName, _goalParameters, _goalSourceAI, _goalActionState);
				
				#ifndef RELEASE_BUILD
				// So we can put breakpoints, _objectclass comes from the MessageLoop
				switch true do {
					case (_thisObject find "Garrison" != -1): {
						pr __bp = nil;
					};
					case (_thisObject find "Group" != -1): {
						pr __bp = nil;
					};
					case (_thisObject find "Unit" != -1): {
						pr __bp = nil;
					};
					default {
						pr __bp = nil;
					};
				};
				#endif
				FIX_LINE_NUMBERS()

				// Make a new Action Plan
				// First check if the goal assumes a predefined plan
				pr _actionParameters = +_goalParameters;
				if(_spawning) then {
					_actionParameters pushBack [TAG_INSTANT, true];
				};

				pr _newAction = CALLSM2(_goalClassName, "createPredefinedAction", _thisObject, _actionParameters);

				if (_newAction == NULL_OBJECT) then {
					// Predefined action was not supplied, so we must run the planner
					
					// Get desired world state
					pr _args = [/* AI */ _thisObject, _goalParameters];
					pr _wsGoal = CALLSM(_goalClassName, "getEffects", _args);

					#ifdef OOP_ASSERT
					if ((_wsGoal call ws_countExistingProperties) == 0) then {
						OOP_ERROR_0("Goal world state is empty!");
					};
					#endif

					// Make a copy of original parameters
					// Goal might add something to them
					pr _goalParametersCopy = +_goalParameters;

					// Goal might do some preparations on AI or goal parameters here
					T_CALLM1("onGoalChosen", _goalParametersCopy);
					CALLSM2(_goalClassName, "onGoalChosen", _thisObject, _goalParametersCopy);

					// Verify goal parameters
					#ifdef DEBUG_GOAP
					if (!CALLSM1(_goalClassName, "verifyParameters", _goalParametersCopy)) then {
						OOP_ERROR_1("Wrong parameters for goal: %1", _goalClassName);
					};
					#endif
					FIX_LINE_NUMBERS()

					// Get actions this agent can do
					pr _possActions = T_CALLM0("getPossibleActions");
					
					// Run the A* planner to generate a plan
					pr _wsCurrent = +T_GETV("worldState");
					pr _args = [_wsCurrent, _wsGoal, _possActions, _goalParametersCopy, _thisObject];

					CALLSM("AI_GOAP", "planActions", _args) params ["_foundPlan", "_actionPlan"];
					
					// Did the planner succeed?
					if (_foundPlan) then {
						if (count _actionPlan > 0) then {
							// Unpack the plan
							_newAction = T_CALLM4("createActionsFromPlan", _actionPlan, _wsGoal, _goalParametersCopy, _spawning);
						} else {
							// The generated plan is empty but valid
							// It means we don't need to do anything
							OOP_INFO_2("Generated plan is empty but valid: goal: %1, goal parameters: %2", _goalClassName, _goalParametersCopy);
							OOP_INFO_1("Current WS: %1", [_wsCurrent] call ws_toString);
							OOP_INFO_1("Goal WS: %1", [_wsGoal] call ws_toString);

							// Mark the current action as complete
							pr _goalsExternal = T_GETV("goalsExternal");
							pr _index = _goalsExternal findIf { _goalClassName == _x#0 && _goalSourceAI == _x#3 };
							if (_index != -1) then {
								pr _arrayElement = _goalsExternal#_index;
								_arrayElement set [4, ACTION_STATE_COMPLETED];
							};
						};
					} else {
						// Terminate the current action (if it exists)
						//T_CALLM0("deleteCurrentAction");
						pr _wsCurr = T_GETV("worldState");
						OOP_ERROR_2("PROCESS: Failed to generate an action plan for goal %1, parameters: %2", _goalClassName, _goalParametersCopy);
						OOP_ERROR_1("Current WS: %1", [_wsCurr] call ws_toString);
						OOP_ERROR_1("Goal WS: %1", [_wsGoal] call ws_toString);

						CALLSM2(_goalClassName, "onPlanFailed", _thisObject, _goalParametersCopy);
					};
				};

				if(_newAction != NULL_OBJECT) then {
					T_CALLM1("setCurrentAction", _newAction);
					T_SETV("currentGoal", _goalClassName);
					T_SETV("currentGoalSource", _goalSourceAI);
					T_SETV("currentGoalParameters", _goalParameters);
				};
			};
		} else {
			// We don't pursue a goal any more
			OOP_INFO_0("PROCESS: NO GOAL");
			T_CALLM0("deleteCurrentAction");
			T_SETV("currentGoal", NULL_OBJECT);
			T_SETV("currentGoalSource", NULL_OBJECT);
			T_SETV("currentGoalParameters", []);
		};

		// Process the current action if we have it
		pr _currentAction = T_GETV("currentAction");
		if (_currentAction != NULL_OBJECT) then {

			// Make sure we perform the current action instantly if accelerated behavoir is on
			if(_spawning) then {
				CALLM1(_currentAction, "setInstant", true);
			};

			#ifdef ASP_ENABLE
			private __scopeProcessAction = createProfileScope "AI_GOAP_processCurrentAction";
			#endif
			FIX_LINE_NUMBERS()

			pr _actionState = CALLM0(_currentAction, "process");

			#ifdef ASP_ENABLE
			__scopeProcessAction = nil;
			#endif
			FIX_LINE_NUMBERS()

			CALLM1(_currentAction, "setInstant", false);

			pr _subaction = CALLM0(_currentAction, "getFrontSubaction");
			if (_subaction == _currentAction) then { // If it's not a composite action
				OOP_INFO_2("CURRENT ACTION: %1, state: %2", _currentAction, _actionState);
			} else {
				OOP_INFO_3("CURRENT ACTION: %1, subaction: %2, state: %3", _currentAction, _subaction, _actionState);
			};

			// Set goal state
			//T_SETV("currentGoalState", _actionState);

			// If it's an external goal, set its action state in the external goal array
			pr _goalSourceAI = T_GETV("currentGoalSource");
			if (_goalSourceAI != _thisObject) then {
				pr _goalClassName = T_GETV("currentGoal");
				pr _goalsExternal = T_GETV("goalsExternal");

				// goalsExternal can be modified from other threads so use a critical section here
				CRITICAL_SECTION {
					pr _index = _goalsExternal findIf { _goalClassName == _x#0 && _goalSourceAI == _x#3 };
					if (_index != -1) then {
						// Set state of that goal
						pr _arrayElement = _goalsExternal#_index;
						_arrayElement set [4, _actionState];

						// If TAG_INSTANT was passed with the goal, set it to false
						// Because instant flag can only be used once
						// Or maybe it's even better to delete that parameter completely from array?
						pr _goalParameters = _arrayElement#2;
						pr _instantTagId = _goalParameters findIf {_x#0 == TAG_INSTANT;};
						if (_instantTagId != -1) then {
							(_goalParameters#_instantTagID) set [1, false]; // Set value to false 
						};
					} else {
						//OOP_ERROR_1("PROCESS: can't set external goal action state: %1", _goalClassName);
					};
				};
			};

			if(_actionState in [ACTION_STATE_COMPLETED, ACTION_STATE_FAILED, ACTION_STATE_REPLAN]) then {
				T_CALLM0("deleteCurrentAction");
				pr _goalClassName = T_GETV("currentGoal");
				T_SETV("currentGoal", NULL_OBJECT);
				T_SETV("currentGoalSource", NULL_OBJECT);
				T_SETV("currentGoalParameters", []);

				switch (_actionState) do {
					case ACTION_STATE_COMPLETED: { CALLSM1(_goalClassName, "onGoalCompleted", _thisObject); };
					case ACTION_STATE_FAILED: { CALLSM1(_goalClassName, "onGoalFailed", _thisObject); };
				};
			};
		};

		#ifdef ENABLE_LOG_GOAP 
		private __newState = [_thisObject] call vin_fnc_getLogState;
		LOG_GOAP(_thisObject, "", __prevState, __newState);
		#endif
		FIX_LINE_NUMBERS()

	ENDMETHOD;

	METHOD(reset)
		params [P_THISOBJECT];
		T_CALLM0("deleteCurrentAction");
		T_SETV("currentGoal", NULL_OBJECT);
		T_SETV("currentGoalSource", NULL_OBJECT);
		T_SETV("currentGoalParameters", []);
		T_CALLM0("deleteExternalGoal");
	ENDMETHOD;

	public METHOD(resetRecursive)
		params [P_THISOBJECT];
		T_CALLM0("reset");
		// Reset subagents
		{
			CALLM0(_x, "resetRecursive");
		} forEach (CALLM0(T_GETV("agent"), "getSubagents") apply {
			CALLM0(_x, "getAI")
		} select {
			_x != NULL_OBJECT
		});
	ENDMETHOD;

	// ------------------------------------------------------------------------------------------------------
	// -------------------------------------------- G O A L S -----------------------------------------------
	// ------------------------------------------------------------------------------------------------------
	
	
	
	
	// ----------------------------------------------------------------------
	// |                G E T   M O S T   R E L E V A N T   G O A L
	// | Return value: ["_goalClassName", "_goalBias", "_goalParameters", "_goalSourceAI"]
	// | 
	// ----------------------------------------------------------------------
	
	METHOD(getMostRelevantGoal)
		params [P_THISOBJECT];
		
		#ifdef ASP_ENABLE
		private _className = GET_OBJECT_CLASS(_thisObject);
		private __scopeGetGoal = createProfileScope ([format ["%1_getMostRelevantGoal", _className]] call misc_fnc_createStaticString);
		#endif
		FIX_LINE_NUMBERS()
		
		// Get the list of goals available to this agent
		pr _possibleGoals = T_CALLM0("getPossibleGoals");
		pr _relevanceMax = -1000;
		pr _mostRelevantGoal = [];
		_possibleGoals = _possibleGoals apply {[_x, 0, [], _thisObject, ACTION_STATE_INACTIVE, true]}; // Goal class name, bias, parameter, source, state
		pr _extGoals = T_GETV("goalsExternal");
		_possibleGoals append _extGoals;
		#ifdef DEBUG_POSSIBLE_GOALS
			OOP_INFO_1("getMostRelevantGoals possible goals: %1", _possibleGoals);
		#endif
		FIX_LINE_NUMBERS()
		{
			pr _goalState = _x select 4;

			// Instantly find it if it has a TAG_INSTANT set to true
			pr _goalParameters = _x select 2;
			if (_goalParameters findIf {(_x#0 == TAG_INSTANT) && {_x#1}} != -1) exitWith {
				_relevanceMax = 99999;
				_mostRelevantGoal = _x;
			};
			
			// Sanity check if goal state is nil because action didn't return it...
			if (isNil "_goalState") then {
				_goalState = ACTION_STATE_INACTIVE;
				_x set [4, _goalState];
				OOP_ERROR_1("Goal state is nil: %1", _x);
				DUMP_CALLSTACK;
			};

			// Don't return completed goals
			// But return repetitive goals regardless
			if ((_goalState != ACTION_STATE_COMPLETED) || (_x select 5)) then {
				pr _goalClassName = _x select 0;
				//pr _bias = _x select 1; // Not used anywhere
				pr _parameters = _x select 2;
				pr _relevance = CALLSM(_goalClassName, "calculateRelevance", [_thisObject ARG _parameters]);
				//diag_log format ["   Calculated relevance for goal %1: %2", _goalClassName, _relevance];
				//_relevance = _relevance + _bias;
				
				#ifdef DEBUG_POSSIBLE_GOALS
					OOP_INFO_2("getMostRelevantGoals goal: %1, relevance: %2", _goalClassName, _relevance);
				#endif
				FIX_LINE_NUMBERS()
				
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
	ENDMETHOD;
	
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
	_callProcess - Bool, optional default false. If true, also calls process method inside this function call to accelerate goal arbitration.
	_repeat - Bool, optional, default false. If true, this goal will be always active, even when completed.

	Returns: nil
	*/
	
	public METHOD(addExternalGoal)
		params [P_THISOBJECT, P_OOP_OBJECT("_goalClassName"), P_NUMBER("_bias"),
				P_ARRAY("_parameters"), P_OOP_OBJECT("_sourceAI"),
				["_deleteSimilarGoals", true], P_BOOL("_callProcess"), P_BOOL("_repeat")];

		
		OOP_INFO_3("ADDED EXTERNAL GOAL: %1, parameters: %2, source: %3", _goalClassName, _parameters, _sourceAI);
		
		/*
		if (_sourceAI != "") then {
			ASSERT_OBJECT_CLASS(_sourceAI, "AI");
		};
		*/
		
		pr _goalsExternal = T_GETV("goalsExternal");
		
		//private _scope30 = createProfileScope "_deleteSimilarGoals";
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
		//_scope30 = nil;
		
		// !! It makes a deep copy of parameters
		_goalsExternal pushBackUnique [_goalClassName, _bias, +_parameters, _sourceAI, ACTION_STATE_INACTIVE, _repeat];
		
		//private _scope35 = createProfileScope "_onGoalAdded";
		// Call the "onGoalAdded" static method
		CALLSM(_goalClassName, "onGoalAdded", [_thisObject ARG _parameters]);
		//_scope35 = nil;

		//private _scope40 = createProfileScope "_setUrgentPriority";
		// Set as high priority if needed
		if (T_CALLM0("setUrgentPriorityOnAddGoal")) then {
			T_CALLM0("setUrgentPriority");
		};
		//_scope40 = nil;

		0
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                D E L E T E   E X T E R N A L   G O A L
	// ----------------------------------------------------------------------
	/*
	Method: deleteExternalGoal
	Deletes an external goal having the same goalClassName and goalSource
	
	Parameters: _goalClassName, _goalSourceAI
	
	_goalClassName - <Goal> class name
	_goalSourceAI - <AI> object that gave this goal or "" to ignore this field. If "" is provided, source field will be ignored.
	_goalParameters - parameter array, if specified then the function will only delete goals which have all tags set to specified values

	Returns: nil
	*/
	public METHOD(deleteExternalGoal)
		params [P_THISOBJECT, P_OOP_OBJECT("_goalClassName"), P_OOP_OBJECT("_goalSourceAI")];

		CRITICAL_SECTION {
			pr _goalsExternal = T_GETV("goalsExternal");
			pr _i = 0;
			pr _goalDeleted = false;
			while {_i < count _goalsExternal} do {
				pr _cg = _goalsExternal select _i;
				if (	(((_cg select 0) == _goalClassName) || (_goalClassName == "")) &&
						( ((_cg select 3) == _goalSourceAI) || (_goalSourceAI == ""))) then {
					
					// Call the "onGoalDeleted" static method
					pr _thisGoalClassName = _cg select 0;
					CALLSM(_cg select 0, "onGoalDeleted", [_thisObject ARG _cg select 2]);

					// Delete this goal
					pr _deletedGoal = _goalsExternal deleteAt _i;
					OOP_INFO_1("DELETED EXTERNAL GOAL: %1", _deletedGoal);
					_goalDeleted = true;
				} else {
					_i = _i + 1;
				};
			};
		};
		
		nil
	ENDMETHOD;
	
	/*
	Method: deleteExternalGoalRequired
	Deletes an external goal having the same goalClassName and goalSource, the goal must exist or it is an error
	
	Parameters: _goalClassName, _goalSourceAI
	
	_goalClassName - <Goal> class name
	_goalSourceAI - <AI> object that gave this goal or "" to ignore this field. If "" is provided, source field will be ignored.
	_goalParameters - parameter array, if specified then the function will only delete goals which have all tags set to specified values

	Returns: nil
	*/
	public METHOD(deleteExternalGoalRequired)
		params [P_THISOBJECT, P_STRING("_goalClassName"), P_OOP_OBJECT("_goalSourceAI")];

		CRITICAL_SECTION {
			pr _goalsExternal = T_GETV("goalsExternal");
			pr _i = 0;
			pr _goalDeleted = false;
			while {_i < count _goalsExternal} do {
				pr _cg = _goalsExternal select _i;
				if (	(((_cg select 0) == _goalClassName) || (_goalClassName == "")) &&
						( ((_cg select 3) == _goalSourceAI) || (_goalSourceAI == ""))) then {
					
					// Call the "onGoalDeleted" static method
					pr _thisGoalClassName = _cg select 0;
					CALLSM(_cg select 0, "onGoalDeleted", [_thisObject ARG _cg select 2]);

					// Delete this goal
					pr _deletedGoal = _goalsExternal deleteAt _i;
					OOP_INFO_1("DELETED EXTERNAL GOAL: %1", _deletedGoal);
					_goalDeleted = true;
				} else {
					_i = _i + 1;
				};
			};
			
			if (!_goalDeleted) then {
				OOP_ERROR_2("couldn't delete external goal: %1, %2", _goalClassName, _goalSourceAI);
			};
		};
		
		nil
	ENDMETHOD;
	
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
	public METHOD(getExternalGoalActionState)
		params [P_THISOBJECT, P_OOP_OBJECT("_goalClassName"), P_OOP_OBJECT("_goalSourceAI")];

		pr _return = -1;
		CRITICAL_SECTION {
			// [_goalClassName, _bias, _parameters, _source, action state];
			pr _goalsExternal = T_GETV("goalsExternal");
			pr _index = if (_goalSourceAI == "") then {
				_goalsExternal findIf {(_x select 0) == _goalClassName}
			} else {
				_goalsExternal findIf {((_x select 0) == _goalClassName) && (_x select 3 == _goalSourceAI)}
			};
			if (_index != -1) then {
				_return = _goalsExternal select _index select 4;
			} else {
				//OOP_WARNING_2("can't find external goal: %1, external goals: %2", _goalClassName, _goalsExternal);
			};
		};
		
		_return
	ENDMETHOD;

	/*
	Method: hasExternalGoal
	Returns true if this agent has specified external goal from specified source
	
	Parameters: _goalClassName, _source
	
	_goalClassName - <Goal> class name
	_source - string, source of the goal, or "" to ignore this field. If "" is provided, source field will be ignored.
	
	Returns: Bool
	*/
	public METHOD(hasExternalGoal)
		params [P_THISOBJECT, P_OOP_OBJECT("_goalClassName"), P_OOP_OBJECT("_goalSourceAI")];

		pr _return = false;
		CRITICAL_SECTION {
			// [_goalClassName, _bias, _parameters, _source, action state];
			pr _goalsExternal = T_GETV("goalsExternal");
			pr _index = if (_goalSourceAI == "") then {
				_goalsExternal findIf {(_x select 0) == _goalClassName}
			} else {
				_goalsExternal findIf {((_x select 0) == _goalClassName) && (_x select 3 == _goalSourceAI)}
			};
			if (_index != -1) then {
				_return = true
			};
		};
		
		_return
	ENDMETHOD;
	
	/*
	Method: (static)anyAgentHasExternalGoal
	Returns true if any agent has in the array has the specified external goal.
	
	Parameters: _agents, _goalClassName, _goalSourceAI
	
	_agents - array of agent objects (Unit, Garrison, Group - must support getAI method)
	_goalClassName - <Goal> class name
	_source - string, source of the goal, or "" to ignore this field. If "" is provided, source field will be ignored.
	
	Returns: Bool
	*/	
	public STATIC_METHOD(anyAgentHasExternalGoal)
		params [P_THISCLASS, P_ARRAY("_agents"), P_OOP_OBJECT("_goalClassName"), P_OOP_OBJECT("_goalSourceAI")];
		(_agents findIf {
			pr _AI = CALLM0(_x, "getAI");
			CALLM2(_AI, "hasExternalGoal", _goalClassName, _goalSourceAI)
		}) != -1
	ENDMETHOD;
	
	/*
	Method: (static)allAgentsHaveExternalGoal
	Returns true if all agents have the specified external goal.
	
	Parameters: _agents, _goalClassName, _goalSourceAI
	
	_agents - array of agent objects (Unit, Garrison, Group - must support getAI method)
	_goalClassName - <Goal> class name
	_source - string, source of the goal, or "" to ignore this field. If "" is provided, source field will be ignored.
	
	Returns: Bool
	*/	
	public STATIC_METHOD(allAgentsHaveExternalGoal)
		params [P_THISCLASS, P_ARRAY("_agents"), P_STRING("_goalClassName"), P_OOP_OBJECT("_goalSourceAI")];
		(_agents findIf {
			pr _AI = CALLM0(_x, "getAI");
			!CALLM2(_AI, "hasExternalGoal", _goalClassName, _goalSourceAI)
		}) == -1
	ENDMETHOD;
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
	public METHOD(getExternalGoalParameters)
		params [P_THISOBJECT, P_OOP_OBJECT("_goalClassName"), P_OOP_OBJECT("_goalSourceAI")];

		pr _return = [];

		CRITICAL_SECTION {
			// [_goalClassName, _bias, _parameters, _source, action state];
			pr _goalsExternal = T_GETV("goalsExternal");
			pr _index = if (_goalSourceAI == "") then {
				_goalsExternal findIf {(_x select 0) == _goalClassName}
			} else {
				_goalsExternal findIf {((_x select 0) == _goalClassName) && (_x select 3 == _goalSourceAI)}
			};
			if (_index != -1) then {
				_return = _goalsExternal select _index select 2;
			//} else {
				//OOP_WARNING_2("can't find external goal: %1, external goals: %2", _goalClassName, _goalsExternal);
			};
		};
		
		_return
	ENDMETHOD;
	
	/*
	Method: (static)allAgentsCompletedExternalGoal
	Returns true if all provided AI objects have completed an external goal.
	
	Parameters: _agents, _goalClassName, _goalSourceAI
	
	_agents - array of agent objects (Unit, Garrison, Group - must support getAI method)
	_goalClassName - <Goal> class name
	_source - string, source of the goal, or "" to ignore this field. If "" is provided, source field will be ignored.
	
	Returns: Bool
	*/
	public STATIC_METHOD(allAgentsCompletedExternalGoal)
		params [P_THISCLASS, P_ARRAY("_agents"), P_STRING("_goalClassName"), P_OOP_OBJECT("_goalSourceAI")];
		CALLSM4("AI_GOAP", "allAgentsHaveExternalGoalState", _agents, [ACTION_STATE_COMPLETED ARG -1], _goalClassName, _goalSourceAI)
		// OOP_INFO_2("allAgentsCompletedExternalGoal: %1, Source: %2", _goalClassName, _goalSourceAI);

		// pr _completedCount = ({
		// 	pr _AI = CALLM0(_x, "getAI");
		// 	pr _actionState = CALLM2(_AI, "getExternalGoalActionState", _goalClassName, _goalSourceAI);
		// 	// Either actions completed or goal didn't exist
		// 	pr _completed = (_actionState == ACTION_STATE_COMPLETED) || (_actionState == -1);
		// 	OOP_INFO_3("    AI: %1, State: %2, Completed: %3", _AI, _actionState, _completed );
		// 	_completed
		// } count _agents);

		// _completedCount == (count _agents)
	ENDMETHOD;

	/*
	Method: (static)allAgentsHaveExternalGoalState
	Returns true if all agents have one of the desired states for the specified external goal.

	Parameters: _agents, _desiredStates, _goalClassName, _goalSourceAI

	_agents - array of agent objects (Unit, Garrison, Group - must support getAI method)
	_desiredStates - array of desired states
	_goalClassName - <Goal> class name
	_source - string, source of the goal, or "" to ignore this field. If "" is provided, source field will be ignored.
	
	Returns: Bool
	*/
	public STATIC_METHOD(allAgentsHaveExternalGoalState)
		params [P_THISCLASS, P_ARRAY("_agents"), P_ARRAY("_desiredStates"), P_STRING("_goalClassName"), P_OOP_OBJECT("_goalSourceAI")];
		_agents findIf {
			pr _AI = CALLM0(_x, "getAI");
			pr _actionState = CALLM2(_AI, "getExternalGoalActionState", _goalClassName, _goalSourceAI);
			!(_actionState in _desiredStates)
		} == NOT_FOUND
	ENDMETHOD;

	/*
	Method: (static)anyAgentsHaveExternalGoalState
	Returns true if any agents have any of the desired states for the specified external goal.

	Parameters: _agents, _desiredStates, _goalClassName, _goalSourceAI

	_agents - array of agent objects (Unit, Garrison, Group - must support getAI method)
	_desiredStates - array of desired states
	_goalClassName - <Goal> class name
	_source - string, source of the goal, or "" to ignore this field. If "" is provided, source field will be ignored.
	
	Returns: Bool
	*/
	public STATIC_METHOD(anyAgentsHaveExternalGoalState)
		params [P_THISCLASS, P_ARRAY("_agents"), P_ARRAY("_desiredStates"), P_STRING("_goalClassName"), P_OOP_OBJECT("_goalSourceAI")];
		_agents findIf {
			pr _AI = CALLM0(_x, "getAI");
			pr _actionState = CALLM2(_AI, "getExternalGoalActionState", _goalClassName, _goalSourceAI);
			_actionState in _desiredStates
		} != NOT_FOUND
	ENDMETHOD;

	/*
	Method: (static)allAgentsHaveAndCompletedExternalGoal
	Returns true if all provided AI objects have completed an external goal.
	
	Parameters: _agents, _goalClassName, _goalSourceAI
	
	_agents - array of agent objects (Unit, Garrison, Group - must support getAI method)
	_goalClassName - <Goal> class name
	_source - string, source of the goal, or "" to ignore this field. If "" is provided, source field will be ignored.
	
	Returns: Bool
	*/
	public STATIC_METHOD(allAgentsCompletedExternalGoalRequired)
		params [P_THISCLASS, P_ARRAY("_agents"), P_STRING("_goalClassName"), P_OOP_OBJECT("_goalSourceAI")];
		CALLSM4("AI_GOAP", "allAgentsHaveExternalGoalState", _agents, [ACTION_STATE_COMPLETED], _goalClassName, _goalSourceAI)
	ENDMETHOD;

	/*
	Method: (static)anyAgentFailedExternalGoal
	Returns true if any agent has failed the external goal.
	
	Parameters: _agents, _goalClassName, _goalSourceAI
	
	_agents - array of agent objects (Unit, Garrison, Group - must support getAI method)
	_goalClassName - <Goal> class name
	_source - string, source of the goal, or "" to ignore this field. If "" is provided, source field will be ignored.
	
	Returns: Bool
	*/	
	public STATIC_METHOD(anyAgentFailedExternalGoal)
		params [P_THISCLASS, P_ARRAY("_agents"), P_OOP_OBJECT("_goalClassName"), P_OOP_OBJECT("_goalSourceAI")];
		CALLSM4("AI_GOAP", "anyAgentsHaveExternalGoalState", _agents, [ACTION_STATE_FAILED], _goalClassName, _goalSourceAI)
	ENDMETHOD;

	
	// ------------------------------------------------------------------------------------------------------
	// -------------------------------------------- A C T I O N S -------------------------------------------
	// ------------------------------------------------------------------------------------------------------
	
	// ----------------------------------------------------------------------
	// |                S E T   C U R R E N T   A C T I O N
	// |
	// ----------------------------------------------------------------------
	
	METHOD(setCurrentAction)
		params [P_THISOBJECT, P_OOP_OBJECT("_newAction")];
		
		// Make sure previous action is deleted
		pr _currentAction = T_GETV("currentAction");
		
		// Do we currently already have an action?
		if (_currentAction != "") then {
			CALLM0(_currentAction, "terminate");
			DELETE(_currentAction);
		};
		
		T_SETV("currentAction", _newAction);
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                G E T   C U R R E N T   A C T I O N
	// |
	// ----------------------------------------------------------------------
	

	public METHOD(getCurrentAction)
		params [P_THISOBJECT];
		T_GETV("currentAction")
	ENDMETHOD;
	

	// ----------------------------------------------------------------------
	// |            D E L E T E   C U R R E N T   A C T I O N
	// |
	// ----------------------------------------------------------------------
	
	METHOD(deleteCurrentAction)
		params [P_THISOBJECT];
		pr _currentAction = T_GETV("currentAction");
		if (_currentAction != "") then {
			pr _state = GETV(_currentAction, "state");
			OOP_INFO_2("DELETING CURRENT ACTION: %1, state: %2", _currentAction, _state);
		
			CALLM0(_currentAction, "terminate");
			DELETE(_currentAction);
			T_SETV("currentAction", "");
		};
	ENDMETHOD;
	
	
	// ----------------------------------------------------------------------
	// |            C R E A T E   A C T I O N S   F R O M   P L A N
	// |
	// ----------------------------------------------------------------------
	// Creates actions from plan generated by the planActions method	
	METHOD(createActionsFromPlan)
		params [P_THISOBJECT, P_ARRAY("_plan"), P_ARRAY("_wsGoal"), P_ARRAY("_goalParameters"), P_BOOL("_instant")];

		// Resolve parameters for all actions
		pr _parametersResolved = true;
		{
			_x params ["_precedence", "_actionClassName", "_parameters"];
			{
				_x params ["_tag", "_value", "_origin"];
				switch (_origin) do {
					// Take it from goal world state, value is ID
					case ORIGIN_GOAL_WS: {
						pr _valueFromWS = [_wsGoal, _value] call ws_getPropertyValue;
						_x set [1, _valueFromWS];
					};
					// Take it from goal parameter, valyue is tag
					case ORIGIN_GOAL_PARAMETER: {
						// Find goal parameter with given tag
						pr _id = _goalParameters findIf {(_x#0) == _value};
						if (_id == -1) then {
							// It might be valid in some cases, it's not an error
							_x set [1, nil]; // Action.getParameterValue will deal with nil value
							_parametersResolved = false;
							OOP_WARNING_2("Goal parameter with tag %1 was not found, action: %2", _value, _actionClassName);
							OOP_WARNING_1("  Plan: %1", _plan);
							OOP_WARNING_1("  Goal parameters: %1", _goalParameters);
						} else {
							_x set [1, _goalParameters#_id#1];
						};
					};
					// Do nothing, it's value already
					case ORIGIN_STATIC_VALUE: {};
					// WTF
					case ORIGIN_NONE: {
						OOP_ERROR_2("Parameter origin: none, action: %1, plan: %2", _actionClassName, _plan);
					};
					default {
						OOP_ERROR_2("Parameter origin: unknown, action: %1, plan: %2", _actionClassName, _plan);
					};
				};
			} forEach _parameters;
		} forEach _plan;

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
				if(_instant) then {
					if(CALLSM0(_actionClassName, "isNonInstant")) then {
						_instant = false;
					} else {
						_actionParameters = _actionParameters + [[TAG_INSTANT, true]];
					};
				};
				// Create an action
				pr _args = [_thisObject, _actionParameters];
				pr _action = NEW(_actionClassName, _args);
				
				// Add it to the subactions list
				CALLM1(_actionSerial, "addSubactionToBack", _action);
			} forEach _plan;

			// Return the serial action
			_actionSerial
		};
	ENDMETHOD;

	
	// Calculates a string, hash key for planner cache 
	STATIC_METHOD(calculatePlannerCacheKey)
		params [P_THISOBJECT, P_ARRAY("_currentWS"), P_ARRAY("_goalWS"), P_ARRAY("_possibleActions"), P_ARRAY("_goalParameters")];

		_goalParameters = +_goalParameters;
		_goalWS = +_goalWS;
		_currentWS = +_currentWS;

		{
			_x resize 2;
			_x params ["_tag", "_value"];
			// Values of these types must resolve to same key
			if (! (_value isEqualType false)) then { // in ["SCALAR", "ARRAY", "OBJECT", "GROUP", "LOCATION"]) then {
				_x set [1, false]; // Bool is very fast to stringify
			};
		} forEach _goalParameters;

		([_currentWS, _goalWS] call ws_getPlannerCacheKey) + (str _possibleActions) + (str _goalParameters);
	ENDMETHOD;
	
	
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

	#ifdef OFSTREAM_ENABLE
	#define ASTAR_LOG(text) (ofstream_new "A-star.rpt") ofstream_write text
	#else
	#define ASTAR_LOG(text)
	#endif
	FIX_LINE_NUMBERS()
	
	STATIC_METHOD(planActions)
		pr _paramsGood = params [P_THISCLASS, P_ARRAY("_currentWS"), P_ARRAY("_goalWS"), P_ARRAY("_possibleActions"), P_ARRAY("_goalParameters") ];

		/*
		if (!_paramsGood) then {
			DUMP_CALLSTACK;
		};
		*/
		
		#ifdef DEBUG_GOAP
		OOP_INFO_0("");
		OOP_INFO_0("[AI:AStar] Info: ---------- Starting A* ----------");
		OOP_INFO_1("[AI:AStar] Info: currentWS: %1", [_currentWS] call ws_toString);
		OOP_INFO_1("[AI:AStar] Info: goalWS:    %1", [_goalWS] call ws_toString);
		OOP_INFO_1("[AI:AStar] Info: goal parameters: %1", _goalParameters);
		OOP_INFO_1("[AI:AStar] Info: possible actions: %1", _possibleActions);

		
		#endif
		FIX_LINE_NUMBERS()

		// Try to perform lookup in cache
		#ifdef ASP_ENABLE
		pr _scopeLookup = createProfileScope "AI_GOAP_cacheLookup";
		#endif
		pr _cacheKey = CALLSM4("AI_GOAP", "calculatePlannerCacheKey", _currentWS, _goalWS, _possibleActions, _goalParameters);
		pr _cacheValue = gAIPlannerCache getVariable _cacheKey;
		if (!isNil "_cacheValue") exitWith {
			#ifdef DEBUG_GOAP
			AIPlannerCacheNHit = AIPlannerCacheNHit + 1;
			OOP_INFO_3("[AI:AStar] Cache  HIT, cache performance: miss: %1, hit: %2, ttl: %3", AIPlannerCacheNMiss, AIPlannerCacheNHit, AIPlannerCacheNMiss + AIPlannerCacheNHit);
			OOP_INFO_1("[AI:AStar] Info: Cached plan: %1", _cacheValue);
			#endif
			+_cacheValue; // Make a deep copy
		};

		#ifdef ASP_ENABLE
		_scopeLookup = nil;
		#endif

		#ifdef DEBUG_GOAP
		AIPlannerCacheNMiss = AIPlannerCacheNMiss+1;
		OOP_INFO_3("[AI:AStar] Cache MISS, cache performance: miss: %1, hit: %2, ttl: %3", AIPlannerCacheNMiss, AIPlannerCacheNHit, AIPlannerCacheNMiss + AIPlannerCacheNHit);
		#endif

		// Cache is missed, run the algorithm
		
		// Copy the array of possible actions becasue we are going to modify it
		pr _availableActions = +_possibleActions;

		pr _initialNumUnsatisfiedProps = [_goalWS, _currentWS] call ws_getNumUnsatisfiedProps;

		// We are already there!
		if(_initialNumUnsatisfiedProps == 0) exitWith { 
			#ifdef DEBUG_GOAP
			OOP_INFO_0("[AI:AStar] Info: No search required we are already at our goal!");
			#endif
			FIX_LINE_NUMBERS()

			pr _retValue = [true, []];

			// Add it to cache anyway
			gAIPlannerCache setVariable [_cacheKey, +_retValue];

			_retValue;
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
		while {count _openSet > 0 && _count < 500} do {
			
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
			#ifdef DEBUG_GOAP
				OOP_INFO_0("");
				OOP_INFO_1("[AI:AStar] Info: Step: %1,  Open set:", _count);
				// Print the open and closed set
				{
					pr _nodeString = CALLSM("AI_GOAP", "AStarNodeToString", [_x]);
					OOP_INFO_0("[AI:AStar]  " + _nodeString);
				} forEach _openSet;
				
				// Print the selected node
				pr _nodeString = CALLSM("AI_GOAP", "AStarNodeToString", [_node]);
				OOP_INFO_1("[AI:AStar] Info: Analyzing node: %1", _nodeString);
			#endif
			FIX_LINE_NUMBERS()
			
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
				#ifdef DEBUG_GOAP
					OOP_INFO_0("[AI:AStar] Info: Reached current state with path:");
				#endif
				FIX_LINE_NUMBERS()
				_foundPath = true;
				// Reconstruct path
				pr _n = _node;
				while {true} do {
					if (! ((_n select ASTAR_NODE_ID_ACTION) isEqualTo ASTAR_ACTION_DOES_NOT_EXIST)) then {
						pr _actionClassName = _n select ASTAR_NODE_ID_ACTION;
						pr _precedence = CALLSM0(_actionClassName, "getPrecedence");
						_path pushBack [_precedence, _actionClassName, _n select ASTAR_NODE_ID_ACTION_PARAMETERS];
						#ifdef DEBUG_GOAP
						OOP_INFO_2("  %1: %2 ->", count _path, _actionClassName);
						pr _wsStr = [_n select ASTAR_NODE_ID_WS] call ws_toString;
						OOP_INFO_1("     State :%1", _wsStr);
						OOP_INFO_1("     Params:%1", _n select ASTAR_NODE_ID_ACTION_PARAMETERS);
						#endif
						FIX_LINE_NUMBERS()
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
			#ifdef DEBUG_GOAP
				OOP_INFO_1("[AI:AStar] Info: Discovering neighbours:", _nodeString);
			#endif
			FIX_LINE_NUMBERS()
			
			{ // forEach _availableActions;
				pr _action = _x;
				//OOP_INFO_1("Analyzing action: %1", _action);
				pr _effects = GETSV(_x, "effects");
				pr _args = [[], []]; //
				
				// At this point we get static preconditions because action parameters are unknown
				// Properties that will be overwritten by getPreconditions must be set to some values to resolve conflicts!
				pr _preconditions = GETSV(_x, "preconditions");
				// Safety check
				pr _connected = if (!isNil "_preconditions") then { [_preconditions, _effects, _nodeWS] call ws_isActionSuitable; } else {
					OOP_WARNING_1(" preconditions of %1 are nil!", _action);
					false;
				};
				
				//OOP_INFO_1("  connected: %1", _connected);

				// If there is connection, create a new node
				if (_connected) then {
				
					// Array with parameters for this action we are currently considering
					pr _parameters = GETSV(_x, "parametersFromGoal");
					pr _parametersOptional = GETSV(_x, "parametersFromGoalOptional");
					if (isNil "_parameters") then {_parameters = [];} else {
						_parameters = +_parameters; // Make a deep copy
					};
					if (isNil "_parametersOptional") then {_parametersOptional = [];} else {
						_parametersOptional = +_parametersOptional;
					};
					_parametersOptional pushBack [TAG_INSTANT, TAG_INSTANT, ORIGIN_GOAL_PARAMETER];	// TAG_INSTANT can be received by all actions
					OOP_INFO_3("Action: %1, parameters: %2, optional: %3", _x, _parameters, _parametersOptional);
					
					// ----------------------------------------------------------------------------
					// Try to resolve action parameters
					// ----------------------------------------------------------------------------
					
					pr _parametersResolved = true;
					// Resolve required parameters which are derived from goal
					{ // foreach parameters of this action
						pr _tag = _x#0;
						// Find a parameter with the same tag in goal parameters
						pr _idSameTag = _goalParameters findIf {(_x select 0) == _tag};
						if (_idSameTag != -1) then {
							// Add reference to goal parameter to the action parameter
							_x set [1, _tag];
							_x set [2, ORIGIN_GOAL_PARAMETER];
						} else {
							// This parameter is required by action to be retrieved from a goal parameter
							// But it wasn't found in the goal parameter array
							// Print an error
							OOP_INFO_4("[AI:AStar] Warning: can't find a parameter for action: %1,  tag:  %2,  goal: %3,  goal parameters: %4",	_action, _tag, [_goalWS] call ws_toString, _goalParameters);
							_parametersResolved = false;
						};
					} forEach _parameters;

					// Resolve optional parameters
					if (_parametersResolved) then {
						{ // foreach parameters of this action
							pr _tag = _x#0;
							// Find a parameter with the same tag in goal parameters
							pr _idSameTag = _goalParameters findIf {(_x select 0) == _tag};
							if (_idSameTag != -1) then {
								// Add reference to goal parameter to the action parameter
								_x set [1, _tag];
								_x set [2, ORIGIN_GOAL_PARAMETER];
								_parameters pushBack (+_x); // Copy into parameters array
							};	// If it's not found, ignore it
						} forEach _parametersOptional;
					};

					// Have parameters from the goal been resolved so far, if they existed?
					if (_parametersResolved) then {
						// Resolve parameters which are passed from effects
						if (!([_effects, _parameters, _nodeWS] call ws_applyEffectsToParameters)) then {
							_parametersResolved = false;
						};
					};
					
					if (!_parametersResolved) then {
						OOP_INFO_1("[AI:AStar] Can't resolve all parameters for action: %1", _action);
					} else {
						#ifdef DEBUG_GOAP
						//	diag_log format ["[AI:AStar] Info: Connected world states: action: %1,  effects: %2,  WS:  %3", _x, [_effects] call ws_toString, [_nodeWS] call ws_toString];
						#endif
						FIX_LINE_NUMBERS()
						
						// ----------------------------------------------------------------------------
						// Find which node this action came from
						// ----------------------------------------------------------------------------
						
						// Calculate world state before executing this action
						// It depends on action effects, preconditions and world state of current node
						pr _WSBeforeAction = +_nodeWS;
						[_WSBeforeAction, _effects] call ws_substract;
						// Fully resolve preconditions since we now know all the parameters of this action
						pr _preconditions = CALLSM2(_x, "getPreconditions", _goalParameters, _parameters);
						[_WSBeforeAction, _preconditions] call ws_add;
						
						// Check if this world state is in close set already
						pr _possibleAction = _x;
						if ( (_closeSet findIf { /* ((_x select ASTAR_NODE_ID_ACTION) isEqualTo _possibleAction) && */ ((_x select ASTAR_NODE_ID_WS) isEqualTo _WSBeforeAction) }) != -1) then {
							// Print debug text
							#ifdef DEBUG_GOAP
								OOP_INFO_2("[AI:AStar]  Found in close set:  [ WS: %1  Action: %2]", [_WSBeforeAction] call ws_toString, _x);
							#endif
							FIX_LINE_NUMBERS()
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
							pr _cost = GETSV(_x, "cost");
							ASSERT_MSG(!(isNil "_cost"), "Action cost is nil!");
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
								#ifdef DEBUG_GOAP
									pr _nodeString = CALLSM("AI_GOAP", "AStarNodeToString", [_n]);
									OOP_INFO_0("[AI:AStar]  New node:            " + _nodeString);
								#endif
								FIX_LINE_NUMBERS()
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
									#ifdef DEBUG_GOAP
										pr _nodeString = CALLSM("AI_GOAP", "AStarNodeToString", [_nodeOpen]);
										//        "  Found in close set:  "
										OOP_INFO_1("[AI:AStar]  Updated in open set: %1", _nodeString);
									#endif
									FIX_LINE_NUMBERS()
								} else {
									
									// Print debug text
									#ifdef DEBUG_GOAP
										pr _nodeString = CALLSM("AI_GOAP", "AStarNodeToString", [_nodeOpen]);
										OOP_INFO_1("[AI:AStar]  Found in open set:   %1", _nodeString);
									#endif
									FIX_LINE_NUMBERS()
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
		//_path sort true; // Ascending
		
		#ifdef DEBUG_GOAP
			OOP_INFO_1("[AI:AStar] Info: Generated plan: %1", _path);
		#endif
		FIX_LINE_NUMBERS()
		
		pr _retValue = [_foundPath, _path];

		// Add to cache
		gAIPlannerCache setVariable [_cacheKey, +_retValue];

		// Return the reconstructed sorted path 
		_retValue
	ENDMETHOD;
	
	// Converts an A* node to string for debug purposes
	STATIC_METHOD(AStarNodeToString)
		params [P_THISCLASS, P_ARRAY("_node")];
		
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
	ENDMETHOD;
	
	
	// - - - - - - STORAGE - - - - -
	public override METHOD(postDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		//diag_log "AI_GOAP postDeserialize";

		// Call method of all base classes
		CALLCM("AI", _thisObject, "postDeserialize", [_storage]);

		// Restore variables
		T_SETV("currentAction", "");
		T_SETV("currentGoal", "");

		true
	ENDMETHOD;

	// - - - - - - - DEBUG UI - - - - - - - -
	// Returns array for debug UI
	METHOD(getDebugUIData)
		params [P_THISOBJECT];

		pr _a = [];												// Each + is data pushed to array

		// This agent info
		pr _agent = T_GETV("agent");
		pr _agentClass = GET_OBJECT_CLASS(_agent);
		switch (_agentClass) do {								// + Arma agent (object handle, group handle) or Garrison)
			case "Unit": {	_a pushBack CALLM0(_agent, "getObjectHandle"); };
			case "Group": {	_a pushBack CALLM0(_agent, "getGroupHandle"); };
			case "Garrison": { _a pushBack _agent; };
			case "Civilian": { _a pushBack CALLM0(_agent, "getObjectHandle"); };
			default { _a pushBack "ERROR"; };
		};
		_a pushBack _agent;										// + OOP agent
		_a pushBack GET_OBJECT_CLASS(_agent);					// + OOP agent class name

		// This object info
		_a pushBack _thisObject;								// + This Object
		_a pushBack GET_OBJECT_CLASS(_thisObject);				// + This object class name

		// World state
		pr _ws = T_GETV("worldState");
		if (isNil "_ws") then {
			_a pushBack [[], []];
		} else {
			_a pushBack _ws;									// + World State
		};

		// Goal info
		_a pushBack T_GETV("currentGoal");						// + Current goal
		_a pushBack T_GETV("currentGoalParameters");			// + Goal parameters

		// Action info
		pr _action = T_GETV("currentAction");
		pr _subaction = if(_action != NULL_OBJECT) then { CALLM0(_action, "getFrontSubaction") } else { NULL_OBJECT };
		pr _state = if(_subaction != NULL_OBJECT) then { GETV(_subaction, "state") } else { -1 };
		pr _actionClass = if(_action != NULL_OBJECT) then { GET_OBJECT_CLASS(_action) } else { "" };
		pr _subActionClass = if(_subaction != NULL_OBJECT) then { GET_OBJECT_CLASS(_subaction) } else { "" };
		[_goal, _actionClass, _subActionClass, _state];

		_a pushBack _action;									// + Action
		_a pushBack _actionClass;								// + Action class
		_a pushBack _subAction;									// + Subaction
		_a pushBack _subActionClass;							// + Subaction class
		_a pushBack _state;										// + Subaction state

		// Additional AI-specific variables
		pr _extraVarNames = T_CALLM0("getDebugUIVariableNames");
		pr _extraAIVariables = [];
		{
			_extraAIVariables pushBack [_x, T_GETV(_x)]; 
		} forEach _extraVarNames;
		_a pushBack _extraAIVariables;							// + Extra AI variables

		// Additional action-specific variables
		pr _extraSubactionVarNames = [];
		pr _extraSubactionVariables = [];
		if (!IS_NULL_OBJECT(_subAction)) then {
			_extraSubactionVarNames = CALLM0(_subAction, "getDebugUIVariableNames");
			_extraSubactionVarNames = ["AI", "state", "instant"] + _extraSubactionVarNames;
			{
				_extraSubactionVariables pushBack [_x, GETV(_subAction, _x)];
			} forEach _extraSubactionVarNames;
		};
		_a pushBack _extraSubactionVariables;						// + Extra Subaction variables

		// Return
		_a
	ENDMETHOD;

	public STATIC_METHOD(getObjectDebugUIData)

		params [P_THISCLASS, P_OBJECT("_object")];

		pr _unit = CALLSM1("Unit", "getUnitFromObjectHandle", _object);
		pr _civ = CALLSM1("Civilian", "getCivilianFromObjectHandle", _object);

		if (IS_NULL_OBJECT(_unit) && IS_NULL_OBJECT(_civ)) exitWith {
			[_object]	// Data is wrong, take back your object handle!
		};

		pr _unitOrCiv = if (IS_NULL_OBJECT(_unit)) then {
			_civ
		} else {
			_unit
		};
		pr _ai = CALLM0(_unitOrCiv, "getAI");
		if (IS_NULL_OBJECT(_ai)) exitWith {
			[_object]	// Data is wrong, take back your object handle!
		};

		pr _a = CALLM0(_ai, "getDebugUIData");
		_a // Return
	ENDMETHOD;

	public STATIC_METHOD(getGroupDebugUIData)
		params [P_THISCLASS, P_GROUP("_group")];

		pr _groupFound = CALLSM1("Group", "getGroupFromGroupHandle", _group);

		if (IS_NULL_OBJECT(_groupFound)) exitWith {
			[_group]	// Data is wrong, take back your group handle!
		};

		pr _ai = CALLM0(_groupFound, "getAI");
		if (IS_NULL_OBJECT(_ai)) exitWith {
			[_group]	// Data is wrong, take back your group handle!
		};

		pr _a = CALLM0(_ai, "getDebugUIData");
		_a // Return
	ENDMETHOD;

	// Takes object as parameter, returns object's garrison's data
	public STATIC_METHOD(getGarrisonDebugUIDataFromObject)
		params [P_THISCLASS, P_OBJECT("_object")];

		pr _unit = CALLSM1("Unit", "getUnitFromObjectHandle", _object);

		if (IS_NULL_OBJECT(_unit)) exitWith {
			[""]		// Data is wrong, take back your object handle!
		};

		pr _garrison = CALLM0(_unit, "getGarrison");

		if (IS_NULL_OBJECT(_garrison)) exitWith {
			[""]		// Unit has no garrison, not sure how it's possible
		};

		pr _ai = CALLM0(_garrison, "getAI");
		pr _a = CALLM0(_ai, "getDebugUIData");
		_a // Return
	ENDMETHOD;

	// Remote-executed on server from client
	public STATIC_METHOD(requestDebugUIData)
		params [P_THISCLASS, P_NUMBER("_clientOwner"), P_NUMBER("_requestType"), P_DYNAMIC("_target")];

		pr _data = switch (_requestType) do {
			case 0: {	// Unit
				CALLSM1("AI_GOAP", "getObjectDebugUIData", _target);
			};
			case 1: {	// Group
				CALLSM1("AI_GOAP", "getGroupDebugUIData", _target);
			};
			case 2: {
				CALLSM1("AI_GOAP", "getGarrisonDebugUIDataFromObject", _target);
			};
			default {[]}; // Error!
		};

		// Send data back to client
		REMOTE_EXEC_CALL_STATIC_METHOD("AIDebugUI", "receiveData", [_data], _clientOwner, false);
	ENDMETHOD;

	// Client has requested to halt this AI
	public STATIC_METHOD(requestHaltAI)
		params [P_THISCLASS, P_OOP_OBJECT("_ai")];
		if (!IS_NULL_OBJECT(_ai)) then {
			if (IS_OOP_OBJECT(_ai)) then{
				g_AI_GOAP_haltArray pushBackUnique _ai;
			};
		};
	ENDMETHOD;

ENDCLASS;