/*
The thread function of the MessageLoop.
It checks for messages in the loop and calls handleMessages of objects.
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Mutex\Mutex.hpp"
#include "..\Message\Message.hpp"
#include "..\CriticalSection\CriticalSection.hpp"

#define pr private

params [ ["_thisObject", "", [""]] ];

private _msgQueue = GET_VAR(_thisObject, "msgQueue");
private _mutex = GET_VAR(_thisObject, "mutex");
//private _objects = GET_VAR(_thisObject, "objects");

//#define DEBUG

while {true} do {
	//Do we have anything in the queue?
	waitUntil {	(count _msgQueue) > 0 };
	while {(count _msgQueue) > 0} do {
		//Get a message from the front of the queue
		pr _msg = _msgQueue select 0;
		pr _msgID = _msg select MESSAGE_ID_SOURCE_ID;
		#ifdef DEBUG
		diag_log format ["[MessageLoop] Info: message in queue: %1", _msg];
		#endif
		//Get destination object
		private _dest = _msg select MESSAGE_ID_DESTINATION;
		//Call handleMessage
		// todo make sure we call a method on an existing object
		pr _result = CALL_METHOD(_dest, "handleMessage", [_msg]);
		if (isNil "_result") then {_result = 0;};
		// Were we asked to mark the message as processed?
		if (_msgID != MESSAGE_ID_NOT_REQUESTED) then {
			// Did the message originate from this machine?
			pr _msgSourceOwner = _msg select MESSAGE_ID_SOURCE_OWNER;
			if (_msgSourceOwner == clientOwner) then {
				// Mark this message processed on this machine
				[_msgID, _result] call MsgRcvr_fnc_setMsgDone;
			} else {
				// Mark this message processed on the remote machine
				[_msgID, _result] remoteExecCall ["MsgRcvr_fnc_setMsgDone", _msgSourceOwner, false];
			};
		};
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