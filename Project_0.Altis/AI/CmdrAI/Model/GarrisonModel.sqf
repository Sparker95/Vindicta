#include "..\common.hpp"

// Model of a Real Garrison. This can either be the Actual model or the Sim model.
// The Actual model represents the Real Garrison as it currently is. A Sim model
// is a copy that is modified during simulations.
CLASS("GarrisonModel", "ModelBase")
	// Strength vector of the garrison.
	VARIABLE("efficiency");
	//// Current order the garrison is following.
	// TODO: do we want this? I think only real Garrison needs orders, model just has action.
	//VARIABLE_ATTR("order", [ATTR_REFCOUNTED]);
	VARIABLE_ATTR("action", [ATTR_REFCOUNTED]);
	// Is the garrison currently in combat?
	// TODO: maybe replace this with with "engagement score" indicating how engaged they are.
	VARIABLE("inCombat");
	// Position.
	VARIABLE("pos");
	// What side this garrison belongs to.
	VARIABLE("side");
	// Id of the location the garrison is currently occupying.
	VARIABLE("locationId");

	METHOD("new") {
		params [P_THISOBJECT, P_STRING("_world"), P_STRING("_actual")];
		//T_SETV_REF("order", objNull);
		T_SETV_REF("action", objNull);
		// These will get set in sync
		T_SETV("efficiency", []);
		T_SETV("inCombat", false);
		T_SETV("pos", []);
		T_SETV("side", objNull);
		T_SETV("locationId", MODEL_HANDLE_INVALID);
		T_CALLM("sync", []);
		// Add self to world
		CALLM(_world, "addGarrison", [_thisObject]);
	} ENDMETHOD;

	METHOD("simCopy") {
		params [P_THISOBJECT, P_STRING("_targetWorldModel")];
		private _copy = NEW("GarrisonModel", [_targetWorldModel]);
		ASSERT_MSG(T_GETV("id") == GETV(_copy, "id"), 
			format ["%1 id (%2) out of sync with sim copy %3 id (%4)",
			_thisObject, T_GETV("id"), _copy, GETV(_copy, "id")]);

		//	"Id of the GarrisonModel copy is out of sync with the original. This indicates the world garrison list isn't being copied correctly?");
		//SETV(_copy, "id", T_GETV("id"));
		SETV(_copy, "efficiency", +T_GETV("efficiency"));
		//SETV_REF(_copy, "order", T_GETV("order"));
		SETV_REF(_copy, "action", T_GETV("action"));
		SETV(_copy, "inCombat", T_GETV("inCombat"));
		SETV(_copy, "pos", +T_GETV("pos"));
		SETV(_copy, "side", T_GETV("side"));
		SETV(_copy, "locationId", T_GETV("locationId"));
		_copy
	} ENDMETHOD;
	
	METHOD("sync") {
		params [P_THISOBJECT];

		T_PRVAR(actual);
		// If we have an assigned real garrison then sync from it
		if(_actual isEqualType "") then {
			OOP_DEBUG_1("Updating GarrisonModel from Actual Garrison %1", _actual);
			T_SETV("efficiency", GETV(_actual, "effTotal"));
			T_SETV("pos", CALLM(_actual, "getPos", []));
			T_SETV("side", GETV(_actual, "side"));

			private _locationActual = CALLM(_actual, "getLocation", []);
			if(!(_locationActual isEqualTo "")) then {
				T_PRVAR(world);
				private _location = CALLM(_world, "findLocationByActual", [_locationActual]);
				T_SETV("locationId", GETV(_location, "id"));
			} else {
				T_SETV("locationId", MODEL_HANDLE_INVALID);
			};
		};
	} ENDMETHOD;

	METHOD("killed") {
		params [P_THISOBJECT];
		T_PRVAR(world);
		T_SETV("efficiency", []);
		T_CALLM("detachFromLocation", []);
		CALLM(_world, "garrisonKilled", [_thisObject]);
	} ENDMETHOD;

	METHOD("detachFromLocation") {
		params [P_THISOBJECT];
		private _location = T_CALLM("getLocation", []);
		if(_location isEqualType "") then {
			CALLM(_location, "clearGarrison", []);
		};
	} ENDMETHOD;
	
	METHOD("getAction") {
		params [P_THISOBJECT];
		T_GETV("action")
	} ENDMETHOD;

	METHOD("setAction") {
		params [P_THISOBJECT, P_STRING("_action")];
		T_SETV_REF("action", _action);
	} ENDMETHOD;

	METHOD("clearAction") {
		params [P_THISOBJECT];
		T_SETV_REF("action", objNull);
	} ENDMETHOD;

	METHOD("isDead") {
		params [P_THISOBJECT];
		T_PRVAR(efficiency);
		count _efficiency == 0
	} ENDMETHOD;

	METHOD("getLocation") {
		params [P_THISOBJECT];
		T_PRVAR(locationId);
		T_PRVAR(world);
		if(_locationId != -1) exitWith { CALLM(_world, "getLocation", [_locationId]) };
		objNull
	} ENDMETHOD;

	// -------------------- S I M  /  A C T U A L   M E T H O D   P A I R S -------------------
	METHOD("simSplit") {
		params [P_THISOBJECT, P_ARRAY("_splitEff")];
		
		private _detachment =NEW("GarrisonModel", [_world]);

		T_PRVAR(efficiency);
		// Make sure to hard cap detachment so we don't drop below min eff
		private _effa = EFF_DIFF(_efficiency, EFF_MIN_EFF);
		_effa = EFF_FLOOR_0(_effa);
		_effa = EFF_MIN(_splitEff, _effa);
		_splitEff = _effa; //EFF_MIN(_splitEff, EFF_FLOOR_0(EFF_DIFF(_efficiency, EFF_MIN_EFF)));

		SETV(_detachment, "efficiency", _splitEff);
		_efficiency = EFF_DIFF(_efficiency, _splitEff);
		T_SETV("efficiency", _efficiency);

		_detachment
	} ENDMETHOD;

	// TODO: cleanup the logging
	METHOD("actualSplit") {
		params [P_THISOBJECT, P_ARRAY("_splitEff")];

		T_PRVAR(actual);

		ASSERT_MSG(_actual isEqualType "", "Calling an Actual GarrisonModel function when Actual is not valid");
		
		private _units = CALLM0(_actual, "getUnits") select {! CALLM0(_x, "isStatic")};
		_units = _units apply {private _eff = CALLM0(_x, "getEfficiency"); [0, _eff, _x]};
		_allocatedUnits = [];
		_allocatedGroupsAndUnits = [];
		_allocatedCrew = [];
		_allocatedVehicles = [];
		_effAllocated = +T_EFF_null;
		
		// Allocate units per each efficiency category
		private _j = 0;
		for "_i" from T_EFF_ANTI_SOFT to T_EFF_ANTI_AIR do {
			// Exit now if we have allocated enough units
			if(EFF_SUM(EFF_FLOOR_0(EFF_DIFF(_effAllocated, _splitEff))) == 0) exitWith {};

			// if (([_effAllocated, _splitEff] call t_fnc_canDestroy) == T_EFF_CAN_DESTROY_ALL) exitWith {

			// };
			
			// For every unit, set element 0 to efficiency value with index _i
			{_x set [0, _x#1#_i];} forEach _units;
			// Sort units in this efficiency category
			_units sort false; // Descending
			
			// Add units until there are enough of them
			private _splitEffCat = _splitEff#_j; // Required efficiency in this category
			private _pickUnitID = 0;
			while {(_effAllocated#_i < _splitEffCat) && (_pickUnitID < count _units)} do {
				private _unit = _units#_pickUnitID#2;
				private _group = CALLM0(_unit, "getGroup");
				private _groupType = if (_group != "") then {CALLM0(_group, "getType")} else {GROUP_TYPE_IDLE};
				// Try not to take troops from vehicle groups
				private _ignore = (CALLM0(_unit, "isInfantry") && _groupType in [GROUP_TYPE_VEH_NON_STATIC, GROUP_TYPE_VEH_STATIC]);
				
				if (!_ignore) then {							
					// If it was a vehicle, and it had crew in its group, add the crew as well
					if (CALLM0(_unit, "isVehicle")) then {
						private _groupUnits = if (_group != "") then {CALLM0(_group, "getUnits");} else {[]};
						// If there are more than one unit in a vehicle's group, then add the whole group
						if (count _groupUnits > 1) then {
							_allocatedGroupsAndUnits pushBackUnique [_group, +CALLM0(_group, "getUnits")];
							// Add allocated crew to array
							{
								if (CALLM0(_x, "isInfantry")) then {
									_allocatedCrew pushBack _x;
								};
							} forEach (CALLM0(_group, "getUnits"));
						} else {
							_allocatedUnits pushBackUnique _unit;
						};
						_allocatedVehicles pushBack _unit;
						OOP_INFO_2("    Added vehicle unit: %1, %2", _unit, CALLM0(_unit, "getClassName"));
					} else {
						OOP_INFO_2("    Added infantry unit: %1, %2", _unit, CALLM0(_unit, "getClassName"));
						_allocatedUnits pushBack _unit;
					};
					private _unitEff = _units#_pickUnitID#1;
					// Add to the allocated efficiency vector
					_effAllocated = EFF_ADD(_effAllocated, _unitEff);
					//OOP_INFO_1("     New efficiency value: %1", _effAllocated);
				};
				_pickUnitID = _pickUnitID + 1;
			};
			
			_j = _j + 1;
		};
		
		OOP_INFO_3("   Found units: %1, groups: %2, efficiency: %3", _allocatedUnits, _allocatedGroupsAndUnits, _effAllocated);
		
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

		// Do we need to find transport vehicles?
		if (_dist > QRF_NO_TRANSPORT_DISTANCE_MAX) then {
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
					if (_x in _allocatedVehicles || _catID != T_VEH) then { // Don't consider vehicles we have already taken and non-vehicles
						false
					} else {
						if (_subcatID in T_VEH_ground_infantry_cargo) then {
							true
						} else {
							false
						};
					};
				}; // select
				private _availableVehiclesCapacity = _availableVehicles apply {[CALLSM1("Unit", "getCargoInfantryCapacity", [_x]), _x]};
				_availableVehiclesCapacity sort false; // Descending
				
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
					// Not enough vehicles for everyone!
					// Check other locations then
					OOP_INFO_0("   Failed to allocate additional vehicles!");
					_allocated = false;
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
		if(!_allocated) exitWith { objNull };

		// Make a new garrison
		private _newGarrActual = NEW("Garrison", [GETV(_actual, "side")]);
		// This self registers with the world. From now on we just modify the _newGarrActual itself, the Model gets updated automatically during its
		// update phase.
		private _newGarr = NEW("GarrisonModel", [_world]+[_newGarrActual]);

		// Register it at the commander
		// Not needed, it is registered in the WorldModel via the GarrisonModel, and commander can access it via that.
		//CALLM1(_AI, "registerGarrison", _newGarrActual);

		private _location = T_CALLM("getLocation", []);
		if(!(_location isEqualType "")) exitWith {
			// TODO: Garrisons shouldn't need to be assigned to a location to be splittable, it makes 
			// no sense.
			FAILURE("Garrison needs to be assigned to location");
			objNull
		};

		private _locationActual = GETV(_location, "actual");
		ASSERT_MSG(_locationActual isEqualType "", "Actual LocationModel required");
		CALLM(_newGarrActual, "setLocation", [_locationActual]); // This garrison will spawn here if needed
		CALLM(_newGarrActual, "spawn", []);
		
		// Try to move the units
		private _args = [_locationActual, _allocatedUnits, _allocatedGroupsAndUnits];
		private _moveSuccess = CALLM(_newGarrActual, "postMethodSync", ["addUnitsAndGroups"]+[_args]);
		if (!_moveSuccess) exitWith {
			// This shouldn't ever happen because we check all the failure constraints before we got here.
			FAILURE("Couldn't move units to new garrison");
			objNull
		};

		OOP_INFO_0("Successfully split garrison");

		//// Detach from the location
		//CALLM(_newGarrActual, "postMethodAsync", ["setLocation"]+[[""]]);

		// return the New detachment garrison model
		_newGarr
	} ENDMETHOD;
	
ENDCLASS;


// Unit test
#ifdef _SQF_VM

["GarrisonModel.new(actual)", {
	private _actual = NEW("Garrison", [WEST]);
	private _world = NEW("WorldModel", [false]);
	private _garrison = NEW("GarrisonModel", [_world] + [_actual]);
	private _class = OBJECT_PARENT_CLASS_STR(_garrison);
	!(isNil "_class")
}] call test_AddTest;

["GarrisonModel.new(sim)", {
	private _world = NEW("WorldModel", [true]);
	private _garrison = NEW("GarrisonModel", [_world]);
	private _class = OBJECT_PARENT_CLASS_STR(_garrison);
	!(isNil "_class")
}] call test_AddTest;

["GarrisonModel.delete", {
	private _world = NEW("WorldModel", [true]);
	private _garrison = NEW("GarrisonModel", [_world]);
	DELETE(_garrison);
	private _class = OBJECT_PARENT_CLASS_STR(_garrison);
	isNil "_class"
}] call test_AddTest;

["GarrisonModel.simSplit", {
	private _world = NEW("WorldModel", [true]);
	private _garrison = NEW("GarrisonModel", [_world]);
	private _eff1 = [12, 4, 4, 2, 20, 0, 0, 0];
	private _eff2 = EFF_MIN_EFF;
	private _effr = EFF_DIFF(_eff1, _eff2);
	SETV(_garrison, "efficiency", _eff1);
	private _splitGarr = CALLM(_garrison, "simSplit", [_eff2]);
	["Orig eff", GETV(_garrison, "efficiency") isEqualTo _effr] call test_Assert;
	["Split eff", GETV(_splitGarr, "efficiency") isEqualTo _eff2] call test_Assert;
}] call test_AddTest;

Test_group_args = [WEST, 0]; // Side, group type
Test_unit_args = [tNATO, T_INF, T_INF_LMG, -1];

["GarrisonModel.actualSplit", {
	private _actual = NEW("Garrison", [WEST]);
	private _group = NEW("Group", Test_group_args);
	private _eff1 = +T_EFF_null;
	for "_i" from 0 to 20 do
	{
		private _unit = NEW("Unit", Test_unit_args + [_group]);
		CALLM(_actual, "addUnit", [_unit]);
		private _unitEff = CALLM(_unit, "getEfficiency", []);
		_eff1 = EFF_ADD(_eff1, _unitEff);
	};
	private _world = NEW("WorldModel", [false]);
	private _garrison = NEW("GarrisonModel", [_world] + [_actual]);
	["Initial eff", GETV(_garrison, "efficiency") isEqualTo _eff1] call test_Assert;
	private _eff2 = EFF_MIN_EFF;
	private _effr = EFF_DIFF(_eff1, _eff2);
	SETV(_garrison, "efficiency", _eff1);
	private _splitGarr = CALLM(_garrison, "actualSplit", [_eff2]);
	["Orig eff", GETV(_garrison, "efficiency") isEqualTo _effr] call test_Assert;
	["Split eff", GETV(_splitGarr, "efficiency") isEqualTo _eff2] call test_Assert;
}] call test_AddTest;
#endif