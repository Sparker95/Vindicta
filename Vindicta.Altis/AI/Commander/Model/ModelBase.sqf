#include "..\common.hpp"

/*
Class: ModelBase

Base class for model classes.
Model of a Real Object. This can either be the Actual Model or the Sim Model.
The Actual Model represents the Real Object as it currently is. A Sim Model
is a copy that can be simulated.

Parent: <RefCounted>
*/
#define OOP_CLASS_NAME ModelBase
CLASS("ModelBase", ["RefCounted" ARG "Storable"])
	// Variable: id
	// Unique Id of this Model, it is identical between Actual and Sim Models 
	// that represent the same Real Object.
	VARIABLE("id");

	// Variable: actual
	// Optional ref to the Real Object this Model represents. 
	// If set to objNull then this is presumed to be a Sim Model.
	VARIABLE("actual");

	// Variable: world
	// World Model that owns this Object Model
	VARIABLE("world");

	VARIABLE("label");

	/*
	Constructor: new
	See implementing classes for specific constructors.
	
	Parameters:
		_world - <WorldModel>, world model that owns this model object.
		_actual - Any, the real object this model represents.
	*/
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_world"), P_DYNAMIC("_actual")];
		ASSERT_OBJECT_CLASS(_world, "WorldModel");

		T_SETV("id", MODEL_HANDLE_INVALID);
		T_SETV("world", _world);
		T_SETV("actual", _actual);
		T_SETV("label", str _actual);
	ENDMETHOD;

	/*
	Method: isActual
	Is this model the real world model, or a sim one?
	
	Returns: Boolean, true if this is a real model, false if it is a sim one.
	*/
	METHOD(isActual)
		params [P_THISOBJECT];
		CALLM0(T_GETV("world"), "isReal");
	ENDMETHOD;

	/*
	Method: (virtual) simCopy
	Create a sim copy of this object.
	Must be implemented by derived classes.

	Parameters:
		_targetWorldModel - <WorldModel>, world model to own the newly created object.
	
	Returns: <ModelBase>, concrete type is same as this object type.
	*/
	/* virtual */ METHOD(simCopy)
		params [P_THISOBJECT, P_OOP_OBJECT("_targetWorldModel")];
		FAILURE("simCopy method must be implemented when deriving from ModelBase");
	ENDMETHOD;

	// METHOD(setId)
	// 	params [P_THISOBJECT, P_NUMBER("_id")];
	// 	T_SETV("id", _id);
	// ENDMETHOD;
	
	/*
	Method: (virtual) sync
	Sync this model from its actual object, if it is a real model. 
	Must be implemented by derived classes.
	*/
	/* virtual */ METHOD(sync)
		params [P_THISOBJECT];
		FAILURE("sync method must be implemented when deriving from ModelBase");
	ENDMETHOD;

	/*
	Method: update
	Not used?
	*/
	METHOD(update)
		params [P_THISOBJECT];
		T_CALLM("sync", []);
		// private _world = T_GETV("world");
		// // If we have an assigned owner state then ???
		// if(_world isEqualType "") then {

		// }

		// TODO: Probably don't even have order in here so we can remove it.
		// // Update order? Yes, action shouldn't do it, orders are owned by garrison
		// private _order = T_GETV("order");

		// if(_order isEqualType "") then {
		// 	CALLM(_order, "update", [_thisObject]);
		// };

		// TODO: What else does update even do? Actual simulation at some point, but for 
		// now the Action applyImmediate will be all we use.
	ENDMETHOD;

	// - - - - - STORAGE - - - - -

	// Serialize all variables of this and all parent and derived classes
	/* override */ METHOD(serializeForStorage)
		params [P_THISOBJECT];
		SERIALIZE_ALL(_thisObject);
	ENDMETHOD;

	/* override */ METHOD(deserializeFromStorage)
		params [P_THISOBJECT, P_ARRAY("_serial")];
		DESERIALIZE_ALL(_thisObject, _serial);
		true
	ENDMETHOD;

ENDCLASS;