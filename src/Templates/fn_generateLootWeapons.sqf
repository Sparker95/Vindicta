#include "..\common.h"

// Generates array with inventory items to fill inventory of cargo boxes
// This function is meant to work with data in format used by T_INV template category

params [["_primaryWeapons", [], [[]]],  // Array of arrays of [_weapon, _magazines, _items] for each subcategory
        ["_secondaryWeapons", [], [[]]],// Array of arrays of [_weapon, _magazines, _items] for each subcategory
        ["_lootWeight", [], [[]]],      // Array of numbers representing relative amount of each weapon type for each subcategory
        ["_totalAmount", 0, [0]]];           // Amount of soldiers

// Arrays of [_type, count]
private _weapons = [];
private _magazines = [];
private _items = [];

// Function which adds item type with given amount to an array
// First it searches if given item is already in the array
private _addItem = {
    params ["_array", "_type", "_amount"];
    private _index = _array findIf {_x#0 == _type};
    if (_index != -1) then {                // Item was found, increase amount
        private _a = _array#_index;
        _a set [1, _a#1 + _amount];
    } else {                                // Such item was not found
        _array pushBack [_type, _amount];
    };
};

// Iterate all infantry subcategories
private _i = 0;
private _nSubcategories = count _lootWeight;
// This is a scaling factor indended for police and similar factions which have an almost empty soldier type list
private _nSubcategoriesWithWeapons = { count _x > 0 } count _primaryWeapons;
while {_i < _nSubcategories} do {
    private _nWeaponsThisSubcategory = _totalAmount * (_lootWeight#_i) * _nSubcategories / _nSubcategoriesWithWeapons;
    if (_nWeaponsThisSubcategory > 0) then {
        {
            _x params ["_weaponsArray", "_magsPerGun", "_itemsPerGun"];
            if (count _weaponsArray > 0) then {
                // We are adding more weapons than there are weapon types
                // Then share weapons equally among weapon types
                private _weaponID = 0;
                private _nThisWeapon = _nWeaponsThisSubcategory / (count _weaponsArray);
                while {_weaponID < (count _weaponsArray)} do {
                    (_weaponsArray#_weaponID) params ["__type", "__mags", "__items"];
                    [_weapons, __type, _nThisWeapon] call _addItem;                                 // Add weapons
                    { [_magazines, _x, _nThisWeapon*_magsPerGun] call _addItem; } forEach __mags;  // Add magazines
                    { [_items, _x, _nThisWeapon*_itemsPerGun] call _addItem; } forEach __items;     // Add items
                    _weaponID = _weaponID + 1;
                };
            };
        } forEach   [
                        [_primaryWeapons select _i, 10, 1], // Array with weapons, mags per gun, items per gun
                        [_secondaryWeapons select _i, 4, 1]
                    ];
    };

    _i = _i + 1;
};

// Round item amounts, since they are most likely non-integer
#define __ROUND_ARRAY(array) { _x set [1, round (_x select 1)] } forEach array; array = array select {(_x select 1) > 0};
__ROUND_ARRAY(_weapons);
__ROUND_ARRAY(_magazines);
__ROUND_ARRAY(_items);

// Return values
[_weapons, _magazines, _items];