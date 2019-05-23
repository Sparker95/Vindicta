#define OOP_DEBUG
#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Threads.rpt"
#include "..\OOP_Light\OOP_Light.h"
#include "..\Mutex\Mutex.hpp"
#include "..\Message\Message.hpp"
#include "..\CriticalSection\CriticalSection.hpp"
#include "MessageLoop.hpp"

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
private _nextProcessLogTime = time + 5;
#endif

params [ P_THISOBJECT ];

private _msgQueue = GET_VAR(_thisObject, "msgQueue");
private _mutex = GET_VAR(_thisObject, "mutex");
private _processCategories = GET_VAR(_thisObject, "processCategories");
private _fractionsRequired = GET_VAR(_thisObject, "processTimeFractions");
//private _objects = GET_VAR(_thisObject, "objects");


#ifdef _SQF_VM // Don't want to run this in VM testing mode
if(true) exitWith {};
#endif

scriptName _thisObject;

while {true} do {

	//Do we have anything in the queue?
	if ( (count _msgQueue) > 0 ) then {
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

	// Process the process categories
	pr _count = count _processCategories;
	if (_count > 0) then {
		
		// Calculate time spent by each process category
		pr _fractionsCurrent = [];
		_processCategories apply {_x select PROCESS_CATEGORY_ID_EXECUTION_TIME_AVERAGE};
		pr _sum = 0;
		{ _sum = _sum + _x; } forEach _fractionsCurrent;
		_fractionsCurrent apply {_x / _sum};

		// Time spent executing this category this time
		pr _execTime = 0;

		// Iterate through all categories
		for "_i" from 0 to (_count - 1) do {
			pr _cat = _processCategories select _i;
			pr _objs = _cat select PROCESS_CATEGORY_ID_OBJECTS;
			pr _countObjs = count _objs;

			// Do we need to process this category?
			// We need to process it if its current time fraction is less than the required fraction
			if (_fractionsCurrent#_i < _fractionsRequired && _countObjs > 0) then {
				// Find first object in the array with objects that should be processed
				pr _nextID = _cat select PROCESS_CATEGORY_NEXT_OBJECT_ID;
				pr _startID = _nextID;
				if (_nextID >= _countObjs) then {_nextID = 0; _startID = 0;};
				pr _found = false;
				
				// Find the first next object that we should process 
				while {true} do {
					if (_objs#_nextID#1 < time) exitWith {_found = true;};
					_nextID = (_nextID+1) mod _countObjs;
					if (_nextID == _startID) exitWith {}; // We have checked everything
				};
				
				// If we have found an object to process, process it
				if (_found) then {
					// Call object.process
					pr _object = _objs#_nextID;
					pr _timeStart = time;
					CALLM0(_object, "process");
					pr _timeEnd = time;
					// Update summary time of this category
					_execTime = _timeEnd - _timeStart;
					// Update the next execution time of this object
					_timeEnd = _timeEnd + _cat select PROCESS_CATEGORY_ID_MINIMUM_INTERVAL;
					_object set [1, _timeEnd];
				};
			};

			// Filter execution time of this category
			pr _execTimeOld = _cat select PROCESS_CATEGORY_ID_EXECUTION_TIME_AVERAGE;
			pr _execTimeNew = MOVING_AVERAGE_ALPHA*_execTimeOld + (1-MOVING_AVERAGE_ALPHA)*_execTime;
			_cat set [PROCESS_CATEGORY_ID_EXECUTION_TIME_AVERAGE, _execTimeNew];
		};

		#ifdef THREAD_FUNC_DEBUG
		if (time > _nextProcessLogTime) then {

			OOP_PROFILE_3("Message loop: %1, current fractions: %2, required fractions: %3", T_GETV("name"), _fractionsCurrent, _fractionsRequired);
			{
				pr _execTime = _x#PROCESS_CATEGORY_ID_EXECUTION_TIME;
				pr _tag = _x#PROCESS_CATEGORY_ID_TAG;
				pr _numObjs = count (_x#PROCESS_CATEGORY_ID_OBJECTS);
				OOP_PROFILE_3("   tag: %1, time: %2, nObjects: %3", _tag, _execTime, _numObjs);
			} forEach _processCategories;
			_nextProcessLogTime = time + 5;
		};
		#endif
	};

	// Give time to other threads in the SQF scheduler
	sleep 0.001;
};
