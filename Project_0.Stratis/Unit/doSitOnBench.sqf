/*
Makes this unit sit on bench
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Unit\Unit.hpp"

params [["_thisObject", "", [""]], ["_bench", "", [""]], ["_pointID", 0, [0]] ];

// Get information about this point
private _args = [_thisObject, _pointID];
private _pointData = CALLM(_bench, "getPointData", _args);
if (count _pointData > 0) then {
	// Get variables
	_pointData params ["_offset", "_animation", "_dir"];
	private _data = GETV(_thisObject, "data");
	private _unitObject = _data select UNIT_DATA_ID_OBJECT_HANDLE;
	private _benchObject = CALLM(_bench, "getObject", []);
	
	// Perform actions
	_unitObject disableCollisionWith _benchObject;
	_unitObject attachTo [_benchObject, _offset];
	detach _unitObject;
	_unitObject setDir _dir; 
	_unitObject switchMove _animation;
	_unitObject disableAI "MOVE";
	
	true // Sit successfull
} else {
	false // Failed to sit here
};

/*
private _unit = guy;   
private _bench = bench_0; 
private _newDir = ( (getDir _bench) + 180 );    
_unit switchMove "HubSittingChairB_move1";
private _offset = [0.7, 0.08, -0.5];  
_unit attachTo [_bench, _offset]; 
detach _unit;
_unit setDir _newDir; 
_unit disableAI "MOVE";  
  
[_unit, _newDir] spawn { 
	params ["_unit", "_newDir"];  
	waitUntil {(behaviour _unit) == "COMBAT" || (!alive _unit) };
	_unit enableAI "ALL"; 
	_unit setDir _newDir;  
	_unit switchMove "AcrgPknlMstpSnonWnonDnon_AmovPercMstpSrasWrflDnon_getOutLow"; // Jump back on your feet!
 };
*/