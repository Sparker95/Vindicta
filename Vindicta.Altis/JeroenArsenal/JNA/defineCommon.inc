#include "..\defineCommon.inc"

#define EMPTY_ARRAY [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]]



//STRINGS ACTIONS

#define STR_ACTION_ICON_ARSENAL "\A3\ui_f\data\GUI\Rsc\RscDisplayArsenal\spaceArsenal_ca.paa"
#define STR_ACTION_TEXT_ARSENAL localize "STR_JNA_ACT_OPEN"

#define STR_ACTION_ICON_ARSENAL_CONTAINER "JeroenArsenal\Icons\JN_unloadVehicle.paa"  
#define STR_ACTION_TEXT_ARSENAL_CONTAINER localize "STR_JNA_ACT_CONTAINER_OPEN"

#define STR_ACTION_ICON_ARSENAL_UNLOAD "JeroenArsenal\Icons\JN_loadVehicle2.paa"
#define STR_ACTION_TEXT_ARSENAL_UNLOAD localize "STR_JNA_ACT_UNLOAD"

#define INITTYPES\
		private _types = [];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_UNIFORM,["Uniform"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_VEST,["Vest"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_BACKPACK,["Backpack"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_HEADGEAR,["Headgear"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_GOGGLES,["Glasses"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_NVGS,["NVGoggles"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_BINOCULARS,["Binocular","LaserDesignator"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_PRIMARYWEAPON,["AssaultRifle","MachineGun","SniperRifle","Shotgun","Rifle","SubmachineGun"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_SECONDARYWEAPON,["Launcher","MissileLauncher","RocketLauncher"]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_HANDGUN,["Handgun"]];\
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
		_types set [IDC_RSCDISPLAYARSENAL_TAB_CARGOMAGALL,[]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_CARGOTHROW,[/*"Grenade","SmokeShell"*/]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_CARGOPUT,[/*"Mine","MineBounding","MineDirectional"*/]];\
		_types set [IDC_RSCDISPLAYARSENAL_TAB_CARGOMISC,["FirstAidKit","Medikit","MineDetector","Toolkit"]];

