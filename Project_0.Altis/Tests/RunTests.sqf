asserts_Failed = 0;
asserts_Passed = 0;
test_Okay = true;

test_Scope = "Unknown";
test_Assert = {
	params ["_test", "_resultOrCode"];
	private _result = if(_resultOrCode isEqualType {}) then {
		call _resultOrCode
	} else {
		_resultOrCode
	};
	if !(_result) then {
		diag_log format ["  --- TEST !FAILED! ---  [%1] %2", test_Scope, _test];
		asserts_Failed = asserts_Failed + 1;
		test_Okay = false;
	} else {
		asserts_Passed = asserts_Passed + 1;
	};
	nil
};
test_Assert_Throws = {
	params ["_test", "_code", "_expected"];
	private _passed = false;
	{
		call _code;
		diag_log format ["%1: expected exception '%2' but no exception occurred", _test, _expected];
	}
	except__
	{
		if(_exception isEqualTo _expected) then {
			_passed = true;
		} else {
			diag_log format ["%1: exception got '%2', expected '%3'", _test, _exception, _expected];
		}
	};
	if(_passed) then {
		asserts_Passed = asserts_Passed + 1;
	} else {
		diag_log format ["  --- TEST !FAILED! ---  [%1] %2", test_Scope, _test];
		asserts_Failed = asserts_Failed + 1;
		test_Okay = false;
	};
	nil
};

allTests = [];

test_AddTest = {
	allTests pushBack _this;
};

test_DumpCallstack = {
	params ["_cs", "_ex"];
	{
			_x params ["_namespace", "_scope", "_callstack", "_line", "_col", "_file", "_err"];
			//if(_forEachIndex == 0) then {
			diag_log format ["          [ERR][L%1|C%2|%3] %4/%5: %6 (%7 %8 %9 %10)", _line, _col, _file, _forEachIndex+1, count _cs, _ex, _namespace, _scope, _callstack, _err];
			//} else {
			// diag_log format ["          %1(%2,%3)", _file, _line, _col];
			//};
	} forEach _cs;
};

diag_log "----------------------------------------------------------------------";
diag_log "|              I N I T I A L I Z I N G   O O P L I G H T              |";
diag_log "----------------------------------------------------------------------";

#include "..\OOP_Light\OOP_Light.h"

if (isNil "OOP_Light_initialized") then {
	OOP_Light_initialized = true;
	call compile preprocessFileLineNumbers "OOP_Light\OOP_Light_init.sqf"; 
};

diag_log "----------------------------------------------------------------------";
diag_log "|               I N I T I A L I Z I N G   C L A S S E S              |";
diag_log "----------------------------------------------------------------------";
{
	call compile preprocessFileLineNumbers "initModules.sqf";
}
except__
{
	diag_log format ["  EXCEPTION OCCURRED: %1", _exception];
	[_callstack, _exception] call test_DumpCallstack;
	//throw _exception;
};

diag_log "----------------------------------------------------------------------";
diag_log "|               I N I T I A L I Z I N G   G L O B A L S              |";
diag_log "----------------------------------------------------------------------";
{
	call compile preprocessFileLineNumbers "initGlobals.sqf";
}
except__
{
	diag_log format ["  EXCEPTION OCCURRED: %1", _exception];
	[_callstack, _exception] call test_DumpCallstack;
	//throw _exception;
};

diag_log "----------------------------------------------------------------------";
diag_log "|                      R U N N I N G   T E S T S                     |";
diag_log "----------------------------------------------------------------------";
tests_Failed = 0;
{
	_x params ["_name", '_code'];
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

exit__ tests_Failed;
