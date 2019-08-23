#include "common.hpp"

/*
Class: GarrisonServer
Singleton server-only class.
Collects garrisons which have changed their state and sends periodic updates about garrisons to clients which need the data.

When garrison data updates (composition, etc) many times in a short period of time we don't want to send new data on each update,
but we want to send new data at a specific rate.

Author: Sparker 23 August 2019
*/

#define pr private

CLASS("GarrisonServer", "MessageReceiverEx")

	// Array with garrisons for which update events will be broadcasted at next update cycle
	VARIABLE("outdatedObjects");
	
	// Array with garrisons for which destroyed events will be broadcasted at next update cycle
	VARIABLE("destroyedObjects");

	METHOD("new") {
		params [P_THISOBJECT];

		T_SETV("outdatedObjects", []);
		T_SETV("destroyedObjects", []);

		private _msg = MESSAGE_NEW();
		_msg set [MESSAGE_ID_DESTINATION, _thisObject];
		_msg set [MESSAGE_ID_SOURCE, ""];
		_msg set [MESSAGE_ID_DATA, 0];
		_msg set [MESSAGE_ID_TYPE, GARRISON_SERVER_MESSAGE_PROCESS];
		pr _processInterval = 1;
		private _args = [_thisObject, _processInterval, _msg, gTimerServiceMain]; // message receiver, interval, message, timer service
		private _timer = NEW("Timer", _args);
		SETV(_thisObject, "timer", _timer);
	} ENDMETHOD;

	// Marks the garrison requiring an update broadcast
	METHOD("onGarrisonOutdated") {
		params [P_THISOBJECT, P_OOP_OBJECT("_gar")];

		T_GETV("outdatedObjects") pushBackUnique _gar;
	} ENDMETHOD;

	// Marks the garrison requiring a destroyed event broadcast
	METHOD("onGarrisonDestroyed") {
		params [P_THISOBJECT, P_OOP_OBJECT("_gar")];

		T_GETV("destroyedObjects") pushBackUnique _gar;

		// Make sure we don't send an update event
		pr _outdatedObjects = T_GETV("outdatedObjects");
		_outdatedObjects deleteAt (_outdatedObjects find _gar);
	} ENDMETHOD;

	// We only receive messages from timer now, so we don't care about the message type
	METHOD("handleMessageEx") {
		params [P_THISOBJECT];

		// Broadcast destroyed events
		pr _destroyedGarrisons = T_GETV("destroyedGarrisons");
		// Just send data to everyone, those who don't care about these objects will just ignore them
		
		{

		} forEach _destroyedGarrisons;

		// Broadcast update messages
		pr _outdatedGarrisons = T_GETV("outdatedObjects");
		{
			pr _gar = _x;
			if (IS_OOP_OBJECT(_gar)) then {
				if (CALLM(_gar, "isAlive")) then { // We only serve update events here
					
				};
			};
		} forEach _outdatedObjects;

	} ENDMETHOD;

	// GarrisonServer is attached to the main message loop
	METHOD("getMessageLoop") {
		gMsgLoopMain
	} ENDMETHOD;

ENDCLASS;