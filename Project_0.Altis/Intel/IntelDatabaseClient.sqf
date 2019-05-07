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

			CALL_CLASS_METHOD("IntelDatabase", _thisObject, "addIntel", [_item]);

			// Add the new data to client's UI
			CALLM0(_item, "clientAdd"); // Register in the client's UI
		};
	} ENDMETHOD;


	METHOD("updateIntel") {
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_itemDst"), P_OOP_OBJECT("_itemSrc")];

			CALLM1(_itemDst, "clientUpdate", _itemSrc);

			CALL_CLASS_METHOD("IntelDatabase", _thisObject, "updateIntel", [_itemDst ARG _itemSrc]); // It will copy values
		};
	} ENDMETHOD;

	METHOD("removeIntel") {
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_item")];

			CALLM1(_itemDst, "clientRemove", _itemSrc);

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
		params [P_THISCLASS, P_ARRAY("_serialIntel")];

		// Get class name and object name from the array
		pr _intelClassName = SERIALIZED_CLASS_NAME(_serialIntel);
		pr _intelObjName = SERIALIZED_OBJECT_NAME(_serialIntel);

		// Check if we have such an intel object
		if (CALLM1(gIntelDatabaseClient, "isIntelAdded", _intelObjName)) then {
			// We already have it, let's update it in the database then!

			// Create a temporary intel object to deserialize new data into it
			pr _tempIntel = NEW(_intelClassName, []);

			// Unpack serialized intel object into a temporary one
			DESERIALIZE(_tempIntel, _serialIntel);

			// Update existing intel item from the temp object
			CALLM2(gIntelDatabaseClient, "updateIntel", _intelObjName, _tempIntel);

			// Delete the temporary object
			DELETE(_tempIntel);
		} else {
			// Create an intel object and add it to database

			// Create a new intel object with existing ref if needed
			// If we self host it's possible that we already have an Intel object with this ref in mission namespace
			if (!IS_OOP_OBJECT(_intelObjName)) then {
				NEW_EXISTING(_intelClassName, _intelObjName);
			};

			// Unpack serialized intel object
			DESERIALIZE(_intelObjName, _serialIntel);

			// Add the intel item to database
			CALLM1(gIntelDatabaseClient, "addIntel", _intelObjName);
		};

	} ENDMETHOD;

ENDCLASS;