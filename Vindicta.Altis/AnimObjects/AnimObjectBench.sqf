#include "..\OOP_Light\OOP_Light.h"
/*
A bench where a unit can sit at
*/
#define THIS_CLASS_NAME "AnimObjectBench"

CLASS(THIS_CLASS_NAME, "AnimObject")

	STATIC_VARIABLE("animations");
	STATIC_VARIABLE("points");

	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------

	METHOD("new") {
		params [["_thisObject", "", [""]]];

		private _args = GET_STATIC_VAR(THIS_CLASS_NAME, "points");
		SETV(_thisObject, "points", _args);

		private _args = ["", ""];
		SETV(_thisObject, "units", _args);

		SETV(_thisObject, "pointCount", 2);

		private _animations = GET_STATIC_VAR(THIS_CLASS_NAME, "animations");
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
		// pos, direction, animation, animationOut
		// pos offset, animation, animation out, walk out dir, walk out distance
		[_points select _pointID, 180, selectRandom _animations, "AcrgPknlMstpSnonWnonDnon_AmovPercMstpSrasWrflDnon_getOutLow", 0, 2]
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |             G E T    P O I N T   M O V E   P O S   O F F S E T
	// |
	// |  Internal function to get the position where the unit must move to, in model coordinates
	// | before actually playing the animation. Inherited classes must implement this!
	// ----------------------------------------------------------------------

	METHOD("getPointMoveOffset") {
		params [ ["_thisObject", "", [""]], ["_pointID", 0, [0]] ];
		private _points = GETV(_thisObject, "points");
		private _pointOffset = _points select _pointID;
		private _pointMoveOffset = _pointOffset vectorAdd [0, -1.4, 0]; // For bench, unit must walk to a place in front of it
		[_pointMoveOffset, 1.8]
	} ENDMETHOD;

ENDCLASS;

private _animations = ["HubSittingChairA_idle1", "HubSittingChairA_idle2", "HubSittingChairA_idle3",
						 "HubSittingChairA_move1",
						 "HubSittingChairB_idle1", "HubSittingChairB_idle2", "HubSittingChairB_idle3",
						 "HubSittingChairB_move1",
						 "HubSittingChairC_idle1", "HubSittingChairC_idle2", "HubSittingChairC_idle3",
						 "InBaseMoves_SittingRifle1", "InBaseMoves_SittingRifle2"
						 ];
SET_STATIC_VAR(THIS_CLASS_NAME, "animations", _animations);

private _points = [[0.5, -0.08, -1], [-0.5, -0.08, -1]];
SET_STATIC_VAR(THIS_CLASS_NAME, "points", _points);
