#include "..\common.hpp"

/*
DOING::::
DECIDE if cluster class is actually needed. Maybe copy cluster array?
	Actually no, we need a copy because we modify clusters when we attack them. Easier to just keep a class
	structure.
How do we sync cluster? We could 
*/



// Model of a Real Cluster. This can either be the Actual model or the Sim model.
// The Actual model represents the Real Cluster as it currently is. A Sim model
// is a copy that is modified during simulations.
CLASS("ClusterModel", "ModelBase")
	// Cluster position
	VARIABLE("pos");
	// Cluster size
	VARIABLE("size");
	// Cluster radius
	VARIABLE("radius");
	// Cluster efficiency
	VARIABLE("efficiency");
	// Cluster efficiency damage caused
	VARIABLE("damage");

	METHOD("new") {
		params [P_THISOBJECT, P_STRING("_world"), P_ARRAY("_actual")];
		ASSERT_CLUSTER_ACTUAL_OR_NULL(_actual);

		T_SETV("pos", []);
		T_SETV("size", []);
		T_SETV("radius", 0);
		T_SETV("efficiency", +T_EFF_null);
		T_SETV("damage", +T_EFF_null);
		
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
		SETV(_copy, "radius", T_GETV("radius"));
		SETV(_copy, "efficiency", +T_GETV("efficiency"));
		SETV(_copy, "damage", +T_GETV("damage"));
		_copy
	} ENDMETHOD;

	METHOD("sync") {
		params [P_THISOBJECT];

		T_PRVAR(actual);
		_actual params ["_ai", "_clusterId"];
		private _targetCluster = CALLM(_ai, "getTargetCluster", [_clusterId]);
		if(_targetCluster isEqualTo []) then {
			T_CALLM("killed", []);
		} else {
			private _cluster = _targetCluster select TARGET_CLUSTER_ID_CLUSTER;
			T_SETV("pos", (_cluster call cluster_fnc_getCenter) + [0]);
			private _newSize = _cluster call cluster_fnc_getSize;
			T_SETV("size", +_newSize);
			T_SETV("radius", ((selectMax _newSize) + 300) max 300);
			T_SETV("efficiency", _targetCluster select TARGET_CLUSTER_ID_EFFICIENCY);
			T_SETV("damage", _targetCluster select TARGET_CLUSTER_ID_CAUSED_DAMAGE);
		};
	} ENDMETHOD;

	// Garrison is empty (not necessarily killed, could be merged to another garrison etc.)
	METHOD("killed") {
		params [P_THISOBJECT];

		T_PRVAR(world);
		T_SETV("efficiency", []);
	} ENDMETHOD;
	
	METHOD("isDead") {
		params [P_THISOBJECT];
		T_PRVAR(efficiency);
		_efficiency isEqualTo []
	} ENDMETHOD;
ENDCLASS;


// Unit test
#ifdef _SQF_VM

// ["LocationModel.new(actual)", {
// 	private _actual = NEW("Garrison", [WEST]);
// 	private _world = NEW("WorldModel", [WORLD_TYPE_REAL]);
// 	private _location = NEW("LocationModel", [_world] + [_actual]);
// 	private _class = OBJECT_PARENT_CLASS_STR(_location);
// 	!(isNil "_class")
// }] call test_AddTest;

// ["LocationModel.new(sim)", {
// 	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
// 	private _location = NEW("LocationModel", [_world]);
// 	private _class = OBJECT_PARENT_CLASS_STR(_location);
// 	!(isNil "_class")
// }] call test_AddTest;

// ["LocationModel.delete", {
// 	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
// 	private _location = NEW("LocationModel", [_world]);
// 	DELETE(_location);
// 	private _class = OBJECT_PARENT_CLASS_STR(_location);
// 	isNil "_class"
// }] call test_AddTest;

#endif