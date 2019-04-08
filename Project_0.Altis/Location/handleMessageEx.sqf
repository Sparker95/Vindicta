#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "location.hpp"
#include "..\MessageTypes.hpp"

// Class: Location
/*
Method: handleMessage
Checks spawn conditions of this location. Spawns garrisons if needed.
*/

params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];

private _msgType = _msg select MESSAGE_ID_TYPE;

//diag_log format ["[Location] Info: handle message: %1", _this];

switch (_msgType) do {
	case LOCATION_MESSAGE_PROCESS: {
		//diag_log format ["[Location] Info: process %1", GET_VAR(_thisObject, "debugName")];
		private _locPos = GET_VAR(_thisObject, "pos");
		private _spawnState = GET_VAR(_thisObject, "spawnState");
		
	}; // case LOCATION_MESSAGE_PROCESS
}; // switch msg type