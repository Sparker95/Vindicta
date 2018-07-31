/*
TimerService is a container for Timer objects. it checks Timer objects supplied to it with some time interval(resolution) and dispatches a message if the time for this timer has expired.

Author: Sparker 31.07.2018
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Mutex\Mutex.hpp"

TimerService_fnc_threadFunc = compile preprocessFileLineNumbers "TimerService\fn_threadFunc.sqf";

CLASS("TimerService", "")

	VARIABLE("timers");
	VARIABLE("resolution"); // Time resolution
	VARIABLE("scriptHandle");
	VARIABLE("mutex");
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_resolution", 0, [0]]];
		SET_VAR(_thisObject, "timers", []);
		SET_VAR(_thisObject, "resolution", _resolution);
		private _mutex = MUTEX_NEW();
		SET_VAR(_thisObject, "mutex", _mutex);
		
		// Create a thread for this TimerService
		private _hThread = [_thisObject] spawn TimerService_fnc_threadFunc;
		SET_VAR(_thisObject, "scriptHandle", _hThread);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		// Wait until we lock the mutex. We don't want to stop the thread while it's doing something.
		private _mutex = GET_VAR(_thisObject, "mutex");
		MUTEX_LOCK(_mutex);
		// Stop the thread
		private _scriptHandle = GET_VAR(_thisObject, "_scriptHandle");
		terminate _scriptHandle;
		MUTEX_UNLOCK(_mutex);
		
		// Delete all timers attached to this object
		{
			DELETE(_x);
		} forEach (GET_VAR(_thisObject, "timers"));
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                         A D D   T I M E R                          |
	// ----------------------------------------------------------------------
	// Adds a timer to this timerService
	// You don't need to call this since a timer is added to TimerService on Timer creation automatically
	METHOD("addTimer") {
		params [["_thisObject", "", [""]], ["_timer", "", [""]]];
		private _timers = GET_VAR(_thisObject, "timers");
		private _timerDereferenced = CALL_METHOD(_timer, "getDataArray", []);
		_timers pushBackUnique _timerDereferenced;
	} ENDMETHOD;

ENDCLASS;