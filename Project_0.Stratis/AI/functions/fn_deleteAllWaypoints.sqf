/*
This function deletes all waypoints of groups.
*/

private _hGs = _this; //Array with handles of groups
if(_hGs isEqualType grpNull) then
{
	_hGs = [_hGs];
};
{
	//Delete previous waypoints
	while {(count (waypoints _x)) > 0} do
	{
		deleteWaypoint [_x, ((waypoints _x) select 0) select 1];
	};
} forEach _hGs;
