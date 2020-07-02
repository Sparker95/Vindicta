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

#define EFF_ADD_SCALAR(a, b) 						([a, b] call eff_fnc_add_scalar)
#define EFF_ADD(a, b) 								([a, b] call eff_fnc_add)

#define EFF_DIFF_SCALAR(a, b) 						([a, b] call eff_fnc_diff_scalar)
#define EFF_DIFF(a, b) 								([a, b] call eff_fnc_diff)

#define EFF_MUL_SCALAR(e, s) 						([e, s] call eff_fnc_mul_scalar)
#define EFF_MUL(a, b) 								([a, b] call eff_fnc_mul)

#define EFF_MIN_SCALAR(e, s) 						([e, s] call eff_fnc_min_scalar)
#define EFF_MIN(a, b) 								([a, b] call eff_fnc_min)

#define EFF_MAX_SCALAR(e, s) 						([e, s] call eff_fnc_max_scalar)
#define EFF_MAX(a, b) 								([a, b] call eff_fnc_max)
#define EFF_FLOOR_0(e) 								(EFF_MAX_SCALAR(e, 0))

#define EFF_CLAMP_SCALAR(e, a, b) 					(EFF_MIN_SCALAR(EFF_MAX_SCALAR(e, a), b))
#define EFF_SUM(a)									(a call eff_fnc_sum)
#define EFF_FLOOR(a) 								(a call eff_fnc_floor)
#define EFF_CEIL(a) 								(a call eff_fnc_ceil)

#define EFF_SIMULATE_ATTACK(attacker, defender) 	([attacker, defender] call eff_fnc_simulate_attack)

#define EFF_EQUAL(a, b)								(a isEqualTo b)
#define EFF_GT(a, b)								([a, b] call eff_fnc_gt)
#define EFF_GTE(a, b)								([a, b] call eff_fnc_gte)
#define EFF_LT(a, b)								([a, b] call eff_fnc_lt)
#define EFF_LTE(a, b)								([a, b] call eff_fnc_lte)

#define EFF_MASK_DEF(e)								EFF_MUL(e, T_EFF_def_mask)
#define EFF_MASK_ATT(e)								EFF_MUL(e, T_EFF_att_mask)
#define EFF_MASK_DEF_ATT(e)							EFF_MUL(e, T_EFF_def_att_mask)
#define EFF_DEF_SUB(e) 								(e call eff_fnc_def_sub)
#define EFF_ATT_SUB(e) 								(e call eff_fnc_att_sub)

#define EFF_MAKE_FROM_SUBS(a, d) 					([a, d] call eff_fnc_make_from_subs)


#define EFF_SUB_ADD_SCALAR(a, b) 					([a, b] call eff_fnc_sub_add_scalar)
#define EFF_SUB_ADD(a, b) 							([a, b] call eff_fnc_sub_add)
#define EFF_SUB_DIFF_SCALAR(a, b) 					([a, b] call eff_fnc_sub_diff_scalar)
#define EFF_SUB_DIFF(a, b) 							([a, b] call eff_fnc_sub_diff)
#define EFF_SUB_MUL_SCALAR(e, s) 					([e, s] call eff_fnc_sub_mul_scalar)
#define EFF_SUB_MUL(a, b) 							([a, b] call eff_fnc_sub_mul)
#define EFF_SUB_MIN_SCALAR(e, s) 					([e, s] call eff_fnc_sub_min_scalar)
#define EFF_SUB_MIN(a, b) 							([a, b] call eff_fnc_sub_min)
#define EFF_SUB_MAX_SCALAR(e, s) 					([e, s] call eff_fnc_sub_max_scalar)
#define EFF_SUB_MAX(a, b) 							([a, b] call eff_fnc_sub_max)
#define EFF_SUB_CLAMP_SCALAR(e, a, b) 				(EFF_MIN_SCALAR(EFF_MAX_SCALAR(e, a), b))
#define EFF_SUB_SUM(a) 								(a call eff_fnc_sub_sum)
#define EFF_SUB_FLOOR(a) 							(a call eff_fnc_sub_floor)
#define EFF_SUB_CEIL(a) 							(a call eff_fnc_sub_ceil)
