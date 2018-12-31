#include "..\..\OOP_Light\OOP_Light.h"
#include "..\Action\Action.hpp"

/*
Class: Action.ActionCompositeSerial
A composite action, which executed its subactions in serial way, starting from FRONT of the action queue.

Based on source from "Programming Game AI by Example" by Mat Buckland: http://www.ai-junkie.com/books/toc_pgaibe.html

Author: Sparker 05.08.2018
*/

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
		
		// remove all completed actions from the front of the subaction list
		while {count _subactions > 0} do {
			private _subactionFront = _subactions select 0;
			private _state = GETV(_subactionFront, "state");
			if (_state != ACTION_STATE_COMPLETED /*&& _state != ACTION_STATE_FAILED*/) exitWith {};
			// The front action is in either COMPLETED or FAILED state, so we must delete it
			CALLM(_subactionFront, "terminate", []);
			DELETE(_subactionFront);
			_subactions deleteAt 0;
		};
		
		// if any subactions remain, process the one at the front of the list
		private _statusOfSubactions = ACTION_STATE_COMPLETED; // If there will be no subactions to process, return COMPLETED
		if (count _subactions > 0) then {
			private _subactionFront = _subactions select 0;
			
			// grab the status of the front-most subaction
			_statusOfSubactions = CALLM(_subactionFront, "process", []);
			
			// we have to test for the special case where the front-most subaction
		    // reports 'completed' *and* the subaction list contains additional actions.When
		    // this is the case, to ensure the parent keeps processing its subaction list
		    // we must return the 'active' status.
		    if (_statusOfSubactions == ACTION_STATE_COMPLETED && count _subactions > 1) then {
		    	_statusOfSubactions = ACTION_STATE_ACTIVE;
		    };
		};
		
		// return
		_statusOfSubactions
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

ENDCLASS;