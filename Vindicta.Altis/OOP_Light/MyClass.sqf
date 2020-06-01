#include "..\common.h"

/*
A template class.
*/

#define OOP_CLASS_NAME MyClass
CLASS("MyClass", "MyClassParent");

	VARIABLE("myVariable");
	STATIC_VARIABLE("myStaticVariable");

	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD(new)
		params [P_THISOBJECT];
		
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------

	METHOD(delete)
		params [P_THISOBJECT];

	ENDMETHOD;

ENDCLASS;

SETSV("MyClass", "myStaticVariable", 0);
