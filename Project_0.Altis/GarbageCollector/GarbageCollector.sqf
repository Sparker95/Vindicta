#define OOP_INFO
#define OOP_DEBUG
#define OOP_WARNING
#define OOP_ERROR
#include "..\OOP_Light\OOP_light.h"

/*
Class: GarbageCollector
This class deals with deleting destroyed objects/units.
*/

#define pr private

/*
!!!!!
Make sure that the .ext file is set up correctly!
https://community.bistudio.com/wiki/Description.ext#Corpse_.26_wreck_management
*/

CLASS("GarbageCollector", "")

	/*
	Method: addUnit
	Adds a unit to this garbage collector.

	Parameters: _unit

	_unit - <Unit> object

	Returns: nil
	*/
	METHOD("addUnit") {
		params [P_THISOBJECT, P_OOP_OBJECT("_unit")];

		pr _hO = CALLM0(_unit, "getObjectHandle");
		if (isNull _hO) exitWith {
			OOP_WARNING_1("Unit %1 is null!", _unit);
		};

		if (alive _hO) exitWith {
			OOP_WARNING_1("Unit %1 is still alive!", _unit);
		};

		// Delete the Unit OOP object when arma's garbage collector deletes it
		_hO addEventHandler ["Deleted", { 
			params ["_entity"];
			pr _unit = CALLSM1("Unit", "getUnitFromObjectHandle", _entity);
			if (_unit != "") then {
				OOP_INFO_MSG("Deleted %1", [_unit]);
				DELETE(_unit);
			};
		}];

		// Add it to arma's garbage collector
		addToRemainsCollector [_hO];

		// todo what to do with weapon holsters and other things??

	} ENDMETHOD;

ENDCLASS;