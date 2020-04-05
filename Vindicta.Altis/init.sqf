#define OOP_INFO
#define OOP_DEBUG
#include "OOP_Light\OOP_Light.h"

// Looks kind of empty since all was moved elsewhere, we need to remove the file probably

// Code which adds all objects to be edited by zeus
if (isServer) then {  
    [] spawn { 
        scriptName "Add Curator Objects";
        sleep 5;
        while {true} do {  
            {  
                _x addCuratorEditableObjects [allUnits, true];
                _x addCuratorEditableObjects [vehicles, true];
                sleep 10;
            } forEach allCurators;
        };
    };
};