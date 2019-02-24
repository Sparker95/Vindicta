#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "UndercoverMonitor.hpp"
#include "..\modCompatBools.sqf"
#include "..\UI\Resources\UndercoverUI\UndercoverUI_Macros.h"

/* Test speed of undercoverMonitor class PROCESS */ 
params ["_unit"];

private _msg = MESSAGE_NEW();
MESSAGE_SET_TYPE(_msg, SMON_MESSAGE_PROCESS);
private _undercoverMonitor = player getVariable "undercoverMonitor";
CALLM1(_undercoverMonitor, "postMessage", _msg);