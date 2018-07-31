/*
DebugPrinter class is just a MessageReceiver for testing purposes. It simply prints out every received message.

Author: Sparker 31.07.2018
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"

CLASS("DebugPrinter", "MessageReceiver")

	VARIABLE("name");
	VARIABLE("msgLoop");
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
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
	} ENDMETHOD;

ENDCLASS;