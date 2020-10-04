#include "..\common.hpp"

#ifdef ASP_ENABLE
#define _CREATE_PROFILE_SCOPE(scopeName) private _tempScope = createProfileScope scopeName
#define _DELETE_PROFILE_SCOPE _tempScope = 0
#else
#define _CREATE_PROFILE_SCOPE(scopeName)
#define _DELETE_PROFILE_SCOPE
#endif

#ifdef UNIT_ALLOCATOR_DEBUG
#define LOG_ALLOCATOR(fmt) diag_log format (fmt)
#define LOG_ALLOCATOR_COMP(msg, comp) [(comp), (msg)] call comp_fnc_print
#define LOG_ALLOCATOR_META(msg, cat, subcat) diag_log format [(msg)] + ([[(cat), 0, (subcat)]] call t_fnc_getMetadata)
#else
#define LOG_ALLOCATOR(fmt)
#define LOG_ALLOCATOR_COMP(msg, comp)
#define LOG_ALLOCATOR_META(msg, cat, subcat)
#endif
FIX_LINE_NUMBERS()

// GarrisonModel_getThread = {
// 	params ["_garrisonModel"];
// 	// Can't use normal accessor because it would cause an infinite loop!
// 	private _side = _GETV(_garrisonModel, "side");
// 	if(!isNil "_side") then {
// 		private _AICommander = CALLSM("AICommander", "getAICommander", [_side]);
// 		if(!IS_NULL_OBJECT(_AICommander)) then {
// 			GETV(CALLM0(_AICommander, "getMessageLoop"), "scriptHandle")
// 		} else {
// 			nil
// 		}
// 	}
// };

#define pr private

// Maximum amount of entries into the unit allocation cache
#define ALLOCATOR_CACHE_SIZE (1024*10)

//#define UNIT_ALLOCATOR_DEBUG

// Model of a Real Garrison. This can either be the Actual model or the Sim model.
// The Actual model represents the Real Garrison as it currently is. A Sim model
// is a copy that is modified during simulations.
#define OOP_CLASS_NAME GarrisonModel
CLASS("GarrisonModel", "ModelBase")
	// Strength vector of the garrison.
	VARIABLE_ATTR("efficiency", []);
	// Composition of the garrison (see templates\composition)
	VARIABLE_ATTR("composition", []);
	// Available transportation (free seats in trucks)
	VARIABLE_ATTR("transport", []);
	//// Current order the garrison is following.
	// TODO: do we want this? I think only real Garrison needs orders, model just has action.
	//VARIABLE_ATTR("order", [ATTR_REFCOUNTED]);
	VARIABLE_ATTR("action", [ATTR_GET_ONLY]);
	// Is the garrison currently in combat?
	// TODO: maybe replace this with with "engagement score" indicating how engaged they are.
	VARIABLE_ATTR("inCombat", [ATTR_PRIVATE]);
	// Position.
	VARIABLE_ATTR("pos", []);
	// What type of garrison this is.
	VARIABLE_ATTR("type", []);
	// What side this garrison belongs to.
	VARIABLE_ATTR("side", []);
	// What faction within the side this garrison belongs to.
	VARIABLE_ATTR("faction", []);
	// Id of the location the garrison is currently occupying.
	VARIABLE_ATTR("locationId", [ATTR_GET_ONLY]);

	// Garrison AI alertness - how alert the garrison is 0-1
	VARIABLE_ATTR("alertness", []);

	// Hash map for unit allocation algorithm
	STATIC_VARIABLE("allocatorCache");
	STATIC_VARIABLE("allocatorCacheAllKeys");	// Array of all keys
	STATIC_VARIABLE("allocatorCacheCounter");	// Counter for all keys
	STATIC_VARIABLE("allocatorCacheNMiss");		// Amount of misses in the cache
	STATIC_VARIABLE("allocatorCacheNHit");		// Amount of hits in the cache

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_world"), P_OOP_OBJECT("_actual")];

		T_SETV("action", NULL_OBJECT);
		// These will get set in sync
		T_SETV("efficiency", +EFF_ZERO);
		T_SETV("composition", +T_comp_null);
		T_SETV("transport", 0);
		T_SETV("inCombat", false);
		T_SETV("pos", []);
		T_SETV("side", sideUnknown);
		T_SETV("type", GARRISON_TYPE_GENERAL);
		T_SETV("faction", "");
		T_SETV("locationId", MODEL_HANDLE_INVALID);
		T_SETV("alertness", 0);
		if(T_CALLM0("isActual")) then {
			T_CALLM0("sync");
			#ifdef OOP_DEBUG
			OOP_DEBUG_MSG("GarrisonModel for %1 created in %2", [_actual ARG _world]);
			#endif
			FIX_LINE_NUMBERS()
		};
		// Add self to world
		CALLM1(_world, "addGarrison", _thisObject);
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];
		T_CALLM0("killed");
	ENDMETHOD;

	public override METHOD(simCopy)
		params [P_THISOBJECT, P_OOP_OBJECT("_targetWorldModel")];
		ASSERT_OBJECT_CLASS(_targetWorldModel, "WorldModel");

		private _actual = T_GETV("actual");
		private _copy = NEW("GarrisonModel", [_targetWorldModel ARG _actual]);

		// id is set in the constructor above, as the garrison self registers with the world
		#ifdef OOP_ASSERT
		private _idsEqual = T_GETV("id") == GETV(_copy, "id");
		private _msg = format ["%1 id (%2) out of sync with sim copy %3 id (%4)", _thisObject, T_GETV("id"), _copy, GETV(_copy, "id")];
		ASSERT_MSG(_idsEqual, _msg);
		#endif
		FIX_LINE_NUMBERS()

		//	"Id of the GarrisonModel copy is out of sync with the original. This indicates the world garrison list isn't being copied correctly?");
		//SETV(_copy, "id", T_GETV("id"));
		SETV(_copy, "label", T_GETV("label"));
		SETV(_copy, "efficiency", +T_GETV("efficiency"));
		SETV(_copy, "composition", +T_GETV("composition"));
		SETV(_copy, "transport", +T_GETV("transport"));
		private _action = T_GETV("action");
		// Call setAction so the action gets register/unregister messages
		if(!IS_NULL_OBJECT(_action)) then {
			CALLM1(_copy, "setAction", _action);
		};
		SETV(_copy, "inCombat", T_GETV("inCombat"));
		SETV(_copy, "pos", +T_GETV("pos"));
		SETV(_copy, "side", T_GETV("side"));
		SETV(_copy, "type", T_GETV("type"));
		SETV(_copy, "faction", T_GETV("faction"));
		SETV(_copy, "locationId", T_GETV("locationId"));
		SETV(_copy, "alertness", T_GETV("alertness"));
		_copy
	ENDMETHOD;

	METHOD(_sync)
		params [P_THISOBJECT, P_OOP_OBJECT("_actual")];
		
		if(CALLM0(_actual, "isDestroyed") && (IS_NULL_OBJECT(CALLM0(_actual, "getLocation")))) exitWith {
			T_CALLM0("killed");
		};

		private _newEff = CALLM0(_actual, "getEfficiencyMobile");
		if(EFF_LTE(_newEff, EFF_ZERO) && (IS_NULL_OBJECT(CALLM0(_actual, "getLocation"))) ) then {
			T_CALLM0("killed");
		} else {
			T_SETV("type", CALLM0(_actual, "getType"));
			T_SETV("side", CALLM0(_actual, "getSide"));
			T_SETV("faction", CALLM0(_actual, "getFaction"));
			T_SETV("efficiency", _newEff);
			T_SETV("composition", CALLM0(_actual, "getCompositionNumbers")); // It does a deep copy itself
			T_SETV("transport", CALLM1(_actual, "getTransportCapacity", [T_VEH_truck_inf])); // Get seats only for trucks as we care about this most
			T_SETV("pos", +CALLM0(_actual, "getPos"));
			private _AI = CALLM0(_actual, "getAI");
			T_SETV("alertness", CALLM0(_AI, "getAlertness"));
			private _locationActual = CALLM0(_actual, "getLocation");
			if(!IS_NULL_OBJECT(_locationActual)) then {
				private _location = CALLM1(T_GETV("world"), "findOrAddLocationByActual", _locationActual);
				T_SETV("locationId", GETV(_location, "id"));
				// We don't call the proper functions because it deals with updating the LocationModel
				// and we don't need to do that in sync (LocationModel sync does it)
				//T_CALLM1("attachToLocation", _location);
			} else {
				T_SETV("locationId", MODEL_HANDLE_INVALID);
			};
		};
	ENDMETHOD;
	
	public override METHOD(sync)
		params [P_THISOBJECT];
		ASSERT_MSG(T_CALLM0("isActual"), "Only sync actual models");
		private _actual = T_GETV("actual");
		ASSERT_OBJECT_CLASS(_actual, "Garrison");

		SCOPE_IGNORE_ACCESS(GarrisonModel); // _sync is called out of our scope technically, so explicitly allow it
		CALLM3(_actual, "runLocked", _thisObject, "_sync", [_actual]);
	ENDMETHOD;

	// Garrison is empty (not necessarily killed, could be merged to another garrison etc.)
	public METHOD(killed)
		params [P_THISOBJECT];

		private _world = T_GETV("world");
		T_SETV("efficiency", +EFF_ZERO);
		T_SETV("composition", +T_comp_null);
		T_SETV("transport", 0);
		T_CALLM0("detachFromLocation");
		CALLM1(_world, "garrisonKilled", _thisObject);
		T_CALLM0("clearAction");
		OOP_DEBUG_MSG("Killed %1", [_thisObject]);
	ENDMETHOD;

	public METHOD(detachFromLocation)
		params [P_THISOBJECT];
		private _location = T_CALLM0("getLocation");
		if(!IS_NULL_OBJECT(_location)) then {
			CALLM1(_location, "removeGarrison", _thisObject);
			T_SETV("locationId", MODEL_HANDLE_INVALID);
			OOP_DEBUG_MSG("Detached %1 from location %2", [_thisObject ARG _location]);
		};
	ENDMETHOD;

	public METHOD(isBusy)
		params [P_THISOBJECT];
		!IS_NULL_OBJECT(T_GETV("action"))
	ENDMETHOD;

	public METHOD(getAction)
		params [P_THISOBJECT];
		T_GETV("action")
	ENDMETHOD;

	public METHOD(setAction)
		params [P_THISOBJECT, P_OOP_OBJECT("_action")];
		// Clear previous action first
		T_CALLM0("clearAction");
		T_SETV("action", _action);
		CALLM1(_action, "registerGarrison", _thisObject);

		// If this model is in the real world, notify the actual garrison, for the GarrisonServer to transmit updates
		private _world = T_GETV("world");
		if (CALLM0(_world, "isReal")) then {
			private _AI = CALLM0(T_GETV("actual"), "getAI");
			private _recordSerial = CALLM2(_action, "getRecordSerial", _thisObject, _world);
			CALLM2(_AI, "postMethodAsync", "setCmdrActionSerial", [_recordSerial]);
		};
	ENDMETHOD;

	public METHOD(clearAction)
		params [P_THISOBJECT];
		private _currentAction = T_GETV("action");
		if(!IS_NULL_OBJECT(_currentAction)) then {
			CALLM1(_currentAction, "unregisterGarrison", _thisObject);
		};
		T_SETV("action", NULL_OBJECT);

		// If this model is in the real world, notify the actual garrison, for the GarrisonServer to transmit updates
		if (CALLM0(T_GETV("world"), "isReal")) then {
			private _AI = CALLM0(T_GETV("actual"), "getAI");
			CALLM2(_AI, "postMethodAsync", "setCmdrActionSerial", []); // [] means no action is being done any more
		};
	ENDMETHOD;

	public METHOD(isDead)
		params [P_THISOBJECT];
		// Garrison is dead if it's empty AND is not at a location
		T_GETV("efficiency") isEqualTo EFF_ZERO && {T_GETV("locationId") == MODEL_HANDLE_INVALID} //or {EFF_LTE(_efficiency, EFF_ZERO)}
	ENDMETHOD;

	public METHOD(isDepleted)
		params [P_THISOBJECT];
		private _efficiency = T_GETV("efficiency");
		!EFF_GT(_efficiency, EFF_MIN_EFF)
	ENDMETHOD;

	public METHOD(getLocation)
		params [P_THISOBJECT];
		private _locationId = T_GETV("locationId");
		if(_locationId != MODEL_HANDLE_INVALID) exitWith { CALLM1(T_GETV("world"), "getLocation", _locationId) };
		NULL_OBJECT
	ENDMETHOD;

	/*
	Method: countUnits
	Counts the number of units with specified category and subcategory

	Parameters: _query

	_query - array of [_catID, _subcatID].

	Returns: Count of units matching query
	*/
	public METHOD(countUnits)
		params [P_THISOBJECT, P_ARRAY("_query")];
		private _composition = T_GETV("composition");
		private _return = 0;
		{// for each _query
			_x params ["_catID", "_subcatID"];
			_return = _return + _composition#_catID#_subcatID;
		} forEach _query;
		_return
	ENDMETHOD;

	/*
	Method: countOfficers
	Returns: the number of officers in the Garrison
	*/
	public METHOD(countOfficers)
		params [P_THISOBJECT, P_ARRAY("_query")];
		T_CALLM1("countUnits", [[T_INF ARG T_INF_officer]])
	ENDMETHOD;

	// -------------------- S I M  /  A C T U A L   M E T H O D   P A I R S -------------------
	// Does this make sense? Could the sim/actual split be handled in a single functions
	// instead? Need the concept of operations that take time, and they only apply to 
	// Actual not sim. 

	// SPLIT
	// Flags defined in CmdrAI/common.hpp
	public METHOD(splitSim)
		params [P_THISOBJECT, P_ARRAY("_compToDetach"), P_ARRAY("_effToDetach")];

		// Here we just add/substract the composition and efficiency values

		ASSERT_MSG(EFF_SUM(_effToDetach) > 0, "_effToDetach can't be zero");

		private _composition = T_GETV("composition");
		private _efficiency = T_GETV("efficiency");

		[_composition, _compToDetach] call comp_fnc_diffAccumulate;
		_efficiency = EFF_DIFF(_efficiency, _effToDetach);

		// Don't need to set composition again we modified it directly

		T_SETV("efficiency", _efficiency);
		
		private _world = T_GETV("world");
		private _actual = T_GETV("actual");
		private _detachment = NEW("GarrisonModel", [_world ARG _actual]);
		SETV(_detachment, "efficiency", _effToDetach);
		SETV(_detachment, "composition", _compToDetach);
		SETV(_detachment, "pos", +T_GETV("pos"));
		SETV(_detachment, "side", T_GETV("side"));
		SETV(_detachment, "faction", T_GETV("faction"));

		_detachment
	ENDMETHOD;

	public METHOD(splitActual)
		params [P_THISOBJECT, P_ARRAY("_compToDetach"), P_ARRAY("_effToDetach")];

		ASSERT_MSG(EFF_SUM(_effToDetach) > 0, "_effToDetach can't be zero");
		private _actual = T_GETV("actual");
		private _world = T_GETV("world");
		ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when Actual is not valid");

		// Make a new garrison
		private _newGarrActual = CALLSM1("Garrison", "newFrom", _actual);

		// CALLM2(_newGarrActual, "postMethodAsync", "setPos", [_pos]);

		// Try to move the units
		OOP_INFO_1("Composition before split: %1", GETV(_actual, "compositionNumbers"));
		OOP_INFO_1("Split composition: %1", _compToDetach);
		private _args = [_actual, _compToDetach];
		private _moveSuccess = CALLM2(_newGarrActual, "postMethodSync", "addUnitsFromCompositionNumbers", _args);
		if (!_moveSuccess) exitWith {
			OOP_WARNING_MSG("Couldn't move units to new garrison", []);
			NULL_OBJECT
		};
		OOP_INFO_1("Composition after split: %1", GETV(_actual, "compositionNumbers"));

		// WIP temporary fix to give resources to convoys
		//CALLM2(_newGarrActual, "postMethodAsync", "addBuildResources", [120]);

		// Copy intel and radio keys from the old garrison into the new one
		CALLM2(_newGarrActual, "postMethodAsync", "copyIntelFrom", [_actual]);

		OOP_INFO_0("Successfully split garrison");

		// Register it at the commander (do it after adding the units so the sync is correct)
		#ifndef _SQF_VM
		private _newGarr = CALLM0(_newGarrActual, "activateCmdrThread");
		#else
		private _newGarr = NEW("GarrisonModel", [_world ARG _newGarrActual]);
		#endif
		FIX_LINE_NUMBERS()

		// return the New detachment garrison model
		_newGarr
	ENDMETHOD;

	// MOVE TO POS
	public METHOD(moveSim)
		params [P_THISOBJECT, P_ARRAY("_pos"), P_NUMBER("_radius")];

		T_SETV("pos", _pos);
	ENDMETHOD;

	public METHOD(moveActual)
		params [P_THISOBJECT, P_ARRAY("_pos"), P_NUMBER("_radius")];

		private _actual = T_GETV("actual");
		ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when Actual is not valid");
		private _AI = CALLM0(_actual, "getAI");
		private _parameters = [[TAG_POS, _pos], [TAG_MOVE_RADIUS, _radius]];
		CALLM2(_AI, "postMethodAsync", "addExternalGoal", ["GoalGarrisonMove" ARG 0 ARG _parameters ARG _thisObject]);

		OOP_INFO_MSG("Moving %1 to %2 within %3", [LABEL(_thisObject) ARG _pos ARG _radius]);
	ENDMETHOD;

	public METHOD(cancelMoveActual)
		params [P_THISOBJECT];

		private _actual = T_GETV("actual");
		ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when Actual is not valid");
		private _AI = CALLM0(_actual, "getAI");
		CALLM2(_AI, "postMethodAsync", "deleteExternalGoal", ["GoalGarrisonMove" ARG _thisObject]);

		OOP_INFO_MSG("Cancelled move of %1", [LABEL(_thisObject)]);
	ENDMETHOD;

	public METHOD(moveActualComplete)
		params [P_THISOBJECT];

		private _actual = T_GETV("actual");
		ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when Actual is not valid");
		private _AI = CALLM0(_actual, "getAI");
		private _goalState = CALLM2(_AI, "getExternalGoalActionState", "GoalGarrisonMove", _thisObject);
		if(_goalState == ACTION_STATE_COMPLETED) then {
			OOP_INFO_MSG("Move of %1 complete", [LABEL(_thisObject)]);
		};
		_goalState == ACTION_STATE_COMPLETED
	ENDMETHOD;

	// MERGE TO ANOTHER GARRISON
	public METHOD(mergeSim)
		params [P_THISOBJECT, P_OOP_OBJECT("_otherGarr")];
		ASSERT_OBJECT_CLASS(_otherGarr, "GarrisonModel");

		private _efficiency = T_GETV("efficiency");
		private _composition = T_GETV("composition");
		private _otherComp = GETV(_otherGarr, "composition");
		[_otherComp, _composition] call comp_fnc_addAccumulate;

		private _otherEff = GETV(_otherGarr, "efficiency");
		private _newOtherEff = EFF_ADD(_efficiency, _otherEff);
		SETV(_otherGarr, "efficiency", _newOtherEff);

		private _transport = T_GETV("transport");
		private _otherTransport = GETV(_otherGarr, "transport");
		SETV(_otherGarr, "transport", _otherTransport + _transport);

		OOP_DEBUG_MSG("Merged %1%2 to %3%4->%5", [_thisObject ARG _efficiency ARG _otherGarr ARG _otherEff ARG _newOtherEff]);
		T_CALLM0("killed");
	ENDMETHOD;

	public METHOD(mergeActual)
		params [P_THISOBJECT, P_OOP_OBJECT("_otherGarr")];
		ASSERT_OBJECT_CLASS(_otherGarr, "GarrisonModel");

		private _actual = T_GETV("actual");
		ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when Actual is not valid");

		OOP_INFO_MSG("Merging %1 to %2", [LABEL(_thisObject) ARG LABEL(_otherGarr)]);
		private _otherActual = GETV(_otherGarr, "actual");
		CALLM2(_otherActual, "postMethodAsync", "addGarrison", [_actual]);
		T_CALLM0("killed");
		OOP_INFO_MSG("Merged %1 to %2", [LABEL(_thisObject) ARG LABEL(_otherGarr)]);
	ENDMETHOD;

	// JOIN LOCATION
	public METHOD(joinLocationSim)
		params [P_THISOBJECT, P_OOP_OBJECT("_location")];
		ASSERT_OBJECT_CLASS(_location, "LocationModel");
		
		CALLM1(_location, "addGarrison", _thisObject);
		private _id = GETV(_location, "id");
		T_SETV("locationId", _id);
	ENDMETHOD;

	public METHOD(joinLocationActual)
		params [P_THISOBJECT, P_OOP_OBJECT("_location")];
		ASSERT_OBJECT_CLASS(_location, "LocationModel");

		private _actual = T_GETV("actual");
		ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when Actual is not valid");

		private _locationActual = GETV(_location, "actual");
		// CALLM2(_locationActual, "postMethodAsync", "registerGarrison", [_actual]);
		CALLM2(_actual, "postMethodAsync", "setLocation", [_locationActual]);
		OOP_INFO_MSG("Joined %1 to %2", [LABEL(_thisObject) ARG LABEL(_location)]);

		private _locType = GETV(_location, "type");
		if(_locType == LOCATION_TYPE_ROADBLOCK) then {
			// TODO: BUILD ROADBLOCK? This would be temporary, not sure what proper way to do it is...
		};

		// private _AI = CALLM0(_actual, "getAI");
		// private _parameters = [[TAG_LOCATION, _locationActual]];
		// private _args = ["GoalGarrisonJoinLocation", 0, _parameters, _thisObject];
		// CALLM2(_AI, "postMethodAsync", "addExternalGoal", _args);
	ENDMETHOD;

	// CLEAR AREA
	public METHOD(clearAreaActual)
		params [P_THISOBJECT, P_ARRAY("_pos"), P_NUMBER("_moveRadius"), P_NUMBER("_clearRadius"), P_NUMBER("_timeOutSeconds")];

		private _actual = T_GETV("actual");
		ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when Actual is not valid");
		private _AI = CALLM0(_actual, "getAI");
		private _parameters = [[TAG_POS_CLEAR_AREA, _pos], [TAG_CLEAR_RADIUS, _clearRadius], [TAG_DURATION_SECONDS, _timeOutSeconds]];
		CALLM2(_AI, "postMethodAsync", "addExternalGoal", ["GoalGarrisonClearArea" ARG 0 ARG _parameters ARG _thisObject]);

		OOP_INFO_MSG("%1 clearing area at %2, radius %3, timeout %4 seconds", [LABEL(_thisObject) ARG _pos ARG _clearRadius ARG _timeOutSeconds]);
	ENDMETHOD;

	public METHOD(clearActualComplete)
		params [P_THISOBJECT];

		private _actual = T_GETV("actual");
		ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when Actual is not valid");
		private _AI = CALLM0(_actual, "getAI");
		private _goalState = CALLM2(_AI, "getExternalGoalActionState", "GoalGarrisonClearArea", _thisObject);
		if(_goalState == ACTION_STATE_COMPLETED) then {
			OOP_INFO_MSG("%1 completed clearing area", [LABEL(_thisObject)]);
		};
		_goalState == ACTION_STATE_COMPLETED
	ENDMETHOD;

	public METHOD(cancelClearAreaActual)
		params [P_THISOBJECT];

		private _actual = T_GETV("actual");
		ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when Actual is not valid");
		private _AI = CALLM0(_actual, "getAI");
		CALLM2(_AI, "postMethodAsync", "deleteExternalGoal", ["GoalGarrisonClearArea" ARG _thisObject]);

		OOP_INFO_MSG("Cancelled clear area for %1", [LABEL(_thisObject)]);
	ENDMETHOD;

	// ASSIGN CARGO
	public METHOD(assignCargoActual)
		params [P_THISOBJECT, P_ARRAY("_cargo")];
		private _actual = T_GETV("actual");
		ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when Actual is not valid");
		CALLM2(_actual, "postMethodAsync", "assignCargo", [_cargo]);
	ENDMETHOD;

	// CLEAR CARGO
	public METHOD(clearCargoActual)
		params [P_THISOBJECT];
		private _actual = T_GETV("actual");
		ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when Actual is not valid");
		CALLM2(_actual, "postMethodAsync", "clearCargo", []);
	ENDMETHOD;

	// Unit allocation algorithm
	// Allocates units from composition while trying to satisfy _effExt (external efficiency)
	public STATIC_METHOD(allocateUnits)
		params [P_THISCLASS,
				P_ARRAY("_effExt"),						// External efficiency requirement we must fullfill
				P_ARRAY("_constraintFlags"),			// Array of flags for constraint verification
				P_ARRAY("_comp"),						// Composition array: [[1, 2, 3], [4, 5], [6, 7]]: 1 unit of cat:0,subcat:0, 2x(0, 1), 3x(0, 2), etc
				P_ARRAY("_eff"),						// Efficiency which corresponds to composition
				P_ARRAY("_compPayloadWhitelistMask"),	// Whitelist mask for payload or []
				P_ARRAY("_compPayloadBlacklistMask"),	// Blacklist mask for payload or []
				P_ARRAY("_compTransportWhitelistMask"),	// Whitelist mask for transport or []
				P_ARRAY("_compTransportBlacklistMask"), // Blacklist mask for transport or []
				P_ARRAY("_requiredComp")				// Any specifically required composition or []
		];
		LOG_ALLOCATOR(["allocateUnits: %1" ARG _this]);

		// Perform lookup in hash map
		pr _hashMap = GETSV("GarrisonModel", "allocatorCache");
		pr _hashMapKey = str _this;	// 200us and more
		pr _hashmapValue = _hashMap getVariable _hashMapKey;
		if (!isNil "_hashmapValue") exitWith {
			LOG_ALLOCATOR(["_hashmapValue: %1" ARG str _hashmapValue]);
			SETSV("GarrisonModel", "allocatorCacheNHit", GETSV("GarrisonModel", "allocatorCacheNHit") + 1);	// Increase hit counter
			_hashmapValue	
		};
		SETSV("GarrisonModel", "allocatorCacheNMiss", GETSV("GarrisonModel", "allocatorCacheNMiss") + 1);	// Increase miss counter

		// Assign validation functions according to flags
		pr _constraintFnNames = [];
		if (SPLIT_VALIDATE_CREW in _constraintFlags) then {
			_constraintFnNames pushBack "eff_fnc_validateCrew";
		};
		if (SPLIT_VALIDATE_TRANSPORT in _constraintFlags) then {
			_constraintFnNames pushBack "eff_fnc_validateTransport";
		};
		if (SPLIT_VALIDATE_ATTACK in _constraintFlags) then {
			_constraintFnNames pushBack "eff_fnc_validateAttack";
		};
		if (SPLIT_VALIDATE_CREW_EXT in _constraintFlags) then {
			_constraintFnNames pushBack "eff_fnc_validateCrewExternal";
		};
		if (SPLIT_VALIDATE_TRANSPORT_EXT in _constraintFlags) then {
			_constraintFnNames pushBack "eff_fnc_validateTransportExternal";
		};

		// Composition left after the allocation
		pr _compRemaining = +_comp;
		pr _effRemaining = +_eff;

		// Select units we can allocate for payload
		pr _compPayload = +_comp;

		// Apply masks if they are provided...
		if (count _compPayloadWhitelistMask > 0) then {
			LOG_ALLOCATOR(["_compPayloadWhitelistMask: %1" ARG str _compPayloadWhitelistMask]);
			LOG_ALLOCATOR(["_compPayload before: %1" ARG str _compPayload]);
			[_compPayload, _compPayloadWhitelistMask] call comp_fnc_applyWhitelistMask;
			LOG_ALLOCATOR(["_compPayload after: %1" ARG str _compPayload]);
		};

		if (count _compPayloadBlacklistMask > 0) then {
			LOG_ALLOCATOR(["_compPayloadBlacklistMask: %1" ARG str _compPayloadBlacklistMask]);
			LOG_ALLOCATOR(["_compPayload before: %1" ARG str _compPayload]);
			[_compPayload, _compPayloadBlacklistMask] call comp_fnc_applyBlacklistMask;
			LOG_ALLOCATOR(["_compPayload after: %1" ARG str _compPayload]);
		};

		// Exclude special inf from allocation unless they are in the requiredComp
		[_compPayload, T_PL_inf_special] call comp_fnc_applyBlacklist;

		// Select units we can allocate for transport
		pr _compTransport = +_comp;
		if (count _compTransportWhitelistMask > 0) then {
			[_compTransport, _compTransportWhitelistMask] call comp_fnc_applyWhitelistMask;
		};
		if (count _compTransportBlacklistMask > 0) then {
			[_compTransport, _compTransportBlacklistMask] call comp_fnc_applyBlacklistMask;
		};

		// Exclude special inf from allocation unless they are in the requiredComp
		[_compTransport, T_PL_inf_special] call comp_fnc_applyBlacklist;

		LOG_ALLOCATOR(["- - - - - -"]);
		LOG_ALLOCATOR_COMP("Payload composition after masks:", _compPayload);
		LOG_ALLOCATOR(["- - - - - -"]);
		LOG_ALLOCATOR_COMP("Transport composition after masks:", _compTransport);

		// Initialize variables
		pr _allocated = false;
		pr _failedToAllocate = false;
		pr _compAllocated = [0] call comp_fnc_new;	// Allocated composition
		pr _effAllocated = +T_EFF_null;				// Allocated efficiency
		pr _nIteration = 0;
		pr _effSorted = T_efficiencySorted;

		// Attempt to satisfy the composition requirements if they are specified
		{
			_x params ["_catID", "_subcatID", "_required"];

			// Do we have enough of this type available?
			pr _avail = _compRemaining#_catID#_subcatID;
			if(_avail < _required) exitWith {
				LOG_ALLOCATOR_META("  Failed to satisfy comp requirement %1 %2 %3", _catID, _subcatID);
				// If we fail to satisfy composition requirements then we can fail immediately
				// Still complete the function to set the cache value for later though
				_failedToAllocate = true;
			};

			// Update.
			pr _effToAdd = [T_efficiency#_catID#_subcatID, _required] call eff_fnc_mul_scalar;
			[_effAllocated, _effToAdd] call eff_fnc_acc_add;	// Add with accumulation
			[_effRemaining, _effToAdd] call eff_fnc_acc_diff;	// Substract with accumulation
			// Substract from payload and transport, it we are satisfying the constraint for both when 
			// we satisfy it for either.
			[_compPayload, _catID, _subcatID, -_required] call comp_fnc_addValue;
			[_compTransport, _catID, _subcatID, -_required] call comp_fnc_addValue;
			// Adjust the running totals.
			[_compRemaining, _catID, _subcatID, -_required] call comp_fnc_addValue;
			[_compAllocated, _catID, _subcatID, _required] call comp_fnc_addValue;
		} forEach _requiredComp;

		// Start the allocation iterations
		while {!_allocated && !_failedToAllocate && (_nIteration < 100)} do { // Should we limit amount of iterations??

			_CREATE_PROFILE_SCOPE("ALLOCATE UNITS - iteration");

			LOG_ALLOCATOR([""]);
			LOG_ALLOCATOR(["Iteration: %1" ARG _nIteration]);

			// Get allocated efficiency
			LOG_ALLOCATOR_COMP("Allocated composition:", _compAllocated);
			LOG_ALLOCATOR(["  Allocated eff: %1" ARG _effAllocated]);
			LOG_ALLOCATOR(["  Remaining eff: %1" ARG _effRemaining]);
			LOG_ALLOCATOR(["  External  eff: %1" ARG _effExt]);

			// Validate against provided constrain functions
			pr _unsatisfied = []; // Array of unsatisfied criteria
			for "_i" from 0 to ((count _constraintFnNames) - 1) do {
				_CREATE_PROFILE_SCOPE("Get unsatisfied constraints");
				pr _newConstraints = [_effAllocated, _effExt] call ( missionNamespace getVariable (_constraintFnNames#_i) );
				_unsatisfied append _newConstraints;
				if (count _newConstraints > 0) exitWith {}; // Bail on occurance of first unsatisfied constraint
			};

			LOG_ALLOCATOR(["  Unsatisfied constraints: %1" ARG _unsatisfied]);

			// If there are no unsatisfied constraints, break the loop
			if ((count _unsatisfied) == 0) then {
				LOG_ALLOCATOR(["  Allocated enough units!"]);
				_allocated = true;
			} else {
				pr _constraint = _unsatisfied#0#0;
				pr _constraintValue = _unsatisfied#0#1;

				// Select the array with units sorted by their capability to satisfy constraint
				pr _constraintTransport = _constraint in T_EFF_constraintsTransport;	// True if we are satisfying a transport constraint

				LOG_ALLOCATOR(["  Trying to satisfy constraints: %1" ARG _constraint]);
				// Try to find a unit to satisfy this constraint
				pr _potentialUnits = if (_constraintTransport) then {
					_CREATE_PROFILE_SCOPE("Select units");
					_effSorted#_constraint select { // Array of value, catID, subcatID, sorted by value
						(_compTransport#(_x#1)#(_x#2)) > 0
					};
				} else {
					_CREATE_PROFILE_SCOPE("Select units");
					_effSorted#_constraint select { // Array of value, catID, subcatID, sorted by value
						(_compPayload#(_x#1)#(_x#2)) > 0
					};
				};

				LOG_ALLOCATOR(["  Potential units: %1" ARG _potentialUnits]);

				pr _found = false;
				pr _count = count _potentialUnits;
				if (_count > 0) then {
					pr _ID = 0;
					
					// If we oversatisfy this constraint, try to find units which satisfy this less, we dont want to use expensive units too much
					if (	( (!_constraintTransport) /* || (_constraintTransport && _payloadSatisfied) */ ) && // Payload constraint   // --- , or transport and there are no more payload constraints
							{ (_potentialUnits#_ID#0 > _constraintValue) && (_count > 1) }) then {
						_CREATE_PROFILE_SCOPE("select smallest ID");
						while { (_ID < (_count - 1)) } do {
							if ((_potentialUnits#(_ID+1)#0 < _constraintValue)) exitWith {};
							_ID = _ID + 1;
						};
					} else {
						// Try to pick a random unit if there are many units with same capability
						_CREATE_PROFILE_SCOPE("select random ID");
						pr _value = _potentialUnits#0#0;
						pr _index = _potentialUnits findIf {_x#0 != _value};
						if (_index != -1) then {
							_ID = floor (random _index);
						} else {
							_ID = floor (random _count);
						};
						LOG_ALLOCATOR(["  Generated random ID: %1" ARG _ID]);
					};

					_CREATE_PROFILE_SCOPE("_end of iteration");

					pr _catID = _potentialUnits#_ID#1;
					pr _subcatID = _potentialUnits#_ID#2;
					pr _effToAdd = T_efficiency#_catID#_subcatID;
					[_effAllocated, _effToAdd] call eff_fnc_acc_add;					// Add with accumulation
					[_effRemaining, _effToAdd] call eff_fnc_acc_diff;					// Substract with accumulation
					[_compPayload, _catID, _subcatID, -1] call comp_fnc_addValue;		// Substract from both since they might have same units in them
					[_compTransport, _catID, _subcatID, -1] call comp_fnc_addValue;
					[_compRemaining, _catID, _subcatID, -1] call comp_fnc_addValue;
					[_compAllocated, _catID, _subcatID, 1] call comp_fnc_addValue;

					LOG_ALLOCATOR(["  Allocated unit: %1" ARG (T_NAMES select _catID select _subcatID)]);

					_found = true;
					//_nextRandomID = _nextRandomID + 1;
				} else {
					// Can't find any more units!
					LOG_ALLOCATOR(["  Failed to find a unit!"]);
				};
				
				// If we've looked through all the units and couldn't find one to help us safisfy this constraint, raise a failedToAllocate flag
				_failedToAllocate = !_found;
				_nIteration = _nIteration + 1;
			};
		};
		LOG_ALLOCATOR(["Allocation finished. Iterations: %1, Allocated: %2, failed: %3" ARG _nIteration ARG _allocated ARG _failedToAllocate]);

		pr _result = if (!_allocated || _failedToAllocate) then {
			// Could not allocate units!
			LOG_ALLOCATOR([""]);
			LOG_ALLOCATOR(["  Failed to allocate units!"]);
			[]
		} else {
			LOG_ALLOCATOR([""]);
			LOG_ALLOCATOR_COMP("  Allocated successfully:", _compAllocated);
			[_compAllocated, _effAllocated, _compRemaining, _effRemaining]
		};

		// Add result to the cache
		// Make sure we don't add too many entries
		CRITICAL_SECTION {	// Multiple allocators might run at once by multiple commanders...
			pr _allKeys = GETSV("GarrisonModel", "allocatorCacheAllKeys");
			pr _counter = GETSV("GarrisonModel", "allocatorCacheCounter");
			pr _existingKey = _allKeys#_counter;
			if ( count _existingKey > 0 ) then { // It's not a ""
				// There is an existing entry here, need to delete it from the cache
				// Because we want to limit the cache size
				_hashMap setVariable [_existingKey, nil];
			};

			pr _valueInCache = +_result;
			_allKeys set [_counter, _hashMapKey];
			_hashMap setVariable [_hashMapKey, _valueInCache];
			_counter = (_counter + 1) % ALLOCATOR_CACHE_SIZE;
			SETSV("GarrisonModel", "allocatorCacheCounter", _counter);
		};

		_result
	ENDMETHOD;

	public STATIC_METHOD(initUnitAllocatorCache)
		params [P_THISCLASS];

		// Bail if already initialized
		if (!isNil {GETSV(_thisClass, "allocatorCache")}) exitWith {};

		#ifdef _SQF_VM
		pr _hm = "dummy" createVehicle [1, 2, 3];
		#else
		pr _hm = [false] call CBA_fnc_createNamespace;
		#endif
		SETSV(_thisClass, "allocatorCache", _hm);
		SETSV(_thisClass, "allocatorCacheNHit", 0);
		SETSV(_thisClass, "allocatorCacheNMiss", 0);
		pr _allkeys = [];
		_allKeys resize ALLOCATOR_CACHE_SIZE;
		_allKeys = _allKeys apply {""};
		SETSV(_thisClass, "allocatorCacheAllKeys", _allKeys);
		SETSV(_thisClass, "allocatorCacheCounter", 0);
	ENDMETHOD;

	// -------------------- S C O R I N G   T O O L K I T / U T I L S -------------------
	public STATIC_METHOD(transportRequired)
		params [P_THISOBJECT, P_ARRAY("_eff")];
		_eff#T_EFF_reqTransport
	ENDMETHOD;

	// ------------------------- Intel -----------------------------------
	// Adds known friendly locations closer that _radius from the _pos
	public METHOD(addKnownFriendlyLocationsActual)
		params [P_THISOBJECT, P_POSITION("_pos"), P_NUMBER("_radius")];

		private _actual = T_GETV("actual");
		ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when Actual is not valid");

		// Bail if the garrison has been unregistered/destroyed
		if (T_CALLM0("isDead")) exitWith {};

		private _world = T_GETV("world");
		private _side = T_GETV("side");
		private _nearLocs = CALLM0(_world, "getLocations") select { // Array of location models
			((GETV(_x, "pos") distance2D _pos) < _radius) &&		// Is close enough
			{!IS_NULL_OBJECT(CALLM1(_x, "getGarrison", _side))}	// Belongs to our side (right now at least!)
		};

		private _AI = CALLM0(_actual, "getAI");
		{
			private _locActual = GETV(_x, "actual");
			CALLM2(_AI, "postMethodAsync", "addKnownFriendlyLocation", [_locActual]);
		} forEach _nearLocs;

	ENDMETHOD;
	
ENDCLASS;

// Initialize the unit allocator hashmap
if (IS_SERVER || !HAS_INTERFACE) then {
	CALLSM0("GarrisonModel", "initUnitAllocatorCache");
};

// Unit test
#ifdef _SQF_VM

["GarrisonModel.new(actual)", {
	private _actual = NEW("Garrison", [GARRISON_TYPE_GENERAL ARG WEST]);
	private _world = NEW("WorldModel", [WORLD_TYPE_REAL]);
	private _garrison = NEW("GarrisonModel", [_world ARG _actual]);
	private _class = OBJECT_PARENT_CLASS_STR(_garrison);
	!(isNil "_class")
}] call test_AddTest;

["GarrisonModel.new(sim)", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	private _class = OBJECT_PARENT_CLASS_STR(_garrison);
	!(isNil "_class")
}] call test_AddTest;

["GarrisonModel.simCopy", {
	private _actual = NEW("Garrison", [GARRISON_TYPE_GENERAL ARG WEST]);
	private _world = NEW("WorldModel", [WORLD_TYPE_REAL]);
	private _garrison = NEW("GarrisonModel", [_world ARG _actual]);
	private _simWorld = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _copy = CALLM1(_garrison, "simCopy", _simWorld);
	private _class = OBJECT_PARENT_CLASS_STR(_copy);
	!(isNil "_class")
}] call test_AddTest;

["GarrisonModel.delete", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	SETV(_garrison, "efficiency", EFF_MIN_EFF);
	DELETE(_garrison);
	private _class = OBJECT_PARENT_CLASS_STR(_garrison);
	isNil "_class"
}] call test_AddTest;

["GarrisonModel.killed", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	SETV(_garrison, "efficiency", EFF_MIN_EFF);
	CALLM0(_garrison, "killed");
	CALLM0(_garrison, "isDead")
}] call test_AddTest;

["GarrisonModel.isDead", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	SETV(_garrison, "efficiency", EFF_MIN_EFF);
	["False before killed", !CALLM0(_garrison, "isDead")] call test_Assert;
	CALLM0(_garrison, "killed");
	["True after killed", CALLM0(_garrison, "isDead")] call test_Assert;
}] call test_AddTest;

["GarrisonModel.UnitAllocator", {

		pr _comp = [30] call comp_fnc_new;
		pr _eff = [_comp] call comp_fnc_getEfficiency;

		pr _effExt = +T_EFF_null;		// "External" requirement we must satisfy during this allocation
		// Fill in units which we must destroy
		_effExt set [T_EFF_soft, 10];
		//_effExt set [T_EFF_medium, 3];
		_effExt set [T_EFF_armor, 3];

		pr _validationFlags = [SPLIT_VALIDATE_ATTACK, SPLIT_VALIDATE_CREW, SPLIT_VALIDATE_TRANSPORT]; // "eff_fnc_validateDefense"
		pr _payloadWhitelistMask = T_comp_ground_or_infantry_mask;
		pr _payloadBlacklistMask = T_comp_static_mask;					// Don't take static weapons under any conditions
		pr _transportWhitelistMask = T_comp_ground_or_infantry_mask;	// Take ground units, take any infantry to satisfy crew requirements
		pr _transportBlacklistMask = [];
		pr _requiredComp = [
			[T_INF, T_INF_officer, 1]
		];

		pr _args = [_effExt, _validationFlags, _comp, _eff,
					_payloadWhitelistMask, _payloadBlacklistMask,
					_transportWhitelistMask, _transportBlacklistMask,
					_requiredComp];
		pr _result = CALLSM("GarrisonModel", "allocateUnits", _args);

		_result params ["_compAllocated", "_effAllocated", "_compRemaining", "_effRemaining"];

		//[_compAllocated, "Allocated composition:"] call comp_fnc_print;

		// Verify that the allocated forces can deal with the threat
		pr _effAllocated = [_compAllocated] call comp_fnc_getEfficiency;
		pr _constraintsUnsatisfied = [_effAllocated, _effExt] call eff_fnc_validateAttack;

		["Allocated successfully", (count _effAllocated) > 0] call test_Assert;
		["Can destroy enemy", (count _constraintsUnsatisfied) == 0] call test_Assert;

		pr _c1 = +_compAllocated;
		[_c1, _compRemaining] call comp_fnc_addAccumulate;
		["Compositions match", _c1 isEqualTo _comp] call test_Assert;

		["Required composition present", _compAllocated#T_INF#T_INF_officer == 1] call test_Assert;

		["Efficiencies match", EFF_ADD(_effAllocated, _effRemaining) isEqualTo _eff] call test_Assert;

}] call test_AddTest;

["GarrisonModel.simSplit", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);

	private _comp0 = [10] call comp_fnc_new;
	private _eff0 = [_comp0] call comp_fnc_getEfficiency;

	private _comp1 = [2] call comp_fnc_new;
	private _eff1 = [_comp1] call comp_fnc_getEfficiency;

	private _compResult = [10-2] call comp_fnc_new;
	private _effResult = [_compResult] call comp_fnc_getEfficiency;

	SETV(_garrison, "efficiency", _eff0);
	SETV(_garrison, "composition", _comp0);

	private _splitGarr = CALLM2(_garrison, "splitSim", _comp1, _eff1);

	["Orig eff", GETV(_garrison, "efficiency") isEqualTo _effResult] call test_Assert;
	["Orig comp", GETV(_garrison, "composition") isEqualTo _compResult] call test_Assert;
	["Split eff", GETV(_splitGarr, "efficiency") isEqualTo _eff1] call test_Assert;
	["Split comp", GETV(_splitGarr, "composition") isEqualTo _comp1] call test_Assert;
}] call test_AddTest;


["GarrisonModel.mergeSim", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);

	private _garrison0 = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	private _comp0 = [10] call comp_fnc_new;
	private _eff0 = [_comp0] call comp_fnc_getEfficiency;
	SETV(_garrison0, "efficiency", _eff0);
	SETV(_garrison0, "composition", _comp0);

	private _garrison1 = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	private _comp1 = [2] call comp_fnc_new;
	private _eff1 = [_comp1] call comp_fnc_getEfficiency;
	SETV(_garrison1, "efficiency", _eff1);
	SETV(_garrison1, "composition", _comp1);

	private _compResult = [10+2] call comp_fnc_new;
	private _effResult = [_compResult] call comp_fnc_getEfficiency;

	CALLM1(_garrison0, "mergeSim", _garrison1);

	["Merge eff", GETV(_garrison1, "efficiency") isEqualTo _effResult] call test_Assert;
	["Merge comp", GETV(_garrison1, "composition") isEqualTo _compResult] call test_Assert;
}] call test_AddTest;

Test_group_args = [WEST, 0]; // Side, group type
Test_unit_args = [tNATO, T_INF, T_INF_rifleman, -1];

["GarrisonModel.actualSplit", {
	private _actual = NEW("Garrison", [GARRISON_TYPE_GENERAL ARG WEST]);
	private _group = NEW("Group", Test_group_args);
	private _eff1 = +T_EFF_null;
	private _comp1 = +T_comp_null;
	for "_i" from 0 to 19 do
	{
		private _unit = NEW("Unit", Test_unit_args + [_group]);
		private _unitEff = CALLM0(_unit, "getEfficiency");
		_eff1 = EFF_ADD(_eff1, _unitEff);
		[_comp1, T_INF, T_INF_rifleman, 1] call comp_fnc_addValue;
	};

	CALLM1(_actual, "addGroup", _group);
	
	private _world = NEW("WorldModel", [WORLD_TYPE_REAL]);
	private _garrison = NEW("GarrisonModel", [_world ARG _actual]);
	["Initial eff", GETV(_garrison, "efficiency") isEqualTo _eff1] call test_Assert;
	["Initial comp", GETV(_garrison, "composition") isEqualTo _comp1] call test_Assert;

	private _compToDetach = [0] call comp_fnc_new;
	(_compToDetach#T_INF) set [T_INF_rifleman, 3];
	private _effToDetach = [_compToDetach] call comp_fnc_getEfficiency;

	private _effRemains = EFF_DIFF(_eff1, _effToDetach);
	SETV(_garrison, "efficiency", _eff1);

	private _splitGarr = CALLM2(_garrison, "splitActual", _compToDetach, _effToDetach);

	["Split successfull", !IS_NULL_OBJECT(_splitGarr)] call test_Assert;

	// Sync the Models
	CALLM0(_garrison, "sync");
	CALLM0(_splitGarr, "sync");

	// diag_log format["garr eff: %1, effr: %2", GETV(_garrison, "efficiency"), _effr];
	// diag_log format["split garr eff: %1, effr: %2", GETV(_splitGarr, "efficiency"), _eff2];

	["Orig eff", EFF_MASK_DEF_ATT(GETV(_garrison, "efficiency")) isEqualTo EFF_MASK_DEF_ATT(_effRemains)] call test_Assert;
	["Split eff", EFF_MASK_DEF_ATT(GETV(_splitGarr, "efficiency")) isEqualTo EFF_MASK_DEF_ATT(_effToDetach)] call test_Assert;
}] call test_AddTest;
#endif