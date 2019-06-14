//Just a quick file to initialize the modules already made in needed order
#define OOP_DEBUG
#include "OOP_Light\OOP_Light.h"

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

//Initialize templates
call compile preprocessFileLineNumbers "Templates\initFunctions.sqf";
call compile preprocessFileLineNumbers "Templates\initVariables.sqf";

//Initialize the NATO template
tNATO = call compile preprocessFileLineNumbers "Templates\Factions\NATO.sqf";
tCSAT = call compile preprocessFileLineNumbers "Templates\Factions\CSAT.sqf";
tAAF = call compile preprocessFileLineNumbers "Templates\Factions\AAF.sqf";
tGUERILLA = call compile preprocessFileLineNumbers "Templates\Factions\GUERILLA.sqf";
tPOLICE = call compile preprocessFileLineNumbers "Templates\Factions\POLICE.sqf";
tCIVILIAN = call compile preprocessFileLineNumbers "Templates\Factions\CIVILIAN.sqf";

// Initialize Build menu object templates
call compile preprocessFileLineNumbers "Templates\BuildUI\initFunctions.sqf";

//Initialize misc functions
call compile preprocessFileLineNumbers "Misc\initFunctions.sqf";
fnc_onPlayerRespawnServer = compile preprocessFileLineNumbers "fn_onPlayerRespawnServer.sqf";

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

// Initialize Unit class
call compile preprocessFileLineNumbers "Unit\Unit.sqf";

// Initialize Group class
call compile preprocessFileLineNumbers "Group\Group.sqf";

// Initialize Garrison class
call compile preprocessFileLineNumbers "Garrison\Garrison.sqf";

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

// UI classes and functions
call compile preprocessFileLineNumbers "UI\initClasses.sqf";

// Initialize suspiciosness monitor
call compile preprocessFileLineNumbers "Undercover\initClasses.sqf";

// Initialize Camp class
call compile preprocessFileLineNumbers "Camp\initClasses.sqf";

// Initialize Grid class
call compile preprocessFileLineNumbers "GridStats\Grid.sqf";

// Initialize SideStat class
call compile preprocessFileLineNumbers "SideStat\SideStat.sqf";

// Initialize Intel and IntelDatabase classes
call compile preprocessFileLineNumbers "Intel\initClasses.sqf";

// Initialize the garbage collector
call compile preprocessFileLineNumbers "GarbageCollector\GarbageCollector.sqf";

// Initialize Location Visibility Monitor
call compile preprocessFileLineNumbers "LocationVisibilityMonitor\LocationVisibilityMonitor.sqf";

// Initialize GameModes
call compile preprocessFileLineNumbers "GameMode\initClasses.sqf";

diag_log "[initModules] Done!";