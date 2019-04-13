#define _DEF_EFF_BINARY_OP_EFF_EFF(fn) { \
    params ['_a', '_b']; \
    private _res = []; \
    { \
        _res pushBack (_x fn (_b select _forEachIndex)); \
    } foreach _a; \
    _res \
}
#define _DEF_EFF_BINARY_OP_EFF_SCALAR(fn) { \
    params ['_a', '_b']; \
    _a apply { _x fn _b } \
}
#define _DEF_EFF_UNARY_OP_EFF(fn) { \
    _this apply { fn _x } \
}
#define _DEF_SUB_BINARY_OP_SUB_SUB(fn) { \
    params ['_a', '_b']; \
    [(_a select 0) fn (_b select 0), (_a select 1) fn (_b select 1), (_a select 2) fn (_b select 2), (_a select 3) fn (_b select 3)] \
}
#define _DEF_SUB_BINARY_OP_SUB_SCALAR(fn) { \
    params ['_a', '_b']; \
    [(_a select 0) fn _b, (_a select 1) fn _b, (_a select 2) fn _b, (_a select 3) fn _b] \
}
#define _DEF_SUB_UNARY_OP_SUB(fn) { \
    [fn (_this select 0), fn (_this select 1), fn (_this select 2), fn (_this select 3)] \
}

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

