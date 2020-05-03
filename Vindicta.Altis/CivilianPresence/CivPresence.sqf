#include "common.h"

/*
Civilian presense module for a specific small area (hundreds of meters, but can be different)
Authors: Jeroen Notenbomer, Billw, Sparker
Some BI civilian presence code is used
*/

#define pr private

#define OOP_CLASS_NAME CivPresence
CLASS("CivPresence", "")

	// Area
	// [center, a, b, angle, isRectangle, c]
	VARIABLE("area");

	// Center position
	VARIABLE("pos");

	VARIABLE("debugMarker");

	METHOD(new)
		params [P_THISOBJECT, P_POSITION("_pos"), P_NUMBER("_halfWidthx"), P_NUMBER("_halfWidthy")];

		pr _area = [_pos, _halfWidthx, _halfWidthy, 0, false];
		T_SETV("area", _area);
		T_SETV("pos", _pos);

		#ifdef DEBUG_CIV_PRESENCE
		_pos params ["_x", "_y"];
		pr _mrkName = format ["%1_debug_%2_%3", _thisObject, floor _x, floor _y];
		pr _mrk = createMarkerLocal [_mrkName, _pos];
		_mrk setMarkerShapeLocal "RECTANGLE";
		_mrk setMarkerBrushLocal "SolidFull";
		_mrk setMarkerSizeLocal [_halfWidthx, _halfWidthy];
		_mrk setMarkerColorLocal "ColorBlue";
		_mrk setMarkerAlphaLocal 0.2;
		T_SETV("debugMarker", _mrk);
		#endif

	ENDMETHOD;

	METHOD(enable)
		params [P_THISOBJECT];

		OOP_INFO_0("enable");

		#ifdef DEBUG_CIV_PRESENCE
		pr _mrk = T_GETV("debugMarker");
		_mrk setMarkerAlphaLocal 0.6;
		#endif
	ENDMETHOD;

	METHOD(disable)
		params [P_THISOBJECT];

		OOP_INFO_0("disable");

		#ifdef DEBUG_CIV_PRESENCE
		pr _mrk = T_GETV("debugMarker");
		_mrk setMarkerAlphaLocal 0.2;
		#endif
	ENDMETHOD;

	METHOD(init)
		params [P_THISOBJECT];
/*
		//loop through the border
		private _waypoints = [];//road segments and spawnpoints
		private _spawnPoints = [];//locations in buildings

		// in meters, average distance between spawn/way points
		private _res = (_a max _b) / 4;

		private _maxSize = sqrt (_a^2 + _b^2);

		// Traverse a grid covering the entire area specified
		for "_xp" from -_maxSize to _maxSize step _res do{
			for "_yp" from -_maxSize to _maxSize step _res do{
				//calculate position reletive to whole map
				private _p = [_xp + _pos0#0, _yp + _pos0#1];

				//skipping the ones out side the area
				if(_p inArea _border) then {
					//paint markers for debugging
					#ifdef DEBUG_CIVILIAN_PRESENCE
					private _markerName = createMarker [format["%1",random 99999], _p];
					_markerName setMarkerShape "ICON";
					_markerName setMarkerType "hd_dot";
					_markerName setMarkerColor "ColorBlack";
					#endif

					private _building = nearestObject [_p, "House"]; // (nearestBuilding doesn't return objects placed in editor)
					private _positions = (_building buildingPos -1);
					if ((_building distance2D _p < _res/2) && {count _positions > 0}) then {
						_positions = (_positions call BIS_fnc_arrayShuffle);
						private _waypoint = [true] call CBA_fnc_createNamespace;
						_waypoint setpos (_positions#0);
						_waypoint setVariable ["#type",1];//waypoint & cover
						_waypoint setVariable ["#positions",_positions];
						_waypoints pushback _waypoint;
						_spawnPoints pushback _waypoint;
						#ifdef DEBUG_CIVILIAN_PRESENCE
						{
							private _markerName = createMarker [format["%1",random 99999], _x];
							_markerName setMarkerShape "ICON";
							_markerName setMarkerType "hd_dot";
							_markerName setMarkerColor "ColorRed";
						}forEach _positions;
						#endif
					};
					private _nearRoad = selectRandom ((_p nearRoads _res/2) apply { [_x, roadsConnectedTo _x] } select { count (_x#1) > 0 });
					if(!isnil "_nearRoad") then {
						_nearRoad params ["_road", "_rct"];
						private _dir = _road getDir _rct#0;
						// Check position if it's safe
						private _width = [_road, 1, 8] call misc_fnc_getRoadWidth;
						// Move to the edge
						private _pos = [getPos _road, _width - 4, _dir + (selectRandom [90, 270]) ] call BIS_Fnc_relPos;
						// Move up and down the street a bit
						_pos = [_pos, _width * 0.5, _dir + (selectRandom [0, 180]) ] call BIS_Fnc_relPos;

						private _waypoint = [true] call CBA_fnc_createNamespace;
						_waypoint setpos _pos;
						_waypoint setVariable ["#type",2];//waypoint
						_waypoint setVariable ["#positions",[_pos]];
						_waypoints pushback _waypoint;
						
						#ifdef DEBUG_CIVILIAN_PRESENCE	
						private _markerName = createMarker [format["%1",random 99999], _pos];
						_markerName setMarkerShape "ICON";
						_markerName setMarkerType "hd_dot";
						_markerName setMarkerColor "ColorBlue";
						#endif
					};
					//};//end if _useBuilding
				};
			};//for loop _y
		};
*/
	ENDMETHOD;

	METHOD(getNearestSafeSpot)
		params [P_THISOBJECT];

	ENDMETHOD;

	METHOD(getSafeSpot)
		params [P_THISOBJECT];
		/*

		private _core = _unit getVariable ["#core",objNull]; if (isNull _core) exitWith {objNull};
		private _safespots = _core getVariable ["#modulesSafeSpots",[]];
		private _units = _core getVariable ["#units",[]];


		_safespots = _safespots select {_x getVariable ["#type",-1] != [2,0] select _mode};

		_safespots = _safespots select
		{
			_safespot = _x;
			_capacity = _safespot getVariable ["#capacity",100];
			_inhabitantCount = {_x getVariable ["#safespot",objNull] == _safespot} count _units;



			_inhabitantCount < _capacity
		};

		if (count _safespots == 0) then {_safespots = _core getVariable ["#modulesSafeSpots",[objNull]]};
		switch (_mode) do
		{
			case 0:
			{
				([_safespots,[_unit],{_x distance _input0},"ASCEND"] call bis_fnc_sortBy) param [0,objNull]
			};
			case 1:
			{
				selectRandom _safespots
			};
			default
			{
				objNull
			};
		};}
		*/
	ENDMETHOD;

ENDCLASS;