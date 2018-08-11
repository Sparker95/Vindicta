/*
A bench where a unit can sit at
*/

#include "..\OOP_Light\OOP_Light.h"

CLASS("AnimObjectBench", "AnimObject")
	
	STATIC_VARIABLE("animations");
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]]];
		
		private _args = [[0.5, -0.08, -1], [-0.5, -0.08, -1]];
		SETV(_thisObject, "points", _args);
		
		private _args = ["", ""];
		SETV(_thisObject, "units", _args);
		
		SETV(_thisObject, "pointCount", 2);
		
		private _animations = GET_STATIC_VAR("AnimObjectBench", "animations");
		SETV(_thisObject, "animations", _animations);
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
	
	// ----------------------------------------------------------------------
	// |             G E T    P O I N T   M O V E   P O S   O F F S E T
	// |                                                                    
	// |  Internal function to get the position where the unit must move to
	// | before actually playing the animation. Inherited classes must implement this!
	// ----------------------------------------------------------------------
	
	METHOD("getPointMovePosOffset") {
		params [ ["_thisObject", "", [""]], ["_pointID", 0, [0]] ];
		private _points = GETV(_thisObject, "points");
		private _pointOffset = _points select _pointID;
		private _pointMoveOffset = _pointOffset vectorAdd [0, -1.4, 0];
		_pointMoveOffset
	} ENDMETHOD;
	
ENDCLASS;

private _animations = ["HubSittingChairA_idle1", "HubSittingChairA_idle2", "HubSittingChairA_idle3",
						 "HubSittingChairA_move1",
						 "HubSittingChairB_idle1", "HubSittingChairB_idle2", "HubSittingChairB_idle3",
						 "HubSittingChairB_move1",
						 "HubSittingChairC_idle1", "HubSittingChairC_idle2", "HubSittingChairC_idle3",
						 "InBaseMoves_SittingRifle1", "InBaseMoves_SittingRifle2"
						 ];
SET_STATIC_VAR("AnimObjectBench", "animations", _animations);