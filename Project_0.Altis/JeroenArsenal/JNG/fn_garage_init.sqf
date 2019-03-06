#include "defineCommon.inc"
/*
	Author: Jeroen Notenbomer

	Description:
	Adds garage to a given object

	Parameter(s):
	Object

	Returns:
	
	Usage: object call jn_fnc_garage_init;
	
*/

#include "defineCommon.inc"

///////////////////////////////////////////////////////////////////////////////////////////

params [["_object",objNull,[objNull]]];
diag_log ("Init JNG: Start " + str _object);
if(isNull _object)exitWith{["Error: wrong input given '%1'",_object] call BIS_fnc_error;};

//check if it was already initialised
if(_object getVariable ["jng_init",false])exitWith{diag_log ("Init JNG: Already initialised " + str _object) };
_object setVariable ["jng_init", true];



//server
if(isServer)then{
	diag_log ("Init JNG: server " + str _object);

    //load default if it was not loaded from savegame
    pr _vehicleLists = _object getVariable "jng_vehicleLists";
    if(isnil "_vehicleLists")then{
        _object setVariable ["jng_vehicleLists" ,[[],[],[],[],[],[]]];
    };
	pr _fuel = _object getVariable "jng_fuel";
    if(isnil "_fuel")then{
        _object setVariable ["jng_fuel" ,0];
    };
	pr _ammoPoints = _object getVariable "jng_ammoPoints";
    if(isnil "_ammoPoints")then{
        _object setVariable ["jng_ammoPoints" ,0];
    };
	pr _repairPoints = _object getVariable "jng_repairPoints";
    if(isnil "_repairPoints")then{
        _object setVariable ["jng_repairPoints" ,0];
    };
};


//player
if(hasInterface)then{
    diag_log ("Init JNG: player "+ str _object);

	//add open garage button to object
	_object addaction [
        format ["<img size='1.75' image='\A3\ui_f\data\GUI\Rsc\RscDisplayArsenal\spaceArsenal_ca.paa' />%1",localize "STR_JNG_ACT_OPEN"],
        {
            pr _object = _this select 0;

            //start loading screen
			["jn_fnc_garage", "Loading Nutz™ Arsenal"] call bis_fnc_startloadingscreen;
			[] spawn {
				uisleep 10;
				pr _ids = missionnamespace getvariable ["BIS_fnc_startLoadingScreen_ids",[]];
				if("jn_fnc_garage" in _ids)then{
					pr _display =  uiNamespace getVariable ["arsanalDisplay","No display"];
					titleText["ERROR DURING LOADING GARAGE", "PLAIN"];
					_display closedisplay 2;
					["jn_fnc_garage"] call BIS_fnc_endLoadingScreen;
				};
			};

            //set type and object to use later
            UINamespace setVariable ["jn_type","garage"];
            UINamespace setVariable ["jn_object",_object];

            //request server to open garage
            [clientOwner,_object] remoteExecCall ["jn_fnc_garage_requestOpen",2];
        },
        [],
        6,
        true,
        false,
        "",
        "alive _target && {_target distance _this < 5}"
    ];
	
	//add garage vehicle option
	_object addaction [
        format ["<img size='1.75' image='\A3\ui_f\data\GUI\Rsc\RscDisplayArsenal\spaceArsenal_ca.paa' />%1",localize "STR_JNG_ACT_STOREVEHICLE"],
        {
            pr _object = _this select 0;
			
			pr _script =  {
				params ["_object"];
				pr _vehicle = cursorObject;
				[_vehicle,_object] call jn_fnc_garage_garageVehicle;
			};
			pr _conditionActive = {
				params ["_object"];
				alive player;
			};
			pr _conditionColor = {
				params ["_object"];
				!isnull cursorObject && {!(_object isEqualTo cursorObject)}&&{_object distance cursorObject < MAX_DISTANCE_TO_STORE}
			};
						
			[_script,_conditionActive,_conditionColor,_object] call jn_fnc_common_addActionSelect;
		},
        [],
        6,
        true,
        false,
        "",
        "alive _target && {_target distance _this < 5}"
			
    ];
	
	
	if(missionNamespace getVariable ["jng_first_init",true])then{

        //add open event
        [missionNamespace, "arsenalOpened", {
            disableSerialization;
            UINamespace setVariable ["arsanalDisplay",(_this select 0)];

            //spawn this to make sure it doesnt freeze the game
            [] spawn {
                disableSerialization;
                _type = UINamespace getVariable ["jn_type",""];
                if(_type isEqualTo "garage")then{
                    ["CustomInit", [uiNamespace getVariable "arsanalDisplay"]] call jn_fnc_garage;
                };
            };
        }] call BIS_fnc_addScriptedEventHandler;
		
		 //add close event
        [missionNamespace, "arsenalClosed", {
            _type = UINamespace getVariable ["jn_type",""];

            if(_type isEqualTo "garage")then{
                [clientOwner, UINamespace getVariable "jn_object"] remoteExecCall ["jn_fnc_garage_requestClose",2];
            };
			
			UINamespace setVariable ["jn_type",""];
        }] call BIS_fnc_addScriptedEventHandler;

	};
	
};

missionNamespace setVariable ["jng_first_init",false];

if(isServer)then{ 
	diag_log ("Init Server JNG: done" + str _object);
}else{
	diag_log ("Init pLayer JNG: done" + str _object);
};

