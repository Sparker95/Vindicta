#define OOP_ASSERT
#include "..\common.h"

#ifdef _SQF_VM
call compile preprocessFileLineNumbers "Tests\initTests.sqf";
#endif

call compile preprocessFileLineNumbers "OOP_Light\OOP_Light_init.sqf";

#define OOP_CLASS_NAME ClassA
CLASS("ClassA", "")

	VARIABLE("a");
	VARIABLE("b");
	VARIABLE("cStr");

	METHOD(new)
		params [P_THISOBJECT];
		diag_log "NEW A";
		T_SETV("a", 123);
		T_SETV("b", 456);
		T_SETV("cStr", "test string");
	ENDMETHOD;

ENDCLASS;

#define OOP_CLASS_NAME ClassB
CLASS("ClassB", "")

	VARIABLE("a");
	VARIABLE("bObj");
	VARIABLE("bArrayNum");
	VARIABLE("cArrayObj");
	//VARIABLE("me");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_otherObj")];
		diag_log "NEW B";
		
		T_SETV("a", 123);

		private _b = NEW("ClassA", []);
		T_SETV("bObj", _b);

		private _t = [123, 12, 11, 2];
		T_SETV("bArrayNum", _t);

		private _array = [];
		_array pushBack _b;
		_array pushBack _b;
		private _i = 0;
		while {_i < 2} do {
			private _obj = NEW("ClassA", []);
			_array pushBack _obj;
			_i = _i + 1;
		};
		T_SETV("cArrayObj", _array);

		//T_SETV("me", _thisObject);
	ENDMETHOD;

ENDCLASS;

private _testObj = NEW("ClassB", []);

[_testObj, 0] call OOP_dumpAllVariablesRecursive;


diag_log "";
diag_log "";
diag_log "";
diag_log "";

#define OOP_CLASS_NAME Bot
CLASS("Bot", "")
	VARIABLE("AI");
	VARIABLE("health");
	VARIABLE("numArray");

	METHOD(new)
		params [P_THISOBJECT];

		private _ai = NEW("AIBot", [_thisObject]);
		T_SETV("AI", _ai);

		private _array = [0, 1, 2, "3"];
		T_SETV("numArray", _array);
	ENDMETHOD;

ENDCLASS;

#define OOP_CLASS_NAME AIBot
CLASS("AIBot", "")

	VARIABLE("bot");
	VARIABLE("sameBot");
	VARIABLE("target");
	VARIABLE("state");
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_bot")];
		T_SETV("bot", _bot);
		T_SETV("sameBot", _bot);
	ENDMETHOD;

ENDCLASS;

private _bot0 = NEW("bot", []);
[_bot0, 3] call OOP_dumpAllVariablesRecursive;


// Now test the JSON dump
diag_log "";
diag_log "";
diag_log "";
private _objA = NEW("ClassA", []);
[_bot0] call OOP_objectCrashDump;