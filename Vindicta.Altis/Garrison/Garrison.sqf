#include "common.hpp"
FIX_LINE_NUMBERS()

/*
Class: Garrison
Garrison is an object which holds units and groups and handles their lifecycle (spawning, despawning, destruction).
Garrison is much like a group, it has an <AIGarrison>. But it can have multiple groups of different types.

Author: Sparker 12.07.2018


*/

#define SAFE_ACCESSOR(variableName, defaultValue) \
		(if(IS_GARRISON_DESTROYED(_thisObject)) then { \
			WARN_GARRISON_DESTROYED; \
			defaultValue \
		} else { \
			T_GETV(variableName) \
		})

#define pr private

#define WARN_GARRISON_DESTROYED OOP_WARNING_MSG("Attempted to call function on destroyed garrison %1", [_thisObject]); DUMP_CALLSTACK

#define MESSAGE_LOOP gMessageLoopMain

#define OOP_CLASS_NAME Garrison
CLASS("Garrison", ["MessageReceiverEx" ARG "GOAP_Agent"]);

	STATIC_VARIABLE("all");

	/* save */	VARIABLE_ATTR("type",			[ATTR_PRIVATE ARG ATTR_SAVE]); // Garrison type: one of each type of garrison can exist at a location
	/* save */	VARIABLE_ATTR("side", 			[ATTR_PRIVATE ARG ATTR_SAVE]);
	/* save */	VARIABLE_ATTR("faction",		[ATTR_PRIVATE ARG ATTR_SAVE]); // Template used for loadouts of the garrison
	/* save */	VARIABLE_ATTR("templateName", 	[ATTR_PRIVATE ARG ATTR_SAVE]);
				VARIABLE_ATTR("spawned", 		[ATTR_PRIVATE]);
	// SAVEBREAK >>>
	// Remove, autoSpawn is no longer needed, use garrison type instead
	/* save */	VARIABLE_ATTR("autoSpawn",		[ATTR_PRIVATE ARG ATTR_SAVE]); // If true, it will be updating its own spawn state even if inactive
	// <<< SAVEBREAK
	/* save */	VARIABLE_ATTR("name", 			[ATTR_PRIVATE ARG ATTR_SAVE]);

	/* save */	VARIABLE_ATTR("AI", 			[ATTR_GET_ONLY ARG ATTR_SAVE]); // The AI brain of this garrison
				VARIABLE_ATTR("timer", 			[ATTR_PRIVATE]); // Timer that will be sending PROCESS messages here
				VARIABLE_ATTR("mutex", 			[ATTR_PRIVATE]); // Mutex used to lock the object

	/* save */	VARIABLE_ATTR("active",			[ATTR_PRIVATE ARG ATTR_SAVE]); // Set to true after calling activate method

				VARIABLE_ATTR("units", 			[ATTR_PRIVATE]);
	/* save */	VARIABLE_ATTR("savedUnits",		[ATTR_PRIVATE ARG ATTR_SAVE]);
	/* save */	VARIABLE_ATTR("groups", 		[ATTR_PRIVATE ARG ATTR_SAVE]);

	/* save */	VARIABLE_ATTR("location", 		[ATTR_PRIVATE ARG ATTR_SAVE]);
	/* save */	VARIABLE_ATTR("home", 			[ATTR_PRIVATE ARG ATTR_SAVE]); // Location the garrison considers home (defaults to the first location the garrison is assigned to)

				VARIABLE_ATTR("effTotal", 		[ATTR_PRIVATE]); // Efficiency vector of all units
				VARIABLE_ATTR("effMobile", 		[ATTR_PRIVATE]); // Efficiency vector of all units that can move

				VARIABLE_ATTR("buildResources", [ATTR_PRIVATE]);

	// Counters of subcategories
				VARIABLE_ATTR("countInf",		[ATTR_PRIVATE]);
				VARIABLE_ATTR("countVeh",		[ATTR_PRIVATE]);
				VARIABLE_ATTR("countDrone",		[ATTR_PRIVATE]);
				VARIABLE_ATTR("countCargo", 	[ATTR_PRIVATE]);

	// Array with composition: each element at [_cat][_subcat] index is an array of nubmers 
	// associated with unit's class names, converted from class names with t_fnc_classNameToNubmer
				VARIABLE("compositionClassNames"); // Must be restored after game is loaded!!

	// Array with composition: each element at [_cat][_subcat] is an amount of units of this type
				VARIABLE_ATTR("compositionNumbers", [ATTR_PRIVATE]);

	// Flag which is reset at each process call
	// It is set by various functions changing state of this garrison
	// We use it to delay a large amount of big computations when many changes happen rapidly,
	// which would otherwise cause a lot of computations on each change
				VARIABLE_ATTR("outdated", 		[ATTR_PRIVATE]);
				VARIABLE("regAtServer"); // Bool, garrisonServer sets it to true to identify if this garrison is registered there

	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	/*
	Method: new

	Parameters: _side, _pos

	_side - side of this garrison
	_pos - optional, default position to set to the garrison
	*/
	METHOD(new)
		params [P_THISOBJECT, P_STRING_DEFAULT("_type", GARRISON_TYPE_GENERAL), P_SIDE("_side"), P_ARRAY("_pos"), P_STRING("_faction"), P_STRING_DEFAULT("_templateName", "tDefault"), P_BOOL("_immediateSpawn"), P_OOP_OBJECT("_home")];

		OOP_INFO_1("NEW GARRISON: %1", _this);

		// Take our own ref that we will release in "destroy" function. This makes sure that delete never pre-empts destroy (assuming ref counting is done properly by other classes)
		REF(_thisObject);

		// Check existance of neccessary global objects
		ASSERT_GLOBAL_OBJECT(MESSAGE_LOOP);
		ASSERT_GLOBAL_OBJECT(gGarrisonServer);
		//ASSERT_GLOBAL_OBJECT(gGarrisonAbandonedVehicles);
		ASSERT_GLOBAL_OBJECT(gTimerServiceMain);
		ASSERT_GLOBAL_OBJECT(gMessageLoopMainManager);

		// Ensure some template
		if (_templateName == "") then {
			_templateName = "tDefault";
			OOP_WARNING_1("Garrison without template name was created: %1", _this);
		};

		T_SETV("side", _side);
		T_SETV("type", _type);
		T_SETV("faction", _faction);
		T_SETV("templateName", _templateName);
		T_SETV("units", []);
		T_SETV("groups", []);
		T_SETV("spawned", false);
		T_SETV("name", "");
		T_SETV("location", NULL_OBJECT);
		T_SETV("home", _home);
		//T_SETV("action", "");
		T_SETV("effTotal", +T_EFF_null);
		T_SETV("effMobile", +T_EFF_null);
		T_SETV("countInf", 0);
		T_SETV("countVeh", 0);
		T_SETV("countDrone", 0);
		T_SETV("countCargo", 0);
		T_SETV("active", false);
		T_SETV("buildResources", -1);
		T_SETV("outdated", true);
		T_SETV("regAtServer", false);
		pr _mutex = MUTEX_RECURSIVE_NEW();
		T_SETV("mutex", _mutex);

		// Set value of composition array
		pr _comp = [];
		{
			pr _tempArray = [];
			_tempArray resize _x;
			_comp pushBack (_tempArray apply {[]});
		} forEach [T_INF_SIZE, T_VEH_SIZE, T_DRONE_SIZE, T_CARGO_SIZE];
		T_SETV("compositionClassNames", _comp);

		T_SETV("compositionNumbers", +T_comp_null);

		// Create AI object
		// Create an AI brain of this garrison and start it
		pr _AI = NEW("AIGarrison", [_thisObject]);
		T_SETV("AI", _AI);

		// Create a timer to call process method
		T_CALLM0("initTimer");

		// Set position if it was specified
		if (count _pos > 0) then {
			T_CALLM2("postMethodAsync", "setPos", [_pos]);
		};

		// Enable automatic spawning
		private _autoSpawn = _type in GARRISON_TYPES_AUTOSPAWN;
		if(_immediateSpawn || !_autoSpawn) then {
			T_CALLM2("postMethodAsync", "spawn", [true]);
		};

		GETSV("Garrison", "all") pushBack _thisObject;
	ENDMETHOD;

	// Create a new garrison from an existing one, copying relevant state
	STATIC_METHOD(newFrom)
		params [P_THISCLASS, P_OOP_OBJECT("_other"), P_POSITION("_posOverride")];

		// Make a new garrison
		private _type = CALLM0(_other, "getType");
		private _side = CALLM0(_other, "getSide");
		private _pos = if(_posOverride isEqualTo []) then { CALLM0(_other, "getPos") } else { _posOverride };
		private _faction = CALLM0(_other, "getFaction");
		private _templateName = CALLM0(_other, "getTemplateName");
		private _spawned = CALLM0(_other, "isSpawned");
		private _home = CALLM0(_other, "getHome");

		private _args = [_type, _side, _pos, _faction, _templateName, _spawned, _home];
		NEW("Garrison", _args);
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	/*
	Method: delete

	*/
	METHOD(delete)
		params [P_THISOBJECT];

		OOP_INFO_0("DELETE GARRISON");
		
		ASSERT_MSG(IS_GARRISON_DESTROYED(_thisObject), "Garrison should be destroyed before it is deleted");
	ENDMETHOD;
	
	METHOD(initTimer)
		params [P_THISOBJECT];

		pr _msg = MESSAGE_NEW();
		MESSAGE_SET_DESTINATION(_msg, _thisObject);
		MESSAGE_SET_TYPE(_msg, GARRISON_MESSAGE_PROCESS);
		pr _args = [_thisObject, 2.5, _msg, gTimerServiceMain, true]; // !! Will be called unscheduled
		pr _timer = NEW("Timer", _args);
		T_SETV("timer", _timer);
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                          A C T I V A T E                           |
	// ----------------------------------------------------------------------
	/*
	Method: activate

	Start AI
	Registers with commander and global garrison list
	Sets "active" variable to true

	!! Must be called from commander thread !!

	Returns: GarrisonModel
	*/
	METHOD(activate)
		params [P_THISOBJECT];

		if(T_GETV("active")) exitWith {
			OOP_ERROR_0("This garrison is already activated");
		};

		// Set 'active' flag
		T_SETV("active", true);

		T_CALLM1("postMethodAsync", "_activate");

		return CALL_STATIC_METHOD("AICommander", "registerGarrison", [_thisObject])
	ENDMETHOD;

	// internal
	METHOD(_activate)
		params [P_THISOBJECT];

		// Start AI object
		private _startProcCat = ["AIGarrisonDespawned", "AIGarrisonSpawned"] select T_GETV("spawned");

		CALLM1(T_GETV("AI"), "start", _startProcCat); // Let's start the party! \o/

		// Notify GarrisonServer
		CALLM1(gGarrisonServer, "onGarrisonCreated", _thisObject);
	ENDMETHOD;

	/*
	Method: activateOutOfThread

	Same as activate, for calling outside the commander thread.

	Returns: nil
	*/
	METHOD(activateOutOfThread)
		params [P_THISOBJECT];

		// Start AI object
		CALLM1(T_GETV("AI"), "start", "AIGarrisonDespawned"); // Let's start the party! \o/

		// Set 'active' flag
		T_SETV("active", true);

		// Enable automatic spawning
		private _autoSpawn = T_GETV("type") in GARRISON_TYPES_AUTOSPAWN;
		if(!_autoSpawn) then {
			T_CALLM2("postMethodAsync", "spawn", [true]);
		};
		
		T_SETV("outdated", true);

		CALL_STATIC_METHOD("AICommander", "registerGarrisonOutOfThread", [_thisObject]);
		nil
	ENDMETHOD;
	// ----------------------------------------------------------------------
	// |                           D E S T R O Y                            |
	// ----------------------------------------------------------------------
	/*
	Method: destroy

	This starts the delete process for this garrison. It sets the garrison to 
	destroyed state (isDestroyed returns true, isAlive returns false), removes
	all units and groups, deletes the timer and AI components.
	*/
	METHOD(destroy)
		params [P_THISOBJECT, P_BOOL_DEFAULT_TRUE("_unregisterFromCmdr")];
		
		OOP_INFO_0("DESTROY GARRISON");

		__MUTEX_LOCK;

		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {

			__MUTEX_UNLOCK;
			OOP_WARNING_MSG("Garrison is already destroyed", []);
		};

		ASSERT_THREAD(_thisObject);

		// Detach from location if was attached to it
		private _location = T_GETV("location");
		if (_location != NULL_OBJECT) then {
			CALLM1(_location, "unregisterGarrison", _thisObject);
		};

		// Despawn if spawned
		if(T_GETV("spawned")) then {
			__MUTEX_UNLOCK;
			T_CALLM0("despawn");
			__MUTEX_LOCK;
		};

		private _units = T_GETV("units");
		private _groups = T_GETV("groups");

		if (count _units != 0) then {
			OOP_ERROR_1("Deleting garrison which has units: %1", _units);
		};
		
		if (count _groups != 0) then {
			OOP_ERROR_1("Deleting garrison which has groups: %1", _groups);
		};
		
		// Despawn method of groups and units might need to lock this garrison object
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
		if (_timer != NULL_OBJECT) then {
			DELETE(_timer);
			T_SETV("timer", nil);
		};

		// Delete the AI object
		// We delete it instantly because Garrison AI is in the same thread
		DELETE(T_GETV("AI"));
		T_SETV("AI", nil);

		if(_unregisterFromCmdr) then {
			// Unregister with the owning commander, do it last because it will cause an unref
			CALL_STATIC_METHOD("AICommander", "unregisterGarrison", [_thisObject]);
		};

		T_SETV("effMobile", []);
		// effTotal will serve as our DESTROYED marker. Set to [] means Garrison is destroyed and should not be used or referenced.
		T_SETV("effTotal", []);

		// Notify GarrisonServer
		CALLM1(gGarrisonServer, "onGarrisonDestroyed", _thisObject);

		__MUTEX_UNLOCK;

		// Release our own ref. This might call delete if all other holders already released their refs.
		UNREF(_thisObject);
	ENDMETHOD;

	/*
	Method: isAlive

	Is this Garrison ready to be used?
	*/
	METHOD(isAlive)
		params [P_THISOBJECT];
		// No mutex lock because this is expected to be atomic
		!IS_GARRISON_DESTROYED(_thisObject)
		//(T_GETV("effTotal") isEqualTo [])
	ENDMETHOD;

	/*
	Method: isDestroyed

	Is this Garrison ready to be used?
	*/
	METHOD(isDestroyed)
		params [P_THISOBJECT];
		// No mutex lock because this is expected to be atomic
	 	IS_GARRISON_DESTROYED(_thisObject)
	ENDMETHOD;


	METHOD(runLocked)
		params [P_THISOBJECT, P_OOP_OBJECT("_obj"), P_STRING("_funcName"), P_ARRAY("_args")];
		__MUTEX_LOCK;
		CALLM(_obj, _funcName, _args);
		__MUTEX_UNLOCK;
	ENDMETHOD;

	METHOD(lock)
		params [P_THISOBJECT];
		__MUTEX_LOCK;
	ENDMETHOD;

	METHOD(unlock)
		params [P_THISOBJECT];
		__MUTEX_UNLOCK;
	ENDMETHOD;

	/*
	Method: (static) getAllActive
	Returns all garrisons
	
	Parameters: _sidesInclude, _sidesExclude
	
	_sidesInclude - optional, Sides of garrisons to include. If _sidesInclude is not provided, include all garrisons.
	_sidesExclude - optional, Sides of garrisons to exclude. If _sidesExclude is not provided, no garrisons are excluded.

	Returns: Array with <Garrison> objects
	*/
	STATIC_METHOD(getAllActive)
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
	ENDMETHOD;

	/*
	Method: (static) getAllNotEmpty
	Returns all active non empty garrisons
	
	Parameters: _sidesInclude, _sidesExclude
	
	_sidesInclude - optional, Sides of garrisons to include. If _sidesInclude is not provided, include all garrisons.
	_sidesExclude - optional, Sides of garrisons to exclude. If _sidesExclude is not provided, no garrisons are excluded.

	Returns: Array with <Garrison> objects
	*/
	STATIC_METHOD(getAllNotEmpty)
		params [P_THISCLASS, P_ARRAY("_sidesInclude"), P_ARRAY("_sidesExclude")];
		
		if (count _sidesInclude == 0 and count _sidesExclude == 0) then {
			GETSV("Garrison", "all") select { 
				GETV(_x, "active") and {!CALLM0(_x, "isEmpty")} 
			}
		} else {
			GETSV("Garrison", "all") select { 
				GETV(_x, "active") and {!CALLM0(_x, "isEmpty")} and 
				{count _sidesInclude == 0 or {CALLM0(_x, "getSide") in _sidesInclude}} and 
				{count _sidesExclude == 0 or {!(CALLM0(_x, "getSide") in _sidesExclude)}}
			}
		};
	ENDMETHOD;

	/*
	Method: (static) getAll

	Returns absolutely all garrison objects
	*/
	STATIC_METHOD(getAll)
		params [P_THISCLASS];
		GETSV("Garrison", "all")
	ENDMETHOD;

	/*
	Method: getMessageLoop
	See <MessageReceiver.getMessageLoop>

	Returns: <MessageLoop>
	*/
	// Returns the message loop this object is attached to
	METHOD(getMessageLoop)
		MESSAGE_LOOP
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                           P R O C E S S                            |
	// | THIS IS RUN UNSCHEDULED											|
	// ----------------------------------------------------------------------
	METHOD(process)
		params [P_THISOBJECT];

		//OOP_INFO_0("PROCESS");

		// 
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
		};

		// Update spawn state
		IF(T_GETV("type") in GARRISON_TYPES_AUTOSPAWN) then {
			T_CALLM("updateSpawnState", []);
		};

		// Check spawn state if active
		if (T_GETV("active")) then { 

			//OOP_INFO_0("  ACTIVE");

			// If we are empty except for vehicles and we are not at a location then we must abandon them
			if((T_GETV("side") != CIVILIAN) and {T_GETV("location") == ""} and {T_CALLM("isOnlyEmptyVehicles", [])}) then {
				OOP_INFO_MSG("This garrison only has vehicles left, abandoning them", []);
				// Move the units to the abandoned vehicle garrison
				pr _args = [_thisObject];
				CALLM2(gGarrisonAbandonedVehicles, "postMethodAsync", "addGarrison", _args);
			};

			pr _loc = T_GETV("location");
			// Players might be messing with inventories, so we must update our amount of build resources more often
			pr _locHasPlayers = (_loc != "" && { CALLM0(_loc, "hasPlayers") } );
			//OOP_INFO_1("  hasPlayers: %1", _locHasPlayers);
			if (T_GETV("outdated") || _locHasPlayers) then {
				// Update build resources from the actual units
				// It will cause an update broadcast by garrison server
				T_CALLM0("updateBuildResources");

				T_SETV("outdated", false);
			};
		};

		private _location = T_GETV("location");
		// Top up the civilian cars if this is a civilian garrison (ignore spawn status, we will pop them into existance regardless)
		if(_location != NULL_OBJECT && { T_GETV("side") == CIVILIAN }) then {
			private _currCars = T_CALLM0("countVehicleUnits");
			private _template = T_CALLM0("getTemplate");
			private _maxCars = CALLM0(_location, "getMaxCivilianVehicles");
			private _spawned = T_GETV("spawned");
			// If we aren't spawned then immediately top up, if we are spawned then only top up if 1/2 cars are gone (should mostly avoid cars popping into existance)
			if(_spawned && _currCars < _maxCars / 2 || !_spawned && _currCars < _maxCars) then {
				for "_i" from _currCars to _maxCars do {
					private _newUnit = NEW("Unit", [_template ARG T_VEH ARG T_VEH_DEFAULT ARG -1 ARG ""]);
					T_CALLM1("addUnit", _newUnit);
				};
			};
		};

		// Make sure we spawn
		// T_CALLM("spawn", []);
		// private _thisPos = T_CALLM("getPos", []);
		// // private _side = T_GETV("side");
		// // Get nearest other garrison
		// pr _nearGarrisons = CALL_STATIC_METHOD("Garrison", "getAllNotEmpty", [[] ARG []]) select {
		// 	!CALLM0(_x, "isOnlyEmptyVehicles")
		// } apply {
		// 	[CALLM0(_x, "getPos") distance _thisPos, _x]
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
		// 	private _worldModel = T_GETV("worldModel");
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
		// // } forEach (T_GETV("garrisons") select { CALLM0(_x, "isOnlyEmptyVehicles") });
		// };
	ENDMETHOD;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                           S E T T I N G   M E M B E R   V A L U E S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	/*
	Method: setFaction
	Parameters: _faction
	_faction - string
	*/
	METHOD(setFaction)
		params [P_THISOBJECT, P_STRING("_faction")];
		T_SETV("faction", _faction);
	ENDMETHOD;

	/*
	Method: setName
	Parameters: _name
	_name - string
	*/
	METHOD(setName)
		params [P_THISOBJECT, P_STRING("_name")];
		T_SETV("name", _name);
	ENDMETHOD;

	/*
	Method: setLocation
	Sets the location of this garrison

	Parameters: _location

	_location - <Location>
	*/
	METHOD(setLocation)
		params [P_THISOBJECT, P_OOP_OBJECT("_location")];

		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
		};

		ASSERT_THREAD(_thisObject);
		
		// Notify AI object
		pr _AI = T_GETV("AI");
		CALLM1(_AI, "handleLocationChanged", _location);
		
		// Detach from current location if it exists
		pr _currentLoc = T_GETV("location");
		if (_currentLoc != NULL_OBJECT) then {
			CALLM1(_currentLoc, "unregisterGarrison", _thisObject);
		};
		
		// Attach to another location
		if (_location != NULL_OBJECT) then {
			ASSERT_OBJECT_CLASS(_location, "Location");
			CALLM1(_location, "registerGarrison", _thisObject);
			if(T_GETV("home") == NULL_OBJECT) then {
				T_SETV("home", _location);
			};
		};
		
		T_SETV("location", _location);
		
		// Tell commander to update its location data
		pr _AI = CALLSM1("AICommander", "getAICommander", T_GETV("side"));
		if (!IS_NULL_OBJECT(_AI)) then {
			if (_currentLoc != NULL_OBJECT) then {
				pr _args0 = [_currentLoc, CLD_UPDATE_LEVEL_UNITS, civilian, true, true, 0];
				CALLM2(_AI, "postMethodAsync", "updateLocationData", _args0);
			};
			if (_location != NULL_OBJECT) then {
				pr _args1 = [_location, CLD_UPDATE_LEVEL_UNITS, civilian, true, true, 0];
				CALLM2(_AI, "postMethodAsync", "updateLocationData", _args1);
			};
		};

		// Position change might change spawn state so update it before returning.
		T_CALLM("updateSpawnState", []);

		// Notify GarrisonServer
		CALLM1(gGarrisonServer, "onGarrisonOutdated", _thisObject);

		__MUTEX_UNLOCK;
		
	ENDMETHOD;

	
	//                     S E T   H O M E
	/*
	Method: setHome
	Sets the location this garrison considers home base

	Parameters: _home

	_home - <Location>
	*/
	METHOD(setHome)
		params [P_THISOBJECT, P_OOP_OBJECT("_home")];

		__MUTEX_LOCK;

		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
		};
		T_SETV("home", _home);

		__MUTEX_UNLOCK;
		
	ENDMETHOD;
	
	METHOD(detachFromLocation)
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
			pr _AI = CALLSM1("AICommander", "getAICommander", T_GETV("side"));
			if (!IS_NULL_OBJECT(_AI)) then {
				pr _args0 = [_currentLoc, CLD_UPDATE_LEVEL_UNITS, civilian, true, true, 0];
				CALLM2(_AI, "postMethodAsync", "updateLocationData", _args0);
			};
		};

		// Notify AI object
		pr _AI = T_GETV("AI");
		CALLM1(_AI, "handleLocationChanged", "");

		// Notify GarrisonServer
		CALLM1(gGarrisonServer, "onGarrisonOutdated", _thisObject);
		
		__MUTEX_UNLOCK;
	ENDMETHOD;

	/*
	Method: setPos
	Sets the position of this garrison. Note that position can be updated later on its own by garrison's actions.

	Parameters: _pos

	_pos - position
	*/
	METHOD(setPos)
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
		T_CALLM0("updateSpawnState");
		__MUTEX_UNLOCK;
	ENDMETHOD;



	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                           G E T T I N G   M E M B E R   V A L U E S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


	// Getting values

	/*
	Method: getFaction
	Returns: faction - string
	*/
	METHOD(getFaction)
		params [P_THISOBJECT];
		SAFE_ACCESSOR("faction", "")
	ENDMETHOD;

	//                         G E T   S I D E
	/*
	Method: getSide
	Returns side of this garrison.

	Returns: Side
	*/
	METHOD(getSide)
		params [P_THISOBJECT];
		SAFE_ACCESSOR("side", sideUnknown)
	ENDMETHOD;

	//                         G E T   T Y P E
	/*
	Method: getType
	Returns type of this garrison.

	Returns: string
	*/
	METHOD(getType)
		params [P_THISOBJECT];
		SAFE_ACCESSOR("type", "")
	ENDMETHOD;

	//                     G E T   L O C A T I O N
	/*
	Method: getLocation
	Returns location this garrison is attached to.

	Returns: <Location>
	*/
	METHOD(getLocation)
		params [P_THISOBJECT];
		SAFE_ACCESSOR("location", NULL_OBJECT)
	ENDMETHOD;

	//                     G E T   H O M E
	/*
	Method: getHome
	Returns location this garrison considers home (usually the first location it was attached to)

	Returns: <Location>
	*/
	METHOD(getHome)
		params [P_THISOBJECT];
		SAFE_ACCESSOR("home", NULL_OBJECT)
	ENDMETHOD;

	//                      G E T   G R O U P S
	/*
	Method: getGroups
	Returns groups of this garrison.

	Returns: Array of <Group> objects.
	*/
	METHOD(getGroups)
		params [P_THISOBJECT];
		+SAFE_ACCESSOR("groups", [])
	ENDMETHOD;

	// 						G E T   U N I T S
	/*
	Method: getUnits
	Returns all units of this garrison.

	Returns: Array of <Unit> objects.
	*/
	METHOD(getUnits)
		params [P_THISOBJECT];
		+SAFE_ACCESSOR("units", [])
	ENDMETHOD;

	// |                         G E T  I N F A N T R Y  U N I T S
	/*
	Method: getInfantryUnits
	Returns all infantry units.

	Returns: Array of units.
	*/
	METHOD(getInfantryUnits)
		params [P_THISOBJECT];
		SAFE_ACCESSOR("units", []) select { CALLM0(_x, "isInfantry") }
	ENDMETHOD;

	// |                         G E T  O F F I C E R  U N I T S
	/*
	Method: getOfficerUnits
	Returns only officer units.

	Returns: Array of officers.
	*/
	METHOD(getOfficerUnits)
		params [P_THISOBJECT];
		T_CALLM1("findUnits", [[T_INF ARG T_INF_officer]]);
	ENDMETHOD;

	// |                         G E T   V E H I C L E   U N I T S
	/*
	Method: getVehiucleUnits
	Returns all vehicle units.

	Returns: Array of units.
	*/
	METHOD(getVehicleUnits)
		params [P_THISOBJECT];
		SAFE_ACCESSOR("units", []) select { CALLM0(_x, "isVehicle") }
	ENDMETHOD;

	// |                         G E T   D R O N E   U N I T S
	/*
	Method: getVehicleUnits
	Returns all drone units.

	Returns: Array of units.
	*/
	METHOD(getDroneUnits)
		params [P_THISOBJECT];
		SAFE_ACCESSOR("units", []) select { CALLM0(_x, "isDrone") }
	ENDMETHOD;

	// |                         G E T   C A R G O   U N I T S
	/*
	Method: getCargoUnits
	Returns all cargo units.

	Returns: Array of units.
	*/
	METHOD(getCargoUnits)
		params [P_THISOBJECT];
		SAFE_ACCESSOR("units", []) select { CALLM0(_x, "isCargo") }
	ENDMETHOD;

	/*
	Method: getBuildResources

	Returns: number
	*/
	METHOD(getBuildResources)
		params [P_THISOBJECT, ["_forceUpdate", false]];

		private _buildRes = T_GETV("buildResources");

		//__MUTEX_LOCK;
		if (_buildRes == -1 || _forceUpdate) then {
			T_CALLM0("updateBuildResources");
			_buildRes = T_GETV("buildResources");
		};

		_buildRes
	ENDMETHOD;

	// This is rather computation-heavy
	// An internal function
	METHOD(_getBuildResources)
		params [P_THISOBJECT];

		private _return = 0;
		private _units = T_GETV("units");
		{
			_return = _return + CALLM0(_x, "getBuildResources");
		} forEach _units;

		_return
	ENDMETHOD;

	// Call this to update the buildResources variable
	// After this call, getBuildResources should be returning the most actual value
	METHOD(updateBuildResources)
		params [P_THISOBJECT];

		private _buildRes = T_CALLM0("_getBuildResources");
		T_SETV("buildResources", _buildRes);

		OOP_INFO_1("UPDATE BUILD RESOURCES: %1", _buildRes);

		// Notify GarrisonServer
		CALLM1(gGarrisonServer, "onGarrisonOutdated", _thisObject);
	ENDMETHOD;

	METHOD(addBuildResources)
		params [P_THISOBJECT, P_NUMBER("_value")];

		// Bail if number is negative
		if (_value <= 0) exitWith {};
		
		// Find units which can have build resources
		private _units = T_GETV("units") select {CALLM0(_x, "canHaveBuildResources")};

		// Bail if there are no units which can have build resources
		if (count _units == 0) exitWith {};

		private _valuePerUnit = ceil (_value / (count _units)); // Round the values a bit
		{
			CALLM1(_x, "addBuildResources", _valuePerUnit);
		} forEach _units;

		T_CALLM0("updateBuildResources");
	ENDMETHOD;

	METHOD(removeBuildResources)
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
	ENDMETHOD;

	METHOD(assignCargo)
		params [P_THISOBJECT, P_ARRAY("_cargo")];
		// Assign cargo to T_VEH_Cargo vehicles of the type specified, of the amount specified
		private _cargoVehicles = T_CALLM1("findUnits", [[T_VEH ARG T_VEH_truck_ammo]]);

		{
			private _unit = _x;
			CALLM1(_unit, "addToInventory", _cargo);
		} forEach _cargoVehicles;
	ENDMETHOD;

	METHOD(clearCargo)
		params [P_THISOBJECT];
		// Assign cargo to T_VEH_Cargo vehicles of the type specified, of the amount specified
		private _cargoVehicles = T_CALLM1("findUnits", [[T_VEH ARG T_VEH_truck_ammo]]);

		{
			private _unit = _x;
			CALLM0(_unit, "clearInventory");
		} forEach _cargoVehicles;
	ENDMETHOD;


	// 						G E T   P O S
	/*
	Method: getPos
	Returns the position of the garrison. It's the same as position world state property.

	Returns: Array
	*/
	METHOD(getPos)
		params [P_THISOBJECT];
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			[]
		};
		pr _AI = T_GETV("AI");
		+CALLM0(_AI, "getPos")
	ENDMETHOD;
	
	//						I S   E M P T Y
	/*
	Method: isEmpty
	Returns true if garrison is empty (has no units)

	Returns: Bool
	*/
	METHOD(isEmpty)
		params [P_THISOBJECT];
		count SAFE_ACCESSOR("units", []) == 0
	ENDMETHOD;

	//				I S   O N L Y   E M P T Y   V E H I C L E S
	/*
	Method: isOnlyEmptyVehicles
	Returns true if garrison contains only empty vehicles

	Returns: Bool
	*/
	METHOD(isOnlyEmptyVehicles)
		params [P_THISOBJECT];
		SAFE_ACCESSOR("countInf", []) == 0
	ENDMETHOD;

	//						I S   S P A W N E D
	/*
	Method: isSpawned
	Returns true if garrison is spawned

	Returns: Bool
	*/
	METHOD(isSpawned)
		params [P_THISOBJECT];
		SAFE_ACCESSOR("spawned", false)
	ENDMETHOD;
	

	//             F I N D   G R O U P S   B Y   T Y P E
	/*
	Method: findGroupsByType
	Finds groups in this garrison that have the same type as _type

	Parameters: _type

	_type - Number, one of <GROUP_TYPE>, or Array with such numbers

	Returns: Array with <Group> objects.
	*/
	METHOD(findGroupsByType)
		params [P_THISOBJECT, ["_types", 0, [0, []]]];

		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			[]
		};

		if (_types isEqualType 0) then {_types = [_types]};

		pr _groups = T_GETV("groups");
		pr _return = [];
		{
			if (CALLM0(_x, "getType") in _types) then {
				_return pushBack _x;
			};
		} forEach _groups;
		
		
		_return
	ENDMETHOD;

	/*
	Method: countAllUnits
	Returns: total number of units in this garrison.
	*/
	METHOD(countAllUnits)
		params [P_THISOBJECT];
		count SAFE_ACCESSOR("units", [])
	ENDMETHOD;

	/*
	Method: getTransportCapacity
	Count number of passenger seats available in all vehicles of the categories specified.
	Parameters: _vehicleCategories

	_vehicleCategories - Array of vehicle categories, defaults to T_VEH_ground_infantry_cargo
	Returns: number of seats available.
	*/
	METHOD(getTransportCapacity)
		params [P_THISOBJECT, P_ARRAY("_vehicleCategories")];

		SAFE_ACCESSOR("effTotal", T_EFF_null) # T_EFF_transport

		/*
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
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

		_transportCapacity
		*/
	ENDMETHOD;
	
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
	/* async */ METHOD(addUnit)
		params[P_THISOBJECT, P_OOP_OBJECT("_unit")];
		ASSERT_OBJECT_CLASS(_unit, "Unit");

		// Assert that the unit is valid (this function is called via message queue and as such the unit can become invalid)
		if (!IS_OOP_OBJECT(_unit) || {!CALLM0(_unit, "isValid")}) exitWith {
			OOP_ERROR_1("Attempt to add an invalid unit: %1", _unit);
		};

		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			nil
		};

		OOP_INFO_1("ADD UNIT: %1", _unit);

		ASSERT_THREAD(_thisObject);

		// If the unit is already in a garrison then remove it from there first
		private _unitGarrison = CALLM0(_unit, "getGarrison");
		OOP_INFO_1("  unit's garrison: %1", _unitGarrison);
		if(_unitGarrison != NULL_OBJECT) then {
			CALLM1(_unitGarrison, "removeUnit", _unit);
		};

		private _unitGroup = CALLM0(_unit, "getGroup");
		if (_unitGroup != NULL_OBJECT) then {
			diag_log format ["[Garrison::addUnit] Warning: adding a unit assigned to a group, garrison : %1, unit: %2: %3",
				T_GETV("name"), _unit, CALLM0(_unit, "getData")];
		};

		// Add the unit to the garrison before we spawn it so the state in spawn callbacks is consistent
		// (e.g. if they ask for the units garrison AI object it will be correct)
		private _units = T_GETV("units");
		_units pushBackUnique _unit;
		CALLM1(_unit, "setGarrison", _thisObject);
		
		// Update the cached composition and efficieny
		CALLM0(_unit, "getMainData") params ["_catID", "_subcatID", "_className"];
		T_CALLM3("increaseCounters", _catID, _subcatID, _className);

		// Spawn or despawn the unit if needed
		if (T_GETV("spawned")) then {
			pr _unitIsSpawned = CALLM0(_unit, "isSpawned");
			if (!_unitIsSpawned) then {
				pr _loc = T_GETV("location");
				if (_loc == NULL_OBJECT) then {
					pr _pos = T_CALLM0("getPos");
					pr _className = CALLM0(_unit, "getClassName");
					pr _posAndDir = CALLSM3("Location", "findSafePos", _pos, _className, 400);
					CALLM(_unit, "spawn", _posAndDir);
				} else {
					pr _unitData = CALLM0(_unit, "getMainData");
					pr _group = CALLM0(_unit, "getGroup");
					pr _groupType = if (_group != NULL_OBJECT) then {
						CALLM0(_group, "getType")
					} else {
						GROUP_TYPE_INF
					};
					pr _posAndDir = CALLM(_loc, "getSpawnPos", _unitData + [_groupType]);
					CALLM(_unit, "spawn", _posAndDir);
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
		if (_AI != NULL_OBJECT) then {
			CALLM1(_AI, "handleUnitsAdded", [_unit]);
			CALLM0(_AI, "updateComposition");
		};
 
		// Move all cargo of this unit too!
		pr _unitAI = CALLM0(_unit, "getAI");
		if (_unitAI != NULL_OBJECT) then {
			pr _unitCargo = CALLM0(_unitAI, "getCargoUnits");
			if(count _unitCargo > 0) then {
				T_CALLM1("addUnits", _unitCargo);
			};
		};

		// Notify GarrisonServer
		CALLM1(gGarrisonServer, "onGarrisonOutdated", _thisObject);

		__MUTEX_UNLOCK;

		nil
	ENDMETHOD;

	/*
	Method: assignUnits
	Same as assignUnits, but removes units from thier existing group.

	Parameters: _units

	_units - array of <Unit> object

	Returns: nil
	*/
	METHOD(assignUnits)
		params [P_THISOBJECT, P_ARRAY("_units")];
		// Remove the units from thier group
		{
			private _unit = _x;
			pr _unitGroup = CALLM0(_unit, "getGroup");
			if (_unitGroup != NULL_OBJECT) then {
				CALLM1(_unitGroup, "removeUnit", _unit);
			};
		} forEach _units;

		// Move the units into the players garrison
		T_CALLM1("addUnits", _units);
	ENDMETHOD;

	/*
	Method: takeUnits
	Same as takeUnits, but creates new groups for the units where required

	Parameters: _units

	_units - array of <Unit> object

	Returns: nil
	*/
	METHOD(takeUnits)
		params [P_THISOBJECT, P_OOP_OBJECT("_garSrc"), P_ARRAY("_units")];
		
		private _inf = _units select { CALLM0(_x, "getCategory") == T_INF };
		private _vehiclesStaticsAndDrones = _units select { CALLM0(_x, "getCategory") in [T_VEH, T_DRONE] };
		private _cargo = _units select { CALLM0(_x, "getCategory") == T_CARGO };

		private _statics = _vehiclesStaticsAndDrones select { CALLM0(_x, "getSubcategory") in T_VEH_static };
		private _vehiclesAndDrones = _vehiclesStaticsAndDrones - _statics;

		// Reorganize the infantry units we are moving
		if (count _inf > 0) then {
			_newGroup = NEW("Group", [T_GETV("side") ARG GROUP_TYPE_INF]);
			pr _newInfGroups = [_newGroup];
			CALLM1(_garSrc, "addGroup", _newGroup); // Add the new group to the src garrison first
			// forEach _inf;
			{
				// Create a new inf group if the current one is 'full'
				if (count CALLM0(_newGroup, "getUnits") > 6) then {
					_newGroup = NEW("Group", [T_GETV("side") ARG GROUP_TYPE_INF]);
					_newInfGroups pushBack _newGroup;
					CALLM1(_garSrc, "addGroup", _newGroup);
				};

				// Add the unit to the group
				CALLM1(_newGroup, "addUnit", _x);
			} forEach _inf;

			// Move all the infantry groups
			{
				T_CALLM1("addGroup", _x);
			} forEach _newInfGroups;
		};

		// Move all the vehicle units into one group
		// Vehicles need to be moved within a group too
		OOP_INFO_1("Moving vehicles and drones: %1", _vehiclesAndDrones);
		if (count _vehiclesAndDrones > 0) then {
			pr _newVehGroup = NEW("Group", [T_GETV("side") ARG GROUP_TYPE_VEH]);
			CALLM1(_garSrc, "addGroup", _newVehGroup);
			{
				CALLM1(_newVehGroup, "addUnit", _x);
			} forEach _vehiclesAndDrones;

			// Move the veh group
			T_CALLM1("addGroup", _newVehGroup);
		};

		// TODO: static groups?
		// We will keep cargo and statics not in groups for now
		T_CALLM1("assignUnits", _cargo + _statics);

		// Delete empty groups in the src garrison
		CALLM0(_garSrc, "deleteEmptyGroups");
	ENDMETHOD;

	/*
	Method: addUnits
	Same as addUnit, but for an array of units.

	Parameters: _units

	_units - array of <Unit> object

	Returns: nil
	*/
	METHOD(addUnits)
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
	ENDMETHOD;

	/*
	Method: captureUnit
	Same as addUnit, but also ungroups the unit if it's in a group. Should be used only on vehicles/cargo boxes.

	Threading: should be called through postMethod (see <MessageReceiverEx>)

	Parameters: _unit

	_unit - <Unit> object

	Returns: nil
	*/
	METHOD(captureUnit)
		params [P_THISOBJECT, P_OOP_OBJECT("_unit")];

		OOP_INFO_1("CAPTURE UNIT: %1", _unit);

		// Warn if used on infantry
		if (CALLM0(_unit, "isInfantry")) exitWith {
			OOP_ERROR_1("Capture unit must not be used for infantry units! Unit: %1", CALLM0(_unit, "getData"));
		};

		pr _group = CALLM0(_unit, "getGroup");

		// Ungroup the unit if it's in a group
		if (!IS_NULL_OBJECT(_group)) then {
			CALLM1(_group, "removeUnit", _unit);
		};

		T_CALLM1("addUnit", _unit);

	ENDMETHOD;

	/*
	Method: removeUnit
	Removes a unit from this garrison.
	Threading: should be called through postMethod (see <MessageReceiverEx>)

	Parameters: _unit

	_unit - <Unit> object

	Returns: nil
	*/
	/* async */ METHOD(removeUnit)
		params[P_THISOBJECT, P_OOP_OBJECT("_unit")];
		ASSERT_OBJECT_CLASS(_unit, "Unit");
		// Assert that the unit is valid (this function is called via message queue and as such the unit can become invalid)
		if (!IS_OOP_OBJECT(_unit) || {!CALLM0(_unit, "isValid")}) exitWith {
			OOP_ERROR_1("Attempt to add an invalid unit: %1", _unit);
		};

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
		if (_AI != NULL_OBJECT) then {
			CALLM1(_AI, "handleUnitsRemoved", [_unit]);
		};
		
		private _units = T_GETV("units");
		_units deleteAt (_units find _unit);

		// Set the garrison of this unit
		CALLM1(_unit, "setGarrison", "");
		
		// Notify the AI object after the unit is removed
		if(_AI != "") then {
			CALLM0(_AI, "updateComposition");
		};

		// Substract from the efficiency vector
		CALLM0(_unit, "getMainData") params ["_catID", "_subcatID", "_className"];
		T_CALLM3("decreaseCounters", _catID, _subcatID, _className);

		// Remove all cargo of this unit too!
		pr _unitAI = CALLM0(_unit, "getAI");
		if (_unitAI != NULL_OBJECT) then {
			pr _unitCargo = CALLM0(_unitAI, "getCargoUnits");
			{
				T_CALLM1("removeUnit", _x);
			} forEach _unitCargo;
		};

		// Notify GarrisonServer
		CALLM1(gGarrisonServer, "onGarrisonOutdated", _thisObject);

		__MUTEX_UNLOCK;

		nil
	ENDMETHOD;

	/*
	Method: addGroup
	Adds an existing group to this garrison. Also use it when you want to move a group to another garrison.

	Threading: should be called through postMethod (see <MessageReceiverEx>)

	Parameters: _group

	_unit - <Group> object

	Returns: nil
	*/
	/* async */ METHOD(addGroup)
		params[P_THISOBJECT, P_OOP_OBJECT("_group")];
		ASSERT_OBJECT_CLASS(_group, "Group");
		if (!IS_OOP_OBJECT(_group)) exitWith {
			OOP_ERROR_1("Attempt to add a non-existant group: %1", _group);
		};
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
		private _groupGarrison = CALLM0(_group, "getGarrison");
		if (_groupGarrison != "") then {
			// Remove the group from its previous garrison
			CALLM1(_groupGarrison, "removeGroup", _group);
		};

		// Add this group and its units to this garrison
		private _groupUnits = CALLM0(_group, "getUnits");
		private _units = T_GETV("units");
		{
			// Add to units array
			_units pushBackUnique _x;
			
			// Move all cargo of this unit too!
			pr _unitAI = CALLM0(_x, "getAI");
			if (_unitAI != "") then {
				pr _unitCargo = CALLM0(_unitAI, "getCargoUnits");
				{
					_units pushBackUnique _x;

					// Add to the efficiency vector
					CALLM0(_x, "getMainData") params ["_catID", "_subcatID", "_className"];
					T_CALLM3("increaseCounters", _catID, _subcatID, _className);
				} forEach _unitCargo;
			};

			// Add to the efficiency vector
			CALLM0(_x, "getMainData") params ["_catID", "_subcatID", "_className"];
			T_CALLM3("increaseCounters", _catID, _subcatID, _className);
		} forEach _groupUnits;
		private _groups = T_GETV("groups");
		_groups pushBackUnique _group;
		CALLM(_group, "setGarrison", [_thisObject]);

		// Spawn or despawn the units if needed
		if (T_GETV("spawned")) then {
			pr _groupIsSpawned = CALLM0(_group, "isSpawned");
			if (!_groupIsSpawned) then {
				pr _loc = T_GETV("location");
				if (_loc == "") then {
					pr _pos = T_CALLM0("getPos");
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
	ENDMETHOD;

	/*
	Method: removeGroup
	Removes an existing group from this garrison.
	You don't need to call this. Use addGroup when you need to move groups between garrisons.

	Parameters: _group

	_unit - <Group> object

	Returns: nil
	*/
	METHOD(removeGroup)
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
		pr _groupUnits = CALLM0(_group, "getUnits");
		pr _units = T_GETV("units");
		{
			_units deleteAt (_units find _x);

			// Remove all cargo of this unit too!
			pr _unitAI = CALLM0(_x, "getAI");
			if (_unitAI != "") then {
				pr _unitCargo = CALLM0(_unitAI, "getCargoUnits");
				{
					_units deleteAt (_units find _x);

					// Remove from the efficiency vector
					CALLM0(_x, "getMainData") params ["_catID", "_subcatID", "_className"];
					T_CALLM3("decreaseCounters", _catID, _subcatID, _className);
				} forEach _unitCargo;
			};
			
			// Substract from the efficiency vector
			CALLM0(_x, "getMainData") params ["_catID", "_subcatID", "_className"];
			T_CALLM3("decreaseCounters", _catID, _subcatID, _className);
				
		} forEach _groupUnits;
		pr _groups = T_GETV("groups");
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
	ENDMETHOD;

	/*
	Method: deleteEmptyGroups
	DeletesEmptyGroups in this garrison
	
	Returns: nil
	*/

	METHOD(deleteEmptyGroups)
		params [P_THISOBJECT];

		//ASSERT_THREAD(_thisObject);

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
	ENDMETHOD;

	/*
	Method: addGarrison
	Moves all units and groups from another garrison to this one.
	
	Parameters: _garrison
	
	_garrison - <Garrison> object
	
	Returns: nil
	*/
	
	METHOD(addGarrison)
		params[P_THISOBJECT, P_OOP_OBJECT("_garrison")];
		ASSERT_OBJECT_CLASS(_garrison, "Garrison");

		// This can be called async so we must check _garrison still exists
		if (!IS_OOP_OBJECT(_garrison)) exitWith {
			OOP_ERROR_1("Attempt to add a non-existant garrison: %1", _garrison);
		};

		// Bail if adding myself
		if (_thisObject == _garrison) exitWith {
			OOP_ERROR_0("Attempt to add garrison to itself");
		};
 
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			OOP_ERROR_0("addGarrison: this garrison is destroyed!");
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			nil
		};

		if(IS_GARRISON_DESTROYED(_garrison)) exitWith {
			OOP_ERROR_1("addGarrison: garrison is destroyed: %1", _garrison);
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			nil
		};

		ASSERT_THREAD(_thisObject);

		OOP_INFO_3("ADD GARRISON: %1, garrison groups: %2, garrison units: %3", _garrison, CALLM0(_garrison, "getGroups"), CALLM0(_garrison, "getUnits"));
		
		// Move all groups
		pr _groups = +CALLM0(_garrison, "getGroups");
		{
			T_CALLM1("addGroup", _x);
		} forEach _groups;
		
		// Move remaining units
		pr _units = +CALLM0(_garrison, "getUnits");
		{
			T_CALLM1("addUnit", _x);
		} forEach _units;
		
		// // Delete the other garrison if needed
		// if (_delete) then {
		// 	// TODO: we need to work out how to do this properly.
		// 	// DELETE(_garrison);
		// 	// HACK: Just unregister with AICommander for now so the model gets cleaned up
		// 	// CALLM0(_garrison, "destroy");
		// };

		// Merge intel and known locations
		pr _AI = T_GETV("AI");
		pr _otherAI = GETV(_garrison, "AI");
		CALLM1(_AI, "copyIntelFrom", _otherAI);

		__MUTEX_UNLOCK;
		
		nil
	ENDMETHOD;

	/*
	Method: capturesGarrison
	Captures all units from another garrison to this one. The other garrison must not have any infantry.
	See difference between <addUnit> and <captureUnit>.
	
	Parameters: _garrison, _destroy
	
	_garrison - <Garrison> object
	_destroy - bool, default true, will destroy the source garrison on success.
	
	Returns: nil
	*/
	METHOD(captureGarrison)
		params[P_THISOBJECT, P_OOP_OBJECT("_garrison"), P_BOOL_DEFAULT_TRUE("_destroy")];
		ASSERT_OBJECT_CLASS(_garrison, "Garrison");

		// This can be called async so we must check _garrison still exists
		if (!IS_OOP_OBJECT(_garrison)) exitWith {
			OOP_ERROR_1("Attempt to capture a non-existant garrison: %1", _garrison);
		};

		// Bail if captureing myself
		if (_thisObject == _garrison) exitWith {
			OOP_ERROR_0("Attempt to capture the same garrison");
		};

		__MUTEX_LOCK;

		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			OOP_ERROR_0("captureGarrison: this garrison is destroyed!");
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			nil
		};

		if(IS_GARRISON_DESTROYED(_garrison)) exitWith {
			OOP_ERROR_1("captureGarrison: garrison is destroyed: %1", _garrison);
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			nil
		};

		// Bail if source garrison has infantry
		if (GETV(_garrison, "countInf") > 0) exitWith {
			OOP_ERROR_1("Cant capture a garrison which has infantry: %1", _garrison);
		};

		// Capture all units
		pr _srcUnits = +GETV(_garrison, "units"); // Make a deep copy because this array will be modified!
		OOP_INFO_1("Capturing units: %1", _srcUnits);
		{
			T_CALLM1("captureUnit", _x);
		} forEach _srcUnits;

		// Notify players of what happened
		private _loc = CALLM0(_garrison, "getLocation");
		private _garrDesc = if(!IS_NULL_OBJECT(_loc)) then {
			format["at %1", CALLM0(_loc, "getDisplayName")]
		} else {
			private _pos = CALLM0(_garrison, "getPos");
			format["at %1", mapGridPosition _pos]
		};
		private _action = if(count _srcUnits > 0) then {
			"captured"
		} else {
			"destroyed"
		};

		private _args = ["GARRISON CAPTURED", format["Garrison %1 was %2 by enemy", _garrDesc, _action], "Garrisons must contain infantry"];
		REMOTE_EXEC_CALL_STATIC_METHOD("NotificationFactory", "createGarrisonNotification", _args, ON_CLIENTS, NO_JIP);

		// Destroy the source garrison
		if (_destroy) then {
			CALLSM2("AICommander", "unregisterGarrison", _garrison, true); // Unregister and destroy
		};

		__MUTEX_UNLOCK;

	ENDMETHOD;
	
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
	METHOD(addUnitsAndGroups)
		params [P_THISOBJECT, P_OOP_OBJECT("_garSrc"), P_ARRAY("_units"), P_ARRAY("_groupsAndUnits")];
		ASSERT_OBJECT_CLASS(_garSrc, "Garrison");

		// This can be called async so we must check _garrison still exists
		if (!IS_OOP_OBJECT(_garSrc)) exitWith {
			OOP_ERROR_1("Attempt to add units and groups from a non-existant garrison: %1", _garSrc);
		};

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
					pr _args = [_side, GROUP_TYPE_INF];
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
					pr _args = [_side, GROUP_TYPE_VEH]; // todo We assume we aren't moving static vehicles anywhere right now
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
			T_CALLM1("addGroup", _x);
		} forEach _newInfGroups;
		
		if (_newVehGroup != "") then {
			T_CALLM1("addGroup", _newVehGroup);
		};
		
		{
			pr _group = _x select 0;
			T_CALLM1("addGroup", _group);
		} forEach _groupsAndUnits;
		
		// Delete empty groups in the src garrison
		CALLM0(_garSrc, "deleteEmptyGroups");

		__MUTEX_UNLOCK;

		true
		
	ENDMETHOD;

	/*
	Method: addUnitsFromCompositionClassNames
	Adds units to this garrison from another garrison.
	Unit arrangement is specified by composition array with class names.

	Parameters: _garSrc, _comp
	
	_garSrc - source <Garrison>
	_comp - composition array. See "compositionClassNames" member variable and how it's organized.
	
	Returns: Number, amount of unsatisfied matches. 0 if all composition elements were matched.
	*/
	METHOD(addUnitsFromCompositionClassNames)
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

		//// Find units for each category
		//pr _unitsFound = [[], [], []];
		//_unitsFound params ["_unitsFoundInf", "_unitsFoundVeh", "_unitsFoundDrones"];
		// forEach [T_INF, T_VEH, T_DRONE];
		private _unitsFound = [];
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
						_unitsFound pushBack (_unitsSrc#_index); // Move to the array with found units
						_unitsSrc deleteAt _index;
						_unitsSrcData deleteAt _index;
					} else {
						// Increase the fail counter
						_numUnsat = _numUnsat + 1;
					};
				} forEach _classes;
			} forEach _comp#_catID;
		} forEach [T_INF, T_VEH, T_DRONE, T_CARGO];

		T_CALLM2("takeUnits", _garSrc, _unitsFound);
		// // Reorganize the infantry units we are moving
		// if (count _unitsFoundInf > 0) then {
		// 	_newGroup = NEW("Group", [T_GETV("side") ARG GROUP_TYPE_INF]);
		// 	pr _newInfGroups = [_newGroup];
		// 	CALLM1(_garSrc, "addGroup", _newGroup); // Add the new group to the src garrison first
		// 	// forEach _unitsFoundInf;
		// 	{
		// 		// Create a new inf group if the current one is 'full'
		// 		if (count CALLM0(_newGroup, "getUnits") > 6) then {
		// 			_newGroup = NEW("Group", [T_GETV("side") ARG GROUP_TYPE_INF]);
		// 			_newInfGroups pushBack _newGroup;
		// 			CALLM1(_garSrc, "addGroup", _newGroup);
		// 		};

		// 		// Add the unit to the group
		// 		CALLM1(_newGroup, "addUnit", _x);
		// 	} forEach _unitsFoundInf;

		// 	// Move all the infantry groups
		// 	{
		// 		T_CALLM1("addGroup", _x);
		// 	} forEach _newInfGroups;
		// };

		// // Move all the vehicle units into one group
		// // Vehicles need to be moved within a group too
		// pr _vehiclesAndDrones = _unitsFoundVeh + _unitsFoundDrones;
		// OOP_INFO_1("Moving vehicles and drones: %1", _vehiclesAndDrones);
		// if (count _vehiclesAndDrones > 0) then {
		// 	pr _newVehGroup = NEW("Group", [T_GETV("side") ARG GROUP_TYPE_VEH]); // todo we assume we aren't moving statics anywhere right now
		// 	CALLM1(_garSrc, "addGroup", _newVehGroup);
		// 	{
		// 		CALLM1(_newVehGroup, "addUnit", _x);
		// 	} forEach _vehiclesAndDrones;

		// 	// Move the veh group
		// 	T_CALLM1("addGroup", _newVehGroup);
		// };

		// // Delete empty groups in the src garrison
		// CALLM0(_garSrc, "deleteEmptyGroups");

		__MUTEX_UNLOCK;

		_numUnsat
	ENDMETHOD;
	
	/*
	Method: addUnitsFromCompositionNumbers
	Adds units to this garrison from another garrison.
	Unit arrangement is specified by composition array with numbers.

	Parameters: _garSrc, _comp
	
	_garSrc - source <Garrison>
	_comp - composition array. See "compositionNumbers" member variable and how it's organized.
	
	Returns: Bool, true if transfer was successfull.
	*/
	METHOD(addUnitsFromCompositionNumbers)
		params [P_THISOBJECT, P_OOP_OBJECT("_garSrc"), P_ARRAY("_comp")];

		OOP_INFO_1("ADD UNITS FROM COMPOSITION NUMBERS: %1", _this);

		// Bail if garSrc is destroyed for some reason
		if (!IS_OOP_OBJECT(_garSrc)) exitWith {
			OOP_ERROR_1("Source garrison object is invalid: %1", _garSrc);
			false
		};

		__MUTEX_LOCK;

		// Ensure that we have enough resources
		pr _compositionNumbers = GETV(_garSrc, "compositionNumbers");
		if (!([_compositionNumbers, _comp] call comp_fnc_greaterOrEqual)) exitWith {
			OOP_WARNING_1("Not enough resources to add units from composition: %1", _garSrc);
			OOP_WARNING_1("  Other garrison's composition: %1", _compositionNumbers);
			OOP_WARNING_1("  Required         composition: %1", _comp);
			__MUTEX_UNLOCK;
			false
		};

		pr _unitsSrc = +CALLM0(_garSrc, "getUnits"); // Make a deep copy! Don't want to break it.

		// Find units for each category
		pr _unitsFound = [[], [], [], []];
		_unitsFound params ["_unitsFoundInf", "_unitsFoundVeh", "_unitsFoundDrones", "_unitsFoundCargo"];
		pr _groupsUsed = [];

		{// forEach [T_INF, T_VEH, T_DRONE, T_CARGO];
			private _catID = _x;

			{// forEach _comp#_catID;
				private _nUnitsNeeded = _x;
				private _subcatID = _foreachindex;
				while { _nUnitsNeeded > 0 } do {
					// Prefer to take units from the same groups
					_unitsSrc = [_unitsSrc, {
						private _grp = CALLM0(_x, "getGroup");
						[_groupsUsed findIf { _grp == _x }, _x]
					}, DESCENDING] call pr0_fnc_sortBy;

					//  apply { 
					// 	private _grp = CALLM0(_x, "getGroup");
					// 	[_groupsUsed findIf { _grp == _x }, _x]
					// };
					// _unitsSrc sort ASCENDING;

					private _index = _unitsSrc findIf {
						private _mainData = CALLM0(_x, "getMainData");
						(_mainData#0 == _catID) && {_mainData#1 == _subCatID}
					};

					if (_index == NOT_FOUND) exitWith { OOP_ERROR_0("addUnitsFromCompositionNumbers Failed to find a unit?!") }; // WTF it should not happen, we have just verified that

					private _unit = _unitsSrc#_index;
					_groupsUsed pushBackUnique CALLM0(_unit, "getGroup");
					_unitsFound#_catID pushBack _unit;
					_unitsSrc deleteAt _index;
					_nUnitsNeeded = _nUnitsNeeded - 1;
				};
			} forEach (_comp#_catID);
		} forEach [T_INF, T_VEH, T_DRONE, T_CARGO];

		// Reorganize the infantry units we are moving
		if (count _unitsFoundInf > 0) then {
			_newGroup = NEW("Group", [T_GETV("side") ARG GROUP_TYPE_INF]);
			pr _newInfGroups = [_newGroup];
			CALLM1(_garSrc, "addGroup", _newGroup); // Add the new group to the src garrison first
			// forEach _unitsFoundInf;
			{
				// Create a new inf group if the current one is 'full'
				if (count CALLM0(_newGroup, "getUnits") > 6) then {
					_newGroup = NEW("Group", [T_GETV("side") ARG GROUP_TYPE_INF]);
					_newInfGroups pushBack _newGroup;
					CALLM1(_garSrc, "addGroup", _newGroup);
				};

				// Add the unit to the group
				CALLM1(_newGroup, "addUnit", _x);
			} forEach _unitsFoundInf;

			// Move all the infantry groups
			{
				T_CALLM1("addGroup", _x);
			} forEach _newInfGroups;
		};

		// Move all the vehicle units into one group
		// Vehicles need to be moved within a group too
		pr _vehiclesAndDrones = _unitsFoundVeh + _unitsFoundDrones;
		OOP_INFO_1("Moving vehicles and drones: %1", _vehiclesAndDrones);
		if (count _vehiclesAndDrones > 0) then {
			pr _newVehGroup = NEW("Group", [T_GETV("side") ARG GROUP_TYPE_VEH]); // todo we assume we aren't moving statics anywhere right now
			CALLM1(_garSrc, "addGroup", _newVehGroup);
			{
				CALLM1(_newVehGroup, "addUnit", _x);
			} forEach _vehiclesAndDrones;

			// Move the veh group
			T_CALLM1("addGroup", _newVehGroup);
		};

		// Delete empty groups in the src garrison
		CALLM0(_garSrc, "deleteEmptyGroups");

		__MUTEX_UNLOCK;

		true
	ENDMETHOD;
	
	/*
	Method: getRequiredCrew
	Returns amount of needed drivers and turret operators for all vehicles in this garrison.

	Returns: [_nDrivers, _nTurrets]
	*/

	METHOD(getRequiredCrew)
		params [P_THISOBJECT];
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			[]
		};
		pr _units = T_GETV("units");
		CALLSM1("Unit", "getRequiredCrew", _units)
	ENDMETHOD;
	
	/*
	Method: mergeVehicleGroups
	Ensure all non-static vehicles are in one group.
	It merges any existing non-static vehicle groups, and moves any non-static vehicles
	not in vehicle groups into the one vehicle group.
	*/
	METHOD(mergeVehicleGroups)
		params [P_THISOBJECT];

		ASSERT_THREAD(_thisObject);
		
		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
		};

		// Find all vehicle groups
		pr _vehGroups = T_CALLM1("findGroupsByType", GROUP_TYPE_VEH);
		pr _destGroup = _vehGroups select 0;

		// If there are no vehicle groups, create one right now
		if (isNil "_destGroup") then {
			pr _args = [T_CALLM0("getSide"), GROUP_TYPE_VEH];
			_destGroup = NEW("Group", _args);
			CALLM0(_destGroup, "spawnAtLocation");
			T_CALLM1("addGroup", _destGroup);
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

		// Also move ungrouped vehicles, or those in non-vehicle groups
		pr _vehicleUnits = T_CALLM0("getVehicleUnits");
		{
			pr _vehGroup = CALLM0(_x, "getGroup");
			if (_vehGroup != _destGroup 
				&& {
					IS_NULL_OBJECT(_vehGroup) 
					||
					{!(CALLM0(_vehGroup, "getType") in [GROUP_TYPE_VEH, GROUP_TYPE_STATIC])}
				}
			) then {
				CALLM1(_destGroup, "addUnit", _x);
			};
		} forEach _vehicleUnits;

		__MUTEX_UNLOCK;
		
		nil
	ENDMETHOD;

	/*
	Method: splitVehicleGroups
	Splits all existing vehicle groups so that each group contains only one vehicle and its crew.
	*/
	METHOD(splitVehicleGroups)
		params [P_THISOBJECT];

		ASSERT_THREAD(_thisObject);
		
		__MUTEX_LOCK;

		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
		};

		// Find all vehicle groups
		pr _vehGroups = T_CALLM1("findGroupsByType", GROUP_TYPE_VEH);

		// Split every vehicle group
		{
			pr _group = _x;
			pr _groupVehicles = CALLM0(_group, "getUnits") select { CALLM0(_x, "isVehicle") };

			// If there are more than one vehicle
			if (count _groupVehicles > 1) then {
				// Temporarily stop the AI object of the group because it can perform vehicle assignments in the other thread.
				// Event handlers when units are destroyed are disposed from this thread anyway.
				pr _groupAI = CALLM0(_group, "getAI");
				if (!IS_NULL_OBJECT(_groupAI)) then {
					CALLM2(_groupAI, "postMethodSync", "stop",  []);
				};

				// Create a new group per every vehicle (except for the first one)
				pr _side = CALLM0(_group, "getSide");
				for "_i" from 1 to ((count _groupVehicles) - 1) do {
					pr _vehicle = _groupVehicles select _i;
					pr _vehAI = CALLM0(_vehicle, "getAI");

					// Create a group, add it to the garrison
					pr _args = [_side, GROUP_TYPE_VEH];
					pr _newGroup = NEW("Group", _args);
					CALLM0(_newGroup, "spawnAtLocation");
					T_CALLM1("addGroup", _newGroup);

					// Get crew of this vehicle
					if (!IS_NULL_OBJECT(_vehAI)) then {
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
				if (!IS_NULL_OBJECT(_groupAI)) then {
					CALLM2(_groupAI, "postMethodSync", "start",  []);
				};
			};
		} forEach _vehGroups;

		__MUTEX_UNLOCK;

		nil
	ENDMETHOD;

	// Method: rebalanceGroups
	// Attempt to fully rebalance groups.
	// All vehicle groups will be assigned crew, remaining inf will be split into regular groups.
	METHOD(rebalanceGroups)
		params [P_THISOBJECT];
		
		// ===== Ensure all vehicles are manned first =====
		// Create a pool of units we can use to fill vehicle slots
		pr _freeUnits = [];
		pr _freeGroups = T_CALLM1("findGroupsByType", GROUP_TYPE_INF);// select { CALLM0(_x, "isLanded") };
		{
			_freeUnits append CALLM0(_x, "getUnits");
		} forEach _freeGroups;

		pr _vehGroups = T_CALLM1("findGroupsByType", [GROUP_TYPE_VEH ARG GROUP_TYPE_STATIC]);// select { CALLM0(_x, "isLanded") };

		// We can also take units from vehicle turrets if we really need it
		{// forEach _vehGroups;
			pr _group = _x;
			CALLM0(_group, "getRequiredCrew") params ["_nDrivers", "_nTurrets"];
			pr _infUnits = CALLM0(_x, "getInfantryUnits");
			while {(count _infUnits) > _nDrivers} do { // Just add all the units except for drivers
				_freeUnits pushBack (_infUnits deleteAt ((count _infUnits) - 1));
			};
		} forEach _vehGroups;

		OOP_INFO_2("Vehicle groups: %1, free units: %2", _vehGroups, _freeUnits);
		
		// Try to add drivers and turret operators to all groups
		{// foreach _vehGroups
			pr _group = _x;
			CALLM0(_group, "getRequiredCrew") params ["_nDrivers", "_nTurrets"];
			pr _infUnits = CALLM0(_x, "getInfantryUnits");
			//pr _nInf = count _infUnits;
			
			OOP_INFO_3("Analyzing vehicle group: %1, required drivers: %2, required turret operators: %3", _group, _nDrivers, _nTurrets);
			
			pr _nMoreUnitsRequired = _nDrivers + _nTurrets - count _infUnits;
			if (_nMoreUnitsRequired > 0) then {
				while {_nMoreUnitsRequired > 0 && (count _freeUnits > 0)} do {
					CALLM1(_group, "addUnit", _freeUnits deleteAt 0);
					_nMoreUnitsRequired = _nMoreUnitsRequired - 1;
				};
			} else {
				// If there are more units than we need in this group
				if (_nMoreUnitsRequired < 0) then {
					// Move the not needed units into any of the other groups
					pr _receivingGroup = _freeGroups select 0;
					if (isNil "_receivingGroup") then {
						pr _args = [CALLM0(_group, "getSide"), GROUP_TYPE_INF];
						_receivingGroup = NEW("Group", _args);
						//CALLM0(_receivingGroup, "spawnAtLocation");
						T_CALLM1("addGroup", _receivingGroup);
						_freeGroups pushBack _receivingGroup;
					};
					
					// Move the units
					//pr _groupUnits = CALLM0(_group, "getUnits");
					while { _nMoreUnitsRequired < 0 && {count _infUnits > 0} } do {
						CALLM1(_receivingGroup, "addUnit", _infUnits deleteAt 0);
						_nMoreUnitsRequired = _nMoreUnitsRequired + 1;
					};
				};
			};
			
			/*
			pr _nMoreDriversRequired = _nDrivers - _nInf;
			if (_nMoreDriversRequired > 0) then {
				while {_nMoreDriversRequired > 0 && (count _freeUnits > 0)} do {
					CALLM1(_group, "addUnit", _freeUnits deleteAt 0);
					_nMoreDriversRequired = _nMoreDriversRequired - 1;
				};
			};
			*/
		} forEach _vehGroups;
		
		// Try to add turret operators to all groups
		{// foreach _vehGroups
			pr _group = _x;
			CALLM0(_group, "getRequiredCrew") params ["_nDrivers", "_nTurrets"];
			pr _nInf = count CALLM0(_group, "getInfantryUnits");
			
			pr _nTurretOperatorsRequired = _nTurrets - _nInf - _nDrivers;
			
			if (_nTurretOperatorsRequired > 0) then {
				while {_nTurretOperatorsRequired > 0 && (count _freeUnits > 0)} do {
					CALLM1(_group, "addUnit", _freeUnits deleteAt 0);
					_nTurretOperatorsRequired = _nTurretOperatorsRequired - 1;
				};
			} else {
				
			};
		} forEach _vehGroups;

		// Delete empty groups
		T_CALLM0("deleteEmptyGroups");

		#define DESIRED_GROUP_SIZE 6
		// ===== Now rebalance remaining inf into effective squads =====
		pr _infGroups = T_CALLM1("findGroupsByType", GROUP_TYPE_INF)
		 // select { CALLM0(_x, "isLanded") }
		 apply {
			[
				CALLM0(_x, "getUnits"),
				_x
			]
		};
		pr _tooBig = _infGroups select { count (_x#0) > DESIRED_GROUP_SIZE };
		pr _tooSmall = _infGroups select { count (_x#0) < DESIRED_GROUP_SIZE };
		pr _side = T_CALLM0("getSide");

		// Take parts of groups that are too big and join them to smaller (or new empty) groups
		{// forEach _tooBig;
			_x params ["_srcUnits", "_srcGrp"];
			pr _spareUnits = _srcUnits select [6, count _srcUnits];
			while { count _spareUnits > 0 } do {
				if(count _tooSmall == 0) then {
					// create a new group
					pr _args = [
						_side,
						GROUP_TYPE_INF
					];
					pr _newGroup = NEW("Group", _args);
					CALLM0(_newGroup, "spawnAtLocation");
					T_CALLM1("addGroup", _newGroup);
					_tooSmall pushBack [[], _newGroup];
				};
				(_tooSmall#0) params ["_tgtUnits", "_tgtGrp"];
				pr _numToAssign = (count _spareUnits) min (DESIRED_GROUP_SIZE - count _tgtUnits);
				pr _unitsToAssign = _spareUnits select [0, _numToAssign];
				_spareUnits = _spareUnits select [_numToAssign, count _spareUnits];
				CALLM1(_tgtGrp, "addUnits", _unitsToAssign);
				_tgtUnits append _unitsToAssign;
				if(count _tgtUnits >= DESIRED_GROUP_SIZE ) then {
					_tooSmall deleteAt 0;
				};
			};
		} forEach _tooBig;

		// Take groups that are too small and merge them
		while { count _tooSmall > 1 } do {
			_tooSmall#0 params ["_srcUnits", "_srcGrp"];
			while { count _srcUnits > 0 && { count _tooSmall > 1 } } do {
				(_tooSmall#1) params ["_tgtUnits", "_tgtGrp"];
				pr _numToAssign = (count _srcUnits) min (DESIRED_GROUP_SIZE - count _tgtUnits);
				pr _unitsToAssign = _srcUnits select [0, _numToAssign];
				_srcUnits = _srcUnits select [_numToAssign, count _srcUnits];
				CALLM1(_tgtGrp, "addUnits", _unitsToAssign);
				_tgtUnits append _unitsToAssign;
				if(count _tgtUnits >= DESIRED_GROUP_SIZE ) then {
					_tooSmall deleteAt 1;
				};
			};
		};

		// Delete empty groups once more
		T_CALLM0("deleteEmptyGroups");

		// Cleanup vehicle assignments for groups if garrison is spawned
		// This is a hack to stop units from automatically changing vehicles all the time
		if(T_CALLM0("isSpawned")) then {
			pr _allVehicles = T_CALLM0("getVehicleUnits") apply { CALLM0(_x, "getObjectHandle") };
			{
				pr _groupVehicles = CALLM0(_x, "getVehicleUnits") apply { CALLM0(_x, "getObjectHandle") };
				pr _groupHandle = CALLM0(_x, "getGroupHandle");
				{
					_groupHandle leaveVehicle _x;
				} forEach (_allVehicles - _groupVehicles); // Don't unassign the groups ones, we don't want all the crew getting kicked out
			} forEach (T_CALLM0("getGroups") select {
				CALLM0(_x, "isLanded")
			});
		};
	ENDMETHOD;
	
	/*
	Method: increaseCounters
	Adds values to efficiency vector and other counters
	
	Private use!
	
	Returns: nil
	*/
	METHOD(increaseCounters)
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
		pr _comp = T_GETV("compositionClassNames");
		(_comp#_catID#_subCatID) pushBack ([_className] call t_fnc_classNameToNumber);

		pr _compNumbers = T_GETV("compositionNumbers");
		[_compNumbers, _catID, _subcatID, 1] call comp_fnc_addValue;

		__MUTEX_UNLOCK;
	ENDMETHOD;

	/*
	Method: _recalculateCounters
	Recalculates efficiency vector and other counters from scratch,
	used during loading.
	
	Private use!
	
	Returns: nil
	*/
	METHOD(_recalculateCounters)
		params [P_THISOBJECT];

		T_SETV("effTotal", +T_EFF_null);
		T_SETV("effMobile", +T_EFF_null);
		T_SETV("countInf", 0);
		T_SETV("countVeh", 0);
		T_SETV("countDrone", 0);
		T_SETV("countCargo", 0);

		pr _comp = [];
		{
			pr _tempArray = [];
			_tempArray resize _x;
			_comp pushBack (_tempArray apply {[]});
		} forEach [T_INF_SIZE, T_VEH_SIZE, T_DRONE_SIZE, T_CARGO_SIZE];
		T_SETV("compositionClassNames", _comp);
		T_SETV("compositionNumbers", +T_comp_null);

		{
			// Add to the efficiency vector
			CALLM0(_x, "getMainData") params ["_catID", "_subcatID", "_className"];
			T_CALLM3("increaseCounters", _catID, _subcatID, _className);
		} forEach T_GETV("units");
	ENDMETHOD;
	
	/*
	Method: subEfficiency
	Substracts values from efficiency vector and other counters
	
	Private use!
	
	Returns: nil
	*/
	METHOD(decreaseCounters)
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
		pr _comp = T_GETV("compositionClassNames");
		pr _array = _comp#_catID#_subCatID;
		_array deleteAt (_array find ([_className] call t_fnc_classNameToNumber));

		pr _compNumbers = T_GETV("compositionNumbers");
		[_compNumbers, _catID, _subcatID, -1] call comp_fnc_addValue;

		__MUTEX_UNLOCK;
	ENDMETHOD;
	
	/*
	Method: getEfficiencyMobile
	Returns efficiency of all mobile units
	
	Returns: Efficiency vector
	*/
	
	METHOD(getEfficiencyMobile)
		params [P_THISOBJECT];
		+SAFE_ACCESSOR("effMobile", T_EFF_null)
	ENDMETHOD;
	
	/*
	Method: getEfficiencyTotal
	Returns efficiency of all mobile units
	
	Returns: Efficiency vector
	*/
	
	METHOD(getEfficiencyTotal)
		params [P_THISOBJECT];
		+SAFE_ACCESSOR("effTotal", T_EFF_null)
	ENDMETHOD;

	METHOD(getCompositionClassNames)
		params [P_THISOBJECT];
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			pr _comp = [];
			{
				pr _tempArray = [];
				_tempArray resize _x;
				_comp pushBack (_tempArray apply {[]});
			} forEach [T_INF_SIZE, T_VEH_SIZE, T_DRONE_SIZE, T_CARGO_SIZE];
			_comp
		};
		+T_GETV("compositionClassNames")
	ENDMETHOD;

	METHOD(getCompositionNumbers)
		params [P_THISOBJECT];
		+SAFE_ACCESSOR("compositionNumbers", [0] call comp_fnc_new)
	ENDMETHOD;

	// ---------------------------------------------------------------
	//  G O A P
	// ---------------------------------------------------------------

	//            G E T   S U B A G E N T S
	/*
	Method: getSubagents
	Returns subagents of this agent.
	For garrison it returns an empty array, because the subagents of garrison (groups) are processed in a separate thread.

	Access: Used by AI class

	Returns: [].
	*/
	METHOD(getSubagents)
		[]
	ENDMETHOD;

	// 						G E T   A I
	/*
	Method: getAI
	Returns the AI object of this garrison.

	Returns: Array of <Unit> objects.
	*/
	METHOD(getAI)
		params [P_THISOBJECT];
		SAFE_ACCESSOR("AI", NULL_OBJECT)
	ENDMETHOD;


	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// |                                E V E N T   H A N D L E R S
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


	METHOD(handleGroupRemoved)
	ENDMETHOD;


	// |                 H A N D L E   U N I T   K I L L E D                |
	/*
	Method: handleUnitKilled
	Called when the unit has been killed.

	Must be called inside the garrison thread through postMethodAsync, not inside event handler.

	Returns: nil
	*/
	METHOD(handleUnitKilled)
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

		// If its a player leading an AI group with no other players in it then release the group back to the AI commander
		if(CALLM0(_unit, "isPlayer")) then {
			private _unitHandle = CALLM0(_unit, "getObjectHandle");
			private _group = group _unitHandle;
			// If there are no other players in the group then release the AI units back to the AI commander
			if((units _group findIf { _x != _unitHandle && _x in allPlayers }) == NOT_FOUND) then {
				// Remove player from the group
				[_unitHandle] joinSilent grpNull;

				// // Move units to a new garrison
				// // Make a new garrison
				// private _actual = _thisObject;
				// private _side = T_CALLM0("getSide");
				// private _type = T_CALLM0("getType");
				// private _faction = T_CALLM0("getFaction");
				// private _templateName = T_CALLM0("getTemplateName");
				// private _newGarr = NEW("Garrison", [_type ARG _side ARG [] ARG _faction ARG _templateName]);
				// private _pos = T_CALLM0("getPos");
				// CALLM2(_newGarr, "postMethodAsync", "setPos", [_pos]);
				// // Add the units to the garrison in a new group
				// private _newGroup = NEW("Group", [_side ARG GROUP_TYPE_INF]);
				// CALLM1(_newGarr, "addGroup", _newGroup); // Add the new group to the src garrison first
				// {
				// 	CALLM1(_newGroup, "addUnit", _x);
				// } forEach (units _group apply { 
				// 	CALL_STATIC_METHOD("Unit", "getUnitFromObjectHandle", [_objectHandle]) 
				// } select {
				// 	!IS_NULL_OBJECT(_x)
				// });
				// CALLM0(_newGarr, "activate");
			};
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
		T_CALLM1("removeUnit", _unit);

		// Add the unit to the garbage collector
		CALLM1(gGarbageCollector, "addUnit", _unit);

		__MUTEX_UNLOCK;
	ENDMETHOD;

	/*
	Method: handleGetInVehicle
	Called when someone enters a vehicle that belongs to this garrison.

	Must be called inside the garrison thread through postMethodAsync, not inside event handler.

	Parameters: _unitVeh, _unitInf

	_unitVeh - the vehicle
	_unitInf - the unit that entered the vehicle

	Returns: nil
	*/

	METHOD(handleGetInVehicle)
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

		// Get the inf handle, we only auto detach vics (which is all this function does) by player action
		private _infHandle = CALLM0(_unitInf, "getObjectHandle");
		if(isNull _infHandle or {!isPlayer _infHandle}) exitWith {
			__MUTEX_UNLOCK;
		};

		// Get garrison of the unit that entered the vehicle
		private _garDest = CALLM0(_unitInf, "getGarrison");
		if (_garDest == NULL_OBJECT) then {
			// Shouldn't be possible...
			_garDest = gGarrisonAmbient;
		};

		// Check garrison of the unit that entered this vehicle
		if (_garDest != _thisObject) then {
			// Remove the vehicle from its group
			private _vehGroup = CALLM0(_unitVeh, "getGroup");
			if (_vehGroup != NULL_OBJECT) then {
				CALLM1(_vehGroup, "removeUnit", _unitVeh);
			};

			// Move the vehicle into the other garrison
			CALLM1(_garDest, "addUnit", _unitVeh);

			private _vicHandle = CALLM0(_unitVeh, "getObjectHandle");

			private _location = T_CALLM0("getLocation");
			private _msg = if(_location != NULL_OBJECT) then {
				format["%1 was automatically detached from garrison at %2", getText (configFile >> "cfgVehicles" >> typeOf _vicHandle >> "displayName"), CALLM0(_location, "getDisplayName")]
			} else {
				format["%1 was automatically detached from garrison", getText (configFile >> "cfgVehicles" >> typeOf _vicHandle >> "displayName")]
			};

			private _ourSide = T_CALLM0("getSide");

			// Notify nearby players of what happened
			private _nearbyClients = allPlayers select {side group _x == _ourSide && (_x distance _vicHandle) < 100} apply { owner _x };
			private _args = ["VEHICLE DETACHED", _msg, "It will be no longer be saved here"];
			REMOTE_EXEC_CALL_STATIC_METHOD("NotificationFactory", "createResourceNotification", _args, _nearbyClients, NO_JIP);
			OOP_INFO_0(_msg);

			private _newSide = CALLM0(_garDest, "getSide");
			if(_newSide != _ourSide) then {
				// Send stimulus to garrison's casualties sensor if we are losing the vehicle to another side
				// We consider it destruction of the vehicle
				private _garAI = T_CALLM0("getAI");
				if (!IS_NULL_OBJECT(_garAI)) then {
					private _stim = STIMULUS_NEW();
					STIMULUS_SET_TYPE(_stim, STIMULUS_TYPE_UNIT_DESTROYED);
					private _value = [_unitVeh, _infHandle];
					STIMULUS_SET_VALUE(_stim, _value);
					CALLM2(_garAI, "postMethodAsync", "handleStimulus", [_stim]);
				};
			};
		};
		__MUTEX_UNLOCK;
	ENDMETHOD;

	/*
	Method: handleGetOutVehicle
	Called when someone leaves a vehicle that belongs to this garrison.

	Must be called inside the garrison thread through postMethodAsync, not inside event handler.

	Parameters: _unitVeh, _unitInf

	_unitVeh - the vehicle
	_unitInf - the unit that left the vehicle

	Returns: nil
	*/
	METHOD(handleGetOutVehicle)
		params [P_THISOBJECT, P_OOP_OBJECT("_unitVeh"), P_OOP_OBJECT("_unitInf")];
		ASSERT_OBJECT_CLASS(_unitVeh, "Unit");
		ASSERT_OBJECT_CLASS(_unitInf, "Unit");

		OOP_INFO_2("HANDLE UNIT GET OUT VEHICLE: %1, %2", _unitVeh, _unitInf);

		ASSERT_THREAD(_thisObject);

		__MUTEX_LOCK;

		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
		};

		// Get the inf handle, we only auto attach vics (which is all this function does) by player action
		pr _infHandle = CALLM0(_unitInf, "getObjectHandle");
		if(isNull _infHandle or {!isPlayer _infHandle}) exitWith {
			__MUTEX_UNLOCK;
		};

		// If the unit is the last one to leave the vehicle then we might
		// assign the vehicle to the nearest locations garrison, if we are 
		// at a location
		pr _vicHandle = CALLM0(_unitVeh, "getObjectHandle");
		if(isNull _vicHandle) exitWith {
			__MUTEX_UNLOCK;
			pr _data = CALLM0(_unitVeh, "getData");
			OOP_ERROR_2("handleGetOutVehicle: vehicle unit doesn't have valid arma handle: %1, %2", _unitVeh, _data);
		};

		// Players remain in the vehicle so we don't change the owner
		if ({ isPlayer _x } count (crew _vicHandle) != 0) exitWith { __MUTEX_UNLOCK; };

		private _infSide = side group _infHandle;

		// Find nearest appropriate garrison
		// Use the side of the inf unit not the garrison, as the garrison isn't necessarily the same side as the unit
		pr _ourLocs = CALLSM1("Location", "getLocationsAtPos", getPos _vicHandle) apply {
			[getPos _vicHandle distance CALLM0(_x, "getPos"), _x, CALLM1(_x, "getGarrisons", _infSide)]
		} select {
			// garrisons exist
			count (_x#2) > 0
		};

		// No friendly location found
		if(count _ourLocs == 0) exitWith { 
			__MUTEX_UNLOCK;
		};

		// Get closest one
		_ourLocs sort ASCENDING;
		_ourLocs#0 params ["_dist", "_nearestLocation", "_ourGarrisons"];

		// Get garrison of the location
		pr _garDest = _ourGarrisons#0;

		// This can't really happen if _thisObject is always the ambient garrison, but may as well check
		if (_garDest != _thisObject) then {
			// Remove the vehicle from its group
			pr _vehGroup = CALLM0(_unitVeh, "getGroup");
			if (_vehGroup != NULL_OBJECT) then {
				CALLM1(_vehGroup, "removeUnit", _unitVeh);
			};

			// Move the vehicle into the other garrison
			CALLM1(_garDest, "addUnit", _unitVeh);

			// Find nearest appropriate garrison
			// Notify nearby players of what happened if its on player side
			pr _nearbyClients = allPlayers select {side group _x == _infSide && (_x distance _vicHandle) < 100} apply { owner _x };

			private _args = ["VEHICLE ATTACHED", format["%1 was automatically attached to garrison at %2", 
				getText (configFile >> "cfgVehicles" >> typeOf _vicHandle >> "displayName"),
				CALLM0(_nearestLocation, "getDisplayName")
			], "It will be saved here"];
			REMOTE_EXEC_CALL_STATIC_METHOD("NotificationFactory", "createResourceNotification", _args, _nearbyClients, NO_JIP);
			OOP_INFO_0(_msg);
		};
		__MUTEX_UNLOCK;
	ENDMETHOD;

	/*
	Method: handleCargoLoaded
	Called when someone loads a cargo unit that belongs to this garrison.

	Must be called inside the garrison thread through postMethodAsync, not inside event handler.

	Parameters: _unitCargo, _unitVehicle

	_unitCargo - the cargo item (static gun or cargo box or whatever) which was loaded
	_unitVehicle - the vehicle unit into which the cargo was loaded

	Returns: nil
	*/
	METHOD(handleCargoLoaded)
		params [P_THISOBJECT, P_OOP_OBJECT("_unitCargo"), P_OOP_OBJECT("_unitVeh")];

		ASSERT_OBJECT_CLASS(_unitCargo, "Unit");
		ASSERT_OBJECT_CLASS(_unitVeh, "Unit");

		OOP_INFO_2("HANDLE CARGO LOADED: %1, %2", _unitCargo, _unitVeh);

		ASSERT_THREAD(_thisObject);

		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
		};

		// Get garrison of the vehicle into which cargo was loaded
		pr _garDest = CALLM0(_unitVeh, "getGarrison");
		if (_garDest == "") then {
			_garDest = gGarrisonAmbient;
			OOP_ERROR_2("handleCargoLoaded: vehicle has no garrison: %1, %2", _unitVeh, CALLM0(_unitVeh, "getData"));
		};

		// Remove the cargo from its group
		pr _cargoGroup = CALLM0(_unitCargo, "getGroup");
		if (_cargoGroup != "") then {
			CALLM1(_cargoGroup, "removeUnit", _unitCargo);
		};

		// Check garrison of the destination vehicle
		if (_garDest != _thisObject) then {

			// Move the vehicle into the other garrison
			CALLM1(_garDest, "addUnit", _unitCargo);
		};

		// Call destination unit's specific function
		CALLM1(_unitVeh, "handleCargoLoaded", _unitCargo);
		__MUTEX_UNLOCK;
	ENDMETHOD;

	METHOD(handleCargoUnloaded)
		params [P_THISOBJECT, P_OOP_OBJECT("_unitCargo"), P_OOP_OBJECT("_unitVeh")];

		ASSERT_OBJECT_CLASS(_unitCargo, "Unit");
		ASSERT_OBJECT_CLASS(_unitVeh, "Unit");

		OOP_INFO_2("HANDLE CARGO UNLOADED: %1, %2", _unitCargo, _unitVeh);

		__MUTEX_LOCK;
		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
		};

		// Cargo's garrison doesn't need to change when it is unloaded, so we don't really need to do much here

		// Call destination unit's specific function
		CALLM1(_unitVeh, "handleCargoUnloaded", _unitCargo);
		__MUTEX_UNLOCK;
	ENDMETHOD;

	/*
	Method: findUnits
	Returns an array of units with specified category and subcategory

	Parameters: _query

	_query - array of [_catID, _subcatID].
	_subcatID can be -1 if you don't care about a subcategory match.

	Returns: Array of units <Unit> class
	*/
	METHOD(findUnits)
		params [P_THISOBJECT, P_ARRAY("_query")];

		__MUTEX_LOCK;

		// Call this INSIDE the lock so we don't have race conditions
		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			WARN_GARRISON_DESTROYED;
			__MUTEX_UNLOCK;
			[]
		};

		pr _return = [];
		pr _units = T_GETV("units");
		{ // for each _query
			_x params ["_catID", "_subcatID"];
			{ // for each _units
				pr _unit = _x;
				pr _mainData = CALLM0(_unit, "getMainData");
				_mainData params ["_catIDx", "_subcatIDx"];
				if (_catIDx == _catID && (_subcatIDx == _subcatID || _subcatID == -1)) then { _return pushBack _unit; };
			} forEach _units;
		} forEach _query;

		__MUTEX_UNLOCK;
		_return
	ENDMETHOD;
	
	/*
	Method: countUnits
	Counts amount of units with specified category and subcategory

	Parameters: _query

	_query - array of [_catID, _subcatID].
	_subcatID can be -1 if you don't care about a subcategory match.

	Returns: Array of units <Unit> class
	*/
	// Todo: optimize this
	METHOD(countUnits)
		params [P_THISOBJECT, P_ARRAY("_query")];
		// findUnits will do asserts and locks for us
		count T_CALLM1("findUnits", _query)
	ENDMETHOD;

	/*
	Method: countInfantryUnits
	Returns the amount of infantry units

	Returns: Number
	*/
	METHOD(countInfantryUnits)
		params [P_THISOBJECT];
		T_GETV("countInf")
	ENDMETHOD;

	/*
	Method: countConsciousInfantryUnits
	Returns the amount of conscious infantry units

	Returns: Number
	*/
	METHOD(countConsciousInfantryUnits)
		params [P_THISOBJECT];
		{ CALLM0(_x, "isConscious") } count T_CALLM0("getInfantryUnits")
	ENDMETHOD;
	
	/*
	Method: countOfficers
	Returns the amount of officers

	Returns: Number
	*/
	METHOD(countOfficers)
		params [P_THISOBJECT];
		count T_CALLM0("getOfficerUnits");
	ENDMETHOD;

	/*
	Method: countVehicleUnits
	Returns the amount of vehicle units

	Returns: Number
	*/
	METHOD(countVehicleUnits)
		params [P_THISOBJECT];
		T_GETV("countVeh")
	ENDMETHOD;

	/*
	Method: countDroneUnits
	Returns the amount of drone units

	Returns: Number
	*/
	METHOD(countDroneUnits)
		params [P_THISOBJECT];
		T_GETV("countDrone")
	ENDMETHOD;

	/*
	Method: countCargoUnits
	Returns the amount of cargo units

	Returns: Number
	*/
	METHOD(countCargoUnits)
		params [P_THISOBJECT];
		T_GETV("countCargo")
	ENDMETHOD;

	/*
	Method: copyIntelFrom
	Calls AI.copyIntelFrom another garrison's AI.

	Parameters: _gar - another garrison
	*/
	METHOD(copyIntelFrom)
		params [P_THISOBJECT, P_OOP_OBJECT("_gar")];
		pr _AI = T_GETV("AI");
		pr _otherAI = GETV(_gar, "AI");
		CALLM1(_AI, "copyIntelFrom", _otherAI);
	ENDMETHOD;

	/*
	Method: updateSpawnedUnitsIntel
	Updates intel of units if this garrison is spawned
	*/
	METHOD(updateUnitsIntel)
		params [P_THISOBJECT];
		if (T_GETV("spawned")) then {
			{
				CALLSM1("UnitIntel", "updateUnit", _x);
			} forEach T_GETV("units");
		};
	ENDMETHOD;
	
	// ======================================= FILES ==============================================
	// Handles incoming messages. Since it's a MessageReceiverEx, we must overwrite handleMessageEx
	METHOD_FILE(handleMessageEx, "Garrison\handleMessageEx.sqf");

	// Spawns the whole garrison
	METHOD_FILE(spawn, "Garrison\spawn.sqf");

	// Despawns the whole garrison
	METHOD_FILE(despawn, "Garrison\despawn.sqf");

	// Update spawn state of the garrison
	METHOD_FILE(updateSpawnState, "Garrison\updateSpawnState.sqf");

	METHOD(createAddInfGroup)
		params [P_THISOBJECT, "_side", "_subcatID", ["_type", GROUP_TYPE_INF]];

		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			OOP_WARNING_MSG("Garrison is already destroyed", []);
		};

		// Create an empty group
		private _newGroup = NEW("Group", [_side ARG _type]);
		// Create units from template
		private _template = CALLM2(gGameMode, "getTemplate", _side, "");
		private _count = CALLM2(_newGroup, "createUnitsFromTemplate", _template, _subcatID);
		T_CALLM2("postMethodAsync", "addGroup", [_newGroup]);
		[_newGroup, _count]
	ENDMETHOD;

	METHOD(createAddInfGroupInThread)
		params [P_THISOBJECT, "_side", "_subcatID", ["_type", GROUP_TYPE_INF]];

		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			OOP_WARNING_MSG("Garrison is already destroyed", []);
		};
		ASSERT_THREAD(_thisObject);

		// Create an empty group
		private _newGroup = NEW("Group", [_side ARG _type]);
		// Create units from template
		private _template = CALLM2(gGameMode, "getTemplate", _side, "");
		private _count = CALLM2(_newGroup, "createUnitsFromTemplate", _template, _subcatID);
		T_CALLM1("addGroup", _newGroup);
		[_newGroup, _count]
	ENDMETHOD;

	METHOD(createAddVehGroup)
		params [P_THISOBJECT, "_side", "_catID", "_subcatID", "_classID"];

		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			OOP_WARNING_MSG("Garrison is already destroyed", []);
		};

		// Create an empty group
		private _newGroup = NEW("Group", [_side ARG GROUP_TYPE_VEH]);
		private _template = CALLM2(gGameMode, "getTemplate", _side, "");
		private _newUnit = NEW("Unit", [_template ARG _catID ARG _subcatID ARG -1 ARG _newGroup]);
		// Create crew for the vehicle
		CALLM1(_newUnit, "createDefaultCrew", _template);
		T_CALLM2("postMethodAsync", "addGroup", [_newGroup]);
		_newGroup
	ENDMETHOD;

	METHOD(createAddVehGroupInThread)
		params [P_THISOBJECT, "_side", "_catID", "_subcatID", "_classID"];

		if(IS_GARRISON_DESTROYED(_thisObject)) exitWith {
			OOP_WARNING_MSG("Garrison is already destroyed", []);
		};
		ASSERT_THREAD(_thisObject);

		// Create an empty group
		private _newGroup = NEW("Group", [_side ARG GROUP_TYPE_VEH]);
		private _template = CALLM2(gGameMode, "getTemplate", _side, "");
		private _newUnit = NEW("Unit", [_template ARG _catID ARG _subcatID ARG -1 ARG _newGroup]);
		// Create crew for the vehicle
		CALLM1(_newUnit, "createDefaultCrew", _template);
		T_CALLM1("addGroup", _newGroup);
		_newGroup
	ENDMETHOD;

	// Static helpers

	// Updates spawn state of garrisons close to the provided position
	// Public, thread-safe
	STATIC_METHOD(updateSpawnStateOfGarrisonsNearPos)
		params [P_THISCLASS, P_POSITION("_pos")];
		pr _args = ["Garrison", "_updateSpawnStateOfGarrisonsNearPos", [_pos]];
		CALLM2(gMessageLoopMainManager, "postMethodAsync", "callStaticMethodInThread", _args);
	ENDMETHOD;

	// Private, thread-unsafe
	STATIC_METHOD(_updateSpawnStateOfGarrisonsNearPos)
		params [P_THISCLASS, P_POSITION("_pos")];

		pr _gars = GETSV("Garrison", "all");
		pr _garsToCheck = _gars select {
			if (CALLM0(_x, "isAlive")) then {
				pr _garPos = CALLM0(_x, "getPos");
				((_garPos distance2D _pos) < 1500) && // todo arbitrary number for now
				((_pos distance2D [0, 0, 0]) > 1) // Ignore garrisons with default pos at [0, 0, 0]
			} else {
				false
			};
		};

		{
			CALLM0(_x, "updateSpawnState");
		} forEach _garsToCheck;
	ENDMETHOD;

	STATIC_METHOD(updatePlayerGroup)
		params [P_THISCLASS, P_OBJECT("_player")];
		pr _args = ["Garrison", "_updatePlayerGroup", [_player]];
		CALLM2(gMessageLoopMainManager, "postMethodAsync", "callStaticMethodInThread", _args);
	ENDMETHOD;

	STATIC_METHOD(_updatePlayerGroup)
		params [P_THISCLASS, P_OBJECT("_player")];

		// Check that all non player units are in the player garrison, move them if not
		// Make player group leader if leader is an AI

		// Get the units OOP objects
		private _nonPlayerUnits = (units group _player) select { !(_x in allPlayers) };

		// Work out what garrison we are moving these units to
		private _playerGarrison = CALLSM1("GameModeBase", "getPlayerGarrisonForSide", side group _player);

		// Get units that need reassigning to player garrison
		private _unitsNeedReassigning = _nonPlayerUnits apply {
			[CALL_STATIC_METHOD("Unit", "getUnitFromObjectHandle", [_x]), _x]
		} select {
			!IS_NULL_OBJECT(_x select 0) && {CALLM0(_x select 0, "getGarrison") != _playerGarrison}
		} apply {
			// Get the object handle back
			_x select 1
		};

		if(count _unitsNeedReassigning > 0) then {
			CALLSM2("Garrison", "_addUnitsToPlayerGroup", _player, _unitsNeedReassigning);
		};

		// Disable all this for now, player can make them selves leader
		// // Make sure the group leader is a player
		// if !(leader group _player in allPlayers) then {

		// 	// remove and re-add AI to the group so players are first
		// 	private _units = (units group _player) select { !(_x in allPlayers) };
		// 	private _dummyGroup = createGroup (side group _player);
		// 	_units joinSilent _dummyGroup;
		// 	_units joinSilent group _player;
		// 	group _player selectLeader _player;

		// 	// private _players = [_player] + (_units - [_player]) select { _x in allPlayers };
		// 	// private _reorderedUnits = _players + (_units - _players);
		// 	// _reorderedUnits joinSilent _newGroup;
		// };

	ENDMETHOD;
	
	STATIC_METHOD(addUnitsToPlayerGroup)
		params [P_THISCLASS, P_OBJECT("_player"), P_ARRAY("_unitHandles")];

		pr _args = ["Garrison", "_addUnitsToPlayerGroup", [_player, _unitHandles]];
		CALLM2(gMessageLoopMainManager, "postMethodAsync", "callStaticMethodInThread", _args);
	ENDMETHOD;

	STATIC_METHOD(_addUnitsToPlayerGroup)
		params [P_THISCLASS, P_OBJECT("_player"), P_ARRAY("_unitHandles")];

		// Updates spawn state of garrisons close to the provided position
		OOP_INFO_2("Adding units %1 to group of player %2", _unitHandles, name _player);

		// Work out what garrison we are moving these units to
		private _tgtGarrison = CALLSM1("GameModeBase", "getPlayerGarrisonForSide", side group _player);
		private _tgtUnits = GETV(_tgtGarrison, "units");

		if(isNull _player || {!alive _player}) exitWith {
			OOP_WARNING_1("Can't add units, player is null or dead: %1", _player);
		};

		// Some sanity checks on the handles
		_unitHandles = _unitHandles select {
			!isNull _x 
			// Only units on real player side
			&& {side group _x isEqualTo side group _player}
		};

		// Get the units OOP objects
		private _units = _unitHandles apply {
			CALL_STATIC_METHOD("Unit", "getUnitFromObjectHandle", [_x])
		} select {
			!IS_NULL_OBJECT(_x) && {!(CALLM0(_x, "getGarrison") isEqualTo _tgtGarrison)} 
		};

		if(count _units == 0) exitWith {
			OOP_WARNING_2("Can't add units, no valid units to add, player: %1, unit handles: %2", _player, _unitHandles);
		};

		// Assign the units to the players garrison
		CALLM1(_tgtGarrison, "assignUnits", _units);

		pr _nearbyClients = allPlayers select { side group _x == side group _player && (_x distance _player) < 100 } apply { owner _x };
		private _msg = format ["%1 units assigned to %2", count _units, name _player];
		private _args = ["UNITS ASSIGNED", _msg, "They are now under direct control"];
		REMOTE_EXEC_CALL_STATIC_METHOD("NotificationFactory", "createResourceNotification", _args, _nearbyClients, NO_JIP);

		// HACK: somewhat of a hack as we aren't making OOP groups, however the player garrisons do not 
		// have any AI so they won't interfere with this
		_unitHandles join _player;
	ENDMETHOD;


	// STATIC_METHOD(makeGarrisonFromUnits)
	// 	params [P_THISCLASS, P_ARRAY("_unitHandles"), P_SIDE("_side")];
	// 	pr _args = ["Garrison", "_makeGarrisonFromUnits", [_unitHandles, _side]];
	// 	CALLM2(gMessageLoopMainManager, "postMethodAsync", "callStaticMethodInThread", _args);
	// ENDMETHOD;

	METHOD(makeGarrisonFromUnits)
		params [P_THISOBJECT, P_ARRAY("_unitHandles"), P_STRING_DEFAULT("_type", GARRISON_TYPE_GENERAL)];

		if(count _unitHandles == 0) exitWith {
			OOP_WARNING_0("makeGarrisonFromUnits: No unit handles specified");
		};

		private _ourUnits = T_GETV("units");

		// Get the units OOP objects
		private _unitObjects = _unitHandles apply {
			CALL_STATIC_METHOD("Unit", "getUnitFromObjectHandle", [_x])
		} select {
			!IS_NULL_OBJECT(_x) && {_x in _ourUnits}
		};

		if(count _unitObjects == 0) exitWith {
			OOP_WARNING_1("makeGarrisonFromUnits: No unit objects found for unit handles %1 in our garrison", _unitHandles);
		};

		OOP_INFO_2("Adding units %1 to commander for side %2", _unitHandles, _side);

		// Make a new garrison
		private _side = T_GETV("side");
		private _pos = position (_unitHandles#0);
		private _faction = T_CALLM0("getFaction");
		private _templateName = T_CALLM0("getTemplateName");
		private _spawned = true; // If we are adding units from unit handles then they must be spawned
		private _args = [_type, _side, _pos, _faction, _templateName, _spawned];
		private _newGarrison = NEW("Garrison", _args);

		// Create some infantry group
		private _group = NEW("Group", [_side ARG GROUP_TYPE_INF]);

		// Add group to ourselves first so we can move it after we populated it
		T_CALLM1("addGroup", _group);

		// Populate the new group
		{
			CALLM1(_group, "addUnit", _x);
		} forEach _unitObjects;

		// Add group to new garrison
		CALLM1(_newGarrison, "addGroup", _group);

		// Register it at the commander (do it after adding the units so the sync is correct)
		CALLM0(_newGarrison, "activate");

		// Delete our empty groups
		T_CALLM0("deleteEmptyGroups");

		private _msg = format ["%1 units formed new garrison at %2", count _unitObjects, mapGridPosition _pos];
		private _args = ["GARRISON FORMED", _msg, "They are now available for map control"];
		REMOTE_EXEC_CALL_STATIC_METHOD("NotificationFactory", "createResourceNotification", _args, ON_CLIENTS, NO_JIP);
	ENDMETHOD;

	METHOD(getTemplateName)
		params [P_THISOBJECT];
		T_GETV("templateName")
	ENDMETHOD;

	METHOD(getTemplate)
		params [P_THISOBJECT];
		[T_GETV("templateName")] call t_fnc_getTemplate
	ENDMETHOD;

	// - - - - - STORAGE - - - - -
	/* override */ METHOD(preSerialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		// Save all units (except players)
		pr _savedUnits = T_GETV("units") select {
			// Don't save players
			!CALLM0(_x, "isPlayer")
		};

		T_SETV("savedUnits", _savedUnits);
		{
			private _unit = _x;
			CALLM1(_storage, "save", _unit);
		} forEach _savedUnits;

		// Save our groups
		{
			pr _group = _x;
			CALLM1(_storage, "save", _group);
		} forEach T_GETV("groups");

		// Save AI
		pr _AI = T_GETV("AI");
		if(!IS_NULL_OBJECT(_AI)) then {
			CALLM1(_storage, "save", _AI);
		};

		true
	ENDMETHOD;

	/* virtual */ METHOD(postDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		// Call method of all base classes
		T_CALLCM1("MessageReceiverEx", "postDeserialize", _storage);

		// Restore variables which were not saved

		// Load all our units
		// We don't care that groups will try to restore them as well
		// Storage class will not load same object twice anyway
		private _savedUnits = T_GETV("savedUnits");

		{
			private _unit = _x;
			CALLM1(_storage, "load", _unit);
		} forEach _savedUnits;

		T_SETV("units", _savedUnits);
		T_SETV("savedUnits", []);

		// Load groups
		{
			pr _group = _x;
			CALLM1(_storage, "load", _group);
		} forEach T_GETV("groups");

		T_SETV("spawned", false);

		// Restore timer
		T_CALLM0("initTimer");

		// Restore mutex
		pr _mutex = MUTEX_RECURSIVE_NEW();
		T_SETV("mutex", _mutex);

		// Other variables...
		T_SETV("outdated", true);
		T_SETV("regAtServer", false);

		// Recalculate all the counters, efficiency, classnames etc.
		T_CALLM0("_recalculateCounters");

		// Load AI object
		pr _AI = T_GETV("AI");
		CALLM1(_storage, "load", _AI);
		if(T_GETV("active")) then {
			// Start AI object
			CALLM1(_AI, "start", "AIGarrisonDespawned");
			// Register at garrison server if active
			CALLM1(gGarrisonServer, "onGarrisonCreated", _thisObject);
		};

		// Enable automatic spawning
		private _autoSpawn = T_GETV("type") in GARRISON_TYPES_AUTOSPAWN;
		if(!_autoSpawn) then {
			if(T_GETV("active")) then {
				// Process before spawning so we can ensure any immediate Action is able to provide custom spawning
				CALLM2(_AI, "postMethodAsync", "process", []);
			};
			T_CALLM2("postMethodAsync", "spawn", [true]);
		};

		// Push to 'all' static variable
		GETSV("Garrison", "all") pushBack _thisObject;

		// Delete out empty groups
		T_CALLM0("deleteEmptyGroups");

		// Recalculate build resources
		T_CALLM0("updateBuildResources");

		true
	ENDMETHOD;

	/* override */ STATIC_METHOD(saveStaticVariables)
		params [P_THISCLASS, P_OOP_OBJECT("_storage")];
	ENDMETHOD;

	/* override */ STATIC_METHOD(loadStaticVariables)
		params [P_THISCLASS, P_OOP_OBJECT("_storage")];
		SETSV("Garrison", "all", []);
	ENDMETHOD;

ENDCLASS;

if (isNil { GETSV("Garrison", "all") } ) then {
	SETSV("Garrison", "all", []);
};


// - - - - - - SQF VM - - - - - - -

#ifdef _SQF_VM

["Garrison.add units", {
	private _actual = NEW("Garrison", [GARRISON_TYPE_GENERAL ARG WEST]);
	private _Test_group_args = [WEST, 0]; // Side, group type
	private _subcatID = T_INF_rifleman;
	private _Test_unit_args = [tNATO, T_INF, _subcatID, -1];
	private _group = NEW("Group", _Test_group_args);
	private _eff1 = +T_EFF_null;
	private _comp1 = +T_comp_null;
	for "_i" from 0 to 19 do
	{
		private _unit = NEW("Unit", _Test_unit_args + [_group]);
		private _unitEff = CALLM0(_unit, "getEfficiency");
		_eff1 = EFF_ADD(_eff1, _unitEff);
		[_comp1, T_INF, _subcatID, 1] call comp_fnc_addValue;
	};

	CALLM(_actual, "addGroup", [_group]);
	
	//diag_log format ["Garrison total eff after adding group: %1", CALLM0(_actual, "getEfficiencyTotal")];
	//diag_log format ["Garrison composition after adding group: %1", CALLM0(_actual, "getCompositionNumbers")];
	["Efficiency", CALLM0(_actual, "getEfficiencyTotal") isEqualTo _eff1] call test_Assert;
	["Composition", CALLM0(_actual, "getCompositionNumbers") isEqualTo _comp1] call test_Assert;

	true
}] call test_AddTest;

["Garrison.save and load", {
	private _gar = NEW("Garrison", [GARRISON_TYPE_GENERAL ARG WEST ARG [] ARG "military" ARG "tNATO"]);
	["Garrison is OK 0", CALLM0(_gar, "getSide") == WEST] call test_Assert;
	private _Test_group_args = [WEST, 0]; // Side, group type
	private _subcatID = T_INF_rifleman;
	private _Test_unit_args = [tNATO, T_INF, _subcatID, -1];
	private _groups = [];
	private _units = [];
	for "_nGroups" from 0 to 2 do {
		private _group = NEW("Group", _Test_group_args);
		for "_i" from 0 to 4 do
		{
			private _unit = NEW("Unit", _Test_unit_args + [_group]);
			_units pushBack _unit;
		};
		CALLM(_gar, "addGroup", [_group]);
		_groups pushBack _group;
	};

	["Garrison is OK 1", CALLM0(_gar, "getSide") == WEST] call test_Assert;

	pr _storage = NEW("StorageProfileNamespace", []);
	CALLM1(_storage, "open", "testRecordGarrison");
	CALLM1(_storage, "save", _gar);
	CALLSM1("Garrison", "saveStaticVariables", _storage);

	{DELETE(_x);} forEach _units;
	{DELETE(_x);} forEach _groups;
	CALLM0(_gar, "destroy");

	CALLM1(_storage, "load", _gar);
	CALLSM1("Garrison", "loadStaticVariables", _storage);

	["Garrison loaded", CALLM0(_gar, "getSide") == WEST] call test_Assert;
	["Groups are loaded", CALLM0(_groups#0, "getSide") == WEST] call test_Assert;
	["Units are loaded", CALLM0(_units#0, "getCategory") == T_INF] call test_Assert;
	true
}] call test_AddTest;

#endif
