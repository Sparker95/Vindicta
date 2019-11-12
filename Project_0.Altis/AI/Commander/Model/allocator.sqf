#include "..\common.hpp"

// Development of the new unit allocator algorithm

// Initialize test functions
#ifdef _SQF_VM
call compile preprocessFileLineNumbers "Tests\initTests.sqf";
#endif

//Initialize templates
call compile preprocessFileLineNumbers "Templates\initFunctions.sqf";
call compile preprocessFileLineNumbers "Templates\initVariables.sqf";

#define pr private

//#define UNIT_ALLOCATOR_DEBUG
//#ifdef UNIT_ALLOCATOR_DEBUG

#define ASP_ENABLE

#ifdef _SQF_VM
#undef ASP_ENABLE
#endif

#ifdef ASP_ENABLE
#define _CREATE_PROFILE_SCOPE(scopeName) private _tempScope = createProfileScope scopeName
#define _DELETE_PROFILE_SCOPE _tempScope = 0
#else
#define _CREATE_PROFILE_SCOPE(scopeName)
#define _DELETE_PROFILE_SCOPE
#endif


// Allocate units from a given unit composition array,
// efficiency masks, etc
fnc_allocateUnits = {

	_CREATE_PROFILE_SCOPE("ALLOCATE UNITS - whole function");

	params [P_THISCLASS,
		P_ARRAY("_effExt"),					// External efficiency requirement we must fullfill
		P_ARRAY("_constraintFnNames"),		// Array of names of constraint validation functions, all of which receive [_ourEff, _theirEff]
		P_ARRAY("_comp"),					// Composition array: [[1, 2, 3], [4, 5], [6, 7]]: 1 unit of cat:0,subcat:0, 2x(0, 1), 3x(0, 2), etc
		P_ARRAY("_compPayloadWhitelistMask"),	// Whitelist mask for payload or []
		P_ARRAY("_compPayloadBlacklistMask"),	// Blacklist mask for payload or []
		P_ARRAY("_compTransportWhitelistMask"),	// Whitelist mask for transport or []
		P_ARRAY("_compTransportBlacklistMask")];// Blacklist mask for transport or []

	// Select units we can allocate for payload
	pr _compPayload = +_comp;
	// Apply masks if they are provided...
	if (count _compPayloadWhitelistMask > 0) then {
		[_compPayload, _compPayloadWhitelistMask] call comp_fnc_applyWhitelistMask;
	};
	if (count _compPayloadBlacklistMask > 0) then {
		[_compPayload, _compPayloadBlacklistMask] call comp_fnc_applyBlacklistMask;
	};

	// Select units we can allocate for transport
	pr _compTransport = +_comp;
	if (count _compTransportWhitelistMask > 0) then {
		[_compTransport, _compTransportWhitelistMask] call comp_fnc_applyWhitelistMask;
	};
	if (count _compTransportBlacklistMask > 0) then {
		[_compTransport, _compTransportBlacklistMask] call comp_fnc_applyBlacklistMask;
	};

	#ifdef UNIT_ALLOCATOR_DEBUG
	diag_log "- - - - - -";
	[_compPayload, "Payload composition after masks:"] call comp_fnc_print;

	diag_log "- - - - - -";
	[_compTransport, "Transport composition after masks:"] call comp_fnc_print;
	#endif

	// Initialize variables
	pr _allocated = false;
	pr _failedToAllocate = false;
	pr _compAllocated = [0] call comp_fnc_new;	// Allocated composition
	pr _effAllocated = +T_EFF_null;				// Allocated efficiency
	pr _nIteration = 0;
	pr _effSorted = T_efficiencySorted;

	// Start the allocation iterations
	while {!_allocated && !_failedToAllocate && (_nIteration < 100)} do { // Should we limit amount of iterations??

		_CREATE_PROFILE_SCOPE("ALLOCATE UNITS - iteration");


		#ifdef UNIT_ALLOCATOR_DEBUG
		diag_log "";
		diag_log format ["Iteration: %1", _nIteration];
		#endif

		// Get allocated efficiency
		#ifdef UNIT_ALLOCATOR_DEBUG
		diag_log format ["  Allocated eff: %1", _effAllocated];
		[_compAllocated, "  Allocated composition:"] call comp_fnc_print;
		#endif

		// Validate against provided constrain functions
		pr _unsatisfied = []; // Array of unsatisfied criteria
		for "_i" from 0 to ((count _constraintFnNames) - 1) do {
			_CREATE_PROFILE_SCOPE("Get unsatisfied constraints");
			pr _newConstraints = [_effAllocated, _effExt] call ( missionNamespace getVariable (_constraintFnNames#_i) );
			_unsatisfied append _newConstraints;
			if (count _newConstraints > 0) exitWith {}; // Bail on occurance of first unsatisfied constraint
		};
		#ifdef UNIT_ALLOCATOR_DEBUG
		diag_log format ["  Unsatisfied constraints: %1", _unsatisfied];
		#endif

		// If there are no unsatisfied constraints, break the loop
		if ((count _unsatisfied) == 0) then {
			#ifdef UNIT_ALLOCATOR_DEBUG
			diag_log "  Allocated enough units!";
			#endif
			_allocated = true;
		} else {
			pr _constraint = _unsatisfied#0#0;
			pr _constraintValue = _unsatisfied#0#1;

			// Select the array with units sorted by their capability to satisfy constraint
			pr _constraintTransport = _constraint in T_EFF_constraintsTransport;	// True if we are satisfying a transport constraint

			#ifdef UNIT_ALLOCATOR_DEBUG
			diag_log format ["  Trying to satisfy constraint: %1", _constraint];
			#endif
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


			#ifdef UNIT_ALLOCATOR_DEBUG
			diag_log format ["  Potential units: %1", _potentialUnits];
			#endif

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
					#ifdef UNIT_ALLOCATOR_DEBUG
					diag_log format ["  Generated random ID: %1", _ID];
					#endif
				};

				_CREATE_PROFILE_SCOPE("_end of iteration");

				pr _catID = _potentialUnits#_ID#1;
				pr _subcatID = _potentialUnits#_ID#2;
				pr _effToAdd = T_efficiency#_catID#_subcatID;
				[_effAllocated, _effToAdd] call eff_fnc_acc_add;					// Add with accumulation
				[_compPayload, _catID, _subcatID, -1] call comp_fnc_addValue;		// Substract from both since they might have same units in them
				[_compTransport, _catID, _subcatID, -1] call comp_fnc_addValue;
				[_compAllocated, _catID, _subcatID, 1] call comp_fnc_addValue;

				#ifdef UNIT_ALLOCATOR_DEBUG
				diag_log format ["  Allocated unit: %1", T_NAMES#_catID#_subcatID];
				#endif

				_found = true;
				//_nextRandomID = _nextRandomID + 1;
			} else {
				// Can't find any more units!
				diag_log "  Failed to find a unit!";
			};
			
			// If we've looked through all the units and couldn't find one to help us safisfy this constraint, raise a failedToAllocate flag
			_failedToAllocate = !_found;
			_nIteration = _nIteration + 1;
		};
	};

	diag_log format ["Allocation finished. Iterations: %1, Allocated: %2, failed: %3", _nIteration, _allocated, _failedToAllocate];

	if (!_allocated || _failedToAllocate) exitWith {
		// Could not allocate units!
		[]
	};

	#ifdef UNIT_ALLOCATOR_DEBUG
	diag_log "";
	[_compAllocated, "  Allocated successfully:"] call comp_fnc_print;
	#endif
	_compAllocated
};


testComp = [30] call comp_fnc_new;


allocatorTest = {

	//pr _comp = [30] call comp_fnc_new; // 20 units of each type

	pr _comp = +testComp;

	/*
	(_comp#T_INF) set [T_INF_rifleman, 30];
	(_comp#T_INF) set [T_INF_AT, 15];
	(_comp#T_INF) set [T_INF_LAT, 15];

	(_comp#T_VEH) set [T_VEH_truck_inf, 10];
	*/

	#ifdef UNIT_ALLOCATOR_DEBUG
	[_comp, "Composition:"] call comp_fnc_print;
	#endif


	/*
	More realistic numbers
	todo
	*/


	// Call unit allocator
	diag_log "Calling allocate units...";
	pr _effExt = +T_EFF_null;		// "External" requirement we must satisfy during this allocation

	// Fill in units which we must destroy
	_effExt set [T_EFF_soft, 10];
	//_effExt set [T_EFF_medium, 3];
	_effExt set [T_EFF_armor, 3];
	//_effExt set [T_EFF_air, 2];

	pr _validationFnNames = ["eff_fnc_validateAttack", "eff_fnc_validateTransport", "eff_fnc_validateCrew"]; // "eff_fnc_validateDefense"

	pr _payloadWhitelistMask = T_comp_ground_or_infantry_mask;

	pr _payloadBlacklistMask = T_comp_static_mask;	// Don't take static weapons under any conditions

	pr _transportWhitelistMask = T_comp_ground_and_transport_or_infantry_mask;	// Take ground units, take any infantry to satisfy crew requirements

	pr _transportBlacklistMask = [];

	["Noclass", _effExt, _validationFnNames, _comp,
		_payloadWhitelistMask, _payloadBlacklistMask,
		_transportWhitelistMask, _transportBlacklistMask,
		_unitBlacklist] call fnc_allocateUnits;
};

allocator_maskTest = {
	pr _comp = +testComp;
	pr _effPayloadWhitelist = [	T_EFF_ground_mask,		// Take any ground units
						T_EFF_infantry_mask];	// Take any infantry units
	pr _effPayloadBlacklist = [];
	pr _unitBlacklists = [T_static];

	pr _compPayload = +_comp;
	[_compPayload, _effPayloadWhitelist, _effPayloadBlacklist, _unitBlacklists] call comp_fnc_applyMasks;

};

0 call allocatorTest;



/*
pr _comp = [30] call comp_fnc_new;
pr _compMask = [0] call comp_fnc_new;
(_compMask#T_inf) set [T_INF_rifleman, 3];
[_comp, T_comp_static_mask] call comp_fnc_applyBlacklistMask;
[_comp, "Composition after mask:"] call comp_fnc_print;
*/

//[[T_comp_air_mask, T_comp_transport_mask] call comp_fnc_maskAndMask, "Air transport"] call comp_fnc_print;