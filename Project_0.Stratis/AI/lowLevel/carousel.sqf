params ["_carousel", "_objs"];
_carousel setDir 0;
{
	_a = -70*_foreachindex;
	private _cos = cos _a;
	private _sin = sin _a;
	private _r = 0.9;
	_x attachto [_carousel, [_sin*_r, -_cos*_r, 0.4]];
	_x setDir -_a;
	_x switchmove "passenger_bench_1_Idle";
	_x disableAI "move";
}foreach _objs;

diag_log format ["carousel object: %1", _carousel];

[_carousel] spawn{
	_r = 0;
	_a = 1;
	private _c = _this select 0;
	diag_log format ["carousel object: %1", _c];
	while {_a < 20} do
	{
		_c setDir _r;
		_r = _r + _a;
		_a = _a + 0.3;
		sleep 0.05;
	};
	while {_a > 0} do
	{
		_c setDir _r;
		_r = _r + _a;
		_a = _a - 0.12;
		sleep 0.02;
	};
};
