/*
Functions to work with unit compositions
*/

#include "common.hpp"

#define pr private

// Creates a new composition array with numbers
comp_fnc_new = {

	_CREATE_PROFILE_SCOPE("comp_fnc_new");

	params [["_value", 0]];

	pr _comp = [];

	{
		pr _tempArray = [];
		_tempArray resize _x;
		_comp pushBack (_tempArray apply {_value});
	} forEach [T_INF_SIZE, T_VEH_SIZE, T_DRONE_SIZE, T_CARGO_SIZE];

	_comp
};

// Adds value
comp_fnc_addValue = {

	_CREATE_PROFILE_SCOPE("eff_fnc_addValue");

	params ["_comp", "_catID", "_subcatID", "_amount"];
	pr _a = _comp#_catID;
	_a set [_subcatID, (_a#_subcatID) + _amount];
};

// Converts a composition array into an efficiency vector
// It's stupidly slow and thus don't use it unless it's really needed
comp_fnc_getEfficiency = {

	_CREATE_PROFILE_SCOPE("comp_fnc_getEfficiency");

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

// Just prints composition in a pretty way
comp_fnc_print = {

	_CREATE_PROFILE_SCOPE("eff_fnc_print");

	params ["_comp0", "_text"];
	_labels = [	"Infantry",
				"Vehicles",
				"Drones",
				"Cargo"];
	diag_log _text;
	{
		pr _catid = _foreachindex;
		pr _sum = 0;
		diag_log format ["  %1", _labels#_foreachindex];
		{
			pr _subcatid = _foreachindex;
			if (_x > 0) then {
				diag_log format ["    %1: %2", T_NAMES#_catid#_subcatid, _x];
				_sum = _sum + _x;
			};
		} forEach _x;
		diag_log format ["    -- Total: %1", _sum];
	} forEach _comp0;
};

// Applies masks for this composition array, modifies existing array
comp_fnc_applyEfficiencyMasks = {

	_CREATE_PROFILE_SCOPE("comp_fnc_applyMasks");

	params ["_comp", "_whiteListMasks", "_blackistMasks", "_unitWhitelists", "_unitBlackLists"];
	for "_catID" from 0 to ((count _comp) - 1) do {
		pr _a = _comp#_catID;
		for "_subcatID" from 0 to ((count _a) - 1) do {
			pr _eff = (T_efficiency#_catID#_subcatID);

			pr _allowed = 
					// Check against whitelists masks
					(count _whiteListMasks == 0 || {(_whiteListMasks findIf { [_eff, _x] call eff_fnc_matchesMask }) != NOT_FOUND})
					// Check if this unit is in whitelist
				&&	{count _unitWhitelists == 0 || {(_unitWhitelists findIf { [_catID, _subcatID] in _x }) != NOT_FOUND}}
				&&	{
						// Check against blacklist masks
						((_blackistMasks findIf { [_eff, _x] call eff_fnc_matchesMask }) == NOT_FOUND)
						&&
						// Check against unit blacklists
						{(_unitBlacklists findIf { [_catID, _subcatID] in _x }) == NOT_FOUND}
					}
				;

			// If we are not taking this unit type, set counter of this unit type to zero
			if (!_allowed) then {
				_a set [_subcatID, 0];
			};
		};
	};
	_comp
};

// Applies AND operation between two masks, returns a new mask
comp_fnc_maskAndMask = {
	_CREATE_PROFILE_SCOPE("comp_fnc_maskAndMask");
	params ["_mask0", "_mask1"];

	//
	//[_mask0, "Mask 0"] call comp_fnc_print;
	//[_mask1, "Mask 1"] call comp_fnc_print;

	pr _ret = [0] call comp_fnc_new;
	for "_i" from 0 to ((count _mask0) - 1) do {
		pr _cat = _ret#_i;
		for "_j" from 0 to ((count _cat) - 1) do {
			_cat set [_j, (_mask0#_i#_j) * (_mask1#_i#_j)];
		};
	};
	_ret
};

// Applies OR operation between two masks, returns a new mask
comp_fnc_maskOrMask = {
	_CREATE_PROFILE_SCOPE("comp_fnc_maskOrMask");
	params ["_mask0", "_mask1"];
	pr _ret = [0] call comp_fnc_new;
	for "_i" from 0 to ((count _mask0) - 1) do {
		pr _cat = _ret#_i;
		//diag_log _cat;
		for "_j" from 0 to ((count _cat) - 1) do {
			_cat set [_j, ((_mask0#_i#_j) + (_mask1#_i#_j)) min 1]; // Clamp it within 0..1 range
		};
	};
	_ret
};

// Nullify all counts in _comp0 for which _comp1 is zero
comp_fnc_applyWhitelistMask = {
	_CREATE_PROFILE_SCOPE("comp_fnc_applyWhitelistMask");
	params ["_comp", "_compMask"];
	{
		pr _cat = _comp#_forEachIndex;
		{
			if (_x == 0) then {
				_cat set [_forEachIndex, 0];
			};
		} forEach _x;
	} forEach _compMask;
};

// Nullify all counts in _comp for which _compMask is non-zero
comp_fnc_applyBlacklistMask = {
	_CREATE_PROFILE_SCOPE("comp_fnc_applyBlacklistMask");
	params ["_comp", "_compMask"];
	{
		pr _cat = _comp#_forEachIndex;
		pr _maskCatIsZero = _x apply {_x==0};
		{
			if (_x != 0) then {
				_cat set [_forEachIndex, 0];
			};
		} forEach _x;
	} forEach _compMask;
};

// Nullify all counts in _comp if they are contained in _blackList
// _blackList is of the form [[catID, subCatID], ...]
comp_fnc_applyBlacklist = {
	_CREATE_PROFILE_SCOPE("comp_fnc_applyBlacklistMask");
	params ["_comp", "_blackList"];
	{
		_x params ["_catID", "_subcatID"];
		(_comp#_catID) set[_subcatID, 0];
	} forEach _blackList;
};

// Adds two compositions, result stored in _to
comp_fnc_addAccumulate = {
	_CREATE_PROFILE_SCOPE("comp_fnc_addAcc");
	params ["_to", "_from"];
	for "_i" from 0 to ((count _to) - 1) do {
		pr _catTo = _to#_i;
		pr _catFrom = _from#_i;
		for "_j" from 0 to ((count _catTo) - 1) do {
			_catTo set [_j, ((_catTo#_j) + (_catFrom#_j))];
		};
	};
};

// Substracts two compositions, result stored in _to
comp_fnc_diffAccumulate = {
	_CREATE_PROFILE_SCOPE("comp_fnc_subAcc");
	params ["_to", "_from"];
	for "_i" from 0 to ((count _to) - 1) do {
		pr _catTo = _to#_i;
		pr _catFrom = _from#_i;
		for "_j" from 0 to ((count _catTo) - 1) do {
			_catTo set [_j, ((_catTo#_j) - (_catFrom#_j))];
		};
	};
};

// True if all values in _comp0 are greater or equal than those in _comp1
comp_fnc_greaterOrEqual = {
	_CREATE_PROFILE_SCOPE("comp_fnc_greaterOrEqual");
	params ["_comp0", "_comp1"];
	pr _failed = false;
	for "_i" from 0 to ((count _comp0) - 1) do {
		pr _cat0 = _comp0#_i;
		pr _cat1 = _comp1#_i;
		for "_j" from 0 to ((count _cat0) - 1) do {
			if (!((_cat0#_j) >= (_cat1#_j))) exitWIth { _failed = true;};
		};
		if (_failed) exitWith {};
	};
	!_failed
};

// Calculates amount of infantry
comp_fnc_countInfantry = {
	params ["_comp"];
	pr _inf = _comp select T_INF;
	pr _ret = 0;
	{
		_ret = _ret + _x;
	} forEach _inf;
	_ret;
};

#ifdef _SQF_VM

["Composition functions", {

	_mask_ones = [1] call comp_fnc_new;
	_mask_zeros = [0] call comp_fnc_new;
	_mask_twos = [2] call comp_fnc_new;

	["1 and 1 == 1", 			_mask_ones isEqualTo ([_mask_ones, _mask_ones] call comp_fnc_maskAndMask) ] call test_Assert;
	["1 and 0 == 0", 			_mask_zeros isEqualTo ([_mask_ones, _mask_zeros] call comp_fnc_maskAndMask) ] call test_Assert;
	["1 or 0 == 1", 			_mask_ones isEqualTo ([_mask_ones, _mask_zeros] call comp_fnc_maskOrMask) ] call test_Assert;

	_mask_ones_copy = +_mask_ones;
	[_mask_ones_copy, _mask_ones] call comp_fnc_addAccumulate;
	["1 + 1 == 2", _mask_twos isEqualTo _mask_ones_copy] call test_Assert;

	_mask_twos_copy = +_mask_twos;
	[_mask_twos_copy, _mask_ones] call comp_fnc_diffAccumulate;
	["2 - 1 == 1", _mask_ones isEqualTo _mask_twos_copy] call test_Assert;

	// Comparisons
	["2 >= 1", [_mask_twos, _mask_ones] call comp_fnc_greaterOrEqual] call test_Assert;
	["! 1 >= 2", !([_mask_ones, _mask_twos] call comp_fnc_greaterOrEqual)] call test_Assert;

	true
}] call test_AddTest;

#endif