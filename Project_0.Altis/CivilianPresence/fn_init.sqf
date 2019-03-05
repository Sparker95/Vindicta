//#define DEBUG
#define INT_RESOLUTION 50

params ["_pos","_size","_rotation"];
_pos set [2,0];
private _unitTypes = missionNameSpace getVariable "CivPresence_unitTypes";

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


private _module = [true] call CBA_fnc_createNamespace;//needs to be a object
_module setpos _pos;
_module setVariable ["#unitTypes",_unitTypes];
_module setVariable ["#usePanicMode",true];
_module setVariable ["#unitCount",20];
_module setVariable ["#useAgents",true];

private _waypoints = [];
private _spawnPoints = [];


private _useBuilding = true;
for "_x" from (_pos#0-(_size#0)) to (_pos#0+(_size#0)) step INT_RESOLUTION do{
	for "_y" from (_pos#1-(_size#1)) to (_pos#1+(_size#1)) step INT_RESOLUTION do{
		private _pos = [_x,_y,0];

		if(_useBuilding)then{
			_useBuilding = false;
			
			_building = nearestBuilding _pos;
			private _positions = (_building buildingPos -1);
			if ((_building distance2D _pos < INT_RESOLUTION/2) && {count _positions > 0}) then
			{
				_positions = (_positions call BIS_fnc_arrayShuffle);
				private _waypoint = [true] call CBA_fnc_createNamespace;
				_waypoint setpos (_positions#0);
				_waypoint setVariable ["#type",1];//waypoint & cover
				_waypoint setVariable ["#positions",_positions];
				_waypoints pushback _waypoint;
				_spawnPoints pushback _waypoint;
				#ifdef DEBUG				
				{
					_markerName = createMarker [format["%1",random 99999], _x]; 
					_markerName setMarkerShape "ICON"; 
					_markerName setMarkerType "hd_dot"; 
					_markerName setMarkerColor "ColorRed";
				}forEach _positions;
				#endif
			};
		}else{
			_useBuilding = true;
			
			_road = selectRandom (_pos nearRoads INT_RESOLUTION/2);
			if(!isnil "_road")then{
				private _waypoint = [true] call CBA_fnc_createNamespace;
				_waypoint setpos getpos _road;
				_waypoint setVariable ["#type",2];//waypoint
				_waypoint setVariable ["#positions",[getpos _road]];
				_waypoints pushback _waypoint;
				
				#ifdef DEBUG	
				_markerName = createMarker [format["%1",random 99999], getpos _road]; 
				_markerName setMarkerShape "ICON"; 
				_markerName setMarkerType "hd_dot"; 
				_markerName setMarkerColor "ColorBlue";
				#endif
			};
		};
		
	};
};
_module setVariable ["#modulesSafeSpots",_waypoints];
_module setVariable ["#modulesUnit",_spawnPoints];
_module;