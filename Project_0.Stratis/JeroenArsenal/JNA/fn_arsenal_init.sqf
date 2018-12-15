/*
	Author: Jeroen Notenbomer

	Description:
	Adds arsenal to a given object

	Parameter(s):
	Object

	Returns:
	
*/


#include "\A3\ui_f\hpp\defineDIKCodes.inc"
#include "\A3\Ui_f\hpp\defineResinclDesign.inc"

///////////////////////////////////////////////////////////////////////////////////////////

diag_log "Init JNA: Start";

params [["_object",objNull,[objNull]]];
if(isNull _object)exitWith{["Error: wrong input given '%1'",_object] call BIS_fnc_error;};

//check if it was already initialised
if(_object getVariable ["jna_init",false])exitWith{diag_log "Init JNA: Already initialised";};
_object setVariable ["jna_init", true];

//change this for items that members can only take
jna_minItemMember = [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1];
//jna_minItemMember = [10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,500,20,20,20,10,500];

//preload the ammobox so you dont need to wait the first time
["Preload"] call jn_fnc_arsenal;

//server
if(isServer)then{
	diag_log "Init JNA: server";

    //load default if it was not loaded from savegame
    private _datalist = _object getVariable "jna_dataList";
    if(isnil "_datalist")then{
        _object setVariable ["jna_dataList" ,[[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]]];
    };
};



//player
if(hasInterface)then{
    diag_log "Init JNA: player";

    //add arsenal button
    _object addaction [
        format ["<img size='1.75' image='\A3\ui_f\data\GUI\Rsc\RscDisplayArsenal\spaceArsenal_ca.paa' />%1",localize "STR_JNA_ACT_OPEN"],
        {
            private _object = _this select 0;

            //start loading screen
			//jn_fnc_arsenal", "Loading splendid™ Arsenal"] call bis_fnc_startloadingscreen;
			[] spawn {
				sleep 10;
				["test1"] call BIS_fnc_endLoadingScreen;
			}
            //save proper ammo because BIS arsenal rearms it, and I will over write it back again
            missionNamespace setVariable ["jna_magazines_init",  [
                magazinesAmmoCargo (uniformContainer player),
                magazinesAmmoCargo (vestContainer player),
                magazinesAmmoCargo (backpackContainer player)
            ]];

            //Save attachments in containers, because BIS arsenal removes them
            private _attachmentsContainers = [[],[],[]];
            {
                private _container = _x;
                private _weaponAtt = weaponsItemsCargo _x;
                private _attachments = [];

                if!(isNil "_weaponAtt")then{

                    {
                        private _atts = [_x select 1,_x select 2,_x select 3,_x select 5];
                        _atts = _atts - [""];
                        _attachments = _attachments + _atts;
                    } forEach _weaponAtt;
                    _attachmentsContainers set [_foreachindex,_attachments];
                }
            } forEach [uniformContainer player,vestContainer player,backpackContainer player];
            missionNamespace setVariable ["jna_containerCargo_init", _attachmentsContainers];

            //set type and object to use later
            UINamespace setVariable ["jn_type","arsenal"];
            UINamespace setVariable ["jn_object",_object];

            //request server to open arsenal
            [clientOwner,_object] remoteExecCall ["jn_fnc_arsenal_requestOpen",2];
        },
        [],
        6,
        true,
        false,
        "",
        "alive _target && {_target distance _this < 5}"
    ];

    //add vehicle/box filler button
    _object addaction [
        format ["<img size='1.75' image='\A3\ui_f\data\GUI\Rsc\RscDisplayArsenal\spaceArsenal_ca.paa' />%1",localize "STR_JNA_ACT_CONTAINER_OPEN"],
        {
            private _object = _this select 0;

            //remove old action to not get dubble, but be able to change the main arsenal box
            player removeAction (uiNamespace getVariable ["JN_CONTAINER_OPEN_ACTION",-1]);


            //create action for the player to be able to select second container
            _id = player addaction [
                format ["<t color='#FF0000'><img size='1.75' image='\A3\ui_f\data\GUI\Rsc\RscDisplayArsenal\spaceArsenal_ca.paa' />%1",localize "STR_JNA_ACT_CONTAINER_SELECT"],
                {
                    private _object = _this select 3 select 0;

                    private _id = _this select 2;
                    player removeAction _id;

                    //start loading screen
                    //["jn_fnc_arsenal"] call bis_fnc_startloadingscreen;

                    //check if player is looking at some object
                    _object_selected = cursorObject;
                    if(isnull _object_selected)exitWith{hint localize "STR_JNA_ACT_CONTAINER_SELECTERROR1"; };

                    //check if object is in range
                    if(_object distance cursorObject > 10)exitWith{hint localize "STR_JNA_ACT_CONTAINER_SELECTERROR2";};

                    //check if object has inventory
                    private _className = typeOf _object_selected;
                    private _tb = getNumber (configFile >> "CfgVehicles" >> _className >> "transportmaxbackpacks");
                    private _tm = getNumber (configFile >> "CfgVehicles" >> _className >> "transportmaxmagazines");
                    private _tw = getNumber (configFile >> "CfgVehicles" >> _className >> "transportmaxweapons");
                    if !(_tb > 0  || _tm > 0 || _tw > 0) exitWith{hint localize "STR_JNA_ACT_CONTAINER_SELECTERROR3";};


                    //set type and object to use later
                    UINamespace setVariable ["jn_type","container"];
                    UINamespace setVariable ["jn_object",_object];
                    UINamespace setVariable ["jn_object_selected",_object_selected];

                    //request server to open arsenal
                    [clientOwner,_object] remoteExecCall ["jn_fnc_arsenal_requestOpen",2];

                },
                [_object],
                6,
                true,
                false,
                "",
                "alive _target && {_target distance _this < 5}"
            ];//end of sub addaction


            //remove action if player moves to far
            [_id, _object] spawn {
                params["_id","_object"];
                private _timer = 10;//timer 10sec
                while {_timer > 0} do{
                    sleep 0.1;
                    _timer = _timer - 0.1;
                    if(!isnull cursorObject && {
                            !(_object isEqualTo cursorObject)
                        }&&{
                            _object distance cursorObject < 10;
                        }&&{
                            //check if object has inventory
                            private _className = typeOf cursorObject;
                            private _tb = getNumber (configFile >> "CfgVehicles" >> _className >> "transportmaxbackpacks");
                            private _tm = getNumber (configFile >> "CfgVehicles" >> _className >> "transportmaxmagazines");
                            private _tw = getNumber (configFile >> "CfgVehicles" >> _className >> "transportmaxweapons");
                            if (_tb > 0  || _tm > 0 || _tw > 0) then {true;} else {false;};
                        }
                    )then{
                        player setUserActionText [_id, format ["<t color='#FFA500'><img size='1.75' image='\A3\ui_f\data\GUI\Rsc\RscDisplayArsenal\spaceArsenal_ca.paa' />%1",localize "STR_JNA_ACT_CONTAINER_SELECT"]]
                    }else{
                        player setUserActionText [_id, format ["<t color='#808080'><img size='1.75' image='\A3\ui_f\data\GUI\Rsc\RscDisplayArsenal\spaceArsenal_ca.paa' />%1",localize "STR_JNA_ACT_CONTAINER_SELECT"]]
                    };
                };
                player removeAction _id;
            };

            uiNamespace setVariable ["JN_CONTAINER_OPEN_ACTION",_id];

        },
        [],
        6,
        true,
        false,
        "",
        "alive _target && {_target distance _this < 5}"
    ];

    if(missionNamespace getVariable ["jna_first_init",true])then{

        //add open event
        [missionNamespace, "arsenalOpened", {
            disableSerialization;
            UINamespace setVariable ["arsanalDisplay",(_this select 0)];

            //spawn this to make sure it doesnt freeze the game
            [] spawn {
                disableSerialization;
                _type = UINamespace getVariable ["jn_type",""];
                if(_type isEqualTo "arsenal")then{
                    ["CustomInit", [uiNamespace getVariable "arsanalDisplay"]] call jn_fnc_arsenal;
                }else{
                    ["CustomInit", [uiNamespace getVariable "arsanalDisplay"]] call jn_fnc_arsenal_container;
                };

            };
        }] call BIS_fnc_addScriptedEventHandler;

    	//add close event
        [missionNamespace, "arsenalClosed", {

            _type = UINamespace getVariable ["jn_type",""];

            if(_type isEqualTo "arsenal")then{
                [clientOwner, UINamespace getVariable "jn_object"] remoteExecCall ["jn_fnc_arsenal_requestClose",2];
            };

            if(_type isEqualTo "container")then{
                ["Close"] call jn_fnc_arsenal_container;
                [clientOwner, UINamespace getVariable "jn_object"] remoteExecCall ["jn_fnc_arsenal_requestClose",2];
            };
        }] call BIS_fnc_addScriptedEventHandler;
    };
};


missionNamespace setVariable ["jna_first_init",false];
diag_log "Init JNA: done";