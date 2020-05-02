#define PROFILER_COUNTERS_ENABLE
#include "..\..\common.h"
#include "Action.hpp"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\parameterTags.hpp"

/*
Class: Action
Action represents something which an agent can do over some period of time.
Action can be in many states, see <ACTION_STATE>.

Based on source from "Programming Game AI by Example" by Mat Buckland: http://www.ai-junkie.com/books/toc_pgaibe.html
In the book such a class was called Goal, however in our mission we call Goal another thing (<Goal>).
I've added a few changes to Mat's architecture: in our mission there is a parallel composite Action.

There are also some methods which are needed for GOAP framework.

Note: If you need your Action to be compatible with GOAP action planner, then parameters must be an array
of [tag, value] where tag can be a string or number

Author: Sparker 05.08.2018
*/

#define pr private

#define OOP_CLASS_NAME Action
CLASS("Action", "MessageReceiverEx")

	/* Variable: AI
	Holds a reference to <AI> object which owns this action*/
	VARIABLE("AI"); // The AI object this action is attached to

	/* Variable: state
	State of this action. Can be one of <ACTION_STATE>*/
	VARIABLE("state"); // Status of this goal

	//VARIABLE("msgLoop"); // Message loop of this goal, if this goal needs to receive any messages
	/* Variable: timer
	holds a reference to timer which sends PROCESS messages to this Action, if it's autonomous */
	VARIABLE("timer"); // The timer which will be sending messages to this goal so that it calls its process method

	// Action should be performed instantly where appropriate
	// Used when garrisons spawn so they can immediately apply group and unit state for their current action
	VARIABLE("instant");

	// Variable: (static)cost
	STATIC_VARIABLE("cost"); // Cost of this action, if getCost returns a static number

	// ---- Inherited actions should have these set if planner is supposed to be used for them: ---

	// World state which must be satisfied for this action to start
	STATIC_VARIABLE("preconditions");

	// World state after the action ahs been executed
	STATIC_VARIABLE("effects");

	// Actions that are used by planner will be sorted by their precedence
	STATIC_VARIABLE("precedence");

	// STATIC_VARIABLE("numParameters"); // Amount of parameters this action requires // Maybe implement it later, not very important

	// Array with parameters which must be derived from goal parameters
	STATIC_VARIABLE("parameters");

	// Bool indicating how this action can behave during spawning.
	// This controls how planned actions get the "instant" parameter set in createActionsFromPlan.
	// No actions beyond a nonInstant action in a list of actions can be applied instantly.
	STATIC_VARIABLE("nonInstant");

	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	/*
	Method: new
	Creates this action.
	
	Parameters: _AI, _parameters
	
	_AI - <AI> of the agent
	_parameters - Array of parameters. See note above about parameters.
	*/
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		PROFILER_COUNTER_INC("Action");

		ASSERT_OBJECT_CLASS(_AI, "AI");

		T_SETV("AI", _AI);
		T_SETV("state", ACTION_STATE_INACTIVE); // Default state

		private _instant = CALLSM3("Action", "getParameterValue", _parameters, TAG_INSTANT, false);
		T_SETV("instant", _instant);
		
		T_SETV("timer", NULL_OBJECT); // No timer for this goal until it has been made autonomous
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	/*
	Method: delete
	*/
	METHOD(delete)
		params [P_THISOBJECT];
		
		PROFILER_COUNTER_DEC("Action");
		
		// Delete the timer of this goal if it exists
		private _timer = T_GETV("timer");
		if (_timer != NULL_OBJECT) then {
			DELETE(_timer);
		};
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T   M E S S A G E   L O O P                  |
	// |                                                                    |
	// | Must implement this since we inherit from MessageReceiver          |
	// ----------------------------------------------------------------------
	
	METHOD(getMessageLoop)
		params [P_THISOBJECT];
		CALLM0(T_GETV("AI"), "getMessageLoop");
	ENDMETHOD;

	/* protected virtual */ METHOD(setInstant)
		params [P_THISOBJECT, P_BOOL("_instant")];
		T_SETV("instant", _instant);
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                   S E T   A U T O N O M O U S                      |
	// ----------------------------------------------------------------------
	/*
	Method: setAutonomous
	Sets the goal to autonomous mode.
	Autonomous goals have a timer which generate a message to call the goal's process method.
	By default actions are processed in the process method of their AI (<AI.process>).
	
	Parameters: _timerPeriod
	
	_timerPeriod - period between <Action.process> calls in seconds
	
	Returns: nil
	*/
	METHOD(setAutonomous)
		params [P_THISOBJECT, ["_timerPeriod", 1, [1]] ];
		private _msg = MESSAGE_NEW();
		_msg set [MESSAGE_ID_DESTINATION, _thisObject];
		_msg set [MESSAGE_ID_SOURCE, ""];
		_msg set [MESSAGE_ID_DATA, 0];
		_msg set [MESSAGE_ID_TYPE, ACTION_MESSAGE_PROCESS];
		private _args = [_thisObject, _timerPeriod, _msg, gTimerServiceMain]; // message receiver, interval, message, timer service
		private _timer = NEW("Timer", _args);
		T_SETV("timer", _timer);
	ENDMETHOD;
	
	
	
	// ----------------------------------------------------------------------
	// |                      H A N D L E   M E S S A G E                   |
	// ----------------------------------------------------------------------
	/*
	Method: handleMessage
	See <MessageReceiver.handleMessage>.
	
	Accepts message types:
	
	ACTION_MESSAGE_PROCESS - will call its <Ation.process> method.
	
	ACTION_MESSAGE_DELETE - will delete this action.

	Returns: nil
	*/
	METHOD(handleMessageEx) //Derived classes must implement this method
		params [P_THISOBJECT, P_ARRAY("_msg")];
		private _msgType = _msg select MESSAGE_ID_TYPE;
		private _msgHandled = false;
		
		switch (_msgType) do {
			
			/*case MESSAGE_UNIT_DESTROYED: {
				diag_log "[Goal::handleMessage] Info: unit was destroyed";
				T_SETV("state", ACTION_STATE_FAILED);
				_msgHandled = true; // message handled
			};*/
		
			case ACTION_MESSAGE_PROCESS: {
				//diag_log format ["[Goal::handleMessage] Info: Calling process method...", _msg];
				T_CALLM0("process");
				_msgHandled = true; // message handled
			};
		
			case ACTION_MESSAGE_DELETE: {
				T_CALLM0("terminate");
				DELETE(_thisObject);
				_msgHandled = true; // message handled
			};
			
		};
		
		_msgHandled
	ENDMETHOD;
	
	
	
	// ----------------------------------------------------------------------
	// |                 A C T I V A T E   I F   I N A C T I V E            |
	// ----------------------------------------------------------------------
	/*
	Method: activateIfInactive
	Calls the Activate method of this action if it's inactive.
	
	Returns: Number, one of <ACTION_STATE>, the current state
	*/
	/* virtual */ METHOD(activateIfInactive)
		params [P_THISOBJECT];
		private _state = T_GETV("state");
		if (_state == ACTION_STATE_INACTIVE) then {
			private _instant = T_GETV("instant");
			_state = T_CALLM1("activate", _instant);
			// Clear the instant flag, an action can only be applied instantly once
			T_SETV("instant", false);
		};
		_state
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                 R E A C T I V A T E   I F   F A I L E D            |
	// ----------------------------------------------------------------------
	/*
	Method: reactivateIfFailed
	Calls the Activate method of this action if it's in failed state.
	
	Returns: Number, one of <ACTION_STATE>, the current state
	*/
	METHOD(reactivateIfFailed)
		params [P_THISOBJECT];
		private _state = T_GETV("state");
		if (_state == ACTION_STATE_FAILED) then {
			_state = T_CALLM0("activate");
			T_SETV("instant", false);
		};
		_state
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                      V I R T U A L   M E T H O D S                 |
	// ----------------------------------------------------------------------
	
	/*
	Method: activate
	Logic to run when the goal is activated. You should set the action state inside.
	Parameters: 
		_instant - The action should be completed instantly
	Returns: the current <ACTION_STATE>
	*/
	/* virtual */ METHOD(activate)
		params [P_THISOBJECT];
		// Set state
		T_SETV("state", ACTION_STATE_ACTIVE);
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
	ENDMETHOD;
	
	/*
	Method: process
	Logic to run each update-step. Remember to set the state variable of the action here as well!
	
	Returns: the current <ACTION_STATE>
	*/
	/* virtual */ METHOD(process)
		params [P_THISOBJECT];
		private _state = T_CALLM0("activateIfInactive");
		_state
	ENDMETHOD;
	
	/*
	Method: terminate
	logic to run when the goal is satisfied, or before it is deleted.
	
	Returns: nil
	*/
	/* virtual */ METHOD(terminate)ENDMETHOD;
	
	/*
	Method: addSubactionToFront
	an Action is atomic and cannot aggregate subactions yet we must implement
	this method to provide the uniform interface required for the action
	hierarchy.
	
	Returns: nil
	*/
	/* virtual */ METHOD(addSubactionToFront) diag_log "[Goal::addSubactionToFront] Error: can't add a subgoal to an atomic action!"; ENDMETHOD;
	
	/*
	Method: addSubactionToFront
	an Action is atomic and cannot aggregate subactions yet we must implement
	this method to provide the uniform interface required for the action
	hierarchy.
	
	Returns: nil
	*/
	/* virtual */ METHOD(addSubactionToBack) diag_log "[Goal::addSubactionToBack] Error: can't add a subgoal to an atomic action!"; ENDMETHOD;
	
	/*
	Method: getSubactions
	Returns the list of subactions (for debug purposes).
	
	
	Returns: []
	*/
	/* virtual */ METHOD(getSubactions) [] ENDMETHOD;
	
	
	/*
	Method: getFrontSubaction
	Returns this action. This function is here for common interface with ActionComposite.
	
	Returns: _thisObject
	*/
	
	METHOD(getFrontSubaction)
		params [P_THISOBJECT];
		_thisObject
	ENDMETHOD;
	
	
	
	// ----------------------------------------------------------------------
	// |                         S T A T E   C H E C K S                    |
	// |                                                                    |
	// | Methods for checking the state of the goal                         |
	// ----------------------------------------------------------------------
	/*
	Method: isCompleted
	
	Returns: true if action is in completed state, false otherwise
	*/
	METHOD(isCompleted)
		params [P_THISOBJECT];
		T_GETV("state") == ACTION_STATE_COMPLETED
	ENDMETHOD;
	
	/*
	Method: isActive
	
	Returns: true if action is in active state, false otherwise
	*/
	METHOD(isActive)
		params [P_THISOBJECT];
		T_GETV("state") == ACTION_STATE_ACTIVE
	ENDMETHOD;
	
	/*
	Method: isInactive
	
	Returns: true if action is in inactive state, false otherwise
	*/
	METHOD(isInactive)
		params [P_THISOBJECT];
		(T_GETV("state")) == ACTION_STATE_INACTIVE
	ENDMETHOD;
	
	/*
	Method: isFailed
	
	Returns: true if action is in failed state, false otherwise
	*/
	METHOD(isFailed)
		params [P_THISOBJECT];
		T_GETV("state") == ACTION_STATE_FAILED
	ENDMETHOD;
	
	
	
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                                G O A P
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		


	// ----------------------------------------------------------------------
	// |                         G E T   C O S T                            |
	// |                                                                    |
	// | Returns the cost of taking this action in current situation
	// | By default it returns the value of "cost" static variable
	// | You can redefine it for inherited action if the returned cost needs to depend on something
	// ----------------------------------------------------------------------
	
	/*
	Method: getCost
	Returns the cost of taking this action in current situation
	By default it returns the value of "cost" static variable
	You can redefine it for inherited action if the returned cost needs to depend on something
	
	Parameters: _AI, _wsStart, _wsEnd
	
	_AI - the <AI> object
	_wsStart - the start <WorldState>
	_wsEnd - the end <WorldState>
	
	Returns: Number
	*/
	STATIC_METHOD(getCost)
		//params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_wsStart"), P_ARRAY("_wsEnd")];
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		pr _cost = GET_STATIC_VAR(_thisClass, "cost");
		//if (isNil "_cost") then {
		//	0
		//} else {
			_cost
		//};
	ENDMETHOD;
	
	
	// ----------------------------------------------------------------------
	//                 G E T   P R E C O N D I T I O N S
	// ----------------------------------------------------------------------
	/*
	Method: getPreconditions
	Returns preconditions of this action depending on parameters
	By default it tries to apply parameters to preconditions, if preconditions reference any parameters
	
	Warning:If an action must provide preconditions which can't be copied from goal parameters, it must re-implement this method
	
	Parameters: _goalParameters, _actionParameters
	
	_goalParameters - parameters of the <Goal> for which this action is considered
	_actionParameters - parameters of this action resolved by the action planner
	_c -
	
	Returns: <WorldState>
	*/
	STATIC_METHOD(getPreconditions)
		params [P_THISCLASS, P_ARRAY("_goalParameters"), P_ARRAY("_actionParameters")];

		pr _wsPre = GET_STATIC_VAR(_thisClass, "preconditions");
		//[_wsPre, _goalParameters, _actionParameters] call ws_applyParametersToPreconditions;
		_wsPre
	ENDMETHOD;
	
	
	// ----------------------------------------------------------------------
	// |                         G E T   P R E C E D E N C E                |
	// |                                                                    |
	// ----------------------------------------------------------------------
	
	/*
	Method: getPrecedence
	Returns the precedence of this action.
	Actions executed first should have lower precedence.
	Precedence is only needed for actions that are used by planner.
	
	Returns: Number
	*/
	STATIC_METHOD(getPrecedence)
		params [P_THISCLASS];
		
		pr _precedence = GET_STATIC_VAR(_thisClass, "precedence");
		
		//if (isNil "_precedence") then {
		//	0
		//} else {
			_precedence
		//};
	ENDMETHOD;
	
	STATIC_METHOD(isNonInstant)
		params [P_THISCLASS];
		
		pr _nonInstant = GET_STATIC_VAR(_thisClass, "nonInstant");
		
		if (isNil "_nonInstant") then {
			false
		} else {
			_nonInstant
		};
	ENDMETHOD;

	/*
	Method: (static)getParameterValue
	Takes an array with parameters and returns value of parameter with given tag, or nil if such a parameter was not found.
	If the parameter is not found, it will diag_log an error message.
	
	Parameters: _parameters, _tag
	
	_parameters - array with parameters
	_tag - Number or String, parameter tag
	_showError - Bool, default true, will show error if parameter with given tag is not found
	
	Returns: anything
	*/
	STATIC_METHOD(getParameterValue)
		params [P_THISCLASS, P_ARRAY("_parameters"), ["_tag", "", ["", 0]], P_DYNAMIC("_default")];
		private _index = _parameters findif { _x select 0 == _tag };
		private _val = if(_index == NOT_FOUND) then { _default } else { (_parameters#_index)#1 };
		_val = if(isNil "_val") then { _default } else { _val };
		if (isNil "_val") then {
			OOP_INFO_3("[%1::getParameterValue] Error: parameter with tag %2 was not found in parameters array: %3", _thisClass, _tag, _parameters);
			nil
		} else {
			_val
		}
	ENDMETHOD;
	
	// Merge _additional parameters into _base parameters, leaving any existing values unchanged
	STATIC_METHOD(mergeParameterValues)
		params [P_THISCLASS, P_ARRAY("_base"), P_ARRAY("_additional")];
		{
			_x params ["_tag", "_value"];
			private _idx = _base findIf { _x select 0 == _tag };
			if(_idx == -1) then {
				// Append new value
				_base pushBack _x;
			};
		} forEach _additional;
	ENDMETHOD;
	



	// Virtual methods for hierarchy compatibility, handle units/groups added/removed

	/*
	Method: handleGroupsAdded
	Override in your action to perform special handling of what happens when groups are added while your action is running.
	By default it doesn't do anything.
	
	Parameters: _groups
	
	_groups - Array of <Group>
	
	Returns: nil
	*/
	METHOD(handleGroupsAdded)
		params [P_THISOBJECT, P_ARRAY("_groups")];
		
		nil
	ENDMETHOD;


	/*
	Method: handleGroupsRemoved
	Override in your action to perform special handling of what happens when groups are removed while your action is running.
	By default it doesn't do anything.
	
	Parameters: _groups
	
	_groups - Array of <Group>
	
	Returns: nil
	*/
	METHOD(handleGroupsRemoved)
		params [P_THISOBJECT, P_ARRAY("_groups")];
		
		nil
	ENDMETHOD;
	
	
	/*
	Method: handleUnitsRemoved
	Handles what happens when units get removed from their garrison, for instance when they gets destroyed, while this action is running.
	
	Access: internal
	
	Parameters: _units
	
	_units - Array of <Unit> objects
	
	Returns: nil
	*/
	METHOD(handleUnitsRemoved)
		params [P_THISOBJECT, P_ARRAY("_units")];
		
		nil
	ENDMETHOD;
	
	/*
	Method: handleUnitsAdded
	Handles what happens when units get added to a garrison while this action is running.
	
	Access: internal
	
	Parameters: _unit
	
	_units - Array of <Unit> objects
	
	Returns: nil
	*/
	METHOD(handleUnitsAdded)
		params [P_THISOBJECT, P_ARRAY("_units")];
		
		nil
	ENDMETHOD;

	// Helper functions
	STATIC_METHOD(_clearWaypoints)
		params [P_THISCLASS, P_GROUP("_hG")];
		// Add a dummy waypoint as deleting all waypoints results in a dummy one being created later which messes
		// with waypoint ordering
		if(isNull _hG) exitWith {
			// No group
		};
		//private _pos = position leader _hG;
		while { count waypoints _hG > 0 } do {
			deleteWaypoint [_hG, 0];
		};
		// private _wp = [_hG, 0];
		// _hG setCurrentWaypoint _wp;
		// _wp setWPPos _pos;
		// _wp setWaypointCompletionRadius 30;
		// _wp setWaypointType "MOVE";
		// _wp setWaypointFormation "NO CHANGE";
		// _wp setWaypointCombatMode "NO CHANGE";
		// _wp setWaypointBehaviour "UNCHANGED";
		// _wp setWaypointSpeed "UNCHANGED";
		// _wp setWaypointScript  "";

	ENDMETHOD;
	
	STATIC_METHOD(_regroup)
		params [P_THISCLASS, P_GROUP("_hG")];
		if(isNull _hG) exitWith {
			// No group
		};
		{ _x stop false; _x doFollow leader _hG; } forEach units _hG;
	ENDMETHOD;

	STATIC_METHOD(_teleport)
		params [P_THISCLASS, P_ARRAY("_units"), P_POSITION("_pos")];
		
		{
			private _unit = _x;
			private _hO = CALLM0(_unit, "getObjectHandle");
			if(isNull _hO) exitWith {
				// Can't teleport without a handle
			};

			if(_hO distance2D _pos < 25) exitWith {
				// Don't teleport if we are already almost there, its too risky
			};

			switch true do {
				// dismounted inf
				case (CALLM0(_unit, "isInfantry") && vehicle _hO == _hO): {
					private _tgtPos = [_pos, 0, 25, 0, 0, 2, 0, [], [_pos, _pos]] call BIS_fnc_findSafePos;
					_hO setVehiclePosition  [_tgtPos, [], 5, "CAN_COLLIDE"];
					//_hO setPos _tgtPos;
				};
				// vehicle
				case (CALLM0(_unit, "isVehicle")): {
					// Blacklist nearby vehicles
					private _tgtPos = [_pos, 0, 25, 7, 0, 0.5, 0, [], [_pos, _pos]] call BIS_fnc_findSafePos;
					// _hO allowDamage false;
					// _hO hideObjectGlobal true;
					// _hO setVariable ["vin_allow_damage_at", TIME_NOW + 5];

					// private _epeHandle = [_hO, "EpeContactStart", {
					// 	params ["_object1", "_object2", "_selection1", "_selection2", "_force"];
					// 	_thisArgs params ["_pos"];
					// 	if(_force > 10) then {
					// 		// Spawned unsafely, so try again
					// 		_object2 allowDamage false;
					// 		CRITICAL_SECTION {
					// 			if(_object2 getVariable ["vin_allow_damage_at", 0] == 0) then {
					// 				_object2 spawn {
					// 					waitUntil {
					// 						sleep 1;
					// 						TIME_NOW > _this getVariable ["vin_allow_damage_at", 0]
					// 					};
					// 					sleep 5; 
					// 					_this allowDamage true;
					// 					_this setVariable ["vin_allow_damage_at", nil];
					// 				};
					// 			};
					// 			_object2 setVariable ["vin_allow_damage_at", TIME_NOW + 5];
					// 		};
					// 		private _tgtPos = [_pos, 0, 25, 7, 0, 0.5, 0, [], [_pos, _pos]] call BIS_fnc_findSafePos;
					// 		_object1 setVehiclePosition  [_tgtPos, [], 5];
					// 	};
					// }, [_pos]] call CBA_fnc_addBISEventHandler;

					// [_hO, _epeHandle] spawn {
					// 	params ["_hO", "_epeHandle"];
					// 	waitUntil {
					// 		sleep 1;
					// 		TIME_NOW > _hO getVariable ["vin_allow_damage_at", 0]
					// 	};
					// 	_hO allowDamage true; 
					// 	_hO hideObjectGlobal false;
					// 	_hO setVariable ["vin_allow_damage_at", nil];
					// 	_hO removeEventHandler ["EpeContactStart", _epeHandle];
					// };
					// _hO setVehiclePosition  [_tgtPos, [], 5];
				};
			};
		} forEach _units;
	ENDMETHOD;


	// Debug
	// Returns array of class-specific additional variable names to be transmitted to debug UI
	// Override to show debug data in debug UI for specific class
	/* virtual */ METHOD(getDebugUIVariableNames)
		[]
	ENDMETHOD;

ENDCLASS;