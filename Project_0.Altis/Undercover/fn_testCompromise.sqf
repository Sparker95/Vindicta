#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Undercover.rpt"
#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "UndercoverMonitor.hpp"
#include "..\modCompatBools.sqf"
#include "..\UI\Resources\UndercoverUI\UndercoverUI_Macros.h"

params ["_unit"];

if (count crew vehicle _unit > 0) then {
	{
		if (isPlayer _x && alive _x) then { 
			private _um = _x getVariable ["undercoverMonitor", ""];
			if (_um != "") then { // Sanity check
				private _msg = MESSAGE_NEW();
				MESSAGE_SET_TYPE(_msg, SMON_MESSAGE_COMPROMISED);
				CALLM1(_um, "postMessage", _msg);
			};
		};
	} forEach crew vehicle _unit;		
};
