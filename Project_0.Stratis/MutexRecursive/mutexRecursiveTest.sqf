#include "MutexRecursive.hpp"

0 spawn {
	scriptName "testScript";
	_m = MUTEX_NEW();
	MUTEX_LOCK(_m);
	diag_log format ["Locked mutex: %1", _m];
	MUTEX_LOCK(_m);
	diag_log format ["Locked mutex twice: %1", _m];
	MUTEX_UNLOCK(_m);
	diag_log format ["Unlocked mutex: %1", _m];
	MUTEX_UNLOCK(_m);
	diag_log format ["Unlocked mutex twice: %1", _m];
};


// Tests the mutex
m_sum = 0;
m_mutex = MUTEX_NEW();

_inc = {
	scriptName "_inc";
	
	params ["_amountOfSums"];
	
	for "_i" from 1 to _amountOfSums do {
		MUTEX_LOCK(m_mutex);
		MUTEX_LOCK(m_mutex);
		
		private _temp = m_sum;
		uisleep 0.001;
		_temp = _temp + 1;
		m_sum = _temp;
		
		MUTEX_UNLOCK(m_mutex);
		//MUTEX_UNLOCK(m_mutex);
		//diag_log format ["Unlocked twice mutex: %1", m_mutex];
	};
	
	waitUntil {sleep 1; false};
};

_num = 10;
[_num] spawn _inc;
[_num] spawn _inc;
[_num] spawn _inc;
[_num] spawn _inc;
[_num] spawn _inc;
[_num] spawn _inc;
[_num] spawn _inc;
[_num] spawn _inc;
[_num] spawn _inc;
[_num] spawn _inc;
