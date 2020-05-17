#define OOP_INFO
#define OOP_DEBUG
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Main.rpt"

#include "..\common.h"

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

#define OOP_CLASS_NAME GarbageCollector
CLASS("GarbageCollector", "")

	/*
	Method: addUnit
	Adds a unit to this garbage collector.

	Parameters: _unit

	_unit - <Unit> object

	Returns: nil
	*/
	METHOD(addUnit)
		params [P_THISOBJECT, P_OOP_OBJECT("_unit")];

		pr _hO = CALLM0(_unit, "getObjectHandle");

		OOP_INFO_1("ADD UNIT: %1", _unit);

		if (isNull _hO) exitWith {
			OOP_WARNING_1("Unit %1 is null!", _unit);
		};

		if (alive _hO) exitWith {
			OOP_WARNING_1("Unit %1 is still alive!", _unit);
		};

		// Delete the Unit OOP object when arma's garbage collector deletes it
		_hO addEventHandler ["Deleted", { 
			params ["_entity"];

			// Check if the unit is really destroyed
			// We have two problems
			// "Deleted" event handler seems to be passed across respawns
			// "Deleted" event handler is being called when a unit enters a vehicle: https://feedback.bistudio.com/T141468
			if (! isNull _entity) then { // Sanity check
				if (! alive _entity) then { // More sanity check

					OOP_INFO_1("EH_Deleted: %1", _this);

					pr _unit = CALLSM1("Unit", "getUnitFromObjectHandle", _entity);
					if (_unit != "") then {
						OOP_INFO_1("GarbageCollector: deleted unit %1", _unit);
						if (IS_OOP_OBJECT(_unit)) then { // Even more sanity check
							// Make sure we delete it in the proper thread
							CALLM2(gMessageLoopMainManager, "postMethodAsync", "deleteObject", [_unit]);
						};
					};
				};
			};
		}];

		// Add it to arma's garbage collector
		addToRemainsCollector [_hO];

		// todo what to do with weapon holsters and other things??

	ENDMETHOD;

ENDCLASS;