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
	/* virtual */ METHOD(preSerialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
		
		// Call method of all base classes
		//CALL_CLASS_METHOD(... , _thisObject, "preSerialize", [_storage]);

		true
	ENDMETHOD;

	// Returns an array, does not have to be a deep copy
	// Must return nil on failure
	// By default it serializes variables with the ATTR_SAVE or ATTR_SAVE_VER attribute
	/* virtual */ METHOD(serializeForStorage)
		params [P_THISOBJECT];
		SERIALIZE_SAVE(_thisObject);
	ENDMETHOD;

	// Must return true on success
	/* virtual */ METHOD(postSerialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
		
		// Call method of all base classes
		//CALL_CLASS_METHOD(... , _thisObject, "postSerialize", [_storage]);
		
		true
	ENDMETHOD;

	// These methods must return true on success
	/* virtual */ METHOD(preDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage"), P_NUMBER("_version")];

		// Call method of all base classes
		//CALL_CLASS_METHOD(... , _thisObject, "preDeserialize", [_storage]);

		true
	ENDMETHOD;

	// Must deserialize from an array into this object
	// By default it deserializes variables with the ATTR_SAVE or ATTR_SAVE_VER attribute
	/* virtual */ METHOD(deserializeFromStorage)
		params [P_THISOBJECT, P_ARRAY("_serial"), P_NUMBER("_version")];
		DESERIALIZE_SAVE_VER(_thisObject, _serial, _version)
	ENDMETHOD;

	/* virtual */ METHOD(postDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage"), P_NUMBER("_version")];

		// Call method of all base classes
		//CALL_CLASS_METHOD(... , _thisObject, "postDeserialize", [_storage]);

		true
	ENDMETHOD;

	/* virtual */ STATIC_METHOD(saveStaticVariables)
		params [P_THISCLASS, P_OOP_OBJECT("_storage")];
		OOP_ERROR_1("saveStaticVariables is not implemented for %1", _thisClass);
	ENDMETHOD;

	/* virtual */ STATIC_METHOD(loadStaticVariables)
		params [P_THISCLASS, P_OOP_OBJECT("_storage")];
		OOP_ERROR_1("saveStaticVariables is not implemented for %1", _thisClass);
	ENDMETHOD;

ENDCLASS;