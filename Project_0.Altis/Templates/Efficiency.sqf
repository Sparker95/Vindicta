#define _DEF_EFF_BINARY_OP_EFF_EFF(fn) { \
    params ['_a', '_b']; \
    private _res = []; \
    { \
        _res pushBack (_x fn (_b select _forEachIndex)); \
    } foreach _a; \
    _res \
}
    // [(_a select 0) fn (_b select 0), (_a select 1) fn (_b select 1), (_a select 2) fn (_b select 2), \
    // (_a select 3) fn (_b select 3), (_a select 4) fn (_b select 4), (_a select 5) fn (_b select 5), \
    // (_a select 6) fn (_b select 6), (_a select 7) fn (_b select 7), (_a select 8) fn (_b select 8)] \

#define _DEF_EFF_BINARY_OP_EFF_SCALAR(fn) { \
    params ['_a', '_b']; \
    _a apply { _x fn _b } \
}
#define _DEF_EFF_UNARY_OP_EFF(fn) { \
    _this apply { fn _x } \
}

fn_eff_add_scalar = _DEF_EFF_BINARY_OP_EFF_SCALAR(+);
fn_eff_add = _DEF_EFF_BINARY_OP_EFF_EFF(+);
fn_eff_diff_scalar = _DEF_EFF_BINARY_OP_EFF_SCALAR(-);
fn_eff_diff = _DEF_EFF_BINARY_OP_EFF_EFF(-);
fn_eff_mul_scalar = _DEF_EFF_BINARY_OP_EFF_SCALAR(*);
fn_eff_mul = _DEF_EFF_BINARY_OP_EFF_EFF(*);
fn_eff_sum = {
    (_this#0 + _this#1 + _this#2 + _this#3 + _this#4 + _this#5 + _this#6 + _this#7)
};
fn_eff_min_scalar = _DEF_EFF_BINARY_OP_EFF_SCALAR(min);
fn_eff_min = _DEF_EFF_BINARY_OP_EFF_EFF(min);
fn_eff_max_scalar = _DEF_EFF_BINARY_OP_EFF_SCALAR(max);
fn_eff_max = _DEF_EFF_BINARY_OP_EFF_EFF(max);
fn_eff_floor = _DEF_EFF_UNARY_OP_EFF(floor);
fn_eff_ceil = _DEF_EFF_UNARY_OP_EFF(ceil);
