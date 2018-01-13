/*
_params: [_loc, _isAnybodyWatching]
*/

params ["_scriptObject", "_params"];

private _hScript = [_scriptObject, _params] spawn
{
	params ["_scriptObject", "_params"];
	private _gars = _scriptObject getVariable ["AI_garrisons", objNull];

	private _loc = _params select 0;
	private _isAnybodyWatching = _params select 1;

	private _hGsRegroup = [];
	private _hGsGetIn = [];
	private _hGsSentry = [];

	for "_i" from 0 to ((count _gars) - 1) do
	{
		private _gar = _gars select _i;
		//Groups that need to regroup
		_hGsRegroup append ([_gar, G_GT_idle] call gar_fnc_findGroupHandles);
		_hGsRegroup append ([_gar, G_GT_patrol] call gar_fnc_findGroupHandles);

		//Groups that need to board their vehicles
		_hGsGetIn append ([_gar, G_GT_veh_static] call gar_fnc_findGroupHandles);
		_hGsGetIn append ([_gar, G_GT_veh_non_static] call gar_fnc_findGroupHandles);

		//Sentries
		_hGsSentry append ([_gar, G_GT_building_sentry] call gar_fnc_findGroupHandles);
	};
	
	//Set behaviours
	{_x setBehaviour "COMBAT";} forEach _hGsRegroup;
	{_x setBehaviour "COMBAT";} forEach _hGsGetIn;
	{_x setBehaviour "COMBAT";} forEach _hGsSentry;

	//Do stuff
	private _radius = 0.6 * ([_loc] call loc_fnc_getBoundingRadius);
	private _locPos = getPos _loc;
	//Patrol and idle groups should regroup inside the location
	{
		(units _x) commandFollow (leader _x); //Regroup
		//Delete previous waypoints
		while {(count (waypoints _x)) > 0} do
		{
			deleteWaypoint [_x, ((waypoints _x) select 0) select 1];
		};
		/*
		//Add waypoint to the center of the location
		_wp = _x addWaypoint [_locPos, _radius];
		_wp setWaypointType "MOVE";
		_wp setWaypointSpeed "FULL";
		_wp setWaypointFormation "WEDGE";
		*/
	} forEach _hGsRegroup;

	//Vehicle groups should board their vehicles and kick ass!
	{
		(units _x) orderGetIn true; //All, board that vehicle!
	} forEach _hGsGetIn;
};

_hScript