/*
The thread function of the MessageLoop.
It checks for messages in the loop and calls handleMessages of objects.
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Mutex\Mutex.hpp"
#include "..\Message\Message.hpp"
#include "..\CriticalSection\CriticalSection.hpp"

params [ ["_thisObject", "", [""]] ];

private _msgQueue = GET_VAR(_thisObject, "msgQueue");
private _mutex = GET_VAR(_thisObject, "mutex");
//private _objects = GET_VAR(_thisObject, "objects");

//#define DEBUG

while {true} do {
	//Do we have anything in the queue?
	waitUntil {	(count _msgQueue) > 0 };
	while {(count _msgQueue) > 0} do {
		//Get a message from the front
		private _msg = _msgQueue select 0;
		#ifdef DEBUG
		diag_log format ["[MessageLoop] Info: message in queue: %1", _msg];
		#endif
		//Get destination object
		private _dest = _msg select MESSAGE_ID_DESTINATION;
		//Call handleMessage
		//if (!isNil )
		// todo make sure we call a method on an existing object
		CALL_METHOD(_dest, "handleMessage", [_msg]);
		//Delete the message
		_msgQueue deleteAt 0;
	};
	
	//By now the queue must be empty.
	//Make msgDoneID equal to msgPostID in case something went wrong.
	CRITICAL_SECTION_START
	private _msgPostID = GET_VAR(_thisObject, "msgPostID");
	SET_VAR(_thisObject, "msgDoneID", _msgPostID);
	CRITICAL_SECTION_END
};