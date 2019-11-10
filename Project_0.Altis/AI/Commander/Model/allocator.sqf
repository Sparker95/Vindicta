#include "..\common.hpp"

// Development of the new unit allocator algorithm

// Initialize test functions
call compile preprocessFileLineNumbers "Tests/initTests.sqf";

//Initialize templates
call compile preprocessFileLineNumbers "Templates\initFunctions.sqf";
call compile preprocessFileLineNumbers "Templates\initVariables.sqf";

#define pr private

// Just prints composition in a pretty way
comp_fnc_print = {
	params ["_comp0", "_text"];
	_labels = [	"Units",
				"Vehicles",
				"Drones",
				"Cargo"];
	diag_log _text;
	{
		pr _catid = _foreachindex;
		diag_log format ["  %1:", _labels#_foreachindex];
		{
			pr _subcatid = _foreachindex;
			if (_x > 0) then {
				diag_log format ["    %1: %2", T_NAMES#_catid#_subcatid, _x];
			};
		} forEach _x;
	} forEach _comp0;
};

// Combines an array of vector masks into one (just sums them up and clips to 0...1 range)
eff_fnc_combineMasks = {
	params ["_masks"];
	pr _ret = +T_EFF_null;
	pr _nCols = count (_masks#0);
	for "_col" from 0 to (_nCols - 1) do 
	{
		_num = 0;
		{
			_num = _num + _x#_col;
		} forEach _masks;
		_num = (_num min 1) max 0;
		_ret set [_col, _num];
	};
	_ret
};

// Check if given eff. vector matches a mask vector
// Vector maches the mask when it has non-zero values at all non-zero columns in the mask
eff_fnc_matchesMask = {
	params ["_eff", "_mask"];
	pr _match = true;
	{
		if (_x>0 && {(_eff#_forEachIndex) == 0}) exitWIth { _match = false };
	} forEach _mask;
	_match
};

// Decreases amounf of units in composition array by _amount
comp_fnc_addValue = {
	params ["_comp", "_catID", "_subcatID", "_amount"];
	pr _a = _comp#_catID;
	_a set [_subcatID, (_a#_subcatID) + _amount];
};

// Creates a new composition array with numbers
comp_fnc_new = {
	params [["_value", 0]];

	pr _comp = [];

	{
		pr _tempArray = [];
		_tempArray resize _x;
		_comp pushBack (_tempArray apply {_value});
	} forEach [T_INF_SIZE, T_VEH_SIZE, T_DRONE_SIZE, T_CARGO_SIZE];

	_comp
};

// Converts a composition array into an efficiency vector
comp_fnc_getEfficiency = {
	params ["_comp"];
	pr _acc = +T_EFF_null; // Accumulator
	{
		pr _catID = _forEachIndex;
		{
			pr _subCatID = _forEachIndex;
			pr _value = _x;
			pr _eff = T_efficiency#_catID#_subcatID;
			{
				_acc set [_forEachIndex, (_acc#_forEachIndex) + _value*(_eff#_forEachIndex)];
			} forEach _eff;
		} forEach _x;
	} forEach _comp;
	_acc
};

// Applies masks for this composition array, modifies existing array
comp_fnc_applyMasks = {
	params ["_comp", "_whiteListMasks", "_blackistMsks", "_unitBlackLists"];
	for "_catID" from 0 to ((count _comp) - 1) do {
		pr _a = _comp#_catID;
		for "_subcatID" from 0 to ((count _a) - 1) do {
			pr _eff = (T_efficiency#_catID#_subcatID);
			pr _allocateThisUnit = true;
			
			// Check against unit blacklists
			{
				if ([_catID, _subcatID] in _x) exitWith {
					_allocateThisUnit = false;
				};
			} forEach _unitBlacklists;

			// Check against whitelists masks
			if (_allocateThisUnit) then {
				// Result is an OR between results of applying every mask
				pr _allowTake = false;
				{
					_allowTake = _allowTake || ([_eff, _x] call eff_fnc_matchesMask);
				} forEach _whiteListMasks;
				_allocateThisUnit = _allowTake;
			};

			// Check against blacklist masks
			if (_allocateThisUnit) then {
				// Any match to a blacklist will forbid taking this unit
				{
					if (([_eff, _x] call eff_fnc_matchesMask)) exitWith { _allocateThisUnit = false; };
				} forEach _blackistMsks;
			};
			
			// If we are not taking this unit type, set counter of this unit type to zero
			if (!_allocateThisUnit) then {
				_a set [_subcatID, 0];
			};
		};
	};
	_comp
};

// Allocate units from a given unit composition array,
// efficiency masks, etc
fnc_allocateUnits = {
	params [P_THISCLASS,
		P_ARRAY("_effExt"),					// External efficiency requirement we must fullfill
		P_ARRAY("_constraintFnNames"),		// Array of names of constraint validation functions, all of which receive [_ourEff, _theirEff]
		P_ARRAY("_comp"),					// Composition array: [[1, 2, 3], [4, 5], [6, 7]]: 1 unit of cat:0,subcat:0, 2x(0, 1), 3x(0, 2), etc
		P_ARRAY("_effPayloadWhitelist"),	// Array of whitelist masks for payload
		P_ARRAY("_effPayloadBlacklist"),	// Array of blacklist masks for payload
		P_ARRAY("_effTransportWhitelist"),	// Array of whitelist masks for transport
		P_ARRAY("_effTransportBlacklist"),	// Array of blacklist masks for transport
		P_ARRAY("_unitBlacklists")];			// Arrays of [[_catID, _subcatID], ...] of units we don't want to allocate under any conditions
	// Make combined whitelist and blacklist masks
	/*
	// wrong code, makes no sense, we don't want to combine all whitelists into one
	pr _payloadWhitelist = false;
	pr _payloadWhitelistMask = T_EFF_ones;
	if (count _effPayloadWhitelist > 0) then {
		_payloadWhitelistMask = _effPayloadWhitelist call eff_fnc_combineMasks;
		_payloadWhitelist = true;
	};
	pr _payloadBlacklist = false;
	pr _payloadBlacklistMask = T_EFF_ones;
	if (count _effPayloadBlacklist > 0) then {
		_payloadBlacklistMask = _effPayloadBlacklist call eff_fnc_combineMasks;
		_payloadBlacklist = true;
	};

	diag_log format ["Payload whitelist mask: %1", _payloadWhitelistMask];
	diag_log format ["Payload blacklist mask: %1", _payloadBlacklistMask];
	*/

	// Select units we can allocate for payload
	pr _compPayload = +_comp;
	[_compPayload, _effPayloadWhitelist, _effPayloadBlacklist, _unitBlacklists] call comp_fnc_applyMasks;

	// Select units we can allocate for transport
	pr _compTransport = +_comp;
	[_compTransport, _effTransportWhitelist, _effTransportBlacklist, _unitBlacklists] call comp_fnc_applyMasks;

	diag_log "- - - - - -";
	[_compPayload, "Payload composition after masks:"] call comp_fnc_print;

	diag_log "- - - - - -";
	[_compTransport, "Transport composition after masks:"] call comp_fnc_print;

	pr _allocated = false;
	pr _failedToAllocate = false;
	pr _compAllocated = [0] call comp_fnc_new;	// Allocated composition
	pr _nIteration = 0;
	//pr _effSorted = +T_efficiencySorted;		// We are going to modify it
	pr _nextRandomID = 0;						// Random ID generator we are going to use to randomize the results a little
	pr _prevConstraint = -1;					// Previous constraint we tried to satisfy

	while {!_allocated && !_failedToAllocate && (_nIteration < 100)} do { // Should we limit amount of iterations??

		diag_log "";
		diag_log format ["Iteration: %1", _nIteration];

		// Get allocated efficiency
		pr _effAllocated = [_compAllocated] call comp_fnc_getEfficiency;
		diag_log format ["  Allocated eff: %1", _effAllocated];
		[_compAllocated, "  Allocated composition:"] call comp_fnc_print;

		// Validate against provided constrain functions
		pr _unsatisfied = []; // Array of unsatisfied criteria
		for "_i" from 0 to ((count _constraintFnNames) - 1) do {
			_unsatisfied append ( [_effAllocated, _effExt] call ( missionNamespace getVariable (_constraintFnNames#_i) ) );
		};
		diag_log format ["  Unsatisfied constraints: %1", _unsatisfied];

		// If there are no unsatisfied constraints, break the loop
		if ((count _unsatisfied) == 0) then {
			diag_log "  Allocated enough units!";
			_allocated = true;
		} else {
			pr _constraint = _unsatisfied#0#0;
			pr _constraintValue = _unsatisfied#0#1;
			
			// Check if there are no more unsatisfied payload constraints
			//pr _payloadSatisfied = (_unsatisfied findIf {(_x#0) in T_EFF_constraintsPayload}) == -1;
			//diag_log format ["  Payload constraints satisfied: %1", _payloadSatisfied];

			// Reset the counter
			if (_constraint != _prevConstraint) then {
				_nextRandomID = 0;
			};

			// Select the array with units sorted by their capability to satisfy constraint
			pr _constraintTransport = _constraint in T_EFF_constraintsTransport;	// True if we are satisfying a transport constraint
			pr _effSorted = T_efficiencySorted;
			
			/*
			// Old code, tried different ways to sort unit allocation order (straight or inverse)
			if (_constraint in T_EFF_constraintsPayload) then {
				// For payload (combat) constraints, we sort units by inverse of their capability (first riflemen, then machinegunners)
				//T_efficiencySortedInv\
				T_efficiencySorted
			} else {
				// For transport constraints, we sort units by their capability (first trucks for infantry, then small cars)
				_constraintTransport = true;
				T_efficiencySorted
			};
			*/

			diag_log format ["  Trying to satisfy constraint: %1", _constraint];
			// Try to find a unit to satisfy this constraint
			pr _potentialUnits = _effSorted#_constraint select { // Array of value, catID, subcatID, sorted by value
				pr _catID = _x#1;
				pr _subcatID = _x#2;
				(_compPayload#_catID#_subcatID) > 0 || {(_compTransport#_catID#_subcatID) > 0}
			};

			diag_log format ["  Potential units: %1", _potentialUnits];

			pr _found = false;
			pr _count = count _potentialUnits;
			if (_count > 0) then {
				pr _ID = 0;
				
				// If we oversatisfy this constraint, try to find units which satisfy this less, we dont want to use expensive units too much
				if (	( (!_constraintTransport) /*|| (_constraintTransport && _payloadSatisfied)*/ ) && // Payload constraint, or transport and there are no more payload constraints
						{ (_potentialUnits#_ID#0 > _constraintValue) && (_count > 1) }) then {
					while { (_ID < (_count - 1)) } do {
						if ((_potentialUnits#(_ID+1)#0 < _constraintValue)) exitWith {};
						_ID = _ID + 1;
					};
				};


				/*
				pr _ID = if (_constraintTransport) then {
					0	// Take the unit which satisfies our constraint most for transport requirement
				} else {
					0
					//_nextRandomID mod (count _potentialUnits);
				};*/

				pr _catID = _potentialUnits#_ID#1;
				pr _subcatID = _potentialUnits#_ID#2;
				[_compPayload, _catID, _subcatID, -1] call comp_fnc_addValue;		// Substract from both since they might have same units in them
				[_compTransport, _catID, _subcatID, -1] call comp_fnc_addValue;
				[_compAllocated, _catID, _subcatID, 1] call comp_fnc_addValue;
				diag_log format ["  Allocated unit: %1", T_NAMES#_catID#_subcatID];
				_found = true;
				_nextRandomID = _nextRandomID + 1;
			} else {
				// Can't find any more units!
				diag_log "  Failed to find a unit!";
			};
			


			// Look through all units which we have and which can help satisfy the constraint
			//pr _found = false;
			/*
			for "_i" from 0 to ((count _potentialUnits) - 1) do {
				pr _catID = _potentialUnits#_i#1;
				pr _subcatID = _potentialUnits#_i#2;
				if ((_compPayload#_catID#_subcatID) > 0 || {(_compTransport#_catID#_subcatID) > 0} ) exitWith {
					// Substract/add value in compositions
					[_compPayload, _catID, _subcatID, -1] call comp_fnc_addValue;		// Substract from both since they might have same units in them
					[_compTransport, _catID, _subcatID, -1] call comp_fnc_addValue;
					[_compAllocated, _catID, _subcatID, 1] call comp_fnc_addValue;

					// Try to permutate the catid and subcatid to randomize returned value
					pr _value = _potentialUnits#_i;
					for "_j" from 0 to ((count _potentialUnits) - 1) do {

					};

					_found = true;
					diag_log format ["  Allocated unit: %1", T_NAMES#_catID#_subcatID];
				};
			};
			*/

			

			// If we've looked through all the units and couldn't find one to help us safisfy this constraint, raise a failedToAllocate flag
			_failedToAllocate = !_found;
			_prevConstraint = _constraint;
			_nIteration = _nIteration + 1;
		};
	};

	diag_log format ["Allocation finished. Allocated: %1, failed: %2", _allocated, _failedToAllocate];

	if (!_allocated || _failedToAllocate) exitWith {
		// Could not allocate units!
		[]
	};

	diag_log "";
	[_compAllocated, "  Allocated successfully:"] call comp_fnc_print;
	_compAllocated
};


pr _comp = [100] call comp_fnc_new; // 20 units of each type

[_comp, "Composition:"] call comp_fnc_print;



// Call unit allocator
diag_log "Calling allocate units...";
pr _effExt = +T_EFF_null;		// "External" requirement we must satisfy during this allocation

// Fill in units which we must destroy
//_effExt set [T_EFF_soft, 20];
//_effExt set [T_EFF_medium, 2];
_effExt set [T_EFF_armor, 1];
//_effExt set [T_EFF_air, 2];

pr _validationFnNames = ["eff_fnc_validateAttack", "eff_fnc_validateTransport", "eff_fnc_validateCrew"]; // "eff_fnc_validateDefense"
pr _effPayloadWhitelist = [	T_EFF_ground_mask,		// Take any ground units
							T_EFF_infantry_mask];	// Take any infantry units
pr _effPayloadBlacklist = [];
pr _effTransportWhitelist = [[[T_EFF_transport_mask, T_EFF_ground_mask]] call eff_fnc_combineMasks, // Take any units which are BOTH ground and can provide transport
								T_EFF_infantry_mask];												// Take any infantry to satisfy crew requirements
pr _effTransportBlacklist = [];
pr _unitBlacklist = [T_static];	// Do not take static weapons

["Noclass", _effExt, _validationFnNames, _comp,
	_effPayloadWhitelist,_effPayloadBlacklist,
	_effTransportWhitelist, _effTransportBlacklist,
	_unitBlacklist] call fnc_allocateUnits;

/*
_maskGroundTransport = [[T_EFF_transport_mask, T_EFF_ground_mask]] call eff_fnc_combineMasks;
[T_efficiency#T_VEH#T_VEH_boat_unarmed, _maskGroundTransport] call eff_fnc_matchesMask;

T_efficiencySorted#T_EFF_aMedium
*/

//T_efficiencySorted#T_EFF_aMedium

//[_comp] call comp_fnc_getEfficiency;