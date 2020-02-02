#include "..\defineCommon.inc"

#define STATTYPE_DAMAGE 0
#define STATTYPE_FUEL 1
#define STATTYPE_FUELCARGO 2
#define STATTYPE_AMMOCARGO 3
#define STATTYPE_REPAIRCARGO 4
#define STATTYPES [STATTYPE_FUEL,STATTYPE_FUELCARGO,STATTYPE_AMMO,STATTYPE_REPAIR]

#define FADE_DELAY	0.15

#define IDC_JNG_TAB_CAR TYPE_CAR
#define IDC_JNG_TAB_ARMOR TYPE_ARMOR
#define IDC_JNG_TAB_HELI TYPE_HELI
#define IDC_JNG_TAB_PLANE TYPE_PLANE
#define IDC_JNG_TAB_NAVAL TYPE_NAVAL
#define IDC_JNG_TAB_STATIC TYPE_STATIC

#define IDC_JNG_TAB_REARM IDC_RSCDISPLAYARSENAL_TAB_CARGOMAG
#define IDC_JNG_TAB_REPAIR IDC_RSCDISPLAYARSENAL_TAB_CARGOMAGALL
#define IDC_JNG_TAB_REFUEL IDC_RSCDISPLAYARSENAL_TAB_ITEMACC
#define IDC_JNG_TAB_TEXTURE IDC_RSCDISPLAYARSENAL_TAB_ITEMMUZZLE
#define IDC_JNG_TAB_COMPONENT IDC_RSCDISPLAYARSENAL_TAB_ITEMBIPOD
#define IDC_JNG_TAB_PYLON IDC_RSCDISPLAYARSENAL_TAB_CARGOPUT
#define IDC_JNG_TAB_HARDPOINT IDC_RSCDISPLAYARSENAL_TAB_ITEMOPTIC //uses the same tab id as IDC_JNG_TAB_PYLON

#define IDC_JNG_TAB_REARM_SORT IDC_RSCDISPLAYARSENAL_TAB_ITEMOPTIC


#define IDCS_LEFT\
	IDC_JNG_TAB_CAR,\
	IDC_JNG_TAB_ARMOR,\
	IDC_JNG_TAB_HELI,\
	IDC_JNG_TAB_PLANE,\
	IDC_JNG_TAB_NAVAL,\
	IDC_JNG_TAB_STATIC

#define IDCS_RIGHT\
	IDC_JNG_TAB_REARM,\
	IDC_JNG_TAB_REPAIR,\
	IDC_JNG_TAB_REFUEL,\
	IDC_JNG_TAB_TEXTURE,\
	IDC_JNG_TAB_COMPONENT,\
	IDC_JNG_TAB_PYLON,\
	IDC_JNG_TAB_HARDPOINT

#define IDCS	[IDCS_LEFT,IDCS_RIGHT]

#define DECOMPILE_DATA\
	pr _data = if(_dataStr =="")then{[]}else{parseSimpleArray _dataStr};
	
#define SPLIT_SAVE\
	_data params [\
		"_name",\
		"_beingChanged",\
		"_locked",\
		"_lockedName",\
		"_type",\
		"_texture",\
		"_animations",\
		"_ammoClassic",\
		"_ammoPylon",\
		"_damage",\
		"_attachItem",\
		"_fuel",\
		"_fuelCap",\
		"_fuelcargo",\
		"_fuelcargoCap",\
		"_ammocargo",\
		"_ammocargoCap",\
		"_repaircargo",\
		"_repaircargoCap"\
	];\
	
#define COMPILE_SAVE\
	if(isnil "_name" || isnil "_beingChanged" || isnil "_locked" || isnil "_lockedName"  || isnil "_type" || isnil "_texture" || isnil "_animations" || isnil "_ammoClassic"|| isnil "_ammoPylon"|| isnil "_ammoClassic" || isnil "_damage" || isnil "_fuel" || isnil "_fuelCap" || isnil "_fuelcargo" || isnil "_fuelcargoCap" || isnil "_ammocargo" || isnil "_ammocargoCap" || isnil "_repaircargo" || isnil "_repaircargoCap")then{\
		["ERROR COMPILE_SAVE JGA"] call BIS_fnc_error;\
		diag_log "ERROR COMPILE_SAVE JGA";\
	};\
	pr _data = [_name, _beingChanged, _locked, _lockedName, _type, _texture, _animations, _ammoClassic, _ammoPylon, _damage, _attachItem, _fuel, _fuelCap,_fuelcargo,_fuelcargoCap,_ammocargo,_ammocargoCap,_repaircargo,_repaircargoCap];\
	pr _datastr = str _data;
	
#define SPLIT_REARM\
	pr _magazine = _data select 0;\
	pr _currentAmount = _data select 1;\
	pr _maxAmount = _data select 2;\
	pr _displayName = _data select 3;
	
#define COMPILE_REARM\
	pr _data = [_magazine, _currentAmount, _maxAmount, _displayName];\
	pr _datastr = str _data;


#define AMOUTTOTEXT\
{\
	pr _amount = _this;\
	if(_amount == -1)exitWith{"   ∞    ";};\
	pr _suffix = "";\
	pr _prefix = "";\
	if(_amount > 9999)then{\
		_amount = round(_amount/1000);_suffix="k";\
		_prefix = switch true do{\
			case(_amount>=1000):{_amount = 9999; "";};\
			case(_amount>=100):{"0";};\
			case(_amount>=10):{"00";};\
			case(_amount>=0):{"000";};\
		};\
	}else{\
		_prefix = switch true do{\
			case(_amount>=1000):{"";};\
			case(_amount>=100):{"0";};\
			case(_amount>=10):{"00";};\
			case(_amount>=0):{"000";};\
		};\
	};\
	(_prefix + (str _amount) + _suffix);\
};


#define MAX_DISTANCE_TO_STORE 40
