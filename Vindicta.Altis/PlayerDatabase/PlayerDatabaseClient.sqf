#define OOP_INFO
#define OOP_DEBUG
#define OOP_WARNING
#define OOP_ERROR

#include "..\common.h"
#include "PlayerDatabase.hpp"

/*
Class: PlayerDatabaseClient
It's a singleton class to be created at clients.
Stores data about this client on this client's machine. Data is received data from the PlayerDatabaseServer located at server.
*/

#define pr private

#define OOP_CLASS_NAME PlayerDatabaseClient
CLASS("PlayerDatabaseClient", "")

	// Namespace object
	VARIABLE("ns");

	METHOD(new)
		params [P_THISOBJECT];

		#ifndef _SQF_VM
		pr _ns = [false] call CBA_fnc_createNamespace;
		T_SETV("ns", _ns);
		#endif
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		pr _ns = T_GETV("ns");
		DELETE(_ns);
	ENDMETHOD;

	METHOD(set)
		params [P_THISOBJECT, P_STRING("_key"), "_value"];

		pr _ns = T_GETV("ns");
		_ns setVariable ["_key", _value];
	ENDMETHOD;

	METHOD(get)
		params [P_THISOBJECT, P_STRING("_key")];

		pr _ns = T_GETV("ns");
		_ns getVariable _key
	ENDMETHOD;

	// Stores new values for keys
	METHOD(updateData)
		params [P_THISOBJECT, P_ARRAY("_keyValuePairs")];

		OOP_INFO_1("UPDATE DATA: %1", _keyValuePairs);
		pr _ns = T_GETV("ns");
		{
			_x params ["_key", "_value"];
			_ns setVariable [_key, _value];
		} forEach _keyValuePairs;
	ENDMETHOD;

	// Remote-executed from the server to receive actual data
	STATIC_METHOD(receiveData)
		params [P_THISCLASS, P_ARRAY("_keyValuePairs")];
		CALLM1(gPlayerDatabaseClient, "updateData", _keyValuePairs);
	ENDMETHOD;

ENDCLASS;