#include "..\common.h"

/*
Class: Storable
Base class for classes which support saving and loading features
*/

#define OOP_CLASS_NAME Storable
CLASS("Storable", "")

	// - - - - VIRTUAL METHODS - - - - -
	// These might be overriden to customize saving of objects

	// Must return true on success
	public virtual METHOD(preSerialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
		
		// Call method of all base classes
		//CALLCM(... , _thisObject, "preSerialize", [_storage]);

		true
	ENDMETHOD;

	// Returns an array, does not have to be a deep copy
	// Must return nil on failure
	// By default it serializes variables with the ATTR_SAVE or ATTR_SAVE_VER attribute
	public virtual METHOD(serializeForStorage)
		params [P_THISOBJECT];
		SERIALIZE_SAVE(_thisObject);
	ENDMETHOD;

	// Must return true on success
	public virtual METHOD(postSerialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
		
		// Call method of all base classes
		//CALLCM(... , _thisObject, "postSerialize", [_storage]);
		
		true
	ENDMETHOD;

	// These methods must return true on success
	public virtual METHOD(preDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage"), P_NUMBER("_version")];

		// Call method of all base classes
		//CALLCM(... , _thisObject, "preDeserialize", [_storage]);

		true
	ENDMETHOD;

	// Must deserialize from an array into this object
	// By default it deserializes variables with the ATTR_SAVE or ATTR_SAVE_VER attribute
	public virtual METHOD(deserializeFromStorage)
		params [P_THISOBJECT, P_ARRAY("_serial"), P_NUMBER("_version")];
		DESERIALIZE_SAVE_VER(_thisObject, _serial, _version)
	ENDMETHOD;

	public virtual METHOD(postDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage"), P_NUMBER("_version")];

		// Call method of all base classes
		//CALLCM(... , _thisObject, "postDeserialize", [_storage]);

		true
	ENDMETHOD;

	public STATIC_METHOD(saveStaticVariables)
		params [P_THISCLASS, P_OOP_OBJECT("_storage")];
		OOP_ERROR_1("saveStaticVariables is not implemented for %1", _thisClass);
	ENDMETHOD;

	public STATIC_METHOD(loadStaticVariables)
		params [P_THISCLASS, P_OOP_OBJECT("_storage")];
		OOP_ERROR_1("saveStaticVariables is not implemented for %1", _thisClass);
	ENDMETHOD;

ENDCLASS;