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

// Will print some raw and filtered values of the measured process functions execution time
//#define PROCESS_CATEGORIES_DEBUG

#ifdef PROCESS_CATEGORIES_DEBUG
private _execTimeArray = [];
private _execTimeFilteredArray = [];
#endif

// Will log every message
//#define PROFILE_MESSAGE_JSON

#ifdef RELEASE_BUILD
#undef PROFILE_MESSAGE_JSON
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

private _name = T_GETV("name");

while {true} do {

	// Log queue length, post a delay test message
	#ifdef THREAD_FUNC_DEBUG
	if(_nextTickTime != 0 and _nextTickTime < time) then {
		_nextTickTime = 0;
		private _str = format ["{ ""name"": ""%1"", ""queue_len"": %2 }", _name, count _msgQueue];
		OOP_DEBUG_MSG(_str, []);
		_msgQueue pushBack ["__debugtick", "", CLIENT_OWNER, MESSAGE_ID_NOT_REQUESTED, 0, time];
	};
	#endif

	//Do we have anything in the queue?

	if ( (count _msgQueue) > 0 ) then {
		private _countMessages = 0;
		while {(count _msgQueue) > 0 && _countMessages < 16} do {
			//Get a message from the front of the queue
			pr _msg = 0;
			CRITICAL_SECTION {
				// Take the message from the front of the queue
				_msg = _msgQueue select 0;
				// Delete the message
				_msgQueue deleteAt 0;
			};

			// Check if it's the test message to measure queue delay
			#ifdef THREAD_FUNC_DEBUG
			if(_msg#0 == "__debugtick") then {
				private _t = time - _msg#5;
				private _str = format ["{ ""name"": ""%1"", ""delay"": %2 }", _name, _t];
				OOP_DEBUG_MSG(_str, []);
				// OOP_DEBUG_MSG("[message queue len %1]", [count _msgQueue]);
				_nextTickTime = time + 5;
			} else {
			#endif



			pr _msgID = _msg select MESSAGE_ID_SOURCE_ID;
			//Get destination object
			private _dest = _msg select MESSAGE_ID_DESTINATION;
			//Call handleMessage
			// todo make sure we call a method on an existing object

			#ifdef PROFILE_MESSAGE_JSON
			pr _objectClass = GET_OBJECT_CLASS(_dest);
			private _profileTimeStart = diag_tickTime;
			#endif

			pr _result = CALL_METHOD(_dest, "handleMessage", [_msg]);

			#ifdef PROFILE_MESSAGE_JSON
			private _profileTime = diag_tickTime - _profileTimeStart;
			pr _dest = _msg#MESSAGE_ID_DESTINATION;
			pr _type = _msg#MESSAGE_ID_TYPE;
			private _str = format ["{ ""name"": ""%1"", ""msg"": { ""type"": ""%2"", ""destClass"": ""%3"", ""time"": %4} }", _name, _type, _objectClass, _profileTime];
			OOP_DEBUG_MSG(_str, []);
			#endif

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

			_countMessages = _countMessages + 1;
		};
	};

	// Process the process categories
	pr _count = count _processCategories;
	if (_count > 0) then {
		
		// Calculate time spent by each process category
		pr _fractionsCurrent = _processCategories apply {
			private _countObjects = count (_x select PROCESS_CATEGORY_ID_OBJECTS);
			if (_countObjects == 0) then {
				0
			} else {
				(_x select PROCESS_CATEGORY_ID_EXECUTION_TIME_AVERAGE) * (_countObjects)
			};			
		}; // Also divide it by the amount of objects
		//OOP_INFO_1("    fracs current: %1", _fractionsCurrent);
		//OOP_INFO_1("    cats: %1", _processCategories);
		pr _sum = 0;
		{ _sum = _sum + _x; } forEach _fractionsCurrent;
		if (_sum == 0) then {
			pr _t = 1/_count;
			_fractionsCurrent = _fractionsCurrent apply {_t};
		} else {
			_fractionsCurrent = _fractionsCurrent apply {_x / _sum};
		};


		// Iterate through all categories
		for "_i" from 0 to (_count - 1) do {
			pr _cat = _processCategories#_i;
			pr _objects = _cat#PROCESS_CATEGORY_ID_OBJECTS;
			pr _countObjects = count _objects;		
			pr _execTime = 0; // Time spent executing this category this time

			// Do we need to process this category?
			// We need to process it if its current time fraction is less than the required fraction
			if (_fractionsCurrent#_i <= _fractionsRequired#_i && _countObjects > 0) then {
				// Find first object in the array with objects that should be processed
				pr _objectID = _cat#PROCESS_CATEGORY_ID_NEXT_OBJECT_ID;
				pr _nObjectsChecked = 0;
				pr _found = false;

				// Find the first next object that we should process 
				while {_nObjectsChecked < _countObjects} do {
					_objectID = (_objectID+1) mod _countObjects; // Increase the ID of the next object to check
					if (_objects#_objectID#1 < PROCESS_CATEGORY_TIME) exitWith { _found = true; }; // There is an object which hasn't been processed for quite long time
					_nObjectsChecked = _nObjectsChecked + 1;
				};
				
				// If we have found an object to process, process it
				if (_found) then {
					
					// Call object.process
					pr _objectArray = _objects#_objectID;
					pr _object = _objectArray#0;
					pr _timeStart = PROCESS_CATEGORY_TIME;
					CALLM0(_object, "process");
					pr _timeEnd = PROCESS_CATEGORY_TIME;
					// Update summary time of this category
					_execTime = _timeEnd - _timeStart;
					// Update the next execution time of this object
					_timeEnd = _timeEnd + _cat#PROCESS_CATEGORY_ID_MINIMUM_INTERVAL;
					_objectArray set [1, _timeEnd];

					// Update the measurement of execution time of objects in this category
					#ifdef THREAD_FUNC_DEBUG
					pr _callTimeTotal = _cat#PROCESS_CATEGORY_ID_OBJECT_CALL_TIME_TOTAL;
					_callTimeTotal = _callTimeTotal + _execTime;
					_cat set [PROCESS_CATEGORY_ID_OBJECT_CALL_TIME_TOTAL, _callTimeTotal];

					// If we have processed object 0, update our measurement of update interval
					if (_objectID == 0) then {
						// Calculate average call time per object
						/*
						// Actually no, it is being calculated wrong, because we must divide it by the amount of objects processed so far
						// Not by total amount of objects
						// Don't need it much anyway, it is done by profiler wrappers
						pr _callTimeTotal = _cat#PROCESS_CATEGORY_ID_OBJECT_CALL_TIME_TOTAL;
						pr _timePerObj = _callTimeTotal / _countObjects;
						_cat set [PROCESS_CATEGORY_ID_OBJECT_CALL_TIME_AVERAGE, _timePerObj];
						_cat set [PROCESS_CATEGORY_ID_OBJECT_CALL_TIME_TOTAL, 0];
						*/

						// Calculate update interval
						pr _updateInterval = PROCESS_CATEGORY_TIME - _cat#PROCESS_CATEGORY_ID_FIRST_OBJECT_PROCESS_TIME;
						_cat set [PROCESS_CATEGORY_ID_UPDATE_INTERVAL, _updateInterval];
						_cat set [PROCESS_CATEGORY_ID_FIRST_OBJECT_PROCESS_TIME, PROCESS_CATEGORY_TIME];

						/*
						pr _tag = _cat select PROCESS_CATEGORY_ID_TAG;
						pr _timePerObj = _timeAllObjects / _countObjects;

						pr _str = format ["{ ""name"": ""%1"", ""processCategory"" : { ""name"" : ""%2"", ""nObjects"": %3, ""timePerObject"": %4, ""timeAllObjects"": %5 } }", 
							T_GETV("name"), _tag, _countObjects, _timePerObj, _timeAllObjects];
						OOP_DEBUG_MSG(_str, []);
						*/
					};

					#endif
				};

				// Update next ID
				_cat set [PROCESS_CATEGORY_ID_NEXT_OBJECT_ID, _objectID];
			};

			// Filter execution time of this category
			pr _execTimeOld = _cat#PROCESS_CATEGORY_ID_EXECUTION_TIME_AVERAGE;
			// out = alpha*in + (1-alpha)*out
			pr _execTimeNew = MOVING_AVERAGE_ALPHA*_execTime + (1-MOVING_AVERAGE_ALPHA)*_execTimeOld;
			_cat set [PROCESS_CATEGORY_ID_EXECUTION_TIME_AVERAGE, _execTimeNew];

			#ifdef PROCESS_CATEGORIES_DEBUG
			if (_i == 0) then {
				_execTimeFilteredArray pushBack (_execTimeNew*1000);
				_execTimeArray pushBack (_execTime*1000);

				if (count _execTimeFilteredArray >= 60) then {
					OOP_DEBUG_1("   raw  exec time: %1", _execTimeArray apply {round _x});
					OOP_DEBUG_1("   fltr exec time: %1", _execTimeFilteredArray apply {round _x});
					_execTimeFilteredArray = [];
					_execTimeArray = [];
				};
			};
			#endif

		};

		#ifdef THREAD_FUNC_DEBUG
		if (time > _nextProcessLogTime) then {

			//pr _cur = _fractionsCurrent apply {round (_x*100)};
			//pr _req = _fractionsRequired apply {round (_x*100)};
			pr _name = T_GETV("name");
			// OOP_DEBUG_3("Message loop: %1, current fractions: %2, required fractions: %3", T_GETV("name"), _cur, _req);
			{
				pr _i = _foreachindex;

				//pr _execTime = _x#PROCESS_CATEGORY_ID_EXECUTION_TIME_AVERAGE;
				pr _tag = _x#PROCESS_CATEGORY_ID_TAG;
				pr _numObjects = count (_x#PROCESS_CATEGORY_ID_OBJECTS);
				pr _fractionCurrent = round (100*_fractionsCurrent#_i);
				pr _fractionRequired = round (100*_fractionsRequired#_i);
				pr _updateInterval = _x#PROCESS_CATEGORY_ID_UPDATE_INTERVAL;
				pr _timePerObject = _x#PROCESS_CATEGORY_ID_OBJECT_CALL_TIME_AVERAGE;

				pr _str = format ["{ ""name"": ""%1"", ""processCategory"" : { ""name"" : ""%2"", ""nObjects"": %3, ""fractionCurrent"": %4, ""fractionRequired"": %5, ""updateInterval"": %6} }", //,  ""callTimeAvg"": %7} }", 
					_name, _tag, _numObjects, _fractionCurrent, _fractionRequired, _updateInterval, _timePerObject]; //, _timePerObject];
				OOP_DEBUG_MSG(_str, []);
			} forEach _processCategories;


			_nextProcessLogTime = time + 5;
		};
		#endif
	};

	// Give time to other threads in the SQF scheduler
	sleep 0.001;
};
