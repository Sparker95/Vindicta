/*
MessageReceiver class.
This class has capability to handle incoming messages.
Inherited classes must implement a getMessageLoop method which must return the MessageLoop object to which a message can be sent.

Author: Sparker
15.06.2018
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"

CLASS("MessageReceiver", "")

	METHOD("getMessageLoop") { //Derived classes must implement this method
		"ERROR_NO_MESSAGE_LOOP"
	} ENDMETHOD;
	
	/*
	Derived classes can implement this method like this:
	switch(_msgType) do {
		case "DO_STUFF": {...}
		case "DO_OTHER_STUFF" : {...}
		default: {return baseClass::handleMessage(msg);}
	}
	*/
	METHOD("handleMessage") { //Derived classes must implement this method
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		diag_log format ["[MessageReceiver] handleMessage: %1", _msg];
	} ENDMETHOD;
	
	// Posts a message into the MessageLoop of this object
	METHOD("postMessage") {
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		private _messageLoop = CALL_METHOD(_thisObject, "getMessageLoop", []);
		_msg set [MESSAGE_ID_DESTINATION, _thisObject]; //In case message sender forgot to set the destination
		private _msgID = CALL_METHOD(_messageLoop, "postMessage", [_msg]);
		//Return message ID value
		_msgID
	} ENDMETHOD;
	
	// Suspends until the message has been processed
	METHOD("waitUntilMessageDone") {
		params [ ["_thisObject", "", [""]] , ["_msgID", 0, [0]] ];
		private _messageLoop = CALL_METHOD(_thisObject, "getMessageLoop", []);
		waitUntil {
			//diag_log "Waiting...";
			CALL_METHOD(_messageLoop, "messageDone", [_msgID]);
		};
	} ENDMETHOD;
	
ENDCLASS;