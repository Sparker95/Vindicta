/*
MessageReceiver class.
This class has capability to handle incoming messages.
Inherited classes must implement a getMessageLoop method which must return the MessageLoop object to which a message can be sent.

Author: Sparker
15.06.2018
*/

#include "..\OOP_Light\OOP_Light.h"

CLASS("MessageReceiver", "")

	METHOD("getMessageLoop") { //Derived classes must implement this method
	} ENDMETHOD;
	
	METHOD("handleMessage") { //Derived classes must implement this method
	} ENDMETHOD;
	
	// Posts a message into the MessageLoop of this object
	METHOD("postMessage") {
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		private _messageLoop = CALL_METHOD(_thisObject, "getMessageLoop", []);
		private _args = [_thisObject, _msg];
		private _msgID = CALL_METHOD(_messageLoop, "postMessage", _args);
		//Return message ID value
		_msgID;
	} ENDMETHOD;
	
ENDCLASS;