#include "..\common.hpp"

// Development of the new unit allocator algorithm

// Initialize test functions
call compile preprocessFileLineNumbers "Tests/initTests.sqf";

//Initialize templates
call compile preprocessFileLineNumbers "Templates\initFunctions.sqf";
call compile preprocessFileLineNumbers "Templates\initVariables.sqf";

#define pr private

// Just prints composition in a pretty way
fnc_printComp = {
	params ["_comp0", "_text"];
	_labels = [	"Units",
				"Vehicles",
				"Drones",
				"Cargo"];
	diag_log _text;
	{
		pr _catid = _foreachindex;
		diag_log format ["%1:", _labels#_foreachindex];
		{
			pr _subcatid = _foreachindex;
			if (_x > 0) then {
				diag_log format ["  %1: %2", T_NAMES#_catid#_subcatid, _x];
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
comp_fnc_decrease = {
	params ["_comp", "_catID", "_subcatID", "_amount"];
	pr _a = _comp#_catID;
	_a set [_subcatID, (_a#_subcatID) - _amount];
};

// Applies masks for this composition array, modifies existing array
comp_fnc_applyMasks = {
	params ["_comp", "_whiteListMasks", "_blackistMsks", "_unitBlackList"];
	for "_catID" from 0 to ((count _comp) - 1) do {
		pr _a = _comp#_catID;
		for "_subcatID" from 0 to ((count _a) - 1) do {
			pr _eff = (T_efficiency#_catID#_subcatID);
			pr _allocateThisUnit = true;
			
			// Check against unit blacklist
			if ([_catID, _subcatID] in _unitBlacklist) then {
				_allocateThisUnit = false;
			};

			// Check against whitelists masks
			if (_allocateThisUnit) then {
				{
					if (! ([_eff, _x] call eff_fnc_matchesMask)) exitWith { _allocateThisUnit = false; };
				} forEach _whiteListMasks;
			};

			// Check against blacklist masks
			if (_allocateThisUnit) then {
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
		P_ARRAY("_comp"),					// Composition array: [[1, 2, 3], [4, 5], [6, 7]]: 1 unit of cat:0,subcat:0, 2x(0, 1), 3x(0, 2), etc
		P_ARRAY("_effPayloadWhitelist"),	// Array of whitelist masks for payload
		P_ARRAY("_effPayloadBlacklist"),	// Array of blacklist masks for payload
		P_ARRAY("_effTransportWhitelist"),	// Array of whitelist masks for transport
		P_ARRAY("_effTransportBlacklist"),	// Array of blacklist masks for transport
		P_ARRAY("_unitBlacklist")];			// Array of [_catID, _subcatID] of units we don't want to allocate under any conditions
	
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
	[_compPayload, _effPayloadWhitelist, _effPayloadBlacklist, _unitBlacklist] call comp_fnc_applyMasks;

	// Select units we can allocate for transport
	pr _compTransport = +_comp;
	[_compTransport, _effTransportWhitelist, _effTransportBlacklist, _unitBlacklist] call comp_fnc_applyMasks;

	diag_log "- - - - - -";
	[_compPayload, "Payload composition after masks:"] call fnc_printComp;

	diag_log "- - - - - -";
	[_compTransport, "Transport composition after masks:"] call fnc_printComp;

};


pr _comp = [];
{
	pr _tempArray = [];
	_tempArray resize _x;
	_comp pushBack (_tempArray apply {0});
} forEach [T_INF_SIZE, T_VEH_SIZE, T_DRONE_SIZE, T_CARGO_SIZE];

// Lots of every unit type
for "_catID" from 0 to 3 do {
	pr _a = _comp#_catID;
	for "_i" from 0 to ((count _a)-1) do {
		_a set [_i, 20];
	};
};

[_comp, "Composition:"] call fnc_printComp;



// Call unit allocator
diag_log "Calling allocate units...";
pr _effPayloadWhitelist = [[[T_EFF_transport_mask, T_EFF_ground_mask]] call eff_fnc_combineMasks];
pr _effPayloadBlacklist = [];
pr _effTransportWhitelist = [];
pr _effTransportBlacklist = [];
//pr _unitBlacklist = [[T_VEH, T_VEH_APC], [T_VEH, T_VEH_IFV]];
pr _unitBlacklist = [];

["Noclass", _comp, _effPayloadWhitelist, _effPayloadBlacklist, _effTransportWhitelist, _effTransportBlacklist, _unitBlacklist] call fnc_allocateUnits;

_maskGroundTransport = [[T_EFF_transport_mask, T_EFF_ground_mask]] call eff_fnc_combineMasks;
[T_efficiency#T_VEH#T_VEH_boat_unarmed, _maskGroundTransport] call eff_fnc_matchesMask;

