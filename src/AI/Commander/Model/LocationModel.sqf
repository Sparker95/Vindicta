#include "..\common.hpp"
FIX_LINE_NUMBERS()

#define pr private

// Model of a Real Location. This can either be the Actual model or the Sim model.
// The Actual model represents the Real Location as it currently is. A Sim model
// is a copy that is modified during simulations.
#define OOP_CLASS_NAME LocationModel
CLASS("LocationModel", "ModelBase")
	// Location position
	VARIABLE("pos");
	// Location type
	VARIABLE("type");
	// Model Id of the garrison currently occupying this location
	VARIABLE("garrisonIds");
	// Is this location a spawn?
	VARIABLE("spawn");
	// Is this location determined by the cmdr as a staging outpost?
	// (i.e. Planned attacks will be mounted from here)
	// (Not implemented yet)
	VARIABLE("staging");
	// Radius of the location
	VARIABLE("radius");
	// Efficiency of enemy forces occupying this place
	VARIABLE("efficiency");
	// Side which has created this place, or CIVILIAN if it was there at the map initially.
	VARIABLE("sideCreated");
	// Influence value (from game mode)
	VARIABLE("influence");
	// Max infantry capacity
	VARIABLE("capacityInf");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_world"), P_OOP_OBJECT("_actual")];
		T_SETV("pos", []);
		T_SETV("type", "");
		T_SETV("garrisonIds", []);
		T_SETV("spawn", false);
		T_SETV("staging", false);
		T_SETV("radius", 0);
		T_SETV("efficiency", +T_EFF_null);
		T_SETV("sideCreated", CIVILIAN);
		T_SETV("influence", 0);
		T_SETV("capacityInf", 0);

		if(T_CALLM0("isActual")) then {
			// We initialize some variables only once to avoid wasting time
			//  on each update because they never change
			T_SETV("pos", CALLM0(_actual, "getPos"));
			T_SETV("type", GETV(_actual, "type"));
			private _radius = GETV(_actual, "boundingRadius");
			T_SETV("radius", _radius);
			T_SETV("sideCreated", GETV(_actual, "sideCreated"));

			// The rest is synchronized initially through the usual "sync" method
			T_CALLM0("sync");
			#ifdef OOP_DEBUG
			OOP_DEBUG_MSG("LocationModel for %1 created in %2", [_actual ARG _world]);
			#endif
			FIX_LINE_NUMBERS()
		};

		// Add self to world
		CALLM1(_world, "addLocation", _thisObject);
	ENDMETHOD;

	public override METHOD(simCopy)
		params [P_THISOBJECT, P_OOP_OBJECT("_targetWorldModel")];
		ASSERT_OBJECT_CLASS(_targetWorldModel, "WorldModel");

		//ASSERT_MSG(T_CALLM("isActual", []), "Only sync actual models");

		private _actual = T_GETV("actual");
		private _copy = NEW("LocationModel", [_targetWorldModel ARG _actual]);

		// id is set in the constructor above, as the location self registers with the world
		// TODO: copying ID is weird because ID is actually index into array in the world model, so we can't change it.
		#ifdef OOP_ASSERT
		private _idsEqual = T_GETV("id") == GETV(_copy, "id");
		private _msg = format ["%1 id (%2) out of sync with sim copy %3 id (%4)", _thisObject, T_GETV("id"), _copy, GETV(_copy, "id")];
		ASSERT_MSG(_idsEqual, _msg);
		#endif
		FIX_LINE_NUMBERS()
		// SETV(_copy, "id", T_GETV("id"));
		SETV(_copy, "label", T_GETV("label"));
		SETV(_copy, "pos", +T_GETV("pos"));
		SETV(_copy, "type", T_GETV("type"));
		SETV(_copy, "garrisonIds", +T_GETV("garrisonIds"));
		SETV(_copy, "spawn", T_GETV("spawn"));
		SETV(_copy, "staging", T_GETV("staging"));
		SETV(_copy, "radius", T_GETV("radius"));
		SETV(_copy, "efficiency", +T_GETV("efficiency"));
		SETV(_copy, "sideCreated", T_GETV("sideCreated"));
		_copy
	ENDMETHOD;

	public override METHOD(sync)
		params [P_THISOBJECT, P_OOP_OBJECT("_AICommander")];

		ASSERT_MSG(T_CALLM0("isActual"), "Only sync actual models");

		private _actual = T_GETV("actual");
		
		ASSERT_OBJECT_CLASS(_actual, "Location");

		//OOP_DEBUG_1("Updating LocationModel from Location %1", _actual);

		private _world = T_GETV("world");

		private _garrisonActuals = CALLM2(_actual, "getGarrisons", 0, [GARRISON_TYPE_GENERAL ARG GARRISON_TYPE_AIR]);
		private _garrisonIds = [];
		{
			private _garrison = CALLM1(_world, "findGarrisonByActual", _x);
			// Garrison might not be registered, might be civilian, enemy and not known etc.
			if(!IS_NULL_OBJECT(_garrison)) then {
				ASSERT_OBJECT_CLASS(_garrison, "GarrisonModel");
				_garrisonIds pushBack GETV(_garrison, "id");
			};
		} foreach _garrisonActuals;
		T_SETV("garrisonIds", _garrisonIds);

		// Sync intel about enemy efficiency here
		//OOP_INFO_1("SYNC AICommander: %1", _AICommander);
		if (!IS_NULL_OBJECT(_AICommander)) then {
			ASSERT_OBJECT_CLASS(_AICommander, "AICommander");
			pr _intel = CALLM1(_AICommander, "getIntelAboutLocation", _actual);
			//OOP_INFO_1("  Intel: %1", _intel);
			if (IS_NULL_OBJECT(_intel)) then {
				T_SETV("efficiency", +T_EFF_null);
			} else {
				pr _intelEff = GETV(_intel, "efficiency");
				//OOP_INFO_1("  Intel eff: %1", _intelEff);
				T_SETV("efficiency", +_intelEff);
			};
		};

		// Sync influence
		pr _gameModeData = GETV(_actual, "gameModeData");
		if (!IS_NULL_OBJECT(_gameModeData)) then {
			if (GET_OBJECT_CLASS(_gameModeData) == "CivilWarCityData") then {
				pr _influence = CALLM0(_gameModeData, "getInfluence");
				T_SETV("influence", _influence);
			};
		};

		// Sync inf capacity
		T_SETV("capacityInf", CALLM0(_actual, "getCapacityInf"));
	ENDMETHOD;

	public METHOD(isEmpty)
		params [P_THISOBJECT];
		count T_GETV("garrisonIds") == 0
	ENDMETHOD;

	public METHOD(addGarrison)
		params [P_THISOBJECT, P_OOP_OBJECT("_garrison")];
		ASSERT_OBJECT_CLASS(_garrison, "GarrisonModel");
		ASSERT_MSG(GETV(_garrison, "locationId") == MODEL_HANDLE_INVALID, "Garrison is already assigned to another location");

		private _garrisonIds = T_GETV("garrisonIds");
		private _garrisonId = GETV(_garrison, "id");
		ASSERT_MSG(_garrisonIds find _garrisonId == NOT_FOUND, "Garrison already occupying this Location");
		// ASSERT_MSG(_garrisonId == MODEL_HANDLE_INVALID, "Can't setGarrison if location is already occupied, use clearGarrison first");
		_garrisonIds pushBack _garrisonId;
	ENDMETHOD;

	public METHOD(getGarrison)
		params [P_THISOBJECT, P_SIDE("_side")];

		private _world = T_GETV("world");
		private _foundGarr = NULL_OBJECT;
		{
			private _garr = CALLM1(_world, "getGarrison", _x);
			if(_side == GETV(_garr, "side")) exitWith {
				_foundGarr = _garr;
			}
		} forEach T_GETV("garrisonIds");
		_foundGarr
	ENDMETHOD;

	public METHOD(removeGarrison)
		params [P_THISOBJECT, P_OOP_OBJECT("_garrison")];
		ASSERT_OBJECT_CLASS(_garrison, "GarrisonModel");
		ASSERT_MSG(GETV(_garrison, "locationId") == T_GETV("id"), "Garrison is not assigned to this location");

		private _garrisonIds = T_GETV("garrisonIds");
		private _foundIdx = _garrisonIds find GETV(_garrison, "id");
		ASSERT_MSG(_foundIdx != NOT_FOUND, "Garrison was not assigned to this Location");
		_garrisonIds deleteAt _foundIdx;
		//SETV(_garrison, "locationId", MODEL_HANDLE_INVALID);
		//T_SETV("garrisonId", MODEL_HANDLE_INVALID);
	ENDMETHOD;
ENDCLASS;


// Unit test
#ifdef _SQF_VM

["LocationModel.new(actual)", {
	private _pos = [1000,2000,3000];
	private _actual = NEW("Location", [_pos]);
	private _world = NEW("WorldModel", [WORLD_TYPE_REAL]);
	private _location = NEW("LocationModel", [_world ARG _actual]);
	private _class = OBJECT_PARENT_CLASS_STR(_location);
	!(isNil "_class")
}] call test_AddTest;

["LocationModel.new(sim)", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _location = NEW("LocationModel", [_world ARG "<undefined>"]);
	private _class = OBJECT_PARENT_CLASS_STR(_location);
	!(isNil "_class")
}] call test_AddTest;

["LocationModel.delete", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _location = NEW("LocationModel", [_world ARG "<undefined>"]);
	DELETE(_location);
	private _class = OBJECT_PARENT_CLASS_STR(_location);
	isNil "_class"
}] call test_AddTest;

#endif