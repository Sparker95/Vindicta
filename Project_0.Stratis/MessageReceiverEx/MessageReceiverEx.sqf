#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"

/*
MessageReceiverEx class.
This is an enhanced message receiver. It provides several functions to aid in synchronization.
It is useful for objects which need some methods to be executed synchronously or asynchnonously in different situations.

Author: Sparker
16.07.2018
*/

#define pr private

CLASS("MessageReceiverEx", "MessageReceiver")

	// Overwrite the base class method to intercept messages to call methods
	// Messages with string type are special. The string type is the name of the method to execute
	// If message type is not string, handleMessageEx is called
	METHOD("handleMessage") {
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		private _msgType = _msg select MESSAGE_ID_TYPE; // Message type is the function name
		if (_msgType isEqualType "") then {
			_methodParams = _msg select MESSAGE_ID_DATA;
			private _return = CALL_METHOD(_thisObject, _msgType, _methodParams);
			// Did the method return anything?
			if (isNil "_return") then {	_return = 0; };
			_return
		} else {
			private _return = CALL_METHOD(_thisObject, "handleMessageEx", [_msg]);
			if (isNil "_return") then {	_return = 0; };
			_return
		};
	} ENDMETHOD;

	// Inherited classes can overwrite this method
	METHOD("handleMessageEx") {
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		diag_log format ["[MessageReceiverEx] handleMessageEx: %1", [_msg]];
		false
	} ENDMETHOD;

	// Post the method name into the message queue of the object's thread and exits immediately without waiting for it to handle the message
	// Returns: the ID of the posted message
	METHOD("postMethodAsync") {
		params [["_thisObject", "", [""]], ["_methodName", "", [""]], ["_methodParams", [], [[]]], ["_returnMsgID", false]];
		private _msg = MESSAGE_NEW();
		_msg set [MESSAGE_ID_TYPE, _methodName];
		_msg set [MESSAGE_ID_DATA, _methodParams]; // Array to return data to, method parameters
		private _return = CALLM2(_thisObject, "postMessage", _msg, _returnMsgID);
		
		// Return the message ID (if it was requested)
		_return
	} ENDMETHOD;
	
	// Post the method name into the message queue of the object's thread and waits until the message has been processed
	// Returns: the return value of the method which was called
	METHOD("postMethodSync") {
		params [["_thisObject", "", [""]], ["_methodName", "", [""]], ["_methodParams", [], [[]]] ];
		private _msg = MESSAGE_NEW();
		_msg set [MESSAGE_ID_TYPE, _methodName];
		private _returnArray = [];
		_msg set [MESSAGE_ID_DATA, _methodParams]; // Array to return data to, method parameters
		private _msgID = CALLM2(_thisObject, "postMessage", _msg, true);
		pr _return = CALLM1(_thisObject, "waitUntilMessageDone", _msgID);
		
		// Return whatever was returned by this object
		_return
	} ENDMETHOD;

ENDCLASS;