#include "common.hpp"

/*
Class: Garrison
Garrison is an object which holds units and groups and handles their lifecycle (spawning, despawning, destruction).
Garrison is much like a group, it has an <AIGarrison>. But it can have multiple groups of different types.

Author: Sparker 12.07.2018


*/

#define pr private

#define WARN_GARRISON_DESTROYED OOP_WARNING_MSG("Attempted to call function on destroyed garrison %1", [_thisObject])

#define MESSAGE_LOOP gMessageLoopMain

CLASS("Garrison", "MessageReceiverEx");

	STATIC_VARIABLE("all");

	VARIABLE_ATTR("templateName", [ATTR_PRIVATE]);

	// TODO: Add +[ATTR_THREAD_AFFINITY(MessageReceiver_getThread)] ? Currently it is accessed in group thread as well.
	VARIABLE_ATTR("AI", 		[ATTR_GET_ONLY]); // The AI brain of this garrison

	VARIABLE_ATTR("side", 		[ATTR_PRIVATE]);
	VARIABLE_ATTR("units", 		[ATTR_PRIVATE]);
	VARIABLE_ATTR("groups", 	[ATTR_PRIVATE]);
	VARIABLE_ATTR("spawned", 	[ATTR_PRIVATE]);
	VARIABLE_ATTR("name", 		[ATTR_PRIVATE]);
	VARIABLE_ATTR("location", 	[ATTR_PRIVATE]);
	VARIABLE_ATTR("effTotal", 	[ATTR_PRIVATE]); // Efficiency vector of all units
	VARIABLE_ATTR("effMobile", 	[ATTR_PRIVATE]); // Efficiency vector of all units that can move
	VARIABLE_ATTR("timer", 		[ATTR_PRIVATE]); // Timer that will be sending PROCESS messages here
	VARIABLE_ATTR("mutex", 		[ATTR_PRIVATE]); // Mutex used to lock the object
	VARIABLE_ATTR("active",		[ATTR_PRIVATE]); // Set to true after calling activate method
	VARIABLE_ATTR("faction",	[ATTR_PRIVATE]); // Template used for loadouts of the garrison

	VARIABLE_ATTR("buildResources", [ATTR_PRIVATE]);

	// Counters of subcategories
	VARIABLE_ATTR("countInf",	[ATTR_PRIVATE]);
	VARIABLE_ATTR("countVeh",	[ATTR_PRIVATE]);
	VARIABLE_ATTR("countDrone",	[ATTR_PRIVATE]);
	VARIABLE_ATTR("countCargo", [ATTR_PRIVATE]);

	// Array with composition: each element at [_cat][_subcat] index is an array of nubmers 
	// associated with unit's class names, converted from class names with t_fnc_classNameToNubmer
	VARIABLE_ATTR("composition",[ATTR_PRIVATE]);

	VARIABLE_ATTR("intelItems",	[ATTR_PRIVATE]); // Array of intel items player can discover from this garrison

	// Flag which is reset at each process call
	// It is set by various functions changing state of this garrison
	// We use it to delay a large amount of big computations when many changes happen rapidly,
	// which would otherwise cause a lot of computations on each change
	VARIABLE_ATTR("outdated", [ATTR_PRIVATE]);

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
		params [P_THISOBJECT, P_SIDE("_side"), P_ARRAY("_pos"), P_STRING("_faction"), P_STRING("_templateName")];

		OOP_INFO_1("NEW GARRISON: %1", _this);

		// Take our own ref that we will release in "destroy" function. This makes sure that delete never pre-empts destroy (assuming ref counting is done properly by other classes)
		REF(_thisObject);

		// Check existance of neccessary global objects
		ASSERT_GLOBAL_OBJECT(MESSAGE_LOOP);
		ASSERT_GLOBAL_OBJECT(gGarrisonServer);
		//ASSERT_GLOBAL_OBJECT(gGarrisonAbandonedVehicles);
		ASSERT_GLOBAL_OBJECT(gTimerServiceMain);
		ASSERT_GLOBAL_OBJECT(gMessageLoopMainManager);
		

		T_SETV("units", []);
		T_SETV("groups", []);
		T_SETV("spawned", false);
		T_SETV("side", _side);
		T_SETV("name", "");
		//T_SETV("action", "");
		T_SETV("effTotal", +T_EFF_null);
		T_SETV("effMobile", +T_EFF_null);
		T_SETV("countInf", 0);
		T_SETV("countVeh", 0);
		T_SETV("countDrone", 0);
		T_SETV("countCargo", 0);
		T_SETV("location", "");
		T_SETV("active", false);
		T_SETV("faction", _faction);
		T_SETV("intelItems", []);
		T_SETV("buildResources", -1);
		T_SETV("outdated", true);
		pr _mutex = MUTEX_RECURSIVE_NEW();
		T_SETV("mutex", _mutex);

		// Ensure some template
		if (_templateName == "") then {
			_templateName = "tDefault";
			OOP_WARNING_1("Garrison without template name was created: %1", _this);
		};
		T_SETV("templateName", _templateName);

		// Set value of composition array
		pr _comp = [];
		{
			pr _tempArray = [];
			_tempArray resize _x;
			_comp pushBack (_tempArray apply {[]});
		} forEach [T_INF_SIZE, T_VEH_SIZE, T_DRONE_SIZE, T_CARGO_SIZE];
		T_SETV("composition", _comp);

		// Create AI object
		// Create an AI brain of this garrison and start it
		pr _AI = NEW("AIGarrison", [_thisObject]);
		SETV(_thisObject, "AI", _AI);

		// Set position if it was specified
		if (count _pos > 0) then {
			T_CALLM2("postMethodAsync", "setPos", [_pos]);
		};

		// Create a timer to call process method
		pr _msg = MESSAGE_NEW();
		MESSAGE_SET_DESTINATION(_msg, _thisObject);
		MESSAGE_SET_TYPE(_msg, GARRISON_MESSAGE_PROCESS);
		pr _args = [_thisObject, 1, _msg, gTimerServiceMain];
		pr _timer = NEW("Timer", _args);
		T_SETV("timer", _timer);

		/*
		T_SETV("timer", "");
		CALLM(MESSAGE_LOOP, "addProcessCategoryObject", ["Garrison" ARG _thisObject]);
		*/

		GETSV("Garrison", "all") pushBack _thisObject;
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

	Returns: GarrisonModel
	*/
	METHOD("activate") {
		params [P_THISOBJECT];

		// Start AI object
		CALLM(T_GETV("AI"), "start", ["AIGarrisonDespawned"]); // Let's start the party! \o/

		// Set 'active' flag
		T_SETV("active", true);

		// Notify GarrisonServer
		CALLM1(gGarrisonServer, "onGarrisonCreated", _thisObject);

		pr _return = CALL_STATIC_METHOD("AICommander", "registerGarrison", [_thisObject]);
		_return
	} ENDMETHOD;

	/*
	Method: activateOutOfThread

	Same as activate, for calling outside the commander thread.

	Returns: nil
	*/
	METHOD("activateOutOfThread") {
		params [P_THISOBJECT];

		// Start AI object
		CALLM(T_GETV("AI"), "start", ["AIGarrisonDespawned"]); // Let's start the party! \o/

		// Set 'active' flag
		T_SETV("active", true);

		T_SETV("outdated", true);

		CALL_STATIC_METHOD("AICommander", "registerGarrisonOutOfThread", [_thisObject]);
		nil
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
		params [P_THISOBJECT, P_BOOL_DEFAULT_TRUE("_unregisterFromCmdr")];
		
		OOP_INFO_0("DESTROY GARRISON");

		__MUTEX_LOCK;

		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {

			__MUTEX_UNLOCK;
			OOP_WARNING_MSG("Garrison is already destroyed", []);
		};

		ASSERT_THREAD(_thisObject);

		// Detach from location if was attached to it
		T_PRVAR(location);
		if (!IS_NULL_OBJECT(_location)) then {
			CALLM1(_location,"unregisterGarrison", _thisObject);
		};

		// Despawn if spawned
		if(T_GETV("spawned")) then {
			__MUTEX_UNLOCK;
			CALLM(_thisObject, "despawn", []);
			__MUTEX_LOCK;
		};

		T_PRVAR(units);
		T_PRVAR(groups);

		if (count _units != 0) then {
			OOP_ERROR_1("Deleting garrison which has units: %1", _units);
		};
		
		if (count _groups != 0) then {
			OOP_ERROR_1("Deleting garrison which has groups: %1", _groups);
		};
		
		// Despawn method of gorups and units might need to lock this garrison object
		__MUTEX_UNLOCK;
		{
			DELETE(_x);
		} forEach _units;
		
		{
			DELETE(_x);
		} forEach _groups;
		__MUTEX_LOCK;

		T_SETV("units", nil);
		T_SETV("groups", nil);

		private _all = GETSV("Garrison", "all");
		_all deleteAt (_all find _thisObject);
		
		// Delete our timer
		pr _timer = T_GETV("timer");
		if (_timer != "") then {
			DELETE(T_GETV("timer"));
			T_SETV("timer", nil);
		};

		// Delete the AI object
		// We delete it instantly because Garrison AI is in the same thread
		DELETE(T_GETV("AI"));
		T_SETV("AI", nil);

		T_SETV("effMobile", []);
		// effTotal will serve as our DESTROYED marker. Set to [] means Garrison is destroyed and should not be used or referenced.
		T_SETV("effTotal", []);

		if(_unregisterFromCmdr) then {
			// Unregister with the owning commander, do it last because it will cause an unref
			CALL_STATIC_METHOD("AICommander", "unregisterGarrison", [_thisObject]);
		};

		// Notify GarrisonServer
		CALLM1(gGarrisonServer, "onGarrisonDestroyed", _thisObject);

		__MUTEX_UNLOCK;

		// Release our own ref. This might call delete if all other holders already released their refs.
		UNREF(_thisObject);
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
	Method: (static) getAllActive
	Returns all garrisons
	
	Parameters: _sidesInclude, _sidesExclude
	
	_sidesInclude - optional, Sides of garrisons to include. If _sidesInclude is not provided, include all garrisons.
	_sidesExclude - optional, Sides of garrisons to exclude. If _sidesExclude is not provided, no garrisons are excluded.

	Returns: Array with <Garrison> objects
	*/
	STATIC_METHOD("getAllActive") {
		params [P_THISCLASS, P_ARRAY("_sidesInclude"), P_ARRAY("_sidesExclude")];
		
		if (count _sidesInclude == 0 and count _sidesExclude == 0) then {
			GETSV("Garrison", "all") select { GETV(_x, "active") };
		} else {
			GETSV("Garrison", "all") select { 
				GETV(_x, "active") and 
				{count _sidesInclude == 0 or {CALLM0(_x, "getSide") in _sidesInclude}}
				and {count _sidesExclude == 0 or {!(CALLM0(_x, "getSide") in _sidesExclude)}}
			}
		};
	} ENDMETHOD;

	/*
	Method: (static) getAllNotEmpty
	Returns all active non empty garrisons
	
	Parameters: _sidesInclude, _sidesExclude
	
	_sidesInclude - optional, Sides of garrisons to include. If _sidesInclude is not provided, include all garrisons.
	_sidesExclude - optional, Sides of garrisons to exclude. If _sidesExclude is not provided, no garrisons are excluded.

	Returns: Array with <Garrison> objects
	*/
	STATIC_METHOD("getAllNotEmpty") {
		params [P_THISCLASS, P_ARRAY("_sidesInclude"), P_ARRAY("_sidesExclude")];
		
		if (count _sidesInclude == 0 and count _sidesExclude == 0) then {
			GETSV("Garrison", "all") select { 
				GETV(_x, "active") and {!CALLM(_x, "isEmpty", [])} 
			}
		} else {
			GETSV("Garrison", "all") select { 
				GETV(_x, "active") and {!CALLM(_x, "isEmpty", [])} and 
				{count _sidesInclude == 0 or {CALLM0(_x, "getSide") in _sidesInclude}} and 
				{count _sidesExclude == 0 or {!(CALLM0(_x, "getSide") in _sidesExclude)}}
			}
		};
	} ENDMETHOD;

	/*
	Method: (static) getAll

	Returns absolutely all garrison objects
	*/
	STATIC_METHOD("getAll") {
		params [P_THISCLASS];
		GETSV("Garrison", "all")
	} ENDMETHOD;

	/*
	Method: getMessageLoop
	See <MessageReceiver.getMessageLoop>

	Returns: <MessageLoop>
	*/
	// Returns the message loop this object is attached to
	METHOD("getMessageLoop") {
		MESSAGE_LOOP
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                           P R O C E S S                            |
	// ----------------------------------------------------------------------
	METHOD("process") {
		params [P_THISOBJECT];

		//OOP_INFO_0("PROCESS");

		// Check spawn state if active
		if (T_GETV("active")) then { 
			T_CALLM("updateSpawnState", []);

			//OOP_INFO_0("  ACTIVE");

			// If we are empty except for vehicles and we are not at a location then we must abandon them
			if((T_GETV("side") != CIVILIAN) and {T_GETV("location") == ""} and {T_CALLM("isOnlyEmptyVehicles", [])}) then {
				OOP_INFO_MSG("This garrison only has vehicles left, abandoning them", []);
				// Move the units to the abandoned vehicle garrison
				CALLM(gGarrisonAbandonedVehicles, "addGarrison", [_thisObject]);
			};

			pr _loc = T_GETV("location");
			// Players might be messing with inventories, so we must update our amount of build resources more often
			pr _locHasPlayers = (_loc != "" && { CALLM0(_loc, "hasPlayers") } );
			OOP_INFO_1("  hasPlayers: %1", _locHasPlayers);
			if (T_GETV("outdated") || _locHasPlayers) then {
				// Update build resources from the actual units
				// It will cause an update broadcast by garrison server
				T_CALLM0("updateBuildResources");

				T_SETV("outdated", false);
			};
		};

		// Make sure we spawn
		// T_CALLM("spawn", []);
		// private _thisPos = T_CALLM("getPos", []);
		// // T_PRVAR(side);
		// // Get nearest other garrison
		// pr _nearGarrisons = CALL_STATIC_METHOD("Garrison", "getAllNotEmpty", [[] ARG []]) select {
		// 	!CALLM(_x, "isOnlyEmptyVehicles", [])
		// } apply {
		// 	[CALLM(_x, "getPos", []) distance _thisPos, _x]
		// };
		// if(count _nearGarrisons > 0) then {
		// 	_nearGarrisons sort ASCENDING;
		// 	private _otherGarr = _nearGarrisons#0#1;
		// 	OOP_INFO_MSG("Found %1 to merge our empty vehicles to", [_otherGarr]);
		// 	CALLM(_otherGarr, "addGarrison", [_thisObject]);
		// };

		// // Find any garrisons without intantry left and merge any empty vehicles to the nearest
		// // other garrison.
		// {
		// 	// Remove from model first
		// 	T_PRVAR(worldModel);
		// 	private _garrModel = CALLM(_worldModel, "findGarrisonByActual", [_x]);
		// 	private _pos = GETV(_garrModel, "pos");
		// 	private _nearGarrs = CALLM(_worldModel, "getNearestGarrisons", [_pos ARG 1000]);
		// 	if(count _nearGarrs > 0) then {
		// 		(_nearGarrs#0) params ["_dist", "_nearGarr"];
		// 		OOP_INFO_MSG("%1 only has vehicles left, merging to %2", [_nearGarr]);
		// 		CALLM(_garrModel, "mergeActual", [_nearGarr]);
		// 	};
		// 	// Unregister from ourselves straight away
		// 	// T_CALLM("_unregisterGarrison", [_x]);
		// 	// CALLM2(_x, "postMethodAsync", "destroy", [false]); // false = don't unregister from owning cmdr (as we just did it above!)
		// // } forEach (T_GETV("garrisons") select { CALLM(_x, "isOnlyEmptyVehicles", []) });
		// };
	} ENDMETHOD;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                           S E T T I N G   M E M B E R   V A L U E S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	/*
	Method: setFaction
	Parameters: _faction
	_faction - string
	*/
	METHOD("setFaction") {
		params [P_THISOBJECT, P_STRING("_faction")];
		T_SETV("faction", _faction);
	} ENDMETHOD;

	/*
	Method: setName
	Parameters: _name
	_name - string
	*/
	METHOD("setName") {
		params [P_THISOBJECT, P_STRING("_name")];
		T_SETV("name", _name);
	} ENDMETHOD;

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
		
		pr _AI = T_GETV("AI");
		CALLM1(_AI, "handleLocationChanged", _location);
		
		// Detach from current location if it exists
		pr _currentLoc = T_GETV("location");
		if (_currentLoc != "") then {
			CALLM1(_currentLoc, "unregisterGarrison", _thisObject);
		};
		
		// Attach to another location
		if (_location != "") then {
			ASSERT_OBJECT_CLASS(_location, "Location");
			CALLM1(_location, "registerGarrison", _thisObject);
		};
		
		T_SETV("location", _location);
		
		// Tell commander to update its location data
		pr _AI = CALLSM1("AICommander", "getCommanderAIOfSide", T_GETV("side"));
		if (!IS_NULL_OBJECT(_AI)) then {
			if (_currentLoc != "") then {
				pr _args0 = [_currentLoc, CLD_UPDATE_LEVEL_UNITS, civilian, true, true, 0];
				CALLM2(_AI, "postMethodAsync", "updateLocationData", _args0);
			};
			if (_location != "") then {
				pr _args1 = [_location, CLD_UPDATE_LEVEL_UNITS, civilian, true, true, 0];
				CALLM2(_AI, "postMethodAsync", "updateLocationData", _args1);
			};
		};

		// Position change might change spawn state so update it before returning.
		T_CALLM("updateSpawnState", []);

		// Notify GarrisonServer
		CALLM1(gGarrisonServer, "onGarrisonOutdated", _thisObject);

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
			CALLM1(_currentLoc, "unregisterGarrison", _thisObject);
			T_SETV("location", "");

			// Notify commander
			pr _AI = CALLSM1("AICommander", "getCommanderAIOfSide", T_GETV("side"));
			if (!IS_NULL_OBJECT(_AI)) then {
				pr _args0 = [_currentLoc, CLD_UPDATE_LEVEL_UNITS, civilian, true, true, 0];
				CALLM2(_AI, "postMethodAsync", "updateLocationData", _args0);
			};
		};

		// Notify GarrisonServer
		CALLM1(gGarrisonServer, "onGarrisonOutdated", _thisObject);
		
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

		OOP_INFO_1("SET POS: %1", _pos);

		__MUTEX_LOCK;

		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
		};

		pr _AI = T_GETV("AI");
		CALLM(_AI, "setPos", [_pos]);

		// Position change might change spawn state so update it before returning.
		T_CALLM("updateSpawnState", []);
		__MUTEX_UNLOCK;
	} ENDMETHOD;



	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                           G E T T I N G   M E M B E R   V A L U E S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


	// Getting values

	/*
	Method: getFaction
	Returns: faction - string
	*/
	METHOD("getFaction") {
		params [P_THISOBJECT];

		__MUTEX_LOCK;

		private _return = "";

		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			_return
		};

		_return = GET_VAR(_thisObject, "faction");
		__MUTEX_UNLOCK;
		_return
	} ENDMETHOD;

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

	/*
	Method: getBuildResources

	Returns: number
	*/
	METHOD("getBuildResources") {
		params [P_THISOBJECT, ["_forceUpdate", false]];

		pr _buildRes = 0;
		__MUTEX_LOCK;
		if (_buildRes == -1 || _forceUpdate) then {
			T_CALLM0("updateBuildResources");
		};
		_buildRes = T_GETV("buildResources");
		__MUTEX_UNLOCK;

		_buildRes
	} ENDMETHOD;

	// This is rather computation-heavy
	// An internal function
	METHOD("_getBuildResources") {
		params [P_THISOBJECT];

		pr _return = 0;
		pr _units = T_GETV("units");
		{
			_return = _return + CALLM0(_x, "getBuildResources");
		} forEach _units;

		_return
	} ENDMETHOD;

	// Call this to update the buildResources variable
	// After this call, getBuildResources should be returning the most actual value
	METHOD("updateBuildResources") {
		params [P_THISOBJECT];

		_buildRes = T_CALLM0("_getBuildResources");
		T_SETV("buildResources", _buildRes);

		OOP_INFO_1("UPDATE BUILD RESOURCES: %1", _buildRes);

		// Notify GarrisonServer
		CALLM1(gGarrisonServer, "onGarrisonOutdated", _thisObject);
	} ENDMETHOD;

	METHOD("addBuildResources") {
		params [P_THISOBJECT, P_NUMBER("_value")];

		// Bail if number is negative
		if (_value <= 0) exitWith {};
		
		// Find units which can have build resources
		pr _units = T_GETV("units") select {CALLM0(_x, "canHaveBuildResources")};

		// Bail if there are no units which can have build resources
		if (count _units == 0) exitWith {};

		pr _valuePerUnit = ceil (_value / (count _units)); // Round the values a bit
		{
			CALLM1(_x, "addBuildResources", _valuePerUnit);
		} forEach _units;

		T_CALLM0("updateBuildResources");
	} ENDMETHOD;

	METHOD("removeBuildResources") {
		params [P_THISOBJECT, P_NUMBER("_valueToRemove")];

		// Bail if number is negative
		if (_valueToRemove <= 0) exitWith {};

		pr _resCurrent = T_CALLM0("getBuildResources");

		// Find units which can have build resources
		pr _units = T_GETV("units") select {CALLM0(_x, "canHaveBuildResources")};

		// Bail if there are no units which can have build resources
		if (count _units == 0) exitWith {};

		pr _resRemoved = 0; // Amount of resources removed so far
		pr _i = 0;
		pr _go = true;
		while {(_i < (count _units)) && (_resRemoved < _valueToRemove) && _go} do {
			pr _unit = _units#_i;
			pr _resAtUnit = CALLM0(_unit, "getBuildResources");
			pr _resLeftToRemove = _valueToRemove - _resRemoved;
			if (_resAtUnit <= _resLeftToRemove) then {
				// Remove everything at this unit
				CALLM1(_unit, "removeBuildResources", _resAtUnit);
				_resRemoved = _resRemoved + _resAtUnit;
			} else {
				// Remove only what is needed to remove
				CALLM1(_unit, "removeBuildResources", _resLeftToRemove);
				_resRemoved = _resRemoved + _resLeftToRemove;
				_go = false; // Terminate the loop
			};
			_i = _i + 1;
		};

		T_CALLM0("updateBuildResources");
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

	//				I S   O N L Y   E M P T Y   V E H I C L E S
	/*
	Method: isOnlyEmptyVehicles
	Returns true if garrison contains only empty vehicles

	Returns: Bool
	*/
	METHOD("isOnlyEmptyVehicles") {
		params [P_THISOBJECT];
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			false
		};
		private _unitList = T_GETV("units");
		//private _return = (_unitList findIf {CALLM0(_x, "isInfantry")}) == -1 and {(_unitList findIf {CALLM0(_x, "isVehicle")}) != -1};
		private _return = (T_GETV("countInf") == 0);
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
				GET_VAR(_thisObject, "name"), _unit, CALL_METHOD(_unit, "getData", [])];
				*/
		};

		// Check if the unit is in a group
		private _unitGroup = CALL_METHOD(_unit, "getGroup", []);
		if (_unitGroup != "") then {
			diag_log format ["[Garrison::addUnit] Warning: adding a unit assigned to a group, garrison : %1, unit: %2: %3",
				GET_VAR(_thisObject, "name"), _unit, CALL_METHOD(_unit, "getData", [])];
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
					pr _className = CALLM0(_unit, "getClassName");
					pr _posAndDir = CALLSM2("Location", "findSafeSpawnPos", _className, _pos);
					CALL_METHOD(_unit, "spawn", _posAndDir);
				} else {
					pr _unitData = CALL_METHOD(_unit, "getMainData", []);
					pr _group = CALLM0(_unit, "getGroup");
					pr _groupType = if (_group != "") then {
						CALLM0(_group, "getType")
					} else {
						GROUP_TYPE_IDLE
					};
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
		CALLM0(_unit, "getMainData") params ["_catID", "_subcatID", "_className"];
		CALLM3(_thisObject, "increaseCounters", _catID, _subcatID, _className);
 
		// Notify GarrisonServer
		CALLM1(gGarrisonServer, "onGarrisonOutdated", _thisObject);

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
		CALLM0(_unit, "getMainData") params ["_catID", "_subcatID", "_className"];
		CALLM3(_thisObject, "decreaseCounters", _catID, _subcatID, _className);

		// Notify GarrisonServer
		CALLM1(gGarrisonServer, "onGarrisonOutdated", _thisObject);

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
			CALLM0(_x, "getMainData") params ["_catID", "_subcatID", "_className"];
			CALLM3(_thisObject, "increaseCounters", _catID, _subcatID, _className);
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
			CALLM1(_AI, "handleGroupsAdded", [_group]);
			CALLM0(_AI, "updateComposition");
		};

		// Notify GarrisonServer
		CALLM1(gGarrisonServer, "onGarrisonOutdated", _thisObject);

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
			CALLM0(_x, "getMainData") params ["_catID", "_subcatID", "_className"];
			CALLM3(_thisObject, "decreaseCounters", _catID, _subcatID, _className);
				
		} forEach _groupUnits;
		pr _groups = GET_VAR(_thisObject, "groups");
		_groups deleteAt (_groups find _group);
		
		// If garrison is spawned, notify the AI object. updateComposition must be called after the group and its units are already removed from the garrison.
		if (_AI != "") then {
			CALLM0(_AI, "updateComposition");
		};

		CALLM1(_group, "setGarrison", "");

		// Notify GarrisonServer
		CALLM1(gGarrisonServer, "onGarrisonOutdated", _thisObject);

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
	
	Parameters: _garrison
	
	_garrison - <Garrison> object
	
	Returns: nil
	*/
	
	METHOD("addGarrison") {
		params[P_THISOBJECT, P_OOP_OBJECT("_garrison")];
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
		
		// // Delete the other garrison if needed
		// if (_delete) then {
		// 	// TODO: we need to work out how to do this properly.
		// 	// DELETE(_garrison);
		// 	// HACK: Just unregister with AICommander for now so the model gets cleaned up
		// 	// CALLM(_garrison, "destroy", []);
		// };

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

		OOP_INFO_1("ADD UNITS AND GROUPS: %1", _this);

		ASSERT_THREAD(_thisObject);

		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			false
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
		
		// Delete empty groups in the src garrison
		CALLM0(_garSrc, "deleteEmptyGroups");

		__MUTEX_UNLOCK;

		true
		
	} ENDMETHOD;

	/*
	Method: addUnitsFromComposition
	Adds units to this garrison from another garrison.
	Unit arrangement is specified by composition array.

	Parameters: _garSrc, _comp
	
	_garSrc - source <Garrison>
	_comp - composition array. See "composition" member variable and how it's organized.
	
	Returns: Number, amount of unsatisfied matches. 0 if all composition elements were matched.
	*/
	METHOD("addUnitsFromComposition") {
		params [P_THISOBJECT, P_OOP_OBJECT("_garSrc"), P_ARRAY("_comp")];

		OOP_INFO_1("ADD UNITS FROM COMPOSITION: %1", _this);

		// Bail if garSrc is destroyed for some reason
		if (!IS_OOP_OBJECT(_garSrc)) exitWith {
			OOP_ERROR_1("Source garrison object is invalid: %1", _garSrc);
			1
		};

		__MUTEX_LOCK;

		// Number of unsatisfied constraints
		pr _numUnsat = 0;

		pr _unitsSrc = +CALLM0(_garSrc, "getUnits"); // Make a deep copy! Don't want to break it.

		// Preprocess classnames into IDs in advance for each unit
		pr _unitsSrcData = _unitsSrc apply {
			CALLM0(_x, "getMainData") params ["_catID", "_subcatID", "_className"];
			pr _classID = [_className] call t_fnc_classNameToNumber;
			if (_classID == -1) then {_ID = -2; }; // So that it doesn't equal a (potential) -1 in the incoming _comp array
			[_catID, _subcatID, _classID]
		};

		// Find units for each category
		pr _unitsFound = [[], [], []];
		_unitsFound params ["_unitsFoundInf", "_unitsFoundVeh", "_unitsFoundDrones"];
		// forEach [T_INF, T_VEH, T_DRONE];
		{
			pr _catID = _x;
			// forEach _comp#_catID;
			{
				pr _classes = _x;
				pr _subcatID = _foreachindex;
				// forEach _classes;
				{
					pr _classID = _x;
					// Find a unit which has the same classID, catID and subcatID
					pr _index = _unitsSrcData find [_catID, _subcatID, _classID];
					if (_index != -1) then {
						// There is a match
						(_unitsFound#_catID) pushBack (_unitsSrc#_index); // Move to the array with found units
						_unitsSrc deleteAt _index;
						_unitsSrcData deleteAt _index;
					} else {
						// Increase the fail counter
						_numUnsat = _numUnsat + 1;
					};
				} forEach _classes;
			} forEach _comp#_catID;
		} forEach [T_INF, T_VEH, T_DRONE];

		// Reorganize the infantry units we are moving
		if (count _unitsFoundInf > 0) then {
			_newGroup = NEW("Group", [T_GETV("side") ARG GROUP_TYPE_IDLE]);
			pr _newInfGroups = [_newGroup];
			CALLM1(_garSrc, "addGroup", _newGroup); // Add the new group to the src garrison first
			// forEach _unitsFoundInf;
			{
				// Create a new inf group if the current one is 'full'
				if (count CALLM0(_newGroup, "getUnits") > 6) then {
					_newGroup = NEW("Group", [T_GETV("side") ARG GROUP_TYPE_IDLE]);
					_newInfGroups pushBack _newGroup;
					CALLM1(_garSrc, "addGroup", _newGroup);
				};

				// Add the unit to the group
				CALLM1(_newGroup, "addUnit", _x);
			} forEach _unitsFoundInf;

			// Move all the infantry groups
			{
				CALLM1(_thisObject, "addGroup", _x);
			} forEach _newInfGroups;
		};

		// Move all the vehicle units into one group
		// Vehicles need to be moved within a group too
		pr _vehiclesAndDrones = _unitsFoundVeh + _unitsFoundDrones;
		OOP_INFO_1("Moving vehicles and drones: %1", _vehiclesAndDrones);
		if (count _vehiclesAndDrones > 0) then {
			pr _newVehGroup = NEW("Group", [T_GETV("side") ARG GROUP_TYPE_VEH_NON_STATIC]); // todo we assume we aren't moving statics anywhere right now
			CALLM1(_garSrc, "addGroup", _newVehGroup);
			{
				CALLM1(_newVehGroup, "addUnit", _x);
			} forEach _vehiclesAndDrones;

			// Move the veh group
			CALLM1(_thisObject, "addGroup", _newVehGroup);
		};

		// Delete empty groups in the src garrison
		CALLM0(_garSrc, "deleteEmptyGroups");

		__MUTEX_UNLOCK;

		_numUnsat
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
	Method: increaseCounters
	Adds values to efficiency vector and other counters
	
	Private use!
	
	Returns: nil
	*/
	METHOD("increaseCounters") {
		params [P_THISOBJECT, "_catID", "_subCatID", "_className"];
		
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

		// Update counters
		pr _varName = "countInf";
		switch (_catID) do {
			case T_INF: {_varName = "countInf"};
			case T_VEH: {_varName = "countVeh"};
			case T_DRONE: {_varName = "countDrone"};
			case T_CARGO: {_varName = "countCargo"};
		};
		T_SETV(_varName, T_GETV(_varName)+1);

		// Update composition array
		pr _comp = T_GETV("composition");
		(_comp#_catID#_subCatID) pushBack ([_className] call t_fnc_classNameToNumber);

		__MUTEX_UNLOCK;
	} ENDMETHOD;	
	
	/*
	Method: subEfficiency
	Substracts values from efficiency vector and other counters
	
	Private use!
	
	Returns: nil
	*/
	METHOD("decreaseCounters") {
		params [P_THISOBJECT, "_catID", "_subCatID", "_className"];
		
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

		// Update counters
		pr _varName = "countInf";
		switch (_catID) do {
			case T_INF: {_varName = "countInf"};
			case T_VEH: {_varName = "countVeh"};
			case T_DRONE: {_varName = "countDrone"};
			case T_CARGO: {_varName = "countCargo"};
		};
		T_SETV(_varName, T_GETV(_varName)-1);

		// Update composition array
		pr _comp = T_GETV("composition");
		pr _array = _comp#_catID#_subCatID;
		_array deleteAt (_array find ([_className] call t_fnc_classNameToNumber));

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

	METHOD("getComposition") {
		params [P_THISOBJECT];
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			pr _comp = [];
			{
				pr _tempArray = [];
				_tempArray resize _x;
				_comp pushBack (_tempArray apply {[]});
			} forEach [T_INF_SIZE, T_VEH_SIZE, T_DRONE_SIZE, T_CARGO_SIZE];
			_comp
		};
		pr _return = +T_GETV("composition");
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

		// Add the unit to the garbage collector
		CALLM1(gGarbageCollector, "addUnit", _unit);

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

	/*
	Method: countInfantryUnits
	Returns the amount of infantry units

	Returns: Number
	*/
	METHOD("countInfantryUnits") {
		params [P_THISOBJECT];
		T_GETV("countInf")
	} ENDMETHOD;

	/*
	Method: countVehicleUnits
	Returns the amount of vehicle units

	Returns: Number
	*/
	METHOD("countVehicleUnits") {
		params [P_THISOBJECT];
		T_GETV("countVeh")
	} ENDMETHOD;

	/*
	Method: countDroneUnits
	Returns the amount of drone units

	Returns: Number
	*/
	METHOD("countDroneUnits") {
		params [P_THISOBJECT];
		T_GETV("countDrone")
	} ENDMETHOD;

	/*
	Method: countCargoUnits
	Returns the amount of cargo units

	Returns: Number
	*/
	METHOD("countCargoUnits") {
		params [P_THISOBJECT];
		T_GETV("countCargo")
	} ENDMETHOD;
	
	// ======================================= FILES ==============================================
	// Handles incoming messages. Since it's a MessageReceiverEx, we must overwrite handleMessageEx
	METHOD_FILE("handleMessageEx", "Garrison\handleMessageEx.sqf");

	// Spawns the whole garrison
	METHOD_FILE("spawn", "Garrison\spawn.sqf");

	// Despawns the whole garrison
	METHOD_FILE("despawn", "Garrison\despawn.sqf");

	// Update spawn state of the garrison
	METHOD_FILE("updateSpawnState", "Garrison\updateSpawnState.sqf");
	
	// Static helpers

	
	METHOD("createAddInfGroup") {
		params [P_THISOBJECT, "_side", "_subcatID", ["_type", GROUP_TYPE_IDLE]];
		// Create an empty group
		private _newGroup = NEW("Group", [_side ARG _type]);
		// Create units from template
		pr _templateName = GET_TEMPLATE_NAME(_side);
		pr _template = [_templateName] call t_fnc_getTemplate;
		private _count = CALL_METHOD(_newGroup, "createUnitsFromTemplate", [_template ARG _subcatID]);
		T_CALLM("addGroup", [_newGroup]);
		[_newGroup, _count]
	} ENDMETHOD;
	
	METHOD("createAddVehGroup") {
		params [P_THISOBJECT, "_side", "_catID", "_subcatID", "_classID"];
		// Create an empty group
		private _newGroup = NEW("Group", [_side ARG GROUP_TYPE_VEH_NON_STATIC]);
		pr _templateName = GET_TEMPLATE_NAME(_side);
		pr _template = [_templateName] call t_fnc_getTemplate;
		private _newUnit = NEW("Unit", [_template ARG _catID ARG _subcatID ARG -1 ARG _newGroup]);
		// Create crew for the vehicle
		CALL_METHOD(_newUnit, "createDefaultCrew", [_template]);
		T_CALLM("addGroup", [_newGroup]);
		_newGroup
	} ENDMETHOD;

	// Adds an intel item to this garrison
	METHOD("addIntel") {
		pr _return = params ["_thisObject", ["_intel", "", [""]]];

		if(!_return) exitWith {
			DUMP_CALLSTACK;
		};

		T_GETV("intelItems") pushBackUnique _intel;

		OOP_INFO_1("Added intel: %1", _intel);
	} ENDMETHOD;

	// Gets all intel items from this garrison
	METHOD("getIntel") {
		params ["_thisObject"];

		T_GETV("intelItems")
	} ENDMETHOD;

	// Updates spawn state of garrisons close to the provided position
	// Public, thread-safe
	STATIC_METHOD("updateSpawnStateOfGarrisonsNearPos") {
		params ["_thisClass", ["_pos", [], [[]]]];
		pr _args = ["Garrison", "_updateSpawnStateOfGarrisonsNearPos", [_pos]];
		CALLM2(gMessageLoopMainManager, "postMethodAsync", "callStaticMethodInThread", _args);
	} ENDMETHOD;

	// Private, thread-unsafe
	STATIC_METHOD("_updateSpawnStateOfGarrisonsNearPos") {
		params ["_thisClass", ["_pos", [], [[]]]];

		pr _gars = GETSV("Garrison", "all");
		pr _garsToCheck = _gars select {
			if (CALLM0(_x, "isAlive")) then {
				CALLM0(_x, "getPos") distance2D _pos < 1500 // todo arbitrary number for now
			} else {
				false
			};
		};

		{
			CALLM0(_x, "updateSpawnState");
		} forEach _garsToCheck;
	} ENDMETHOD;

	METHOD("getTemplateName") {
		params [P_THISOBJECT];
		T_GETV("templateName")
	} ENDMETHOD;

ENDCLASS;

SETSV("Garrison", "all", []);