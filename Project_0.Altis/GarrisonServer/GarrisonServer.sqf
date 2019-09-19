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

#define __JIP_ID_SUFFIX "_srv_update"

CLASS("GarrisonServer", "MessageReceiverEx")

	// Array with garrisons which have just been created
	VARIABLE("createdObjects");

	// Array with garrisons for which update events will be broadcasted at next update cycle
	VARIABLE("outdatedObjects");
	
	// Array with garrisons for which destroyed events will be broadcasted at next update cycle
	VARIABLE("destroyedObjects");

	VARIABLE("timer");
	VARIABLE("timer1");

	METHOD("new") {
		params [P_THISOBJECT];

		T_SETV("outdatedObjects", []);
		T_SETV("destroyedObjects", []);
		T_SETV("createdObjects", []);

		// Timer to send garrison update messages
		private _msg = MESSAGE_NEW();
		_msg set [MESSAGE_ID_DESTINATION, _thisObject];
		_msg set [MESSAGE_ID_SOURCE, ""];
		_msg set [MESSAGE_ID_DATA, []];
		_msg set [MESSAGE_ID_TYPE, "process"];
		pr _processInterval = 1;
		private _args = [_thisObject, _processInterval, _msg, gTimerServiceMain]; // message receiver, interval, message, timer service
		private _timer = NEW("Timer", _args);
		SETV(_thisObject, "timer", _timer);

	} ENDMETHOD;

	// Sends update messages about a garrison(_gar) to _target(same as remoteExecCall target)
	METHOD("_sendUpdate") {
		params [P_THISOBJECT, P_OOP_OBJECT("_gar"), "_target"];

		// Create a GarrisonRecord to serialize it (to deserialize it at the client machine)
		pr _tempRecord = NEW("GarrisonRecord", [_gar]);
		CALLM1(_tempRecord, "initFromGarrison", _gar);
		pr _serArray = SERIALIZE(_tempRecord);
		DELETE(_tempRecord);

		OOP_INFO_2("SEND UPDATE Garrison: %1, target: %2", _gar, _target);
		OOP_INFO_1("  data: %1", _serArray);

		// Now we can send the serialized array
		pr _jipid = _gar + __JIP_ID_SUFFIX;
		REMOTE_EXEC_CALL_STATIC_METHOD("GarrisonDatabaseClient", "update", [_serArray], _target, _jipid); // classNameStr, methodNameStr, extraParams, targets, JIP
	} ENDMETHOD;

	// We only receive messages from timer now, so we don't care about the message type
	// - - - - Processing of garrisons - - - - -
	METHOD("process") {
		params [P_THISOBJECT];

		// Broadcast update messages
		// This also corresponds to just created garrisons as they are outdated
		pr _outdatedGarrisons = T_GETV("outdatedObjects") + T_GETV("createdObjects");
		if (count _outdatedGarrisons > 0) then { OOP_INFO_1("OUTDATED: %1", _outdatedGarrisons); };
		{
			pr _gar = _x;
			if (IS_OOP_OBJECT(_gar)) then {
				if (CALLM0(_gar, "isAlive")) then { // We only serve update events here
					pr _side = GETV(_gar, "side");
					T_CALLM2("_sendUpdate", _gar, _side); // Send data to all clients of same side as this garrison
				};
			};
		} forEach _outdatedGarrisons;

		// Broadcast destroyed events
		pr _destroyedGarrisons = T_GETV("destroyedObjects");
		if (count _destroyedGarrisons > 0) then { OOP_INFO_1("DESTROYED: %1", _destroyedGarrisons); };
		// Just send data to everyone, those who don't care about these objects will just ignore them
		{
			pr _sides = [EAST, WEST, INDEPENDENT, CIVILIAN];
			REMOTE_EXEC_CALL_STATIC_METHOD("GarrisonDatabaseClient", "destroy", [_x], _sides, false); // Execute on all machines with interface, don't add to JIP!
			// Remove the message from the JIP queue
			pr _jipid = _x + __JIP_ID_SUFFIX;
			remoteExecCall ["", _jipid];
		} forEach _destroyedGarrisons;

		// Reset the arrays of garrisons to broadcast
		T_SETV("outdatedObjects", []);
		T_SETV("destroyedObjects", []);
		T_SETV("createdObjects", []);

	} ENDMETHOD;


	// Called when a client has connected
	METHOD("onClientConnected") {
		params [P_THISOBJECT, P_NUMBER("_clientOwner"), P_SIDE("_side")];

		OOP_INFO_2("CLIENT CONNECTED: %1, side: %2", _clientOwner, _side);

		// Transmit data about all garrisons with the same side
		pr _garrisons = CALLSM2("Garrison", "getAllActive", [_side], []);
		{
			T_CALLM2("_sendUpdate", _x, _side); // Send data to all clients of same side as this garrison
		} forEach _garrisons;

	} ENDMETHOD;


	// - - - - Methods to be called by garrison on various events - - - - 

	// Marks the garrison as just created
	METHOD("onGarrisonCreated") {
		params [P_THISOBJECT, P_OOP_OBJECT("_gar")];

		T_GETV("createdObjects") pushBackUnique _gar;
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

		// Make sure we don't send an update event about it any more
		pr _outdatedObjects = T_GETV("outdatedObjects");
		_outdatedObjects deleteAt (_outdatedObjects find _gar);
	} ENDMETHOD;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 




	// GarrisonServer is attached to the main message loop
	METHOD("getMessageLoop") {
		gMessageLoopMain
	} ENDMETHOD;

ENDCLASS;