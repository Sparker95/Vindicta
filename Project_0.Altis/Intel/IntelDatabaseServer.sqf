#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Intel.rpt"
#include "..\OOP_Light\OOP_Light.h"

/*
Class: IntelDatabase.IntelDatabaseServer

A database that is meant to be created at the server.
When items are added or updated, it synchronizes intel with clients.

Author: Sparker 07.05.2019 
*/

#define pr private

OOP_INFO_0("Compiling IntelDatabaseServer");
CLASS("IntelDatabaseServer", "IntelDatabase")

	METHOD("addIntel") {
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_item")];

			//OOP_INFO_1("ADD INTEL: %1", _item);

			CALL_CLASS_METHOD("IntelDatabase", _thisObject, "addIntel", [_item]);

			// Broadcast the message
			private _serialIntel = SERIALIZE(_item);
			REMOTE_EXEC_CALL_STATIC_METHOD("IntelDatabaseClient", "updateIntelClient", [_serialIntel], T_GETV("side"), _item);
		};
	} ENDMETHOD;


	METHOD("updateIntel") {
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_itemDst"), P_OOP_OBJECT("_itemSrc")];

			CALL_CLASS_METHOD("IntelDatabase", _thisObject, "updateIntel", [_itemDst ARG _itemSrc]); // It will copy values

			// Broadcast the message
			private _serialIntel = SERIALIZE(_itemDst);
			REMOTE_EXEC_CALL_STATIC_METHOD("IntelDatabaseClient", "updateIntelClient", [_serialIntel], T_GETV("side"), _itemDst);
		};
	} ENDMETHOD;

/*
	METHOD("removeIntel") {
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_item")];

			CALLM1(_itemDst, "clientRemove", _itemSrc);

			CALL_CLASS_METHOD("IntelDatabase", _thisObject, "removeIntel", [_item]); // It will copy values
		};
	} ENDMETHOD;
*/

ENDCLASS;