#include "defineCommon.inc"

/*
    By: Jeroen Notenbomer

    Create HUD for sentences to be displayed on.
	Is called by preinit=1, but can be called to again to update functions incase of debugging

	Input:
		
	Output:
		nil
*/

//FRAME-----------------------------------------------------------------------------
private _display = findDisplay 46;
private _frame =  _display getvariable ["Dialog_compas_frame" ,controlNull];
ctrlDelete _frame;
if(isnull _frame)then{
	_frame = _display ctrlCreate ["RscEdit", -1];
	_display setvariable ["Dialog_compas_frame" ,_frame];
};
_frame ctrlsetBackgroundColor [0, 0, 0, 0.6];
_frame ctrlSetPosition [0, FLOAT_POS_Y, 1, 0.1];
_frame ctrlSetFade 1;
_frame ctrlCommit 0;

//clean old list incase you loaded a mission
private _ctrl_sets = (_display getvariable ["Dialog_text_ctrlSet" ,[]]);
{
	_x params ["_icon","_text"];
	ctrlDelete _icon;
	ctrlDelete _text;
}forEach _ctrl_sets;
_display setvariable ["Dialog_text_ctrlSet" ,[]];


//call BIS_fnc_addStackedEventHandler
["dialog_HUD", "onEachFrame", {
	private _display = findDisplay 46;

	private _ctrl_sets = (_display getvariable ["Dialog_text_ctrlSet" ,[]]);
	private _frame =  _display getvariable ["Dialog_compas_frame" ,controlNull];
	
	private _frameFaded =  _frame getvariable ["faded",true];
	if(count _ctrl_sets == 0 )then{
		if(!_frameFaded)then{
			_frame setvariable ["faded",true];
			_frame ctrlSetFade 1;
			_frame ctrlCommit FLOAT_FADE_OUT;};
	}else{
		if(_frameFaded)then{
			_frame setvariable ["faded",false];
			_frame ctrlSetFade 0;
			_frame ctrlCommit 0;
		};
	};
	
	//remove items if there are to many
	while{count _ctrl_sets > INT_SENTENCE_LIMIT}do{
		_ctrl_sets # 0 params ["_icon","_text","_unit","_fadeTime","_removeTime"];
		ctrlDelete _icon;
		ctrlDelete _text;
		_ctrl_sets deleteAt 0;
	};
	
	private _text_y  = FLOAT_POS_Y - 0.1;
	for "_i" from (count _ctrl_sets) - 1 to 0 step -1 do{
		(_ctrl_sets # _i) params ["_icon","_text","_unit","_fadeTime","_removeTime"];

		if(time > _fadeTime)then{
		
		
			if(_text getvariable ["faded",false])then{
				if(time > _removeTime)then{
					ctrlDelete _icon;
					ctrlDelete _text;
					_ctrl_sets deleteAt _i;
				};
			}else{
				_text setvariable ["faded",true];
				_icon ctrlSetFade 1;
				_icon ctrlCommit FLOAT_FADE_OUT;
				
				_text ctrlSetFade 1;
				_text ctrlCommit FLOAT_FADE_OUT;
			};
		};
		
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
		};
		
		
		//TEXT
		_text ctrlsetposition [0, _text_y];
		_text ctrlCommit 0;
		
		_text_y = _text_y - 0.05;
	};
}] call BIS_fnc_addStackedEventHandler;














