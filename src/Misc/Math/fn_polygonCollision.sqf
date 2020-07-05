// See https://gist.github.com/nyorain/dc5af42c6e83f7ac6d831a2cfd5fbece
private _fn_separatedPolys = {
	params ["_a", "_b"];
	private _result = false;
	for "_i" from 0 to (count _a - 1) do
	{
		// calculate the normal vector of the current edge
		// this is the axis will we check in this loop
		private _current = _a select _i;
		private _next = _a select ((_i + 1) % count _a);
		private _edge = [_next#0 - _current#0, _next#1 - _current#1];
		private _axis = [-(_edge#1), _edge#0];

		// loop over all vertices of both polygons and project them
		// onto the axis. We are only interested in max/min projections
		private _aMaxProj = -1000000;
		private _aMinProj = 1000000;
		private _bMaxProj = -1000000;
		private _bMinProj = 1000000;

		{
			private _proj = _axis#0 * _x#0 + _axis#1 * _x#1;
			_aMinProj = _aMinProj min _proj;
			_aMaxProj = _aMaxProj max _proj;
		} forEach _a;

		{
			private _proj = _axis#0 * _x#0 + _axis#1 * _x#1;
			_bMinProj = _bMinProj min _proj;
			_bMaxProj = _bMaxProj max _proj;
		} forEach _b;

		// now check if the intervals the both polygons projected on the
		// axis overlap. If they don't, we have found an axis of separation and
		// the given polygons cannot overlap
		if(_aMaxProj < _bMinProj or _aMinProj > _bMaxProj) exitWith {
			_result = true;
		};
	};
	_result
};

params ["_a", "_b"];

!(([_a, _b] call _fn_separatedPolys) or {([_b, _a] call _fn_separatedPolys)})