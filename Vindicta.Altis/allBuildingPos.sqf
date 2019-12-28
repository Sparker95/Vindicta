// _o = cursorObject;
// _posArray = _o buildingPos -1;
// {
// _no = "Sign_Arrow_Large_Blue_F" createVehicle _x;
// _no setPosATL _x;
// _no setVariable ["buildingPosID", _forEachIndex];
// } forEach _posArray;
// _exitArray = [];
// _i = 0;
// _exitPos = _o buildingExit _i;
// while {!(_exitPos isEqualTo [0, 0, 0])} do
// {
// _exitArray pushBack _exitPos;
// _i = _i + 1;
// _exitPos = _o buildingExit _i;
// };
// {
// _no = "Sign_Arrow_Large_F" createVehicle _x;
// _no setPosATL _x;
// } forEach _exitArray;

//Good positions on different buildings:
/*
BuildingPos number, direction

Big watchtower: "Land_Cargo_Tower_V2_F"
High HMGs, high GMGs:
	[11, 90], [13, 0], [14, 0], [16, 180], [17, 180]
Snipers, spotters: inside building
	[2, 0], [4, 180], [7, 90], [8, 270]
Snipers, spotters: at the roof
	[10, 180], [12, 0], [15, 270],

Small watchtower: "Land_Cargo_Patrol_V2_F"
High HMGs, high GMGs:
	[2.1, 220, 4.4, 180], [2.1, 130, 4.4, 180],  //[offset, offset direction, height offset, direction]

_newdir = direction b + 180;
(vehicle player) setDir _newDir;
vehicle player setPos ((b getPos [1.5, (direction b) + 240]) vectorAdd [0, 0, 4.4]);

HQ: "Land_Cargo_HQ_V2_F"
High HMGs, high GMGs:
	[4, 90], [5, 0], [6, -45], [7, 225], [8, 180]

*/
