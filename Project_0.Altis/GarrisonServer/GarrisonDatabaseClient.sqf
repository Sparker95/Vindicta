#include "common.hpp"

#define pr private

/*
Class: GarrisonDatabaseClient
Singleton client-only class.
Stores data about garrisons on client side.
Receives data from GarrisonServer.

Author: Sparker 23 August 2019
*/

CLASS("GarrisonDatabaseClient", "")

	// Hashmap that maps actual garrison references to garrison records
	VARIABLE("hm");

	METHOD("new") {
		params [P_THISOBJECT];

		pr _ns = [false] call CBA_fnc_createNamespace;
		T_SETV("ns", _ns);
	} ENDMETHOD;

	// It really never gets deleted now, so we don't care about it
	METHOD("delete") {
		params [P_THISOBJECT];

		pr _ns = T_GETV("ns");
		_ns call CBA_fnc_deleteNamespace;
	} ENDMETHOD;

	METHOD("addGarrisonRecord") {
		params [P_THISOBJECT, P_OOP_OBJECT("_garRecord")];

		// Add the garrison reference to the hashmap
		pr _hm = T_GETV("hm");
		pr _garRef = GETV(_garRecord, "garRef");
		_hm setVariable [_garRef, _garRecord];

		// Initialize the client-side data of the GarrisonRecord
		CALLM0(_garRecord, "clientInit");

	} ENDMETHOD;

	METHOD("deleteGarrisonRecord") {
		params [P_THISOBJECT, P_OOP_OBJECT("_garRecord")];

		// Remove it from the hashmap
		pr _hm = T_GETV("hm");
		pr _garRef = GETV(_garRecord, "garRef");
		_hm setVariable [_garRef, nil];

		// Destroy the GarrisonRecord
		CALLM0(_garRecord, "clientDestroy");
	} ENDMETHOD;

	// - - - - - - Static methods called by the GarrisonServer - - - - - - 

	STATIC_METHOD("destroy") {
		params [P_THISCLASS, P_STRING("_garRef")];

		// The global garrison database
		pr _object = gGDBClient;
		//if (isNil "_object") exitWith{}; // Sanity check

		// Check if we have a local record about this garrison
		pr _hm = T_GETV("hm");
		pr _garRecordLocal = _hm getVariable _garRef;
		if (isNil "_garRecordLocal") then {
			// We don't have a record of such garrison anyway, ignore it
		} else {
			CALLM1(_object, "deleteGarrisonRecord", _garRecordLocal);
		};
	} ENDMETHOD;

	// Receives a serialized GarrisonRecord from the GarrisonServer
	STATIC_METHOD("update") {
		params [P_THISCLASS, P_OOP_OBJECT("_recordSerial")];

		// The global garrison database
		pr _object = gGDBClient;
		//if (isNil "_object") exitWith{}; // Sanity check

		pr _garRecord = NEW("GarrisonRecord", []);
		DESERIALIZE(_garRecord, _recordSerial);

		pr _garRef = GETV(_garRecord, "garRef");

		// Check if we have a local record about this garrison
		pr _hm = T_GETV("hm");
		pr _garRecordLocal = _hm getVariable _garRef;
		if (isNil "_garRecordLocal") then {
			// Store the just-created GarrisonRecord
			CALLM1(_object, "addGarrisonRecord", _garRecord);
		} else {
			// Update data and then delete it
			CALLM1(_garRecordLocal, "clientUpdate", _garRecord);
			DELETE(_garRecord); // We have copied data and don't need this any more
		};
	} ENDMETHOD;

ENDCLASS;