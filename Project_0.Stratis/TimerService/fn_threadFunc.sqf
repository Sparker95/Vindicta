/*
Thread function for a TimerService.
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Mutex\Mutex.hpp"
#include "..\Timer\Timer.hpp"

params [["_thisObject", "", [""]]];

private _mutex = GET_VAR(_thisObject, "mutex");
private _timers = GET_VAR(_thisObject, "timers");
while {true} do {
	private _res = GET_VAR(_thisObject, "resolution");
	sleep _res;
	// Lock the mutex
	MUTEX_LOCK(_mutex);
	{
		// Is it time to trigger this timer yet?
		if (time > (_x select TIMER_DATA_ID_TIME_NEXT)) then {
			// Post a message
			private _msgLoop = _x select TIMER_DATA_ID_MESSAGE_LOOP;
			private _msgID = _x select TIMER_DATA_ID_MESSAGE_ID;
			// Check if the previous message has been handled (we don't want to overflood the receiver with the same messages)
			if (CALL_METHOD(_msgLoop, "messageDone", [_msgID])) then {
				// Post a new message
				// todo inline the MessageReceiver::postMessage it some time later!
				private _msgReceiver = _x select TIMER_DATA_ID_MESSAGE_RECEIVER;
				private _msg = _x select TIMER_DATA_ID_MESSAGE;
				private _newID = CALL_METHOD(_msgReceiver, "postMessage", [_msg]);
				_x set [TIMER_DATA_ID_MESSAGE_ID, _newID];
			};
			
			// Set the time when the timer will fire next time
			_x set [TIMER_DATA_ID_TIME_NEXT, time + (_x select TIMER_DATA_ID_INTERVAL)];
		};
	} forEach _timers;
	MUTEX_UNLOCK(_mutex);
};