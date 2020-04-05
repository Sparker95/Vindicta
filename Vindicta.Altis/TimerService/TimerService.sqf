#include "..\OOP_Light\OOP_Light.h"
#include "..\Mutex\Mutex.hpp"

/*
Class: TimerService
TimerService is a container for Timer objects. It checks Timer objects supplied to it with some time interval(resolution) and dispatches a message if the time for this timer has expired.

Author: Sparker 31.07.2018
*/

TimerService_fnc_threadFunc = compile preprocessFileLineNumbers "TimerService\fn_threadFunc.sqf";

CLASS("TimerService", "")

	VARIABLE("timers");
	VARIABLE("resolution"); // Time resolution
	VARIABLE("scriptHandle");
	VARIABLE("mutex");
	
	// |                              N E W                                 |
	/*
	Method: new
	
	Parameters: _resolution
	
	_resolution - the time interval at which this timer service will check its timers and dispatch messages.
	It defines the maximum frequency at which your timer can run.
	*/
	METHOD("new") {
		params [P_THISOBJECT, P_NUMBER("_resolution")];
		T_SETV("timers", []);
		T_SETV("resolution", _resolution);
		private _mutex = MUTEX_NEW();
		T_SETV("mutex", _mutex);
		
		// Create a thread for this TimerService
		private _hThread = [_thisObject] spawn TimerService_fnc_threadFunc;
		T_SETV("scriptHandle", _hThread);
	} ENDMETHOD;
	

	// |                            D E L E T E                             |
	/*
	Method: delete
	
	Warning: must be called in scheduled environment!
	*/
	METHOD("delete") {
		params [P_THISOBJECT];
		// Wait until we lock the mutex. We don't want to stop the thread while it's doing something.
		private _mutex = T_GETV("mutex");
		MUTEX_LOCK(_mutex);
		// Stop the thread
		private _scriptHandle = T_GETV("_scriptHandle");
		terminate _scriptHandle;
		MUTEX_UNLOCK(_mutex);
		
		// Delete all timers attached to this object
		{
			DELETE(_x);
		} forEach (T_GETV("timers"));
	} ENDMETHOD;
	
	// |                         A D D   T I M E R                          |
	/*
	Method: addTimer
	Adds a timer to this timerService.
	
	Access: Internal use. You don't need to call this since a timer is added to TimerService on Timer creation automatically.
	
	Parameters: _timer
	
	_timer - the <Timer> object to add to this TimerService.
	
	Returns: nil
	*/
	METHOD("addTimer") {
		params [P_THISOBJECT, P_OOP_OBJECT("_timer")];
		private _timers = T_GETV("timers");
		private _timerDereferenced = CALL_METHOD(_timer, "getDataArray", []);
		_timers pushBackUnique _timerDereferenced;
	} ENDMETHOD;
	
	// |                      R E M O V E   T I M E R                       |
	/*
	Method: removeTimer
	Remove a timer from this TimerService.
	
	Warning: must be called in scheduled environment!
	
	Parameters: _timer
	
	_timer - the <Timer> object to remove from this TimerService.
	
	Returns: nil
	*/
	METHOD("removeTimer") {
		params [P_THISOBJECT, P_OOP_OBJECT("_timer")];
		private _timers = T_GETV("timers");
		private _timerDereferenced = CALL_METHOD(_timer, "getDataArray", []);
		
		// Lock the mutex. We don't want to manipulate the timer array while it's being accessed by TimerService thread function.
		private _mutex = T_GETV("mutex");
		MUTEX_LOCK(_mutex);
		
		// Check if the timer exists in the array
		private _index = _timers find _timerDereferenced;
		if (_index == -1) exitWith { diag_log format ["[TimerService::removeTimer] Error: timer not found: %1", _timerDereferenced]; };
		
		// Such a timer has been found, delete it
		_timers deleteAt _index;
		//T_SETV("timers", _timers);
		
		// Unlock the mutex
		MUTEX_UNLOCK(_mutex);
	} ENDMETHOD;

ENDCLASS;