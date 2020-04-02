#include "..\OOP_Light\OOP_Light.h"
#include "..\Mutex\Mutex.hpp"
#include "..\Timer\Timer.hpp"

// Class: TimerService
/*
Function: threadFunc
Thread function for a TimerService.

Parameters: _timerService

Access: Internal use.
*/

params [P_THISOBJECT];

scriptName "Timer Service";

#ifdef _SQF_VM // Don't want to run this in VM testing mode
diag_log format ["[TimerService::threadFunc] Disabled due to SQFvm mode"];
#else
diag_log format ["[TimerService::threadFunc] Info: thread started"];

private _mutex = T_GETV("mutex");
private _timers = T_GETV("timers");
while {true} do {
	private _res = T_GETV("resolution");
	//diag_log format ["[TimerService::threadFunc] Info: sleeping for %1 seconds", _res];
	uisleep _res;
	// Lock the mutex
	MUTEX_LOCK(_mutex);
	{ // forEach _timers
		//diag_log format ["[TimerService::threadFunc] Info: checking timer: %1", _x];
		// Is it time to trigger this timer yet?
		if (time > (_x select TIMER_DATA_ID_TIME_NEXT)) then {
			//diag_log format ["[TimerService::threadFunc] Info: time to post a message"];
			// Post a message
			//private _msgLoop = _x select TIMER_DATA_ID_MESSAGE_LOOP;
			private _msgID = _x select TIMER_DATA_ID_MESSAGE_ID;
			// Check if the previous message has been handled (we don't want to overflood the receiver with the same messages)
			if (CALL_STATIC_METHOD("MessageReceiver", "messageDone", [_msgID])) then {
				//diag_log format ["[TimerService::threadFunc] Info: posting a message"];
				// Post a new message
				// todo inline the MessageReceiver::postMessage it some time later!
				private _msgReceiver = _x select TIMER_DATA_ID_MESSAGE_RECEIVER;
				private _msg = _x select TIMER_DATA_ID_MESSAGE;
				private _newID = CALLM2(_msgReceiver, "postMessage", _msg, true);
				_x set [TIMER_DATA_ID_MESSAGE_ID, _newID];
				//diag_log format [" --- Timer posted message to: %1,  msgID: %2", _msgReceiver, _newID];
			} else {
				private _msg = _x select TIMER_DATA_ID_MESSAGE;
				OOP_WARNING_MSG("[TimerService::threadFunc] Info: Message not posted: %1,  msgID: %2", [_msg]+[_msgID]);
			};
			
			// Set the time when the timer will fire next time
			_x set [TIMER_DATA_ID_TIME_NEXT, time + (_x select TIMER_DATA_ID_INTERVAL)];
		};
	} forEach _timers;
	MUTEX_UNLOCK(_mutex);
};
#endif