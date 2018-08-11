/*
A bench where a unit can sit at
*/

#include "..\OOP_Light\OOP_Light.h"

CLASS("AnimObjectBench", "AnimObject")
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]]];
		
		private _args = [[0.7, 0.08, -0.5], [-0.7, 0.08, -0.5]];
		SETV(_thisObject, "points", _args);
		
		private _args = ["", ""];
		SETV(_thisObject, "units", _args);
		
		SETV(_thisObject, "pointCount", 2);
		
		private _args = ["HubSittingChairB_move1"];
		SETV(_thisObject, "animations", _args);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |          G E T   P O I N T   D A T A  I N T E R N A L              
	// | Internal function which is called by getPointData and returns the point data.
	// | Inherited classes must implement this.
	// | Returns [_offset, _animation, _direction]
	// ----------------------------------------------------------------------
	METHOD("getPointDataInternal") {
		params [["_thisObject", "", [""]], ["_pointID", 0, [0]]];
		private _animations = GETV(_thisObject, "animations");
		private _points = GETV(_thisObject, "points");
		private _bench = GETV(_thisObject, "object");
		private _dir = (getDir _bench) + 180;
		[_points select _pointID, selectRandom _animations, _dir]
	} ENDMETHOD;
	
ENDCLASS;