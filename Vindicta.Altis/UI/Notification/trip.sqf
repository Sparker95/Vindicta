if (!isNil "tripLength") then {
	tripLength = (tripLength + 7) min 45;
};

if (!isNil "tripEH") exitWith {
	player groupChat "O_o";
};

tripStartTime = time;
tripControls = [];
tripControlsMax = 400;
tripLength = 20;
tripColors = [
	[240, 28, 28],
	[98, 237, 31],
	[30, 238, 92],
	[61, 239, 239],
	[235, 65, 231],
	[238, 62, 74]
];
tripUnc = false;
private _EH = addMissionEventHandler ["EachFrame", {
	private _progress = (time - tripStartTime) / tripLength;
	if (time - tripStartTime < tripLength) then {
		while {(count tripControls) < tripControlsMax} do {
			private _ctrl = (finddisplay 46) ctrlCreate ["RscText", -1];
			tripControls pushBack _ctrl;
			private _alpha = sin ( 180 * _progress);
			_ctrl ctrlSetBackgroundColor (((selectRandom tripColors) apply {_x/255}) + [_alpha]);
			_ctrl ctrlSetPosition [0.5, 0.5, random 0.3, random 0.3];
			_ctrl ctrlCommit 0;
			private _angle = random 360;
			_ctrl ctrlSetPosition [3*(cos _angle), 3*(sin _angle), 0.6 + random 1.2, 0.6 + random 1.2];
			private _speedFactor = sin ( 180 * _progress);
			_ctrl ctrlCommit ((0.5 + random (0.3*_speedFactor)) + random 0.3);
		};
		private _i = 0;
		while {_i < (count tripControls)} do {
			private _ctrl = tripControls#_i;
			if (ctrlCommitted _ctrl) then {
				tripControls deleteAt _i;
				ctrlDelete _ctrl;
			} else {
				_i = _i + 1;
			};
		};

		if (_progress > 0.3 && !tripUnc) then {
			//player setUnconscious true;
			tripUnc = true;
			player groupChat "What the fuck?!";
			[player, "dead"] remoteExec ["setMimic", 0];
		};
	} else {
		{
			ctrlDelete _x;
		} forEach tripControls;
		tripControls = [];
		//player setUnconscious false;
		[player, "neutral"] remoteExec ["setMimic", 0];
		player groupChat "Finally it's over!!";
		removeMissionEventHandler ["EachFrame", tripEH];
		tripEH = nil;
	};
}];
tripEH = _EH;