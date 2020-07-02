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

#define pr private

/* 
	Adds local action allowing the player to free themselves from being in undercoverMonitor's captive state.

*/


params [P_OBJECT("_unit")];

[ 
	_unit,
	"cut yourself free",
	"",
	"",
	"_this distance _target < 3",
	"_caller distance _target < 3",
	{},
	{ // code during progress
		params ["_target", "_caller", "_actionId", "_arguments", "_progress", "_maxProgress"];
		private _args = [_target, 3.0];
		REMOTE_EXEC_CALL_STATIC_METHOD("undercoverMonitor", "boostSuspicion", _args, _target, false);
	},
	{ // code when finished
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