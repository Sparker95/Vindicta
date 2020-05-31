#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Threads.rpt"
#include "..\common.h"
#include "..\Mutex\Mutex.hpp"
#include "..\CriticalSection\CriticalSection.hpp"
#include "..\Message\Message.hpp"
#include "ProcessCategories.hpp"
FIX_LINE_NUMBERS()

/*
Class: MessageLoop
MessageLoop is a thread (a spawned script) which can have
MessageLoop, when created, spawns a thread which waits for messages to get into its queue. Then it routes messages to specific objects or to itself.

Author: Sparker
15.06.2018
*/

/*
#ifndef RELEASE_BUILD
//#define DEBUG_MESSAGE_LOOP
#endif
*/

#define pr private

MessageLoop_fnc_threadFunc = compile preprocessFileLineNumbers "MessageLoop\fn_threadFunc.sqf";
MessageLoop_fnc_perFrameHandler = compile preprocessFileLineNumbers "MessageLoop\fn_perFrameHandler.sqf";

#define N_MESSAGES_IN_SERIES_DEFAULT 128

#define OOP_CLASS_NAME MessageLoop
CLASS("MessageLoop", "Storable");

	//Array with messages
	/* save */	VARIABLE_ATTR("msgQueue", [ATTR_SAVE]);	// We are saving all the messages in the message queue
	//Handle to the script which does message processing
				VARIABLE("scriptHandle");
	//Mutex for accessing the message queue
				VARIABLE("mutex");
	//Debug name to help read debug printouts
	/* save */	VARIABLE_ATTR("name", [ATTR_SAVE]);
	// Process categories
				VARIABLE("processCategories");
	// Desired process time fractions calculated from priorities of categories
				VARIABLE("updateFrequencyFractions");
	// Amount of messages this message loop will process before switching to process categories
				VARIABLE("nMessagesInSeries");
	// Sleep interval
				VARIABLE_ATTR("sleepInterval", [ATTR_SAVE]);
	// Last processed object (through message queue or process categories)
				VARIABLE("lastObject");

	// Event handler ID
				VARIABLE("eachFrameEHID");
	// Bool, if true then message loop will be processing messages in per-frame handler.
	/* save */	VARIABLE_ATTR("unscheduled", [ATTR_SAVE]);

	//Constructor
	//Spawn a script which will be checking messages
	/*
	Method: new

	parameters: _name

	_name - String, optional, name of the message loop used for debug
	_nMessagesInSeries - number, max amount of messages to process in row.
	_sleepInterval - number, sleep time between message processing. Irrelevant if _unscheduled == true
	_unscheduled - bool, default false. If true, message loop will be processing messages in per-frame handler.

	Constructor
	*/
	METHOD(new)
		params [P_THISOBJECT, P_STRING("_name"), ["_nMessagesInSeries", N_MESSAGES_IN_SERIES_DEFAULT, [0]], ["_sleepInterval", 0.001, [0]], ["_unscheduled", false, [false]] ];
		T_SETV("msgQueue", []);
		if (_name == "") then {
			T_SETV("name", _thisObject);
		} else {
			T_SETV("name", _name);
		};
		T_SETV("mutex", MUTEX_NEW());
		T_SETV("processCategories", []);
		T_SETV("updateFrequencyFractions", []);
		T_SETV("nMessagesInSeries", _nMessagesInSeries);
		T_SETV("sleepInterval", _sleepInterval);
		T_SETV("lastObject", NULL_OBJECT);
		T_SETV("unscheduled", _unscheduled);

		T_CALLM0("_initThreadOrPFH");

	ENDMETHOD;

	METHOD(_initThreadOrPFH)
		params [P_THISOBJECT];
		
		// Start a scheduled 'thread' or create a per-frame handler
		if (T_GETV("unscheduled")) then {
			private _codeStr = format ["[""%1""] call MessageLoop_fnc_perFrameHandler;", _thisObject];
			#ifndef _SQF_VM
			private _id = addMissionEventHandler ["EachFrame", _codeStr];
			T_SETV("eachFrameEHID", _id);
			#endif
			FIX_LINE_NUMBERS()
		} else {
			// Do this last to avoid race condition on other members of this class
			private _scriptHandle = [_thisObject] spawn MessageLoop_fnc_threadFunc;
			T_SETV("scriptHandle", _scriptHandle);
		};
	ENDMETHOD;

	/*
	Method: delete
	Deletes this thread.

	After the thread is deleted, objects can no longer process messages through it.

	Warning: must be called in scheduled environment!
	*/
	METHOD(delete)
		params [P_THISOBJECT];

		if (T_GETV("unscheduled")) then {
			private _id = T_GETV("eachFrameEHID");
			removeMissionEventHandler ["EachFrame", _id];
		} else {
			private _mutex = T_GETV("mutex");
			MUTEX_LOCK(_mutex); //Make sure we don't terminate the thread after it locks the mutex!
			//Clear the variables
			private _scriptHandle = T_GETV("scriptHandle");
			terminate _scriptHandle;
			MUTEX_UNLOCK(_mutex);
		};
	ENDMETHOD;


	/*
	Method: setName
	Sets debug name of this MessageLoop.

	Parameters: _name

	_name - String

	Returns: nil
	*/
	METHOD(setName)
		params [P_THISOBJECT, P_STRING("_name")];
		T_SETV("name", _name);
	ENDMETHOD;

	/*
	Method: setMaxMessagesInSeries
	Sets maximum amount of messages this message loop is allowed to process in series,
	before switching to processing its process categories.
	When thread is created, its default value is N_MESSAGES_IN_SERIES_DEFAULT.
	*/
	METHOD(setMaxMessagesInSeries)
		params [P_THISOBJECT, ["_nMessagesInSeries", N_MESSAGES_IN_SERIES_DEFAULT, [0]] ];
		T_SETV("nMessagesInSeries", _nMessagesInSeries);
	ENDMETHOD;

	/*
	Method: postMessage
	Adds a message into the message queue

	Access: internal use!

	Parameters: _msg

	_msg - <Message>

	Returns: nil
	*/
	METHOD(postMessage)
		#ifdef DEBUG_MESSAGE_LOOP
		diag_log format ["[MessageLoop::postMessage] params: %1", _this];
		#endif
		FIX_LINE_NUMBERS()
		params [P_THISOBJECT, P_ARRAY("_msg")];

		PROFILE_ADD_EXTRA_FIELD("message_source", _msg select MESSAGE_ID_SOURCE);
		PROFILE_ADD_EXTRA_FIELD("message_dest", _msg select MESSAGE_ID_DESTINATION);
		PROFILE_ADD_EXTRA_FIELD("message_type", _msg select MESSAGE_ID_TYPE);
    
		private _msgQueue = T_GETV("msgQueue");
		_msgQueue pushBack _msg;
	ENDMETHOD;

	//MessageLoop can also handle messages directed to it.
	/*
	Derived classes can implement this method like this:
	switch(_msgType) do {
		case "DO_STUFF": {...}
		case "DO_OTHER_STUFF" : {...}
		default: {return baseClass::handleMessage(msg);}
	}
	*/
	/*
	METHOD(handleMessage)
		// For now it returns false (message not handled)
		false
	ENDMETHOD;
	*/


	/*
	Method: deleteReceiverMessages
	Description
	Deletes messages targeted to specified <MessageReceiver>.

	Access: internal use!

	Parameters: _msgReceiver

	_msgReceiver - <String>, <MessageReceiver>

	Returns: nil
	*/
	METHOD(deleteReceiverMessages)
		params [P_THISOBJECT, P_OOP_OBJECT("_msgReceiver") ];
		CRITICAL_SECTION {
			private _msgQueue = T_GETV("msgQueue");

			//diag_log format ["Deleting message receiver: %1", _msgReceiver];
			//diag_log format ["Message queue: %1", _msgQueue];

			private _i = 0;
			while {  _i < (count _msgQueue)} do {
				pr _msg = _msgQueue select _i;
				if ( (_msg select MESSAGE_ID_DESTINATION) == _msgReceiver) then { // If found a message directed to thi receiver
					_msgQueue deleteAt _i;
					//diag_log format ["=========== Deleted a message: %1", _msg];
				} else {
					_i = _i + 1;
				};
			};
		};
		nil
	ENDMETHOD;

	// Functions for process categories

	METHOD(addProcessCategory)
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_STRING("_tag"), ["_priority", 1, [1]], ["_minInterval", 1, [0]], ["_maxInterval", 5, [0]]];

			if (T_GETV("unscheduled")) exitWith {
				OOP_ERROR_0("Attempt to call addProcessCategory on unscheduled message loop");
			};

			pr _cat = __PC_NEW(_tag, _priority, _minInterval, _maxInterval);
			pr _cats = T_GETV("processCategories"); // meow ^.^
			_cats pushBack _cat;

			if (!T_GETV("unscheduled")) then {
				T_CALLM0("updateRequiredFractions");
			};
		};
		nil
	ENDMETHOD;

	// Only for unscheduled msg loop
	METHOD(addProcessCategoryUnscheduled)
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_STRING("_tag"), ["_interval", 1, [0]], ["_minObjPerFrame", 0, [0]], ["_maxObjPerFrame", 100, [0]]];

			if (!T_GETV("unscheduled")) exitWith {
				OOP_ERROR_0("Attempt to call addProcessCategoryUnscheduled on scheduled message loop");
			};

			pr _cat = __PC_NEW(_tag, 0, _interval, _interval);
			_cat set [__PC_ID_N_OBJECTS_PER_FRAME_MIN, _minObjPerFrame];
			_cat set [__PC_ID_N_OBJECTS_PER_FRAME_MAX, _maxObjPerFrame];
			pr _cats = T_GETV("processCategories");
			_cats pushBack _cat;

			if (!T_GETV("unscheduled")) then {
				T_CALLM0("updateRequiredFractions");
			};
		};
		nil
	ENDMETHOD;

	// Only relevant for scheduled process categories
	METHOD(updateRequiredFractions)
		params [P_THISOBJECT];
		pr _cats = T_GETV("processCategories");
		pr _fractions = T_GETV("updateFrequencyFractions");
		_fractions resize (count _cats);
		pr _sum = 0; // Sum of all priorities
		for "_i" from 0 to ((count _cats) - 1) do {
			pr _priority = _cats#_i#__PC_ID_PRIORITY;
			pr _countObjects = count (_cats#_i#__PC_ID_OBJECTS);
			if (_countObjects == 0) then {
				_priority = 0;
			};
			_fractions set [_i, _priority];
			_sum = _sum + _priority;
		};
		if (_sum == 0) then {
			for "_i" from 0 to ((count _cats) - 1) do {
				_fractions set [_i, 0];
			};
		} else {
			for "_i" from 0 to ((count _cats) - 1) do {
				_fractions set [_i, (_fractions#_i)/_sum];
			};
		};
	ENDMETHOD;

	METHOD(addProcessCategoryObject)
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_STRING("_tag"), P_OOP_OBJECT("_object")];

			OOP_INFO_2("addProcessCategoryObject: %1 %2", _tag, _object);

			// Remove from any existing categories
			pr _cats = T_GETV("processCategories");
			{
				pr _allObjects = _x#__PC_ID_ALL_OBJECTS;
				pr _index = _allObjects find _object;
				if (_index != NOT_FOUND) then {
					_x#__PC_ID_OBJECTS deleteAt _index;
					_allObjects deleteAt _index;
					// Delete from queue of high priority objects
					pr _objsHigh = _x#__PC_ID_OBJECTS_URGENT;
					_objsHigh deleteAt (_objsHigh findIf { _x#0 == _object });
				};
			} forEach _cats;

			// Find category with given tag
			pr _index = _cats findIf { _x#__PC_ID_TAG == _tag };
			if (_index != NOT_FOUND) then {
				pr _cat = _cats#_index;
				pr _allObjects = _cat#__PC_ID_ALL_OBJECTS;

				// Ensure we don't add same object twice
				if (_allObjects find _object == NOT_FOUND) then {
					pr _objs = _cat#__PC_ID_OBJECTS;
					_objs pushBack __PC_OBJECT_NEW(_object, false);
					_allObjects pushBack _object;
				} else {
					OOP_ERROR_2("Attempt to add object %1 to process category %2 twice", _object, _tag);
				};
			} else {
				OOP_ERROR_1("Process category with tag %1 was not found!", _tag);
			};

			if (!T_GETV("unscheduled")) then {
				T_CALLM0("updateRequiredFractions");
			};
		};
		nil
	ENDMETHOD;

	METHOD(deleteProcessCategoryObject)
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_object")];

			OOP_INFO_1("deleteProcessCategoryObject: %1", _object);

			pr _cats = T_GETV("processCategories");
			{
				pr _allObjects = _x#__PC_ID_ALL_OBJECTS;
				pr _index = _allObjects find _object;
				pr _objs = _x#__PC_ID_OBJECTS;

				#ifdef _SQF_VM
				if (_index != NOT_FOUND) then {
				#endif

					//diag_log format ["index: %1", _index];
					_objs deleteAt _index;
					_allObjects deleteAt _index;

					// Delete from queue of high priority objects
					pr _objsHigh = _x#__PC_ID_OBJECTS_URGENT;
					_objsHigh deleteAt (_objsHigh findIf {_x#0 == _object});

					//true // No need to search any more

				#ifdef _SQF_VM
				};
				#endif

				//} else {
				//	false // Need to search other categories, this object is not here
				//};
			} forEach _cats;

			if (!T_GETV("unscheduled")) then {
				T_CALLM0("updateRequiredFractions");
			};
		};
		nil
	ENDMETHOD;

	// Adds this object to high priority queue of its process category
	METHOD(setObjectUrgentPriority)
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_object")];

			OOP_INFO_1("setObjectUrgentPriority: %1", _object);

			// Find category in which this object is
			pr _added = false;
			pr _cats = T_GETV("processCategories");
			{
				pr _allObjects = _x select __PC_ID_ALL_OBJECTS;
				pr _index = _allObjects find _object;
				if (_index != -1) then { // Object found in this cat
					pr _objsHigh = _x select __PC_ID_OBJECTS_URGENT;
					_objsHigh pushBack (__PC_OBJECT_NEW(_object, true));
					OOP_INFO_2("setObjectUrgentPriority: added object %1 from category %2", _object, _x#__PC_ID_TAG);
					_added = true;				
				};
			} forEach _cats;

			if (!_added) then {
				OOP_ERROR_1("setObjectUrgentPriority: object %1 is not found", _object);
			};
		};
		nil
	ENDMETHOD;

	METHOD(lock)
		params [P_THISOBJECT];
		pr _mutex = T_GETV("mutex");
		MUTEX_LOCK(_mutex);
	ENDMETHOD;

	METHOD(tryLockTimeout)
		params [P_THISOBJECT, P_NUMBER("_timeout")];
		pr _mutex = T_GETV("mutex");
		MUTEX_TRY_LOCK_TIMEOUT(_mutex, _timeout);
	ENDMETHOD;

	METHOD(unlock)
		params [P_THISOBJECT];
		pr _mutex = T_GETV("mutex");
		MUTEX_UNLOCK(_mutex);
	ENDMETHOD;

	// Returns true if message loop is running
	// That is, it has not crashed
	METHOD(isRunning)
		params [P_THISOBJECT];
		if (T_GETV("unscheduled")) then {
			true // Always running
		} else {
			pr _scriptHandle = T_GETV("scriptHandle");
			!(scriptDone _scriptHandle)
		};
	ENDMETHOD;

	// Same as above, inverted
	// Returns true if it has crashed
	METHOD(isNotRunning)
		params [P_THISOBJECT];
		if (T_GETV("unscheduled")) then {
			false // Always running
		} else {
			pr _scriptHandle = T_GETV("scriptHandle");
			(scriptDone _scriptHandle)
		};
	ENDMETHOD;

	METHOD(getLength)
		params [P_THISOBJECT];
		private _msgQueue = T_GETV("msgQueue");
		count _msgQueue
	ENDMETHOD;

	// STORAGE

	/* override */ METHOD(postDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		T_SETV("mutex", MUTEX_NEW());
		T_SETV("processCategories", []);
		T_SETV("updateFrequencyFractions", []);
		T_SETV("nMessagesInSeries", N_MESSAGES_IN_SERIES_DEFAULT);
		T_SETV("lastObject", NULL_OBJECT);

		T_CALLM0("_initThreadOrPFH");

		true
	ENDMETHOD;

ENDCLASS;
