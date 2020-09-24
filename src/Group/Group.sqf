#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#define OOP_DEBUG
#define OFSTREAM_FILE "Main.rpt"
#include "Group.hpp"
#include "..\Unit\Unit.hpp"
#include "..\common.h"
#include "..\Mutex\Mutex.hpp"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "..\defineCommon.inc"
FIX_LINE_NUMBERS()

// Class: Group
/*
Virtualized Group has <Unit> objects inside it.

Unlike standard ARMA group, it can have men, vehicles and drones inside it.

Author: Sparker
11.06.2018
*/

#define pr private

#define OOP_CLASS_NAME Group
CLASS("Group", ["MessageReceiverEx" ARG "GOAP_Agent"]);

	//Variables
	VARIABLE_ATTR("data", [ATTR_SAVE]);

	// |                             N E W                                  |
	/*
	Method: new

	Parameters: _side, _groupType,

	_side - Side (west, east, etc) of this group
	_groupType - Number, group type, see <GROUP_TYPE>

	Returns: nil
	*/
	METHOD(new)
		params [P_THISOBJECT, ["_side", WEST, [WEST]], ["_groupType", GROUP_TYPE_INF, [GROUP_TYPE_INF]]];
		
		PROFILER_COUNTER_INC(GROUP_CLASS_NAME);
		
		OOP_INFO_2("NEW   side: %1, group type: %2", _side, _groupType);

		// Check existance of neccessary global objects
		ASSERT_GLOBAL_OBJECT(gMessageLoopMain);

		private _data = GROUP_DATA_DEFAULT;
		_data set [GROUP_DATA_ID_SIDE, _side];
		_data set [GROUP_DATA_ID_TYPE, _groupType];
		_data set [GROUP_DATA_ID_MUTEX, MUTEX_NEW()];
		T_SETV("data", _data);
	ENDMETHOD;

	// |                            D E L E T E
	/*
	Method: delete
	*/
	METHOD(delete)
		params [P_THISOBJECT];
		
		PROFILER_COUNTER_DEC(GROUP_CLASS_NAME);
		
		OOP_INFO_0("DELETE");

		pr _data = T_GETV("data");
		pr _units = _data select GROUP_DATA_ID_UNITS;

		// Delete the group from its garrison
		pr _gar = _data select GROUP_DATA_ID_GARRISON;
		if (_gar != NULL_OBJECT) then {
			CALLM1(_gar, "removeGroup", _thisObject);
		};

		// Despawn if spawned
		if (T_CALLM0("isSpawned")) then {
			T_CALLM0("despawn");
		};

		// Report an error if we are deleting a group with units in it
		if(count _units > 0) then {
			OOP_ERROR_2("Deleting a group that has units in it: %1, %2", _thisObject, _data);
			{
				DELETE(_x);
			} forEach _units;
		};

	ENDMETHOD;

	/*
	Method: getMessageLoop
	See <MessageReceiver.getMessageLoop>

	Returns: <MessageLoop>
	*/
	// Returns the message loop this object is attached to
	public override METHOD(getMessageLoop)
		gMessageLoopMain
	ENDMETHOD;


	// |                           A D D   U N I T
	/*
	Method: addUnit
	Adds existing <Unit> to this group. Also use it when you want to move unit between groups.

	Parameters: _units

	_unit - <Unit> to add

	Returns: bool - true if the unit was moved
	*/
	public METHOD(addUnit)
		params [P_THISOBJECT, P_OOP_OBJECT("_unit")];
		T_CALLM1("addUnits", [_unit]) > 0
	ENDMETHOD;

	// |                           A D D   U N I T S
	/*
	Method: addUnits
	Adds array of existing <Unit> to this group. Also use it when you want to move units between groups.

	Parameters: _units

	_units - Array of <Unit> to add

	Returns: number of units added
	*/
	public METHOD(addUnits)
		params [P_THISOBJECT, P_ARRAY("_units")];

		OOP_INFO_1("ADD UNITS: %1", _units);
		
		private _unitsToMove = _units select {
			// Valid units only
			CALLM0(_x, "isValid")
		} apply {
			// Get the unit group as we need it a couple of times
			[
				_x,
				CALLM0(_x, "getGroup")
			]
		} select {
			// Only move units not already in this group
			_x#1 != _thisObject
		};

		if(count _unitsToMove == 0) exitWith {
			// No units to move
			0
		};

		private _data = T_GETV("data");
		private _unitList = _data select GROUP_DATA_ID_UNITS;

		{// forEach _unitsToMove;
			_x params ["_unit", "_unitGroup"];
			// Remove the unit from its previous group
			if (_unitGroup != NULL_OBJECT) then {
				//if (CALLM0(_unitGroup, "getOwner") == clientOwner) then {
					CALLM1(_unitGroup, "removeUnit", _unit);
				//} else {
				//	CALLM3(_unitGroup, "postMethodAsync", "removeUnit", [_unit], false);
					//CALLM1(_unitGroup, "waitUntilMessageDone", _msgID);
				//};
			};
			// Add unit to the new group
			_unitList pushBackUnique _unit;
			CALLM1(_unit, "setGroup", _thisObject);
		} forEach _unitsToMove;

		// Associate the unit with the garrison of this group
		// todo

		// Handle spawn states
		if (T_CALLM0("isSpawned")) then {
			// Make the unit join the actual group
			pr _groupHandle = T_CALLM0("_createGroupHandle");
			private _unitsMoved = _unitsToMove apply { _x#0 };
			private _unitHandles = _unitsMoved apply { CALLM0(_x, "getObjectHandle") };
			_unitHandles join _groupHandle;

			// If the target group is spawned, notify its AI object
			private _AI = _data select GROUP_DATA_ID_AI;
			if (_AI != NULL_OBJECT) then {
				CALLM2(_AI, "postMethodSync", "handleUnitsAdded", [_unitsMoved]);
			};
		};

		// Select leader if needed
		private _leader = _data select GROUP_DATA_ID_LEADER;
		if (_leader == NULL_OBJECT) then {
			T_CALLM0("_selectNextLeader");
		};

		count _unitsToMove
	ENDMETHOD;

	/*
	Method: addGroup
	Moves all units from second group into this group.

	Parameters: _group

	_group - the group to move into this group
	_delete - Boolean, true - deletes the abandoned group. Default: false.

	Returns: nil
	*/

	public METHOD(addGroup)
		params [P_THISOBJECT, P_OOP_OBJECT("_group"), ["_delete", false]];

		OOP_INFO_1("ADD GROUP: %1", _group);

		// Get units of the other group
		pr _units = CALLM0(_group, "getUnits");

		// Add all units to this group
		{
			T_CALLM1("addUnit", _x);
		} forEach _units;

		// Delete the other group if needed
		if (_delete) then {
			DELETE(_group);
		};
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                        R E M O V E   U N I T                       |
	// ----------------------------------------------------------------------
	/*
	Method: removeUnit
	Removes a unit from this group.

	Access: internal use

	Parameters: _unit, _newGroup

	_unit - <Unit> that will be removed from this group.

	Returns: nil
	*/
	public METHOD(removeUnit)
		params [P_THISOBJECT, P_OOP_OBJECT("_unit")];
		T_CALLM1("removeUnits", [_unit]);
	ENDMETHOD;

	public METHOD(removeUnits)
		params [P_THISOBJECT, P_ARRAY("_unitsToRemove")];

		OOP_INFO_1("REMOVE UNITS: %1", _unitsToRemove);

		pr _data = T_GETV("data");

		// Notify group AI of these units being removed
		if (T_CALLM0("isSpawned")) then {
			pr _AI = _data select GROUP_DATA_ID_AI;
			if (_AI != NULL_OBJECT) then {
				CALLM3(_AI, "postMethodSync", "handleUnitsRemoved", [_unitsToRemove], true);
			};
		};

		// Remove the units from this group
		pr _units = _data select GROUP_DATA_ID_UNITS;
		{
			pr _unit = _x;
			pr _index = _units find _unit;
			if (_index == NOT_FOUND) then {
				OOP_ERROR_1("remoteUnit: Unit not found in group: %1", _unit);
				OOP_ERROR_1("  group units: %1", _units);
			};
			_units deleteAt _index;
			CALLM1(_unit, "setGroup", NULL_OBJECT);
		} forEach _unitsToRemove;

		// Select a new leader if one of the removed units is the current leader
		if ((_data select GROUP_DATA_ID_LEADER) in _unitsToRemove) then {
			T_CALLM0("_selectNextLeader");
		};
	ENDMETHOD;

	public METHOD(removeAllUnits)
		params [P_THISOBJECT, P_OOP_OBJECT("_unit")];
		// We write a custom method for this (rather than calling removeUnits) as a few steps can be skipped when we know we are removing all units

		OOP_INFO_0("REMOVE ALL UNITS");

		pr _data = T_GETV("data");
		pr _units = _data#GROUP_DATA_ID_UNITS;

		// Notify group AI of these units being removed
		if (T_CALLM0("isSpawned")) then {
			pr _AI = _data#GROUP_DATA_ID_AI;
			if (_AI != NULL_OBJECT) then {
				CALLM3(_AI, "postMethodSync", "handleUnitsRemoved", [_units], true);
			};
		};

		// Remove all units from this group
		{
			CALLM1(_x, "setGroup", NULL_OBJECT);
		} forEach _units;

		// Empty the units array
		_units resize 0;

		// Clear the leader as we removed all units
		_data set [GROUP_DATA_ID_LEADER, NULL_OBJECT];
	ENDMETHOD;

	// Create new group handle if it doesn't exist
	METHOD(_createGroupHandle)
		pr _groupHandle = grpNull;
		CRITICAL_SECTION {
			params [P_THISOBJECT];
			pr _data = T_GETV("data");
			_groupHandle = _data#GROUP_DATA_ID_GROUP_HANDLE;
			// Create group handle if it doesn't exist yet
			if (isNull _groupHandle) then {
				_groupHandle = createGroup [_data#GROUP_DATA_ID_SIDE, false]; //side, delete when empty
				_groupHandle allowFleeing 0; // Never flee
				_data set [GROUP_DATA_ID_GROUP_HANDLE, _groupHandle];

				// Initialize variables
				_groupHandle setVariable [GROUP_VAR_NAME_STR, _thisObject, true];	// Public variable!`
			};
		};
		_groupHandle
	ENDMETHOD;

	public METHOD(rectifyGroupHandle)
		params [P_THISOBJECT];

		pr _data = T_GETV("data");
		if(!(_data#GROUP_DATA_ID_SPAWNED)) exitWith {
			// not spawned so no group handle
		};
		pr _units = _data#GROUP_DATA_ID_UNITS;
		if(count _units == 0) exitWith {
			// no units so no group handle
		};
		// First try and use the existing group handle if there is one, it might have 
		// waypoints on it that we want to keep
		pr _groupHandle = _data#GROUP_DATA_ID_GROUP_HANDLE;
		if(isNull _groupHandle) then {
			// Try and use leaders group handle instead
			pr _leader = _data#GROUP_DATA_ID_LEADER;
			if(_leader == NULL_OBJECT) then {
				_leader = T_CALLM0("_selectNextLeader");
			};
			pr _leaderHandle = CALLM0(_leader, "getObjectHandle");
			_groupHandle = group _leaderHandle;
			_groupHandle allowFleeing 0;
			_data set [GROUP_DATA_ID_GROUP_HANDLE, _groupHandle];
		};
		// Reform other units back to the group
		pr _otherUnitHandles = (_units apply {CALLM0(_x, "getObjectHandle")});
		(_otherUnitHandles - units _groupHandle) joinSilent _groupHandle;
	ENDMETHOD;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                          G E T T I N G   M E M B E R   V A L U E S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -



	// |                         G E T   U N I T S
	/*
	Method: getUnits
	Returns an array with units in this group.

	Returns: Array of units.
	*/
	public METHOD(getUnits)
		params [P_THISOBJECT];
		+(T_GETV("data") # GROUP_DATA_ID_UNITS);
	ENDMETHOD;

	// |                         G E T  I N F A N T R Y  U N I T S
	/*
	Method: getInfantryUnits
	Returns all infantry units.

	Returns: Array of units.
	*/
	public METHOD(getInfantryUnits)
		params [P_THISOBJECT];
		(T_GETV("data") # GROUP_DATA_ID_UNITS) select { CALLM0(_x, "isInfantry") }
	ENDMETHOD;

	// |                         G E T   V E H I C L E   U N I T S
	/*
	Method: getVehicleUnits
	Returns all vehicle units.

	Returns: Array of units.
	*/
	public METHOD(getVehicleUnits)
		params [P_THISOBJECT];
		(T_GETV("data") # GROUP_DATA_ID_UNITS) select { CALLM0(_x, "isVehicle") }
	ENDMETHOD;

	// |                         G E T   D R O N E   U N I T S
	/*
	Method: getDroneUnits
	Returns all drone units.

	Returns: Array of units.
	*/
	public METHOD(getDroneUnits)
		params [P_THISOBJECT];
		(T_GETV("data") # GROUP_DATA_ID_UNITS) select { CALLM0(_x, "isDrone") }
	ENDMETHOD;

	/*
	Method: getAirUnits
	Returns all air units.

	Returns: Array of units.
	*/
	public METHOD(getAirUnits)
		params [P_THISOBJECT];
		(T_GETV("data") # GROUP_DATA_ID_UNITS) select { CALLM0(_x, "isAir") }
	ENDMETHOD;

	// |                         G E T   T Y P E                            |
	/*
	Method: getType
	Returns <GROUP_TYPE>

	Returns: Number, group type. See <GROUP_TYPE>,
	*/
	public METHOD(getType)
		params [P_THISOBJECT];
		T_GETV("data") # GROUP_DATA_ID_TYPE
	ENDMETHOD;

	// |                         G E T   S I D E                            |
	/*
	Method: getSide
	Returns side of this group

	Returns: Side
	*/
	public METHOD(getSide)
		params [P_THISOBJECT];
		T_GETV("data") # GROUP_DATA_ID_SIDE
	ENDMETHOD;

	// |                  G E T   G R O U P   H A N D L E
	/*
	Method: getGroupHandle
	Returns the group handle of this group.

	Returns: group handle.
	*/
	public METHOD(getGroupHandle)
		params [P_THISOBJECT];
		T_GETV("data") # GROUP_DATA_ID_GROUP_HANDLE
	ENDMETHOD;

	// |                  S E T / G E T   L E A D E R
	/*
	Method: getLeader
	Returns the leader of the group.
	!!! Warning: might return a dead unit!

	Returns: <Unit> object
	*/
	public METHOD(getLeader)
		params [P_THISOBJECT];
		T_GETV("data") # GROUP_DATA_ID_LEADER
	ENDMETHOD;

	public METHOD(getPos)
		params [P_THISOBJECT];
		if(!T_CALLM0("isSpawned")) exitWith {
			private _garrison = T_CALLM0("getGarrison");
			CALLM0(_garrison, "getPos")
		};

		private _leader = T_CALLM0("getLeader");
		if(_leader != NULL_OBJECT) exitWith {
			CALLM0(_leader, "getPos")
		};

		private _garrison = T_CALLM0("getGarrison");
		CALLM0(_garrison, "getPos")
	ENDMETHOD;

	/*
	Method: (static)getGroupFromGroupHandle
	Returns the <Group> object the given group handle is associated with, or "" if this groupHandle is not associated with <Group>

	Parameters: _groupHandle

	_groupHandle - the object handle of a unit.

	Returns: <Group> or ""
	*/
	public STATIC_METHOD(getGroupFromGroupHandle)
		params [P_THISCLASS, P_GROUP("_groupHandle") ];
		_groupHandle getVariable [GROUP_VAR_NAME_STR, ""]
	ENDMETHOD;
	
	/*
	Method: setLeader
	Sets the leader of this group to a specified Unit. The Unit must belong to this group.
	*/
	public METHOD(setLeader)
		params [P_THISOBJECT, P_OOP_OBJECT("_unit")];

		pr _data = T_GETV("data");

		if(_data#GROUP_DATA_ID_LEADER == _unit) exitWith {
			// Already set
		};

		if(!(_unit in _data#GROUP_DATA_ID_UNITS)) exitWith {
			OOP_ERROR_2("Unit %1 cannot lead group %2 as it doesn't belong to it", _unit, _thisObject);
		};

		if(!CALLM0(_unit, "isInfantry")) exitWith {
			OOP_ERROR_2("Unit %1 cannot lead group %2 as it isn't infantry", _unit, _thisObject);
		};
		
		if (_data#GROUP_DATA_ID_SPAWNED) then {
			pr _hO = CALLM0(_unit, "getObjectHandle");
			if (isNull _hO) then {
				OOP_ERROR_1("Unit %1 is null object!", _unit);
				T_CALLM0("_selectNextLeader"); // Select a new leader
			} else {
				pr _hG = _data#GROUP_DATA_ID_GROUP_HANDLE;
				_hG selectLeader _hO;
				_data set [GROUP_DATA_ID_LEADER, _unit];
			};
		} else {
			_data set [GROUP_DATA_ID_LEADER, _unit];
		};
	ENDMETHOD;

	// Selects the next leader when the current one is removed or whatever
	// If there is no more infantry, it sets leader to NULL_OBJECT (no leader)
	METHOD(_selectNextLeader)
		params [P_THISOBJECT];

		pr _data = T_GETV("data");
		pr _infUnits = T_CALLM0("getInfantryUnits");
		if (count _infUnits == 0) then {
			// There is no leader in this group any more
			_data set [GROUP_DATA_ID_LEADER, NULL_OBJECT];
			NULL_OBJECT
		} else {
			pr _leader = _infUnits#0;

			if (_data#GROUP_DATA_ID_SPAWNED) then {
				pr _hG = _data#GROUP_DATA_ID_GROUP_HANDLE;
				pr _hO = CALLM0(_leader, "getObjectHandle");
				if (isNull _hO) then {
					OOP_ERROR_1("Unit %1 is null object!", _leader);
				} else {
					_hG selectLeader _hO;
					_data set [GROUP_DATA_ID_LEADER, _leader];
				};
			} else {
				_data set [GROUP_DATA_ID_LEADER, _leader];
			};
			_leader
		}
	ENDMETHOD;

	// All the units in the group have just been spawned so we must select the right leader
	METHOD(_selectLeaderOnSpawn)
		params [P_THISOBJECT];

		pr _data = T_GETV("data");
		pr _leader = _data select GROUP_DATA_ID_LEADER;
		if (_leader == NULL_OBJECT) exitWith {};
		pr _hO = CALLM0(_leader, "getObjectHandle");
		pr _hG = _data select GROUP_DATA_ID_GROUP_HANDLE;
		_hG selectLeader _hO;
	ENDMETHOD;

	// |                     S E T / G E T   G A R R I S O N                |
	//
	/*
	Method: setGarrison
	Sets the <Garrison> of this garrison.
	Use <Garrison.addGroup> to add a group to a garrison.

	Access: internal use.

	Parameters: _garrison

	_garrison - <Garrison>

	Returns: nil
	*/
	public METHOD(setGarrison)
		params [P_THISOBJECT, P_OOP_OBJECT("_garrison") ];
		private _data = T_GETV("data");
		_data set [GROUP_DATA_ID_GARRISON, _garrison];

		// Set the garrison of all units in this group
		private _units = _data select GROUP_DATA_ID_UNITS;
		{ CALLM(_x, "setGarrison", [_garrison]); } forEach _units;
	ENDMETHOD;


	/*
	Method: getGarrison
	Returns the <Garrison> this Group is attached to.

	Returns: String, <Garrison>
	*/
	public METHOD(getGarrison)
		params [P_THISOBJECT];
		T_GETV("data") select GROUP_DATA_ID_GARRISON
	ENDMETHOD;


	// |                           I S   S P A W N E D
	/*
	Method: isSpawned
	Returns the spawned state of this group

	Returns: Bool
	*/
	public METHOD(isSpawned)
		params [P_THISOBJECT];
		T_GETV("data") select GROUP_DATA_ID_SPAWNED
	ENDMETHOD;
	
	// 								I S   E M P T Y 
	/*
	Method: isEmpty
	Returns true if group has no units in it

	Returns: Bool
	*/
	public METHOD(isEmpty)
		params [P_THISOBJECT];
		count (T_GETV("data") select GROUP_DATA_ID_UNITS) == 0
	ENDMETHOD;

	/*
	Method: isAirGroup
	Returns true if group has air units in it

	Returns: Bool
	*/
	public METHOD(isAirGroup)
		params [P_THISOBJECT];
		count T_CALLM0("getAirUnits") > 0
	ENDMETHOD;

	/*
	Method: isLanded
	Returns true if group is landed on the ground (if air units), or beach (if water units)

	Returns: Bool
	*/
	public METHOD(isLanded)
		params [P_THISOBJECT];
		private _AI = T_CALLM0("getAI");
		_AI == NULL_OBJECT || { CALLM0(_AI, "isLanded") }
	ENDMETHOD;
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                                E V E N T   H A N D L E R S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


	// |                 H A N D L E   U N I T   K I L L E D                |
	/*
	Method: handleUnitRemoved
	Called when the unit has been removed (killed or moved to a different place).

	Must be called inside the group's thread, not inside event handler.

	Returns: nil
	*/
	public METHOD(handleUnitRemoved)
		params [P_THISOBJECT, P_OOP_OBJECT("_unit")];

		diag_log format ["[Group::handleUnitRemoved] Info: %1", _unit];

		T_CALLM1("removeUnit", _unit);
	ENDMETHOD;

	// |              H A N D L E   U N I T   D E S P A W N E D             |
	/*
	Method: handleUnitDespawned
	NYI

	Returns: nil
	*/
	public METHOD(handleUnitDespawned)
		params [P_THISOBJECT, P_OOP_OBJECT("_unit") ];
	ENDMETHOD;

	// |                 H A N D L E   U N I T   S P A W N E D              |
	/*
	Method: handleUnitSpawned
	NYI

	Returns: nil
	*/
	public METHOD(handleUnitSpawned)
		params [P_THISOBJECT, "_unit"];
	ENDMETHOD;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                          S P A W N I N G   A N D   D E S P A W N I N G
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	// |                           C R E A T E   A I
	/*
	Method: createAI
	Creates an <AIGroup> for this group.

	Access: internal.

	Returns: Created <AI> object
	*/
	METHOD(createAI)
		params [P_THISOBJECT];

		pr _data = T_GETV("data");

		if(_data # GROUP_DATA_ID_AI != NULL_OBJECT) exitWith {
			OOP_ERROR_0("Group AI is already created");
		};

		pr _AI = NEW("AIGroup", [_thisObject]);
		_data set [GROUP_DATA_ID_AI, _AI];

		CALLM0(_AI, "start");

		// Return
		_AI
	ENDMETHOD;




	// |         S P A W N   A T   L O C A T I O N
	/*
	Method: spawnAtLocation
	Spawns all the units in this group at specified location.

	Parameters: _loc

	_loc - <Location> where the group will spawn.

	Returns: nil
	*/
	public METHOD(spawnAtLocation)
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];

		OOP_INFO_1("SPAWN AT LOCATION: %1", _loc);

		pr _data = T_GETV("data");
		if (!(_data select GROUP_DATA_ID_SPAWNED)) then {
			pr _groupUnits = _data select GROUP_DATA_ID_UNITS;
			pr _groupType = _data select GROUP_DATA_ID_TYPE;
			pr _groupHandle = T_CALLM0("_createGroupHandle");

			_groupHandle setBehaviour "SAFE";

			{
				private _unit = _x;
				private _unitData = CALLM0(_unit, "getMainData");
				private _args = _unitData + [_groupType]; // P_NUMBER("_catID"), P_NUMBER("_subcatID"), P_STRING("_className"), P_STRING("_groupType")
				private _posAndDir = CALLM(_loc, "getSpawnPos", _args);

				// Recreate group handle if needed, for some reason although we create it above, it might get deleted between these calls. Why, arma?
				T_CALLM0("_createGroupHandle");

				CALLM(_unit, "spawn", _posAndDir);
			} forEach _groupUnits;

			// Select leader
			T_CALLM0("_selectLeaderOnSpawn");

			// Create an AI for this group
			T_CALLM0("createAI");

			// Set the spawned flag to true
			_data set [GROUP_DATA_ID_SPAWNED, true];
		} else {
			OOP_ERROR_0("Already spawned");
			DUMP_CALLSTACK;
		};
	ENDMETHOD;

	//	S P A W N   V E H I C L E S   O N   R O A D
	/*
	Method: spawnVehiclesOnRoad
	Spawns vehicles in this group specified positions, one after another. Infantry units are spawned nearby.
	This function is intended for vehicle groups to spawn them on a road.

	Parameters: _vehPosAndDir, _startPos

	_vehPosAndDir - array of [_posATL, _dir] where vehicles will be spawned.
	_startPos - positoon ATL, optional, if used, then _vehPosAndDir will be ignored and the function will find positions on road on its own.

	Returns: nil
	*/
	public METHOD(spawnVehiclesOnRoad)
		params [P_THISOBJECT, P_ARRAY("_posAndDir"), P_ARRAY("_startPos")];

		OOP_INFO_2("SPAWN VEHICLES ON ROAD: _posAndDir: %1, _startPos: %2", _posAndDir, _startPos);

		pr _data = T_GETV("data");
		if (!(_data select GROUP_DATA_ID_SPAWNED)) then {
			pr _groupUnits = _data select GROUP_DATA_ID_UNITS;
			pr _groupType = _data select GROUP_DATA_ID_TYPE;
			pr _groupHandle = T_CALLM0("_createGroupHandle");
			
			_groupHandle setBehaviour "SAFE";
			
			// Handle vehicles first
			pr _vehUnits = T_CALLM0("getVehicleUnits");
			// Find positions manually if not enough spawn positions were provided or _startPos parameter was passed
			if ((count _vehUnits > count _posAndDir) || !(_startPos isEqualTo [])) then {
				if (count _vehUnits > count _posAndDir) then {
					OOP_WARNING_0("Not enough positions for all vehicles!");
				};
				{
					CALLM0(_x, "getMainData") params ["_cat", "_subcat", "_className"];
					pr _posAndDir = if(_cat == T_VEH && _subcat in T_VEH_ground) then {
						CALLSM3("Location", "findSafePosOnRoad", _pos, _className, 300)
					} else {
						CALLSM3("Location", "findSafePos", _pos, _className, 300)
					};
					CALLM(_x, "spawn", _posAndDir);
				} forEach _vehUnits;
			} else {
				{
					(_posAndDir select _forEachIndex) params ["_pos", "_dir"];
					// Check if this position is safe
					pr _className = CALLM0(_x, "getClassName");
					//diag_log format ["--- Finding a pos for a vehicle: %1", _className];
					if (!CALLSM3("Location", "isPosSafe", _pos, _dir, _className)) then {
						//diag_log format ["   Provided position is not safe. Finding a safe pos on road"];
						pr _return = CALLSM3("Location", "findSafePosOnRoad", _pos, _className, 300);
						_return params ["_posReturn", "_dirReturn"];
						CALLM2(_x, "spawn", _posReturn, _dirReturn);
					} else {
						//diag_log format ["   Provided position is safe!"];
						CALLM2(_x, "spawn", _pos, _dir);
					};
				} forEach _vehUnits;
			};

			// Handle infantry
			pr _infUnits = T_CALLM0("getInfantryUnits");
			// Get position around which infantry will be spawning
			pr _infSpawnPos = if !(_startPos isEqualTo []) then {
				_startPos
			} else {
				// First position
				_posAndDir#0#0
			};
			{
				// todo improve this
				pr _pos = _infSpawnPos vectorAdd [-15 + random 15, -15 + random 15, 0]; // Just put them anywhere

				// Recreate group handle if needed, for some reason although we create it above, it might get deleted between these calls. Why, arma?
				T_CALLM0("_createGroupHandle");

				CALLM2(_x, "spawn", _pos, 0);
			} forEach _infUnits;

			// todo Handle drones??

			// Select leader
			T_CALLM0("_selectLeaderOnSpawn");

			// Create an AI for this group
			T_CALLM0("createAI");

			// Set the spawned flag to true
			_data set [GROUP_DATA_ID_SPAWNED, true];
		} else {
			OOP_ERROR_0("Already spawned");
			DUMP_CALLSTACK;
		};
	ENDMETHOD;

	//	S P A W N   A T   P O S 
	/*
	Method: spawnAtPos
	Vehicles are spawned at road nearest to the provided position, infantry units are spawned at provided position.

	Parameters: _pos

	_pos - position
	_global - if true then the units will be spawned at their saved positions

	Returns: nil
	*/
	public METHOD(spawnAtPos)
		params [P_THISOBJECT, P_ARRAY("_pos"), P_BOOL("_global")];

		OOP_INFO_1("SPAWN AT POS: %1", _pos);

		pr _data = T_GETV("data");
		if (!(_data select GROUP_DATA_ID_SPAWNED)) then {
			pr _groupType = _data select GROUP_DATA_ID_TYPE;
			pr _groupHandle = T_CALLM0("_createGroupHandle");
			
			_groupHandle setBehaviour "SAFE";
			
			if(_global) then {
				pr _groupUnits = _data select GROUP_DATA_ID_UNITS;
				{
					CALLM3(_x, "spawn", _pos, 0, _global);
				} forEach _groupUnits;
			} else {
				// Handle vehicles first
				pr _vehUnits = T_CALLM0("getVehicleUnits");
				{
					CALLM0(_x, "getMainData") params ["_cat", "_subcat", "_className"];
					pr _posAndDir = if(_cat == T_VEH && _subcat in T_VEH_ground) then {
						CALLSM3("Location", "findSafePosOnRoad", _pos, _className, 300)
					} else {
						CALLSM3("Location", "findSafePos", _pos, _className, 300)
					};
					CALLM(_x, "spawn", _posAndDir);
				} forEach _vehUnits;

				// Handle infantry
				pr _infUnits = T_CALLM0("getInfantryUnits");

				// Get position around which infantry will be spawning
				pr _infSpawnPos = _pos;
				{
					pr _pos = _infSpawnPos getPos [random 15, random 360]; // Just put them anywhere

					// Recreate group handle if needed, for some reason although we create it above, it might get deleted between these calls. Why, arma?
					T_CALLM0("_createGroupHandle");

					CALLM2(_x, "spawn", _pos, 0);
				} forEach _infUnits;

				// todo Handle drones??
			};

			// Select leader
			T_CALLM0("_selectLeaderOnSpawn");

			// Create an AI for this group
			T_CALLM0("createAI");

			// Set the spawned flag to true
			_data set [GROUP_DATA_ID_SPAWNED, true];
		} else {
			OOP_ERROR_0("Already spawned");
			DUMP_CALLSTACK;
		};
	ENDMETHOD;

	//	S P A W N   I N   A I R
	/*
	Method: spawnInAir
	Vehicles are spawned in the air, infantry in seats as crew

	Parameters: _pos

	_pos - position

	Returns: nil
	*/
	public METHOD(spawnInAir)
		params [P_THISOBJECT, P_ARRAY("_pos")];

		OOP_INFO_1("SPAWN IN AIR: %1", _pos);

		pr _data = T_GETV("data");
		if (!(_data select GROUP_DATA_ID_SPAWNED)) then {
			pr _groupUnits = _data select GROUP_DATA_ID_UNITS;
			pr _groupType = _data select GROUP_DATA_ID_TYPE;
			pr _groupHandle = T_CALLM0("_createGroupHandle");

			_groupHandle setBehaviour "SAFE";

			// Handle infantry
			pr _infUnits = T_CALLM0("getInfantryUnits");

			// Get position around which infantry will be spawning
			pr _infSpawnPos = _pos;
			{
				pr _pos = _infSpawnPos getPos [random 15, random 360]; // Just put them anywhere
				CALLM2(_x, "spawn", _pos, 0);
			} forEach _infUnits;

			// Handle vehicles
			pr _vehUnits = T_CALLM0("getVehicleUnits");

			pr _vehiclesToCrew = [];
			{
				private _vehicle = _x;
				CALLM0(_vehicle, "getMainData") params ["_cat", "_subcat", "_className"];
				pr _posAndDir = switch true do {
					case (_subcat in T_VEH_ground): {
						CALLSM3("Location", "findSafePosOnRoad", _pos, _className, 300)
					};
					case (_subcat in T_VEH_air): {
						_vehiclesToCrew pushBack ([_vehicle] + ([CALLM0(_vehicle, "getClassName")] call misc_fnc_getFullCrew));
						// TODO: determine spawn in height more intelligently (perhaps save it...)
						[_pos getPos [_forEachIndex * 30, random 360] vectorAdd [0, 0, 50], 0]
					};
					default {
						CALLSM3("Location", "findSafePos", _pos, _className, 300)
					};
				};
				CALLM(_x, "spawn", _posAndDir);
			} forEach _vehUnits;

			// Assign drivers first to make sure we all have drivers
			{
				_x params ["_vehicle", "_n_driver", "_copilotTurrets", "_stdTurrets", "_psgTurrets", "_n_cargo"];
				if (_n_driver > 0 && count _infUnits > 0) then {
					private _driver = _infUnits deleteAt 0;
					private _driverAI = CALLM0(_driver, "getAI");
					CALLM1(_driverAI, "assignAsDriver", _vehicle);
					CALLM0(_driverAI, "executeVehicleAssignment");
					CALLM0(_driverAI, "moveInAssignedVehicle");
				};
			} forEach _vehiclesToCrew;

			// Assign co-pilots and turrets next
			{
				_x params ["_vehicle", "_n_driver", "_copilotTurrets", "_stdTurrets", "_psgTurrets", "_n_cargo"];
				{
					private _turretPath = _x;
					if(count _infUnits > 0) then {
						private _driver = _infUnits deleteAt 0;
						private _driverAI = CALLM0(_driver, "getAI");
						CALLM2(_driverAI, "assignAsTurret", _vehicle, _turretPath);
						CALLM0(_driverAI, "executeVehicleAssignment");
						CALLM0(_driverAI, "moveInAssignedVehicle");
					};
				} forEach (_stdTurrets + _copilotTurrets);
			} forEach _vehiclesToCrew;

			// todo Handle drones??

			// Select leader
			T_CALLM0("_selectLeaderOnSpawn");

			// Create an AI for this group
			T_CALLM0("createAI");

			// Set the spawned flag to true
			_data set [GROUP_DATA_ID_SPAWNED, true];
		} else {
			OOP_ERROR_0("Already spawned");
			DUMP_CALLSTACK;
		};
	ENDMETHOD;

	// |         D E S P A W N
	/*
	Method: despawn
	Despawns all units in this group. Also deletes the group handle.

	Returns: nil
	*/
	public METHOD(despawn)
		params [P_THISOBJECT];

		OOP_INFO_0("DESPAWN");

		pr _data = T_GETV("data");
		if (_data select GROUP_DATA_ID_SPAWNED) then {
			pr _AI = _data select GROUP_DATA_ID_AI;
			if (_AI != NULL_OBJECT) then {
				// Switch off their brain
				// We must safely delete the AI object because it might be currently used in its own thread
				CALLM2(gMessageLoopGroupManager, "postMethodSync", "deleteObject", [_AI]);
				_data set [GROUP_DATA_ID_AI, NULL_OBJECT];
			};

			// Despawn everything
			pr _groupUnits = _data select GROUP_DATA_ID_UNITS;
			{
				CALLM0(_x, "despawn");
			} forEach _groupUnits;

			// Delete the group handle
			pr _groupHandle = _data select GROUP_DATA_ID_GROUP_HANDLE;
			if (count units _groupHandle > 0) then {
				OOP_WARNING_1("Group is not empty at despawning: %1. Units remaining:", _data);
				{
					diag_log format ["  %1,  alive: %2", _x, alive _x];
				} forEach (units _groupHandle);
				_groupHandle deleteGroupWhenEmpty true;
			} else {
				deleteGroup _groupHandle;
			};
			_data set [GROUP_DATA_ID_GROUP_HANDLE, grpNull];

			// Set the spawned flag to false
			_data set [GROUP_DATA_ID_SPAWNED, false];
		} else {
			OOP_ERROR_0("Already despawned");
			DUMP_CALLSTACK;
		};
	ENDMETHOD;

	// |         S O R T
	/*
	Method: sort
	Makes passed units rejoin this group in specified order. Useful for reorganizing formation for convoys.

	Parameters: _unitsSorted

	_unitsSorted - Array with <Unit> objects

	Returns: nil
	*/
	public METHOD(sort)
		params [P_THISOBJECT, P_ARRAY("_unitsSorted")];

		pr _data = T_GETV("data");

		if (!(_data#GROUP_DATA_ID_SPAWNED)) exitWith {
			OOP_ERROR_0("sort: group is not spawned!");
		};

		pr _hG = T_CALLM0("_createGroupHandle");

		if (count (units _hG) < 2) exitWith {
			// Bail if the group has only one unit
		};

		OOP_INFO_1("Group handle: %1", _hG);

		pr _infantryUnitsOnly = _unitsSorted select { CALLM0(_x, "isInfantry") };
		if(count _infantryUnitsOnly <= 1) exitWith {
			OOP_INFO_0("sort: no sorting necessary, less than 2 infantry units provided");
		};

		// We sort by removing all units except the leader from the group, then readding them
		// Make all passed units join the new temporary group
		pr _newLeader = _infantryUnitsOnly deleteAt 0;

		pr _allButLeader = _infantryUnitsOnly apply { CALLM0(_x, "getObjectHandle") };

		// Create a temporary group
		pr _tempGroupHandle = createGroup (_data#GROUP_DATA_ID_SIDE);

		// Join everyone else to the other group, leaving only the leader behind
		_allButLeader joinSilent _tempGroupHandle;

		// Rejoin in correct order
		_allButLeader joinSilent _hG;

		deleteGroup _tempGroupHandle;

		T_CALLM1("setLeader", _newLeader);
	ENDMETHOD;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                                         G O A P
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	// |                           G E T   A I
	/*
	Method: getAI
	Returns the <AI> of this group, if it's spawned, or "" otherwise.

	Returns: String, <AIGroup>
	*/
	public override METHOD(getAI)
		params [P_THISOBJECT];
		T_GETV("data") select GROUP_DATA_ID_AI
	ENDMETHOD;

	//                          G E T   S U B A G E N T S
	/*
	Method: getSubagents
	Returns subagents of this agent.
	For group subagents are its units, since their <AIUnit> is processed synchronosuly with <AIGroup> by default.

	Access: Used by AI class

	Returns: array of units.
	*/
	public override METHOD(getSubagents)
		params [P_THISOBJECT];
		// All units can have AI
		T_GETV("data") select GROUP_DATA_ID_UNITS;
	ENDMETHOD;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                                O W N E R S H I P   T R A N S F E R
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	/*
	Method: serialize
	See <MessageReceiver.serialize>
	*/
	// Must return a single value which can be deserialized to restore value of an object
	protected override METHOD(serialize)
		params [P_THISOBJECT];

		diag_log "[Group:serialize] was called!";

		pr _data = T_GETV("data");
		pr _units = _data select GROUP_DATA_ID_UNITS;

		// Store data on all units in this group
		pr _unitsSerialized = [];
		private _units = _data select GROUP_DATA_ID_UNITS;
		{
			pr _unitDataArray = GETV(_x, "data");
			_unitsSerialized pushBack [_x, +_unitDataArray];
		} forEach _units;

		// Store data about this group
		[_unitsSerialized, _data];
	ENDMETHOD;

	/*
	Method: deserialize
	See <MessageReceiver.deserialize>
	*/
	// Takes the output of deserialize and restores values of an object
	protected override METHOD(deserialize)
		params [P_THISOBJECT, "_serialData"];

		diag_log "[Group:deserialize] was called!";

		// Unpack the array
		_serialData params ["_unitsSerialized", "_data"];
		T_SETV("data", _data);
		_data set [GROUP_DATA_ID_MUTEX, MUTEX_NEW()];

		// Unpack all the units
		{ // forEach _unitsSerialized
			_x params ["_unitObjNameStr", "_unitDataArray"];
			pr _newUnit = NEW_EXISTING("Unit", _unitObjNameStr);
			SETV(_newUnit, "data", +_unitDataArray);

			// Create a new AI for this unit, if it existed
			pr _unitAI = _unitDataArray select UNIT_DATA_ID_AI;
			diag_log format [" --- Old unit AI: %1", _unitAI];
			if (_unitAI != NULL_OBJECT) then {
				CALLM0(_newUnit, "createAI");
				diag_log format [" --- Created new unit AI: %1", _unitDataArray select UNIT_DATA_ID_AI];
			};
		} forEach _unitsSerialized;

		// Create a new AI for this group
		if (_data select GROUP_DATA_ID_AI != NULL_OBJECT) then {
			T_CALLM0("createAI");
		};

	ENDMETHOD;

	/*
	Method: transferOwnership
	See <MessageReceiver.transferOwnership>
	*/
	protected override METHOD(transferOwnership)
		params [P_THISOBJECT, P_NUMBER("_newOwner") ];

		diag_log "[Group:transferOwnership] was called!";

		pr _data = T_GETV("data");

		// Delete the AI of this group
		// todo transfer the AI instead, or just transfer the goals and most important data?
		pr _AI = _data select GROUP_DATA_ID_AI;
		if (_AI != NULL_OBJECT) then {
			pr _msg = MESSAGE_NEW_SHORT(_AI, AI_MESSAGE_DELETE); // if you ever look at it again, redo it!! with posting msg to group thread manager
			pr _msgID = CALLM2(_AI, "postMessage", _msg, true);
			//if (_msgID < 0) then {diag_log format ["--- Got wrong msg ID %1 %2 %3", _msgID, __FILE__, __LINE__];};
			T_CALLM("waitUntilMessageDone", [_msgID]);
		};

		// Delete AI of all the units
		pr _units = _data select GROUP_DATA_ID_UNITS;
		{
			pr _unitData = GETV(_x, "data");
			pr _unitAI = _unitData select UNIT_DATA_ID_AI;
			if (_unitAI != NULL_OBJECT) then {
				pr _msg = MESSAGE_NEW_SHORT(_unitAI, AI_MESSAGE_DELETE); // if you ever look at it again, redo it!! with posting msg to group thread manager
				pr _msgID = CALLM2(_unitAI, "postMessage", _msg, true);
				//diag_log format ["--- Got msg ID %1 %2 %3 while deleting Unit's AI", _msgID, __FILE__, __LINE__];
				T_CALLM("waitUntilMessageDone", [_msgID]);
			};
		} forEach _units;

		// Switch group owner if the group was spawned
		pr _groupHandle = _data select GROUP_DATA_ID_GROUP_HANDLE;
		if (!isNull _groupHandle) then {
			if (clientOwner == 2) then {
				_groupHandle setGroupOwner _newOwner;
			} else {
				[_groupHandle, _newOwner] remoteExecCall ["setGroupOwner", 2, false];
			};
		};

		// We're done here
		true
	ENDMETHOD;




	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                               O T H E R   M E T H O D S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


	// |         C R E A T E   U N I T S   F R O M   T E M P L A T E
	/*
	Method: createUnitsFromTemplate
	Creates units from template and adds them to this group.

	Parameters: _template, _subcatID

	_template - <Template>
	_subcatID - subcategory of this group template

	Returns: Number, amount of created units.
	*/
	public METHOD(createUnitsFromTemplate)
		params [P_THISOBJECT, P_ARRAY("_template"), P_NUMBER("_subcatID")];
		private _groupData = [_template, _subcatID, -1] call t_fnc_selectGroup;

		// Create every unit and add it to this group
		{
			private _catID = _x select 0;
			private _subcatID = _x select 1;
			private _classID = _x select 2;
			if ([_template, _catID, _subcatID, _classID] call t_fnc_isValid) then {
				private _args = [_template, _catID, _subcatID, _classID, _thisObject]; //P_ARRAY("_template"), P_NUMBER("_catID"), P_NUMBER("_subcatID"), P_NUMBER("_classID"), P_OOP_OBJECT("_group")
				NEW("Unit", _args);
			} else {
				OOP_ERROR_4("createUnitFromTemplate: [%1, %2, %3] is not a valid unit for template %4", _catID, _subcatID, _classID, _template select T_NAME);
			};
		} forEach _groupData;

		count _groupData
	ENDMETHOD;

	/*
	Method: getRequiredCrew
	Returns amount of needed drivers and turret operators for all vehicles in this group. Also returns amount of available cargo seats.

	Returns: [_nDrivers, _nTurrets, _nCargo]
	*/

	public METHOD(getRequiredCrew)
		params [P_THISOBJECT];

		pr _units = T_GETV("data") select GROUP_DATA_ID_UNITS;

		pr _nDrivers = 0;
		pr _nTurrets = 0;
		pr _nCargo = 0;

		{
			if (CALLM0(_x, "isVehicle")) then {
				pr _className = CALLM0(_x, "getClassName");
				([_className] call misc_fnc_getFullCrew) params ["_n_driver", "_copilotTurrets", "_stdTurrets", "_psgTurrets", "_n_cargo"];
				_nDrivers = _nDrivers + _n_driver;
				_nTurrets = _nTurrets + (count _copilotTurrets) + (count _stdTurrets);
				_nCargo = _nCargo + (count _psgTurrets) + _n_cargo;
			};
		} forEach _units;

		OOP_INFO_3("getRequiredCrew: drivers: %1, turrets: %2, cargo: %3", _nDrivers, _nTurrets, _nCargo);

		[_nDrivers, _nTurrets, _nCargo]
	ENDMETHOD;



	// - - - - - - - STORAGE - - - - - - - -
	public override METHOD(preSerialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
		
		// Save units which we own
		pr _data = T_GETV("data");
		{
			pr _unit = _x;
			//diag_log format ["Saving unit: %1", _unit];
			CALLM1(_storage, "save", _x);
		} forEach (_data#GROUP_DATA_ID_UNITS);

		true
	ENDMETHOD;

	public override METHOD(serializeForStorage)
		params [P_THISOBJECT];
		
		pr _data = +T_GETV("data");
		_data set [GROUP_DATA_ID_GROUP_HANDLE, 0];
		_data set [GROUP_DATA_ID_MUTEX, 0];
		_data set [GROUP_DATA_ID_AI, 0];
		_data set [GROUP_DATA_ID_SPAWNED, 0];

		_data
	ENDMETHOD;

	public override METHOD(deserializeFromStorage)
		params [P_THISOBJECT, P_ARRAY("_serial")];
		
		_serial set [GROUP_DATA_ID_GROUP_HANDLE, grpNull];
		_serial set [GROUP_DATA_ID_MUTEX, MUTEX_NEW()];
		_serial set [GROUP_DATA_ID_AI, ""];
		_serial set [GROUP_DATA_ID_SPAWNED, false];

		T_SETV("data", _serial);

		true
	ENDMETHOD;

	public override METHOD(postDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		// Call method of all base classes
		CALLCM("MessageReceiverEx", _thisObject, "postDeserialize", [_storage]);

		pr _data = T_GETV("data");

		// Load all units which we own
		{
			pr _unit = _x;
			CALLM1(_storage, "load", _unit);
		} forEach (_data#GROUP_DATA_ID_UNITS);

		// Cleanup
		private _leader = _data#GROUP_DATA_ID_LEADER;
		if(_leader != NULL_OBJECT && !IS_OOP_OBJECT(_leader)) then {
			OOP_WARNING_2("Cleanup: group %1 leader %2 is not a valid object", _thisObject, _leader);
			T_CALLM0("_selectNextLeader");
		};

		true
	ENDMETHOD;

ENDCLASS;


// Tests
#ifdef _SQF_VM

["Group.save and load", {

	_Test_group_args = [WEST, 0]; // Side, group type
	_Test_unit_args = [tNATO, T_INF, T_INF_LMG, -1];

	private _group = NEW("Group", _Test_group_args);
	private _units = [];
	for "_i" from 0 to 3 do {
		pr _unit = NEW("Unit", _Test_unit_args + [_group]);
		_units pushBack _unit;
	};

	pr _storage = NEW("StorageProfileNamespace", []);
	CALLM1(_storage, "open", "testRecordGroup");
	CALLM1(_storage, "save", _group);
	{
		DELETE(_x);
	} forEach CALLM0(_group, "getUnits");
	DELETE(_group);
	CALLM1(_storage, "load", _group);

	["Object loaded", CALLM0(_group, "getSide") == WEST] call test_Assert;
	["Group's unit loaded", CALLM0(_units#1, "getCategory") == T_INF] call test_Assert;

	true
}] call test_AddTest;


#endif