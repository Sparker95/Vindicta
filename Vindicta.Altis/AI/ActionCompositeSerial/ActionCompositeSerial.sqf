#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#define OFSTREAM_FILE "AI.rpt"
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\Action\Action.hpp"

/*
Class: Action.ActionCompositeSerial
A composite action, which executed its subactions in serial way, starting from FRONT of the action queue.

Based on source from "Programming Game AI by Example" by Mat Buckland: http://www.ai-junkie.com/books/toc_pgaibe.html

Author: Sparker 05.08.2018
*/

#define pr private

CLASS("ActionCompositeSerial", "ActionComposite")

	// ----------------------------------------------------------------------
	// |                            P R O C E S S                           |
	// ----------------------------------------------------------------------
	/*
	Method: process
	If this composite action is not in failed state, it processes the front
	action which is not completed byt calling processSubaction method.
	You can override it to achieve custom behaviour.
	
	Returns: Number, current state, one of <ACTION_STATE>
	*/
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		private _state = GETV(_thisObject, "state");
		if (_state != ACTION_STATE_FAILED) then {
			_state = CALLM(_thisObject, "processSubactions", []);
		};
		SETV(_thisObject, "state", _state);
		
		// Return state
		_state
	} ENDMETHOD;
	
	
	// ----------------------------------------------------------------------
	// |                    P R O C E S S   S U B G O A L S                 |
	// ----------------------------------------------------------------------
	/*
	Method: processSubactions
	Removes completed subactions from FRONT of the queue, then calls
	process on non-completed actions.
	
	Returns: Number, current state of the front most action, one of <ACTION_STATE>
	*/
	METHOD("processSubactions") {
		params [["_thisObject", "", [""]]];
		private _subactions = GETV(_thisObject, "subactions");
		
		private _state = ACTION_STATE_COMPLETED;
		
		while {count _subactions > 0 && _state == ACTION_STATE_COMPLETED} do {
			scopeName "s0";

			private _subactionFront = _subactions select 0;
			_state = CALLM0(_subactionFront, "process");

			OOP_INFO_2("Processed subaction: %1, state: %2", _subactionFront, _state);

			// Terminate and delete a completed action
			if (_state == ACTION_STATE_COMPLETED) then  {
				// Action is completed, terminate and delete it
				CALLM(_subactionFront, "terminate", []);
				DELETE(_subactionFront);
				_subactions deleteAt 0;
			};
		};

		// return
		_state
	} ENDMETHOD;
	
	/*
	Method: terminate
	Calls "terminate" method of the front most action
	
	Returns: nil
	*/
	METHOD("terminate") {
		params ["_thisObject"];
		pr _subactions = T_GETV("subactions");
		
		// If there are still subactions left, terminate the front one
		if (count _subactions > 0) then {
			pr _a = _subactions select 0;
			CALLM0(_a, "terminate");
		};
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                      H A N D L E   M E S S A G E                   |
	// ----------------------------------------------------------------------
	/*
	Method: handleMessage
	Forwards the message to frontmost subaction
	
	Parameters: _msg
	
	_msg - <Message>
	
	Returns: Bool, true if message was handled
	*/
	METHOD("handleMessage") { //Derived classes must implement this method
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		// Forward the message to base class Action message handler
		private _msgHandled = CALL_CLASS_METHOD("Action", _thisObject, "handleMessage", [_msg]);
		// Did the default handler handle the message?
		if (!_msgHandled) then {
			// Forward the message to the frond subaction
			_msgHandled = CALLM(_thisObject, "forwardMessageToFrontSubaction", [_msg]);
		} else {
			// That was a strange message!
			_msgHandled = false; // message not handled
		};
		_msgHandled // return
	} ENDMETHOD;
	
	// -----------------------------------------------------------------------------------------------
	//                F O R W A R D   M E S S A G E   T O   F R O N T   S U B G O A L
	// -----------------------------------------------------------------------------------------------
	/*
	Method: forwardMessageToFrontSubaction
	passes the message to the action at the front of the queue
	
	Parameters: _msg
	
	_msg - <Message>
		
	Returns: Bool, true if message was handled
	*/
	METHOD("forwardMessageToFrontSubaction") {
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		private _subactions = GETV(_thisObject, "subactions");
		private _subactionFront = _subactions select 0;
		private _msgHandled = CALLM(_subactionFront, "handleMessage", [_msg]);
		_msgHandled
	} ENDMETHOD;
	
	
	
	/*
	Method: handleGroupsAdded
	Calls the same method of the front most action.
	*/
	METHOD("handleGroupsAdded") {
		params [["_thisObject", "", [""]], ["_groups", [], [[]]]];
		private _subactions = GETV(_thisObject, "subactions");
		CALLM1(_subactions select 0, "handleGroupsAdded", _groups);
	} ENDMETHOD;


	/*
	Method: handleGroupsRemoved
	Calls the same method of the front most action.
	*/
	METHOD("handleGroupsRemoved") {
		params [["_thisObject", "", [""]], ["_groups", [], [[]]]];
		private _subactions = GETV(_thisObject, "subactions");		
		CALLM1(_subactions select 0, "handleGroupsRemoved", _groups);
	} ENDMETHOD;
	
	/*
	Method: handleUnitsAdded
	Calls the same method of the front most action.
	*/
	
	METHOD("handleUnitsAdded") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]]];
		private _subactions = GETV(_thisObject, "subactions");		
		CALLM1(_subactions select 0, "handleUnitsAdded", _units);
	} ENDMETHOD;
	
	/*
	Method: handleUnitsRemoved
	Calls the same method of the front most action.
	*/
	
	METHOD("handleUnitsRemoved") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]]];
		private _subactions = GETV(_thisObject, "subactions");		
		CALLM1(_subactions select 0, "handleUnitsRemoved", _units);
	} ENDMETHOD;
	

ENDCLASS;