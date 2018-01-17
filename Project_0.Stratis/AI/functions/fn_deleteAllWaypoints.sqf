/*
This function deletes all waypoints of groups.
*/

params ["_hGs"]; //Handles of groups

{
	//Delete previous waypoints
	while {(count (waypoints _x)) > 0} do
	{
		deleteWaypoint [_x, ((waypoints _x) select 0) select 1];
	};
} forEach _hGs;
