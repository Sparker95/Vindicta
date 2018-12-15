/*
    By: Jeroen Notenbomer

	Get the index of which item is part of

    Inputs:
        1: item			"name"
        2: (list)		[1,3,10]	index to search in, optional

    Outputs
        index or -1 if not found
*/

#define INITTYPES\
		_types = [];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_PRIMARYWEAPON,["AssaultRifle","MachineGun","SniperRifle","Shotgun","Rifle","SubmachineGun"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_SECONDARYWEAPON,["Launcher","MissileLauncher","RocketLauncher"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_HANDGUN,["Handgun"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_UNIFORM,["Uniform"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_VEST,["Vest"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_BACKPACK,["Backpack"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_HEADGEAR,["Headgear"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_GOGGLES,["Glasses"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_NVGS,["NVGoggles"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_BINOCULARS,["Binocular","LaserDesignator"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_MAP,["Map"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_GPS,["GPS","UAVTerminal"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_RADIO,["Radio"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_COMPASS,["Compass"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_WATCH,["Watch"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_FACE,[]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_VOICE,[]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_INSIGNIA,[]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_ITEMOPTIC,["AccessorySights"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_ITEMMUZZLE,["AccessoryMuzzle"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_ITEMACC,["AccessoryPointer"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_ITEMBIPOD,["AccessoryBipod"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_CARGOMAG,[]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_CARGOMAGALL,["Bullet","Missile","Rocket","Shell","ShotgunShell","SmokeShell","Laser"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_CARGOTHROW,["Grenade","SmokeShell","Flare"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_CARGOPUT,["Mine","MineBounding","MineDirectional"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_CARGOMISC,["FirstAidKit","Medikit","MineDetector","Toolkit"]];



#include "\A3\ui_f\hpp\defineDIKCodes.inc"
#include "\A3\Ui_f\hpp\defineResinclDesign.inc"

params ["_item"];
private ["_types","_return","_data"];
_return = -1;

INITTYPES

(_item call bis_fnc_itemType) params ["_weaponTypeCategory", "_weaponTypeSpecific"];

{
	if (_weaponTypeSpecific in _x) exitwith {_return = _foreachindex;};
} foreach _types;


if(_return == -1)then{
	private _data = (missionnamespace getvariable "bis_fnc_arsenal_data");
	if (isNil "_data") exitWith {};
	{
		private _index = _x;
		private _dataSet = _data select _index;

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

_return;