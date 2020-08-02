#include "common.h"

// Initialize test functions
//CALL_COMPILE_COMMON("Tests\initTests.sqf");

// Init OOP
OOP_Light_initialized = true;
CALL_COMPILE_COMMON("OOP_Light\OOP_Light_init.sqf");

// Init dependent classes
CALL_COMPILE_COMMON("SaveSystem\initClasses.sqf");
CALL_COMPILE_COMMON("AI\AI\GOAP_Agent.sqf");
CALL_COMPILE_COMMON("MessageReceiver\MessageReceiver.sqf");
CALL_COMPILE_COMMON("MessageReceiverEx\MessageReceiverEx.sqf");
CALL_COMPILE_COMMON("AI\Misc\databaseFunctions.sqf");
CALL_COMPILE_COMMON("AI\Misc\repairFunctions.sqf");
CALL_COMPILE_COMMON("AI\Misc\testFunctions.sqf");
CALL_COMPILE_COMMON("AI\WorldState\WorldState.sqf");
CALL_COMPILE_COMMON("AI\WorldFact\WorldFact.sqf");
CALL_COMPILE_COMMON("AI\Misc\initFunctions.sqf");
CALL_COMPILE_COMMON("AI\Action\Action.sqf");
CALL_COMPILE_COMMON("AI\Sensor\Sensor.sqf");
CALL_COMPILE_COMMON("AI\SensorStimulatable\SensorStimulatable.sqf");
CALL_COMPILE_COMMON("AI\ActionComposite\ActionComposite.sqf");
CALL_COMPILE_COMMON("AI\ActionCompositeParallel\ActionCompositeParallel.sqf");
CALL_COMPILE_COMMON("AI\ActionCompositeSerial\ActionCompositeSerial.sqf");
CALL_COMPILE_COMMON("AI\Goal\Goal.sqf");
CALL_COMPILE_COMMON("AI\AI\AI.sqf");
CALL_COMPILE_COMMON("AI\AI\AI_GOAP.sqf");
CALL_COMPILE_COMMON("AI\Garrison\initClasses.sqf");
CALL_COMPILE_COMMON("AI\Unit\initClasses.sqf");
//CALL_COMPILE_COMMON("AI\initClasses.sqf");

/*
A script to test how AStar works
Author: Sparker 08.12.2018
*/

#define pr private

// Some garrison tests
CALL_COMPILE_COMMON("AI\AI\tests\garrison.sqf");

// Getting into vehicle
CALL_COMPILE_COMMON("AI\AI\tests\infantryGetInVehicle.sqf");

// Driver follow leader
CALL_COMPILE_COMMON("AI\AI\tests\driverFollowLeader.sqf");

// Civilian panic
CALL_COMPILE_COMMON("AI\AI\tests\civilianPanic.sqf");