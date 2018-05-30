#include "Mutex\Mutex.hpp"

private _mutex = MUTEX_NEW();

_testScript = {
    params ["_mutex", "_threadID"];
    while {true} do {
	    MUTEX_LOCK(_mutex);
	    diag_log format ["Thread %1 locked!", _threadID];
	    sleep 0.1;
	    MUTEX_UNLOCK(_mutex);
	    sleep 0.1;
	    diag_log format ["Thread %1 unlocked!", _threadID];
	};
};

/*
private _i = 0;
while {_i < 10} do {
    [_mutex, _i] spawn _testScript;
    _i = _i + 1;
};
*/

gnum = 0;

_testScript2 = {
	params ["_mutex", "_threadID"];
	diag_log format ["Thread %1 started!", _threadID];
	private _i = 0;
	while {_i < 100} do {
		MUTEX_LOCK(_mutex);
		private _b = gnum;
		_b = _b + 1;
		//sleep 0.0001;
		gnum = _b;
		_i = _i + 1;
		MUTEX_UNLOCK(_mutex);
	};
	diag_log format ["Thread %1 terminated!", _threadID];
};

private _i = 0;
while {_i < 300} do {
    [_mutex, _i] spawn _testScript2;
    _i = _i + 1;
};