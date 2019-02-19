#define OOP_ERROR
#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "Unit.hpp"
#include "..\Undercover\UndercoverMonitor.hpp"

/*
Damage EH for units. Its main job is to send messages to objects.
Fires on the owner of the unit.
*/

#define pr private

params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];

// Disable damage for driving over friendlies
if ((side _source == side _unit) && /*(_projectile == "") &&*/ (isNull _instigator)) then
{
	0
};

if (side _unit != side _source && isPlayer _source && alive _source) then { 
	_source setVariable [UNDERCOVER_WANTED, true, true];
};
