#include "defineCommon.inc"

/*
    By: Jeroen Notenbomer

    Create HUD for sentences to be displayed on.
	Is called by preinit=1, but can be called again to update functions when debugging

	Input:
		
	Output:
		nil
*/

disableSerialization;
private _display = findDisplay 46;

//Remove key event
private _keyDownEvent = _display getVariable ["pr0_dialogue_keyDownEvent",-1];
_display displayRemoveEventHandler ["keyDown",_keyDownEvent];
_display setVariable ["pr0_dialogue_keyDownEvent",nil];

//remove hud
private _hud =  _display getvariable ["pr0_dialogue_hud" ,controlNull];
ctrlDelete _hud;

//clean lists
private _ctrl_sentences = (_display getvariable ["pr0_dialogue_sentence_list" ,[]]);
private _ctrl_icons = (_display getvariable ["pr0_dialogue_icon_list" ,[]]);
{
	ctrlDelete _x;
}forEach (_ctrl_sentences + _ctrl_icons);
_display setvariable ["pr0_dialogue_sentence_list" ,[]];
_display setvariable ["pr0_dialogue_icon_list" ,[]];
_display setvariable ["pr0_dialogue_question_list" ,[]];

["pr0_dialogue_compas_onEachFrame", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;

//show DUI hud again if it was hidden
if!(isnil "diwako_dui_main_toggled_off")then{
	diwako_dui_main_toggled_off = missionNamespace getVariable ["diwako_dui_main_toggled_off_before", false];
};
