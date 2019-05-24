#include "..\OOP_Light\OOP_Light.h"
#include "..\Mutex\Mutex.hpp"
#include "..\CriticalSection\CriticalSection.hpp"
#include "..\Message\Message.hpp"
#include "MessageLoop.hpp"

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

CLASS("MessageLoop", "");

	//Array with messages
	VARIABLE("msgQueue");
	//Handle to the script which does message processing
	VARIABLE("scriptHandle");
	//Mutex for accessing the message queue
	VARIABLE("mutex");
	//Debug name to help read debug printouts
	VARIABLE("name");
	// Process categories
	VARIABLE("processCategories");
	// Desired process time fractions calculated from priorities of categories
	VARIABLE("processTimeFractions");

	//Constructor
	//Spawn a script which will be checking messages
	/*
	Method: new

	parameters: _name

	_name - String, optional, name of the message loop used for debug

	Constructor
	*/
	METHOD("new") {
		params [ P_THISOBJECT, ["_name", "", [""]] ];
		T_SETV("msgQueue", []);
		if (_name == "") then {
			T_SETV("name", _thisObject);
		} else {
			T_SETV("name", _name);
		};
		private _scriptHandle = [_thisObject] spawn MessageLoop_fnc_threadFunc;
		T_SETV("scriptHandle", _scriptHandle);
		T_SETV("mutex", MUTEX_NEW());
		T_SETV("processCategories", []);
		T_SETV("processTimeFractions", []);
	} ENDMETHOD;

	/*
	Method: delete
	Deletes this thread.

	After the thread is deleted, objects can no longer process messages through it.

	Warning: must be called in scheduled environment!
	*/
	METHOD("delete") {
		params [ P_THISOBJECT ];
		private _mutex = GET_VAR(_thisObject, "mutex");
		MUTEX_LOCK(_mutex); //Make sure we don't terminate the thread after it locks the mutex!
		//Clear the variables
		private _scriptHandle = GET_VAR(_thisObject, "scriptHandle");
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
		params [P_THISOBJECT, ["_name", "", [""]]];
		T_SETV("name", _name);
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
		params [ P_THISOBJECT, ["_msg", [], [[]]]];

		PROFILE_ADD_EXTRA_FIELD("message_source", _msg select MESSAGE_ID_SOURCE);
		PROFILE_ADD_EXTRA_FIELD("message_dest", _msg select MESSAGE_ID_DESTINATION);
		PROFILE_ADD_EXTRA_FIELD("message_type", _msg select MESSAGE_ID_TYPE);
    
		private _msgQueue = GET_VAR(_thisObject, "msgQueue");
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
		params [ P_THISOBJECT, ["_msgReceiver", "", [""]] ];
		private _msgQueue = GETV(_thisObject, "msgQueue");

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
			params ["_thisObject", ["_tag", "", [""]], ["_priority", 1, [1]], ["_minInterval", 1, [0]]];

			pr _cat = PROCESS_CATEGORY_NEW(_tag, _priority, _minInterval);
			pr _cats = T_GETV("processCategories"); // meow ^.^
			_cats pushBack _cat;

			// Update process time fractions
			pr _fractions = T_GETV("processTimeFractions");
			_fractions resize (count _cats);
			pr _sum = 0; // Sum of all priorities
			for "_i" from 0 to ((count _cats) - 1) do {
				pr _priority = _cats#_i#PROCESS_CATEGORY_ID_PRIORITY;
				_fractions set [_i, _priority];
				_sum = _sum + _priority;
			};
			for "_i" from 0 to ((count _cats) - 1) do {
				_fractions set [_i, (_fractions#_i)/_sum];
			};
		};
	} ENDMETHOD;

	METHOD("addProcessCategoryObject") {
		CRITICAL_SECTION {
			params ["_thisObject", ["_tag", "", [""]], ["_object", "", [""]]];

			// Find category with given tag
			pr _cats = T_GETV("processCategories");
			pr _index = _cats findIf {(_x select PROCESS_CATEGORY_ID_TAG) == _tag};
			if (_index != -1) then {
				pr _cat = _cats select _index;
				pr _objs = _cat select PROCESS_CATEGORY_ID_OBJECTS;
				_objs pushBack PROCESS_CATEGORY_OBJECT_NEW(_object);
			} else {
				OOP_ERROR_1("Process category with tag %1 was not found!", _tag);
			};
		};
	} ENDMETHOD;

	METHOD("deleteProcessCategoryObject") {
		CRITICAL_SECTION {
			params ["_thisObject", ["_object", "", [""]]];

			pr _cats = T_GETV("processCategories");
			{
				pr _objs = _x select PROCESS_CATEGORY_ID_OBJECTS;
				pr _index = _objs findIf {_x select 0 == _object};
				//if (_index != -1) then {
					_objs deleteAt _index;
					//true // No need to search any more
				//} else {
				//	false // Need to search other categories, this object is not here
				//};
			} forEach _cats;
		};
	} ENDMETHOD;

ENDCLASS;
