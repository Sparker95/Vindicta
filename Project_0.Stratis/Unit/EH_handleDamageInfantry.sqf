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

	//systemchat format ["%1 damaged %2", name _instigator, name _damagedUnit];

	if (side _unit != side _source && isPlayer _source && alive _source) then { 
		_source setVariable [UNDERCOVER_WANTED, true, true];
	};
