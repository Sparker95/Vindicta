#define OOP_DEBUG
#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Threads.rpt"
#include "..\OOP_Light\OOP_Light.h"
#include "..\Mutex\Mutex.hpp"
#include "..\Message\Message.hpp"
#include "..\CriticalSection\CriticalSection.hpp"
/*
The thread function of the MessageLoop.
It checks for messages in the loop and calls handleMessages of objects.
*/

#define pr private

#ifndef RELEASE_BUILD
#define THREAD_FUNC_DEBUG
#endif

#ifdef THREAD_FUNC_DEBUG
private _nextTickTime = time + 5;
#endif

params [ P_THISOBJECT ];

private _msgQueue = GET_VAR(_thisObject, "msgQueue");
private _mutex = GET_VAR(_thisObject, "mutex");
//private _objects = GET_VAR(_thisObject, "objects");

#ifdef _SQF_VM // Don't want to run this in VM testing mode
if(true) exitWith {};
#endif

scriptName _thisObject;

while {true} do {
	//Do we have anything in the queue?
	waitUntil {	(count _msgQueue) > 0 };
	while {(count _msgQueue) > 0} do {
		//Get a message from the front of the queue
		pr _msg = 0;
		CRITICAL_SECTION {
			// Take the message from the front of the queue
			_msg = _msgQueue select 0;
			// Delete the message
			_msgQueue deleteAt 0;

			#ifdef THREAD_FUNC_DEBUG
			if(_nextTickTime != 0 and _nextTickTime < time) then {
				_nextTickTime = 0;
				_msgQueue pushBack ["__debugtick", "", CLIENT_OWNER, MESSAGE_ID_NOT_REQUESTED, 0, time];
			};
			#endif
		};
		#ifdef THREAD_FUNC_DEBUG
		if(_msg#0 == "__debugtick") then {
			private _t = time - _msg#5;
			T_PRVAR(name);
			private _str = format ["{ ""name"": ""%1"", ""queue_len"": %2 , ""delay"": %3 }", _name, count _msgQueue, _t];
			OOP_DEBUG_MSG(_str, []);
			// OOP_DEBUG_MSG("[message queue len %1]", [count _msgQueue]);
			_nextTickTime = time + 5;
		} else {
		#endif
		pr _msgID = _msg select MESSAGE_ID_SOURCE_ID;
		// OOP_DEBUG_1("[MessageLoop] Info: message in queue: %1", _msg);
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
				[_msgID, _result, _dest] call MsgRcvr_fnc_setMsgDone;
			} else {
				// Mark this message processed on the remote machine
				[_msgID, _result, _dest] remoteExecCall ["MsgRcvr_fnc_setMsgDone", _msgSourceOwner, false];
			};
		};
		#ifdef THREAD_FUNC_DEBUG
		};
		#endif
	};
};
