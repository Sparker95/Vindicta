#include "defineCommon.inc"
/*
    By: Jeroen Notenbomer

	Get the index of which item is part of

    Inputs:
        1: item			"name"
        2: (list)		[1,3,10]	index to search in, optional

    Outputs
        index or -1 if not found
*/

#include "\A3\ui_f\hpp\defineDIKCodes.inc"
#include "\A3\Ui_f\hpp\defineResinclDesign.inc"

params [["_item","",[""]]];
if(_item isEqualTo "")exitWith{diag_log "JNA Warning: empty item received in fnc_arsenal_itemType"};

// Try to perform lookup in hashmap first
pr _hm = missionNamespace getVariable ["jna_itemTypeHashmap", locationNull];
pr _return = _hm getVariable [_item, -1];
if (_return != -1) exitWith {
	_return
};

// Item was not found in the hashmap, perform usual type resolution
pr ["_types","_return","_data"];
_return = -1;

// Fix for CBA_miscItem-derived classes
if (_item isKindOf ["CBA_MiscItem", configFile >> "cfgWeapons"]) exitWith { IDC_RSCDISPLAYARSENAL_TAB_CARGOMISC };


// Do the usual class resolution
INITTYPES

(_item call bis_fnc_itemType) params ["_weaponTypeCategory", "_weaponTypeSpecific"];

{
	if ((_weaponTypeSpecific in _x) || (_item in _x)) exitwith {_return = _foreachindex;};
} foreach _types;


if(_return == -1)then{
	pr _data = (missionnamespace getvariable "bis_fnc_arsenal_data");
	if (isNil "_data") exitWith {};
	{
		pr _index = _x;
		pr _dataSet = _data select _index;

		{
			if((tolower _item)isEqualTo (tolower _x))exitWith{_return = _index};
		} forEach _dataSet;

		if(_return != -1)exitWith{};
	}forEach [
		IDC_RSCDISPLAYARSENAL_TAB_CARGOPUT,
		IDC_RSCDISPLAYARSENAL_TAB_CARGOTHROW,
		IDC_RSCDISPLAYARSENAL_TAB_CARGOMAGALL,
		IDC_RSCDISPLAYARSENAL_TAB_CARGOMISC,
		IDC_RSCDISPLAYARSENAL_TAB_ITEMOPTIC,
		IDC_RSCDISPLAYARSENAL_TAB_ITEMACC,
		IDC_RSCDISPLAYARSENAL_TAB_ITEMMUZZLE,
		IDC_RSCDISPLAYARSENAL_TAB_ITEMBIPOD
	];
};

//Assigning item to misc if no category was given
if(_return == -1)then{
    _return = IDC_RSCDISPLAYARSENAL_TAB_CARGOMISC;
};

// Add the value to hash map, so that later it's faster to look it up
if (isNull _hm) then { // Warn if hashmap was not initialized yet
	diag_log "JNA Warning: item type hash map was not initialized";
} else {
	_hm setVariable [_item, _return];
};

_return;
