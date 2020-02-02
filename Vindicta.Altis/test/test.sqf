// Cmdr planning constants
#define CMDR_PLANNING_PRIORITY_HIGH 0
#define CMDR_PLANNING_PRIORITY_NORMAL 1
#define CMDR_PLANNING_PRIORITY_LOW 2

// PRIME NUMBERS > 1 only
//#ifdef RELEASE_BUILD
// #define CMDR_PLANNING_RATIO_HIGH 3
// #define CMDR_PLANNING_RATIO_NORMAL 11
// #define CMDR_PLANNING_RATIO_LOW 31
// #else
#define CMDR_PLANNING_RATIO_HIGH 2
#define CMDR_PLANNING_RATIO_NORMAL 5
#define CMDR_PLANNING_RATIO_LOW 11
//#endif

private _plans = [0,0,0,0];
for "_planningCycle" from 0 to 1000 do {
	private _priority = 0;
	switch true do {
		case (round (_planningCycle mod CMDR_PLANNING_RATIO_HIGH) == 0): { _priority = CMDR_PLANNING_PRIORITY_HIGH; };
		case (round (_planningCycle mod CMDR_PLANNING_RATIO_NORMAL) == 0): { _priority = CMDR_PLANNING_PRIORITY_NORMAL; };
		case (round (_planningCycle mod CMDR_PLANNING_RATIO_LOW) == 0): { _priority = CMDR_PLANNING_PRIORITY_LOW; };
		default { _priority = 3; };
	};
	
	_plans set [_priority, (_plans#_priority) + 1];
};

diag_log str _plans;

diag_log str (_plans apply { _x / 1000 });

diag_log str (_plans apply { 10000 / _x });
