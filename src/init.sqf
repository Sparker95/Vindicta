#define OOP_INFO
#define OOP_DEBUG
#include "common.h"

// Most normal init code is handled in GameMode init functions.

// Code which adds all objects to be edited by zeus
if (isServer) then {  
    [] spawn { 
        scriptName "Add Curator Objects";
        sleep 5;
        while {true} do {  
            {  
                _x addCuratorEditableObjects [allUnits, true];
                sleep 1;
                _x addCuratorEditableObjects [vehicles, true];
                sleep 1;
                _x addCuratorEditableObjects [agents apply {agent _x} select {_x isKindOf "Man"}, true]; 
                sleep 10;
            } forEach allCurators;
        };
    };
};

CALLM0(gGameManager, "init");
