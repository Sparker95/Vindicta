#include "..\common.h"
#include "..\Message\Message.hpp"
#include "location.hpp"
#include "..\MessageTypes.hpp"

// Class: Location
/*
Method: handleMessage
Checks spawn conditions of this location. Spawns garrisons if needed.
*/

params [P_THISOBJECT, P_ARRAY("_msg") ];

private _msgType = _msg select MESSAGE_ID_TYPE;

//diag_log format ["[Location] Info: handle message: %1", _this];

switch (_msgType) do {
	case LOCATION_MESSAGE_PROCESS: {
		//diag_log format ["[Location] Info: process %1", T_GETV("name")];

		T_CALLM0("process");

	}; // case LOCATION_MESSAGE_PROCESS
}; // switch msg type