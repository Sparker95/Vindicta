test_Assert = {
	params ["_test", "_resultOrCode"];
	private _result = if(_resultOrCode isEqualType {}) then {
		call _resultOrCode
	} else {
		_resultOrCode
	};
	if !(_result) then {
		diag_log format [" ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~"];
		diag_log format ["  ------<<< TEST !FAILED! >>>------  [%1] %2", test_Scope, _test];
		diag_log format [" ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~"];
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
		diag_log format [" ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~"];
		diag_log format ["  ------<<< TEST !FAILED! >>>------  [%1] %2", test_Scope, _test];
		diag_log format [" ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~"];
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
	diag_log "    CALLSTACK:";
	{
			_x params ["_namespace", "_scope", "_callstack", "_line", "_col", "_file", "_err"];
			private _trimpos = (_file find "Vindicta.Altis") + count "Vindicta.Altis" + 1;
			private _relFile = _file select [_trimpos];
			diag_log format ["    (%4/%5) %3 line %1", _line, _col, _relFile, _forEachIndex+1, count _cs, _ex, _namespace, _scope, _callstack, _err];
	} forEach _cs;
	diag_log "";
	diag_log "";
};