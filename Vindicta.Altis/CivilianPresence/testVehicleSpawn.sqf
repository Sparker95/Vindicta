//spawn vehicles at gates

//Testing
{deleteVehicle _x;}forEach vehicles;

//find all gates, Land_City_Gate_F are the ones with sheetmetal in the bottom part
private _gates = player nearObjects ["Land_Stone_Gate_F",2000];//2ms
_gates append (player nearObjects ["Land_City_Gate_F",2000]);//2ms
{
	private _gate = _x;

	//maybe we can spawn then inside the gate 
	//opening gates takes some time
	//([_gate, 1, 1] call BIS_fnc_Door);
	//([_gate, 2, 1] call BIS_fnc_Door);

	private _pos1 = _gate modelToWorld [0,5,0];		_pos1 deleteat 2; //0.0014ms
	private _pos2 = _gate modelToWorld [0,-5,0];	_pos2 deleteat 2;

	private _isRoad1 = isOnRoad _pos1; //0.0007ms
	private _isRoad2 = isOnRoad _pos2;

	if(_isRoad1 || _isRoad2)then{
		private _pos = if(_isRoad1)then{
			_pos2;
		}else{
			_pos1;
		};
		_pos pushBack 1;
		private _dir = direction _gate + selectRandom[0,180] + random 30 - 15;
		private _car = "C_Offroad_01_F" createVehicle [0,0,0];//6ms

		_car setdir _dir;
		_car setpos _pos;

	};
}forEach _gates;


////////////////////////////

// spawn cars in garages

//{deleteVehicle _x;}forEach vehicles;

private _garages = player nearObjects ["Land_i_Garage_V1_dam_F",2000];
_garages append (player nearObjects ["Land_i_Garage_V2_F",2000]);

{
	_garage = _x;
	private _dir = direction _garage;
	private _pos = _garage modelToWorld [(random -3)+1,random -1.5,0];

	private _car = "C_Offroad_01_F" createVehicle [0,0,0];
	_car setdir _dir + selectRandom[90,-90] + (random 10 - 5);
	_car setpos _pos;

}forEach _garages;



///////////////////////////////


//add some cars to repair shops at gas stations
{deleteVehicle _x;}forEach vehicles;
private _fuelGarages = player nearObjects ["Land_CarService_F",2000];
{
	_garage = _x;
	private _dir = direction _garage;
	private _pos = _garage modelToWorld [-2.7,3.5,0]; _pos set [2,0.5];

	private _car = "C_Offroad_01_F" createVehicle [0,0,0];
	_car setdir _dir + selectRandom[0,180];
	_car setpos _pos;

}forEach _fuelGarages







private _car = "C_Offroad_01_F" createVehicle getpos cursorObject;

_car addEventHandler ["Dammaged", {
	params ["_unit", "_selection", "_damage", "_hitIndex", "_hitPoint", "_shooter", "_projectile"];
	deleteVehicle _unit;
}];


sphere = "Sign_Sphere10cm_F" createVehicle [0,0,0];
onEachFrame {
	_begPos = positionCameraToWorld [0,0,0];
	_begPosASL = AGLToASL _begPos;
	_endPos = positionCameraToWorld [0,0,1000];
	_endPosASL = AGLToASL _endPos;
	_ins = lineIntersectsSurfaces [_begPosASL, _endPosASL, player, objNull, true, 1, "FIRE", "NONE"];
	if (_ins isEqualTo []) exitWith {sphere setPosASL [0,0,0]};
	_ins select 0 params ["_pos", "_norm", "_obj", "_parent"];
	if !(getModelInfo _parent select 2) exitWith {sphere setPosASL [0,0,0]};
	_ins2 = [_parent, "FIRE"] intersect [_begPos, _endPos];
	if (_ins2 isEqualTo []) exitWith {sphere setPosASL [0,0,0]};
	_ins2 select 0 params ["_name", "_dist"];
	_posASL = _begPosASL vectorAdd ((_begPosASL vectorFromTo _endPosASL) vectorMultiply _dist);
	sphere setPosASL _posASL;
};


private _car = "C_Offroad_01_F" createVehicle [0,0,0];

_car_bb = boundingBoxReal _car;


_house = cursorObject;
_house_bb = boundingBoxReal _house;
_house_dir = direction _house;

_pos= _house modelToWorld [_house_bb#1#0 + _car_bb#1#0 ,0];

_car setdir _house_dir;
_car setpos _pos;






