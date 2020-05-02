//Just a quick file to initialize the modules already made in needed order
#define OOP_DEBUG
#include "common.h"

diag_log "[initModules] Starting...";

//Initialize the group for logic objects
if(isNil "groupLogic") then {
	groupLogic = createGroup sideLogic;
};

// Initialize the debug menu
call compile preprocessFileLineNumbers "DebugMenu\DebugMenu.sqf";

if (isNil "OOP_Light_initialized") then {
	OOP_Light_initialized = true;
	call compile preprocessFileLineNumbers "OOP_Light\OOP_Light_init.sqf";
};

// Initialize StorageInterfaces
call compile preprocessFileLineNumbers "SaveSystem\initClasses.sqf";

//Initialize templates
call compile preprocessFileLineNumbers "Templates\initFunctions.sqf";
call compile preprocessFileLineNumbers "Templates\initVariables.sqf";

// Common functions
call compile preprocessFileLineNumbers "Common\initFunctions.sqf";

// UI classes and functions
call compile preprocessFileLineNumbers "UI\initClasses.sqf";

//Initialize misc functions
call compile preprocessFileLineNumbers "Misc\initFunctions.sqf";
fnc_onPlayerRespawnServer = compile preprocessFileLineNumbers "fn_onPlayerRespawnServer.sqf";
fnc_onPlayerInitializedServer = compile preprocessFileLineNumbers "fn_onPlayerInitializedServer.sqf";

//Initialize cluster module
call compile preprocessFileLineNumbers "Cluster\initFunctions.sqf";

// Initialize MessageReceiver class
call compile preprocessFileLineNumbers "MessageReceiver\MessageReceiver.sqf";

// Initialize MessageReceiverEx class
call compile preprocessFileLineNumbers "MessageReceiverEx\MessageReceiverEx.sqf";

// Initialize MessageLoop class
call compile preprocessFileLineNumbers "MessageLoop\MessageLoop.sqf";

// Mod compatibility global variables
call compile preprocessFileLineNumbers "modCompatBools.sqf";

// Initialize Commander class
call compile preprocessFileLineNumbers "Commander\Commander.sqf";

// Initialize GOAP_Agent - we need it before Unit, Group, Garrison
call compile preprocessFileLineNumbers "AI\AI\GOAP_Agent.sqf";

// Initialize Unit class
call compile preprocessFileLineNumbers "Unit\Unit.sqf";

// Initialize Group class
call compile preprocessFileLineNumbers "Group\Group.sqf";

// Initialize Garrison class
call compile preprocessFileLineNumbers "Garrison\Garrison.sqf";

// Initialize MessageLoopManagers classes
call compile preprocessFileLineNumbers "MessageLoopManagers\MessageLoopMainManager.sqf";
call compile preprocessFileLineNumbers "MessageLoopManagers\MessageLoopGroupManager.sqf";

// Initialize Location class
call compile preprocessFileLineNumbers "Location\Location.sqf";

// Initialize Timer class
call compile preprocessFileLineNumbers "Timer\Timer.sqf";

// Initialize TimerService class
call compile preprocessFileLineNumbers "TimerService\TimerService.sqf";

// Initialize DebugPrinter class
call compile preprocessFileLineNumbers "DebugPrinter\DebugPrinter.sqf";

// Initialize LocationUnitArrayprovider class
call compile preprocessFileLineNumbers "LocationUnitArrayProvider\LocationUnitArrayProvider.sqf";

// Initialize AnimObject class
call compile preprocessFileLineNumbers "AnimObject\AnimObject.sqf";

// Initialize AnimObject inherited classes
call compile preprocessFileLineNumbers "AnimObjects\initClasses.sqf";

// Initialize AI classes
call compile preprocessFileLineNumbers "AI\initClasses.sqf";

// Initialize suspiciosness monitor
call compile preprocessFileLineNumbers "Undercover\initClasses.sqf";

// Initialize Grid class
call compile preprocessFileLineNumbers "GridStats\Grid.sqf";

// Initialize SideStat class
call compile preprocessFileLineNumbers "SideStat\SideStat.sqf";

// Initialize Intel and IntelDatabase classes
call compile preprocessFileLineNumbers "Intel\initClasses.sqf";

// Initialize the garbage collector
call compile preprocessFileLineNumbers "GarbageCollector\GarbageCollector.sqf";

// Initialize client side checks
call compile preprocessFileLineNumbers "ClientSideChecks\initClasses.sqf";

// Initialize GameModes
call compile preprocessFileLineNumbers "GameMode\initClasses.sqf";

// Initialize GameManager classes
call compile preprocessFileLineNumbers "GameManager\initClasses.sqf";

// Initialize PlayerDatabases
call compile preprocessFileLineNumbers "DoubleKeyHashmap\DoubleKeyHashmap.sqf";
call compile preprocessFileLineNumbers "PlayerDatabase\PlayerDatabaseServer.sqf";
call compile preprocessFileLineNumbers "PlayerDatabase\PlayerDatabaseClient.sqf";

// Initialize the GarrisonServer
call compile preprocessFileLineNumbers "GarrisonServer\initClasses.sqf";

diag_log "[initModules] Done!";