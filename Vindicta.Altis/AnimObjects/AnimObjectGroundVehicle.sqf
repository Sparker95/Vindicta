#include "..\common.h"
/*
A vehicle and animations to 'repair' it.
*/
#define OOP_CLASS_NAME AnimObjectGroundVehicle
CLASS("AnimObjectGroundVehicle", "AnimObject")

	STATIC_VARIABLE("animations");

	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------

	METHOD(new)
		params [P_THISOBJECT, P_OBJECT("_object")];

		private _objectHandle = T_GETV("object");
		private _width = [_object] call misc_fnc_getVehicleWidth;
		// Compensate the Z coordinate of the vehicle, because [0,0,0] of the vehicle model is above the ground
		private _vehCenter = _objectHandle modelToWorld [0,0,0];
		private _centerHeight = _vehCenter select 2;
		private _args = [	[-_width, -1.5, -_centerHeight], [-_width, 0, -_centerHeight], [-_width, 1.5, -_centerHeight],
							[_width, -1.5, -_centerHeight], [_width, 0, -_centerHeight], [_width, 1.5, -_centerHeight] ];
		T_SETV("points", _args);

		private _args = ["", "", "", "", "", ""];
		T_SETV("units", _args);

		T_SETV("pointCount", 6);

		private _animations = GET_STATIC_VAR("AnimObjectGroundVehicle", "animations");
		T_SETV("animations", _animations);
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |          G E T   P O I N T   D A T A  I N T E R N A L
	// | Internal function which is called by getPointData and returns the point data.
	// | Inherited classes must implement this.
	// | Returns [_offset, _animation, _direction]
	// ----------------------------------------------------------------------
	METHOD(getPointDataInternal)
		params [P_THISOBJECT, P_NUMBER("_pointID")];
		private _animations = T_GETV("animations");
		private _points = T_GETV("points");
		private _dir = 0;
		if (_pointID < 3) then {
			_dir = 90;
		} else {
			_dir = -90;
		};
		private _offset = _points select _pointID;

		_offset set [1, (_offset select 1) - 0.5 + (random 1) ]; // Randomize the coordinate along the vehicle
		// pos offset, animation, animation out, walk out dir, walk out distance
		[_offset, _dir, selectRandom _animations, "", 0, 0]
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |             G E T    P O I N T   M O V E   P O S   O F F S E T
	// |
	// |  Internal function to get the position where the unit must move to, in model coordinates
	// | before actually playing the animation. Inherited classes must implement this!
	// ----------------------------------------------------------------------
	METHOD(getPointMoveOffset)
		params [P_THISOBJECT, P_NUMBER("_pointID") ];
		private _points = T_GETV("points");
		private _pointOffset = _points select _pointID;
		[_pointOffset, 6] // For vehicles completion radius is quite large
	ENDMETHOD;

ENDCLASS;

private _animations = ["InBaseMoves_repairVehiclePne", "InBaseMoves_assemblingVehicleErc", "InBaseMoves_repairVehicleKnl"];
SET_STATIC_VAR("AnimObjectGroundVehicle", "animations", _animations);
