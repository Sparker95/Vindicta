#define OOP_DEBUG
#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Threads.rpt"
#include "..\common.h"

#define pr private

#define OOP_CLASS_NAME DummyLoad
CLASS("DummyLoad", "")

	VARIABLE("logDeltaTime");
	VARIABLE("lastProcessTime");

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("logDeltaTime", false);
		T_SETV("lastProcessTime", diag_tickTime);
	ENDMETHOD;

	public METHOD(process)
		params [P_THISOBJECT];

		_a = [];
		_a resize 1024;
		_a apply {sqrt abs random 1};

		if (T_GETV("logDeltaTime")) then {
			pr _delta = diag_tickTime - T_GETV("lastProcessTime");
			OOP_INFO_1("Process interval: %1", _delta);
		};

		T_SETV("lastProcessTime", diag_tickTime);

		0

	ENDMETHOD;

ENDCLASS;

pr _args = ["TestUnscheduledMsgLoop", 100, 0, true];
if (!isNil "gTestMsgLoop") then {
	DELETE(gTestMsgLoop);
};

gTestMsgLoop = NEW("MessageLoop", _args);

CALLM4(gTestMsgLoop, "addProcessCategoryUnscheduled", "onePerSecond", 1, 3, 3);

pr _obj = NEW("DummyLoad", []);
SETV(_obj, "logDeltaTime", true);
CALLM2(gTestMsgLoop, "addProcessCategoryObject", "onePerSecond", _obj);

for "_i" from 0 to 4 do {
	pr _obj = NEW("DummyLoad", []);
	CALLM2(gTestMsgLoop, "addProcessCategoryObject", "onePerSecond", _obj);
};