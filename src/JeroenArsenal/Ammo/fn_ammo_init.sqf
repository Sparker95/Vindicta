#include "defineCommon.inc"

#include "\A3\ui_f\hpp\defineDIKCodes.inc"
#include "\A3\Ui_f\hpp\defineResinclDesign.inc"

/*
	Author: Jeroen Notenbomer

	Description:
	Init ammo GUI
	
	Parameter(s):

	Returns:
	
*/

params [];


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
diag_log ("Init JN_ammo: Start");

//preload the ammobox so you dont need to wait the first time
["Preload"] call jn_fnc_arsenal;

//server
if(isServer)then{

};

//player
if(hasInterface)then{
    diag_log ("Init JNA: player");

    if(missionNamespace getVariable ["jn_ammo_first_init",true])then{

        //add open event
        [missionNamespace, "arsenalOpened", {
            disableSerialization;
            UINamespace setVariable ["arsanalDisplay",(_this select 0)];

            //spawn this to make sure it doesnt freeze the game
            [] spawn {
                disableSerialization;
                pr _type = UINamespace getVariable ["jn_type",""];
				if(_type isEqualTo "ammo")then{
                    ["CustomInit", [uiNamespace getVariable "arsanalDisplay"]] call jn_fnc_ammo_gui;
                };

            };
        }] call BIS_fnc_addScriptedEventHandler;

    	//add close event
        [missionNamespace, "arsenalClosed", {
            pr _type = UINamespace getVariable ["jn_type",""];

            if(_type isEqualTo "ammo")then{
                ["Close"] call jn_fnc_ammo_gui;
				UINamespace setVariable ["jn_type",""];
            };
        }] call BIS_fnc_addScriptedEventHandler;
    };
};

missionNamespace setVariable ["jn_ammo_first_init",false];

if(isServer)then{ 
	diag_log ("Init Server JN_ammo: done");
}else{
	diag_log ("Init pLayer JN_ammo: done");
};
