#include "..\common.h"
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

#define OOP_CLASS_NAME MessageReceiverEx
CLASS("MessageReceiverEx", "MessageReceiver")

	VARIABLE_ATTR("refCount", [ATTR_SAVE]);

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("refCount", 0);
	ENDMETHOD;
	
	// todo check reference count on deletion
	/*
	METHOD(delete)
		params [P_THISOBJECT];
	ENDMETHOD;
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
	public override METHOD(handleMessage)
		params [P_THISOBJECT, P_ARRAY("_msg")];
		private _msgType = _msg select MESSAGE_ID_TYPE; // Message type is the function name
		private _return = nil;
		if (_msgType isEqualType "") then {
			_methodParams = (_msg select MESSAGE_ID_DATA);
			_return = T_CALLM(_msgType, _methodParams);
		} else {
			if(_msgType isEqualType {}) then {
				_methodParams = (_msg select MESSAGE_ID_DATA);
				_return = _methodParams call _msgType;
			} else {
				_return = T_CALLM("handleMessageEx", [_msg]);
			};
		};
		// Did the method return anything?
		if (isNil "_return") then {	0 } else { _return }
	ENDMETHOD;

	/*
	Method: handleMessageEx
	Alternative to <MessageReceiver.handleMessage>.
	Override if your MessageReceiverEx-derived class must also handle common messages.

	Parameters: _msg

	_msg - received message

	Returns: you can return whatever you need from here to later retrieve it by waitUntilMessageDone.
	*/
	public virtual METHOD(handleMessageEx)
		params [P_THISOBJECT , P_ARRAY("_msg") ];
		diag_log format ["[MessageReceiverEx] handleMessageEx: %1", [_msg]];
		false
	ENDMETHOD;

	/*
	Method: postMethodAsync
	Post the method name into the message queue of the object's thread and exits immediately without waiting for it to handle the message.

	Parameters: _methodName, _methodParams, _returnMsgID

	_methodNameOrCode - String, name of the method that will be called, OR code/function to run.
	_params - Array with parameters to be passed to the method
	_returnMsgIDOrContinuation - Optional
		Either: 
			_returnMsgID - Bool, see <MessageReceiver.postMessage>
		Or:
			_continuation - Array like [methodNameOrCode, params, object], defines a callback function
				methodNameOrCode - String or Code, the method to call in this thread once the message is processed
				params - Array of parameters to pass to _conNameOrCode
				messageReceiver - MessageReceiverEx instance to callback on
	Returns: message ID, number, see <MessageReceiver.postMessage>
	*/
	//
	// Returns: the ID of the posted message
	public METHOD(postMethodAsync)
		params [P_THISOBJECT, ["_methodNameOrCode", "", ["", {}]], P_ARRAY("_params"), ["_returnMsgIDOrContinuation", false, [false, []]]];
#ifndef _SQF_VM
		private _msg = MESSAGE_NEW();
		_msg set [MESSAGE_ID_TYPE, _methodNameOrCode];
		_msg set [MESSAGE_ID_DATA, _params]; // Array to return data to, method parameters
		return T_CALLM2("postMessage", _msg, _returnMsgIDOrContinuation);
#else
		// What shall we do for async fire and forget?
		return -1;
#endif
	ENDMETHOD;

	/*
	Method: postMethodSync
	Post the method name into the message queue of the object's thread and waits until the message is handled.

	Warning: must be called in scheduled environment, obviously.

	Parameters: _methodName, _methodParams

	_methodNameOrCode - String, name of the method that will be called, OR code/function to run.
	_methodParams - Array with parameters to be passed to the method

	Returns: whatever was returned by this object
	*/
	public METHOD(postMethodSync)
		params [P_THISOBJECT, ["_methodNameOrCode", "", ["", {}]], P_ARRAY("_methodParams") ];
#ifndef _SQF_VM
		private _msg = MESSAGE_NEW();
		_msg set [MESSAGE_ID_TYPE, _methodNameOrCode];
		_msg set [MESSAGE_ID_DATA, _methodParams];
		private _msgID = T_CALLM("postMessage", [_msg ARG true]);
		// Return whatever was returned by this object
		return T_CALLM("waitUntilMessageDone", [_msgID]);
#else
		// In testing just call the function synchronously
		if(_methodNameOrCode isEqualType "") then {
			return T_CALLM(_methodNameOrCode, _methodParams)
		} else {
			return _methodParams call _methodNameOrCode
		};
#endif
	ENDMETHOD;
	
	// - - - - REFERENCE COUNTER - - - -
	
	METHOD(ref)
		params [P_THISOBJECT];
		CRITICAL_SECTION {
			T_SETV("refCount", T_GETV("refCount") + 1);
		};
		nil // return this to make SQF happy (isNil returns nothing, not nil)
	ENDMETHOD;

	METHOD(unref)
		params [P_THISOBJECT];
		pr _mustDelete = false;

		CRITICAL_SECTION {
			pr _refCount = T_GETV("refCount");
			_refCount = _refCount - 1;
			if(_refCount <= 0) then {
				_mustDelete = true;
			} else {
				T_SETV("refCount", _refCount);
			};
		};

		// If refcount is zero, delete the object outside of critical section, because child classes might need to synchronize with other threads
		if (_mustDelete) then {
			DELETE(_thisObject);
		};

		nil
	ENDMETHOD;

	// - - - - - STORAGE - - - - - -
	
	public override METHOD(postDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		// Call method of all base classes
		T_CALLCM1("MessageReceiver", "postDeserialize", _storage);

		true
	ENDMETHOD;

ENDCLASS;
