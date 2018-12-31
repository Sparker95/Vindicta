{#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Mutex\mutexTest.sqf"
#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Mutex\Mutex.hpp"








































#line 1 "C:\Users\s-tron\Documents\Arma 3 - Other Profiles\Sparker\missions\Project_0\Project_0.Stratis\Mutex\mutexTest.sqf"


_m = [scriptNull, 0];
waitUntil { 	private _lockAquired = false; 	isNil { 		private _s = (_m select 0); 		if( (_s isEqualTo _thisScript) || (_s isEqualTo scriptNull) ) then { 			_m set [0, _thisScript]; 			_m set [1, (_m select 1) + 1]; 			_lockAquired = true; 		}; 	}; 	_lockAquired };;
diag_log format ["Locked mutex: %1", _m];
waitUntil { 	private _lockAquired = false; 	isNil { 		private _s = (_m select 0); 		if( (_s isEqualTo _thisScript) || (_s isEqualTo scriptNull) ) then { 			_m set [0, _thisScript]; 			_m set [1, (_m select 1) + 1]; 			_lockAquired = true; 		}; 	}; 	_lockAquired };;
diag_log format ["Locked mutex twice: %1", _m];
isNil { 	_m params ["_hScript", "_lockCount"]; 	if (_hScript isEqualTo _thisScript) then { 		if (_lockCount == 1) then { 			_m set [0, scriptNull]; 			_m set [1, 0]; 		} else { 			_m set [1, (_m select 1) - 1]; 		}; 	} else { 		diag_log format ["ERROR: error unlocking mutex %1", _m]; 	}; };;
diag_log format ["Unlocked mutex: %1", _m];
isNil { 	_m params ["_hScript", "_lockCount"]; 	if (_hScript isEqualTo _thisScript) then { 		if (_lockCount == 1) then { 			_m set [0, scriptNull]; 			_m set [1, 0]; 		} else { 			_m set [1, (_m select 1) - 1]; 		}; 	} else { 		diag_log format ["ERROR: error unlocking mutex %1", _m]; 	}; };;
diag_log format ["Unlocked mutex twice: %1", _m];




































}