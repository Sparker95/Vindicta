asserts_Failed = 0;
asserts_Passed = 0;
test_Okay = true;

test_Scope = "Unknown";

// Initialize test functions
call compile preprocessFileLineNumbers "Tests/initTests.sqf";

diag_log "----------------------------------------------------------------------";
diag_log "|              I N I T I A L I Z I N G   O O P L I G H T              |";
diag_log "----------------------------------------------------------------------";

#include "..\common.h"

if (isNil "OOP_Light_initialized") then {
	OOP_Light_initialized = true;
	call compile preprocessFileLineNumbers "OOP_Light\OOP_Light_init.sqf";
};

diag_log "----------------------------------------------------------------------";
diag_log "|               I N I T I A L I Z I N G   M O D U L E S              |";
diag_log "----------------------------------------------------------------------";
{
	call compile preprocessFileLineNumbers "initModules.sqf";
}
except__
{
	diag_log format ["  EXCEPTION OCCURRED: %1", _exception];
	[_callstack, _exception] call test_DumpCallstack;
	throw _exception;
	exitcode__ 1; // Return non-zero to cause CI to report the error
};

diag_log "----------------------------------------------------------------------";
diag_log "|                  I N I T I A L I Z I N G   M A I N                 |";
diag_log "----------------------------------------------------------------------";
{
	call compile preprocessFileLineNumbers "initForSQFVM.sqf";
}
except__
{
	diag_log format ["  EXCEPTION OCCURRED: %1", _exception];
	[_callstack, _exception] call test_DumpCallstack;
	//throw _exception;
	exitcode__ 1; // Return non-zero to cause CI to report the error
};

diag_log "----------------------------------------------------------------------";
diag_log "|                      R U N N I N G   T E S T S                     |";
diag_log "----------------------------------------------------------------------";
tests_Failed = 0;
{
	_x params ["_name", '_code'];
	diag_log format ["- - Running test: %1 ...", _name];
	test_Scope = _name;
	test_Okay = true;
	//diag_log format ["TESTING %1 ...", _name];
	{
		private _rval = [] call _code;
		if !(isNil "_rval") then {
			[_name, _rval] call test_Assert;
		};
	}
	except__
	{
		diag_log format ["  --- TEST !FAILED! ---  [%1] EXCEPTION OCCURRED: %2", test_Scope, _exception];
		[_callstack, _exception] call test_DumpCallstack;
		test_Okay = false;
	};
	if(!test_Okay) then {
		tests_Failed = tests_Failed + 1;
	};
} forEach allTests;
diag_log "----------------------------------------------------------------------";
diag_log "|                               D O N E                              |";
diag_log "----------------------------------------------------------------------";

frac_failed = tests_Failed / count allTests;

bar = "";

pb_full = floor (70 * (1 - frac_failed));
pb_empty = 70 - pb_full;

if(pb_full > 0) then {
	for "_i" from 1 to pb_full do {
		bar = bar + "#";
	};
};

if(pb_empty > 0) then {
	for "_i" from 1 to pb_empty do {
		bar = bar + "-";
	};
};

diag_log "";
diag_log bar;
diag_log format["%1 out of %2 TESTS PASSED", count allTests - tests_Failed, count allTests];
diag_log format["%1 ASSERTS PASSED, %2 FAILED", asserts_Passed, asserts_Failed];

exitcode__ tests_Failed;
