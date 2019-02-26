#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"

/*
Class: MessageReceiver.DebugPrinter
DebugPrinter class is just a MessageReceiver for testing purposes. It simply prints out every received message.
It can also be passed to another machine through <MessageReceiver.setOwner> method.

Author: Sparker 31.07.2018
*/

CLASS("DebugPrinter", "MessageReceiver");

	VARIABLE("name");
	VARIABLE("msgLoop");

	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	/*
	Method: new

	Parameters: _msgLoop

	_msgLoop - <MessageLoop> this object will be attached to.

	Returns: nil
	*/
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_name", "", [""]], ["_msgLoop", "", [""] ] ];
		SET_VAR(_thisObject, "name", _name);
		SET_VAR(_thisObject, "msgLoop", _msgLoop);
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------

	METHOD("delete") {
		params [["_thisObject", "", [""]]];
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                  G E T   M E S S A G E   L O O P                   |
	// ----------------------------------------------------------------------

	METHOD("getMessageLoop") { //Derived classes must implement this method
		params [["_thisObject", "", [""]]];
		private _return = GET_VAR(_thisObject, "msgLoop");
		_return
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                    H A N D L E   M E S S A G E                     |
	// ----------------------------------------------------------------------

	METHOD("handleMessage") {
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		diag_log format ["[DebugPrinter] Info: %1: %2 has received a message: type: %3, data: %4",
			_thisObject, GET_VAR(_thisObject, "name"), _msg select MESSAGE_ID_TYPE, _msg select MESSAGE_ID_DATA];
		// Returns the data field
		_msg select MESSAGE_ID_DATA
	} ENDMETHOD;


	// Change ownership


		// Must return a single value which can be deserialized to restore value of an object
	/* virtual */ METHOD("serialize") {
		params [["_thisObject", "", [""]]];
		private _data = [GETV(_thisObject, "name"), GETV(_thisObject, "msgLoop")];
		_data
	} ENDMETHOD;

	// Takes the output of deserialize and restores values of an object
	/* virtual */ METHOD("deserialize") {
		params [["_thisObject", "", [""]], "_serialData"];
		_serialData params ["_name", "_msgLoop"];
		SETV(_thisObject, "name", _serialData);
		SETV(_thisObject, "msgLoop", _msgLoop);
	} ENDMETHOD;

	// If your class has objects that must be transfered through the same mechanism, you must handle transfer of ownership of such objects here
	// Must return true if all objects have been successfully transfered and return false otherwise
	// You can also clear unneeded variables of this object here
	/* virtual */ METHOD("transferOwnership") {
		true
	} ENDMETHOD;

ENDCLASS;
