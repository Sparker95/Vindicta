#include "defineCommon.inc"

/*
    By: Jeroen Notenbomer

    Create HUD for sentences to be displayed on.
	Is called by preinit=1, but can be called to again to update functions incase of debugging

	Input:
		
	Output:
		nil
*/




//////////////////////
private _cfg = missionConfigFile >> "dialogue_question";
[_cfg, 46] call ui_fnc_createControlsFromConfig;

private _display = findDisplay 46;
(_display displayCtrl 1) ctrlSetStructuredText parseText "<t align='center'>Response:</t><br/>[1] Yes<br/>[2] No<br/>[3] No<br/>[4] No<br/>[5] No";
//////////////////////




private _display = findDisplay 46;

//clean old list incase you loaded a mission
private _ctrl_sets = (_display getvariable ["Dialog_text_ctrlNew" ,[]]) + (_display getvariable ["Dialog_text_ctrlShown" ,[]]);
{
	private _text = _x;
	private _icon = _text getVariable ["icon",controlNull];
	ctrlDelete _icon;
	ctrlDelete _text;
}forEach _ctrl_sets;
_display setvariable ["Dialog_text_ctrlNew" ,[]];
_display setvariable ["Dialog_text_ctrlShown" ,[]];


//call BIS_fnc_addStackedEventHandler
["dialog_HUD", "onEachFrame", {
	private _display = findDisplay 46;
	private _array_textShown =  _display getvariable ["Dialog_text_ctrlShown" ,[]];
	private _array_textNew = _display getvariable ["Dialog_text_ctrlNew" ,[]];
	if(count _array_textShown + count _array_textNew == 0)exitWith{};
	private _timer = _display getVariable ["dialogueHideTimer", 0];

	//remove ctrls that are markered for removal
	{
		private _text = _x;
		private _icon = _x getVariable ["icon",controlNull];
		private _remove = _text getVariable ["markForRemoval",false];
		if(_remove)then{
			if(ctrlFade _text == 1)then{
				_array_textShown deleteAt (_array_textShown find _text);
				ctrlDelete _text;
				ctrlDelete _icon;
			};
		};
	}forEach _array_textShown;

	//wait untill timer runs out and remove all ctrls 
	if(time > _timer)exitWith{
		{
			private _text = _x;
			private _icon = _x getVariable ["icon",controlNull];
			private _remove = _text getVariable ["markForRemoval",false];
			if(!_remove)then{
				_text ctrlSetFade 1;
				_text ctrlCommit FLOAT_TEXT_SCROLL_SPEED;
				_icon ctrlSetFade 1;
				_icon ctrlCommit FLOAT_TEXT_SCROLL_SPEED;
				_text setVariable ["markForRemoval",true];
			};
		}forEach _array_textShown;
	};

	//check if text is moving if it is we need to wait before adding more
	private _isMoving = if(count  _array_textShown > 0)then{
		private _textBottom =  _array_textShown select (count _array_textShown-1);
		(ctrlPosition _textBottom)#1 != ARRAY_TEXT_POS_START#1 - ARRAY_TEXT_STEPSIZE;
	}else{
		false
	};

	if(!_isMoving )then{

		if(count _array_textNew > 0)then{
			//move from newArray to ActiveArray
			private _ctrl = _array_textNew#0; //selecting the oldest message
			private _icon = _ctrl getVariable ["icon",controlNull];
			_array_textShown pushBack _ctrl;
			_array_textNew deleteAt 0; 

			//make it visable we commit this change later all at ones
			_ctrl ctrlsetfade 0;
			_icon ctrlsetfade 0; _icon ctrlCommit FLOAT_TEXT_SCROLL_SPEED;
			//remove text that was hidden already
			if(count _array_textShown == INT_MAX_LINES_DIALOGUE +1)then{
				private _ctrl = _array_textShown#0;
				private _icon = _ctrl getVariable ["icon",controlNull];
				_array_textShown deleteAt 0;
				ctrlDelete _ctrl;
				ctrlDelete _icon;
			};

			//hide old messages so we dont show to many
			if(count _array_textShown == INT_MAX_LINES_DIALOGUE)then{
				private _ctrl = _array_textShown#0;
				private _icon = _ctrl getVariable ["icon",controlNull];
				_ctrl ctrlsetfade 1;
				_icon ctrlsetfade 1;
			};

			//move all text up one step
			{
				private _clrl = _x;
				
				private _newPos = ctrlPosition _clrl;
				_newPos set [1, ctrlPosition _clrl # 1 - ARRAY_TEXT_STEPSIZE];

				_clrl ctrlSetPosition _newPos;
				_clrl ctrlCommit FLOAT_TEXT_SCROLL_SPEED;
			}forEach _array_textShown;
		};
	};


	//update icon (arrow icon, pointing to who is talking)
	{
		private _icon = _x getVariable ["icon",controlNull];
		private _unit = _x getVariable ["unit",objNull];

		//player it self doesnt need icon
		if(!isnull _icon)then{
			//ALTERNITEVE worldToScreen BASED
			private _pos_screen = (worldToScreen visiblePosition _unit);//returns [] if object is out of screen
			private _icon_x = if(_pos_screen isequalTo [])then{
			
				//ALTERNITEVE ROTATION BASED
				private _dir = getDir player;//0 - 360 
				private _dir_unit = player getDir _unit; //0 - 360 
				_icon_x = _dir_unit  - _dir; 
				if(_icon_x > 180)then{_icon_x = _icon_x-360}; //-180 - 180 
				_icon_x/360*2   +0.5;// 0-1
			
			
			}else{_pos_screen # 0}; //we only need X
		
			
			//limited movement to prevent it from moving out of the frame
			_icon_x = _icon_x - (FLOAT_ICON_WITDH/2);
			_icon_x = _icon_x min (1-FLOAT_ICON_WITDH) max 0;

			
			//ICONS
			_icon ctrlsetposition [_icon_x, FLOAT_POS_Y];
			_icon ctrlCommit 0;
		}
	}forEach _array_textShown;

}] call BIS_fnc_addStackedEventHandler;














