#include "..\OOP_Light\OOP_Light.h"
#include "..\Mutex\Mutex.hpp"
#include "..\CriticalSection\CriticalSection.hpp"
#include "..\Message\Message.hpp"

/*
Class: MessageLoop
MessageLoop is a thread (a spawned script) which can have
MessageLoop, when created, spawns a thread which waits for messages to get into its queue. Then it routes messages to specific objects or to itself.

Author: Sparker
15.06.2018
*/

//#define DEBUG

#define pr private

MessageLoop_fnc_threadFunc = compile preprocessFileLineNumbers "MessageLoop\fn_threadFunc.sqf";

CLASS("MessageLoop", "")

	//Array with messages
	VARIABLE("msgQueue");	
	//Handle to the script which does message processing
	VARIABLE("scriptHandle");	
	//Array with objects handled by this message loop
	VARIABLE("objects");
	//Counter for messages posted into the queue
	VARIABLE("msgPostID");
	//Counter for messages processed by the function
	VARIABLE("msgDoneID");
	//Mutex for accessing the message queue
	VARIABLE("mutex");
	//Debug name to help read debug printouts
	VARIABLE("debugName");

	//Constructor
	//Spawn a script which will be checking messages
	/*
	Method: new
	Constructor
	*/
	METHOD("new") {
		params [ ["_thisObject", "", [""]] ];		
		SET_VAR(_thisObject, "msgQueue", []);
		SET_VAR(_thisObject, "objects", []);
		SET_VAR(_thisObject, "msgPostID", 0);
		SET_VAR(_thisObject, "msgDoneID", 0);
		private _scriptHandle = [_thisObject] spawn MessageLoop_fnc_threadFunc;		
		SET_VAR(_thisObject, "scriptHandle", _scriptHandle);	
		SET_VAR(_thisObject, "mutex", MUTEX_NEW());
	} ENDMETHOD;
	
	/*
	Method: delete
	Deletes this thread.
	
	After the thread is deleted, objects can no longer process messages through it.
	
	Warning: must be called in scheduled environment!
	*/
	METHOD("delete") {
		params [ ["_thisObject", "", [""]] ];
		private _mutex = GET_VAR(_thisObject, "mutex");
		MUTEX_LOCK(_mutex); //Make sure we don't terminate the thread after it locks the mutex!
		//Clear the variables
		private _scriptHandle = GET_VAR(_thisObject, "scriptHandle");
		terminate _scriptHandle;
		SET_VAR(_thisObject, "msgQueue", nil);
		SET_VAR(_thisObject, "objects", nil);
		SET_VAR(_thisObject, "msgPostID", nil);
		SET_VAR(_thisObject, "msgDoneID", nil);	
		SET_VAR(_thisObject, "scriptHandle", nil);		
		MUTEX_UNLOCK(_mutex);
		SET_VAR(_thisObject, "mutex", nil);
	} ENDMETHOD;
	
	
	/*
	Method: setDebugName
	Sets debug name of this MessageLoop.
	
	Parameters: _debugName
	
	_debugName - String
	
	Returns: nil
	*/
	METHOD("setDebugName") {
		params [["_thisObject", "", [""]], ["_debugName", "", [""]]];
		SET_VAR(_thisObject, "debugName", _debugName);
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
		#ifdef DEBUG
		diag_log format ["[MessageLoop::postMessage] params: %1", _this];
		#endif
		params [ ["_thisObject", "", [""]], ["_msg", [], [[]]]];
		
		//Start critical section
		// Nothing must interrupt the message pushing into the queue, even event handlers
		//private _ID = -1; // Because we can't return a variable from a critical section
		CRITICAL_SECTION_START
		
		private _msgQueue = GET_VAR(_thisObject, "msgQueue");
		_msgQueue pushBack _msg;
		
		//Increase the posted msg ID counter
		//_ID = GET_VAR(_thisObject, "msgPostID");
		//SET_VAR(_thisObject, "msgPostID", _ID + 1);
		
		// Stop critical section
		CRITICAL_SECTION_END
		
		//Return the message ID
		//_ID
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
		params [ ["_thisObject", "", [""]], ["_msgReceiver", "", [""]] ];
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
	
ENDCLASS;