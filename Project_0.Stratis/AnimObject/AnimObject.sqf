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

#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"

CLASS("AnimObject", "MessageReceiver")

	VARIABLE("object"); // Object the AnimObject is attached to
	
	// Must set these variables in derived classes:
	VARIABLE("points"); // Array with the relative coordinates of the points
	VARIABLE("units"); // Array with units occupying corresponding points
	VARIABLE("pointCount"); // Total amount of points
	VARIABLE("animations"); // Array with possible animations
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_object", objNull, [objNull]]];
		if (isNil "gMessageLoopGoal") exitWith { diag_log "[AnimObject] Error: global goal message loop doesn't exist!"; };
		SETV(_thisObject, "object", _object);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                          I S   F R E E                             |
	// |                                                                    |
	// | Returns true if there are any free points left                     |
	// ----------------------------------------------------------------------
	METHOD("isFree") {
		params [["_thisObject", "", [""]]];
		private _pointCount = GETV(_thisObject, "pointCount");
		private _units = GETV(_thisObject, "units");
		private _pointFreeCount = {_x == ""} count _units;
		private _return = _pointFreeCount > 0;
		_return
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                     G E T   F R E E   P O I N T                    
	// |                                                                    
	// |  Returns ID and position(in world space) where the bot must move to play the animation of a free point at this
	// | object. If there is no free position, [] is returned               
	// ----------------------------------------------------------------------
	METHOD("getFreePoint") {
		params [ ["_thisObject", "", [""]] ];
		private _units = GETV(_thisObject, "units");
		private _pointCountM1 = GETV(_thisObject, "pointCount") - 1;
		private _freePointIDs = [];
		for "_i" from 0 to _pointCountM1 do {
			// Check if this position is free
			if (_units select _i == "") then {_freePointIDs pushBack _i; };
		};
		
		// Check if there is no free point available
		if (count _freePointIDs == 0) exitWith { [] };
		
		// Select a random point
		private _pointID = selectRandom _freePointIDs;
		
		// Return point coordinates
		private _object = GETV(_thisObject, "object");
		private _movePosOffset = CALLM(_thisObject, "getPointMovePosOffset", [_pointID]);
		private _posWorld = _object modelToWorld _movePosOffset;
		private _return = [_pointID, _posWorld];
		
		_return
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
		_pointOffset
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                      I S   P O I N T  F R E E                      |
	// |                                                                    |
	// | Returns true if the point with given ID is free                    |
	// ----------------------------------------------------------------------
	METHOD("isPointFree") {
		params [["_thisObject", "", [""]], ["_pointID", 0, [0]]];
		private _units = GETV(_thisObject, "units");
		private _return = ( (_units select _pointID) == "");
		_return
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T   P O I N T   D A T A                      |
	// |                                                                    |
	// | Returns the data of this point: attachTo offset, animation, etc    |
	// | Return value: [_offset, _animation] or [] if the point is occupied |
	// ----------------------------------------------------------------------
	METHOD("getPointData") {
		params [["_thisObject", "", [""]], ["_unit", "", [""]], ["_pointID", 0, [0]]];
		private _units = GETV(_thisObject, "units");
		
		// Mark the point occupied by this unit
		if (_units select _pointID == "") then { // Check if it's already occupied by someone
			_units set [_pointID, _unit];
			private _return = CALLM(_thisObject, "getPointDataInternal", [_pointID]);
			_return
		} else {
			[]
		};
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |          G E T   P O I N T   D A T A  I N T E R N A L              
	// | Internal function which is called by getPointData and returns the point data.
	// | Inherited classes must implement this.
	// ----------------------------------------------------------------------
	METHOD("getPointDataInternal") {
		params [["_thisObject", "", [""]], ["_pointID", 0, [0]]];
		private _animations = GETV(_thisObject, "animations");
		private _points = GETV(_thisObject, "points");
		[_points select _pointID, selectRandom _animations]
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                 H A N D L E   M E S S A G E                        |
	// |                                                                    |
	// | Call this method from the handleMessage of inherited classes       |
	// ----------------------------------------------------------------------
	METHOD("handleMessage") {
		params [["_thisObject", "", [""]], ["_msg", [], [[]]] ];
		private _msgType = _msg select MESSAGE_ID_TYPE;
		if (_msgType == ANIM_OBJECT_MESSAGE_POS_FREE) then {
			private _unit = _msg select MESSAGE_ID_SOURCE; // The unit that has sent the message
			private _units = GETV(_thisObject, "units");
			private _unitID = _units find _unit;
			if (_unitID != -1) then { // If the object has been found
				_units set [_unitID, ""];
			};
			true // message handled
		} else {
			false // message not handled
		};
	} ENDMETHOD;
	
	// Get object
	METHOD("getObject") {
		params [["_thisObject", "", [""]] ];
		GETV(_thisObject, "object")
	} ENDMETHOD;

ENDCLASS;