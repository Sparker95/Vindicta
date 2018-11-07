/*
Timer is an object which posts a message into another object with specified time interval.

Author: Sparker 31.07.2018

Usage template:

private _msg = MESSAGE_NEW();
_msg set [MESSAGE_ID_DESTINATION, ***];
_msg set [MESSAGE_ID_SOURCE, ""];
_msg set [MESSAGE_ID_DATA, ***];
_msg set [MESSAGE_ID_TYPE, ***];
private _args = [__destination__, __interval__, _msg, gTimerServiceMain]; // message receiver, interval, message, timer service
private _timer = NEW("Timer", _args);


*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "Timer.hpp"

CLASS("Timer", "")

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
		//diag_log format ["[Timer::New] _this: %1", _this];
		// Fill the data array
		private _data = TIMER_DATA_DEFAULT;
		_data set [TIMER_DATA_ID_INTERVAL, _interval];
		_data set [TIMER_DATA_ID_TIME_NEXT, time+_interval];
		_data set [TIMER_DATA_ID_MESSAGE, +_message];
		_data set [TIMER_DATA_ID_MESSAGE_RECEIVER, _messageReceiver];
		_data set [TIMER_DATA_ID_TIMER_SERVICE, _timerService];
		private _msgLoop = CALL_METHOD(_messageReceiver, "getMessageLoop", []);
		_data set [TIMER_DATA_ID_MESSAGE_LOOP, _msgLoop];
		SET_VAR(_thisObject, "data", _data);
		//diag_log format ["[Timer] Info: %1 data: %2, _msgLoop: %3", _thisObject, _data, _msgLoop];
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
	
	// ----------------------------------------------------------------------
	// |                       S E T   I N T E R V A L                      |
	// ----------------------------------------------------------------------
	
	METHOD("setInterval") {
		params [["_thisObject", "", [""]], ["_interval", 0, [0]]];
		private _data = GET_VAR(_thisObject, "data");
		_data set [TIMER_DATA_ID_INTERVAL, _interval];
		_data set [TIMER_DATA_ID_TIME_NEXT, time+_interval];
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                    G E T   D A T A   A R R A Y                     |
	// ----------------------------------------------------------------------
	// Internal function meant to be used only by TimerService
	METHOD("getDataArray") {
		params [["_thisObject", "", [""]]];
		GET_VAR(_thisObject, "data")
	} ENDMETHOD;
ENDCLASS;