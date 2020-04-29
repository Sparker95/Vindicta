#define OOP_DEBUG
#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Threads.rpt"
#include "..\OOP_Light\OOP_Light.h"

CLASS("DummyLoad", "")

	METHOD("process") {

	} ENDMETHOD;

ENDCLASS;

pr _args = ["TestUnscheduledMsgLoop", 100, 0, true];
if (!isNil "gTestMsgLoop") then {
	DELETE(gTestMsgLoop);
};

gTestMsgLoop = NEW("MessageLoop", _args);

CALLM4(gTestMsgLoop, "addProcessCategory", "onePerSecond", 0, 1, 1);

for "_i" from 0 to 128 do {
	pr _obj = NEW("DummyLoad");
	
};