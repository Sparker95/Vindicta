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

#define pr private

params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];

// Code to dump values passed to the event handler
/*
_array = ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];
_str = "";
{
_str = _str + format ["%1: %2, ", _x, _this select _foreachindex];
} forEach _array;
diag_log "Handle Damage:";
diag_log _str;
*/

if (side _unit != side _source && isPlayer _source && alive _source) then { 
	REMOTE_EXEC_CALL_STATIC_METHOD("UndercoverMonitor", "onUnitCompromised", [_source], _source, false); //classNameStr, methodNameStr, extraParams, targets, JIP
};

// DISABLED as it doesn't function correctly (damage is avoided when it should not be, perhaps the comparisons are broken due to nils or something)
// Disable damage for driving over friendlies
// pr _sideUnit = side group _unit;
// pr _sideSource = side group _source;
// if ((_sideUnit == _sideSource || isNull _source) && /*_projectile == "" &&*/ isNull _instigator) then {
// 	0
// } else {
_this call ace_medical_fnc_handledamage // if not defined, will be just silently ignored and return nil
// };