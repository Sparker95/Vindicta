#define OOP_ERROR
#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "Unit.hpp"
#include "..\Undercover\UndercoverMonitor.hpp"

/*
Damage EH for units. Its main job is to send messages to objects. 
*/

#define pr private

params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];

/*
pr _instigator = _this select 3;
pr _damagedUnit = _this select 0;

//systemchat format ["%1 damaged %2", name _instigator, name _damagedUnit];

if (side _damagedUnit != side _instigator && isPlayer _instigator && alive _instigator) then { 
	_instigator setVariable [UNDERCOVER_WANTED, true, true];
};

*/

	
//private _source = _this select 3; //: Object - The source unit that caused the damage.

//private _instigator = _this select 6; //: Object - Person who pulled the trigger

if ((side _source == side _unit) && /*(_projectile == "") &&*/ (isNull _instigator)) then
{
	0
};