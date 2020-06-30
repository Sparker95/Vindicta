#include "..\common.h"
#include "..\Mutex\Mutex.hpp"
#include "..\CriticalSection\CriticalSection.hpp"
#include "..\Timer\Timer.hpp"
#include "..\Message\Message.hpp"
FIX_LINE_NUMBERS()

/*
Class: TimerService
TimerService is a container for Timer objects. It checks Timer objects supplied to it with some time interval(resolution) and dispatches a message if the time for this timer has expired.

Author: Sparker 31.07.2018
		Sparker 19 april 2020 converted spawned thread to per frame handler
*/

#define pr private

#define OOP_CLASS_NAME TimerService
CLASS("TimerService", "")

	VARIABLE("timers");
	VARIABLE("resolution"); // Time resolution
	VARIABLE("eventHandlerID");
	VARIABLE("suspended");
	VARIABLE("timeLastProcess");
	
	// |                              N E W                                 |
	/*
	Method: new
	
	Parameters: _resolution
	
	_resolution - the time interval at which this timer service will check its timers and dispatch messages.
	It defines the maximum frequency at which your timer can run.
	*/
	METHOD(new)
		params [P_THISOBJECT, P_NUMBER("_resolution"), P_BOOL("_startSuspended")];
		if(_startSuspended) then {
			T_SETV("suspended", 1);
		} else {
			T_SETV("suspended", 0);
		};
		T_SETV("timers", []);
		T_SETV("resolution", _resolution);
		T_SETV("timeLastProcess", 0);

		// Create a per frame event handler
		#ifndef _SQF_VM
		pr _id = addMissionEventHandler ["EachFrame", format ["[""%1""] call %2;", _thisObject, CLASS_METHOD_NAME_STR("TimerService", "PFH")]];
		T_SETV("eventHandlerID", _id);
		#endif
		FIX_LINE_NUMBERS()
	ENDMETHOD;
	

	// |                            D E L E T E                             |
	/*
	Method: delete
	
	Warning: must be called in scheduled environment!
	*/
	METHOD(delete)
		params [P_THISOBJECT];

		// Delete the event handler
		#ifndef _SQF_VM
		pr _id = T_GETV("eventHandlerID");
		removeMissionEventHandler ["EachFrame", _id];
		#endif
		FIX_LINE_NUMBERS()
		
		// Delete all timers attached to this object
		{
			DELETE(_x);
		} forEach (T_GETV("timers"));
	ENDMETHOD;
	
	// |                         A D D   T I M E R                          |
	/*
	Method: addTimer
	Adds a timer to this timerService.
	
	Access: Internal use. You don't need to call this since a timer is added to TimerService on Timer creation automatically.
	
	Parameters: _timer
	
	_timer - the <Timer> object to add to this TimerService.
	
	Returns: nil
	*/
	public METHOD(addTimer)
		params [P_THISOBJECT, P_OOP_OBJECT("_timer")];
		T_GETV("timers") pushBackUnique CALLM0(_timer, "getDataArray");
	ENDMETHOD;
	
	// |                      R E M O V E   T I M E R                       |
	/*
	Method: removeTimer
	Remove a timer from this TimerService.
	
	Warning: must be called in scheduled environment!
	
	Parameters: _timer
	
	_timer - the <Timer> object to remove from this TimerService.
	
	Returns: nil
	*/
	public METHOD(removeTimer)
		params [P_THISOBJECT, P_OOP_OBJECT("_timer")];
		CRITICAL_SECTION {
			private _timers = T_GETV("timers");
			// This could be done in one line, but SQF-VM complains about index out of bounds
			private _index = _timers find CALLM0(_timer, "getDataArray");
			if(_index != NOT_FOUND) then {
				_timers deleteAt _index;
			};
		};
		nil
	ENDMETHOD;

	public METHOD(suspend)
		params [P_THISOBJECT];
		CRITICAL_SECTION {
			T_SETV("suspended", T_GETV("suspended") + 1);
		};
	ENDMETHOD;
	
	public METHOD(resume)
		params [P_THISOBJECT];
		CRITICAL_SECTION {
			T_SETV("suspended", T_GETV("suspended") - 1);
		};
	ENDMETHOD;

	// Per frame handler
	METHOD(PFH)
		params [P_THISOBJECT];
		if ((time - T_GETV("timeLastProcess")) > T_GETV("resolution")) then {

			#ifdef ASP_ENABLE
			private _profilerScope = createProfileScope "TimerService_PFH"; // For ASP
			#endif
			FIX_LINE_NUMBERS()

			if(T_GETV("suspended") == 0) then {
				pr _timers = T_GETV("timers");
				{ // forEach _timers
					//diag_log format ["[TimerService::threadFunc] Info: checking timer: %1", _x];
					// Is it time to trigger this timer yet?
					if (PROCESS_TIME > (_x select TIMER_DATA_ID_TIME_NEXT)) then {
						if (_x#TIMER_DATA_ID_UNSCHEDULED) then {
							// = = = Call the method directly

							private _msg = _x select TIMER_DATA_ID_MESSAGE;
							private _msgReceiver = _x select TIMER_DATA_ID_MESSAGE_RECEIVER;
							#ifdef ASP_ENABLE
							private _profilerScope0 = createProfileScope "TimerService_HandleMessage"; // For ASP
							private _profilerScope1 = createProfileScope ([format ["TimerService_HandleMessage_%1_%2", GET_OBJECT_CLASS(_msgReceiver), _msg#MESSAGE_ID_TYPE]] call misc_fnc_createStaticString);
							#endif

							private _msgReceiver = _x select TIMER_DATA_ID_MESSAGE_RECEIVER;
							CALLM1(_msgReceiver, "handleMessage", _msg);
						} else {
							// = = = Post message

							#ifdef ASP_ENABLE
							private _profilerScope1 = createProfileScope "TimerService_PostMessage"; // For ASP
							#endif

							//diag_log format ["[TimerService::threadFunc] Info: time to post a message"];
							// Post a message
							//private _msgLoop = _x select TIMER_DATA_ID_MESSAGE_LOOP;
							
							private _msgID = _x select TIMER_DATA_ID_MESSAGE_ID;
							
							// Check if the previous message has been handled (we don't want to overflood the receiver with the same messages)
							if (CALLSM("MessageReceiver", "messageDone", [_msgID])) then {
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
						};
						
						// Set the time when the timer will fire next time
						_x set [TIMER_DATA_ID_TIME_NEXT, PROCESS_TIME + (_x select TIMER_DATA_ID_INTERVAL)];
					};
				} forEach _timers;
			};
			T_SETV("timeLastProcess", time);
		};
	ENDMETHOD;

ENDCLASS;