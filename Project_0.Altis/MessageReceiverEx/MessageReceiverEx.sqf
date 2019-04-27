#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\CriticalSection\CriticalSection.hpp"

/*
Class: MessageReceiver.MessageReceiverEx
This is an extended <MessageReceiver>. It provides several functions to aid in synchronization.
It is useful for objects which need some methods to be executed synchronously or asynchnonously in different situations.

It works by overriding handleMessage method and making all String <Message> types represent method names to call.

Author: Sparker, Billw (reference count improvements)
16.07.2018
*/

#define pr private

CLASS("MessageReceiverEx", "MessageReceiver")

	VARIABLE("refCount");

	METHOD("new") {
		params ["_thisObject"];
		T_SETV("refCount", 0);
	} ENDMETHOD;
	
	// todo check reference count on deletion
	/*
	METHOD("delete") {
		params ["_thisObject"];
	} ENDMETHOD;
	*/
	
	/*
	Method: handleMessage
	See <MessageReceiver.handleMessage>.

	It overrides handleMessage method and makes all String <Message> types represent method names to call.
	If the received message type is not String, it calles the handleMessageEx method.

	Warning: String <Message> types will be treated as function names to call them.
	Therefore don't use String Message types in inherited classes.

	Access: internal use.

	Parameters: _msg

	_msg - message

	Returns: nil
	*/
	METHOD("handleMessage") {
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		private _msgType = _msg select MESSAGE_ID_TYPE; // Message type is the function name
		if (_msgType isEqualType "") then {
			_methodParams = (_msg select MESSAGE_ID_DATA);
			//diag_log format ["----- postMethodAsync: methodParams is array: %1", _methodParams isEqualType []];
			private _return = (CALL_METHOD(_thisObject, _msgType, _methodParams));
			// Did the method return anything?
			if (isNil "_return") then {	_return = 0; };
			_return
		} else {
			private _return = CALL_METHOD(_thisObject, "handleMessageEx", [_msg]);
			if (isNil "_return") then {	_return = 0; };
			_return
		};
	} ENDMETHOD;

	/*
	Method: handleMessageEx
	Alternative to <MessageReceiver.handleMessage>.
	Override if your MessageReceiverEx-derived class must also handle common messages.

	Parameters: _msg

	_msg - received message

	Returns: you can return whatever you need from here to later retrieve it by waitUntilMessageDone.
	*/
	METHOD("handleMessageEx") {
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		diag_log format ["[MessageReceiverEx] handleMessageEx: %1", [_msg]];
		false
	} ENDMETHOD;

	/*
	Method: postMethodAsync
	Post the method name into the message queue of the object's thread and exits immediately without waiting for it to handle the message.

	Parameters: _methodName, _methodParams, _returnMsgID

	_methodName - String, name of the method that will be called
	_methodParams - Array with parameters to be passed to the method
	_returnMsgID - Optional, Bool, see <MessageReceiver.postMessage>

	Returns: message ID, number, see <MessageReceiver.postMessage>
	*/
	//
	// Returns: the ID of the posted message
	METHOD("postMethodAsync") {
		params [["_thisObject", "", [""]], ["_methodName", "", [""]], ["_methodParams", [], [[]]], ["_returnMsgID", false]];
#ifndef _SQF_VM
		private _msg = MESSAGE_NEW();
		_msg set [MESSAGE_ID_TYPE, _methodName];
		_msg set [MESSAGE_ID_DATA, _methodParams]; // Array to return data to, method parameters
		private _return = T_CALLM("postMessage", [_msg]+[_returnMsgID]);
#else
		// What shall we do for async fire and forget?
		private _return = -1;
#endif

		// Return the message ID (if it was requested)
		_return
	} ENDMETHOD;

	/*
	Method: postMethodSync
	Post the method name into the message queue of the object's thread and waits until the message is handled.

	Warning: must be called in scheduled environment, obviously.

	Parameters: _methodName, _methodParams

	_methodName - String, name of the method that will be called
	_methodParams - Array with parameters to be passed to the method

	Returns: whatever was returned by this object
	*/
	METHOD("postMethodSync") {
		params [["_thisObject", "", [""]], ["_methodName", "", [""]], ["_methodParams", [], [[]]] ];
#ifndef _SQF_VM
		private _msg = MESSAGE_NEW();
		_msg set [MESSAGE_ID_TYPE, _methodName];
		_msg set [MESSAGE_ID_DATA, _methodParams];
		private _msgID = T_CALLM("postMessage", [_msg]+[true]);
		pr _return = T_CALLM("waitUntilMessageDone", [_msgID]);
#else
		// In testing just call the function synchronously
		pr _return = T_CALLM(_methodName, _methodParams);
#endif
		// Return whatever was returned by this object
		_return
	} ENDMETHOD;
	
	// - - - - REFERENCE COUNTER - - - -
	
	 METHOD("ref") {
	 	params ["_thisObject"];
	 	CRITICAL_SECTION_START
        T_SETV("refCount", T_GETV("refCount") + 1);
        CRITICAL_SECTION_END
        nil // return this to make SQF happy (= operator returns nothing, not nil)
    } ENDMETHOD;

    METHOD("unref") {
    	params ["_thisObject"];
    	pr _mustDelete = false;
    	
    	// Start critical section
    	CRITICAL_SECTION_START
    	pr _refCount = T_GETV("refCount");
        _refCount = _refCount - 1;
        if(_refCount <= 0) then {
            _mustDelete = true;
        } else {
        	T_SETV("refCount", _refCount);
        };
        CRITICAL_SECTION_END
        
        // If refcount is zero, delete the object outside of critical section, because child classes might need to synchronize with other threads
        if (_mustDelete) then {
        	DELETE(_thisObject);
        };
        
        nil
    } ENDMETHOD;

ENDCLASS;
