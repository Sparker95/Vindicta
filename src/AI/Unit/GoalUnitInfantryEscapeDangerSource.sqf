#include "common.hpp"

/*
Author: Sparker
This is meant for escaping some local dangers, like grenades or impeding cars.
Unit will try to get away from a danger source stored in AIUnitHuman.dangerSource variable, if it exists.
*/

#define pr private

#define OOP_CLASS_NAME GoalUnitInfantryEscapeDangerSource
CLASS("GoalUnitInfantryEscapeDangerSource", "GoalUnit")

	STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];
		
		pr _hO = GETV(_ai, "hO");
		if (isNil {GETV(_ai, "dangerSource")} || {!(_hO isEqualTo (vehicle _hO))} || {(_hO distance GETV(_ai, "dangerSource")) > GETV(_ai, "dangerRadius")}  ) then {
			0
		} else {
			GETSV("GoalUnitInfantryEscapeDangerSource", "relevance");
		};
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];
		CALLM1(_ai, "setAllowVehicleWSP", false);

		// We will have to move to some position, so prepare move coordinates
		pr _radius = GETV(_ai, "dangerRadius");
		pr _moveRadius = 0.1;
		pr _dangerSrc = GETV(_ai, "dangerSource");
		pr _hO = GETV(_ai, "hO");
		pr _escapePos = 0;

		// If danger source is a car, we handle it differently
		// We want to run orthogonal to where car is facing
		if ((_dangerSrc isEqualType objNull) && {_dangerSrc isKindOf "Car"}) then {
			pr _posUnitInDangerModel = _dangerSrc worldToModel (getPos _hO);
			pr _bearing = 0;
			if (_posUnitInDangerModel#0 > 0) then {	// If we are to the right of the car
				_bearing = (direction _dangerSrc) + 60;
			} else {
				_bearing = (direction _dangerSrc) - 60;
			};
			pr _vehSpeedms = vectorMagnitude velocity _dangerSrc;
			pr _escapeDistance = 4.5 + 0.3*_vehSpeedms;
			_hO setDir _bearing;
			_escapePos = _hO getPos [_escapeDistance, _bearing];	// Run from current position! Not from danger!
		} else {
			// Bearing from danger src to this bot
			// We will try to move in that direction away from danger
			pr _bearing = _dangerSrc getDir _hO;
			_escapePos = _dangerSrc getPos [_radius*1.1 + 2, _bearing];
		};

		// Set unlimited speed
		_hO forceSpeed -1;
		_hO forceWalk false;
		pr _hGroup = group _hO;
		if (!isNull _hGroup) then {
			if ((behaviour _hO) in ["SAFE", "CARELESS"]) then {
				_hGroup setBehaviour "AWARE";	// todo I wish we could change behaviour of only one unit but well, arma :/
			};
			_hGroup setSpeedMode "NORMAL";
		};

    	//pr _arrow = createVehicle ["Sign_Arrow_Green_F", _escapePos, [], 0, "CAN_COLLIDE"];
		//_arrow spawn {sleep 2; deleteVehicle _this;}; 

		_goalParameters pushBack [TAG_MOVE_TARGET, _escapePos];
		_goalParameters pushBack [TAG_MOVE_RADIUS, _moveRadius];

		CALLM1(_ai, "setMoveTarget", _escapePos);
		CALLM1(_ai, "setMoveTargetRadius", _moveRadius);
		CALLM0(_ai, "updatePositionWSP");
	ENDMETHOD;

	// Must return a bool, true or false, if unit can talk while doing this goal
	// Default is false;
	STATIC_METHOD(canTalk)
		true;
	ENDMETHOD;

ENDCLASS;


/*
#include "common.h"

pr _nearMen = player nearObjects ["CAManBase", 15];
diag_log format ["Nearby men: %1", _nearMen];
{
	private _ai = NULL_OBJECT;
	private _objCivilian = CALLSM1("Civilian", "getCivilianFromObjectHandle", _x);
	if (IS_NULL_OBJECT(_objCivilian)) then {
		private _objUnit = CALLSM1("Unit", "getUnitFromObjectHandle", _x);
		if (!IS_NULL_OBJECT(_objUnit)) then {
			_ai = CALLM0(_objUnit, "getAI");
		};
	} else {
		_ai = CALLM0(_objCivilian, "getAI");
	};
	
	if (!IS_NULL_OBJECT(_ai)) then {
		diag_log format ["  Sending data to AI: %1 %2", _x, _ai];
		// params [P_THISOBJECT, P_DYNAMIC("_dangerSrc"), P_NUMBER("_radius"), P_NUMBER("_duration"), P_NUMBER("_dangerLevel")];
		CALLM4(_ai, "addDangerSource", vehicle player, 14, 5, 10);
	};

} forEach _nearMen;
*/