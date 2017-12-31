//todo add separate artillery radars for sides!

diag_log "======== HQ INIT STARTED!";
globalArtilleryRadar = [] call sense_fnc_createArtilleryRadar;
//diag_log "======== HQ INIT DONE!";
globalSoundMonitor = [] call sense_fnc_createSoundMonitor;
diag_log "======== HQ INIT DONE!";

fn_highScript =
{
	private _counter = 0;
	while {true} do
	{
		sleep 2;
		private _sounds = [globalSoundMonitor, true] call sense_fnc_processSoundMonitor;
		//Create markers
		{
			private _name = format["sound_%1", _counter];
			//deleteMarkerLocal _name;
			_counter = _counter + 1;
			private _mrk = createMarkerLocal [_name,
					[	_x select 0,
						_x select 1,
						0]];
			private _width = _x select 2;
			private _height = _x select 2;
			_mrk setMarkerShapeLocal "RECTANGLE";
			_mrk setMarkerBrushLocal "SolidFull";
			_mrk setMarkerSizeLocal [_width, _height];
			_mrk setMarkerColorLocal "ColorRed";
			_mrk setMarkerAlphaLocal 0.1;
		} forEach _sounds;
	};
};

_null = [] spawn fn_highScript;


diag_log "======== HQ INIT EXIT!";