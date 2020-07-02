#include "..\common.h"
#include "..\Message\Message.hpp"

private _msg = MESSAGE_NEW();
_msg set [MESSAGE_ID_TYPE, 123];
_msg set [MESSAGE_ID_DATA, ">Hello from server!<"];

private _msgID = CALLM2(remoteDebugPrinter, "postMessage", _msg, true);
diag_log "Started waiting!";
private _return = CALLM1(remoteDebugPrinter, "waitUntilMessageDone", _msgID);
diag_log format ["Stopped waiting! Return value: %1", _return];