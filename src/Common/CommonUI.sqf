vin_fnc_coneTarget = {
	params ["_range"];
	private _tgts = (nearestObjects [position player, ["Man"], _range]) apply { 
		[_x, vectorNormalized (position player vectorFromTo position _x) vectorCos getCameraViewDirection player]
	} select { 
		_x#1 > 0.9
	};
	if(count _tgts > 0) then {
		_tgts#0#0
	} else {
		objNull
	}
};
