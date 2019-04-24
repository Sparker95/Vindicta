#include "Efficiency.hpp"

#define _DEF_EFF_BINARY_OP_EFF_EFF(fn) \
{ \
    params ['_a', '_b']; \
    private _res = []; \
    { \
        _res pushBack (_x fn (_b select _forEachIndex)); \
    } foreach _a; \
    _res \
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

#define _DEF_EFF_BOOL_OP_EFF_EFF(fn) { \
    params ['_a', '_b']; \
    private _res = true; \
    { \
        if !(_x fn (_b select _forEachIndex)) exitWith { _res = false }; \
    } foreach _a; \
    _res \
}

// E F F   F U N C T I O N S 
fn_eff_add_scalar = _DEF_EFF_BINARY_OP_EFF_SCALAR(+);
fn_eff_add = _DEF_EFF_BINARY_OP_EFF_EFF(+);
fn_eff_diff_scalar = _DEF_EFF_BINARY_OP_EFF_SCALAR(-);
fn_eff_diff = _DEF_EFF_BINARY_OP_EFF_EFF(-);
fn_eff_mul_scalar = _DEF_EFF_BINARY_OP_EFF_SCALAR(*);
fn_eff_mul = _DEF_EFF_BINARY_OP_EFF_EFF(*);
fn_eff_sum = {  _this#0 + _this#1 + _this#2 + _this#3 + _this#4 + _this#5 + _this#6 + _this#7 };
fn_eff_min_scalar = _DEF_EFF_BINARY_OP_EFF_SCALAR(min);
fn_eff_min = _DEF_EFF_BINARY_OP_EFF_EFF(min);
fn_eff_max_scalar = _DEF_EFF_BINARY_OP_EFF_SCALAR(max);
fn_eff_max = _DEF_EFF_BINARY_OP_EFF_EFF(max);
fn_eff_floor = _DEF_EFF_UNARY_OP_EFF(floor);
fn_eff_ceil = _DEF_EFF_UNARY_OP_EFF(ceil);

fn_eff_gt = _DEF_EFF_BOOL_OP_EFF_EFF(>);
fn_eff_gte = _DEF_EFF_BOOL_OP_EFF_EFF(>=);
fn_eff_lt = _DEF_EFF_BOOL_OP_EFF_EFF(<);
fn_eff_lte = _DEF_EFF_BOOL_OP_EFF_EFF(<=);

// S U B   F U N C T I O N S 
fn_eff_def_sub = { _this select [0, 4] };
fn_eff_att_sub = { _this select [4, 4] };
fn_eff_make_from_subs = { _this#0 + _this#1 };
fn_eff_sub_add_scalar = _DEF_SUB_BINARY_OP_SUB_SCALAR(+);
fn_eff_sub_add = _DEF_SUB_BINARY_OP_SUB_SUB(+);
fn_eff_sub_diff_scalar = _DEF_SUB_BINARY_OP_SUB_SCALAR(-);
fn_eff_sub_diff = _DEF_SUB_BINARY_OP_SUB_SUB(-);
fn_eff_sub_mul_scalar = _DEF_SUB_BINARY_OP_SUB_SCALAR(*);
fn_eff_sub_mul = _DEF_SUB_BINARY_OP_SUB_SUB(*);
fn_eff_sub_sum = { _this#0 + _this#1 + _this#2 + _this#3 };
fn_eff_sub_min_scalar = _DEF_SUB_BINARY_OP_SUB_SCALAR(min);
fn_eff_sub_min = _DEF_SUB_BINARY_OP_SUB_SUB(min);
fn_eff_sub_max_scalar = _DEF_SUB_BINARY_OP_SUB_SCALAR(max);
fn_eff_sub_max = _DEF_SUB_BINARY_OP_SUB_SUB(max);
fn_eff_sub_floor = _DEF_SUB_UNARY_OP_SUB(floor);
fn_eff_sub_ceil = _DEF_SUB_UNARY_OP_SUB(ceil);

fn_eff_simulate_attack = {
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
    if(_before == 0) exitWith { EFF_nul };

    // Simulate losses to attack values
    private _lossFactor = _after / _before;
    _res + ((_defenders select [4,4]) apply { floor (_x * _lossFactor) })
};



#ifdef _SQF_VM

#define EFF_012 	[0, 1, 2, 3, 4, 5, 6, 7]
#define EFF_012_5 	[0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5]
#define EFF_111 	[1, 1, 1, 1, 1, 1, 1, 1]
#define EFF_222 	[2, 2, 2, 2, 2, 2, 2, 2]

#define EFF_ATT 	[0, 0, 0, 0, 1, 0, 3, 2]
#define EFF_DEF 	[4, 2, 8, 0, 4, 0, 4, 0]

["EFF macros", {
	["EFF_ADD_SCALAR", 			[1, 2, 3, 4, 5, 6, 7, 8] isEqualTo EFF_ADD_SCALAR(EFF_012, 1)] call test_Assert;
	["EFF_ADD", 				[0, 2, 4, 6, 8, 10, 12, 14] isEqualTo EFF_ADD(EFF_012, EFF_012)] call test_Assert;
	["EFF_DIFF_SCALAR", 		[-1, 0, 1, 2, 3, 4, 5, 6] isEqualTo EFF_DIFF_SCALAR(EFF_012, 1)] call test_Assert;
	["EFF_DIFF", 				[0, 0, 0, 0, 0, 0, 0, 0] isEqualTo EFF_DIFF(EFF_012, EFF_012)] call test_Assert;
	["EFF_MUL_SCALAR", 			[0, 2, 4, 6, 8, 10, 12, 14] isEqualTo EFF_MUL_SCALAR(EFF_012, 2)] call test_Assert;
	["EFF_MUL", 				[0, 1, 4, 9, 16, 25, 36, 49] isEqualTo EFF_MUL(EFF_012, EFF_012)] call test_Assert;
	["EFF_MIN_SCALAR", 			[0, 1, 1, 1, 1, 1, 1, 1] isEqualTo EFF_MIN_SCALAR(EFF_012, 1)] call test_Assert;
	["EFF_MIN", 				[0, 1, 2, 2, 2, 2, 2, 2] isEqualTo EFF_MIN(EFF_012, EFF_222)] call test_Assert;
	["EFF_MAX_SCALAR", 			[4, 4, 4, 4, 4, 5, 6, 7] isEqualTo EFF_MAX_SCALAR(EFF_012, 4)] call test_Assert;
	["EFF_MAX", 				[2, 2, 2, 3, 4, 5, 6, 7] isEqualTo EFF_MAX(EFF_012, EFF_222)] call test_Assert;

	["EFF_CLAMP_SCALAR", 		[2, 2, 2, 3, 4, 5, 5, 5] isEqualTo EFF_CLAMP_SCALAR(EFF_012, 2, 5)] call test_Assert;
	["EFF_SUM", 				28 isEqualTo EFF_SUM(EFF_012)] call test_Assert;

	["EFF_FLOOR", 				[0, 1, 2, 3, 4, 5, 6, 7] isEqualTo EFF_FLOOR(EFF_012_5)] call test_Assert;
	["EFF_CEIL",  				{[1, 2, 3, 4, 5, 6, 7, 8] isEqualTo EFF_CEIL(EFF_012_5)}] call test_Assert;

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

	["max(mul(...,...),...)", 	[4, 4, 4, 9, 16, 25, 36, 49] isEqualTo EFF_MAX_SCALAR(EFF_MUL(EFF_012, EFF_012), 4)] call test_Assert;
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
}] call test_AddTest;

#endif
