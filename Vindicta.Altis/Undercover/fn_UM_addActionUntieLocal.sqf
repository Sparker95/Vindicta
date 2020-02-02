#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Undercover.rpt"
#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "UndercoverMonitor.hpp"
#include "..\modCompatBools.sqf"
#include "..\UI\InGameUI\InGameUI_Macros.h"

#define pr private

/* 
	Adds local action allowing the player to free themselves from being in undercoverMonitor's captive state.

*/


params [["_unit", objNull, [objNull]]];

[ 
	_unit,
	"cut yourself free",
	"",
	"",
	"_this distance _target < 3",
	"_caller distance _target < 3",
	{},
	{},
	{ 	
		params ["_target", "_caller", "_actionId", "_arguments", "_progress", "_maxProgress"];
		REMOTE_EXEC_CALL_STATIC_METHOD("UndercoverMonitor", "setUnitFree", [_target], _target, false);	
	},
	{}, 
	[],
	8,
	0, 
	true,
	false
] call BIS_fnc_holdActionAdd;