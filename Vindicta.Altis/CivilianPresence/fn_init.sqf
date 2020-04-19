//Gets called at mission start
//initilises every thing to emulate the bis_civilianPresence modules

//Created by: Jeroen Notenbomer

#ifndef RELEASE_BUILD
//#define DEBUG_CIVILIAN_PRESENCE
#endif

#define INT_RESOLUTION 45	//in meters, average distance between spawn/way points

params ["_pos","_border", ["_unitCount", 20]];

//_pos set [2,0];

_border params ["_pos0", "_a", "_b", "_rotation", "_isRectangle"]; // Format is same as here https://community.bistudio.com/wiki/inArea 

//check if it is a circle
private _isCircle = !_isRectangle;

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

//BIS_fnc_moduleCivilianPresence code needs to have a module so we create one
private _module = [true] call CBA_fnc_createNamespace;//needs to be a object
_module setpos _pos;
_module setVariable ["#unitTypes",_unitTypes];
_module setVariable ["#usePanicMode",true];
_module setVariable ["#unitCount",_unitCount];
_module setVariable ["#useAgents",true];


/*create a structior as follows:
	X	0	X	0	X
	0	X	0	X	0	
	X	0	X	0	X
	0	X	0	X	0	
	X	0	X	0	X
	0	X	0	X	0	

	0 = search for road and create waypoint
	x = create spawn point in building if there are not this position will be skipped, are also used as waypont
*/
//loop through the border
private _useBuilding_start = true;
private _waypoints = [];//road segments and spawnpoints
private _spawnPoints = [];//locations in buildings

for "_x_border" from -_a + INT_RESOLUTION/2   to _a - INT_RESOLUTION/2 step INT_RESOLUTION do{

	private _useBuilding = _useBuilding_start;
	if _useBuilding_start then{_useBuilding_start = false;}else{_useBuilding_start=true};

	for "_y_border" from -_b + INT_RESOLUTION/2 to _b - INT_RESOLUTION/2 step INT_RESOLUTION do{

		if(_useBuilding)then{_useBuilding = false;}else{_useBuilding = true;};
		private _x = _x_border;
		private _y = _y_border;

		

		//in case its a circle we need to skip the points that fall outside the circle
		#ifdef DEBUG_CIVILIAN_PRESENCE	
		diag_log ["JEROENTEST1", _isCircle, sqrt(abs _x ^2 + abs _y ^ 2), _a];
		#endif

		if(!_isCircle)then{
			/*doing some rotation matrix calculations
				x2 = cosθ*x1 - sinθ*y1
				y2 = sinθ*x1 + cos0*y1
			*/
			_x = cos -_rotation * _x_border - sin -_rotation * _y_border;
			_y = sin -_rotation * _x_border + cos -_rotation * _y_border;
		};
		
		//calculate position reletive to whole map
		private _p = [_x + _pos#0, _y + _pos#1];
		

		//skipping the ones out side the circle
		if (!_isCircle || _isCircle && {sqrt(abs _x ^ 2 + abs _y ^ 2) <= _a - INT_RESOLUTION/2}) then{

			//paint markers for debugging
			#ifdef DEBUG_CIVILIAN_PRESENCE				
			private _markerName = createMarker [format["%1",random 99999], _p];
			_markerName setMarkerShape "ICON";
			_markerName setMarkerType "hd_dot";
			_markerName setMarkerColor "ColorBlack";
			#endif

			//switch between creating spawn and waypoints
			if(_useBuilding)then{
				
				_building = nearestBuilding _p;
				private _positions = (_building buildingPos -1);
				if ((_building distance2D _p < INT_RESOLUTION/2) && {count _positions > 0}) then{
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
			}else{
				
				_road = selectRandom (_p nearRoads INT_RESOLUTION/2);
				if(!isnil "_road")then{
					private _rct = roadsConnectedTo _road;
					if(count _rct > 0) then {
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
				};
			};//end if _useBuilding
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