//Just a quick file to initialize the modules already made in needed order
#define OOP_DEBUG
#include "common.h"

diag_log "[initModules] Starting...";

//Initialize the group for logic objects
if(isNil "groupLogic") then {
	groupLogic = createGroup sideLogic;
};

// Initialize the debug menu
CALL_COMPILE_COMMON("DebugMenu\DebugMenu.sqf");

if (isNil "OOP_Light_initialized") then {
	OOP_Light_initialized = true;
	CALL_COMPILE_COMMON("OOP_Light\OOP_Light_init.sqf");
};

// Initialize StorageInterfaces
CALL_COMPILE_COMMON("SaveSystem\initClasses.sqf");

//Initialize templates
CALL_COMPILE_COMMON("Templates\initFunctions.sqf");
CALL_COMPILE_COMMON("Templates\initVariables.sqf");

// Common functions
CALL_COMPILE_COMMON("Common\initFunctions.sqf");

// UI classes and functions
CALL_COMPILE_COMMON("UI\initClasses.sqf");

//Initialize misc functions
CALL_COMPILE_COMMON("Misc\initFunctions.sqf");
fnc_onPlayerRespawnServer = COMPILE_COMMON("fn_onPlayerRespawnServer.sqf");
fnc_onPlayerInitializedServer = COMPILE_COMMON("fn_onPlayerInitializedServer.sqf");

//Initialize cluster module
CALL_COMPILE_COMMON("Cluster\initFunctions.sqf");

// Initialize MessageReceiver class
CALL_COMPILE_COMMON("MessageReceiver\MessageReceiver.sqf");

// Initialize MessageReceiverEx class
CALL_COMPILE_COMMON("MessageReceiverEx\MessageReceiverEx.sqf");

// Initialize MessageLoop class
CALL_COMPILE_COMMON("MessageLoop\MessageLoop.sqf");

// Mod compatibility global variables
CALL_COMPILE_COMMON("modCompatBools.sqf");

// Initialize Commander class
CALL_COMPILE_COMMON("Commander\Commander.sqf");

// Initialize GOAP_Agent - we need it before Unit, Group, Garrison
CALL_COMPILE_COMMON("AI\AI\GOAP_Agent.sqf");

// Initialize Unit class
CALL_COMPILE_COMMON("Unit\Unit.sqf");

// Initialize Group class
CALL_COMPILE_COMMON("Group\Group.sqf");

// Initialize Garrison class
CALL_COMPILE_COMMON("Garrison\Garrison.sqf");

// Initialize MessageLoopManagers classes
CALL_COMPILE_COMMON("MessageLoopManagers\MessageLoopMainManager.sqf");
CALL_COMPILE_COMMON("MessageLoopManagers\MessageLoopGroupManager.sqf");

// Initialize Location class
CALL_COMPILE_COMMON("Location\Location.sqf");

// Initialize civ presence
CALL_COMPILE_COMMON("CivilianPresence\initClasses.sqf");

// Initialize Timer class
CALL_COMPILE_COMMON("Timer\Timer.sqf");

// Initialize TimerService class
CALL_COMPILE_COMMON("TimerService\TimerService.sqf");

// Initialize DebugPrinter class
CALL_COMPILE_COMMON("DebugPrinter\DebugPrinter.sqf");

// Initialize LocationUnitArrayprovider class
CALL_COMPILE_COMMON("LocationUnitArrayProvider\LocationUnitArrayProvider.sqf");

// Initialize AnimObject class
CALL_COMPILE_COMMON("AnimObject\AnimObject.sqf");

// Initialize AnimObject inherited classes
CALL_COMPILE_COMMON("AnimObjects\initClasses.sqf");

// Initialize AI classes
CALL_COMPILE_COMMON("AI\initClasses.sqf");

// Initialize suspiciosness monitor
CALL_COMPILE_COMMON("Undercover\initClasses.sqf");

// Initialize Grid class
CALL_COMPILE_COMMON("GridStats\Grid.sqf");

// Initialize SideStat class
CALL_COMPILE_COMMON("SideStat\SideStat.sqf");

// Initialize Intel and IntelDatabase classes
CALL_COMPILE_COMMON("Intel\initClasses.sqf");

// Initialize the garbage collector
CALL_COMPILE_COMMON("GarbageCollector\GarbageCollector.sqf");

// Initialize client side checks
CALL_COMPILE_COMMON("ClientSideChecks\initClasses.sqf");

// Initialize GameModes
CALL_COMPILE_COMMON("GameMode\initClasses.sqf");

// Initialize GameManager classes
CALL_COMPILE_COMMON("GameManager\initClasses.sqf");

// Initialize PlayerDatabases
CALL_COMPILE_COMMON("DoubleKeyHashmap\DoubleKeyHashmap.sqf");
CALL_COMPILE_COMMON("PlayerDatabase\PlayerDatabaseServer.sqf");
CALL_COMPILE_COMMON("PlayerDatabase\PlayerDatabaseClient.sqf");

// Initialize the GarrisonServer
CALL_COMPILE_COMMON("GarrisonServer\initClasses.sqf");

// Initialize dialogue
CALL_COMPILE_COMMON("Dialogue\initClasses.sqf");

diag_log "[initModules] Done!";