#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Intel.rpt"
#include "..\common.h"

/*
Class: IntelDatabase.IntelDatabaseServer

A database that is meant to be created at the server.
When items are added or updated, it synchronizes intel with clients.

Author: Sparker 07.05.2019 
*/

#define pr private

OOP_INFO_0("Compiling IntelDatabaseServer");
#define OOP_CLASS_NAME IntelDatabaseServer
CLASS("IntelDatabaseServer", "IntelDatabase")

	METHOD(addIntel)
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_item")];

			//OOP_INFO_1("ADD INTEL: %1", _item);

			CALL_CLASS_METHOD("IntelDatabase", _thisObject, "addIntel", [_item]);

			// Broadcast the message
			private _serialIntel = SERIALIZE(_item);
			private _side = T_GETV("side");
			_thisObject = nil; // Otherwise it gets passed into inner scope of remoteExecCall on local machine
			_thisClass = nil;
			REMOTE_EXEC_CALL_STATIC_METHOD("IntelDatabaseClient", "updateIntelClient", [_serialIntel], _side, _item);
		};
	ENDMETHOD;


	METHOD(updateIntel)
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_itemDst"), P_OOP_OBJECT("_itemSrc")];

			CALL_CLASS_METHOD("IntelDatabase", _thisObject, "updateIntel", [_itemDst ARG _itemSrc]); // It will copy values

			// Broadcast the message
			private _serialIntel = SERIALIZE(_itemDst);
			private _side = T_GETV("side");
			_thisObject = nil; // Otherwise it gets passed into inner scope of remoteExecCall on local machine
			_thisClass = nil;
			REMOTE_EXEC_CALL_STATIC_METHOD("IntelDatabaseClient", "updateIntelClient", [_serialIntel], _side, _itemDst);
		};
	ENDMETHOD;

	METHOD(removeIntel)
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_item")];

			CALL_CLASS_METHOD("IntelDatabase", _thisObject, "removeIntel", [_item]);

			// Broadcast that intel was removed to existing clients
			private _side = T_GETV("side");
			_thisObject = nil;
			_thisClass = nil;
			REMOTE_EXEC_CALL_STATIC_METHOD("IntelDatabaseClient", "removeIntelClient", [_item], _side, false); // Broadcast without JIP

			// Remove it from JIP queue
			remoteExec ["", _item];
		};
	ENDMETHOD;


ENDCLASS;