/*
Plot the ws_grid on the map

Parameters:
_gridArray
_proportion - which value will result in alpha equal ot 1.0
_plotZero - plot squares if value is zero

Author: Sparker
*/
params ["_gridArray", ["_proportion", 1], ["_plotZero", false]];

call ws_fnc_unplotGrid;

//ws_grid = [missionNamespace, "ws_grid", Nil] call BIS_fnc_getServerVariable;

if(!isNil "_gridArray") then
{
	private _halfSize = 0.5*ws_squareSize;

	for [{private _i = 0}, {_i < ws_gridSizeX}, {_i = _i + 1}] do //_i is x-pos
	{
		//_markerColumn = [];
		for [{private _j = 0}, {_j < ws_gridSizeY}, {_j = _j + 1}] do //_j is y-pos
		{
		    _activity = [_gridArray, _i, _j] call ws_fnc_getValueID;

			if(_activity == 0) then
			{
				if(_plotZero) then
				{
					private _wsmName = format ["ws_mrk_%1_%2", _i, _j];
					private _wsm = createMarkerLocal [_wsmName, [ws_squareSize*_i + _halfSize + ws_gridStartX, ws_squareSize*_j + _halfSize + ws_gridStartY, 0]];
					//_markerColumn pushBack _wsm;
					_wsm setMarkerShapeLocal "RECTANGLE";
					_wsm setMarkerBrushLocal "SolidFull";
					_wsm setMarkerSizeLocal [_halfSize, _halfSize];
					_wsm setMarkerColorLocal "ColorGreen";
					_wsm setMarkerAlphaLocal 0.1;
				};
			}
			else
			{
				private _wsmName = format ["ws_mrk_%1_%2", _i, _j];
				private _wsm = createMarkerLocal [_wsmName, [ws_squareSize*_i + _halfSize + ws_gridStartX, ws_squareSize*_j + _halfSize + ws_gridStartY, 0]];
				//_markerColumn pushBack _wsm;
				_wsm setMarkerShapeLocal "RECTANGLE";
				_wsm setMarkerBrushLocal "SolidFull";
				_wsm setMarkerSizeLocal [_halfSize, _halfSize];
				if(_activity > 0) then
				{
					_wsm setMarkerColorLocal "ColorRed";
					_alpha = _activity * 0.98 / _proportion;
					if(_alpha > 0.98) then {_alpha = 0.98;};
					_alpha = _alpha + 0.02;
					_wsm setMarkerAlphaLocal _alpha;
				}
				else
				{
					_wsm setMarkerColorLocal "ColorBlue";
					_activity = -_activity;
					_alpha = _activity * 0.98 / _proportion;
					if(_alpha > 0.98) then {_alpha = 0.98;};
					_alpha = _alpha + 0.02;
					_wsm setMarkerAlphaLocal _alpha;
				};
			};
		};
	};
};