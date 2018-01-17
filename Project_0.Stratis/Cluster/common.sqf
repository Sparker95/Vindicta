/*
A cluster array structure is:
[x1, y1, x2, y2, objectIDs]

x1, y1, x2, y2 - edge coordinates:
x2 > x1
y2 > y1
	*------(x2, y2)
	|		  |	
	|		  |
(x1, y1)------*

objectIDs - array with IDs of objects (integers)
*/

cluster_fnc_newCluster =
{
	/*
	Creates a new cluster array.
	
	Returns: a new cluster array.
	*/
	params ["_x1", "_y1", "_x2", "_y2", "_objectID"];
	_array = [_x1, _y1, _x2, _y2, [_objectID]];
	_array
};

cluster_fnc_addObjectID =
{
	/*
	Adds a new object ID to the cluster.
	
	Returns: nothing.
	*/
	params ["_c", "_newID"];
	_oids = _c select 4;
	_oids pushback _newID;
};

cluster_fnc_distance =
{
	/*
	Measures distance between two clusters.
	
	Returns: distance(number)
	*/
	params ["_c1", "_c2"];
	
	_c1x1 = _c1 select 0;
    _c1y1 = _c1 select 1;
    _c1x2 = _c1 select 2;
    _c1y2 = _c1 select 3;
    _c2x1 = _c2 select 0;
    _c2y1 = _c2 select 1;
    _c2x2 = _c2 select 2;
    _c2y2 = _c2 select 3;
    
    _dx = 0;
    if( ! (	_c2x1 < _c1x2 && _c2x1 > _c1x1 ||
			_c2x2 < _c1x2 && _c2x2 > _c1x1 ||
			_c1x1 > _c2x1 && _c1x1 < _c2x2 ||
			_c1x2 > _c2x1 && _c1x2 < _c2x2)) then
	{
		if (_c2x1 > _c1x2) then {
			_dx = _c2x1 - _c1x2; }
		else
		{	_dx = _c1x1 - _c2x2; };
	};
    
    _dy = 0;
    if( ! (	_c2y1 < _c1y2 && _c2y1 > _c1y1 ||
			_c2y2 < _c1y2 && _c2y2 > _c1y1 ||
			_c1y1 > _c2y1 && _c1y1 < _c2y2 ||
			_c1y2 > _c2y1 && _c1y2 < _c2y2)) then
	{
		if (_c2y1 > _c1y2) then {
			_dy = _c2y1 - _c1y2; }
		else
		{	_dy = _c1y1 - _c2y2; };
	};
    
    _dx max _dy
};

cluster_fnc_merge =
{
	/*
	This function merges two clusters into one cluster.
	The resulting cluster is stored in the first cluster array.
	
	Returns: nothing.
	*/
	params ["_c1", "_c2"];
	
	_c1x1 = _c1 select 0;
    _c1y1 = _c1 select 1;
    _c1x2 = _c1 select 2;
    _c1y2 = _c1 select 3;
    _c2x1 = _c2 select 0;
    _c2y1 = _c2 select 1;
    _c2x2 = _c2 select 2;
    _c2y2 = _c2 select 3;
    
    _allx = [_c1x1, _c1x2, _c2x1, _c2x2];
    _ally = [_c1y1, _c1y2, _c2y1, _c2y2];
    _newx1 = selectMin _allx;
    _newy1 = selectMin _ally;
    _newx2 = selectMax _allx;
    _newy2 = selectMax _ally;
    
    _c1 set [0, _newx1];
	_c1 set [1, _newy1];
	_c1 set [2, _newx2];
	_c1 set [3, _newy2];
	_array = _c1 select 4;
	_array append (_c2 select 4);
};

cluster_fnc_getCenter =
{
	/*
	Get the center of the cluster
	*/
	params ["_c"];
	private _cx = 0.5*((_c select 0) + (_c select 2));
	private _cy = 0.5*((_c select 1) + (_c select 3));
	[_cx, _cy]
};
