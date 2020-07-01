#include "common.hpp"
/*
Class: MessageLoopGroupManager
It's a MessageReceiverEx which is always attached to the gMessageLoopMain.
We need it to perform different synchronization tasks with the message loop.
We need an object which is always in the thread to send messages to it.
*/

#define pr private

#define OOP_CLASS_NAME MessageLoopGroupManager
CLASS("MessageLoopGroupManager", "MessageReceiverEx");

	/*
	Method: deleteObject
	Deletes object in this thread.

	Returns: nil
	*/
	public METHOD(deleteObject)
		params [P_THISOBJECT, P_OOP_OBJECT("_objectRef")];
		if (IS_OOP_OBJECT(_objectRef)) then {
			DELETE(_objectRef);
		} else {
			OOP_ERROR_1("deleteObject: invalid object ref: %1", _objectRef);
		};
		0
	ENDMETHOD;

	public METHOD(stopAIobject)
		params [P_THISOBJECT, P_OOP_OBJECT("_objectRef")];

		if (IS_OOP_OBJECT(_objectRef)) then {
			CALLM0(_objectRef, "stop");
		} else {
			OOP_ERROR_1("stopAIObject: invalid object ref: %1", _objectRef);
		};
		0
	ENDMETHOD;

	public override METHOD(getMessageLoop)
		gMessageLoopUnscheduled
	ENDMETHOD;

	// We use that to call some static methods in the main thread
	public METHOD(callStaticMethodInThread)
		params [P_THISOBJECT, P_STRING("_className"), P_STRING("_methodName"), P_ARRAY("_parameters")];
		OOP_INFO_1("callStaticMethodInThread: %1", _this);
		SCOPE_ACCESS_MIMIC(_className);
		CALLSM(_className, _methodName, _parameters);
	ENDMETHOD;

ENDCLASS;