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
// fn_eff_attack = {
//     params ['_a', '_b'];
//     private _res = [];
//     {
//         _res pushBack ((_b select _forEachIndex) - _x );
//     } foreach (_a select [4, 4]);
//     _res + [0,0,0,0]
// };

fn_eff_attack = {
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
    } foreach (_attackers select [4, 4]);

    // Avoid that divide by 0
    if(_before == 0) exitWith { EFF_nul };

    // Simulate losses to attack values
    private _lossFactor = _after / _before;
    _res + ((_defenders select [4,4]) apply { floor (_x * _lossFactor) })
};

