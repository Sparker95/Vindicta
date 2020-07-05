#define OOP_INFO
#define OOP_DEBUG
#define OOP_WARNING
#define OOP_ERROR

#include "..\common.h"
#include "PlayerDatabase.hpp"

/*
Class: PlayerDatabaseServer
It's a singleton class to be created at server.
Stores data about players.
Inherits from <DoubleKeyHashmap>.
*/

#define pr private

#define OOP_CLASS_NAME PlayerDatabaseServer
CLASS("PlayerDatabaseServer", "DoubleKeyHashmap")
	/*
	Method: set
	Sets value associated with key0-key1 pair.

	Parameters: _uid, _key, _value

	_uid - String, Key 0, should be player's UID
	_key - String, Key 1, should be name of a variable
	_value - anything, the value to set

	Returns: nil
	*/

	public override METHOD(set)
		params [P_THISOBJECT, P_STRING("_uid"), P_STRING("_key"), "_value"];
		pr _args = [_uid, _key, _value];
		T_CALLCM("DoubleKeyHashmap", "set", _args); // classNameStr, objNameStr, methodNameStr, extraParams

		// Broadcast data to this client
	ENDMETHOD;

	/*
	Method: get
	Returns value associated with key0-key1 pair.

	Parameters: _uid, _key

	_uid - String, Key 0, should be player's UID
	_key - String, Key 1, should be name of a variable

	Returns: value
	*/
/*
	public server METHOD(get)
		params [P_THISOBJECT, P_STRING("_uid"), P_STRING("_key")];
		T_GETV("ns") getVariable _uid + __SEP__ + _key
	ENDMETHOD;
*/

	public server METHOD(onPlayerConnected) // getPlayerUID player, profileName, clientOwner
		params [P_THISOBJECT, P_STRING("_uid"), P_STRING("_profileName"), P_NUMBER("_clientOwner")];

		OOP_INFO_0("- - - - - - - onPlayerConnected - - - - - - -");
		OOP_INFO_1("  UID:          %1", _uid);
		OOP_INFO_1("  PROFILE NAME: %1", _profileName);
		OOP_INFO_1("  CLIENT OWNER: %1", _clientOwner);

		// Check if player has been here before
		pr _prevName = T_CALLM2("get", _uid, PDB_KEY_PROFILE_NAME);
		if (isNil "_prevName") then {
			pr _args = [_uid, _profileName, _clientOwner];
			T_CALLM("_onPlayerConnectedFirstTime", _args);

			
			OOP_INFO_1("  NEW PLAYER", _clientOwner);

		} else {
			// This player has been here before
			// Iterate all keys, make sure that there are no nills,
			// in case we have added more keys but this record is from previos version of the mission
			pr _needToReinit = false;
			{
				pr _value = T_CALLM2("get", _uid, _x);
				if (isNil "_value") exitWith {
					pr _args = [_uid, _profileName];
					T_CALLM("_onPlayerConnectedFirstTime", _args);
				};
			} forEach PDB_KEY_ALL;

			OOP_INFO_1("  PLAYER HAS BEEN RECOGNIZED", _clientOwner);

		};

		OOP_INFO_0("- - - - - - - - - - - - - - - - - - - - - - -");

		// Update some data
		T_CALLM3("set", _uid, PDB_KEY_OWNER_ID, _clientOwner); // Update client owner ID

		// Send data to client
		pr _keyValuePairs = PDB_KEY_ALL apply { // Array of [_key, _value]
			[_x, T_CALLM2("get", _uid, _x)];
		};
		REMOTE_EXEC_CALL_STATIC_METHOD("PlayerDatabaseClient", "receiveData", [_keyValuePairs], _clientOwner, false); // classNameStr, methodNameStr, extraParams, targets, JIP

	ENDMETHOD;

	server METHOD(_onPlayerConnectedFirstTime)
		params [P_THISOBJECT, P_STRING("_uid"), P_STRING("_profileName"), P_NUMBER("_clientOwner")];

		// Create initial records about this player
		T_CALLM3("set", _uid, PDB_KEY_PROFILE_NAME, _profileName);

		pr _keyValuePairs = if (_clientOwner == 0 || _clientOwner == 2) then {
			// Server creator has lots of permissions by default
			[
				[PDB_KEY_ALLOW_COMMAND_GARRISONS,	true],
				[PDB_KEY_ALLOW_CREATE_CAMPS,		true],
				[PDB_KEY_ALLOW_BUILD_OBJECTS,		true],
				[PDB_KEY_ALLOW_CHANGE_PERMISSIONS, 	true],
				[PDB_KEY_ALLOW_KICK,				true],
				[PDB_KEY_ALLOW_BAN,					true]
			]
		} else {
			// Generic users have no permissions by default
			[
				/*
				[PDB_KEY_ALLOW_COMMAND_GARRISONS,	false],
				[PDB_KEY_ALLOW_CREATE_CAMPS,		false],
				[PDB_KEY_ALLOW_BUILD_OBJECTS,		false],
				[PDB_KEY_ALLOW_CHANGE_PERMISSIONS, 	false],
				[PDB_KEY_ALLOW_KICK,				false],
				[PDB_KEY_ALLOW_BAN,					false]
				*/

				[PDB_KEY_ALLOW_COMMAND_GARRISONS,	true],
				[PDB_KEY_ALLOW_CREATE_CAMPS,		true],
				[PDB_KEY_ALLOW_BUILD_OBJECTS,		true],
				[PDB_KEY_ALLOW_CHANGE_PERMISSIONS, 	true],
				[PDB_KEY_ALLOW_KICK,				true],
				[PDB_KEY_ALLOW_BAN,					true]
			]
		};

		//OOP_INFO_1("Key-value pairs: %1", _keyValuePairs);

		// Write data to the database
		{
			_x params ["_key", "_value"];
			T_CALLM3("set", _uid, _key, _value);
		} forEach _keyValuePairs;
	ENDMETHOD;

ENDCLASS;