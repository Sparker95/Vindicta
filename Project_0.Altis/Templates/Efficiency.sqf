#define _DEF_EFF_BINARY_OP_VEC_VEC(fn) { \
    params ['_a', '_b']; \
    (((_a select [0, 3]) fn (_b select [0, 3])) + \
    ((_a select [3, 3]) fn (_b select [3, 3])) + \
    ((_a select [6, 3]) fn (_b select [6, 3]))) \
}
#define _DEF_EFF_BINARY_OP_VEC_SCALAR(fn) { \
    params ['_a', '_b']; \
    (((_a select [0, 3]) fn (_b)) + \
    ((_a select [3, 3]) fn (_b)) + \
    ((_a select [6, 3]) fn (_b))) \
}
#define _DEF_EFF_BINARY_OP_EFF_EFF(fn) { \
    params ['_a', '_b']; \
    [(_a select 0) fn (_b select 0), (_a select 1) fn (_b select 1), (_a select 2) fn (_b select 2), \
    (_a select 3) fn (_b select 3), (_a select 4) fn (_b select 4), (_a select 5) fn (_b select 5), \
    (_a select 6) fn (_b select 6), (_a select 7) fn (_b select 7), (_a select 8) fn (_b select 8)] \
}
#define _DEF_EFF_BINARY_OP_EFF_SCALAR(fn) { \
    params ['_a', '_b']; \
    [(_a select 0) fn (_b), (_a select 1) fn (_b), (_a select 2) fn (_b), \
    (_a select 3) fn (_b), (_a select 4) fn (_b), (_a select 5) fn (_b), \
    (_a select 6) fn (_b), (_a select 7) fn (_b), (_a select 8) fn (_b)] \
}
#define _DEF_EFF_UNARY_OP_EFF(fn) { \
    params ['_a']; \
    [fn (_a select 0), fn (_a select 1), fn (_a select 2), \
    fn (_a select 3), fn (_a select 4), fn (_a select 5), \
    fn (_a select 6), fn (_a select 7), fn (_a select 8)] \
}

fn_eff__add = _DEF_EFF_BINARY_OP_VEC_VEC(vectorAdd);
fn_eff_diff = _DEF_EFF_BINARY_OP_VEC_VEC(vectorDiff);
fn_eff_mul_scalar = _DEF_EFF_BINARY_OP_VEC_SCALAR(vectorMultiply);
fn_eff_mul = _DEF_EFF_BINARY_OP_EFF_EFF(*);
fn_eff_sum = {
    (_this#0 + _this#1 + _this#2 + _this#3 + _this#4 + _this#5 + _this#6 + _this#7 + _this#8)
};
fn_eff_min_scalar = _DEF_EFF_BINARY_OP_EFF_SCALAR(min);
fn_eff_max_scalar = _DEF_EFF_BINARY_OP_EFF_SCALAR(max);
fn_eff_floor = _DEF_EFF_UNARY_OP_EFF(floor);
fn_eff_ceil = _DEF_EFF_UNARY_OP_EFF(ceil);
