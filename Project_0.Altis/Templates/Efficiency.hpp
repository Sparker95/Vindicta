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

#define EFF_ADD_SCALAR(a, b) 						([a, b] call fn_eff_add_scalar)
#define EFF_ADD(a, b) 								([a, b] call fn_eff_add)

#define EFF_DIFF_SCALAR(a, b) 						([a, b] call fn_eff_diff_scalar)
#define EFF_DIFF(a, b) 								([a, b] call fn_eff_diff)

#define EFF_MUL_SCALAR(e, s) 						([e, s] call fn_eff_mul_scalar)
#define EFF_MUL(a, b) 								([a, b] call fn_eff_mul)

#define EFF_MIN_SCALAR(e, s) 						([e, s] call fn_eff_min_scalar)
#define EFF_MIN(a, b) 								([a, b] call fn_eff_min)

#define EFF_MAX_SCALAR(e, s) 						([e, s] call fn_eff_max_scalar)
#define EFF_MAX(a, b) 								([a, b] call fn_eff_max)
#define EFF_FLOOR_0(e) 								(EFF_MAX_SCALAR(e, 0))

#define EFF_CLAMP_SCALAR(e, a, b) 					(EFF_MIN_SCALAR(EFF_MAX_SCALAR(e, a), b))
#define EFF_SUM(a)									(a call fn_eff_sum)
#define EFF_FLOOR(a) 								(a call fn_eff_floor)
#define EFF_CEIL(a) 								(a call fn_eff_ceil)

#define EFF_SIMULATE_ATTACK(attacker, defender) 	([attacker, defender] call fn_eff_simulate_attack)

#define EFF_DEF_SUB(e) 								(e call fn_eff_def_sub)
#define EFF_ATT_SUB(e) 								(e call fn_eff_att_sub)

#define EFF_MAKE_FROM_SUBS(a, d) 					([a, d] call fn_eff_make_from_subs)


#define EFF_SUB_ADD_SCALAR(a, b) 					([a, b] call fn_eff_sub_add_scalar)
#define EFF_SUB_ADD(a, b) 							([a, b] call fn_eff_sub_add)
#define EFF_SUB_DIFF_SCALAR(a, b) 					([a, b] call fn_eff_sub_diff_scalar)
#define EFF_SUB_DIFF(a, b) 							([a, b] call fn_eff_sub_diff)
#define EFF_SUB_MUL_SCALAR(e, s) 					([e, s] call fn_eff_sub_mul_scalar)
#define EFF_SUB_MUL(a, b) 							([a, b] call fn_eff_sub_mul)
#define EFF_SUB_MIN_SCALAR(e, s) 					([e, s] call fn_eff_sub_min_scalar)
#define EFF_SUB_MIN(a, b) 							([a, b] call fn_eff_sub_min)
#define EFF_SUB_MAX_SCALAR(e, s) 					([e, s] call fn_eff_sub_max_scalar)
#define EFF_SUB_MAX(a, b) 							([a, b] call fn_eff_sub_max)
#define EFF_SUB_CLAMP_SCALAR(e, a, b) 				(EFF_MIN_SCALAR(EFF_MAX_SCALAR(e, a), b))
#define EFF_SUB_SUM(a) 								(a call fn_eff_sub_sum)
#define EFF_SUB_FLOOR(a) 							(a call fn_eff_sub_floor)
#define EFF_SUB_CEIL(a) 							(a call fn_eff_sub_ceil)

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

	["max(mul(...,...),...)", 	[4, 4, 4, 9, 16, 25, 36, 49] isEqualTo EFF_MAX_SCALAR(EFF_MUL(EFF_012, EFF_012), 4)] call test_Assert;
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
