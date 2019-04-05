diag_log "in test.hpp: checking test_init";
if(isNil "test_init") then {
	diag_log "test_init is nil, calling test.sqf";
	call compile preprocessFileLineNumbers "test\test.sqf"; 
};
