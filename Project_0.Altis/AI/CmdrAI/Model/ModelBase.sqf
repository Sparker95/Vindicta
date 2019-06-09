#include "..\common.hpp"

// Model of a Real Object. This can either be the Actual Model or the Sim Model.
// The Actual Model represents the Real Object as it currently is. A Sim Model
// is a copy that can be simulated.
CLASS("ModelBase", "RefCounted")
	// Unique Id of this Model, it is identical between Actual and Sim Models 
	// that represent the same Real Object.
	VARIABLE("id");

	// Optional ref to the Real Object this Model represents. 
	// If set to objNull then this is presumed to be a Sim Model.
	VARIABLE("actual");
	// World Model that owns this Object Model
	VARIABLE("world");

	VARIABLE("label");

	METHOD("new") {
		params [P_THISOBJECT, P_STRING("_world"), ["_actual", NULL_OBJECT]];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");

		T_SETV("id", MODEL_HANDLE_INVALID);
		T_SETV("world", _world);
		T_SETV("actual", _actual);
		T_SETV("label", str _actual);
	} ENDMETHOD;

	METHOD("isActual") {
		params [P_THISOBJECT];
		T_PRVAR(world);
		CALLM(_world, "isReal", []);
	} ENDMETHOD;

	METHOD("simCopy") {
		params [P_THISOBJECT, P_STRING("_targetWorldModel")];
		FAILURE("simCopy method must be implemented when deriving from ModelBase");
	} ENDMETHOD;

	// METHOD("setId") {
	// 	params [P_THISOBJECT, P_NUMBER("_id")];
	// 	T_SETV("id", _id);
	// } ENDMETHOD;
	
	METHOD("sync") {
		params [P_THISOBJECT];
		FAILURE("sync method must be implemented when deriving from ModelBase");
	} ENDMETHOD;

	METHOD("update") {
		params [P_THISOBJECT];
		T_CALLM("sync", []);
		// T_PRVAR(world);
		// // If we have an assigned owner state then ???
		// if(_world isEqualType "") then {

		// }

		// TODO: Probably don't even have order in here so we can remove it.
		// // Update order? Yes, action shouldn't do it, orders are owned by garrison
		// T_PRVAR(order);

		// if(_order isEqualType "") then {
		// 	CALLM(_order, "update", [_thisObject]);
		// };

		// TODO: What else does update even do? Actual simulation at some point, but for 
		// now the Action applyImmediate will be all we use.
	} ENDMETHOD;
ENDCLASS;