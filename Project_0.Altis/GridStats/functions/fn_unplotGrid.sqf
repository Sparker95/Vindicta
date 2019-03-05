//Delete previously drawn grid
_allMarkers = allMapMarkers;
{
	if (toLower _x find "ws_mrk" >= 0) then
	{
		deleteMarkerLocal _x;
	};
} forEach _allMarkers;
//ws_markers = missionNamespace getVariable ["ws_markers",[]];
//{{deleteMarkerLocal _x;}forEach _x;} forEach ws_markers;