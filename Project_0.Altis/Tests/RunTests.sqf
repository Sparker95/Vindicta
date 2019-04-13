#include "..\OOP_Light\OOP_Light.h"


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
	};
	//  else {
	// 	//diag_log format ["  --- TEST  PASSED  ---  [%1] %2", test_Scope, _test];
	// 	nil
	// };
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
			diag_log format ["          [ERR][L%1|C%2|%3] %4/%5: %6", _line, _col, _file, _forEachIndex+1, count _cs, _ex];
			//} else {
			// diag_log format ["          %1(%2,%3)", _file, _line, _col];
			//};
	} forEach _cs;
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
	throw _exception;
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
	throw _exception;
};

diag_log "----------------------------------------------------------------------";
diag_log "|                      R U N N I N G   T E S T S                     |";
diag_log "----------------------------------------------------------------------";
{
	_x params ["_name", '_code'];
	test_Scope = _name;
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
	}
} forEach allTests;
diag_log "----------------------------------------------------------------------";
diag_log "|                               D O N E                              |";
diag_log "----------------------------------------------------------------------";