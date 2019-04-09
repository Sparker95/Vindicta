
#define _EFF_BINARY_OP_VEC_VEC(a, fn, b) \
    (((a select [0, 3]) fn (b select [0, 3])) + \
    ((a select [3, 3]) fn (b select [3, 3])) + \
    ((a select [6, 3]) fn (b select [6, 3])))

#define _EFF_BINARY_OP_VEC_SCALAR(a, fn, b) \
    (((a select [0, 3]) fn (b)) + \
    ((a select [3, 3]) fn (b)) + \
    ((a select [6, 3]) fn (b)))

#define _EFF_BINARY_OP_EFF_EFF(a, fn, b) \
    [a#0 fn b#0, a#1 fn b#1, a#2 fn b#2, \
    a#3 fn b#3, a#4 fn b#4, a#5 fn b#5, \
    a#6 fn b#6, a#7 fn b#7, a#8 fn b#8]

#define _EFF_BINARY_OP_EFF_SCALAR(a, fn, b) \
    [a#0 fn (b), a#1 fn (b), a#2 fn (b), \
    a#3 fn (b), a#4 fn (b), a#5 fn (b), \
    a#6 fn (b), a#7 fn (b), a#8 fn (b)]

#define _EFF_UNARY_OP_EFF(a, fn, b) \
    [fn a#0, fn a#1, fn a#2, \
    fn a#3, fn a#4, fn a#5, \
    fn a#6, fn a#7, fn a#8]

fn_eff_add = {
    params ['_a', '_b'];
    _EFF_BINARY_OP_VEC_VEC(_a, vectorAdd, _b)
};

fn_eff_sub = {
    params ['_a', '_b'];
    _EFF_BINARY_OP_VEC_VEC(_a, vectorDiff, _b)
};

fn_eff_sum = {
    (_this#0 + _this#1 + _this#2 + _this#3 + _this#4 + _this#5 + _this#6 + _this#7 + _this#8)
};

fn_eff_mul = {
    params ['_a', '_b'];
    _EFF_BINARY_OP_EFF_EFF(_a, *, _b)
};

// Adds/substracts two vectors of length 9
#define EFF_ADD(a, b) ([a, b] call fn_eff_add)
#define EFF_SUB(a, b) ([a, b] call fn_eff_sub)
#define EFF_SUM(a) (a call fn_eff_sum)

#define EFF_MUL(a, b) _EFF_BINARY_OP_EFF_EFF(a, *, b)
#define EFF_MUL_SCALAR(a, b) _EFF_BINARY_OP_VEC_SCALAR(a, vectorMultiply, b)
#define EFF_MIN_SCALAR(e, min_val) _EFF_BINARY_OP_EFF_SCALAR(e, min min_val)
#define EFF_MAX_SCALAR(e, max_val) _EFF_BINARY_OP_EFF_SCALAR(e, min max_val)
#define EFF_CLAMP_SCALAR(e, min_val, max_val) EFF_MAX_SCALAR(EFF_MIN_SCALAR(e, min_val), max_val)

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