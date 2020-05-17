

#include "..\common.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
/*
AnimObject is a representation of a world object a unit can play animation on: bench, campfire, table, etc.

How to use it:
1. Unit wants to play an animation with the object.
2. Find a suitable object with isFree.
3. Get the position and ID where the unit has to walk to with getFreePos.
4. While the unit is walking, check if the position is still free with isPosFree.
5. When the unit has walked to the position, get animation data with getPointData.
6. When unit has finished playing the animation for any reason, send a ANIM_OBJECT_MESSAGE_POS_FREE message to the AnimObject.

Author: Sparker 10.08.2018
*/

#define OOP_CLASS_NAME AnimObject
CLASS("AnimObject", "")

	VARIABLE("object"); // Object the AnimObject is attached to

	// Must set these variables in derived classes:
	VARIABLE("points"); // Array with the relative coordinates of the points
	VARIABLE("units"); // Array with units occupying corresponding points
	VARIABLE("pointCount"); // Total amount of points
	VARIABLE("animations"); // Array with possible animations

	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------

	METHOD(new)
		params [P_THISOBJECT, P_OBJECT("_object")];
		if (isNil "gMessageLoopGoal") exitWith { diag_log "[AnimObject] Error: global goal message loop doesn't exist!"; };
		T_SETV("object", _object);
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                          I S   F R E E                             |
	// |                                                                    |
	// | Returns true if there are any free points left                     |
	// ----------------------------------------------------------------------
	METHOD(isFree)
		params [P_THISOBJECT];
		private _pointCount = T_GETV("pointCount");
		private _units = T_GETV("units");
		private _pointFreeCount = {_x == ""} count _units;
		private _return = _pointFreeCount > 0;
		_return
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                     G E T   F R E E   P O I N T
	// |
	// |  Returns ID and position (in model space) where the bot must move to play the animation of a free point at this
	// | object. If there is no free position, [] is returned
	// |  Return:
	// |  [_pointID, _movePosOffset]
	// |   _movePosOffset - position in MODEL coordinates
	// ----------------------------------------------------------------------
	METHOD(getFreePoint)
		params [P_THISOBJECT];
		private _units = T_GETV("units");
		private _pointCountM1 = T_GETV("pointCount") - 1;
		private _freePointIDs = [];
		for "_i" from 0 to _pointCountM1 do {
			// Check if this position is free
			if (_units select _i == "") then {_freePointIDs pushBack _i; };
		};

		// Check if there is no free point available
		if (count _freePointIDs == 0) exitWith { [] };

		// Select a random point
		private _pointID = selectRandom _freePointIDs; //selectRandom _freePointIDs;

		// Return point coordinates
		private _object = T_GETV("object");
		private _movePosOffsetAndRadius = T_CALLM("getPointMoveOffset", [_pointID]);
		//private _posWorld = _object modelToWorld _movePosOffset;
		private _return = [_pointID] + _movePosOffsetAndRadius;

		_return
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                      I S   P O I N T  F R E E                      |
	// |                                                                    |
	// | Returns true if the point with given ID is free                    |
	// ----------------------------------------------------------------------
	METHOD(isPointFree)
		params [P_THISOBJECT, P_NUMBER("_pointID")];
		private _units = T_GETV("units");
		private _return = ( (_units select _pointID) == "");
		_return
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                   G E T   P O I N T   D A T A
	// |
	// | Returns the data of this point: offset, animation, etc
	// | Return value: [_offset, _animation, _dir, _walkOutDir, _walkOutDistance] or [] if the point is occupied
	// | _offset, _dir - offset position and direction in MODEL coordinates
	// ----------------------------------------------------------------------
	METHOD(getPointData)
		params [P_THISOBJECT, P_OOP_OBJECT("_unit"), P_NUMBER("_pointID")];
		private _units = T_GETV("units");

		// Mark the point occupied by this unit
		if (_units select _pointID == "") then { // Check if it's already occupied by someone
			_units set [_pointID, _unit];
			private _return = T_CALLM("getPointDataInternal", [_pointID]);
			_return
		} else {
			[]
		};
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                 P O I N T   I S   F R E E
	// |
	// | Notifies the AnimObject that the position is now not occupied any more
	// ----------------------------------------------------------------------
	METHOD(pointIsFree)
		params [P_THISOBJECT, P_NUMBER("_pointID") ];
		private _units = T_GETV("units");
		_units set [_pointID, ""];
	ENDMETHOD;

	// ----------------------------------------------------------------------------
	// |                    G E T   O B J E C T
	// ----------------------------------------------------------------------------
	METHOD(getObject)
		params [P_THISOBJECT ];
		T_GETV("object")
	ENDMETHOD;




	// =============================================================================
	// | V I R T U A L   M E T H O D S   F O R   I N H E R I T E D   C L A S S E S |
	// =============================================================================

	// ----------------------------------------------------------------------
	// |             G E T    P O I N T   M O V E   O F F S E T
	// |
	// |  Internal function to get the position where the unit must move to, in model coordinates
	// | before actually playing the animation. Inherited classes must implement this!
	// | Return value:
	// | [_posOffset, _completionRadius]
	// ----------------------------------------------------------------------

	METHOD(getPointMoveOffset)
		params [P_THISOBJECT, P_NUMBER("_pointID") ];
		private _points = T_GETV("points");
		private _pointOffset = _points select _pointID;
		[_pointOffset, 1.8]
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |          G E T   P O I N T   D A T A  I N T E R N A L
	// |
	// | Internal function which is called by getPointData and returns the point data.
	// | Inherited classes must implement this.
	// | Return value: [_pos, _dir, _animation, _animationOut, _walkOutDir, _walkOutDistance]
	// ----------------------------------------------------------------------
	METHOD(getPointDataInternal)
		params [P_THISOBJECT, P_NUMBER("_pointID")];
		private _animations = T_GETV("animations");
		private _animationsOut = T_GETV("animationsOut");
		private _points = T_GETV("points");
		private _id = floor (random (count _animations));
		[_points select _pointID, 0, _animations select _id, "", 0, 0]; // "" animation will cause the unit erase all animations by default
	ENDMETHOD;

ENDCLASS;
