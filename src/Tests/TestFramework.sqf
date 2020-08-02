
Test_wrapper_fn = {
	params ["_wrapped"];

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
		} else {
			diag_log format ["  --- TEST  PASSED  ---  [%1] %2", test_Scope, _test];
		};
	};

	allTests = [];

	test_AddTest = {
		allTests pushBack _this;
	};

	diag_log "----------------------------------------------------------------------";
	diag_log "|                   C O L L E C T I N G   T E S T S                  |";
	diag_log "----------------------------------------------------------------------";
	[] call _wrapped;
	// CALL_COMPILE_COMMON("initModules.sqf");

	// diag_log "----------------------------------------------------------------------";
	// diag_log "|               I N I T I A L I Z I N G   G L O B A L S              |";
	// diag_log "----------------------------------------------------------------------";
	// CALL_COMPILE_COMMON("initGlobals.sqf");

	diag_log "----------------------------------------------------------------------";
	diag_log "|                      R U N N I N G   T E S T S                     |";
	diag_log "----------------------------------------------------------------------";
	{
		_x params ["_name", '_code'];
		test_Scope = _name;
		diag_log format ["TESTING %1 ...", _name];
		private _rval = [] call _code;
		if !(isNil "_rval") then {
			[_name, _rval] call test_Assert;
		};
	} forEach allTests;

};