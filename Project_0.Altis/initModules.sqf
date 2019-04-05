//Just a quick file to initialize the modules already made in needed order
#define OOP_DEBUG
#include "OOP_Light\OOP_Light.h"
#define COMPILEFUNC(path) compile preprocessFileLineNumbers path

diag_log "initModules was called!";

//Initialize the group for logic objects
if(isNil "groupLogic") then
{
	groupLogic = createGroup sideLogic;
};

//Initialize templates
call compile preprocessFileLineNumbers "Templates\initFunctions.sqf";
call compile preprocessFileLineNumbers "Templates\initVariablesServer.sqf";

//Initialize the NATO template
tNATO = call compile preprocessFileLineNumbers "Templates\NATO.sqf";
tCSAT = call compile preprocessFileLineNumbers "Templates\CSAT.sqf";
tAAF = call compile preprocessFileLineNumbers "Templates\AAF.sqf";
tGUERILLA = call compile preprocessFileLineNumbers "Templates\GUERILLA.sqf";
//a = [classesNATO, T_VEH, T_VEH_default] call t_fnc_select;
//[classesNATO] call t_fnc_checkNil;

// Initialize Build menu object templates
call compile preprocessFileLineNumbers "Templates\BuildUI\initFunctions.sqf";

//Initialize misc functions
call compile preprocessFileLineNumbers "Misc\initFunctions.sqf";
fnc_onPlayerRespawnServer = COMPILEFUNC("fn_onPlayerRespawnServer.sqf");

//Initialize cluster module
call compile preprocessFileLineNumbers "Cluster\initFunctions.sqf";

/*
//Initialize garrison
call compile preprocessFileLineNumbers "Garrison\initFunctions.sqf";
call compile preprocessFileLineNumbers "Garrison\initVariablesServer.sqf";

//Initialize location
call compile preprocessFileLineNumbers "Location\initFunctions.sqf";
call compile preprocessFileLineNumbers "Location\initVariablesServer.sqf";

//Initialize AI scripts
call compile preprocessFileLineNumbers "AI\initFunctions.sqf";
call compile preprocessFileLineNumbers "AI\initVariablesServer.sqf";

//Initialize UI functions
call compile preprocessFileLineNumbers "UI\initFunctions.sqf";

//Initialize sense module
call compile preprocessFileLineNumbers "Sense\initFunctions.sqf";
call compile preprocessFileLineNumbers "Sense\initVariablesServer.sqf";

//Initialize script objects
call compile preprocessFileLineNumbers "scriptObject\scriptObject.sqf";

//Initialize commander scripts
call compile preprocessFileLineNumbers "Commander\initFunctions.sqf";
*/

// Initialize OOP_Light
call compile preprocessFileLineNumbers "OOP_Light\OOP_Light_init.sqf";

// Initialize MessageReceiver class
call compile preprocessFileLineNumbers "MessageReceiver\MessageReceiver.sqf";

// Initialize MessageReceiverEx class
call compile preprocessFileLineNumbers "MessageReceiverEx\MessageReceiverEx.sqf";

// Initialize MessageLoop class
call compile preprocessFileLineNumbers "MessageLoop\MessageLoop.sqf";

// Mod compatibility global variables
call compile preprocessFileLineNumbers "modCompatBools.sqf";

// Initialize Unit class
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

diag_log "initModules ended!";
