#include "common.hpp"
FIX_LINE_NUMBERS()

/*
Class: CivilWarPoliceStationData
Police station data specific to this game mode.
*/
#define OOP_CLASS_NAME CivilWarPoliceStationData
CLASS("CivilWarPoliceStationData", "CivilWarLocationData")
	// If a reinforcement regiment is on the way then it goes here. We ref count it ourselves as well
	// so it doesn't get deleted until we are done with it.
	VARIABLE_ATTR("reinfGarrison", [ATTR_REFCOUNTED]);
	VARIABLE_ATTR("reinfSent", [ATTR_SAVE]); // Police reinforcements can be sent to a police station only once

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("reinfSent", false);
		T_SETV_REF("reinfGarrison", NULL_OBJECT);
	ENDMETHOD;

	public METHOD(update)
		params [P_THISOBJECT, P_OOP_OBJECT("_policeStation"), P_NUMBER("_cityState")];
		ASSERT_OBJECT_CLASS(_policeStation, "Location");

		private _reinfGarrison = T_GETV("reinfGarrison");
		// If there is an active reinforcement garrison...
		if(!IS_NULL_OBJECT(_reinfGarrison)) then {
			// If reinf garrison arrived or died then we delete it
			if(CALLM0(_reinfGarrison, "isEmpty") or { CALLM0(_reinfGarrison, "getLocation") == _policeStation }) then {
				T_SETV_REF("reinfGarrison", NULL_OBJECT);
			};
		} else {
			// If we have no or weakened garrison then we spawn a new one to reinforce/
			// TODO: make this a bit better, maybe have them come from nearest town held by the same side.
			// We need some way to reinforce police generally probably?
			private _garrisons = CALLM1(_policeStation, "getGarrisons", ENEMY_SIDE);
			// We only want to reinforce police stations still under our control
			if (count _garrisons > 0 and  { CALLM0(_garrisons#0, "countInfantryUnits") <= 4 } and {!T_GETV("reinfSent")}) then {
				OOP_INFO_MSG("Spawning police reinforcements for %1 as the garrison is dead", [_policeStation]);
				// If we liberated the city then we spawn police on our own side!
				private _side = if(_cityState == CITY_STATE_FRIENDLY_CONTROL) then {  FRIENDLY_SIDE } else { ENEMY_SIDE };
				// We will use a fixed response size -- police are coming from outside town so town size isn't really relavent
				private _cVehGround = 2;
				private _cInf = _cVehGround * 4;

				// Work out where to start the garrison, we don't want to be near to active players as it will appear out of nowhere
				private _locPos = CALLM0(_policeStation, "getPos");
				private _playerBlacklistAreas = playableUnits apply { [getPos _x, 1000] };
				private _maxDistance = 2500;
				private _spawnInPos = +_locPos;
				while { _spawnInPos distance2D _locPos <= 900 && _maxDistance <= 4500 } do {
					_spawnInPos = [_locPos, 1000, _maxDistance, 0, 0, 1, 0, _playerBlacklistAreas, _locPos] call BIS_fnc_findSafePos;
					// This function returns 2D vector for some reason
					if(count _spawnInPos == 2) then { _spawnInPos pushBack 0; };
					_maxDistance = _maxDistance + 500;
				};

				// Ensure that the found position is far enough from the location which is being reinforced
				if (_spawnInPos distance2D _locPos > 900) then {
					// [P_THISOBJECT, P_STRING("_faction"), P_SIDE("_side"), P_NUMBER("_cInf"), P_NUMBER("_cVehGround"), P_NUMBER("_cHMGGMG"), P_NUMBER("_cBuildingSentry"), P_NUMBER("_cCargoBoxes")];
					private _args = [_side, _cInf, _cVehGround];
					private _newGarrison = CALLM(gGameMode, "createPoliceGarrison", _args);
					T_SETV_REF("reinfGarrison", _newGarrison);

					CALLM2(_newGarrison, "postMethodAsync", "setPos", [_spawnInPos]);
					CALLM0(_newGarrison, "activate");
					private _AI = CALLM0(_newGarrison, "getAI");
					// Send the garrison to join the police station location
					private _args = ["GoalGarrisonJoinLocation", 0, [[TAG_LOCATION, _policeStation], [TAG_MOVE_RADIUS, 100]], _thisObject];
					CALLM2(_AI, "postMethodAsync", "addExternalGoal", _args);

					// Set flag that we have dispatched reinforcements once already
					T_SETV("reinfSent", true);
				};
			};
		};
	ENDMETHOD;

	// STORAGE

	public override METHOD(postDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		// Call method of all base classes
		CALLCM("CivilWarLocationData", _thisObject, "postDeserialize", [_storage]);

		T_SETV_REF("reinfGarrison", NULL_OBJECT);

		true
	ENDMETHOD;
ENDCLASS;
