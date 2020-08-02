#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#define OFSTREAM_FILE "AI.rpt"
#include "..\..\common.h"
#include "..\Action\Action.hpp"

/*
Class: Action.ActionCompositeSerial
A composite action, which executed its subactions in serial way, starting from FRONT of the action queue.

Based on source from "Programming Game AI by Example" by Mat Buckland: http://www.ai-junkie.com/books/toc_pgaibe.html

Author: Sparker 05.08.2018
*/

#define pr private

#define OOP_CLASS_NAME ActionCompositeSerial
CLASS("ActionCompositeSerial", "ActionComposite")

	public override METHOD(process)
		params [P_THISOBJECT];
		private _state = T_GETV("state");
		if (_state != ACTION_STATE_FAILED) then {
			_state = T_CALLM0("processSubactions");
		};
		T_SETV("state", _state);
		
		// Return state
		_state
	ENDMETHOD;

	/*
	Method: processSubactions
	Removes completed subactions from FRONT of the queue, then calls
	process on non-completed actions.
	
	Returns: Number, current state of the front most action, one of <ACTION_STATE>
	*/
	METHOD(processSubactions)
		params [P_THISOBJECT];
		private _subactions = T_GETV("subactions");
		
		private _state = ACTION_STATE_COMPLETED;
		
		while {count _subactions > 0 && _state == ACTION_STATE_COMPLETED} do {
			scopeName "s0";

			private _subactionFront = _subactions select 0;
			_state = CALLM0(_subactionFront, "process");

			CALLM1(_subactionFront, "setInstant", false);

			OOP_INFO_2("Processed subaction: %1, state: %2", _subactionFront, _state);

			// Terminate and delete a completed action
			if (_state == ACTION_STATE_COMPLETED) then  {
				// Action is completed, terminate and delete it
				CALLM0(_subactionFront, "terminate");
				DELETE(_subactionFront);
				_subactions deleteAt 0;
			};
		};

		// return
		_state
	ENDMETHOD;

	public override METHOD(terminate)
		params [P_THISOBJECT];
		pr _subactions = T_GETV("subactions");
		
		// If there are still subactions left, terminate the front one
		if (count _subactions > 0) then {
			pr _a = _subactions select 0;
			CALLM0(_a, "terminate");
		};
	ENDMETHOD;

	public override METHOD(handleMessage)
		params [P_THISOBJECT, P_ARRAY("_msg") ];

		// Forward the message to base class Action message handler
		private _msgHandled = CALLCM("Action", _thisObject, "handleMessage", [_msg]);
		// Did the default handler handle the message?
		if (!_msgHandled) then {
			// Forward the message to the frond subaction
			_msgHandled = T_CALLM("forwardMessageToFrontSubaction", [_msg]);
		} else {
			// That was a strange message!
			_msgHandled = false; // message not handled
		};
		_msgHandled // return
	ENDMETHOD;
	
	/*
	Method: forwardMessageToFrontSubaction
	passes the message to the action at the front of the queue
	
	Parameters: _msg
	
	_msg - <Message>
		
	Returns: Bool, true if message was handled
	*/
	/* private */ METHOD(forwardMessageToFrontSubaction)
		params [P_THISOBJECT, P_ARRAY("_msg") ];
		private _subactions = T_GETV("subactions");
		private _subactionFront = _subactions select 0;
		private _msgHandled = CALLM(_subactionFront, "handleMessage", [_msg]);
		_msgHandled
	ENDMETHOD;

	public override METHOD(handleGroupsAdded)
		params [P_THISOBJECT, P_ARRAY("_groups")];
		private _subactions = T_GETV("subactions");
		CALLM1(_subactions select 0, "handleGroupsAdded", _groups);
	ENDMETHOD;

	public override METHOD(handleGroupsRemoved)
		params [P_THISOBJECT, P_ARRAY("_groups")];
		private _subactions = T_GETV("subactions");
		CALLM1(_subactions select 0, "handleGroupsRemoved", _groups);
	ENDMETHOD;

	public override METHOD(handleUnitsAdded)
		params [P_THISOBJECT, P_ARRAY("_units")];
		private _subactions = T_GETV("subactions");
		CALLM1(_subactions select 0, "handleUnitsAdded", _units);
	ENDMETHOD;

	public override METHOD(handleUnitsRemoved)
		params [P_THISOBJECT, P_ARRAY("_units")];
		private _subactions = T_GETV("subactions");
		CALLM1(_subactions select 0, "handleUnitsRemoved", _units);
	ENDMETHOD;
	

ENDCLASS;