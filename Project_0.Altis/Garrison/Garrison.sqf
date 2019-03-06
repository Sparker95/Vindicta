#include "common.hpp"
#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "..\GlobalAssert.hpp"

/*
Class: Garrison
Garrison is an object which holds units and groups and handles their lifecycle (spawning, despawning, destruction).
Garrison is much like a group, it has an <AIGarrison>. But it can have multiple groups of different types.

Author: Sparker 12.07.2018


*/

#define pr private

CLASS("Garrison", "MessageReceiverEx");

	VARIABLE("units");
	VARIABLE("groups");
	VARIABLE("spawned");
	VARIABLE("side");
	VARIABLE("debugName");
	VARIABLE("location");
	VARIABLE("AI"); // The AI brain of this garrison

	// ----------------------------------------------------------------------
	// |                 S E T   D E B U G   N A M E                        |
	// ----------------------------------------------------------------------

	METHOD("setDebugName") {
		params [["_thisObject", "", [""]], ["_debugName", "", [""]]];
		SET_VAR(_thisObject, "debugName", _debugName);
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	/*
	Method: new

	Parameters: _side

	_side - side of this garrison
	*/

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_side", WEST, [WEST]]];

		// Check existance of neccessary global objects
		ASSERT_GLOBAL_OBJECT(gMessageLoopMain);

		SET_VAR(_thisObject, "units", []);
		SET_VAR(_thisObject, "groups", []);
		SET_VAR(_thisObject, "spawned", false);
		SET_VAR(_thisObject, "side", _side);
		SET_VAR(_thisObject, "debugName", "");
		//SET_VAR(_thisObject, "action", "");
		SETV(_thisObject, "AI", "");
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	/*
	Method: delete

	*/
	METHOD("delete") {
		params [["_thisObject", "", [""]]];

		OOP_INFO_0("DELETE GARRISON");
		
		// Detach from location if was attached to it
		pr _loc = T_GETV("location");
		if (_loc != "") then {
			CALLM2(_loc, "postMethodSync", "setGarrisonMilitaryMain", "");
		};
		
		// Despawn if spawned
		CALLM0(_thisObject, "despawn");
		
		pr _units = T_GETV("units");
		pr _groups = T_GETV("groups");
		
		if (count _units != 0) then {
			OOP_ERROR_1("Deleting garrison which has units: %1", _units);
		};
		
		if (count _groups != 0) then {
			OOP_ERROR_1("Deleting garrison which has groups: %1", _groups);
		};
		
		{
			DELETE(_x);
		} forEach _units;
		
		{
			DELETE(_x);
		} forEach _groups;
    
	} ENDMETHOD;

	/*
	Method: getMessageLoop
	See <MessageReceiver.getMessageLoop>

	Returns: <MessageLoop>
	*/
	// Returns the message loop this object is attached to
	METHOD("getMessageLoop") {
		gMessageLoopMain
	} ENDMETHOD;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                           S E T T I N G   M E M B E R   V A L U E S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	//                       S E T   L O C A T I O N
	/*
	Method: setLocation
	Sets the location of this garrison

	Parameters: _location

	_location - <Location>
	*/
	METHOD("setLocation") {
		params [["_thisObject", "", [""]], ["_location", "", [""]] ];
		SET_VAR(_thisObject, "location", _location);
	} ENDMETHOD;






	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                           G E T T I N G   M E M B E R   V A L U E S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


	// Getting values

	//                         G E T   S I D E
	/*
	Method: getSide
	Returns side of this garrison.

	Returns: Side
	*/
	METHOD("getSide") {
		params [["_thisObject", "", [""]]];
		GET_VAR(_thisObject, "side")
	} ENDMETHOD;


	//                     G E T   L O C A T I O N
	/*
	Method: getLocation
	Returns location this garrison is attached to.

	Returns: <Location>
	*/
	METHOD("getLocation") {
		params [["_thisObject", "", [""]]];
		GET_VAR(_thisObject, "location")
	} ENDMETHOD;


	//                      G E T   G R O U P S
	/*
	Method: getGroups
	Returns groups of this garrison.

	Returns: Array of <Group> objects.
	*/
	METHOD("getGroups") {
		params [["_thisObject", "", [""]]];
		GET_VAR(_thisObject, "groups")
	} ENDMETHOD;

	// 						G E T   U N I T S
	/*
	Method: getUnits
	Returns all units of this garrison.

	Returns: Array of <Unit> objects.
	*/
	METHOD("getUnits") {
		params [["_thisObject", "", [""]]];
		T_GETV("units")
	} ENDMETHOD;

	// |                         G E T  I N F A N T R Y  U N I T S
	/*
	Method: getInfantryUnits
	Returns all infantry units.

	Returns: Array of units.
	*/
	METHOD("getInfantryUnits") {
		params [["_thisObject", "", [""]]];
		private _unitList = T_GETV("units");
		_unitList select {CALLM0(_x, "isInfantry")}
	} ENDMETHOD;

	// |                         G E T   V E H I C L E   U N I T S
	/*
	Method: getVehiucleUnits
	Returns all vehicle units.

	Returns: Array of units.
	*/
	METHOD("getVehicleUnits") {
		params [["_thisObject", "", [""]]];
		private _unitList = T_GETV("units");
		_unitList select {CALLM0(_x, "isVehicle")}
	} ENDMETHOD;

	// |                         G E T   D R O N E   U N I T S
	/*
	Method: getVehicleUnits
	Returns all drone units.

	Returns: Array of units.
	*/
	METHOD("getDroneUnits") {
		params [["_thisObject", "", [""]]];
		private _unitList = T_GETV("units");
		_unitList select {CALLM0(_x, "isDrone")}
	} ENDMETHOD;

	// 						G E T   A I
	/*
	Method: getAI
	Returns the AI object of this garrison.

	Returns: Array of <Unit> objects.
	*/
	METHOD("getAI") {
		params [["_thisObject", "", [""]]];
		T_GETV("AI")
	} ENDMETHOD;

	//             F I N D   G R O U P S   B Y   T Y P E
	/*
	Method: findGroupsByType
	Finds groups in this garrison that have the same type as _type

	Parameters: _type

	_type - Number, one of <GROUP_TYPE>, or Array with such numbers

	Returns: Array with <Group> objects.
	*/
	METHOD("findGroupsByType") {
		params [["_thisObject", "", [""]], ["_types", 0, [0, []]]];

		if (_types isEqualType 0) then {_types = [_types]};

		pr _groups = GETV(_thisObject, "groups");
		pr _return = [];
		{
			if (CALLM0(_x, "getType") in _types) then {
				_return pushBack _x;
			};
		} forEach _groups;
		_return
	} ENDMETHOD;

	/*
	Method: countAllUnits
	Returns all units of this garrison.

	Returns: Array of <Unit> objects.
	*/
	METHOD("countAllUnits") {
		params [["_thisObject", "", [""]]];
		count T_GETV("units")
	} ENDMETHOD;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                A D D I N G / R E M O V I N G   U N I T S   A N D   G R O U P S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	/*
	Method: addUnit
	Adds an existing unit to this garrison. Also use it if you want to move ungrouped units between garrisons.
	Unit should be not in agroup since this function doesn't move unit's group to this garrison. So, only vehicles should be added/moved this way.

	Threading: should be called through postMethod (see <MessageReceiverEx>)

	Parameters: _unit

	_unit - <Unit> object

	Returns: nil
	*/
	METHOD("addUnit") {
		params[["_thisObject", "", [""]], ["_unit", "", [""]] ];

		OOP_INFO_1("ADD UNIT: %1", _unit);

		// Check if the unit is already in a garrison
		private _unitGarrison = CALL_METHOD(_unit, "getGarrison", []);
		if(_unitGarrison != "") then {
			// Remove unit from its previous garrison
			CALLM1(_unitGarrison, "removeUnit", _unit);

			/*
			diag_log format ["[Garrison::addUnit] Error: can't add a unit which is already in a garrison, garrison: %1, unit: %2: %3",
				GET_VAR(_thisObject, "debugName"), _unit, CALL_METHOD(_unit, "getData", [])];
				*/
		};

		// Check if the unit is in a group
		private _unitGroup = CALL_METHOD(_unit, "getGroup", []);
		if (_unitGroup != "") then {
			diag_log format ["[Garrison::addUnit] Warning: adding a unit assigned to a group, garrison : %1, unit: %2: %3",
				GET_VAR(_thisObject, "debugName"), _unit, CALL_METHOD(_unit, "getData", [])];
		};

		private _units = GET_VAR(_thisObject, "units");
		_units pushBackUnique _unit;
		CALL_METHOD(_unit, "setGarrison", [_thisObject]);

		nil
	} ENDMETHOD;


	/*
	Method: removeUnit
	Removes a unit from this garrison.
	Threading: should be called through postMethod (see <MessageReceiverEx>)

	Parameters: _unit

	_unit - <Unit> object

	Returns: nil
	*/
	METHOD("removeUnit") {
		params[["_thisObject", "", [""]], ["_unit", "", [""]] ];
		
		OOP_INFO_1("REMOVE UNIT: %1", _unit);
		
		private _units = GET_VAR(_thisObject, "units");
		_units deleteAt (_units find _unit);

		// Set the garrison of this unit
		CALLM1(_unit, "setGarrison", "");

		nil
	} ENDMETHOD;

	/*
	Method: addGroup
	Adds an existing group to this garrison. Also use it when you want to move a group to another garrison.

	Threading: should be called through postMethod (see <MessageReceiverEx>)

	Parameters: _group

	_unit - <Group> object

	Returns: nil
	*/
	METHOD("addGroup") {
		params[["_thisObject", "", [""]], ["_group", "", [""]] ];

		OOP_INFO_2("ADD GROUP: %1, group units: %2", _group, CALLM0(_group, "getUnits"));
		
    // Check if the group is already in another garrison
		private _groupGarrison = CALL_METHOD(_group, "getGarrison", []);
		if (_groupGarrison != "") then {
			// Remove the group from its previous garrison
			CALLM1(_groupGarrison, "removeGroup", _group);
		};

		// Add this group and its units to this garrison
		private _groupUnits = CALL_METHOD(_group, "getUnits", []);
		private _units = GET_VAR(_thisObject, "units");
		{
			_units pushBackUnique _x;
		} forEach _groupUnits;
		private _groups = GET_VAR(_thisObject, "groups");
		_groups pushBackUnique _group;
		CALL_METHOD(_group, "setGarrison", [_thisObject]);

		// Spawn or despawn the units if needed
		if (T_GETV("spawned")) then {
			pr _groupIsSpawned = CALLM0(_group, "isSpawned");
			if (!_groupIsSpawned) then {
				pr _loc = T_GETV("location");
				if (_loc == "") then {
					// Can't spawn the added group because there is no location
					OOP_ERROR_1("Can't spawn a new group while adding it because the garrison is not attached to a location. Group: %1", _group);
				} else {
					CALLM1(_group, "spawn", _loc);
				};
			};
			_groupIsSpawned = CALLM0(_group, "isSpawned");
			if (_groupIsSpawned) then { // If the group is finally spawned
				// Notify the AI of the garrison about it
				// Call the handleGroupsAdded directly since it's in the same thread
				pr _AI = T_GETV("AI");
				if (_AI != "") then {
					CALLM1(_AI, "handleGroupsAdded", [[_group]]);
				};
			};
		} else {
			// If this garrison is not spawned, despawn the group as well
			pr _groupIsSpawned = CALLM0(_group, "isSpawned");
			if (_groupIsSpawned) then {
				CALLM0(_group, "despawn");
			};
		};

		nil
	} ENDMETHOD;

	/*
	Method: removeGroup
	Removes an existing group from this garrison.
	You don't need to call this. Use addGroup when you need to move groups between garrisons.

	Parameters: _group

	_unit - <Group> object

	Returns: nil
	*/
	METHOD("removeGroup") {
		params[["_thisObject", "", [""]], ["_group", "", [""]] ];
		
		OOP_INFO_2("REMOVE GROUP: %1, group units: %1", _group, CALLM0(_group, "getUnits"));
		
		// Notify AI object if the garrison is spawned
		if (T_GETV("spawned")) then {
			pr _AI = T_GETV("AI");
			if (_AI != "") then {
				CALLM1(_AI, "handleGroupsRemoved", [_group]); // We call it synchronously because Garrison AI is in the same thread.
			};
		};

		// Remove this group and all its units from this garrison
		pr _groupUnits = CALL_METHOD(_group, "getUnits", []);
		pr _units = GET_VAR(_thisObject, "units");
		{
			_units deleteAt (_units find _x);
		} forEach _groupUnits;
		pr _groups = GET_VAR(_thisObject, "groups");
		_groups deleteAt (_groups find _group);

		CALLM1(_group, "setGarrison", "");

		nil
	} ENDMETHOD;


	/*
	Method: addGarrison
	Moves all units and groups from another garrison to this one.
	
	Parameters: _garrison, _delete
	
	_garrison - <Garrison> object
	_delete - Bool, optional, deletes the _garrison, default: false
	
	Returns: nil
	*/
	
	METHOD("addGarrison") {
		params[["_thisObject", "", [""]], ["_garrison", "", [""]], ["_delete", false] ];
		
		OOP_INFO_3("ADD GARRISON: %1, garrison groups: %2, garrison units: %3", _garrison, CALLM0(_garrison, "getGroups"), CALLM0(_garrison, "getUnits"));
		
		// Move all groups
		pr _groups = +CALLM0(_garrison, "getGroups");
		{
			CALLM1(_thisObject, "addGroup", _x);
		} forEach _groups;
		
		// Move remaining units
		pr _units = +CALLM0(_garrison, "getUnits");
		{
			CALLM1(_thisObject, "addUnit", _x);
		} forEach _units;
		
		// Delete the other garrison if needed
		if (_delete) then {
			DELETE(_garrison);
		};
		
		nil
	} ENDMETHOD;
	
	
	/*
	Method: getRequiredCrew
	Returns amount of needed drivers and turret operators for all vehicles in this garrison.

	Returns: [_nDrivers, _nTurrets]
	*/

	METHOD("getRequiredCrew") {
		params [["_thisObject", "", [""]]];

		pr _units = T_GETV("units");

		pr _nDrivers = 0;
		pr _nTurrets = 0;

		{
			if (CALLM0(_x, "isVehicle")) then {
				pr _className = CALLM0(_x, "getClassName");
				([_className] call misc_fnc_getFullCrew) params ["_n_driver", "_copilotTurrets", "_stdTurrets"];//, "_psgTurrets", "_n_cargo"];
				_nDrivers = _nDrivers + _n_driver;
				_nTurrets = _nTurrets + (count _copilotTurrets) + (count _stdTurrets);
			};
		} forEach _units;

		[_nDrivers, _nTurrets]
	} ENDMETHOD;
	
	/*
	Method: mergeVehicleGroups
	Merges or splits vehicle group(s)
	
	Parameters: _merge
	
	_merge - Bool, true to merge, false to split
	
	Returns: nil
	*/
	
	METHOD("mergeVehicleGroups") {
		params [["_thisObject", "", [""]], ["_merge", false, [false]]];
		
		if (_merge) then {
			// Find all vehicle groups
			pr _vehGroups = CALLM1(_thisObject, "findGroupsByType", GROUP_TYPE_VEH_NON_STATIC);
			pr _destGroup = _vehGroups select 0;
			
			// If there are no vehicle groups, create one right now
			if (isNil "_destGroup") then {
				pr _args = [CALLM0(_thisObject, "getSide"), GROUP_TYPE_VEH_NON_STATIC];
				_destGroup = NEW("Group", _args);
				CALLM0(_destGroup, "spawn");
				CALLM1(_thisObject, "addGroup", _destGroup);
				_vehGroups pushBack _destGroup;
			};
						
			// If there are more than one vehicle groups, merge them into the first group
			if (count _vehGroups > 1) then {
				for "_i" from 1 to (count _vehGroups - 1) do {
					pr _group = _vehGroups select _i;
					CALLM1(_destGroup, "addGroup", _group);
					DELETE(_group);
				};
			};
			
			// Also move ungrouped vehicles
			pr _vehicleUnits = CALLM0(_thisObject, "getVehicleUnits");
			{
				pr _vehGroup = CALLM0(_x, "getGroup");
				if (_vehGroup == "") then {
					CALLM1(_destGroup, "addUnit", _x);
				};
			} forEach _vehicleUnits;
		} else {
			// Find all vehicle groups
			pr _vehGroups = CALLM1(_thisObject, "findGroupsByType", GROUP_TYPE_VEH_NON_STATIC);
			
			// Split every vehicle group
			{
				pr _group = _x;
				pr _groupVehicles = CALLM0(_group, "getUnits") select {CALLM0(_x, "isVehicle")};
				
				// If there are more than one vehicle
				if (count _groupVehicles > 1) then {
					// Temporarily stop the AI object of the group because it can perform vehicle assignments in the other thread
					// Event handlers when units are destroyed are disposed from this thread anyway
					pr _groupAI = CALLM0(_group, "getAI");
					if (_groupAI != "") then {
						CALLM2(_groupAI, "postMethodSync", "stop",  []);
					};
					
					// Create a new group per every vehicle (except for the first one)
					pr _side = CALLM0(_group, "getSide");
					for "_i" from 1 to ((count _groupVehicles) - 1) do {
						pr _vehicle = _groupVehicles select _i;
						pr _vehAI = CALLM0(_vehicle, "getAI");
						
						// Create a group, add it to the garrison
						pr _args = [_side, GROUP_TYPE_VEH_NON_STATIC];
						pr _newGroup = NEW("Group", _args);
						CALLM0(_newGroup, "spawn");
						CALLM1(_thisObject, "addGroup", _newGroup);
						
						// Get crew of this vehicle
						if (_vehAI != "") then {
							pr _vehCrew = CALLM3(_vehAI, "getAssignedUnits", true, true, false) select {
								// We only need units in this vehicle that are also in this group
								CALLM0(_x, "getGroup") == _group
							};
							//OOP_INFO_1("Vehicle crew: %1", _vehCrew);
							
							// Move units to the new group
							{ CALLM1(_newGroup, "addUnit", _x); } forEach _vehCrew;
						};
						
						// Move the vehicle to its new group
						CALLM1(_newGroup, "addUnit", _vehicle);
					};
					
					// Start up the AI object again
					if (_groupAI != "") then {
						CALLM2(_groupAI, "postMethodSync", "start",  []);
					};
				};
			} forEach _vehGroups;
		};
		
		nil
	} ENDMETHOD;	
	

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                                G O A P
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -




	// It should return the goals this garrison might be willing to achieve
	METHOD("getPossibleGoals") {
		["GoalGarrisonRelax",
		"GoalGarrisonRepairAllVehicles",
		"GoalGarrisonDefendPassive",
		"GoalGarrisonRebalanceVehicleGroups"]
	} ENDMETHOD;

	METHOD("getPossibleActions") {
		["ActionGarrisonDefendPassive",
		"ActionGarrisonLoadCargo",
		"ActionGarrisonMountCrew",
		"ActionGarrisonMountInfantry",
		"ActionGarrisonMoveDismounted",
		//"ActionGarrisonMoveMountedToPosition",
		//"ActionGarrisonMoveMountedToLocation",
		"ActionGarrisonMoveMounted",
		"ActionGarrisonMoveMountedCargo",
		"ActionGarrisonRelax",
		"ActionGarrisonRepairAllVehicles",
		"ActionGarrisonUnloadCurrentCargo",
		"ActionGarrisonMergeVehicleGroups",
		"ActionGarrisonRebalanceVehicleGroups",
		"ActionGarrisonClearArea",
		"ActionGarrisonJoinLocation"]
	} ENDMETHOD;


	//            G E T   S U B A G E N T S
	/*
	Method: getSubagents
	Returns subagents of this agent.
	For garrison it returns an empty array, because the subagents of garrison (groups) are processed in a separate thread.

	Access: Used by AI class

	Returns: [].
	*/
	METHOD("getSubagents") {
		[]
		// In case we decide to process groups in the same thread as garrison, we can return the groups here
	} ENDMETHOD;




	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                                E V E N T   H A N D L E R S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


	METHOD("handleGroupRemoved") {
	} ENDMETHOD;


	// |                 H A N D L E   U N I T   K I L L E D                |
	/*
	Method: handleUnitKilled
	Called when the unit has been killed.

	Must be called inside the garrison thread through postMethodAsync, not inside event handler.

	Returns: nil
	*/
	METHOD("handleUnitKilled") {
		params [["_thisObject", "", [""]], ["_unit", "", [""]]];

		OOP_INFO_0("");

		diag_log format ["[Garrison::handleUnitKilled] Info: %1", _unit];

		// Call handleUnitKilled of the group of this unit
		pr _group = CALLM0(_unit, "getGroup");
		if (_group != "") then {
			CALLM1(_group, "handleUnitRemoved", _unit);
		};

		// Call handleKilled of the unit
		CALLM0(_unit, "handleKilled");

		// Set Garrison of this Unit
		CALLM1(_unit, "setGarrison", "");

		// Remove the unit from this garrison
		CALLM1(_thisObject, "removeUnit", _unit);
	} ENDMETHOD;

	/*
	Method: handleGetInVehicle
	Called when someone enters a vehicle that belongs to this garrison.

	Must be called inside the garrison thread through postMethodAsync, not inside event handler.

	Parameters: _unitVeh, _unitInf

	_unitVeh - the vehicle
	_unitInf - the unit that entered the vehicle

	Returns: nil
	*/

	METHOD("handleGetInVehicle") {
		params [["_thisObject", "", [""]], ["_unitVeh", "", [""]], ["_unitInf", "", [""]]];

		OOP_INFO_0("");

		// Get garrison of the unit that entered the vehicle
		pr _garDest = CALLM0(_unitInf, "getGarrison");
		if (_garDest == "") then {
			_garDest = gGarrisonAmbient;
			OOP_ERROR_2("handleGetInVehicle: infantry unit has no garrison: %1, %2", _unitInf, CALLM0(_unitInf, "getData"));
		};

		// Check garrison of the unit that entered this vehicle
		if (_garDest != _thisObject) then {
			// Remove the vehicle from its group
			pr _vehGroup = CALLM0(_unitVeh, "getGroup");
			if (_vehGroup != "") then {
				CALLM1(_vehGroup, "removeUnit", _unitVeh);
			};

			// Move the vehicle into the other garrison
			CALLM1(_garDest, "addUnit", _unitVeh);
		};
	} ENDMETHOD;




	// ======================================= FILES ==============================================

	// Handles incoming messages. Since it's a MessageReceiverEx, we must overwrite handleMessageEx
	METHOD_FILE("handleMessageEx", "Garrison\handleMessageEx.sqf");

	// Spawns the whole garrison
	METHOD_FILE("spawn", "Garrison\spawn.sqf");

	// Despawns the whole garrison
	METHOD_FILE("despawn", "Garrison\despawn.sqf");

	// Find units with specific type
	METHOD_FILE("findUnits", "Garrison\findUnits.sqf");

	// Counts amount of units with specific type
	METHOD_FILE("countUnits", "Garrison\countUnits.sqf");

ENDCLASS;
