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

	METHOD("getMessageLoop") { //Derived classes must implement this method if they need to receive messages
		""
	} ENDMETHOD;
	
	// Delete method must be called by the thread(message loop) which owns this object
	METHOD("delete") {
		params [ ["_thisObject", "", [""]] ];
		private _msgLoop = CALLM(_thisObject, "getMessageLoop", []);
		// Delete all remaining messages directed to this object to make sure they will not be handled after the object is deleted
		CALLM(_msgLoop, "deleteReceiverMessages", [_thisObject]);
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
		// Please leave your message ...
		diag_log format ["[MessageReceiver] handleMessage: %1", _msg];
		false // message not handled
	} ENDMETHOD;
	
	// Posts a message into the MessageLoop of this object
	METHOD("postMessage") {
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		private _messageLoop = CALL_METHOD(_thisObject, "getMessageLoop", []);
		if (_messageLoop == "") exitWith { diag_log format ["[MessageReceiver:postMessage] Error: %1 is not assigned to a message loop", _thisObject];};
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