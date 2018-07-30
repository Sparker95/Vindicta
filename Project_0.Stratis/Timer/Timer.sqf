/*
Timer is an object which posts a message into another object with specified time interval.

Author: Sparker 31.07.2018
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "Timer.hpp"

CLASS("MyClass", "")

	VARIABLE("data");
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	/*
	Parameters:
		_messageReceiver - the object of MessageReceiver class (or inherited) which will be receiving the messages
		_interval - interval between sending messages in seconds
		_message - a Message which will be posted to the _messageReceiver
		_timerService - the TimerService object this timer will be attached to
	*/
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_messageReceiver", "", [""]], ["_interval", 1, [1]], ["_message", [], [[]]], ["_timerService", "", [""]] ];
		// Fill the data array
		private _data = TIMER_DATA_DEFAULT;
		_data set [TIMER_DATA_ID_INTERVAL, _interval];
		_data set [TIMER_DATA_ID_TIME_NEXT, time+_interval];
		_data set [TIMER_DATA_ID_MESSAGE, _message];
		_data set [TIMER_DATA_ID_MESSAGE_RECEIVER, _messageReceiver];
		_data set [TIMER_DATA_ID_TIMER_SERVICE, _messageReceiver];
		_data set [TIMER_DATA_ID_MESSAGE_LOOP, CALL_METHOD(_mesageReceiver, "getMessageLoop", [])];
		SET_VAR(_thisObject, "data", _data);
		// Add this timer to the timer service
		CALL_METHOD(_timerService, "addTimer", [_thisObject]);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		private _data = GET_VAR(_thisObject, "data");
		private _timerService = _data select TIMER_DATA_ID_TIMER_SERVICE;
		CALL_METHOD(_timerService, "removeTimer", [_thisObject]);
	} ENDMETHOD;

ENDCLASS;