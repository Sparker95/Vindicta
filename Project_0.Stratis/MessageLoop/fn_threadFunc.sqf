/*
The thread function of the MessageLoop.
It checks for messages in the loop and calls handleMessages of objects.
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Mutex\Mutex.hpp"
#include "..\Message\Message.hpp"

params [ ["_thisObject", "", [""]] ];

private _msgQueue = GET_VAR(_thisObject, "msgQueue");
private _mutex = GET_VAR(_thisObject, "mutex");
//private _objects = GET_VAR(_thisObject, "objects");

while {true} do {
	//Do we have anything in the queue?
	waitUntil {	(count _msgQueue) > 0 };
	while {(count _msgQueue) > 0} do {
		//Get a message from the front
		private _msg = _msgQueue select 0;
		//Get destination object
		private _dest = _msg select MSG_ID_DESTINATION;
		//Call handleMessage
		CALL_METHOD(_dest, "handleMessage", [_msg]);
		//Delete the message
		_msgQueue deleteAt 0;
	};
	
	//By now the queue must be empty.
	//Make msgDoneID equal to msgPostID in case something went wrong.
	MUTEX_LOCK(_mutex);
	private _msgPostID = GET_VAR(_thisObject, "msgPostID");
	SET_VAR(_thisObject, "msgDoneID", _msgPostID);
	MUTEX_UNLOCK(_mutex);
};