#include "Efficiency.hpp"

#include "common.hpp"

#define _DEF_EFF_BINARY_OP_EFF_EFF(fn) \
{ \
    params ['_a', '_b']; \
    private _res = []; \
    { \
        _res pushBack (_x fn (_b select _forEachIndex)); \
    } foreach _a; \
    _res \
}
// Operation which performs accumulation int oa destination vector
#define _DEF_EFF_BINARY_OP_ACC_EFF_EFF(fn) \
{ \
	_CREATE_PROFILE_SCOPE("_DEF_EFF_BINARY_OP_ACC_EFF_EFF"); \
	params ["_dest", "_b"]; \
	{ \
		_dest set [_forEachIndex, (_dest select _forEachIndex) fn _x]; \
	} forEach _b; \
}
#define _DEF_EFF_BINARY_OP_EFF_SCALAR(fn) \
{ \
    params ['_a', '_b']; \
    _a apply { _x fn _b } \
}
#define _DEF_EFF_UNARY_OP_EFF(fn) \
{ \
    _this apply { fn _x } \
}
#define _DEF_SUB_BINARY_OP_SUB_SUB(fn) \
{ \
    params ['_a', '_b']; \
    [(_a select 0) fn (_b select 0), (_a select 1) fn (_b select 1), (_a select 2) fn (_b select 2), (_a select 3) fn (_b select 3)] \
}
#define _DEF_SUB_BINARY_OP_SUB_SCALAR(fn) \
{ \
    params ['_a', '_b']; \
    [(_a select 0) fn _b, (_a select 1) fn _b, (_a select 2) fn _b, (_a select 3) fn _b] \
}
#define _DEF_SUB_UNARY_OP_SUB(fn) \
{ \
    [fn (_this select 0), fn (_this select 1), fn (_this select 2), fn (_this select 3)] \
}

#define _DEF_EFF_BOOL_OP_EFF_EFF(fn) \
{ \
    params ['_a', '_b']; \
    private _res = true; \
    { \
        if !(_x fn (_b select _forEachIndex)) exitWith { _res = false }; \
    } foreach _a; \
    _res \
}

// E F F   F U N C T I O N S 
eff_fnc_add_scalar = _DEF_EFF_BINARY_OP_EFF_SCALAR(+);
eff_fnc_add = _DEF_EFF_BINARY_OP_EFF_EFF(+);
eff_fnc_acc_add = _DEF_EFF_BINARY_OP_ACC_EFF_EFF(+);
eff_fnc_diff_scalar = _DEF_EFF_BINARY_OP_EFF_SCALAR(-);
eff_fnc_diff = _DEF_EFF_BINARY_OP_EFF_EFF(-);
eff_fnc_acc_diff = _DEF_EFF_BINARY_OP_ACC_EFF_EFF(-);
eff_fnc_mul_scalar = _DEF_EFF_BINARY_OP_EFF_SCALAR(*);
eff_fnc_mul = _DEF_EFF_BINARY_OP_EFF_EFF(*);
eff_fnc_sum = {  _this#0 + _this#1 + _this#2 + _this#3 + _this#4 + _this#5 + _this#6 + _this#7 + _this#8 + _this#9 + _this#10 + _this#11 + _this#12 + _this#13 };
eff_fnc_min_scalar = _DEF_EFF_BINARY_OP_EFF_SCALAR(min);
eff_fnc_min = _DEF_EFF_BINARY_OP_EFF_EFF(min);
eff_fnc_max_scalar = _DEF_EFF_BINARY_OP_EFF_SCALAR(max);
eff_fnc_max = _DEF_EFF_BINARY_OP_EFF_EFF(max);
eff_fnc_floor = _DEF_EFF_UNARY_OP_EFF(floor);
eff_fnc_ceil = _DEF_EFF_UNARY_OP_EFF(ceil);

eff_fnc_gt = _DEF_EFF_BOOL_OP_EFF_EFF(>);
eff_fnc_gte = _DEF_EFF_BOOL_OP_EFF_EFF(>=);
eff_fnc_lt = _DEF_EFF_BOOL_OP_EFF_EFF(<);
eff_fnc_lte = _DEF_EFF_BOOL_OP_EFF_EFF(<=);

// S U B   F U N C T I O N S 
eff_fnc_def_sub = { _this select [0, 4] };
eff_fnc_att_sub = { _this select [4, 4] };
eff_fnc_make_from_subs = { _this#0 + _this#1 };
eff_fnc_sub_add_scalar = _DEF_SUB_BINARY_OP_SUB_SCALAR(+);
eff_fnc_sub_add = _DEF_SUB_BINARY_OP_SUB_SUB(+);
eff_fnc_sub_diff_scalar = _DEF_SUB_BINARY_OP_SUB_SCALAR(-);
eff_fnc_sub_diff = _DEF_SUB_BINARY_OP_SUB_SUB(-);
eff_fnc_sub_mul_scalar = _DEF_SUB_BINARY_OP_SUB_SCALAR(*);
eff_fnc_sub_mul = _DEF_SUB_BINARY_OP_SUB_SUB(*);
eff_fnc_sub_sum = { _this#0 + _this#1 + _this#2 + _this#3 };
eff_fnc_sub_min_scalar = _DEF_SUB_BINARY_OP_SUB_SCALAR(min);
eff_fnc_sub_min = _DEF_SUB_BINARY_OP_SUB_SUB(min);
eff_fnc_sub_max_scalar = _DEF_SUB_BINARY_OP_SUB_SCALAR(max);
eff_fnc_sub_max = _DEF_SUB_BINARY_OP_SUB_SUB(max);
eff_fnc_sub_floor = _DEF_SUB_UNARY_OP_SUB(floor);
eff_fnc_sub_ceil = _DEF_SUB_UNARY_OP_SUB(ceil);

eff_fnc_simulate_attack = {
    params ['_attackers', '_defenders'];
    private _res = [];
    private _before = 0;
    private _after = 0;
    {
        private _def = _defenders select _forEachIndex;
        _before = _before + _def;
        _def = 0 max (_def - _x);
        _res pushBack _def;
        _after = _after + _def;
    } forEach (_attackers select [4, 4]);

    // Avoid that divide by 0
    if(_before == 0) exitWith { +T_EFF_null };

    // Simulate losses to attack values
    private _lossFactor = _after / _before;
    _res + ((_defenders select [4,4]) apply { floor (_x * _lossFactor) })
};

// Allocation validation functions
// They return an array of unsatisfied constraints in format [[_constraint, _value], [_constraint, _value]]

// Validate that we can destroy them
eff_fnc_validateAttack = {
	params ["_effOur", "_effTheir"];
	private _ret = [];
	private _ids = [	[T_EFF_aSoft,	T_EFF_soft],
						[T_EFF_aMedium,	T_EFF_medium],
						[T_EFF_aArmor,	T_EFF_armor],
						[T_EFF_aAir,	T_EFF_air]];
	{
		_x params ["_idOur", "_idTheir"];
		if (_effOur#_idOur < _effTheir#_idTheir) then {
			_ret pushBack [_idOur, _effTheir#_idTheir - _effOur#_idOur];
		};
	} forEach _ids;
	_ret
};

// Validates that we can defend against them
eff_fnc_validateDefense = {
	params ["_effOur", "_effTheir"];
	private _ret = [];
	private _ids = [	[T_EFF_soft,	T_EFF_aSoft],
						[T_EFF_medium,	T_EFF_aMedium],
						[T_EFF_armor,	T_EFF_aArmor],
						[T_EFF_air,		T_EFF_aAir]];
	{
		_x params ["_idOur", "_idTheir"];
		if (_effOur#_idOur < _effTheir#_idTheir) then {
			_ret pushBack [_idOur, _effTheir#_idTheir - _effOur#_idOur]
		};
	} forEach _ids;
	_ret
};

// Validates that we can transport ourselves
// Their eff vector can represent an external requirement to allocate some more transport  
eff_fnc_validateTransport = {
	params ["_effOur", ["_effTheir", T_EFF_null]];
	// How many units are allocated as crew?
	private _usedCrewSpace = _effOur#T_EFF_reqCrew min _effOur#T_EFF_crew;
	private _passengersSpace = _effOur#T_EFF_transport;
	private _requiredSpace = _effOur#T_EFF_reqTransport - (_usedCrewSpace + _passengersSpace);
	if (_requiredSpace > 0) then { // Try to allocate a bit more transport space
		[[T_EFF_transport, _requiredSpace]]
	} else {
		[]
	}
};

// Validate transport capability VS the external requirement (for logistics)
eff_fnc_validateTransportExternal = {
	params ["_effOur", ["_effTheir", T_EFF_null]];
	private _transportOur = _effOur#T_EFF_transport;
	if (_effTheir#T_EFF_transport > _transportOur) exitWith { // Try to allocate a bit more transport space
		[[T_EFF_transport, _effTheir#T_EFF_transport - _transportOur]]
	};
	[]
};

// Validate that we have enough crew
eff_fnc_validateCrew = {
	params ["_effOur", "_effTheir"]; // _effTheir is not needed, but we pass it anyway
	if (_effOur#T_EFF_reqCrew > _effOur#T_EFF_crew) exitWith {
		[[T_EFF_crew, _effOur#T_EFF_reqCrew - _effOur#T_EFF_crew]] // Need more crew
	};
	[]
};

eff_fnc_validateCrewExternal = {
	params ["_effOur", "_effTheir"]; // _effTheir is not needed, but we pass it anyway
	if (_effTheir#T_EFF_crew > _effOur#T_EFF_crew) exitWith {
		[[T_EFF_crew, _effTheir#T_EFF_crew - _effOur#T_EFF_crew]] // Need more crew
	};
	[]
};


// Functions to work with masks and other things
// Combines an array of vector masks into one (just sums them up and clips to 0...1 range)
eff_fnc_combineMasks = {

	_CREATE_PROFILE_SCOPE("eff_fnc_combineMasks");

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

	_CREATE_PROFILE_SCOPE("eff_fnc_matchesMask");

	params ["_eff", "_mask"];
	pr _match = true;
	{
		if (_x>0 && {(_eff#_forEachIndex) == 0}) exitWIth { _match = false };
	} forEach _mask;
	_match
};


#ifdef _SQF_VM

#define EFF_012 	[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
#define EFF_012_5 	[0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 11.5, 12.5, 13.5]
#define EFF_111 	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
#define EFF_222 	[2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
#define EFF_ZERO	(+T_EFF_null)

#define EFF_ATT 	[0, 0, 0, 0, 1, 0, 3, 2, 0, 0, 0, 0, 0, 0]
#define EFF_DEF 	[4, 2, 8, 0, 4, 0, 4, 0, 0, 0, 0, 0, 0, 0]

["EFF macros", {
	["EFF_ADD_SCALAR", 			[1, 2, 3, 4, 5, 6, 7, 8, 9, 10,11,12,13,14] isEqualTo EFF_ADD_SCALAR(EFF_012, 1)] call test_Assert;
	["EFF_ADD", 				[0, 2, 4, 6, 8, 10,12,14,16,18,20,22,24,26] isEqualTo EFF_ADD(EFF_012, EFF_012)] call test_Assert;
	["EFF_DIFF_SCALAR", 		[-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12] isEqualTo EFF_DIFF_SCALAR(EFF_012, 1)] call test_Assert;
	["EFF_DIFF", 				EFF_ZERO isEqualTo EFF_DIFF(EFF_012, EFF_012)] call test_Assert;
	["EFF_MUL_SCALAR", 			[0, 2, 4, 6, 8, 10,12,14,16,18,20,22,24,26] isEqualTo EFF_MUL_SCALAR(EFF_012, 2)] call test_Assert;
	["EFF_MUL", 				[0, 1, 4, 9, 16,25,36,49,64,81,100,121,144,169] isEqualTo EFF_MUL(EFF_012, EFF_012)] call test_Assert;
	["EFF_MIN_SCALAR", 			[0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1] isEqualTo EFF_MIN_SCALAR(EFF_012, 1)] call test_Assert;
	["EFF_MIN", 				[0, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2] isEqualTo EFF_MIN(EFF_012, EFF_222)] call test_Assert;
	["EFF_MAX_SCALAR", 			[4, 4, 4, 4, 4, 5, 6, 7, 8, 9, 10,11,12,13] isEqualTo EFF_MAX_SCALAR(EFF_012, 4)] call test_Assert;
	["EFF_MAX", 				[2, 2, 2, 3, 4, 5, 6, 7, 8, 9, 10,11,12,13] isEqualTo EFF_MAX(EFF_012, EFF_222)] call test_Assert;

	["EFF_CLAMP_SCALAR", 		[2, 2, 2, 3, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5] isEqualTo EFF_CLAMP_SCALAR(EFF_012, 2, 5)] call test_Assert;
	["EFF_SUM", 				91 isEqualTo EFF_SUM(EFF_012)] call test_Assert;

	["EFF_FLOOR", 				[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,11,12,13] isEqualTo EFF_FLOOR(EFF_012_5)] call test_Assert;
	["EFF_CEIL",  				{[1, 2, 3, 4, 5, 6, 7, 8, 9, 10,11,12,13,14] isEqualTo EFF_CEIL(EFF_012_5)}] call test_Assert;

	["EFF_SIMULATE_ATTACK",  	{[3, 2, 5, 0, 2, 0, 2, 0] isEqualTo EFF_SIMULATE_ATTACK(EFF_ATT, EFF_DEF)}] call test_Assert;

	["EFF_EQUAL 1", 			{ EFF_EQUAL(EFF_012, EFF_012) }] call test_Assert;
	["EFF_EQUAL 2", 			{ !EFF_EQUAL(EFF_012, EFF_012_5) }] call test_Assert;
	
	["EFF_GT 1", 				{ !EFF_GT(EFF_012, EFF_012) }] call test_Assert;
	["EFF_GT 2", 				{ EFF_GT(EFF_012_5, EFF_012) }] call test_Assert;
	["EFF_GTE 1", 				{ EFF_GTE(EFF_012, EFF_012) }] call test_Assert;
	["EFF_GTE 2", 				{ EFF_GTE(EFF_012_5, EFF_012) }] call test_Assert;

	["EFF_LT 1", 				{ !EFF_LT(EFF_012, EFF_012) }] call test_Assert;
	["EFF_LT 2", 				{ EFF_LT(EFF_012, EFF_012_5) }] call test_Assert;
	["EFF_LTE 1", 				{ EFF_LTE(EFF_012, EFF_012) }] call test_Assert;
	["EFF_LTE 2", 				{ EFF_LTE(EFF_012, EFF_012_5) }] call test_Assert;

	["max(mul(...,...),...)", 	[4, 4, 4, 9, 16, 25, 36, 49,64,81,100,121,144,169] isEqualTo EFF_MAX_SCALAR(EFF_MUL(EFF_012, EFF_012), 4)] call test_Assert;

	true
}] call test_AddTest;

#define EFF_SUB_012 	[0, 1, 2, 3]
#define EFF_SUB_012_5 	[0.5, 1.5, 2.5, 3.5]
#define EFF_SUB_111 	[1, 1, 1, 1]
#define EFF_SUB_222 	[2, 2, 2, 2]

["EFF_SUB macros", {
	["EFF_SUB_ADD_SCALAR", 			[1, 2, 3, 4] isEqualTo EFF_SUB_ADD_SCALAR(EFF_SUB_012, 1)] call test_Assert;
	["EFF_SUB_ADD", 				[0, 2, 4, 6] isEqualTo EFF_SUB_ADD(EFF_SUB_012, EFF_SUB_012)] call test_Assert;
	["EFF_SUB_DIFF_SCALAR", 		[-1, 0, 1, 2] isEqualTo EFF_SUB_DIFF_SCALAR(EFF_SUB_012, 1)] call test_Assert;
	["EFF_SUB_DIFF", 				[0, 0, 0, 0] isEqualTo EFF_SUB_DIFF(EFF_SUB_012, EFF_SUB_012)] call test_Assert;
	["EFF_SUB_MUL_SCALAR", 			[0, 2, 4, 6] isEqualTo EFF_SUB_MUL_SCALAR(EFF_SUB_012, 2)] call test_Assert;
	["EFF_SUB_MUL", 				[0, 1, 4, 9] isEqualTo EFF_SUB_MUL(EFF_SUB_012, EFF_SUB_012)] call test_Assert;
	["EFF_SUB_MIN_SCALAR", 			[0, 1, 1, 1] isEqualTo EFF_SUB_MIN_SCALAR(EFF_SUB_012, 1)] call test_Assert;
	["EFF_SUB_MIN", 				[0, 1, 2, 2] isEqualTo EFF_SUB_MIN(EFF_SUB_012, EFF_SUB_222)] call test_Assert;
	["EFF_SUB_MAX_SCALAR", 			[4, 4, 4, 4] isEqualTo EFF_SUB_MAX_SCALAR(EFF_SUB_012, 4)] call test_Assert;
	["EFF_SUB_MAX", 				[2, 2, 2, 3] isEqualTo EFF_SUB_MAX(EFF_SUB_012, EFF_SUB_222)] call test_Assert;
	["EFF_SUB_CLAMP_SCALAR", 		[2, 2, 2, 3] isEqualTo EFF_SUB_CLAMP_SCALAR(EFF_SUB_012, 2, 5)] call test_Assert;
	["EFF_SUB_SUM", 				6 isEqualTo EFF_SUB_SUM(EFF_SUB_012)] call test_Assert;

	["EFF_SUB_FLOOR", 				[0, 1, 2, 3] isEqualTo EFF_SUB_FLOOR(EFF_SUB_012_5)] call test_Assert;
	["EFF_SUB_CEIL",  				{[1, 2, 3, 4] isEqualTo EFF_SUB_CEIL(EFF_SUB_012_5)}] call test_Assert;

	["max(mul(...,...),...)", 		[4, 4, 4, 9] isEqualTo EFF_SUB_MAX_SCALAR(EFF_SUB_MUL(EFF_SUB_012, EFF_SUB_012), 4)] call test_Assert;

	true
}] call test_AddTest;

["EFF validation", {
	["validate attack", 			[] isEqualTo ([EFF_111, EFF_ZERO] call eff_fnc_validateAttack)] call test_Assert;
	["validate defense", 			[[0,1], [1,1], [2,1], [3,1]] isEqualTo ([EFF_ZERO, EFF_111] call eff_fnc_validateDefense)] call test_Assert;

	// Validate crew
	_e0 = +T_EFF_null;
	_e0 set [T_EFF_crew, 4];
	_e0 set [T_EFF_reqCrew, 5];
	["validate crew", 			[[T_EFF_crew, 1]] isEqualTo ([_e0] call eff_fnc_validateCrew)] call test_Assert;

	// Validate transport
	_e0 = +T_EFF_null;
	_e0 set [T_EFF_transport, 4];
	_e0 set [T_EFF_reqTransport, 5];
	["validate transport", 			[[T_EFF_transport, 1]] isEqualTo ([_e0] call eff_fnc_validateTransport)] call test_Assert;

	true
}] call test_AddTest;

#endif
