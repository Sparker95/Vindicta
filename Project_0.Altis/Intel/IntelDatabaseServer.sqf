#include "..\OOP_Light\OOP_Light.h"

/*
Class: IntelDatabase.IntelDatabaseServer

A database that is meant to be created at the server.
When items are added or updated, it synchronizes intel with clients.

Author: Sparker 07.05.2019 
*/

CLASS("IntelDatabaseServer", "")

	METHOD("addIntel") {
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_item")];

			CALL_CLASS_METHOD("IntelDatabase", _thisObject, "addIntel", [_item]);

			// Broadcast stuff here
		};
	} ENDMETHOD;


	METHOD("updateIntel") {
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_itemDst"), P_OOP_OBJECT("_itemSrc")];

			// Broadcast stuff here
			
			CALL_CLASS_METHOD("IntelDatabase", _thisObject, "updateIntel", [_itemDst ARG _itemSrc]); // It will copy values
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