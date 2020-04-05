#include "..\OOP_Light\OOP_Light.h"
#include "..\Mutex\Mutex.hpp"
#include "..\CriticalSection\CriticalSection.hpp"
#include "..\Message\Message.hpp"
#include "ProcessCategories.hpp"
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

#define N_MESSAGES_IN_SERIES_DEFAULT 128

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

	//Constructor
	//Spawn a script which will be checking messages
	/*
	Method: new

	parameters: _name

	_name - String, optional, name of the message loop used for debug
	_nMessagesInSeries - number
	_sleepInterval - number

	Constructor
	*/
	METHOD("new") {
		params [P_THISOBJECT, P_STRING("_name"), ["_nMessagesInSeries", N_MESSAGES_IN_SERIES_DEFAULT, [0]], ["_sleepInterval", 0.001, [0]] ];
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

		// Do this last to avoid race condition on other members of this class
		private _scriptHandle = [_thisObject] spawn MessageLoop_fnc_threadFunc;
		T_SETV("scriptHandle", _scriptHandle);
	} ENDMETHOD;

	/*
	Method: delete
	Deletes this thread.

	After the thread is deleted, objects can no longer process messages through it.

	Warning: must be called in scheduled environment!
	*/
	METHOD("delete") {
		params [P_THISOBJECT];
		private _mutex = T_GETV("mutex");
		MUTEX_LOCK(_mutex); //Make sure we don't terminate the thread after it locks the mutex!
		//Clear the variables
		private _scriptHandle = T_GETV("scriptHandle");
		terminate _scriptHandle;
		T_SETV("msgQueue", nil);
		T_SETV("scriptHandle", nil);
		MUTEX_UNLOCK(_mutex);
		T_SETV("mutex", nil);
	} ENDMETHOD;


	/*
	Method: setName
	Sets debug name of this MessageLoop.

	Parameters: _name

	_name - String

	Returns: nil
	*/
	METHOD("setName") {
		params [P_THISOBJECT, P_STRING("_name")];
		T_SETV("name", _name);
	} ENDMETHOD;

	/*
	Method: setMaxMessagesInSeries
	Sets maximum amount of messages this message loop is allowed to process in series,
	before switching to processing its process categories.
	When thread is created, its default value is N_MESSAGES_IN_SERIES_DEFAULT.
	*/
	METHOD("setMaxMessagesInSeries") {
		params [P_THISOBJECT, ["_nMessagesInSeries", N_MESSAGES_IN_SERIES_DEFAULT, [0]] ];
		T_SETV("nMessagesInSeries", _nMessagesInSeries);
	} ENDMETHOD;

	/*
	Method: postMessage
	Adds a message into the message queue

	Access: internal use!

	Parameters: _msg

	_msg - <Message>

	Returns: nil
	*/
	METHOD("postMessage") {
		#ifdef DEBUG_MESSAGE_LOOP
		diag_log format ["[MessageLoop::postMessage] params: %1", _this];
		#endif
		params [P_THISOBJECT, P_ARRAY("_msg")];

		PROFILE_ADD_EXTRA_FIELD("message_source", _msg select MESSAGE_ID_SOURCE);
		PROFILE_ADD_EXTRA_FIELD("message_dest", _msg select MESSAGE_ID_DESTINATION);
		PROFILE_ADD_EXTRA_FIELD("message_type", _msg select MESSAGE_ID_TYPE);
    
		private _msgQueue = T_GETV("msgQueue");
		_msgQueue pushBack _msg;
	} ENDMETHOD;

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
	METHOD("handleMessage") {
		// For now it returns false (message not handled)
		false
	} ENDMETHOD;
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
	METHOD("deleteReceiverMessages") {
		params [P_THISOBJECT, P_OOP_OBJECT("_msgReceiver") ];
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
	} ENDMETHOD;

	// Functions for process categories

	METHOD("addProcessCategory") {
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_STRING("_tag"), ["_priority", 1, [1]], ["_minInterval", 1, [0]], ["_maxInterval", 5, [0]]];

			pr _cat = __PC_NEW(_tag, _priority, _minInterval, _maxInterval);
			pr _cats = T_GETV("processCategories"); // meow ^.^
			_cats pushBack _cat;

			T_CALLM0("updateRequiredFractions");
		};
	} ENDMETHOD;

	METHOD("updateRequiredFractions") {
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
	} ENDMETHOD;

	METHOD("addProcessCategoryObject") {
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_STRING("_tag"), P_OOP_OBJECT("_object")];

			// Find category with given tag
			pr _cats = T_GETV("processCategories");
			pr _index = _cats findIf {(_x select __PC_ID_TAG) == _tag};
			if (_index != -1) then {
				pr _cat = _cats select _index;
				pr _objs = _cat select __PC_ID_OBJECTS;
				_objs pushBack __PC_OBJECT_NEW(_object);
			} else {
				OOP_ERROR_1("Process category with tag %1 was not found!", _tag);
			};

			T_CALLM0("updateRequiredFractions");
		};
	} ENDMETHOD;

	METHOD("deleteProcessCategoryObject") {
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_object")];

			pr _cats = T_GETV("processCategories");
			{
				pr _objs = _x select __PC_ID_OBJECTS;
				pr _index = _objs findIf {_x select 0 == _object};
				#ifdef _SQF_VM
				if (_index != -1) then {
				#endif
					//diag_log format ["index: %1", _index];
					_objs deleteAt _index;
					//true // No need to search any more
				#ifdef _SQF_VM
				};
				#endif
				//} else {
				//	false // Need to search other categories, this object is not here
				//};
			} forEach _cats;

			T_CALLM0("updateRequiredFractions");
		};
	} ENDMETHOD;

	METHOD("lock") {
		params [P_THISOBJECT];
		pr _mutex = T_GETV("mutex");
		MUTEX_LOCK(_mutex);
	} ENDMETHOD;

	METHOD("tryLockTimeout") {
		params [P_THISOBJECT, P_NUMBER("_timeout")];
		pr _mutex = T_GETV("mutex");
		MUTEX_TRY_LOCK_TIMEOUT(_mutex, _timeout);
	} ENDMETHOD;

	METHOD("unlock") {
		params [P_THISOBJECT];
		pr _mutex = T_GETV("mutex");
		MUTEX_UNLOCK(_mutex);
	} ENDMETHOD;

	// Returns true if message loop is running
	// That is, it has not crashed
	METHOD("isRunning") {
		params [P_THISOBJECT];
		pr _scriptHandle = T_GETV("scriptHandle");
		!(scriptDone _scriptHandle)
	} ENDMETHOD;

	// Same as above, inverted
	// Returns true if it has crashed
	METHOD("isNotRunning") {
		params [P_THISOBJECT];
		pr _scriptHandle = T_GETV("scriptHandle");
		(scriptDone _scriptHandle)
	} ENDMETHOD;


	// STORAGE

	/* override */ METHOD("postDeserialize") {
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		T_SETV("mutex", MUTEX_NEW());
		T_SETV("processCategories", []);
		T_SETV("updateFrequencyFractions", []);
		T_SETV("nMessagesInSeries", N_MESSAGES_IN_SERIES_DEFAULT);
		T_SETV("lastObject", NULL_OBJECT);

		// Do this last to avoid race condition on other members of this class
		private _scriptHandle = [_thisObject] spawn MessageLoop_fnc_threadFunc;
		T_SETV("scriptHandle", _scriptHandle);

		true
	} ENDMETHOD;

ENDCLASS;
