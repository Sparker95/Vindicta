#include "..\common.h"
/*
A bench where a unit can sit at
*/
#define THIS_CLASS_NAME "AnimObjectBench"
#define OOP_CLASS_NAME AnimObjectBench
CLASS("AnimObjectBench", "AnimObject")

	STATIC_VARIABLE("animations");
	STATIC_VARIABLE("points");

	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------

	METHOD(new)
		params [P_THISOBJECT];

		private _args = GETSV(THIS_CLASS_NAME, "points");
		T_SETV("points", _args);

		private _args = ["", ""];
		T_SETV("units", _args);

		T_SETV("pointCount", 2);

		private _animations = GETSV(THIS_CLASS_NAME, "animations");
		T_SETV("animations", _animations);
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |          G E T   P O I N T   D A T A  I N T E R N A L
	// | Internal function which is called by getPointData and returns the point data.
	// | Inherited classes must implement this.
	// | Returns [_offset, _animation, _direction]
	// ----------------------------------------------------------------------
	public override METHOD(getPointDataInternal)
		params [P_THISOBJECT, P_NUMBER("_pointID")];
		private _animations = T_GETV("animations");
		private _points = T_GETV("points");
		// pos, direction, animation, animationOut
		// pos offset, animation, animation out, walk out dir, walk out distance
		[_points select _pointID, 180, selectRandom _animations, "AcrgPknlMstpSnonWnonDnon_AmovPercMstpSrasWrflDnon_getOutLow", 0, 2]
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |             G E T    P O I N T   M O V E   P O S   O F F S E T
	// |
	// |  Internal function to get the position where the unit must move to, in model coordinates
	// | before actually playing the animation. Inherited classes must implement this!
	// ----------------------------------------------------------------------

	public override METHOD(getPointMoveOffset)
		params [P_THISOBJECT, P_NUMBER("_pointID") ];
		private _points = T_GETV("points");
		private _pointOffset = _points select _pointID;
		private _pointMoveOffset = _pointOffset vectorAdd [0, -1.4, 0]; // For bench, unit must walk to a place in front of it
		[_pointMoveOffset, 1.8]
	ENDMETHOD;

ENDCLASS;

private _animations = ["HubSittingChairA_idle1", "HubSittingChairA_idle2", "HubSittingChairA_idle3",
						 "HubSittingChairA_move1",
						 "HubSittingChairB_idle1", "HubSittingChairB_idle2", "HubSittingChairB_idle3",
						 "HubSittingChairB_move1",
						 "HubSittingChairC_idle1", "HubSittingChairC_idle2", "HubSittingChairC_idle3",
						 "InBaseMoves_SittingRifle1", "InBaseMoves_SittingRifle2"
						 ];
SETSV(THIS_CLASS_NAME, "animations", _animations);

private _points = [[0.5, -0.08, -1], [-0.5, -0.08, -1]];
SETSV(THIS_CLASS_NAME, "points", _points);
