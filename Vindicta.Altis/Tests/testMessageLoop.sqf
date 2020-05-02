#include "..\common.h"

#define pr private


private _msgLoopTest = NEW("MessageLoop", []);
CALLM1(_msgLoopTest, "setName", "Process test");

// Add process categories
CALLM(_msgLoopTest, "addProcessCategory", ["high" ARG 4 ARG 0.3 ARG 10]);
CALLM(_msgLoopTest, "addProcessCategory", ["low" ARG 1 ARG 0.3 ARG 600]);

// Add dummy objects
for "_i" from 0 to 30 do {
	pr _testObj = NEW("DebugPrinter", ["HIGH" ARG _msgLoopTest]);
	CALLM(_msgLoopTest, "addProcessCategoryObject", ["high" ARG _testObj]);
};

// Add dummy objects
for "_i" from 0 to 10 do {
	pr _testObj = NEW("DebugPrinter", ["LOW" ARG _msgLoopTest]);
	CALLM(_msgLoopTest, "addProcessCategoryObject", ["low" ARG _testObj]);
};