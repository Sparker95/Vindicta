#include "common.hpp"

/*
Class: Garrison
Garrison is an object which holds units and groups and handles their lifecycle (spawning, despawning, destruction).
Garrison is much like a group, it has an <AIGarrison>. But it can have multiple groups of different types.

Author: Sparker 12.07.2018


*/

#define pr private

#define WARN_GARRISON_DESTROYED OOP_WARNING_MSG("Attempted to call function on destroyed garrison %1", [_thisObject])

CLASS("Garrison", "MessageReceiverEx");

	STATIC_VARIABLE("all");

	// TODO: Add +[ATTR_THREAD_AFFINITY(MessageReceiver_getThread)] ? Currently it is accessed in group thread as well.
	VARIABLE_ATTR("AI", 		[ATTR_GET_ONLY]); // The AI brain of this garrison

	VARIABLE_ATTR("side", 		[ATTR_PRIVATE]);
	VARIABLE_ATTR("units", 		[ATTR_PRIVATE]);
	VARIABLE_ATTR("groups", 	[ATTR_PRIVATE]);
	VARIABLE_ATTR("spawned", 	[ATTR_PRIVATE]);
	VARIABLE_ATTR("debugName", 	[ATTR_PRIVATE]);
	VARIABLE_ATTR("location", 	[ATTR_PRIVATE]);
	VARIABLE_ATTR("effTotal", 	[ATTR_PRIVATE]); // Efficiency vector of all units
	VARIABLE_ATTR("effMobile", 	[ATTR_PRIVATE]); // Efficiency vector of all units that can move
	VARIABLE_ATTR("timer", 		[ATTR_PRIVATE]); // Timer that will be sending PROCESS messages here
	VARIABLE_ATTR("mutex", 		[ATTR_PRIVATE]); // Mutex used to lock the object
	VARIABLE_ATTR("active",		[ATTR_PRIVATE]); // Set to true after calling activate method

	// ----------------------------------------------------------------------
	// |                 S E T   D E B U G   N A M E                        |
	// ----------------------------------------------------------------------
	METHOD("setDebugName") {
		params [P_THISOBJECT, ["_debugName", "", [""]]];
		T_SETV("debugName", _debugName);
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	/*
	Method: new

	Parameters: _side, _pos

	_side - side of this garrison
	_pos - optional, default position to set to the garrison
	*/
	METHOD("new") {
		params [P_THISOBJECT, P_SIDE("_side"), P_ARRAY("_pos")];

		OOP_INFO_0("NEW GARRISON");

		OOP_INFO_1("%1", _side);

		// Check existance of neccessary global objects
		ASSERT_GLOBAL_OBJECT(gMessageLoopMain);

		T_SETV("units", []);
		T_SETV("groups", []);
		T_SETV("spawned", false);
		T_SETV("side", _side);
		T_SETV("debugName", "");
		//T_SETV("action", "");
		T_SETV("effTotal", +T_EFF_null);
		T_SETV("effMobile", +T_EFF_null);
		T_SETV("location", "");
		T_SETV("active", false);

		// Create AI object
		// Create an AI brain of this garrison and start it
		pr _AI = NEW("AIGarrison", [_thisObject]);
		SETV(_thisObject, "AI", _AI);

		// Set position if it was specified
		if (count _pos > 0) then {
			CALLM1(_AI, "setPos", _pos);
		};

		// Create a timer to call process method
		pr _msg = MESSAGE_NEW();
		MESSAGE_SET_DESTINATION(_msg, _thisObject);
		MESSAGE_SET_TYPE(_msg, GARRISON_MESSAGE_PROCESS);
		pr _args = [_thisObject, 1, _msg, gTimerServiceMain];
		pr _timer = NEW("Timer", _args);
		T_SETV("timer", _timer);

		GETSV("Garrison", "all") pushBack _thisObject;

		// Handle the PROCESS message right now to make the garrison instantly switch to spawned state if required
		//CALLM1(_thisObject, "handleMessage", _msg);
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	/*
	Method: delete

	*/
	METHOD("delete") {
		params [P_THISOBJECT];

		OOP_INFO_0("DELETE GARRISON");
		
		ASSERT_MSG(IS_GARRISON_DESTROYED(_thisObject), "Garrison should be destroyed before it is deleted");
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                          A C T I V A T E                           |
	// ----------------------------------------------------------------------
	/*
	Method: activate

	Start AI
	Registers with commander and global garrison list
	Sets "active" variable to true
	*/
	METHOD("activate") {
		params [P_THISOBJECT];

		// Start AI object
		CALLM(T_GETV("AI"), "start", []); // Let's start the party! \o/

		// Set 'active' flag
		T_SETV("active", true);

		pr _return = CALL_STATIC_METHOD("AICommander", "registerGarrison", [_thisObject]);
		_return
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                           D E S T R O Y                            |
	// ----------------------------------------------------------------------
	/*
	Method: destroy

	This starts the delete process for this garrison. It sets the garrison to 
	destroyed state (isDestroyed returns true, isAlive returns false), removes
	all units and groups, deletes the timer and AI components.
	*/
	METHOD("destroy") {
		params [P_THISOBJECT];
		
		OOP_INFO_0("DESTROY GARRISON");

		__MUTEX_LOCK;

		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			OOP_WARNING_MSG("Garrison %1 is already destroyed", []);
		};

		ASSERT_THREAD(_thisObject);

		// Unregister with the owning commander
		CALL_STATIC_METHOD("AICommander", "unregisterGarrison", [_thisObject]);

		// Detach from location if was attached to it
		T_PRVAR(location);
		if (!IS_NULL_OBJECT(_location)) then {
			CALLM(_location, "postMethodSync", ["unregisterGarrison"]+[[_thisObject]]);
		};

		// Despawn if spawned
		if(T_GETV("spawned")) then {
			CALLM(_thisObject, "despawn", []);
		};

		T_PRVAR(units);
		T_PRVAR(groups);

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

		T_SETV("units", nil);
		T_SETV("groups", nil);


		private _all = GETSV("Garrison", "all");
		_all deleteAt (_all find _thisObject);
		
		
		// Delete our timer
		DELETE(T_GETV("timer"));
		T_SETV("timer", nil);

		// Delete the AI object
		// We delete it instantly because Garrison AI is in the same thread
		DELETE(T_GETV("AI"));
		T_SETV("AI", nil);

		T_SETV("effMobile", []);
		// effTotal will serve as our DESTROYED marker. Set to [] means Garrison is destroyed and should not be used or referenced.
		T_SETV("effTotal", []);
		__MUTEX_UNLOCK;
	} ENDMETHOD;

	/*
	Method: isAlive

	Is this Garrison ready to be used?
	*/
	METHOD("isAlive") {
		params [P_THISOBJECT];
		// No mutex lock because this is expected to be atomic
		!IS_GARRISON_DESTROYED(_thisObject)
		//(T_GETV("effTotal") isEqualTo [])
	} ENDMETHOD;

	/*
	Method: isDestroyed

	Is this Garrison ready to be used?
	*/
	METHOD("isDestroyed") {
		params [P_THISOBJECT];
		// No mutex lock because this is expected to be atomic
	 	IS_GARRISON_DESTROYED(_thisObject)
	} ENDMETHOD;


	METHOD("runLocked") {
		params [P_THISOBJECT, P_OOP_OBJECT("_obj"), P_STRING("_funcName"), P_ARRAY("_args")];
		__MUTEX_LOCK;
		CALLM(_obj, _funcName, _args);
		__MUTEX_UNLOCK;
	} ENDMETHOD;

	/*
	Method: (static) getAll
	Returns all garrisons
	
	Parameters: _side
	
	_side - optional, Side of garrisons to returns. If side is not provided, returns all garrisons.

	Returns: Array with <Garrison> objects
	*/
	STATIC_METHOD("getAll") {
		params ["_thisClass", ["_side", sideEmpty]];
		
		if (_side == sideEmpty) then {
			GETSV("Garrison", "all")
		} else {
			GETSV("Garrison", "all") select {CALLM0(_x, "getSide") == _side}
		};
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
		params [P_THISOBJECT, P_OOP_OBJECT("_location")];

		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
		};

		ASSERT_THREAD(_thisObject);

		T_SETV("location", _location);
		
		pr _AI = T_GETV("AI");
		CALLM1(_AI, "handleLocationChanged", _location);
		
		// Detach from current location if it exists
		pr _currentLoc = T_GETV("location");
		if (_currentLoc != "") then {
			CALLM2(_currentLoc, "postMethodAsync", "unregisterGarrison", [_thisObject]);
		};
		
		// Attach to another location
		if (_location != "") then {
			ASSERT_OBJECT_CLASS(_location, "Location");
			CALLM2(_location, "postMethodAsync", "registerGarrison", [_thisObject]);
		};
		
		T_SETV("location", _location);
		
		__MUTEX_UNLOCK;
		
	} ENDMETHOD;
	
	METHOD("detachFromLocation") {
		params [P_THISOBJECT];

		ASSERT_THREAD(_thisObject);
		
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
		};

		pr _currentLoc = T_GETV("location");
		if (_currentLoc != "") then {
			CALLM2(_currentLoc, "postMethodAsync", "unregisterGarrison", [_thisObject]);
			T_SETV("location", "");
		};
		
		__MUTEX_UNLOCK;
	} ENDMETHOD;

	/*
	Method: setPos
	Sets the position of this garrison. Note that position can be updated later on its own by garrison's actions.

	Parameters: _pos

	_pos - position
	*/
	METHOD("setPos") {
		params [P_THISOBJECT, P_POSITION("_pos")];

		ASSERT_THREAD(_thisObject);

		__MUTEX_LOCK;

		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
		};

		pr _AI = T_GETV("AI");
		CALLM1(_AI, "setPos", _pos);
		
		__MUTEX_UNLOCK;
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
		params [P_THISOBJECT];

		__MUTEX_LOCK;

		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			sideUnknown
		};

		private _return = GET_VAR(_thisObject, "side");
		__MUTEX_UNLOCK;
		_return
	} ENDMETHOD;


	//                     G E T   L O C A T I O N
	/*
	Method: getLocation
	Returns location this garrison is attached to.

	Returns: <Location>
	*/
	METHOD("getLocation") {
		params [P_THISOBJECT];
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			NULL_OBJECT
		};
		private _return = GET_VAR(_thisObject, "location");
		__MUTEX_UNLOCK;
		_return
	} ENDMETHOD;


	//                      G E T   G R O U P S
	/*
	Method: getGroups
	Returns groups of this garrison.

	Returns: Array of <Group> objects.
	*/
	METHOD("getGroups") {
		params [P_THISOBJECT];

		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			[]
		};
		pr _return = +GET_VAR(_thisObject, "groups");
		__MUTEX_UNLOCK;
		_return
	} ENDMETHOD;

	// 						G E T   U N I T S
	/*
	Method: getUnits
	Returns all units of this garrison.

	Returns: Array of <Unit> objects.
	*/
	METHOD("getUnits") {
		params [P_THISOBJECT];
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			[]
		};
		private _return = +T_GETV("units");
		__MUTEX_UNLOCK;
		_return
	} ENDMETHOD;

	// |                         G E T  I N F A N T R Y  U N I T S
	/*
	Method: getInfantryUnits
	Returns all infantry units.

	Returns: Array of units.
	*/
	METHOD("getInfantryUnits") {
		params [P_THISOBJECT];
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			[]
		};
		private _unitList = T_GETV("units");
		private _return = _unitList select {CALLM0(_x, "isInfantry")};
		__MUTEX_UNLOCK;
		_return
	} ENDMETHOD;

	// |                         G E T   V E H I C L E   U N I T S
	/*
	Method: getVehiucleUnits
	Returns all vehicle units.

	Returns: Array of units.
	*/
	METHOD("getVehicleUnits") {
		params [P_THISOBJECT];
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			[]
		};
		private _unitList = T_GETV("units");
		private _return = _unitList select {CALLM0(_x, "isVehicle")};
		__MUTEX_UNLOCK;
		_return
	} ENDMETHOD;

	// |                         G E T   D R O N E   U N I T S
	/*
	Method: getVehicleUnits
	Returns all drone units.

	Returns: Array of units.
	*/
	METHOD("getDroneUnits") {
		params [P_THISOBJECT];
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			[]
		};
		private _unitList = T_GETV("units");
		private _return = _unitList select {CALLM0(_x, "isDrone")};
		__MUTEX_UNLOCK;
		_return
	} ENDMETHOD;

	// 						G E T   A I
	/*
	Method: getAI
	Returns the AI object of this garrison.

	Returns: Array of <Unit> objects.
	*/
	METHOD("getAI") {
		params [P_THISOBJECT];
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			NULL_OBJECT
		};
		private _AI = T_GETV("AI");
		__MUTEX_UNLOCK;
		_AI
	} ENDMETHOD;
	
	// 						S E T   P O S
	// Sets the position, because it is stored in the world state
	METHOD("setPos") {
		params [P_THISOBJECT, P_POSITION("_pos")];
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
		};
		pr _AI = T_GETV("AI");
		CALLM(_AI, "setPos", [_pos]);
		__MUTEX_UNLOCK;
	} ENDMETHOD;

	// 						G E T   P O S
	/*
	Method: getPos
	Returns the position of the garrison. It's the same as position world state property.

	Returns: Array
	*/
	METHOD("getPos") {
		params [P_THISOBJECT];
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			[]
		};
		pr _AI = T_GETV("AI");
		private _return = CALLM0(_AI, "getPos");
		__MUTEX_UNLOCK;
		_return
	} ENDMETHOD;
	
	//						I S   E M P T Y
	/*
	Method: isEmpty
	Returns true if garrison is empty (has no units)

	Returns: Bool
	*/
	METHOD("isEmpty") {
		params [P_THISOBJECT];
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			true
		};
		private _return = (count T_GETV("units")) == 0;
		__MUTEX_UNLOCK;
		_return
	} ENDMETHOD;

	//						I S   S P A W N E D
	/*
	Method: isSpawned
	Returns true if garrison is spawned

	Returns: Bool
	*/
	METHOD("isSpawned") {
		params [P_THISOBJECT];
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			false
		};
		private _return = T_GETV("spawned");
		__MUTEX_UNLOCK;
		_return
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
		params [P_THISOBJECT, ["_types", 0, [0, []]]];

		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			[]
		};

		if (_types isEqualType 0) then {_types = [_types]};

		pr _groups = GETV(_thisObject, "groups");
		pr _return = [];
		{
			if (CALLM0(_x, "getType") in _types) then {
				_return pushBack _x;
			};
		} forEach _groups;
		
		__MUTEX_UNLOCK;
		
		_return
	} ENDMETHOD;

	/*
	Method: countAllUnits
	Returns: total number of units in this garrison.
	*/
	METHOD("countAllUnits") {
		params [P_THISOBJECT];
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			0
		};
		private _return = count T_GETV("units");
		__MUTEX_UNLOCK;
		_return
	} ENDMETHOD;

	/*
	Method: getTransportCapacity
	Count number of passenger seats available in all vehicles of the categories specified.
	Parameters: _vehicleCategories

	_vehicleCategories - Array of vehicle categories, defaults to T_VEH_ground_infantry_cargo
	Returns: number of seats available.
	*/
	METHOD("getTransportCapacity") {
		params [P_THISOBJECT, P_ARRAY("_vehicleCategories")];
		
		__MUTEX_LOCK;
		
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			0
		};

		if(count _vehicleCategories == 0) then {
			_vehicleCategories = T_VEH_ground_infantry_cargo;
		};

		// Get available seats for transportation for any matching vehicles
		private _transportCapacityPerUnit = T_CALLM("getUnits", []) apply {
			CALLM0(_x, "getMainData") params ["_catID", "_subcatID"];
			if(_catID == T_VEH and {_subcatID in _vehicleCategories}) then {
				CALLSM1("Unit", "getCargoInfantryCapacity", [_x])
			} else {
				0
			};
		};
		// Sum the available seats.
		private _transportCapacity = 0;
		{
			_transportCapacity = _transportCapacity + _x;
		} foreach _transportCapacityPerUnit;
		__MUTEX_UNLOCK;

		_transportCapacity
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
		params[P_THISOBJECT, P_OOP_OBJECT("_unit")];
		ASSERT_OBJECT_CLASS(_unit, "Unit");

		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			nil
		};
	
		OOP_INFO_1("ADD UNIT: %1", _unit);

		ASSERT_THREAD(_thisObject);

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

		// Spawn or despawn the unit if needed
		if (T_GETV("spawned")) then {
			pr _unitIsSpawned = CALLM0(_unit, "isSpawned");
			if (!_unitIsSpawned) then {
				pr _loc = T_GETV("location");
				if (_loc == "") then {
					pr _pos = CALLM0(_thisObject, "getPos");
					pr _posAndDir = CALLSM2("Location", "findSafeSpawnPos", _className, _pos);
					CALL_METHOD(_unit, "spawn", _posAndDir);
				} else {
					pr _unitData = CALL_METHOD(_unit, "getMainData", []);
					pr _args = _unitData + [_groupType]; // ["_catID", 0, [0]], ["_subcatID", 0, [0]], ["_className", "", [""]], ["_groupType", "", [""]]
					pr _posAndDir = CALL_METHOD(_loc, "getSpawnPos", _args);
					CALL_METHOD(_unit, "spawn", _posAndDir);
				};
			};
		} else {
			// If this garrison is not spawned, despawn the group as well
			pr _unitIsSpawned = CALLM0(_unit, "isSpawned");
			if (_unitIsSpawned) then {
				CALLM0(_unit, "despawn");
			};
		};

		// Notify AI object
		pr _AI = T_GETV("AI");
		if (_AI != "") then {
			CALLM1(_AI, "handleUnitsAdded", [_unit]);
			CALLM0(_AI, "updateComposition");
		};
		
		CALLM1(_unit, "setGarrison", _thisObject);
		
		// Add to the efficiency vector
		CALLM0(_unit, "getMainData") params ["_catID", "_subcatID"];
		CALLM2(_thisObject, "addEfficiency", _catID, _subcatID);

		__MUTEX_UNLOCK;

		nil
	} ENDMETHOD;

	METHOD("addUnits") {
		params[P_THISOBJECT, P_ARRAY("_units")];
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			nil
		};
		{
			T_CALLM("addUnit", [_x]);
		} forEach _units;
		__MUTEX_UNLOCK;
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
		params[P_THISOBJECT, P_OOP_OBJECT("_unit")];
		ASSERT_OBJECT_CLASS(_unit, "Unit");
		
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			nil
		};
		
		OOP_INFO_1("REMOVE UNIT: %1", _unit);

		ASSERT_THREAD(_thisObject);
		
		// Notify AI of the garrison about unit removal
		pr _AI = T_GETV("AI");
		if (_AI != "") then {
			CALLM1(_AI, "handleUnitsRemoved", [_unit]);
		};
		
		private _units = GET_VAR(_thisObject, "units");
		_units deleteAt (_units find _unit);

		// Set the garrison of this unit
		CALLM1(_unit, "setGarrison", "");
		
		// Notify the AI object after the unit is removed
		if(_AI != "") then {
			CALLM0(_AI, "updateComposition");
		};

		// Substract from the efficiency vector
		CALLM0(_unit, "getMainData") params ["_catID", "_subcatID"];
		CALLM2(_thisObject, "substractEfficiency", _catID, _subcatID);

		__MUTEX_UNLOCK;

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
		params[P_THISOBJECT, P_OOP_OBJECT("_group")];
		ASSERT_OBJECT_CLASS(_group, "Group");

		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			nil
		};

		OOP_INFO_2("ADD GROUP: %1, group units: %2", _group, CALLM0(_group, "getUnits"));

		ASSERT_THREAD(_thisObject);
		
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
			
			// Add to the efficiency vector
			CALLM0(_x, "getMainData") params ["_catID", "_subcatID"];
			CALLM2(_thisObject, "addEfficiency", _catID, _subcatID);
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
					pr _pos = CALLM0(_thisObject, "getPos");
					CALLM1(_group, "spawnAtPos", _pos);
				} else {
					CALLM1(_group, "spawnAtLocation", _loc);
				};
			};
		} else {
			// If this garrison is not spawned, despawn the group as well
			pr _groupIsSpawned = CALLM0(_group, "isSpawned");
			if (_groupIsSpawned) then {
				CALLM0(_group, "despawn");
			};
		};

		// Notify the AI of the garrison
		// Call the handleGroupsAdded directly since it's in the same thread
		pr _AI = T_GETV("AI");
		if (_AI != "") then {
			CALLM1(_AI, "handleGroupsAdded", [[_group]]);
			CALLM0(_AI, "updateComposition");
		};

		__MUTEX_UNLOCK;

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
		params[P_THISOBJECT, P_OOP_OBJECT("_group")];
		ASSERT_OBJECT_CLASS(_group, "Group");

		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			nil
		};

		OOP_INFO_2("REMOVE GROUP: %1, group units: %2", _group, CALLM0(_group, "getUnits"));

		ASSERT_THREAD(_thisObject);
		
		// Notify AI object if the garrison is spawned
		pr _AI = T_GETV("AI");
		if (_AI != "") then {
			CALLM1(_AI, "handleGroupsRemoved", [_group]); // We call it synchronously because Garrison AI is in the same thread.
		};

		// Remove this group and all its units from this garrison
		pr _groupUnits = CALL_METHOD(_group, "getUnits", []);
		pr _units = GET_VAR(_thisObject, "units");
		{
			_units deleteAt (_units find _x);
			
			// Substract from the efficiency vector
			CALLM0(_x, "getMainData") params ["_catID", "_subcatID"];
			CALLM2(_thisObject, "substractEfficiency", _catID, _subcatID);
				
		} forEach _groupUnits;
		pr _groups = GET_VAR(_thisObject, "groups");
		_groups deleteAt (_groups find _group);
		
		// If garrison is spawned, notify the AI object. updateComposition must be called after the group and its units are already removed from the garrison.
		if (_AI != "") then {
			CALLM0(_AI, "updateComposition");
		};

		CALLM1(_group, "setGarrison", "");

		__MUTEX_UNLOCK;

		nil
	} ENDMETHOD;

	/*
	Method: deleteEmptyGroups
	DeletesEmptyGroups in this garrison
	
	Returns: nil
	*/

	METHOD("deleteEmptyGroups") {
		params [P_THISOBJECT];

		ASSERT_THREAD(_thisObject);

		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
		};

		pr _groups = T_GETV("groups");
		pr _emptyGroups = _groups select {CALLM0(_x, "isEmpty")};
		{
			DELETE(_x);
		} forEach _emptyGroups;

		__MUTEX_UNLOCK;
	} ENDMETHOD;

	/*
	Method: addGarrison
	Moves all units and groups from another garrison to this one.
	
	Parameters: _garrison, _delete
	
	_garrison - <Garrison> object
	_delete - Bool, optional, deletes the _garrison, default: false. Deletion doesn't happen immediately.
	
	Returns: nil
	*/
	
	METHOD("addGarrison") {
		params[P_THISOBJECT, P_OOP_OBJECT("_garrison"), P_BOOL("_delete")];
		ASSERT_OBJECT_CLASS(_garrison, "Garrison");

		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			nil
		};

		ASSERT_THREAD(_thisObject);

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
			// TODO: we need to work out how to do this properly.
			// DELETE(_garrison);
			// HACK: Just unregister with AICommander for now so the model gets cleaned up
			CALLM(_garrison, "destroy", []);
		};

		__MUTEX_UNLOCK;
		
		nil
	} ENDMETHOD;
	
	/*
	Method: addUnitsAndGroups
	Moves all specified units and groups from another garrison to this one.
	Before moving, it ensures that all provided units are still in this garrison.
	New groups for infantry units and vehicle units are created.
	ALl provided units and groups must originate in one garrison!
	
	Parameters: _garrison, _units, _groups
	
	_garSrc - source <Garrison>
	_units - array of <Unit> objects
	_groupsAndUnits - array of [_group, _units]
	
	Returns: Bool, true if move was performed properly
	*/
	METHOD("addUnitsAndGroups") {
		params [P_THISOBJECT, P_OOP_OBJECT("_garSrc"), P_ARRAY("_units"), P_ARRAY("_groupsAndUnits")];
		ASSERT_OBJECT_CLASS(_garSrc, "Garrison");

		ASSERT_THREAD(_thisObject);

		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
		};

		// Check if all units are still in the same garrison
		pr _index = _units findIf {CALLM0(_x, "getGarrison") != _garSrc};
		if (_index != NOT_FOUND) exitWith { 
			OOP_WARNING_0("Units being added must all be in the same source garrison");
			__MUTEX_UNLOCK;
			false 
		};
		
		// Check if all groups and their units are still in the same garrison
		pr _index = _groupsAndUnits findIf {
			_x params ["_group", "_groupUnits"];;
			if (CALLM0(_group, "getGarrison") != _garSrc) then {
				true;
			} else {
				pr _index1 = _groupUnits findIf {CALLM0(_x, "getGarrison") != _garSrc};
				if (_index1 != NOT_FOUND) then {
					true
				} else{
					false
				};
			};
		};
		if (_index != NOT_FOUND) exitWith { 
			OOP_WARNING_0("Groups being added must all be in the same source garrison");
			__MUTEX_UNLOCK;
			false
		};
		
		// If we are here then the composition is ok
		// Move units first
		pr _newInfGroups = [];
		pr _newVehGroup = "";
		pr _srcIsSpawned = T_GETV("spawned");
		pr _side = T_GETV("side");
		{
			if (CALLM0(_x, "isInfantry")) then {
				// Move the unit to the new group
				// If there is no inf group yet, create one
				// Also create a new group if the amount of troops is too big
				pr _createNewGroup = if (count _newInfGroups == 0) then {
					true
				} else {
					pr _lastGroup = _newInfGroups select (count _newInfGroups - 1);
					if (count CALLM0(_lastGroup, "getUnits") > 6) then {
						true	
					} else { false };
				};
				// Create a new group if needed or pick an existing one
				pr _group = if (_createNewGroup) then {
					pr _args = [_side, GROUP_TYPE_IDLE];
					_newGroup = NEW("Group", _args);
					//if (_srcIsSpawned) then { // If the garrison is currently spawned, set proper state to the new group
					//	CALLM0(_newGroup, "spawn");
					//};
					CALLM1(_garSrc, "addGroup", _newGroup);
					_newInfGroups pushBack _newGroup;
					_newGroup
				} else {
					_newInfGroups select (count _newInfGroups - 1)
				};
				// We have a group now, move the unit here
				CALLM1(_group, "addUnit", _x);
			} else {
				// All vehicle groups go into one group
				if (_newVehGroup == "") then {
					pr _args = [_side, GROUP_TYPE_VEH_NON_STATIC]; // todo We assume we aren't moving static vehicles anywhere right now
					_newVehGroup = NEW("Group", _args);
					//if (_srcIsSpawned) then { // If the garrison is currently spawned, set proper state to the new group
					//	CALLM0(_newVehGroup, "spawn");
					//};
					CALLM1(_garSrc, "addGroup", _newVehGroup);
				};
				// Move the vehicle into the new group
				CALLM1(_newVehGroup, "addUnit", _x);
			};
		} forEach _units;
		
		// Now move all groups into the new garrison
		{
			CALLM1(_thisObject, "addGroup", _x);
		} forEach _newInfGroups;
		
		if (_newVehGroup != "") then {
			CALLM1(_thisObject, "addGroup", _newVehGroup);
		};
		
		{
			pr _group = _x select 0;
			CALLM1(_thisObject, "addGroup", _group);
		} forEach _groupsAndUnits;
		
		__MUTEX_UNLOCK;

		true
		
	} ENDMETHOD;
	
	
	/*
	Method: getRequiredCrew
	Returns amount of needed drivers and turret operators for all vehicles in this garrison.

	Returns: [_nDrivers, _nTurrets]
	*/

	METHOD("getRequiredCrew") {
		params [P_THISOBJECT];

		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
		};

		pr _units = T_GETV("units");
		private _return = CALLSM1("Unit", "getRequiredCrew", _units);

		__MUTEX_UNLOCK;

		_return
	} ENDMETHOD;
	
	/*
	Method: mergeVehicleGroups
	Merges or splits vehicle group(s)
	
	Parameters: _merge
	
	_merge - Bool, true to merge, false to split
	
	Returns: nil
	*/
	
	METHOD("mergeVehicleGroups") {
		params [P_THISOBJECT, P_BOOL("_merge")];

		ASSERT_THREAD(_thisObject);
		
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
		};

		if (_merge) then {
			// Find all vehicle groups
			pr _vehGroups = CALLM1(_thisObject, "findGroupsByType", GROUP_TYPE_VEH_NON_STATIC);
			pr _destGroup = _vehGroups select 0;
			
			// If there are no vehicle groups, create one right now
			if (isNil "_destGroup") then {
				pr _args = [CALLM0(_thisObject, "getSide"), GROUP_TYPE_VEH_NON_STATIC];
				_destGroup = NEW("Group", _args);
				CALLM0(_destGroup, "spawnAtLocation");
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
						CALLM0(_newGroup, "spawnAtLocation");
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

		__MUTEX_UNLOCK;
		
		nil
	} ENDMETHOD;
	
	/*
	Method: addEfficiency
	Adds values to efficiency vector
	
	Private use!
	
	Returns: nil
	*/
	METHOD("addEfficiency") {
		params [P_THISOBJECT, "_catID", "_subCatID"];
		
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
		};

		pr _effAdd = T_efficiency select _catID select _subcatID;
		
		pr _effTotal = T_GETV("effTotal");
		_effTotal = EFF_ADD(_effTotal, _effAdd);
		T_SETV("effTotal", _effTotal);
		 
		// If the added unit is not static
		if (! ([_catID, _subcatID] in T_static)) then {
			pr _effMobile = T_GETV("effMobile");
			_effMobile = EFF_ADD(_effMobile, _effAdd);
			T_SETV("effMobile", _effMobile);
		};

		__MUTEX_UNLOCK;
	} ENDMETHOD;	
	
	/*
	Method: subEfficiency
	Substracts values to efficiency vector
	
	Private use!
	
	Returns: nil
	*/
	METHOD("substractEfficiency") {
		params [P_THISOBJECT, "_catID", "_subCatID"];
		
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
		};

		pr _effSub = T_efficiency select _catID select _subcatID;
		
		pr _effTotal = T_GETV("effTotal"); 
		_effTotal = EFF_DIFF(_effTotal, _effSub);
		T_SETV("effTotal", _effTotal);
		
		// If the removed unit is not static
		if (! ([_catID, _subcatID] in T_static)) then {
			pr _effMobile = T_GETV("effMobile");
			_effMobile = EFF_DIFF(_effMobile, _effSub);
			T_SETV("effMobile", _effMobile);
		};

		__MUTEX_UNLOCK;
	} ENDMETHOD;
	
	/*
	Method: getEfficiencyMobile
	Returns efficiency of all mobile units
	
	Returns: Efficiency vector
	*/
	
	METHOD("getEfficiencyMobile") {
		params [P_THISOBJECT];
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			+T_EFF_null
		};

		private _return = +T_GETV("effMobile");
		__MUTEX_UNLOCK;
		_return
	} ENDMETHOD;
	
	/*
	Method: getEfficiencyTotal
	Returns efficiency of all mobile units
	
	Returns: Efficiency vector
	*/
	
	METHOD("getEfficiencyTotal") {
		params [P_THISOBJECT];
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			+T_EFF_null
		};
		pr _return = +T_GETV("effTotal");
		__MUTEX_UNLOCK;
		_return
	} ENDMETHOD;
	
	/*
	Method: spawnAndDetach
	Spawnes the garrison and detaches it from its current location
	
	Returns: nil
	*/
	METHOD("spawnAndDetach") {
		params [P_THISOBJECT];

		ASSERT_THREAD(_thisObject);

		__MUTEX_LOCK;

		CALLM0(_thisObject, "spawn");
		CALLM1(_thisObject, "setLocation", "");

		__MUTEX_UNLOCK;

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
		"GoalGarrisonRebalanceVehicleGroups",
		"GoalGarrisonAttackAssignedTargets"]
	} ENDMETHOD;

	METHOD("getPossibleActions") {
		["ActionGarrisonDefendPassive",
		"ActionGarrisonLoadCargo",
		"ActionGarrisonMountCrew",
		"ActionGarrisonMountInfantry",
		"ActionGarrisonMountCrewInfantry",
		"ActionGarrisonMoveDismounted",
		//"ActionGarrisonMoveMountedToPosition",
		//"ActionGarrisonMoveMountedToLocation",
		"ActionGarrisonMoveCombined",
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
		params [P_THISOBJECT, P_OOP_OBJECT("_unit")];
		ASSERT_OBJECT_CLASS(_unit, "Unit");

		OOP_INFO_1("HANDLE UNIT KILLED: %1", _unit);

		ASSERT_THREAD(_thisObject);

		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			+T_EFF_null
		};

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

		__MUTEX_UNLOCK;
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
		params [P_THISOBJECT, P_OOP_OBJECT("_unitVeh"), P_OOP_OBJECT("_unitInf")];
		ASSERT_OBJECT_CLASS(_unitVeh, "Unit");
		ASSERT_OBJECT_CLASS(_unitInf, "Unit");

		OOP_INFO_2("HANDLE UNIT GET IN VEHICLE: %1, %2", _unitVeh, _unitInf);

		ASSERT_THREAD(_thisObject);

		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			+T_EFF_null
		};

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
		__MUTEX_UNLOCK;
	} ENDMETHOD;

	/*
	Method: findUnits
	Returns an array of units with specified category and subcategory

	Parameters: _query

	_query - array of [_catID, _subcatID].
	_subcatID can be -1 if you don't care about a subcategory match.

	Returns: Array of units <Unit> class
	*/
	METHOD("findUnits") {
		params [P_THISOBJECT, P_ARRAY("_query")];

		__MUTEX_LOCK;

		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
		};

		pr _return = [];
		pr _units = GETV(_thisObject, "units");
		{ // for each _query
			_x params ["_catID", "_subcatID"];
			{ // for each _units
				pr _unit = _x;
				pr _mainData = CALLM(_unit, "getMainData", []);
				_mainData params ["_catIDx", "_subcatIDx"];
				if (_catIDx == _catID && (_subcatIDx == _subcatID || _subcatID == -1)) then { _return pushBack _unit; };
			} forEach _units;
		} forEach _query;

		__MUTEX_UNLOCK;
		_return		
	} ENDMETHOD;
	
	/*
	Method: countUnits
	Counts amount of units with specified category and subcategory

	Parameters: _query

	_query - array of [_catID, _subcatID].
	_subcatID can be -1 if you don't care about a subcategory match.

	Returns: Array of units <Unit> class
	*/
	// Todo: optimize this
	METHOD("countUnits") {
		params [P_THISOBJECT, P_ARRAY("_query")];
		// findUnits will do asserts and locks for us
		pr _units = CALLM1(_thisObject, "findUnits", _query);
		count _units	
	} ENDMETHOD;
	
	// ======================================= FILES ==============================================

	// Handles incoming messages. Since it's a MessageReceiverEx, we must overwrite handleMessageEx
	METHOD_FILE("handleMessageEx", "Garrison\handleMessageEx.sqf");

	// Spawns the whole garrison
	METHOD_FILE("spawn", "Garrison\spawn.sqf");

	// Despawns the whole garrison
	METHOD_FILE("despawn", "Garrison\despawn.sqf");

	// Handle PROCESS message
	METHOD_FILE("process", "Garrison\process.sqf");

	// Static helpers

	
	METHOD("createAddInfGroup") {
		params [P_THISOBJECT, "_side", "_subcatID", ["_type", GROUP_TYPE_IDLE]];
		// Create an empty group
		private _newGroup = NEW("Group", [_side ARG _type]);
		// Create units from template
		private _count = CALL_METHOD(_newGroup, "createUnitsFromTemplate", [GET_TEMPLATE(_side) ARG _subcatID]);
		T_CALLM("addGroup", [_newGroup]);
		[_newGroup, _count]
	} ENDMETHOD;
	
	METHOD("createAddVehGroup") {
		params [P_THISOBJECT, "_side", "_catID", "_subcatID", "_classID"];
		// Create an empty group
		private _newGroup = NEW("Group", [_side ARG GROUP_TYPE_VEH_NON_STATIC]);
		private _template = GET_TEMPLATE(_side);
		private _newUnit = NEW("Unit", [_template ARG _catID ARG _subcatID ARG -1 ARG _newGroup]);
		// Create crew for the vehicle
		CALL_METHOD(_newUnit, "createDefaultCrew", [_template]);
		T_CALLM("addGroup", [_newGroup]);
		_newGroup
	} ENDMETHOD;

ENDCLASS;

SETSV("Garrison", "all", []);