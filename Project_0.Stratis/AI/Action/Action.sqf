#include "..\..\OOP_Light\OOP_Light.h"
#include "Action.hpp"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"

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

CLASS("Action", "MessageReceiver")

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
	
	// Variable: (static)cost
	STATIC_VARIABLE("cost"); // Cost of this action, if getCost returns a static number
	
	
	
	// ---- Inherited actions should have these set if planner is supposed to be used for them: ---
	
	// World state which must be satisfied for this action to start
	STATIC_VARIABLE("preconditions");
	
	// World state after the action ahs been executed
	STATIC_VARIABLE("effects");
	
	// STATIC_VARIABLE("numParameters"); // Amount of parameters this action requires // Maybe implement it later, not very important
	
	// Array with parameters which must be derived from goal parameters
	STATIC_VARIABLE("parameters");
	
	// ----------------------------------------------------------------------------------------------
	
		
	
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
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", []]];

		ASSERT_OBJECT_CLASS(_AI, "AI");

		SET_VAR(_thisObject, "AI", _AI);
		SET_VAR(_thisObject, "state", ACTION_STATE_INACTIVE); // Default state
		//pr _msgLoop = CALLM("AI", "getMessageLoop");
		//SETV(_thisObject, "msgLoop", _msgLoop);
		
		SETV(_thisObject, "timer", ""); // No timer for this goal until it has been made autonomous
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	/*
	Method: delete
	*/
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		
		// Delete the timer of this goal if it exists
		private _timer = GETV(_thisObject, "timer");
		if (_timer != "") then {
			DELETE(_timer);
		};
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T   M E S S A G E   L O O P                  |
	// |                                                                    |
	// | Must implement this since we inherit from MessageReceiver          |
	// ----------------------------------------------------------------------
	
	METHOD("getMessageLoop") {
		params [ ["_thisObject", "", [""]] ];
		pr _AI = GETV(_thisObject, "AI");
		pr _msgLoop = CALLM(_AI, "getMessageLoop", []);
		//diag_log format ["[Action:getMessageLoop] Action: %1, Returned message loop: %2", _thisObject, _msgLoop];		
		//ade_dumpCallstack;
		_msgLoop
	} ENDMETHOD;
	
	
	
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
	METHOD("setAutonomous") {
		params [["_thisObject", "", [""]], ["_timerPeriod", 1, [1]] ];
		private _msg = MESSAGE_NEW();
		_msg set [MESSAGE_ID_DESTINATION, _thisObject];
		_msg set [MESSAGE_ID_SOURCE, ""];
		_msg set [MESSAGE_ID_DATA, 0];
		_msg set [MESSAGE_ID_TYPE, ACTION_MESSAGE_PROCESS];
		private _args = [_thisObject, _timerPeriod, _msg, gTimerServiceMain]; // message receiver, interval, message, timer service
		private _timer = NEW("Timer", _args);
		SETV(_thisObject, "timer", _timer);
	} ENDMETHOD;
	
	
	
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
	METHOD("handleMessage") { //Derived classes must implement this method
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		private _msgType = _msg select MESSAGE_ID_TYPE;
		private _msgHandled = false;
		
		switch (_msgType) do {
			
			/*case MESSAGE_UNIT_DESTROYED: {
				diag_log "[Goal::handleMessage] Info: unit was destroyed";
				SETV(_thisObject, "state", ACTION_STATE_FAILED);
				_msgHandled = true; // message handled
			};*/
		
			case ACTION_MESSAGE_PROCESS: {
				//diag_log format ["[Goal::handleMessage] Info: Calling process method...", _msg];
				CALLM(_thisObject, "process", []);
				_msgHandled = true; // message handled
			};
		
			case ACTION_MESSAGE_DELETE: {
				CALLM(_thisObject, "terminate", []);
				DELETE(_thisObject);
				_msgHandled = true; // message handled
			};
			
		};
		
		_msgHandled
	} ENDMETHOD;
	
	
	
	// ----------------------------------------------------------------------
	// |                 A C T I V A T E   I F   I N A C T I V E            |
	// ----------------------------------------------------------------------
	/*
	Method: activateIfInactive
	Calls the Activate method of this action if it's inactive.
	
	Returns: Number, one of <ACTION_STATE>, the current state
	*/
	METHOD("activateIfInactive") {
		params [["_thisObject", "", [""]]];
		private _state = GETV(_thisObject, "state");
		if (_state == ACTION_STATE_INACTIVE) then {
			_state = CALLM(_thisObject, "activate", []);
		};
		_state
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                 R E A C T I V A T E   I F   F A I L E D            |
	// ----------------------------------------------------------------------
		/*
	Method: reactivateIfFailed
	Calls the Activate method of this action if it's in failed state.
	
	Returns: Number, one of <ACTION_STATE>, the current state
	*/
	METHOD("reactivateIfFailed") {
		params [["_thisObject", "", [""]]];
		private _state = GETV(_thisObject, "state");
		if (_state == ACTION_STATE_FAILED) then {
			_state = CALLM(_thisObject, "activate", []);
		};
		_state
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                      V I R T U A L   M E T H O D S                 |
	// ----------------------------------------------------------------------
	
	/*
	Method: activate
	Logic to run when the goal is activated. You should set the action state inside.
	
	Returns: the current <ACTION_STATE>
	*/
	/* virtual */ METHOD("activate") {} ENDMETHOD;
	
	/*
	Method: process
	Logic to run each update-step. Remember to set the state variable of the action here as well!
	
	Returns: the current <ACTION_STATE>
	*/
	/* virtual */ METHOD("process") {} ENDMETHOD;
	
	/*
	Method: terminate
	logic to run when the goal is satisfied, or before it is deleted.
	
	Returns: nil
	*/
	/* virtual */ METHOD("terminate") {} ENDMETHOD; 
	
	/*
	Method: addSubactionToFront
	an Action is atomic and cannot aggregate subactions yet we must implement
	this method to provide the uniform interface required for the action
	hierarchy.
	
	Returns: nil
	*/
	/* virtual */ METHOD("addSubactionToFront") { diag_log "[Goal::addSubactionToFront] Error: can't add a subgoal to an atomic action!"; } ENDMETHOD;
	
	/*
	Method: addSubactionToFront
	an Action is atomic and cannot aggregate subactions yet we must implement
	this method to provide the uniform interface required for the action
	hierarchy.
	
	Returns: nil
	*/
	/* virtual */ METHOD("addSubactionToBack") { diag_log "[Goal::addSubactionToBack] Error: can't add a subgoal to an atomic action!"; } ENDMETHOD;
	
	/*
	Method: getSubactions
	Returns the list of subactions (for debug purposes).
	
	
	Returns: []
	*/
	/* virtual */ METHOD("getSubactions") { [] } ENDMETHOD;
	
	
	
	
	
	
	
	// ----------------------------------------------------------------------
	// |                         S T A T E   C H E C K S                    |
	// |                                                                    |
	// | Methods for checking the state of the goal                         |
	// ----------------------------------------------------------------------
	/*
	Method: isCompleted
	
	Returns: true if action is in completed state, false otherwise
	*/
	METHOD("isCompleted") {
		params [ ["_thisObject", "", [""]] ];
		private _state = GETV(_thisObject, "state"); _state == ACTION_STATE_COMPLETED
	} ENDMETHOD;
	
	/*
	Method: isActive
	
	Returns: true if action is in active state, false otherwise
	*/
	METHOD("isActive") {
		params [["_thisObject", "", [""]]];
		(GETV(_thisObject, "state")) == ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	/*
	Method: isInactive
	
	Returns: true if action is in inactive state, false otherwise
	*/
	METHOD("isInactive") {
		params [["_thisObject", "", [""]]];
		(GETV(_thisObject, "state")) == ACTION_STATE_INACTIVE
	} ENDMETHOD;
	
	/*
	Method: isFailed
	
	Returns: true if action is in failed state, false otherwise
	*/
	METHOD("isFailed") {
		params [["_thisObject", "", [""]]];
		(GETV(_thisObject, "state")) == ACTION_STATE_COMPLETED
	} ENDMETHOD;
	
	
	
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
	STATIC_METHOD("getCost") {
		//params [ ["_thisClass", "", [""]], ["_AI", "", [""]], ["_wsStart", [], [[]]], ["_wsEnd", [], [[]]]];
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];
		
		pr _cost = GET_STATIC_VAR(_thisClass, "cost");
		// Return static cost
		_cost
	} ENDMETHOD;
	
	
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
	STATIC_METHOD("getPreconditions") {
		params [ ["_thisClass", "", [""]], ["_goalParameters", [], [[]]], ["_actionParameters", [], [[]]]];
		
		pr _wsPre = GET_STATIC_VAR(_thisClass, "preconditions");
		//[_wsPre, _goalParameters, _actionParameters] call ws_applyParametersToPreconditions;
		
		_wsPre		
	} ENDMETHOD;
	
	/*
	Method: (static)getParameterValue
	Takes an array with parameters and returns value of parameter with given tag, or nil if such a parameter was not found.
	If the parameter is not found, it will diag_log an error message.
	
	Parameters: _parameters, _tag
	
	_parameters - array with parameters
	_tag - Number or String, parameter tag
	
	Returns: anything
	*/
	STATIC_METHOD("getParameterValue") {
		params [ ["_thisClass", "", [""]], ["_parameters", [], [[]]], ["_tag", "", ["", 0]]];
		pr _index = _parameters findif {_x select 0 == _tag};
		if (_index == -1) then {
			diag_log format ["[%1::] Error: parameter with tag %2 was not found in parameters array: %3", _thisClass, _tag, _parameters];
			nil
		} else {
			(_parameters select _index) select 1
		};
	} ENDMETHOD;
	
ENDCLASS;