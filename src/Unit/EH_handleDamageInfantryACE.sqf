#define OOP_ERROR
#include "..\common.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "Unit.hpp"
#include "..\Undercover\UndercoverMonitor.hpp"
FIX_LINE_NUMBERS()

/*
Damage EH for units. Its main job is to send messages to objects.
Fires on the owner of the unit.
*/

// Enables damage logging
//#define DEBUG_DAMAGE

#define pr private

params	["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];

// Ignore non-local units
if !(local _unit) exitWith {nil};

// Dump values passed to the event handler
#ifdef DEBUG_DAMAGE
_array = ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];
_str = "";
{
	_str = _str + format ["%1: %2, ", _x, _this select _foreachindex];
} forEach _array;
diag_log "[Dmg] Handle Damage:";
diag_log ("[Dmg] " + _str);
#endif

// Report to undercover monitor when player driver over bots
if (side _unit != side _source && isPlayer _source && alive _source) then { 
	REMOTE_EXEC_CALL_STATIC_METHOD("UndercoverMonitor", "onUnitCompromised", [_source], _source, false); //classNameStr, methodNameStr, extraParams, targets, JIP
};

// Disable damage for driving over friendlies
pr _sideUnit = side group _unit;
pr _sideSource = side group _source;
pr _onFoot = (vehicle _unit) isEqualTo _unit;

#ifdef DEBUG_DAMAGE
diag_log format ["[Dmg] _sideUnit: %1, _sideSource: %2, _onFoot: %3", _sideUnit, _sideSource, _onFoot];
#endif

pr _ret = if ((_sideUnit == _sideSource || isNull _source) && {_projectile == ""} && {isNull _instigator} && {_onFoot}) then {

	#ifdef DEBUG_DAMAGE
	diag_log "[Dmg] Damage ignored!";
	#endif

	0;
} else {

	#ifdef DEBUG_DAMAGE
	diag_log "[Dmg] Damage added!";
	#endif
	
	_this call ace_medical_engine_fnc_handleDamage;
};

#ifdef DEBUG_DAMAGE
diag_log format ["[Dmg] Return value: %1", _ret];
#endif

_ret;