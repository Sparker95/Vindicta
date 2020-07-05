#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Undercover.rpt"
#include "..\common.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "UndercoverMonitor.hpp"
#include "..\modCompatBools.sqf"
#include "..\UI\InGameUI\InGameUI_Macros.h"

/* 
	Tests the "compromise" feature of the undercoverMonitor by sending a message to the monitor.

	Parameter: _unit - the unit that is to be compromised

	Example: [player] call fnc_testCompromise
*/


params ["_unit"];

if (count crew vehicle _unit > 0) then {
	{
		if (isPlayer _x && alive _x) then { 
			REMOTE_EXEC_CALL_STATIC_METHOD("UndercoverMonitor", "onUnitCompromised", [_x], _x, false); //classNameStr, methodNameStr, extraParams, targets, JIP	
		};
	} forEach crew vehicle _unit;
};
