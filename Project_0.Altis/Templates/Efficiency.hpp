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

#define EFF_ADD(a, b) ([a, b] call fn_eff_add)
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
