#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Undercover.rpt"
#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "UndercoverMonitor.hpp"
#include "..\modCompatBools.sqf"
#include "..\UI\UndercoverUI\UndercoverUI_Macros.h"

/* 
	Add untie action to an arrested unit. Only visible to other players, but not the player this action is attached to.
*/


params ["_unit"];

params [["_unit", objNull, [objNull]]];

[ 
	_unit,
	"Cut free",
	"",
	"",
 	"_this distance _target < 3 && _this != _target", 
	"_caller distance _target < 3",
	{},
	{},
	{ 	
		params ["_target", "_caller", "_actionId", "_arguments", "_progress", "_maxProgress"];
		REMOTE_EXEC_CALL_STATIC_METHOD("UndercoverMonitor", "setUnitFree", [_target], _target, false);	
	},
	{}, 
	[],
	3,
	0, 
	true,
	false
] remoteExec ["BIS_fnc_holdActionAdd", 0, _unit];