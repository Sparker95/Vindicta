#include "..\common.hpp"

// Model of a Real Cluster. This can either be the Actual model or the Sim model.
// The Actual model represents the Real Cluster as it currently is. A Sim model
// is a copy that is modified during simulations.
CLASS("ClusterModel", "ModelBase")
	// Cluster position
	VARIABLE("pos");
	// Cluster size
	VARIABLE("size");
	// Cluster efficiency
	VARIABLE("eff");
	// Cluster efficiency damage caused
	VARIABLE("damage");

	METHOD("new") {
		params [P_THISOBJECT, P_STRING("_world"), P_NUMBER("_actual")];
		T_SETV("pos", []);
		T_SETV("size", []);
		T_SETV("eff", T_EFF_null);
		T_SETV("damage", T_EFF_null);
		
		// Add self to world
		CALLM(_world, "addCluster", [_thisObject]);
	} ENDMETHOD;

	METHOD("simCopy") {
		params [P_THISOBJECT, P_STRING("_targetWorldModel")];
		private _copy = NEW("ClusterModel", [_targetWorldModel]);
		// TODO: copying ID is weird because ID is actually index into array in the world model, so we can't change it.
		#ifdef OOP_ASSERT
		private _idsEqual = T_GETV("id") == GETV(_copy, "id");
		private _msg = format ["%1 id (%2) out of sync with sim copy %3 id (%4)", _thisObject, T_GETV("id"), _copy, GETV(_copy, "id")];
		ASSERT_MSG(_idsEqual, _msg);
		#endif
		SETV(_copy, "id", T_GETV("id"));
		SETV(_copy, "pos", +T_GETV("pos"));
		SETV(_copy, "size", +T_GETV("size"));
		SETV(_copy, "eff", +T_GETV("eff"));
		SETV(_copy, "damage", +T_GETV("damage"));
		_copy
	} ENDMETHOD;
	
	METHOD("sync") {
		params [P_THISOBJECT];

		T_PRVAR(actual);
		// // If we have an assigned Reak Object then sync from it
		// if(_actual isEqualType "") then {
		// 	OOP_DEBUG_1("Updating LocationModel from Location %1", _actual);
		// 	T_SETV("pos", CALLM(_actual, "getPos", []));
		// 	T_SETV("side", CALLM(_actual, "getSide", []));

		// 	private _garrisonActual = CALLM(_actual, "getGarrisonMilitaryMain", []);
		// 	if(!(_garrisonActual isEqualTo "")) then {
		// 		T_PRVAR(world);
		// 		private _garrison = CALLM(_world, "findGarrisonByActual", [_garrisonActual]);
		// 		T_SETV("garrisonId", GETV(_garrison, "id"));
		// 	} else {
		// 		T_SETV("garrisonId", MODEL_HANDLE_INVALID);
		// 	};
		// };
	} ENDMETHOD;
	
ENDCLASS;


// Unit test
#ifdef _SQF_VM

// ["LocationModel.new(actual)", {
// 	private _actual = NEW("Garrison", [WEST]);
// 	private _world = NEW("WorldModel", [false]);
// 	private _location = NEW("LocationModel", [_world] + [_actual]);
// 	private _class = OBJECT_PARENT_CLASS_STR(_location);
// 	!(isNil "_class")
// }] call test_AddTest;

// ["LocationModel.new(sim)", {
// 	private _world = NEW("WorldModel", [true]);
// 	private _location = NEW("LocationModel", [_world]);
// 	private _class = OBJECT_PARENT_CLASS_STR(_location);
// 	!(isNil "_class")
// }] call test_AddTest;

// ["LocationModel.delete", {
// 	private _world = NEW("WorldModel", [true]);
// 	private _location = NEW("LocationModel", [_world]);
// 	DELETE(_location);
// 	private _class = OBJECT_PARENT_CLASS_STR(_location);
// 	isNil "_class"
// }] call test_AddTest;

#endif