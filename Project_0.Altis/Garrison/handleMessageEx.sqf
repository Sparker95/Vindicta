#include "common.hpp"
/*
Handle message incoming into a garrison object.
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
//#include "..\Garrison\Garrison.hpp"

#define pr private

params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
//diag_log format ["[Garrison] Info: HandleMessage: %1", _msg];

#ifndef _SQF_VM // No messages in testing mode

pr _msgType = _msg select MESSAGE_ID_TYPE;

if (_msgType == GARRISON_MESSAGE_PROCESS) then {
	CALLM0(_thisObject, "process");
};

#endif

nil