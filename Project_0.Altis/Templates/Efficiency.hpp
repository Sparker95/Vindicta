#define T_EFF_SOFT			0
#define T_EFF_MEDIUM		1
#define T_EFF_ARMOR			2
#define T_EFF_AIR			3
#define T_EFF_ANTI_SOFT		4
#define T_EFF_ANTI_MEDIUM	5
#define T_EFF_ANTI_ARMOR	6
#define T_EFF_ANTI_AIR		7
#define T_EFF_DUMMY			8

#define T_EFF_CAN_DESTROY_ALL 4

#define EFF_ADD_SCALAR(a, b) ([a, b] call fn_eff_add_scalar)
#define EFF_ADD(a, b) ([a, b] call fn_eff_add)

#define EFF_SUB_SCALAR(a, b) ([a, b] call fn_eff_diff_scalar)
#define EFF_SUB(a, b) ([a, b] call fn_eff_diff)

#define EFF_MUL_SCALAR(e, s) ([e, s] call fn_eff_mul_scalar)
#define EFF_MUL(a, b) ([a, b] call fn_eff_mul)

#define EFF_MIN_SCALAR(e, s) ([e, s] call fn_eff_min_scalar)
#define EFF_MIN(a, b) ([a, b] call fn_eff_min)

#define EFF_MAX_SCALAR(e, s) ([e, s] call fn_eff_max_scalar)
#define EFF_MAX(a, b) ([a, b] call fn_eff_max)

#define EFF_CLAMP_SCALAR(e, a, b) (EFF_MIN_SCALAR(EFF_MAX_SCALAR(e, a), b))
#define EFF_SUM(a) (a call fn_eff_sum)
#define EFF_FLOOR(a) (a call fn_eff_floor)
#define EFF_CEIL(a) (a call fn_eff_ceil)

#define EFF_ATTACK(attacker, defender) [attacker, defender] call fn_eff_attack

#ifdef _SQF_VM

#define EFF_012 [0, 1, 2, 3, 4, 5, 6, 7]
#define EFF_012_5 [0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5]
#define EFF_111 [1, 1, 1, 1, 1, 1, 1, 1]
#define EFF_222 [2, 2, 2, 2, 2, 2, 2, 2]

["EFF macros", {
	["EFF_ADD_SCALAR", [1, 2, 3, 4, 5, 6, 7, 8] isEqualTo EFF_ADD_SCALAR(EFF_012, 1)] call test_Assert;
	["EFF_ADD", [0, 2, 4, 6, 8, 10, 12, 14] isEqualTo EFF_ADD(EFF_012, EFF_012)] call test_Assert;
	["EFF_SUB_SCALAR", [-1, 0, 1, 2, 3, 4, 5, 6] isEqualTo EFF_SUB_SCALAR(EFF_012, 1)] call test_Assert;
	["EFF_SUB", [0, 0, 0, 0, 0, 0, 0, 0] isEqualTo EFF_SUB(EFF_012, EFF_012)] call test_Assert;
	["EFF_MUL_SCALAR", [0, 2, 4, 6, 8, 10, 12, 14] isEqualTo EFF_MUL_SCALAR(EFF_012, 2)] call test_Assert;
	["EFF_MUL", [0, 1, 4, 9, 16, 25, 36, 49] isEqualTo EFF_MUL(EFF_012, EFF_012)] call test_Assert;
	["EFF_MIN_SCALAR", [0, 1, 1, 1, 1, 1, 1, 1] isEqualTo EFF_MIN_SCALAR(EFF_012, 1)] call test_Assert;
	["EFF_MIN", [0, 1, 2, 2, 2, 2, 2, 2] isEqualTo EFF_MIN(EFF_012, EFF_222)] call test_Assert;
	["EFF_MAX_SCALAR", [4, 4, 4, 4, 4, 5, 6, 7] isEqualTo EFF_MAX_SCALAR(EFF_012, 4)] call test_Assert;
	["EFF_MAX", [2, 2, 2, 3, 4, 5, 6, 7] isEqualTo EFF_MAX(EFF_012, EFF_222)] call test_Assert;

	["EFF_CLAMP_SCALAR", [2, 2, 2, 3, 4, 5, 5, 5] isEqualTo EFF_CLAMP_SCALAR(EFF_012, 2, 5)] call test_Assert;
	["EFF_SUM", 28 isEqualTo EFF_SUM(EFF_012)] call test_Assert;

	["EFF_FLOOR", [0, 1, 2, 3, 4, 5, 6, 7] isEqualTo EFF_FLOOR(EFF_012_5)] call test_Assert;
	["EFF_CEIL",  {[1, 2, 3, 4, 5, 6, 7, 8] isEqualTo EFF_CEIL(EFF_012_5)}] call test_Assert;

	["EFF_ATTACK",  {[4, 4, 4, 4] isEqualTo EFF_ATTACK(EFF_012, EFF_012)}] call test_Assert;

	["max(mul(...,...),...)", [4, 4, 4, 9, 16, 25, 36, 49] isEqualTo EFF_MAX_SCALAR(EFF_MUL(EFF_012, EFF_012), 4)] call test_Assert;
}] call test_AddTest;

#endif
