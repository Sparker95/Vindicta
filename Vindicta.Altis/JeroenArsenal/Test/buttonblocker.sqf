disabledKeys = ["Gear"];

clicked = {
    params["_ctrl","_dikCode","_shiftKey","_ctrlKey","_altKey"];
    
    hint "test";
    {
        if(inputAction _x>0) exitWith {
            hint format["Key:%1 is disabled",_dikCode];
            true;
        };
    } count disabledKeys;
    
};

_display = finddisplay 46;
waituntil {!isnull _display};
_display displayAddEventHandler  ["KeyDown",{_this call clicked}];
_display = finddisplay 46;
_display displayAddEventHandler  ["MouseButtonDown",{hint "test2"; true}];




removeAllActions player;

player addAction ["", {vehicle player action ["CarBack",vehicle player]}, "", 0, false, true, "CarForward"];

//code to disable a weapon from firing
JN_hideEmptyAction = {
    params ["_target","_caller","_id"];
    ((_this select 4) isEqualTo "");
};
//ACE is using inGameUISetEventHandler and overwrites it. Need to find a fix for this
inGameUISetEventHandler ["PrevAction", "_this call JN_hideEmptyAction;"];
inGameUISetEventHandler ["NextAction", "_this call JN_hideEmptyAction;"];
player addAction ["", {}, "", 0, false, true, "DefaultAction"];