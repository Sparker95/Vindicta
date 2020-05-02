
#include "..\common.h"
/*
TEst the goal for AI to play repair vehicle animation
*/

// _benchObject - editor-placed bench object
params ["_vehicleObject"];

// Create a group for a unit
private _args = [WEST, 0]; // Side, group type
private _newGroup = NEW("Group", _args);

// Create new units
private _args = [tNATO, T_INF, T_INF_LMG, -1, _newGroup];
private _unit_0 = NEW("Unit", _args);
private _unit_1 = NEW("Unit", _args);
private _unit_2 = NEW("Unit", _args);
private _unit_3 = NEW("Unit", _args);
private _unit_4 = NEW("Unit", _args);
private _unit_5 = NEW("Unit", _args);
//private _unit_2 = NEW("Unit", _args);

// Spawn the new units
private _args = [ [2414.09,1147.49, 0] /*(getPos player)*/ /*[2414.09,1147.49, 0]*/ vectorAdd [2, 2, 0], random 360];
CALLM(_unit_0, "spawn", _args);
CALLM(_unit_1, "spawn", _args);
CALLM(_unit_2, "spawn", _args);
CALLM(_unit_3, "spawn", _args);
CALLM(_unit_4, "spawn", _args);
CALLM(_unit_5, "spawn", _args);
//CALLM(_unit_2, "spawn", _args);

// Initialize the animObject
private _vehicle = NEW("AnimObjectGroundVehicle", [_vehicleObject]);


// Add the goals to the units
private _args = [_unit_0, _vehicle, 30];
private _goal_0 = NEW("GoalUnitInteractAnimObject", _args);
CALLM(_unit_0, "setGoal", [_goal_0]);
CALLM(_goal_0, "setAutonomous", [1]);

private _args = [_unit_1, _vehicle, 30];
private _goal_1 = NEW("GoalUnitInteractAnimObject", _args);
CALLM(_unit_1, "setGoal", [_goal_1]);
CALLM(_goal_1, "setAutonomous", [1]);

private _args = [_unit_2, _vehicle, 30];
private _goal_2 = NEW("GoalUnitInteractAnimObject", _args);
CALLM(_unit_2, "setGoal", [_goal_2]);
CALLM(_goal_2, "setAutonomous", [1]);

private _args = [_unit_3, _vehicle, 30];
private _goal_3 = NEW("GoalUnitInteractAnimObject", _args);
CALLM(_unit_3, "setGoal", [_goal_3]);
CALLM(_goal_3, "setAutonomous", [1]);

private _args = [_unit_4, _vehicle, 30];
private _goal_4 = NEW("GoalUnitInteractAnimObject", _args);
CALLM(_unit_4, "setGoal", [_goal_4]);
CALLM(_goal_4, "setAutonomous", [1]);

private _args = [_unit_5, _vehicle, 30];
private _goal_5 = NEW("GoalUnitInteractAnimObject", _args);
CALLM(_unit_5, "setGoal", [_goal_5]);
CALLM(_goal_5, "setAutonomous", [1]);
