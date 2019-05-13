#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Intel.rpt"
#include "..\OOP_Light\OOP_Light.h"

/*
Class: IntelDatabase.IntelDatabaseClient

A database that is meant to be created at client.
It receives data from IntelDatabaseServer.

Author: Sparker 07.05.2019 
*/

#define pr private

CLASS("IntelDatabaseClient", "IntelDatabase")

	METHOD("addIntel") {
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_item")];

			// Call base class method
			CALL_CLASS_METHOD("IntelDatabase", _thisObject, "addIntel", [_item]);

			// Add the new data to client's UI
			CALLM0(_item, "clientAdd"); // Register in the client's UI
		};
	} ENDMETHOD;


	METHOD("updateIntel") {
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_itemDst"), P_OOP_OBJECT("_itemSrc")];

			CALLM1(_itemDst, "clientUpdate", _itemSrc);

			// Call base class method
			CALL_CLASS_METHOD("IntelDatabase", _thisObject, "updateIntel", [_itemDst ARG _itemSrc]); // It will copy values
		};
	} ENDMETHOD;

	METHOD("removeIntel") {
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_item")];

			CALLM1(_item, "clientRemove", _item);

			CALL_CLASS_METHOD("IntelDatabase", _thisObject, "removeIntel", [_item]); // It will copy values
		};
	} ENDMETHOD;

	/*
	Method: (static)updateIntelClient
	Gets called remotely or from JIP to synchronize intel items to client.

	Parameters: _serialIntel

	_serialIntel - a serialized <Intel> object

	Returns: nil
	*/
	STATIC_METHOD("updateIntelClient") {
		CRITICAL_SECTION {
			params [P_THISCLASS, P_ARRAY("_serialIntel")];

			//diag_log format ["_thisObject: %1", _thisObject];
			//ade_dumpCallstack;
			//if (true) exitWith {};

			// Get class name and object name from the array
			pr _intelClassName = SERIALIZED_CLASS_NAME(_serialIntel);
			pr _intelObjName = SERIALIZED_OBJECT_NAME(_serialIntel);

			// Create a new intel object with existing ref if needed
			// If we self host it's possible that we already have an Intel object with this ref in mission namespace
			private _delete = false; // No need to delete the object if we have it already in SP because it's in commander's DB!
			if (!IS_OOP_OBJECT(_intelObjName)) then {
				NEW_EXISTING(_intelClassName, _intelObjName);

				// Unpack serialized intel object into a ref equal to the external intel object
				// If we play singleplayer we might already have it, so no need to deserialize it
				DESERIALIZE(_intelObjName, _serialIntel);
			};

			// Check if we have such an intel object
			if (CALLM1(gIntelDatabaseClient, "isIntelAdded", _intelObjName)) then {
				// We already have it, let's update it in the database

				// Update existing intel item from the temp object
				CALLM1(gIntelDatabaseClient, "updateIntelFromSource", _intelObjName);

			} else {
				// Create an intel object and add it to database

				OOP_INFO_1("Received serial intel object: %1", _serialIntel);

				//diag_log format ["_thisObject: %1", _thisObject];
				//ade_dumpCallstack;

				// Copy this intel object to add the copy to database
				// Set the ref to the external intel object as source for the local copy
				pr _intelCopy = CLONE(_intelObjName);
				SETV(_intelCopy, "source", _intelObjName);
				
				// Add the intel item to database
				CALLM1(gIntelDatabaseClient, "addIntel", _intelCopy);
			};

			// Delete the external intel item
			if (_delete) then {	DELETE(_intelObjName); };
		};
	} ENDMETHOD;

ENDCLASS;