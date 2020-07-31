/*
This file scans a template and returns items of soldiers...
Author: Sparker 30 september 2019
*/

#define pr private

#ifdef DEBUG_TEMPLATES
#define LOG_TEMPLATE diag_log format
#else
#define LOG_TEMPLATE pr __nul =
#endif

params ["_t", ["_returnString", false]];

pr _catID = T_INF;
pr _catSize = 23; //T_INF_SIZE; // Quick fix to disable recon items from appearing in the weapon pool
pr _classDefault = _t#_catID#0#0;
pr _subCatID = T_INF_default + 1; // We don't want to process the default loadout/unit!
pr _group = createGroup WEST;

// Weapons and magazines for corresponding weapons
pr _primaryWeapons = [];
pr _primaryWeaponMagazines = [];

// Weapons and magazines for corresponding weapons
pr _secondaryWeapons = [];
pr _secondaryWeaponMagazines = [];

// Weapons and magazines for corresponding weapons
pr _handgunWeapons = [];
pr _handgunWeaponMagazines = [];

// Items are on their own
pr _primaryWeaponItems = [];
pr _secondaryWeaponItems = [];
pr _handgunWeaponItems = [];

// General items
pr _items = [];

// NVGs
pr _NVGs = [];

// Grenades
pr _grenades = [];

// Explosives
pr _explosives = [];

// Headgear
pr _headgears = [];

// Vests
pr _vests = [];

// Backpacks
pr _backpacks = [];

// Check if inventory category has been defined already
if (! isNil {_t select T_INV}) then {
	pr _inv = _t#T_INV;

	// Inheritence of these commented inventory items is not supported now
	// They will be processed by the generic code anyway, class names will be taken from loadouts
	//_primaryWeapons = +(_inv#T_INV_primary);
	//_primaryWeaponItems = +(_inv#T_INV_primary_items);
	//_secondaryWeapons = +(_inv#T_INV_secondary);
	//_secondaryWeaponItems = +(_inv#T_INV_secondary_items);
	//_handgunWeapons = +(_inv#T_INV_handgun_items);

	_items = +(_inv#T_INV_items);
	_headgears = +(_inv#T_INV_headgear);
	_vests = +(_inv#T_INV_vests);
	_backpacks = +(_inv#T_INV_backpacks);
	_NVGs = +(_inv#T_INV_NVGs);
	_grenades = +(_inv#T_INV_grenades);
	_explosives = +(_inv#T_INV_explosives);
};

// Loadout Weapons
// Each element is an array describing loadout weapons of a specific unit subcategory
pr _loadoutGear = [ [[], []] ];

//#define DEBUG

while {_subCatID < _catSize} do {
	pr _classArray = _t#_catID#_subCatID;
	pr _primaryWeaponsThisSubcat = [];		// Primary and secondary weapons of this subcategory
	pr _secondaryWeaponsThisSubcat = [];
	if (!isNil "_classArray") then {
		{ // foreach classarray
			if (_x isEqualType "") then {
				pr _classOrLoadout = _x;
				pr _isLoadout = [_classOrLoadout] call t_fnc_isLoadout;
				
				if (_isLoadout) then {
					LOG_TEMPLATE ["LOADOUT: %1", _classOrLoadout];
				} else {
					LOG_TEMPLATE ["CLASS:   %1", _classOrLoadout];
				};

				// Create a unit from which we will read data
				pr _hO = objNull;
				pr _unitClassName = _classDefault;

				if (!_isLoadout) then {
					_unitClassName = _classOrLoadout;
				};

				_hO = _group createUnit [_unitClassName, [0, 0, 0], [], 100, "CAN_COLLIDE"];

				if (_isLoadout) then {
					[_hO, _classOrLoadout] call t_fnc_setUnitLoadout;
				};

				pr _unitMags = magazines _hO;
				LOG_TEMPLATE			["  Unit mags: %1", _unitMags];

				/*
				// Grabs mags for all muzzles
								_usableMagazines = [];
	_cfgWeapon = configfile >> "cfgweapons" >> (primaryweapon player);
					{ 
						_cfgMuzzle = if (_x == "this") then {_cfgWeapon} else {_cfgWeapon >> _x};
						{ 
							_usableMagazines pushBackUnique _x;
						} foreach getarray (_cfgMuzzle >> "magazines");
					} foreach getarray (_cfgWeapon >> "muzzles");
	_usableMagazines
				*/

				// Process primary weapon
				pr _weap = primaryWeapon _hO;
				if (_weap != "") then {
					_weap = _weap call bis_fnc_baseWeapon;
					LOG_TEMPLATE 	["  Weapon:			%1", _weap];
					if (! (_weap in _primaryWeapons)) then {
						pr _items = primaryWeaponItems _hO;
						pr _mags = getArray (configfile >> "CfgWeapons" >> _weap >> "magazines");
						LOG_TEMPLATE	["  Weapon mags:	%1", _mags];
						pr _magsIntersect = _mags arrayIntersect _unitMags;
						LOG_TEMPLATE	["  Mags intersect:	%1", _magsIntersect];
						_primaryWeapons pushBack _weap;
						if (count _magsIntersect == 0) then {
							_primaryWeaponMagazines pushBack _mags;				// Some configs are incomplete and point at base magazine item, just grab all magazines available in config then
							LOG_TEMPLATE ["   Add to array: %1", _mags];
						} else {
							_primaryWeaponMagazines pushBack _magsIntersect;	// We need mags compatible with unit's weapon, but only those which are compatible with the weapon
							LOG_TEMPLATE ["   Add to array: %1", _magsIntersect];
						};
						
						{ if (_x != "") then {_primaryWeaponItems pushBackUnique _x} } forEach _items;
					};
					_primaryWeaponsThisSubcat pushBackunique _weap;
				};

				// Process secondary weapon
				pr _weap = secondaryWeapon _hO;
				if (_weap != "") then {
					_weap = _weap call bis_fnc_baseWeapon;
					if (! (_weap in _secondaryWeapons)) then {
						pr _items = secondaryWeaponItems _hO;
						pr _mags = getArray (configfile >> "CfgWeapons" >> _weap >> "magazines");
						pr _magsIntersect = _mags arrayIntersect _unitMags;
						_secondaryWeapons pushBack _weap;
						if (count _magsIntersect == 0) then {
							_secondaryWeaponMagazines pushBack _mags;
						} else {
							_secondaryWeaponMagazines pushBack _magsIntersect;
						};
						{ if (_x != "") then {_secondaryWeaponItems pushBackUnique _x} } forEach _items;
					};
					_secondaryWeaponsThisSubcat pushBackUnique _weap;
				};

				// Process handgun weapon
				pr _weap = handgunWeapon _hO;
				if (_weap != "") then {
					_weap = _weap call bis_fnc_baseWeapon;
					if (! (_weap in _handgunWeapons)) then {
						pr _items = handgunItems _hO;
						pr _mags = getArray (configfile >> "CfgWeapons" >> _weap >> "magazines");
						_handgunWeapons pushBack _weap;
						_handgunWeaponMagazines pushBack (_mags arrayIntersect _unitMags);
						{ if (_x != "") then {_handgunWeaponItems pushBackUnique _x} } forEach _items;
					};
				};

				// Process items
				{
					// We don't need magazines here! Go away magazine!
					([_x] call BIS_fnc_itemType) params ["_category", "_type"];
					switch (_type) do {
						case "Mine": {
							_explosives pushBackUnique _x;
						};
						case "Grenade": {
							_grenades pushBackUnique _x;
						};
						case "SmokeShell": {
							_grenades pushBackUnique _x;
						};
						case "NVGoggles": {
							_NVGs pushBackUnique _x;
						};
						default {	// Everything else goes here
							if (! (isClass (configFile >> "cfgMagazines" >> _x))) then {
								_items pushBackUnique _x;
							};
						};
					};
				} forEach ((assignedItems _hO) + (backpackItems _hO) + (vestItems _hO) + (uniformItems _hO));

				// Process headgear
				pr _headgear = headgear _hO;
				if (_headgear != "") then {
					_headgears pushBackUnique _headgear;
				};

				// Process vest
				pr _vest = vest _hO;
				if (_vest != "") then {
					_vests pushBackUnique _vest;
				};

				// Process backpack
				pr _backpack = backpack _hO;
				if (_backpack != "") then {
					pr _backpackBase = _backpack call bis_fnc_basicbackpack;
					if (_backpackBase != "") then {
						_backpacks pushBackUnique _backpackBase;
					};
				};

				// Process night vision
				pr _nvg = hmd _hO;
				if (_nvg != "") then {
					_NVGs pushBackUnique _nvg;
				};

				// Delete the unit
				deleteVehicle _hO;
			}; // if isEqualType ""
		} forEach _classArray;
	}; // if !isNil "_classArray"

	pr _loadoutGearThis = [_primaryWeaponsThisSubcat, _secondaryWeaponsThisSubcat, _headgears, _vests];
	_loadoutGear set [_subCatID, _loadoutGearThis];

	_subCatID = _subCatID + 1;
};

// Post-process loadout weapons of some unit types
// We want these unit types to also be able to use rifleman's main weapon
pr _riflemanWeapons = _loadoutGear#T_INF_rifleman#0;
(_loadoutGear#T_INF_LAT#0) append _riflemanWeapons;
(_loadoutGear#T_INF_AT#0) append _riflemanWeapons;
(_loadoutGear#T_INF_AA#0) append _riflemanWeapons;
(_loadoutGear#T_INF_medic#0) append _riflemanWeapons;
(_loadoutGear#T_INF_engineer#0) append _riflemanWeapons;

LOG_TEMPLATE ["Primary weapons:", _primaryWeapons];
LOG_TEMPLATE ["  %1", _primaryWeapons];
LOG_TEMPLATE ["  %1", _primaryWeaponMagazines];
LOG_TEMPLATE ["  %1", _primaryWeaponItems];

LOG_TEMPLATE ["Secondary weapons:", _secondaryWeapons];
LOG_TEMPLATE ["  %1", _secondaryWeapons];
LOG_TEMPLATE ["  %1", _secondaryWeaponMagazines];
LOG_TEMPLATE ["  %1", _secondaryWeaponItems];

LOG_TEMPLATE ["Handgun weapons:", _handgunWeapons];
LOG_TEMPLATE ["  %1", _handgunWeapons];
LOG_TEMPLATE ["  %1", _handgunWeaponMagazines];
LOG_TEMPLATE ["  %1", _handgunWeaponItems];

LOG_TEMPLATE ["Items:"];
LOG_TEMPLATE ["  %1", _items];

LOG_TEMPLATE ["Grenades:"];
LOG_TEMPLATE ["  %1", _grenades];

LOG_TEMPLATE ["Explosives:"];
LOG_TEMPLATE ["  %1", _explosives];

LOG_TEMPLATE ["Headgear:"];
LOG_TEMPLATE ["  %1", _headgears];

LOG_TEMPLATE ["Vests:"];
LOG_TEMPLATE ["  %1", _vests];

LOG_TEMPLATE ["Backpacks:"];
LOG_TEMPLATE ["  %1", _backpacks];

LOG_TEMPLATE ["Night Vision:"];
LOG_TEMPLATE ["  %1", _NVGs];

// Export to string

// Prepare arrays
pr _primary = [];
pr _secondary = [];
pr _handgun = [];

pr _i = 0;
while {_i < count _primaryWeapons} do {
	_primary pushBack [_primaryWeapons#_i, _primaryWeaponMagazines#_i];
	_i = _i + 1;
};

pr _i = 0;
while {_i < count _secondaryWeapons} do {
	_secondary pushBack [_secondaryWeapons#_i, _secondaryWeaponMagazines#_i];
	_i = _i + 1;
};

pr _i = 0;
while {_i < count _handgunWeapons} do {
	_handgun pushBack [_handgunWeapons#_i, _handgunWeaponMagazines#_i];
	_i = _i + 1;
};

pr _arrayExport = [	_primary,
					_primaryWeaponItems,
					_secondary,
					_secondaryWeaponItems,
					_handgun,
					_handgunWeaponItems,
					_items,
					_headgears,
					_vests,
					_backpacks,
					_NVGs,
					_grenades,
					_explosives];

// Export a human-readable string if requested
if (_returnString) then {
	pr _tab = toString [9];
	pr _nl = toString [10];

	// Function to convert array to a beautyful string with tabs and stuff
	_fnc_arrayToString = {
		params ["_array", "_str", "_level"];
		
		private _arraySize = count _array;

		for "_i" from 0 to (_level-1) do {_str = _str + _tab;}; // Add tabs
		_str = _str + "[";
		_str = _str + _nl;

		private _index = 0;
		while {_index < (count _array) } do {
			//_str = _str + _nl; // New line
			private _element = _array#_index;

			// Check element, if it's an array or not
			if (_element isEqualType "") then {
				// Add tabs plus one more tab
				for "_i" from 0 to (_level) do {_str = _str + _tab;};
				_str = _str + (format ['"%1"', _element]);
			} else {
				_str = [_element, _str, _level+1] call _fnc_arrayToString;
			};

			if (_index <= (_arraySize - 2)) then {
				_str = _str + ",";
			};
			_str = _str + _nl;

			_index = _index + 1;
		};

		//_str = _str + _nl;
		for "_i" from 0 to (_level-1) do {_str = _str + _tab;}; // Add tabs
		_str = _str + "]";
		
		_str
	};

	pr _strStart = 	(format ["/* Exported with t_fnc_processTemplateItems for template %1", _t select T_NAME]) + _nl + "Primary weapons" + _nl + "Primary weapon items" + _nl + 
					"Secondary weapons" + _nl + "Secondary weapon items" + _nl + "Handguns" + _nl + "Handgun items" + _nl + "General items */" + _nl;

	pr _str = [_arrayExport, _strStart, 0] call _fnc_arrayToString;
	_str
} else {
	// Otherwise we return an array
	[_arrayExport, _loadoutGear]
};