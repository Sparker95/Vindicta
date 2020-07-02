#include "common.h"

// Initialize test functions
//call compile preprocessFileLineNumbers "Tests\initTests.sqf";

// Init OOP
OOP_Light_initialized = true;
call compile preprocessFileLineNumbers "OOP_Light\OOP_Light_init.sqf";

// Init dependent classes
call compile preprocessFileLineNumbers "SaveSystem\initClasses.sqf";
call compile preprocessFileLineNumbers "AI\AI\GOAP_Agent.sqf";
call compile preprocessFileLineNumbers "MessageReceiver\MessageReceiver.sqf";
call compile preprocessFileLineNumbers "MessageReceiverEx\MessageReceiverEx.sqf";
call compile preprocessFileLineNumbers "AI\Misc\databaseFunctions.sqf";
call compile preprocessFileLineNumbers "AI\Misc\repairFunctions.sqf";
call compile preprocessFileLineNumbers "AI\Misc\testFunctions.sqf";
call compile preprocessFileLineNumbers "AI\WorldState\WorldState.sqf";
call compile preprocessFileLineNumbers "AI\WorldFact\WorldFact.sqf";
call compile preprocessFileLineNumbers "AI\Misc\initFunctions.sqf";
call compile preprocessFileLineNumbers "AI\Action\Action.sqf";
call compile preprocessFileLineNumbers "AI\Sensor\Sensor.sqf";
call compile preprocessFileLineNumbers "AI\SensorStimulatable\SensorStimulatable.sqf";
call compile preprocessFileLineNumbers "AI\ActionComposite\ActionComposite.sqf";
call compile preprocessFileLineNumbers "AI\ActionCompositeParallel\ActionCompositeParallel.sqf";
call compile preprocessFileLineNumbers "AI\ActionCompositeSerial\ActionCompositeSerial.sqf";
call compile preprocessFileLineNumbers "AI\Goal\Goal.sqf";
call compile preprocessFileLineNumbers "AI\AI\AI.sqf";
call compile preprocessFileLineNumbers "AI\AI\AI_GOAP.sqf";
call compile preprocessFileLineNumbers "AI\Garrison\initClasses.sqf";
call compile preprocessFileLineNumbers "AI\Unit\initClasses.sqf";
//call compile preprocessFileLineNumbers "AI\initClasses.sqf";

/*
A script to test how AStar works
Author: Sparker 08.12.2018
*/

#define pr private

// Some garrison tests
call compile preprocessFileLineNumbers "AI\AI\tests\garrison.sqf";

// Getting into vehicle
call compile preprocessFileLineNumbers "AI\AI\tests\infantryGetInVehicle.sqf";

// Driver follow leader
call compile preprocessFileLineNumbers "AI\AI\tests\driverFollowLeader.sqf";

// Civilian panic
call compile preprocessFileLineNumbers "AI\AI\tests\civilianPanic.sqf";