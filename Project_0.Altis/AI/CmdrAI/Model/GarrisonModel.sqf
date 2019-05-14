#include "..\common.hpp"
#include "..\..\..\Group\Group.hpp"
#include "..\..\parameterTags.hpp"
#include "..\..\Action\Action.hpp"

// GarrisonModel_getThread = {
// 	params ["_garrisonModel"];
// 	// Can't use normal accessor because it would cause an infinite loop!
// 	private _side = FORCE_GET_MEM(_garrisonModel, "side");
// 	if(!isNil "_side") then {
// 		private _AICommander = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_side]);
// 		if(!IS_NULL_OBJECT(_AICommander)) then {
// 			GETV(CALLM(_AICommander, "getMessageLoop", []), "scriptHandle")
// 		} else {
// 			nil
// 		}
// 	}
// };

// Model of a Real Garrison. This can either be the Actual model or the Sim model.
// The Actual model represents the Real Garrison as it currently is. A Sim model
// is a copy that is modified during simulations.
CLASS("GarrisonModel", "ModelBase")
	// Strength vector of the garrison.
	VARIABLE_ATTR("efficiency", []);
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
	// What side this garrison belongs to.
	VARIABLE_ATTR("side", []);
	// Id of the location the garrison is currently occupying.
	VARIABLE_ATTR("locationId", [ATTR_GET_ONLY]);

	METHOD("new") {
		params [P_THISOBJECT, P_STRING("_world"), P_STRING("_actual")];

		//T_SETV_REF("order", objNull);
		T_SETV("action", NULL_OBJECT);
		// These will get set in sync
		T_SETV("efficiency", +EFF_ZERO);
		T_SETV("transport", 0);
		T_SETV("inCombat", false);
		T_SETV("pos", []);
		T_SETV("side", sideUnknown);
		T_SETV("locationId", MODEL_HANDLE_INVALID);
		if(!IS_NULL_OBJECT(_actual)) then {
			T_CALLM("sync", []);
		};
		// Add self to world
		CALLM(_world, "addGarrison", [_thisObject]);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];
		T_CALLM("killed", []);
	} ENDMETHOD;

	METHOD("simCopy") {
		params [P_THISOBJECT, P_STRING("_targetWorldModel")];
		ASSERT_OBJECT_CLASS(_targetWorldModel, "WorldModel");

		private _copy = NEW("GarrisonModel", [_targetWorldModel]);

		#ifdef OOP_ASSERT
		private _idsEqual = T_GETV("id") == GETV(_copy, "id");
		private _msg = format ["%1 id (%2) out of sync with sim copy %3 id (%4)", _thisObject, T_GETV("id"), _copy, GETV(_copy, "id")];
		ASSERT_MSG(_idsEqual, _msg);
		#endif

		//	"Id of the GarrisonModel copy is out of sync with the original. This indicates the world garrison list isn't being copied correctly?");
		//SETV(_copy, "id", T_GETV("id"));
		SETV(_copy, "label", T_GETV("label"));
		SETV(_copy, "efficiency", +T_GETV("efficiency"));
		SETV(_copy, "transport", +T_GETV("transport"));
		//SETV_REF(_copy, "order", T_GETV("order"));
		T_PRVAR(action);
		// Copy it properly so the action gets register/unregister messages
		if(!IS_NULL_OBJECT(_action)) then {
			CALLM(_copy, "setAction", [_action]);
		};
		//SETV(_copy, "action", T_GETV("action"));
		SETV(_copy, "inCombat", T_GETV("inCombat"));
		SETV(_copy, "pos", +T_GETV("pos"));
		SETV(_copy, "side", T_GETV("side"));
		SETV(_copy, "locationId", T_GETV("locationId"));
		_copy
	} ENDMETHOD;

	/* private */ METHOD("_sync") {
		params [P_THISOBJECT, P_OOP_OBJECT("_actual")];

		if(CALLM(_actual, "isDestroyed", [])) exitWith {
			T_CALLM("killed", []);
		};

		private _newEff = CALLM(_actual, "getEfficiencyMobile", []);
		if(EFF_LTE(_newEff, EFF_ZERO)) then {
			T_CALLM("killed", []);
		} else {
			private _actualSide = CALLM(_actual, "getSide", []);
			T_SETV("side", _actualSide);
			
			T_SETV("efficiency", _newEff);

			// Get seats only for trucks as we care about this most
			private _seats = CALLM(_actual, "getTransportCapacity", [[T_VEH_truck_inf]]);
			T_SETV("transport", _seats);
			
			private _actualPos = CALLM(_actual, "getPos", []);
			T_SETV("pos", +_actualPos);


			//OOP_DEBUG_MSG("Updating %1 from %2@%3", [_thisObject ARG _actual ARG _actualPos]);
			private _locationActual = CALLM(_actual, "getLocation", []);
			if(!IS_NULL_OBJECT(_locationActual)) then {
				T_PRVAR(world);
				private _location = CALLM(_world, "findOrAddLocationByActual", [_locationActual]);
				T_SETV("locationId", GETV(_location, "id"));
				// Don't call the proper functions because it deals with updating the LocationModel
				// and we don't need to do that in sync (LocationModel sync does it)
				//T_CALLM("attachToLocation", [_location]);
			} else {
				T_SETV("locationId", MODEL_HANDLE_INVALID);
				//T_CALLM("detachFromLocation", []);
			};
		};
	} ENDMETHOD;
	
	METHOD("sync") {
		params [P_THISOBJECT];

		T_PRVAR(actual);
		// If we have an assigned real garrison then sync from it
		if(!IS_NULL_OBJECT(_actual)) then {
			ASSERT_OBJECT_CLASS(_actual, "Garrison");

			CALLM(_actual, "runLocked", [_thisObject ARG "_sync" ARG [_actual]]);

			// private _newEff = CALLM(_actual, "getEfficiencyMobile", []);
			// if(EFF_LTE(_newEff, EFF_ZERO)) then {
			// 	T_CALLM("killed", []);
			// } else {
			// 	private _actualSide = CALLM(_actual, "getSide", []);
			// 	T_SETV("side", _actualSide);
				
			// 	T_SETV("efficiency", _newEff);
				
			// 	private _actualPos = CALLM(_actual, "getPos", []);
			// 	T_SETV("pos", +_actualPos);


			// 	//OOP_DEBUG_MSG("Updating %1 from %2@%3", [_thisObject ARG _actual ARG _actualPos]);
			// 	private _locationActual = CALLM(_actual, "getLocation", []);
			// 	if(!IS_NULL_OBJECT(_locationActual)) then {
			// 		T_PRVAR(world);
			// 		private _location = CALLM(_world, "findOrAddLocationByActual", [_locationActual]);
			// 		T_SETV("locationId", GETV(_location, "id"));
			// 		// Don't call the proper functions because it deals with updating the LocationModel
			// 		// and we don't need to do that in sync (LocationModel sync does it)
			// 		//T_CALLM("attachToLocation", [_location]);
			// 	} else {
			// 		T_SETV("locationId", MODEL_HANDLE_INVALID);
			// 		//T_CALLM("detachFromLocation", []);
			// 	};
			// };
		};
	} ENDMETHOD;

	// Garrison is empty (not necessarily killed, could be merged to another garrison etc.)
	METHOD("killed") {
		params [P_THISOBJECT];

		T_PRVAR(world);
		T_SETV("efficiency", +EFF_ZERO);
		T_SETV("transport", 0);
		T_CALLM("detachFromLocation", []);
		CALLM(_world, "garrisonKilled", [_thisObject]);
		T_CALLM("clearAction", []);
		OOP_DEBUG_MSG("Killed %1", [_thisObject]);
	} ENDMETHOD;

	METHOD("attachToLocation") {
		params [P_THISOBJECT, P_STRING("_location")];
		ASSERT_OBJECT_CLASS(_location, "LocationModel");

		ASSERT_MSG(T_GETV("locationId") == MODEL_HANDLE_INVALID, "Garrison already attached to another location");

		CALLM(_location, "addGarrison", [_thisObject]);
		T_SETV("locationId", GETV(_location, "id"));
		OOP_DEBUG_MSG("Attached %1 to location %2", [_thisObject ARG _location]);
	} ENDMETHOD;

	METHOD("detachFromLocation") {
		params [P_THISOBJECT];
		private _location = T_CALLM("getLocation", []);
		if(!IS_NULL_OBJECT(_location)) then {
			CALLM(_location, "removeGarrison", [_thisObject]);
			T_SETV("locationId", MODEL_HANDLE_INVALID);
			OOP_DEBUG_MSG("Detached %1 from location %2", [_thisObject ARG _location]);
		};
	} ENDMETHOD;

	METHOD("isBusy") {
		params [P_THISOBJECT];
		!IS_NULL_OBJECT(T_GETV("action"))
	} ENDMETHOD;

	METHOD("getAction") {
		params [P_THISOBJECT];
		T_GETV("action")
	} ENDMETHOD;

	METHOD("setAction") {
		params [P_THISOBJECT, P_STRING("_action")];
		// Clear previous action first
		T_CALLM("clearAction", []);
		T_SETV("action", _action);
		CALLM(_action, "registerGarrison", [_thisObject]);
	} ENDMETHOD;

	METHOD("clearAction") {
		params [P_THISOBJECT];
		private _currentAction = T_GETV("action");
		if(!IS_NULL_OBJECT(_currentAction)) then {
			CALLM(_currentAction, "unregisterGarrison", [_thisObject]);
		};
		T_SETV("action", NULL_OBJECT);
	} ENDMETHOD;

	METHOD("isDead") {
		params [P_THISOBJECT];
		T_PRVAR(efficiency);
		_efficiency isEqualTo EFF_ZERO //or {EFF_LTE(_efficiency, EFF_ZERO)}
	} ENDMETHOD;

	METHOD("isDepleted") {
		params [P_THISOBJECT];
		T_PRVAR(efficiency);
		!EFF_GT(_efficiency, EFF_MIN_EFF)
	} ENDMETHOD;

	METHOD("getLocation") {
		params [P_THISOBJECT];
		T_PRVAR(locationId);
		T_PRVAR(world);
		if(_locationId != MODEL_HANDLE_INVALID) exitWith { CALLM(_world, "getLocation", [_locationId]) };
		NULL_OBJECT
	} ENDMETHOD;

	// -------------------- S I M  /  A C T U A L   M E T H O D   P A I R S -------------------
	// Does this make sense? Could the sim/actual split be handled in a single functions
	// instead? Need the concept of operations that take time, and they only apply to 
	// Actual not sim. 

	// SPLIT
	// Flags defined in CmdrAI/common.hpp
	METHOD("splitSim") {
		params [P_THISOBJECT, P_ARRAY("_splitEff"), P_ARRAY("_flags")];
		

		T_PRVAR(efficiency);
		// Make sure to hard cap detachment so we don't drop below min eff
		private _effAllocated = EFF_DIFF(_efficiency, EFF_MIN_EFF);
		_effAllocated = EFF_FLOOR_0(_effAllocated);
		_effAllocated = EFF_MIN(_splitEff, _effAllocated);
		//_splitEff = _effAllocated; //EFF_MIN(_splitEff, EFF_FLOOR_0(EFF_DIFF(_efficiency, EFF_MIN_EFF)));

		if(!EFF_GTE(_effAllocated, _splitEff) && FAIL_UNDER_EFF in _flags) exitWith {
			OOP_WARNING_MSG("ABORTING --- Couldn't allocate required efficiency: wanted %1, got %2", [_splitEff ARG _effAllocated]);
			NULL_OBJECT
		};

		private _detachment = NEW("GarrisonModel", [_world]);
		SETV(_detachment, "efficiency", _effAllocated);
		SETV(_detachment, "pos", +T_GETV("pos"));
		SETV(_detachment, "side", T_GETV("side"));
		private _newEfficiency = EFF_DIFF(_efficiency, _effAllocated);
		T_SETV("efficiency", _newEfficiency);

		if(ASSIGN_TRANSPORT in _flags) then {
			private _transportRequired = CALL_STATIC_METHOD("GarrisonModel", "transportRequired", [_effAllocated]);
			SETV(_detachment, "transport", _transportRequired);
			T_PRVAR(transport);
			private _newTransport = 0 max (_transport - _transportRequired);
			T_SETV("transport", _newTransport);
		};

		OOP_DEBUG_MSG("Sim split %1%2->%3 to %4%5", [_thisObject ARG _efficiency ARG _newEfficiency ARG _detachment ARG _effAllocated]);

		_detachment
	} ENDMETHOD;

	// // ****** W I P - don't use it
	// // Split garrison.
	// // Flags defined in CmdrAI/common.hpp
	// // TODO: cleanup the logging
	// // TODO: factor into separate functions: build a unit/armor composition, select transport, generate the actual garrison.
	// METHOD("generateDetachment") {
	// 	params [P_THISOBJECT, P_ARRAY("_splitEff"), P_ARRAY("_flags")];

	// 	ASSERT_MSG(count _splitEff == count T_EFF_Null, "_splitEff is not a valid efficiency vector (length is wrong)");
	// 	ASSERT_MSG(EFF_SUM(_splitEff) > 0, "_splitEff can't be zero");
	// 	T_PRVAR(actual);
	// 	ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when actual is not valid");


	// 	private _units = CALLM0(_actual, "getUnits") select {! CALLM0(_x, "isStatic")};
	// 	_units = _units apply {private _eff = CALLM0(_x, "getEfficiency"); [0, _eff, _x]};
	// 	_allocatedUnits = [];
	// 	_allocatedGroupsAndUnits = [];
	// 	_allocatedCrew = [];
	// 	_allocatedVehicles = [];
	// 	_allocatedEff = +T_EFF_null;

	// 	// Allocate units per each efficiency category
	// 	private _j = 0;
	// 	for "_i" from T_EFF_ANTI_SOFT to T_EFF_ANTI_AIR do {
	// 		// Exit now if we have allocated enough units
	// 		if(EFF_GTE(_allocatedEff, _splitEff)) exitWith {};

	// 		// For every unit, set element 0 to efficiency value with index _i
	// 		{_x set [0, _x#1#_i];} forEach _units;

	// 		// Sort units in this efficiency category
	// 		_units sort DESCENDING;

	// 		// Add units until there are enough of them
	// 		private _pickUnitID = 0;
	// 		while {(_allocatedEff#_i < _splitEff#_i) && (_pickUnitID < count _units)} do {
	// 			private _unit = _units#_pickUnitID#2;
	// 			private _group = CALLM0(_unit, "getGroup");
	// 			private _groupType = if (_group != "") then {CALLM0(_group, "getType")} else {GROUP_TYPE_IDLE};
	// 			// Try not to take troops from vehicle groups
	// 			private _ignore = (CALLM0(_unit, "isInfantry") && _groupType in [GROUP_TYPE_VEH_NON_STATIC, GROUP_TYPE_VEH_STATIC]);
				
	// 			if (!_ignore) then {							
	// 				// If it was a vehicle, and it had crew in its group, add the crew as well
	// 				if (CALLM0(_unit, "isVehicle")) then {
	// 					private _groupUnits = if (_group != "") then {CALLM0(_group, "getUnits");} else {[]};
	// 					// If there are more than one unit in a vehicle's group, then add the whole group
	// 					if (count _groupUnits > 1) then {
	// 						_allocatedGroupsAndUnits pushBackUnique [_group, +CALLM0(_group, "getUnits")];
	// 						// Add allocated crew to array
	// 						{
	// 							if (CALLM0(_x, "isInfantry")) then {
	// 								_allocatedCrew pushBack _x;
	// 							};
	// 						} forEach (CALLM0(_group, "getUnits"));
	// 					} else {
	// 						_allocatedUnits pushBackUnique _unit;
	// 					};
	// 					_allocatedVehicles pushBack _unit;
	// 					OOP_INFO_2("    Added vehicle unit: %1, %2", _unit, CALLM0(_unit, "getClassName"));
	// 				} else {
	// 					OOP_INFO_2("    Added infantry unit: %1, %2", _unit, CALLM0(_unit, "getClassName"));
	// 					_allocatedUnits pushBack _unit;
	// 				};
	// 				private _unitEff = _units#_pickUnitID#1;
	// 				// Add to the allocated efficiency vector
	// 				_allocatedEff = EFF_ADD(_allocatedEff, _unitEff);
	// 				//OOP_INFO_1("     New efficiency value: %1", _allocatedEff);
	// 			};
	// 			_pickUnitID = _pickUnitID + 1;
	// 		};
	// 	};
		
	// 	OOP_INFO_3("   Found units: %1, groups: %2, efficiency: %3", _allocatedUnits, _allocatedGroupsAndUnits, _allocatedEff);

	// 	if(!EFF_GTE(_allocatedEff, _splitEff) && (FAIL_UNDER_EFF in _flags)) exitWith {
	// 		OOP_WARNING_MSG("   ABORTING --- Couldn't allocate required efficiency: wanted %1, got %2", [_splitEff ARG _allocatedEff]);
	// 		[]
	// 	};

	// 	private _nCrewRequired = CALLSM1("Unit", "getRequiredCrew", _allocatedVehicles);
	// 	_nCrewRequired params ["_nDrivers", "_nTurrets"];
	// 	private _nInfAllocated = { CALLM0(_x, "isInfantry") } count _allocatedUnits;

	// 	// Do we need to find crew for vehicles?
	// 	if ((_nDrivers + _nTurrets) > (_nInfAllocated + count _allocatedCrew)) then {
	// 		private _nMoreCrewRequired = _nDrivers + _nTurrets - _nInfAllocated - (count _allocatedCrew);
	// 		OOP_INFO_1("Allocating additional crew: %1 units", _nMoreCrewRequired);
	// 		private _freeInfUnits = CALLM0(_actual, "getInfantryUnits") select {
	// 			if (_x in _allocatedUnits) then { false } else {
	// 				private _group = CALLM0(_x, "getGroup");
	// 				if (_group == "") then { false } else {
	// 					if (CALLM0(_group, "getType") in [GROUP_TYPE_IDLE, GROUP_TYPE_PATROL, GROUP_TYPE_BUILDING_SENTRY]) then {
	// 						true
	// 					} else {false};
	// 				};
	// 			};
	// 		};
			
	// 		// Are there enough units left?
	// 		if (count _freeInfUnits < _nMoreCrewRequired) then {
	// 			// Not enough infantry here to equip all the vehicles we have allocated
	// 			// Go check other locations
	// 			OOP_INFO_0("   Failed to allocate additional crew");
	// 			breakTo "scopeLocLoop";
	// 		} else {
	// 			private _crewToAdd = _freeInfUnits select [0, _nMoreCrewRequired];
				
	// 			OOP_INFO_1("   Successfully allocated additional crew: %1", _crewToAdd);
	// 			// Add the allocated units to the array
	// 			_allocatedUnits append _crewToAdd;
	// 		};
	// 	};
	// } ENDMETHOD;

	METHOD("splitActual") {
		params [P_THISOBJECT, P_ARRAY("_splitEff"), P_ARRAY("_flags")];

		ASSERT_MSG(EFF_SUM(_splitEff) > 0, "_splitEff can't be zero");
		T_PRVAR(actual);
		ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when Actual is not valid");

		OOP_INFO_MSG("%1", [_this]);

		private _side = CALLM(_actual, "getSide", []);
		private _units = CALLM0(_actual, "getUnits") select { 
			// Not interested in statics
			!CALLM0(_x, "isStatic") and
			// Don't want crew
			{
				private _group = CALLM0(_x, "getGroup");
				private _groupType = if (_group != "") then {CALLM0(_group, "getType")} else {GROUP_TYPE_IDLE};
				// Try not to take troops from vehicle groups
				!(CALLM0(_x, "isInfantry") && _groupType in [GROUP_TYPE_VEH_NON_STATIC, GROUP_TYPE_VEH_STATIC])
			} and
			// Only want infantry or combat vehicles (not transports, we will assign them after)
			{ 
				CALLM0(_x, "isInfantry") or
				{
					CALLM0(_x, "getMainData") params ["_catID", "_subcatID"];
					_catID == T_VEH and
					{
						_subcatID in T_VEH_ground_combat
					}
				}
			}
		} apply {
			private _eff = CALLM0(_x, "getEfficiency");
			[0, _eff, _x]
		};

		_allocatedUnits = [];
		_allocatedGroupsAndUnits = [];
		_allocatedCrew = [];
		_allocatedVehicles = [];
		_effAllocated = +T_EFF_null;
		
		private _requiredStrength = EFF_SUB_SUM(EFF_ATT_SUB(_splitEff));
		private _infStrength = 0;
		private _vehStrength = 0;

		// Allocate units per each efficiency category
		for "_i" from T_EFF_ANTI_SOFT to T_EFF_ANTI_AIR do {
			
			// Exit now if we have allocated enough units
			if(EFF_GTE(_effAllocated, EFF_MASK_ATT(_splitEff))) exitWith {};

			
			// Add units until there are enough of them
			private _pickUnitID = 0;
			while {(_effAllocated#_i < _splitEff#_i)} do {

				OOP_INFO_MSG("_requiredStrength=%1, _infStrength=%2, _vehStrength=%3", [_requiredStrength ARG _infStrength ARG _vehStrength]);
				// For every unit, set element 0 to efficiency value with index _i modified by
				// biasing hints.
				{
					_x params ["_effElem", "_unitEff", "_unit"];
					private _bias = switch true do {
						case (OCCUPYING_FORCE_HINT in _flags): { 
							// Prefer 50% inf force at least
							if(CALLM0(_unit, "isInfantry") and _infStrength <= _requiredStrength * 0.5) then {
								10
							} else {
								1
							};
						};
						case (COMBAT_FORCE_HINT in _flags): { 
							// Prefer spec ops units and covert vehicles
							// TODO: get unit type and bias positive if it is the right class
							1
						};
						case (RECON_FORCE_HINT in _flags): { 
							// Prefer recon units and fast vehicles
							// TODO: get unit type and bias positive if it is the right class
							1
						};
						case (SPEC_OPS_FORCE_HINT in _flags): { 
							// Prefer spec ops units and covert vehicles
							// TODO: get unit type and bias positive if it is the right class
							1
						};
						default { 1 };
					};
					_x set [0, (_unitEff#_i) * _bias];
				} forEach _units;

				
				// Sort units in this efficiency category
				_units sort DESCENDING;

				OOP_INFO_MSG("%1", [_units]);

				_units#0 params ["_effElem", "_unitEff", "_unit"];

				// No more units can fulfill the efficiency requirements for this element
				if(_effElem <= 0) exitWith {};

				// If it was a vehicle, and it had crew in its group, add the crew as well
				if (CALLM0(_unit, "isVehicle")) then {
					private _group = CALLM0(_unit, "getGroup");
					private _groupUnits = if (_group != "") then {CALLM0(_group, "getUnits");} else {[]};
					// If there are more than one unit in a vehicle's group, then add the whole group
					if (count _groupUnits > 1) then {
						_allocatedGroupsAndUnits pushBackUnique [_group, +CALLM0(_group, "getUnits")];
						// Add allocated crew to array
						{
							if (CALLM0(_x, "isInfantry")) then {
								_allocatedCrew pushBack _x;
								_units deleteAt (_units find _x);
							};
						} forEach (CALLM0(_group, "getUnits"));
					} else {
						_allocatedUnits pushBackUnique _unit;
					};
					_allocatedVehicles pushBack _unit;
					OOP_INFO_2("    Added vehicle unit: %1, %2", _unit, CALLM0(_unit, "getClassName"));
					_vehStrength = _vehStrength + EFF_SUB_SUM(EFF_ATT_SUB(_unitEff));
				} else {
					OOP_INFO_2("    Added infantry unit: %1, %2", _unit, CALLM0(_unit, "getClassName"));
					_allocatedUnits pushBack _unit;
					_infStrength = _infStrength + EFF_SUB_SUM(EFF_ATT_SUB(_unitEff));
				};
				// Remove the unit from the available list
				_units deleteAt 0;
				// Add to the allocated efficiency vector
				_effAllocated = EFF_ADD(_effAllocated, _unitEff);
			};
		};
		
		OOP_INFO_3("   Found units: %1, groups: %2, efficiency: %3", _allocatedUnits, _allocatedGroupsAndUnits, _effAllocated);

		if(!EFF_GTE(_effAllocated, _splitEff) && (FAIL_UNDER_EFF in _flags)) exitWith {
			OOP_WARNING_MSG("   ABORTING --- Couldn't allocate required efficiency: wanted %1, got %2", [_splitEff ARG _effAllocated]);
			NULL_OBJECT
		};

		// Check if we have allocated enough units
		//if ([_effAllocated, _splitEff] call t_fnc_canDestroy == T_EFF_CAN_DESTROY_ALL) then {
		
		//OOP_INFO_0("   Allocated units can destroy the threat");
		
		private _nCrewRequired = CALLSM1("Unit", "getRequiredCrew", _allocatedVehicles);
		_nCrewRequired params ["_nDrivers", "_nTurrets"];
		private _nInfAllocated = { CALLM0(_x, "isInfantry") } count _allocatedUnits;
		
		// Do we need to find crew for vehicles?
		if ((_nDrivers + _nTurrets) > (_nInfAllocated + count _allocatedCrew)) then {
			private _nMoreCrewRequired = _nDrivers + _nTurrets - _nInfAllocated - (count _allocatedCrew);
			OOP_INFO_1("Allocating additional crew: %1 units", _nMoreCrewRequired);
			private _freeInfUnits = CALLM0(_actual, "getInfantryUnits") select {
				if (_x in _allocatedUnits) then { false } else {
					private _group = CALLM0(_x, "getGroup");
					if (_group == "") then { false } else {
						if (CALLM0(_group, "getType") in [GROUP_TYPE_IDLE, GROUP_TYPE_PATROL, GROUP_TYPE_BUILDING_SENTRY]) then {
							true
						} else {false};
					};
				};
			};
			
			// Are there enough units left?
			if (count _freeInfUnits < _nMoreCrewRequired) then {
				// Not enough infantry here to equip all the vehicles we have allocated
				// Go check other locations
				OOP_INFO_0("   Failed to allocate additional crew");
				breakTo "scopeLocLoop";
			} else {
				private _crewToAdd = _freeInfUnits select [0, _nMoreCrewRequired];
				
				OOP_INFO_1("   Successfully allocated additional crew: %1", _crewToAdd);
				// Add the allocated units to the array
				_allocatedUnits append _crewToAdd;
			};
		};

		private _allocated = true;

		private _extraUnits = [];
		// Do we need to find transport vehicles?
		if (ASSIGN_TRANSPORT in _flags) then {
			private _nCargoSeatsRequired = _nInfAllocated; // - _nDrivers - _nTurrets;
			private _nCargoSeatsAvailable = CALLSM1("Unit", "getCargoInfantryCapacity", _allocatedVehicles);
			//ade_dumpcallstack;
			OOP_INFO_2("   Finding additional transport vehicles for %1 troops. Currently available cargo seats: %2", _nCargoSeatsRequired, _nCargoSeatsAvailable);
			
			// If we need more vehicles for transport
			if (_nCargoSeatsAvailable < _nCargoSeatsRequired) then {
			
				OOP_INFO_0("   Currently NOT enough cargo seats");
				
				private _nMoreCargoSeatsRequired = _nCargoSeatsRequired - _nCargoSeatsAvailable;
				// Get all remaining vehicles in this garrison, sort them by their cargo infantry capacity
				private _availableVehicles = CALLM0(_actual, "getUnits") select {
					CALLM0(_x, "getMainData") params ["_catID", "_subcatID"];
					// Don't consider vehicles we have already taken and non-transport vehicles
					!(_x in _allocatedVehicles) and {_catID == T_VEH and {_subcatID in T_VEH_ground_transport}}
				}; // select
				private _availableVehiclesCapacity = _availableVehicles apply {[CALLSM1("Unit", "getCargoInfantryCapacity", [_x]), _x]};
				_availableVehiclesCapacity sort DESCENDING;
				
				OOP_INFO_1("   Available additional vehicles with cargo capacity: %1", _availableVehiclesCapacity);
				
				// Add more vehicles while we can
				private _i = 0;
				while {(_nMoreCargoSeatsRequired > 0) && (_i < count _availableVehiclesCapacity)} do {
					_availableVehiclesCapacity#_i params ["_cap", "_veh"];
					OOP_INFO_2("   Added vehicle: %1, with cargo capacity: %2", _veh, _cap);
					_allocatedUnits pushBack _veh;
					_nMoreCargoSeatsRequired = _nMoreCargoSeatsRequired - _cap;
					_i = _i + 1;
				};
				
				// IF we have finally found enough vehicles
				if (_nMoreCargoSeatsRequired <= 0) then {
					OOP_INFO_0("   Successfully allocated additional vehicles!");
					// Success
				} else {
					if(CHEAT_TRANSPORT in _flags) then {
						OOP_INFO_MSG("   %1 more seats required and CHEAT_TRANSPORT specified, creating more trucks", [_nMoreCargoSeatsRequired]);
						// Make trucks until we have enough
						private _template = CALL_STATIC_METHOD("Unit", "getTemplateForSide", [_side]);
						while {_nMoreCargoSeatsRequired > 0} do {
							private _veh = NEW("Unit", [_template ARG T_VEH ARG T_VEH_truck_inf ARG -1 ARG ""]);
							_extraUnits pushBack _veh;
							private _cap = CALLSM1("Unit", "getCargoInfantryCapacity", [_veh]);
							_nMoreCargoSeatsRequired = _nMoreCargoSeatsRequired - _cap;
							OOP_INFO_2("   Created truck: %1, with cargo capacity: %2", _veh, _cap);
						};
					} else {
						// Not enough vehicles for everyone!
						// Check other locations then
						OOP_INFO_0("   Failed to allocate additional vehicles (CHEAT_TRANSPORT not specified)!");
						_allocated = false;
					};
				}; // if (_nMoreCargoSeatsRequired <= 0)
			} else { // if (_nCargoSeatsAvailable < _nCargoSeatsRequired)
				// We don't need more vehicles, it's fine
				OOP_INFO_0("   Currently enough cargo seats");
			}; // if (_nCargoSeatsAvailable < _nCargoSeatsRequired)
			
		} else {
			// No need to find transport vehicles
			// We are done here!
			OOP_INFO_0("   No need to find more transport vehicles");
		}; // (_dist > QRF_NO_TRANSPORT_DISTANCE_MAX) then {
		
		// We couldn't complete allocation so return a failure
		if(!_allocated and (FAIL_WITHOUT_FULL_TRANSPORT in _flags)) exitWith { NULL_OBJECT };

		// Make a new garrison
		private _newGarrActual = NEW("Garrison", [_side]);
		private _pos = CALLM(_actual, "getPos", []);
		CALLM2(_newGarrActual, "postMethodAsync", "setPos", [_pos]);

		// This self registers with the world. From now on we just modify the _newGarrActual itself, the Model gets updated automatically during its
		// update phase.
		// private _newGarr = NEW("GarrisonModel", [_world ARG _newGarrActual]);

		// private _location = T_CALLM("getLocation", []);
		// if(!(_location isEqualType "")) exitWith {
		// 	// TODO: Garrisons shouldn't need to be assigned to a location to be splittable, it makes 
		// 	// no sense.
		// 	FAILURE("Garrison needs to be assigned to location");
		// 	objNull
		// };

		// private _locationActual = GETV(_location, "actual");
		// ASSERT_MSG(_locationActual isEqualType "", "Actual LocationModel required");
		// CALLM(_newGarrActual, "setLocation", [_locationActual]); // This garrison will spawn here if needed
		//CALLM(_newGarrActual, "spawn", []);

		// Try to move the units
		private _args = [_actual, _allocatedUnits, _allocatedGroupsAndUnits];
		private _moveSuccess = CALLM(_newGarrActual, "postMethodSync", ["addUnitsAndGroups" ARG _args]);
		if (!_moveSuccess) exitWith {
			OOP_WARNING_MSG("Couldn't move units to new garrison", []);
			NULL_OBJECT
		};

		if(count _extraUnits > 0) then {
			CALLM(_newGarrActual, "postMethodSync", ["addUnits" ARG [_extraUnits]]);
		};

		OOP_INFO_0("Successfully split garrison");

		// Register it at the commander (do it after adding the units so the sync is correct)
		#ifndef _SQF_VM
		private _newGarr = CALLM(_newGarrActual, "activate", []);
		#else
		private _newGarr = NEW("GarrisonModel", [_world ARG _newGarrActual]);
		#endif

		//// Detach from the location
		//CALLM(_newGarrActual, "postMethodAsync", ["setLocation" ARG [""]]);

		// return the New detachment garrison model
		_newGarr
	} ENDMETHOD;

	// MOVE TO POS
	METHOD("moveSim") {
		params [P_THISOBJECT, P_ARRAY("_pos"), P_NUMBER("_radius")];

		T_SETV("pos", _pos);
	} ENDMETHOD;

	METHOD("moveActual") {
		params [P_THISOBJECT, P_ARRAY("_pos"), P_NUMBER("_radius")];

		T_PRVAR(actual);
		ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when Actual is not valid");
		private _AI = CALLM(_actual, "getAI", []);
		private _parameters = [[TAG_G_POS, _pos], [TAG_MOVE_RADIUS, _radius]];
		CALLM(_AI, "postMethodAsync", ["addExternalGoal" ARG ["GoalGarrisonMove" ARG 0 ARG _parameters ARG _thisObject]]);

		OOP_INFO_MSG("Moving %1 to %2 within %3", [LABEL(_thisObject) ARG _pos ARG _radius]);
	} ENDMETHOD;

	METHOD("cancelMoveActual") {
		params [P_THISOBJECT];

		T_PRVAR(actual);
		ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when Actual is not valid");
		private _AI = CALLM(_actual, "getAI", []);
		CALLM(_AI, "postMethodAsync", ["deleteExternalGoal" ARG ["GoalGarrisonMove" ARG _thisObject]]);

		OOP_INFO_MSG("Cancelled move of %1", [LABEL(_thisObject)]);
	} ENDMETHOD;

	METHOD("moveActualComplete") {
		params [P_THISOBJECT];

		T_PRVAR(actual);
		ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when Actual is not valid");
		private _AI = CALLM(_actual, "getAI", []);
		private _goalState = CALLM(_AI, "getExternalGoalActionState", ["GoalGarrisonMove" ARG _thisObject]);
		if(_goalState == ACTION_STATE_COMPLETED) then {
			OOP_INFO_MSG("Move of %1 complete", [LABEL(_thisObject)]);
		};
		_goalState == ACTION_STATE_COMPLETED
	} ENDMETHOD;

	// MERGE TO ANOTHER GARRISON
	METHOD("mergeSim") {
		params [P_THISOBJECT, P_STRING("_otherGarr")];
		ASSERT_OBJECT_CLASS(_otherGarr, "GarrisonModel");

		T_PRVAR(efficiency);
		private _otherEff = GETV(_otherGarr, "efficiency");
		private _newOtherEff = EFF_ADD(_efficiency, _otherEff);
		SETV(_otherGarr, "efficiency", _newOtherEff);

		T_PRVAR(transport);
		private _otherTransport = GETV(_otherGarr, "transport");
		SETV(_otherGarr, "transport", _otherTransport + _transport);

		OOP_DEBUG_MSG("Merged %1%2 to %3%4->%5", [_thisObject ARG _efficiency ARG _otherGarr ARG _otherEff ARG _newOtherEff]);
		T_CALLM("killed", []);
	} ENDMETHOD;

	METHOD("mergeActual") {
		params [P_THISOBJECT, P_STRING("_otherGarr")];
		ASSERT_OBJECT_CLASS(_otherGarr, "GarrisonModel");

		T_PRVAR(actual);
		ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when Actual is not valid");

		OOP_INFO_MSG("Merging %1 to %2", [LABEL(_thisObject) ARG LABEL(_otherGarr)]);
		private _otherActual = GETV(_otherGarr, "actual");
		CALLM2(_otherActual, "postMethodAsync", "addGarrison", [_actual ARG true]);
		T_CALLM("killed", []);
		OOP_INFO_MSG("Merged %1 to %2", [LABEL(_thisObject) ARG LABEL(_otherGarr)]);
		//CALLM(_otherActual, "addGarrison", [_actual ARG true]);
	} ENDMETHOD;

	// JOIN LOCATION
	METHOD("joinLocationSim") {
		params [P_THISOBJECT, P_STRING("_location")];
		ASSERT_OBJECT_CLASS(_location, "LocationModel");
		
		CALLM(_location, "addGarrison", [_thisObject]);
		private _id = GETV(_location, "id");
		T_SETV("locationId", _id);
	} ENDMETHOD;

	METHOD("joinLocationActual") {
		params [P_THISOBJECT, P_STRING("_location")];
		ASSERT_OBJECT_CLASS(_location, "LocationModel");

		T_PRVAR(actual);
		ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when Actual is not valid");

		private _locationActual = GETV(_location, "actual");
		// CALLM2(_locationActual, "postMethodAsync", "registerGarrison", [_actual]);
		CALLM2(_actual, "postMethodAsync", "setLocation", [_locationActual]);
		OOP_INFO_MSG("Joined %1 to %2", [LABEL(_thisObject) ARG LABEL(_location)]);
		// private _AI = CALLM(_actual, "getAI", []);
		// private _parameters = [[TAG_LOCATION, _locationActual]];
		// private _args = ["GoalGarrisonJoinLocation", 0, _parameters, _thisObject];
		// CALLM(_AI, "postMethodAsync", ["addExternalGoal" ARG _args]);
	} ENDMETHOD;

	// CLEAR AREA
	METHOD("clearAreaActual") {
		params [P_THISOBJECT, P_ARRAY("_pos"), P_NUMBER("_moveRadius"), P_NUMBER("_clearRadius"), P_NUMBER("_timeOutSeconds")];

		T_PRVAR(actual);
		ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when Actual is not valid");
		private _AI = CALLM(_actual, "getAI", []);
		private _parameters = [[TAG_G_POS, _pos], [TAG_MOVE_RADIUS, _moveRadius], [TAG_CLEAR_RADIUS, _clearRadius], [TAG_DURATION, _timeOutSeconds]]; 
		CALLM(_AI, "postMethodAsync", ["addExternalGoal" ARG ["GoalGarrisonClearArea" ARG 0 ARG _parameters ARG _thisObject]]);

		OOP_INFO_MSG("%1 clearing area at %2, radius %3, timeout %4 seconds", [LABEL(_thisObject) ARG _pos ARG _clearRadius ARG _timeOutSeconds]);
	} ENDMETHOD;

	METHOD("clearActualComplete") {
		params [P_THISOBJECT];

		T_PRVAR(actual);
		ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when Actual is not valid");
		private _AI = CALLM(_actual, "getAI", []);
		private _goalState = CALLM(_AI, "getExternalGoalActionState", ["GoalGarrisonClearArea" ARG _thisObject]);
		if(_goalState == ACTION_STATE_COMPLETED) then {
			OOP_INFO_MSG("%1 completed clearing area", [LABEL(_thisObject)]);
		};
		_goalState == ACTION_STATE_COMPLETED
	} ENDMETHOD;

	METHOD("cancelClearAreaActual") {
		params [P_THISOBJECT];

		T_PRVAR(actual);
		ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when Actual is not valid");
		private _AI = CALLM(_actual, "getAI", []);
		CALLM(_AI, "postMethodAsync", ["deleteExternalGoal" ARG ["GoalGarrisonClearArea" ARG _thisObject]]);

		OOP_INFO_MSG("Cancelled clear area for %1", [LABEL(_thisObject)]);
	} ENDMETHOD;

	// METHOD("joinLocationActualComplete") {
	// 	params [P_THISOBJECT];

	// 	T_PRVAR(actual);
	// 	ASSERT_MSG(!IS_NULL_OBJECT(_actual), "Calling an Actual GarrisonModel function when Actual is not valid");

	// 	private _AI = CALLM(_actual, "getAI", []);
	// 	private _goalState = CALLM(_AI, "getExternalGoalActionState", ["GoalGarrisonJoinLocation" ARG _AI]);
	// 	_goalState == ACTION_STATE_COMPLETED
	// } ENDMETHOD;

	// -------------------- S C O R I N G   T O O L K I T / U T I L S -------------------
	STATIC_METHOD("transportRequired") {
		params [P_THISOBJECT, P_ARRAY("_eff")];
		_eff#0
	} ENDMETHOD;

	METHOD("transportationScore") {
		params [P_THISOBJECT, P_ARRAY("_eff")];
		// TODO: non linearity
		0 max (T_GETV("transport") - CALL_STATIC_METHOD("GarrisonModel", "transportRequired", [_eff]));
	} ENDMETHOD;
	
ENDCLASS;


// Unit test
#ifdef _SQF_VM

["GarrisonModel.new(actual)", {
	private _actual = NEW("Garrison", [WEST]);
	private _world = NEW("WorldModel", [WORLD_TYPE_REAL]);
	private _garrison = NEW("GarrisonModel", [_world ARG _actual]);
	private _class = OBJECT_PARENT_CLASS_STR(_garrison);
	!(isNil "_class")
}] call test_AddTest;

["GarrisonModel.new(sim)", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world]);
	private _class = OBJECT_PARENT_CLASS_STR(_garrison);
	!(isNil "_class")
}] call test_AddTest;

["GarrisonModel.simCopy", {
	private _actual = NEW("Garrison", [WEST]);
	private _world = NEW("WorldModel", [WORLD_TYPE_REAL]);
	private _garrison = NEW("GarrisonModel", [_world ARG _actual]);
	private _simWorld = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _copy = CALLM(_garrison, "simCopy", [_simWorld]);
	private _class = OBJECT_PARENT_CLASS_STR(_copy);
	!(isNil "_class")
}] call test_AddTest;

["GarrisonModel.delete", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world]);
	SETV(_garrison, "efficiency", EFF_MIN_EFF);
	DELETE(_garrison);
	private _class = OBJECT_PARENT_CLASS_STR(_garrison);
	isNil "_class"
}] call test_AddTest;

["GarrisonModel.killed", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world]);
	SETV(_garrison, "efficiency", EFF_MIN_EFF);
	CALLM(_garrison, "killed", []);
	CALLM(_garrison, "isDead", [])
}] call test_AddTest;

["GarrisonModel.isDead", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world]);
	SETV(_garrison, "efficiency", EFF_MIN_EFF);
	["False before killed", !CALLM(_garrison, "isDead", [])] call test_Assert;
	CALLM(_garrison, "killed", []);
	["True after killed", CALLM(_garrison, "isDead", [])] call test_Assert;
}] call test_AddTest;

["GarrisonModel.simSplit", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world]);
	private _eff1 = [12, 4, 4, 2, 20, 0, 0, 0];
	private _eff2 = EFF_MIN_EFF;
	private _effr = EFF_DIFF(_eff1, _eff2);
	SETV(_garrison, "efficiency", _eff1);
	private _splitGarr = CALLM(_garrison, "splitSim", [_eff2]);
	["Orig eff", GETV(_garrison, "efficiency") isEqualTo _effr] call test_Assert;
	["Split eff", GETV(_splitGarr, "efficiency") isEqualTo _eff2] call test_Assert;
}] call test_AddTest;

Test_group_args = [WEST, 0]; // Side, group type
Test_unit_args = [tNATO, T_INF, T_INF_default, -1];

["GarrisonModel.actualSplit", {
	private _actual = NEW("Garrison", [WEST]);
	private _group = NEW("Group", Test_group_args);
	private _eff1 = +T_EFF_null;
	for "_i" from 0 to 19 do
	{
		private _unit = NEW("Unit", Test_unit_args + [_group]);
		//CALLM(_actual, "addUnit", [_unit]);
		private _unitEff = CALLM(_unit, "getEfficiency", []);
		_eff1 = EFF_ADD(_eff1, _unitEff);
	};

	CALLM(_actual, "addGroup", [_group]);
	
	private _world = NEW("WorldModel", [WORLD_TYPE_REAL]);
	private _garrison = NEW("GarrisonModel", [_world ARG _actual]);
	["Initial eff", GETV(_garrison, "efficiency") isEqualTo _eff1] call test_Assert;
	private _eff2 = EFF_MIN_EFF;
	private _effr = EFF_DIFF(_eff1, _eff2);
	SETV(_garrison, "efficiency", _eff1);

	private _splitGarr = CALLM(_garrison, "splitActual", [_eff2]);
	// Sync the Models
	CALLM(_garrison, "sync", []);
	CALLM(_splitGarr, "sync", []);

	// diag_log format["%1, %2", GETV(_garrison, "efficiency"), _effr];
	// diag_log format["%1, %2", GETV(_splitGarr, "efficiency"), _eff2];

	["Orig eff", GETV(_garrison, "efficiency") isEqualTo _effr] call test_Assert;
	["Split eff", GETV(_splitGarr, "efficiency") isEqualTo _eff2] call test_Assert;
}] call test_AddTest;
#endif