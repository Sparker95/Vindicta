#include "..\AI\Commander\AICommander.hpp"

#include "..\common.h"

// Development of the new unit allocator algorithm

// Initialize test functions
#ifdef _SQF_VM
CALL_COMPILE_COMMON("Tests\initTests.sqf");
#endif

//CALL_COMPILE_COMMON("initModules.sqf");

if (isNil "OOP_Light_initialized") then {
	OOP_Light_initialized = true;
	CALL_COMPILE_COMMON("OOP_Light\OOP_Light_init.sqf");
};

//Initialize templates
CALL_COMPILE_COMMON("Templates\initFunctions.sqf");
CALL_COMPILE_COMMON("Templates\initVariables.sqf");

// Initialize GarrisonModel (because it has the allocation algorithm)
CALL_COMPILE_COMMON("SaveSystem\Storable.sqf");
CALL_COMPILE_COMMON("AI\Commander\Model\WorldModel.sqf");
CALL_COMPILE_COMMON("AI\Commander\Model\ModelBase.sqf");
CALL_COMPILE_COMMON("AI\Commander\Model\GarrisonModel.sqf");


#define pr private

//#define UNIT_ALLOCATOR_DEBUG
//#ifdef UNIT_ALLOCATOR_DEBUG

//#define ASP_ENABLE

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

	pr _srcGarrEff = [_comp] call comp_fnc_getEfficiency;

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
	_effExt set [T_EFF_soft, 5];
	//_effExt set [T_EFF_medium, 3];
	_effExt set [T_EFF_armor, 1];
	//_effExt set [T_EFF_air, 2];

	pr _allocationFlags = [SPLIT_VALIDATE_ATTACK, SPLIT_VALIDATE_TRANSPORT, SPLIT_VALIDATE_CREW]; // "eff_fnc_validateDefense"

	pr _payloadWhitelistMask = T_comp_ground_or_infantry_mask;

	pr _payloadBlacklistMask = T_comp_static_mask;	// Don't take static weapons under any conditions

	pr _transportWhitelistMask = T_comp_ground_or_infantry_mask;	// Take ground units, take any infantry to satisfy crew requirements

	pr _transportBlacklistMask = [];
	pr _requiredComp = [
		[T_INF, T_INF_officer, 3]
	];

	pr _args = [_effExt, _allocationFlags, _comp, _srcGarrEff,
				_payloadWhitelistMask, _payloadBlacklistMask,
				_transportWhitelistMask, _transportBlacklistMask,
				_requiredComp];
	private _allocResult = CALLSM("GarrisonModel", "allocateUnits", _args);
	diag_log _allocResult;

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