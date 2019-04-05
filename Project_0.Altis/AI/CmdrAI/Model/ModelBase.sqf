#include "..\..\..\OOP_Light\OOP_Light.h"

// Model of a Real Object. This can either be the Actual Model or the Sim Model.
// The Actual Model represents the Real Object as it currently is. A Sim Model
// is a copy that can be simulated.
CLASS("ModelBase", "RefCounted")
	// Unique Id of this Model, it is identical between Actual and Sim Models 
	// that represent the same Real Object.
	VARIABLE("id");
	// Optional object ref to the Real Object this Model represents. 
	// If set to objNull then this is presumed to be a Sim Model.
	VARIABLE("realObject");
	// World Model that owns this Object Model
	VARIABLE("ownerState");

	METHOD("new") {
		params [P_THISOBJECT, P_STRING("_ownerState"), P_STRING("_realObject")];
		T_SETV("id", -1);
		T_SETV("ownerState", _ownerState);

		if(_realObject isEqualTo "") then {
			T_SETV("realObject", objNull);
			ASSERT_MSG(GETV(_ownerState, "isSim"), "State must be sim if you aren't setting realObject");
		} else {
			T_SETV("realObject", _realObject);
			ASSERT_MSG(!GETV(_ownerState, "isSim"), "State must NOT be sim if you are setting realObject");
		};
	} ENDMETHOD;

	METHOD("setId") {
		params [P_THISOBJECT, P_NUMBER("_id")];
		T_SETV("id", _id);
	} ENDMETHOD;
	
	METHOD("sync") {
		params [P_THISOBJECT];
		OOP_ERROR_0("sync method must be implemented when deriving from ModelBase");
		throw "Not implemented";
	} ENDMETHOD;

	METHOD("update") {
		params [P_THISOBJECT];
		T_CALLM("sync", []);
		// T_PRVAR(ownerState);
		// // If we have an assigned owner state then ???
		// if(_ownerState isEqualType "") then {

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