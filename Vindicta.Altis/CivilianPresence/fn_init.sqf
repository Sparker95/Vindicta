#include "common.hpp"
//Gets called at mission start
//initilises every thing to emulate the bis_civilianPresence modules

//Created by: Jeroen Notenbomer

params ["_pos","_border", ["_unitCount", 20]];

//_pos set [2,0];


//check if it is a circle
// private _isCircle = !_isRectangle;

private _unitTypes = missionNameSpace getVariable "CivPresence_unitTypes";

//we only need to do this ones
if(isnil "_unitTypes")then{
	//register module specific functions
	[
		"\A3\Modules_F_Tacops\Ambient\CivilianPresence\Functions\",
		"bis_fnc_cp_",
		[
			"debug",
			"getQueueDelay",
			"main",
			"addThreat",
			"getSafespot"
		]
	]
	call bis_fnc_loadFunctions;

	private _worldName = worldName;
	if !(_worldName in ["Stratis","Altis","Malden","Tanoa"]) then {_worldName = "Other"};
	_unitTypes = getArray (configfile >> "CfgVehicles" >> "ModuleCivilianPresence_F" >> "UnitTypes" >> _worldName);

	missionNameSpace setVariable ["CivPresence_unitTypes",_unitTypes];
};

_border params ["_pos0", "_a", "_b", "_rotation", "_isRectangle"]; // Format is same as here https://community.bistudio.com/wiki/inArea 

//BIS_fnc_moduleCivilianPresence code needs to have a module so we create one
private _module = [true] call CBA_fnc_createNamespace; // needs to be a object
_module setpos _pos;
_module setVariable ["#unitTypes",_unitTypes];
_module setVariable ["#usePanicMode",true];
_module setVariable ["#unitCount",_unitCount];
_module setVariable ["#useAgents",true];

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

_module setVariable ["#modulesSafeSpots",_waypoints];
_module setVariable ["#modulesUnit",_spawnPoints];

if(count _waypoints == 0||count _spawnPoints ==0)then{
	diag_log format ["ERROR [CivPresence_fnc_init] module doesnt have spawn or waypoints pos:%1",_pos];
	_module call CBA_fnc_deleteNamespace;
	_module = objNull;
};

_module;