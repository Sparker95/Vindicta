#include "common.hpp"
/*
Handle message incoming into a garrison object.
*/

//#include "..\Garrison\Garrison.hpp"

#define pr private

params [P_THISOBJECT, P_ARRAY("_msg") ];
//diag_log format ["[Garrison] Info: HandleMessage: %1", _msg];

#ifndef _SQF_VM // No messages in testing mode

pr _msgType = _msg select MESSAGE_ID_TYPE;

if (_msgType == GARRISON_MESSAGE_PROCESS) then {
	// process will do our asserts and locks
	T_CALLM0("process");
};

#endif

nil