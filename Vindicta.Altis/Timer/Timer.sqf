#include "..\common.h"
#include "..\Message\Message.hpp"
#include "Timer.hpp"

/*
Class: Timer
Timer is an object which posts a message into a message receiver with specified time interval.

Usage example:

private _msg = MESSAGE_NEW();
_msg set [MESSAGE_ID_DESTINATION, ***];
_msg set [MESSAGE_ID_SOURCE, ""];
_msg set [MESSAGE_ID_DATA, ***];
_msg set [MESSAGE_ID_TYPE, ***];
private _args = [__destination__, __interval__, _msg, gTimerServiceMain]; // message receiver, interval, message, timer service
private _timer = NEW("Timer", _args);

Author: Sparker 31.07.2018
*/

#define OOP_CLASS_NAME Timer
CLASS("Timer", "");

	VARIABLE("data");

	// |                              N E W                                 |
	/*
	Method: new

	Parameters: _messageReceiver, _interval, _message, _timerService

	_messageReceiver - the object of MessageReceiver class (or inherited) which will be receiving the messages
	_interval - interval between sending messages in seconds
	_message - a Message which will be posted to the _messageReceiver
	_timerService - the TimerService object this timer will be attached to
	_unscheduled - Bool, if true the timer service will call the method directly in unscheduled manner instead of calling "postMessage" 
	*/

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_messageReceiver"), ["_interval", 1, [1]], P_ARRAY("_message"), P_OOP_OBJECT("_timerService"), P_BOOL("_unscheduled")];
		//diag_log format ["[Timer::New] _this: %1", _this];
		// Fill the data array
		private _data = TIMER_DATA_DEFAULT;
		_data set [TIMER_DATA_ID_INTERVAL, _interval];
		_data set [TIMER_DATA_ID_TIME_NEXT, PROCESS_TIME+_interval];
		_data set [TIMER_DATA_ID_MESSAGE, +_message];
		_data set [TIMER_DATA_ID_MESSAGE_RECEIVER, _messageReceiver];
		_data set [TIMER_DATA_ID_TIMER_SERVICE, _timerService];
		_data set [TIMER_DATA_ID_UNSCHEDULED, _unscheduled];
		private _msgLoop = CALLM0(_messageReceiver, "getMessageLoop");
		_data set [TIMER_DATA_ID_MESSAGE_LOOP, _msgLoop];
		T_SETV("data", _data);
		//diag_log format ["[Timer] Info: %1 data: %2, _msgLoop: %3", _thisObject, _data, _msgLoop];
		// Add this timer to the timer service
		CALLM(_timerService, "addTimer", [_thisObject]);
	ENDMETHOD;


	// |                            D E L E T E                             |
	/*
	Method: delete
	Deletes this timer and removes it from corresponding <TimerService>.

	Warning: must be called in scheduled environment, since it called TimerService.removeTimer.
	*/
	METHOD(delete)
		params [P_THISOBJECT];
		private _data = T_GETV("data");
		private _timerService = _data select TIMER_DATA_ID_TIMER_SERVICE;
		CALLM(_timerService, "removeTimer", [_thisObject]);
	ENDMETHOD;


	// |                       S E T   I N T E R V A L                      |
	/*
	Method: setInterval
	Sets the interval of this timer.

	Parameters: _interval

	_interval - interval in seconds

	Returns: nil
	*/
	METHOD(setInterval)
		params [P_THISOBJECT, ["_interval", 1, [0]]];
		private _data = T_GETV("data");
		_data set [TIMER_DATA_ID_INTERVAL, _interval];
		_data set [TIMER_DATA_ID_TIME_NEXT, PROCESS_TIME+_interval];
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                    G E T   D A T A   A R R A Y                     |
	// ----------------------------------------------------------------------
	// Internal function meant to be used only by TimerService
	/*
	Method: getDataArray
	Returns an internal data array of this Timer.

	Access: Internal use.

	Returns: Array, see Timer.hpp
	*/
	METHOD(getDataArray)
		params [P_THISOBJECT];
		T_GETV("data")
	ENDMETHOD;
ENDCLASS;
