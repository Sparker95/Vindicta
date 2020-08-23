#define OOP_DEBUG
#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Threads.rpt"
#include "..\common.h"
#include "..\Mutex\Mutex.hpp"
#include "..\Message\Message.hpp"
#include "..\CriticalSection\CriticalSection.hpp"
#include "ProcessCategories.hpp"
FIX_LINE_NUMBERS()

/*
The thread function of the MessageLoop.
It checks for messages in the loop and calls handleMessages of objects.
*/

#define pr private

// DEBUG FLAGS

// Will print some raw and filtered values of the measured process functions execution time
#define PROCESS_CATEGORIES_DEBUG

// Will log every message
#define PROFILE_MESSAGE_JSON

// Performs monitoring of thread func prformance
#define THREAD_FUNC_DEBUG

#ifdef THREAD_FUNC_DEBUG
private _nextTickTime = PROCESS_TIME + 5;
private _nextProcessLogTime = PROCESS_TIME + 5;
#endif
FIX_LINE_NUMBERS()

#ifdef PROCESS_CATEGORIES_DEBUG
private _execTimeArray = [];
private _execTimeFilteredArray = [];
#endif
FIX_LINE_NUMBERS()

// Disable flags for release build by force

#ifdef RELEASE_BUILD
#undef PROFILE_MESSAGE_JSON
#undef THREAD_FUNC_DEBUG
#undef PROCESS_CATEGORIES_DEBUG
#endif
FIX_LINE_NUMBERS()


params [P_THISOBJECT];

private _msgQueue = T_GETV("msgQueue");
private _mutex = T_GETV("mutex");
private _processCategories = T_GETV("processCategories");
private _fractionsRequired = T_GETV("updateFrequencyFractions");
private _sleepInterval = T_GETV("sleepInterval");
//private _objects = T_GETV("objects");


#ifdef _SQF_VM // Don't want to run this in VM testing mode
if(true) exitWith {};
#endif
FIX_LINE_NUMBERS()

private _name = T_GETV("name");

scriptName _name;

while {true} do {

	// Log queue length, post a delay test message
	#ifdef THREAD_FUNC_DEBUG
	if(_nextTickTime != 0 && _nextTickTime < PROCESS_TIME) then {
		_nextTickTime = 0;
		private _str = format ["{ ""name"": ""%1"", ""queue_len"": %2 }", _name, count _msgQueue];
		OOP_DEBUG_MSG(_str, []);
		_msgQueue pushBack ["__debugtick", "", CLIENT_OWNER, MESSAGE_ID_NOT_REQUESTED, 0, PROCESS_TIME];
	};
	#endif
	FIX_LINE_NUMBERS()

	private _loadingScreenStarted = false;

	//Do we have anything in the queue?

	if ( count _msgQueue > 0 ) then {

		// Lock mutex
		MUTEX_LOCK(_mutex);

		private _countMessages = 0;
		private _countMessagesMax = T_GETV("nMessagesInSeries");

		// Start loading screen if we have no interface and there are too messages
		/*
		#ifndef _SQF_VM
		if (!HAS_INTERFACE && count _msgQueue > _countMessagesMax) then {
			startLoadingScreen ["Msg loop"];
			_loadingScreenStarted = true;
			OOP_INFO_2("Start loading screen: %1, message queue is too big: %2", T_GETV("name"), count _msgQueue);
		};
		#endif
		*/
		FIX_LINE_NUMBERS()

		while { count _msgQueue > 0 && _countMessages < _countMessagesMax } do {
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
				private _t = PROCESS_TIME - _msg#5;
				private _str = format ["{ ""name"": ""%1"", ""delay"": %2 }", _name, _t];
				OOP_DEBUG_MSG(_str, []);
				// OOP_DEBUG_MSG("[message queue len %1]", [count _msgQueue]);
				_nextTickTime = PROCESS_TIME + 5;
			} else {
			#endif
			FIX_LINE_NUMBERS()

			private _msgID = _msg#MESSAGE_ID_SOURCE_ID;
			//Get destination object
			private _dest = _msg#MESSAGE_ID_DESTINATION;
			//Call handleMessage
			if(IS_OOP_OBJECT(_dest)) then {
				#ifdef PROFILE_MESSAGE_JSON
				private _objectClass = GET_OBJECT_CLASS(_dest);
				private _profileTimeStart = diag_tickTime;
				#endif

				// Set last handled object
				// If it crashes now, we will read this value, and make a memory dump
				T_SETV("lastObject", _dest);

				private _result = if(IS_OOP_OBJECT(_dest)) then { CALLM(_dest, "handleMessage", [_msg]) } else { 0 };

				// Reset last handled object
				T_SETV("lastObject", NULL_OBJECT);

				#ifdef PROFILE_MESSAGE_JSON
				private _profileTime = diag_tickTime - _profileTimeStart;
				private _type = _msg#MESSAGE_ID_TYPE;
				private _str = format ["{ ""name"": ""%1"", ""msg"": { ""type"": ""%2"", ""destClass"": ""%3"", ""time"": %4, ""data"": %5} }", _name, _type, _objectClass, _profileTime, str (_msg#MESSAGE_ID_DATA)];
				OOP_DEBUG_MSG(_str, []);
				#endif
				FIX_LINE_NUMBERS()

				if (isNil "_result") then {_result = 0;};
				// Were we asked to mark the message as processed?
				if (_msgID != MESSAGE_ID_NOT_REQUESTED) then {
					// Did the message originate from this machine?
					private _msgSourceOwner = _msg#MESSAGE_ID_SOURCE_OWNER;
					if (_msgSourceOwner == clientOwner) then {
						// Mark this message processed on this machine
						[_msgID, _result, _dest] call MsgRcvr_fnc_setMsgDone;
					} else {
						// Mark this message processed on the remote machine
						[_msgID, _result, _dest] remoteExecCall ["MsgRcvr_fnc_setMsgDone", _msgSourceOwner, false];
					};
				};
			} else {
				OOP_ERROR_1("Destination object does not exist: %1", _dest);
			};
			#ifdef THREAD_FUNC_DEBUG
			};
			#endif
			FIX_LINE_NUMBERS()

			_countMessages = _countMessages + 1;
		};

		// Unlock mutex
		MUTEX_UNLOCK(_mutex);
	};

	// Process the process categories
	pr _count = count _processCategories;
	if (_count > 0) then {
		
		// Lock the mutex
		MUTEX_LOCK(_mutex);

		// Calculate time spent by each process category
		pr _fractionsCurrent = _processCategories apply {
			private _countObjects = count (_x select __PC_ID_OBJECTS);
			if (_countObjects == 0) then {
				0
			} else {
				1/(_x#__PC_ID_UPDATE_INTERVAL_AVERAGE * _countObjects) // We want to maintain proportions of update frequencies, so that objects with higher priority are processed more often 
			};
		};

		// Normalize
		pr _sum = 0;
		{ _sum = _sum + _x; } forEach _fractionsCurrent;
		if (_sum == 0) then {
			pr _t = 1/_count;
			_fractionsCurrent = _fractionsCurrent apply {_t};
		} else {
			_fractionsCurrent = _fractionsCurrent apply {_x / _sum};
		};

		//diag_log format ["current: %1, required: %2", _fractionsCurrent apply {round (_x*100)}, _fractionsRequired apply {round (_x*100)}];

		// Iterate through all categories
		for "_i" from 0 to (_count - 1) do {
			pr _cat = _processCategories#_i;
			pr _objects = _cat#__PC_ID_OBJECTS;
			pr _countObjects = count _objects;
			pr _execTime = 0; // Time spent executing this category this time

			// Do we need to process this category?
			// We need to process it if its current time fraction is less than the required fraction
			pr _intervalMin = _cat#__PC_ID_UPDATE_INTERVAL_MIN;
			pr _intervalMax = _cat#__PD_ID_UPDATE_INTERVAL_MAX;
			pr _intervalAveragePerObject = _countObjects * _cat#__PC_ID_UPDATE_INTERVAL_AVERAGE;
			pr _categoryAboveMaxInterval = _intervalAveragePerObject > _intervalMax;

			// Start loading screen if we are processing above max interval
			/*
			#ifndef _SQF_VM
			if ( !HAS_INTERFACE && _categoryAboveMaxInterval) then {
				startLoadingScreen ["Msg loop"];
				_loadingScreenStarted = true;
				OOP_DEBUG_4("Start loading screen: %1, process category %2 is above max threshold: %3 > %4", T_GETV("name"), _cat select __PC_ID_TAG, _intervalAveragePerObject, _intervalMax);
			};
			#endif
			*/
			FIX_LINE_NUMBERS()

			if ( ( _fractionsCurrent#_i <= _fractionsRequired#_i									// Process next object from this category if current update frequency fraction is below required level
																	|| _categoryAboveMaxInterval )	// ... OR if current update interval is beyond the required maximum set interval
				&& _countObjects > 0																// ... but don't process anything if there are no objects in this category
				&& _intervalAveragePerObject > _intervalMin ) then {								// ... but don't process anything if update interval is smaller than the minimum set level

				// Find first object in the array with objects that should be processed
				pr _objectID = _cat#__PC_ID_NEXT_OBJECT_ID;
				pr _nObjectsChecked = 0;
				pr _found = false;

				// Find the first next object that we should process 
				while {_nObjectsChecked < _countObjects} do {
					_objectID = (_objectID+1) mod _countObjects; // Increase the ID of the next object to check
					if ( PROCESS_CATEGORY_TIME - _objects#_objectID#1 > _intervalMin ) exitWith { _found = true; }; // There is an object which hasn't been processed for quite long time
					_nObjectsChecked = _nObjectsChecked + 1;
				};
				
				// If we have found an object to process, process it
				if (_found) then {
					
					// Call object.process
					pr _objectArray = _objects#_objectID;
					pr _object = _objectArray#0;
					pr _objectLastProcessTimestamp = _objectArray#1;
					pr _timeStart = PROCESS_CATEGORY_TIME;

					// Set last handled object
					// If it crashes now, we will read this value, and make a memory dump
					T_SETV("lastObject", _object);

					CALLM0(_object, "process");

					// Reset last object
					T_SETV("lastObject", NULL_OBJECT);

					pr _timeEnd = PROCESS_CATEGORY_TIME;
					// Update summary time of this category
					//_execTime = _timeEnd - _timeStart;

					// Set timestamp on this object
					_objectArray set [1, _timeStart];

					// Update the measurement of execution time of objects in this category
					//pr _callTimeTotal = _cat#__PC_ID_OBJECT_CALL_TIME_TOTAL;
					//_callTimeTotal = _callTimeTotal + _execTime;
					//_cat set [__PC_ID_OBJECT_CALL_TIME_TOTAL, _callTimeTotal];

					// Calculate update interval
					pr _lastObjectTimestamp = _cat#__PC_ID_LAST_OBJECT_PROCESS_TIMESTAMP;
					pr _objectUpdateInterval = _timeEnd - _lastObjectTimestamp;
					if (_objectUpdateInterval < 0.001) then {_objectUpdateInterval = 0.0005; }; // Due to timer inaccuracy, time difference can be 0 sometimes
					_cat set [__PC_ID_UPDATE_INTERVAL_LAST, _objectUpdateInterval];
					_cat set [__PC_ID_LAST_OBJECT_PROCESS_TIMESTAMP, _timeStart];

					#ifdef THREAD_FUNC_DEBUG
					pr _timeDiff = _timeStart - _objectLastProcessTimestamp;
					_cat set [__PC_ID_ALL_PROCESS_INTERVAL, _timeDiff];
					_cat set [__PC_ID_ALL_PROCESS_LAST_TIMESTAMP, _timeStart];
					#endif
					FIX_LINE_NUMBERS()
				};

				// Update next ID
				_cat set [__PC_ID_NEXT_OBJECT_ID, _objectID];
			};

			// Filter update frequency of this category
			pr _updateIntervalLast = _cat#__PC_ID_UPDATE_INTERVAL_LAST; // The last recorded update interval
			pr _timeSinceLastUpdate = PROCESS_CATEGORY_TIME - _cat#__PC_ID_LAST_OBJECT_PROCESS_TIMESTAMP; // Time that has passed since we have updated any object from this category
			if (_timeSinceLastUpdate > _updateIntervalLast) then { _updateIntervalLast = _timeSinceLastUpdate; }; // If we haven't updated for more time than typical update interval, we must increase the average time to start updating again 
			// out = alpha*in + (1-alpha)*out
			pr _updateIntervalAverage = _cat#__PC_ID_UPDATE_INTERVAL_AVERAGE; // The filtered update interval
			_updateIntervalAverage = MOVING_AVERAGE_ALPHA*_updateIntervalLast + (1-MOVING_AVERAGE_ALPHA)*_updateIntervalAverage;
			_cat set [__PC_ID_UPDATE_INTERVAL_AVERAGE, _updateIntervalAverage];

			// If this category interval is bigger than max interval, don't give time to other categories then
			//if (_categoryAboveMaxInterval) exitWith {};

			/*
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
			*/
		};

		#ifdef THREAD_FUNC_DEBUG
		if (PROCESS_TIME > _nextProcessLogTime) then {

			//pr _cur = _fractionsCurrent apply {round (_x*100)};
			//pr _req = _fractionsRequired apply {round (_x*100)};
			pr _name = T_GETV("name");
			// OOP_DEBUG_3("Message loop: %1, current fractions: %2, required fractions: %3", T_GETV("name"), _cur, _req);
			{
				pr _i = _foreachindex;

				//pr _execTime = _x#__PC_ID_EXECUTION_TIME_AVERAGE;
				pr _tag = _x#__PC_ID_TAG;
				pr _numObjects = count (_x#__PC_ID_OBJECTS);
				pr _fractionCurrent = round (100*_fractionsCurrent#_i);
				pr _fractionRequired = round (100*_fractionsRequired#_i);
				pr _updateInterval = _x#__PC_ID_ALL_PROCESS_INTERVAL;

				pr _str = format ["{ ""name"": ""%1"", ""processCategory"" : { ""name"" : ""%2"", ""nObjects"": %3, ""fractionCurrent"": %4, ""fractionRequired"": %5, ""updateInterval"": %6} }", //,  ""callTimeAvg"": %7} }", 
					_name, _tag, _numObjects, _fractionCurrent, _fractionRequired, _updateInterval];
				OOP_DEBUG_MSG(_str, []);
			} forEach _processCategories;
			_nextProcessLogTime = PROCESS_TIME + 5;
		};
		#endif
		FIX_LINE_NUMBERS()

		// Unlock the mutex
		MUTEX_UNLOCK(_mutex);
	};

	/*
	// End loading screen if it was ever started
	if (_loadingScreenStarted) then {
		endLoadingScreen;
	};
	*/

	// Give time to other threads in the SQF scheduler
	uisleep _sleepInterval;
};
