/*
MessageLoop class.
MessageLoop, when created, spawns a thread which waits for messages to get into its queue. Then it routes messages to specific objects or to itself.

Author: Sparker
15.06.2018
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Mutex\Mutex.hpp"
#include "..\CriticalSection\CriticalSection.hpp"

#define DEBUG

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
	
	//Adds object to the object list
	METHOD("addObject") {
		params[ ["_thisObject", "", [""]], ["_object", "", [""]] ];
	} ENDMETHOD;
	
	//Adds a message into the message queue
	METHOD("postMessage") {
		#ifdef DEBUG
		diag_log format ["[MessageLoop::postMessage] params: %1", _this];
		#endif
		params [ ["_thisObject", "", [""]], ["_msg", [], [[]]] ];
		
		//Start critical section
		// Nothing must interrupt the message pushing into the queue, even event handlers
		CRITICAL_SECTION_START
		
		private _msgQueue = GET_VAR(_thisObject, "msgQueue");
		_msgQueue pushBack _msg;
		//Increase the posted msg ID counter
		private _ID = GET_VAR(_thisObject, "msgPostID");
		SET_VAR(_thisObject, "msgPostID", _ID + 1);
		
		// Stop critical section
		CRITICAL_SECTION_END
		
		//Return the message ID
		_ID
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
	METHOD("handleMessage") {
		// For now it returns false (message not handled)
		false
	} ENDMETHOD;
	
	//Returns whether the message with specified _msgID has been processed
	METHOD("messageDone") {
		params [ ["_thisObject", "", [""]], ["_msgID", 0, [0]] ];
		private _doneID = GET_VAR(_thisObject, "msgDoneID");
		private _return = _doneID > _msgID;
		_return
	} ENDMETHOD;
	
	//Constructor
	//Spawn a script which will be checking messages
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
	
	//Destructor
	//Terminate a started script
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
	
ENDCLASS;