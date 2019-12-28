clusters = [];
n = 20;
for "_i" from 0 to n do
{
	private _xpos = random 10;
	private _ypos = random 10;
	private _nc = [_xpos, _ypos, _xpos, _ypos, _i] call cluster_fnc_newCluster;
	clusters pushBack _nc;
};
