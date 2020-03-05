
params [["_range",0,[0]]];

private _tgts = (nearestObjects [position player, ["Man"], _range]) apply { 
	[_x, vectorNormalized (position player vectorFromTo position _x) vectorCos getCameraViewDirection player]
} select { 
	_x#1 > 0.9
};



