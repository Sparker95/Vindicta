#include "common.hpp"

#define pr private

/*
Class: GarrisonDatabaseClient
Singleton client-only class.
Stores data about garrisons on client side.
Receives data from GarrisonServer.

Author: Sparker 23 August 2019
*/

#define OOP_CLASS_NAME GarrisonDatabaseClient
CLASS("GarrisonDatabaseClient", "")

	// Hashmap that maps actual garrison references to garrison records
	VARIABLE("hm");

	VARIABLE("allRecords");

	METHOD(new)
		params [P_THISOBJECT];

		#ifndef _SQF_VM
		pr _ns = [false] call CBA_fnc_createNamespace;
		T_SETV("hm", _ns);
		#endif

		T_SETV("allRecords", []);
	ENDMETHOD;

	// It really never gets deleted now, so we don't care about it
	METHOD(delete)
		params [P_THISOBJECT];

		pr _ns = T_GETV("hm");
		_ns call CBA_fnc_deleteNamespace;
	ENDMETHOD;

	METHOD(addGarrisonRecord)
		params [P_THISOBJECT, P_OOP_OBJECT("_garRecord")];

		OOP_INFO_1("ADD GARRISON RECORD: %1", _garRecord);

		// Add the garrison reference to the hashmap
		pr _hm = T_GETV("hm");
		pr _garRef = GETV(_garRecord, "garRef");
		_hm setVariable [_garRef, _garRecord];

		// Initialize the client-side data of the GarrisonRecord
		CALLM0(_garRecord, "clientAdd");

		T_GETV("allRecords") pushBack _garRecord;
	ENDMETHOD;

	METHOD(deleteGarrisonRecord)
		params [P_THISOBJECT, P_OOP_OBJECT("_garRecord")];

		OOP_INFO_1("DELETE GARRISON RECORD: %1", _garRecord);

		// Remove it from the hashmap
		pr _hm = T_GETV("hm");
		pr _garRef = GETV(_garRecord, "garRef");
		_hm setVariable [_garRef, nil];

		// Destroy the GarrisonRecord
		CALLM0(_garRecord, "clientRemove");
		DELETE(_garRecord);

		pr _allrecords = T_GETV("allRecords");
		_allRecords deleteAt (_allRecords find _garRecord);
	ENDMETHOD;

	// Returns garrison record associated with this garrison reference
	METHOD(getGarrisonRecord)
		params [P_THISOBJECT, P_STRING("_garRef")];

		pr _hm = T_GETV("hm");
		_hm getVariable [_garRef, ""]
	ENDMETHOD;

	// Returns an array of existing records which are pointing at the specified _garRef
	METHOD(getLinkedGarrisonRecords)
		params [P_THISOBJECT, "_garRef"];
		//OOP_INFO_1("GET LINKED GARRISON RECORDS: %1", _garRef);
		pr _allRecords = T_GETV("allRecords");
		//OOP_INFO_1("ALL RECORDS: %1", _allRecords);
		pr _return = _allRecords select {
			pr _actionRecord = GETV(_x, "cmdrActionRecord");
			//OOP_INFO_2("  RECORD: %1, ACTION RECORD: %2", _x, _actionRecord);
			// Check if there is an action record
			if (_actionRecord != "") then {
				// Check if the action record has a garrison reference
				pr _recordDstGarRef = FORCE_GET_MEM(_actionRecord, "dstGarRef");
				if (isNil "_recordDstGarRef") then {
					false
				} else {
					_recordDstGarRef == _garRef
				};
			} else {
				false
			};
		};
		//OOP_INFO_1("RETURN: %1", _return);
		_return
	ENDMETHOD;

	// - - - - - - Remotely executed static methods (by GarrisonServer) - - - - - - 

	STATIC_METHOD(destroy)
		params [P_THISCLASS, P_STRING("_garRef")];
		_thisClass = "GarrisonDatabaseClient";

		OOP_INFO_1("DESTROY: %1", _garRef);

		// The global garrison database
		pr _object = gGarrisonDBClient;
		//if (isNil "_object") exitWith{}; // Sanity check

		// Check if we have a local record about this garrison
		pr _hm = GETV(_object, "hm");
		pr _garRecordLocal = _hm getVariable _garRef;
		if (isNil "_garRecordLocal") then {
			// We don't have a record of such garrison anyway, ignore it
		} else {
			CALLM1(_object, "deleteGarrisonRecord", _garRecordLocal);
		};
	ENDMETHOD;

	// Receives a serialized GarrisonRecord from the GarrisonServer
	STATIC_METHOD(update)
		params [P_THISCLASS, P_ARRAY("_recordSerial")];
		_thisClass = "GarrisonDatabaseClient";

		OOP_INFO_1("UPDATE: %1", _recordSerial);

		// The global garrison database
		pr _object = gGarrisonDBClient;
		//if (isNil "_object") exitWith{}; // Sanity check

		pr _garRecord = NEW("GarrisonRecord", []);
		DESERIALIZE(_garRecord, _recordSerial);

		pr _garRef = GETV(_garRecord, "garRef");

		// Check if we have a local record about this garrison
		pr _hm = GETV(_object, "hm");
		pr _garRecordLocal = _hm getVariable _garRef;
		if (isNil "_garRecordLocal") then {
			// Store the just-created GarrisonRecord
			CALLM1(_object, "addGarrisonRecord", _garRecord);
		} else {
			// Update data and then delete it
			CALLM1(_garRecordLocal, "clientUpdate", _garRecord);
			DELETE(_garRecord); // We have copied data and don't need this any more
		};
	ENDMETHOD;

ENDCLASS;