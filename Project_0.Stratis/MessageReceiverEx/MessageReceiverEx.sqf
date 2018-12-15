/*
MessageReceiverEx class.
This is an enhanced message receiver. It provides several functions to aid in synchronization.
It is useful for objects which need some methods to be executed synchronously or asynchnonously in different situations.

Author: Sparker
16.07.2018
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"

CLASS("MessageReceiverEx", "MessageReceiver")

	// Overwrite the base class method to intercept messages to call methods
	// Messages with string type are special. The string type is the name of the method to execute
	// If message type is not string, handleMessageEx is called
	METHOD("handleMessage") {
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		private _msgType = _msg select MESSAGE_ID_TYPE; // Message type is the function name
		if (_msgType isEqualType "") then {
			private _msgData = _msg select MESSAGE_ID_DATA;
			_msgData params ["_returnArray", "_methodParams"]; // Array where we write the result of the method call, Parameters to pass to the method
			private _return = CALL_METHOD(_thisObject, _msgType, _methodParams);
			// Did the method return anything?
			if (!isNil "_return") then {
				_returnArray set [0, _return];
			};
		} else {
			CALL_METHOD(_thisObject, "handleMessageEx", [_msg]);
		};
	} ENDMETHOD;

	// Inherited classes can overwrite this method
	METHOD("handleMessageEx") {
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		diag_log format ["[MessageReceiverEx] handleMessageEx: %1", [_msg]];
	} ENDMETHOD;

	// Post the method name into the message queue of the object's thread and exits immediately without waiting for it to handle the message
	// Returns: the ID of the posted message
	METHOD("postMethodAsync") {
		params [["_thisObject", "", [""]], ["_methodName", "", [""]], ["_methodParams", [], [[]]], ["_returnArray", []]];
		private _msg = MESSAGE_NEW();
		_msg set [MESSAGE_ID_TYPE, _methodName];
		_msg set [MESSAGE_ID_DATA, [_returnArray, _methodParams]]; // Array to return data to, method parameters
		private _return = CALL_METHOD(_thisObject, "postMessage", [_msg]);
		// Return the message ID
		_return
	} ENDMETHOD;
	
	// Post the method name into the message queue of the object's thread and waits until the message has been processed
	// Returns: the return value of the method which was called
	METHOD("postMethodSync") {
		params [["_thisObject", "", [""]], ["_methodName", "", [""]], ["_methodParams", [], [[]]] ];
		private _msg = MESSAGE_NEW();
		_msg set [MESSAGE_ID_TYPE, _methodName];
		private _returnArray = [];
		_msg set [MESSAGE_ID_DATA, [_returnArray, _methodParams]]; // Array to return data to, method parameters
		private _msgID = CALLM2(_thisObject, "postMessage", _msg, true);
		CALL_METHOD(_thisObject, "waitUntilMessageDone", [_msgID]);
		// Did the method return anything?
		if (count _returnArray > 0) then {
			_returnArray select 0; // Return the method return value
		};
	} ENDMETHOD;

ENDCLASS;