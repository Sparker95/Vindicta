#include "..\common.h"
#include "..\Message\Message.hpp"
#include "..\CriticalSection\CriticalSection.hpp"
#include "MessageReceiver.hpp"

#define pr private

[] spawn {
	pr _obj = "o_Group_N_4";
	pr _success = CALLM1(_obj, "setOwner", 3);
	if (_success) then {
		diag_log "Set owner success!";
	} else {
		diag_log "Set owner failed!";
	};
};