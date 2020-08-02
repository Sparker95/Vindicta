

#include "..\common.h"

// _benchObject - editor-placed bench object
params ["_benchObject"];

// Create a group for a unit
private _args = [WEST, 0]; // Side, group type
private _newGroup = NEW("Group", _args);

// Create two new units
private _args = [tNATO, T_INF, T_INF_LMG, -1, _newGroup];
private _unit_0 = NEW("Unit", _args);
private _unit_1 = NEW("Unit", _args);
//private _unit_2 = NEW("Unit", _args);

// Spawn the new units
private _args = [ /*(getPos player)*/ [2414.09,1147.49, 0] vectorAdd [2, 2, 0], random 360];
CALLM(_unit_0, "spawn", _args);
CALLM(_unit_1, "spawn", _args);
//CALLM(_unit_2, "spawn", _args);

// Initialize the bench object
private _bench = NEW("AnimObjectBench", [_benchObject]);

// Make the unit sit on the bench
/*
private _args = [_bench, 0];
CALLM(_unit_0, "doSitOnBench", _args);

private _args = [_bench, 1];
CALLM(_unit_1, "doSitOnBench", _args);
*/

// Add the goals to the units to sit on the bench

private _args = [_unit_0, _bench, 10];
private _goal_0 = NEW("GoalUnitInteractAnimObject", _args);
CALLM(_unit_0, "setGoal", [_goal_0]);
CALLM(_goal_0, "setAutonomous", [1]);


sleep 4;

private _args = [_unit_1, _bench, 40];
private _goal_1 = NEW("GoalUnitInteractAnimObject", _args);
CALLM(_unit_1, "setGoal", [_goal_1]);
CALLM(_goal_1, "setAutonomous", [1]);


//sleep 2;
/*
private _args = [_unit_2, _bench, 40];
private _goal_2 = NEW("GoalUnitSitOnBench", _args);
CALLM(_goal_2, "setAutonomous", [1]);
*/
