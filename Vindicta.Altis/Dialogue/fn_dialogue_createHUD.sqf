#include "defineCommon.inc"


disableSerialization;
private _display = findDisplay 46;

private _hud =  _display getvariable ["pr0_dialogue_hud" ,controlNull];

if(isnull _hud)then{

	_hud = _display ctrlCreate ["rscstructuredtext", -1];
	_display setvariable ["pr0_dialogue_hud" ,_hud];

	_hud ctrlsetBackgroundColor [0, 0, 0, 0.6];
	_hud ctrlSetPosition [0, FLOAT_POS_Y, 1, 0.1];
	_hud ctrlSetFade 1;//starts hidden
	_hud ctrlCommit 0;


	//call BIS_fnc_addStackedEventHandler
	["pr0_dialogue_compas_onEachFrame", "onEachFrame", {
		disableSerialization;
		private _display = findDisplay 46;
		
		private _ctrl_icons = (_display getvariable ["pr0_dialogue_icon_list" ,[]]);
		{
			private _ctrl_icon = _x;		
			
			private _speaker = _ctrl_icon getVariable ["_speaker", objNull];
			
			//worldToScreen BASED works nice but doesnt work when unit is out of side (returns [] if object is out of screen)
			private _pos_screen = (worldToScreen visiblePosition _speaker);
			private _icon_x = if(_pos_screen isequalTo [])then{
				//ALTERNITEVE ROTATION BASED
				private _dir = getDir player;//0 - 360 
				private _dir_unit = player getDir _speaker; //0 - 360 
				_icon_x = _dir_unit  - _dir; 
				if(_icon_x > 180)then{_icon_x = _icon_x-360}; //-180 - 180 
				_icon_x/360*2   +0.5;// 0-1
			}else{_pos_screen # 0}; //select x
			
			//limited movement to prevent it from moving outside hud
			_icon_x = _icon_x - (FLOAT_ICON_WITDH/2);
			_icon_x = _icon_x min (1-FLOAT_ICON_WITDH) max 0;

			//update position on screen
			_ctrl_icon ctrlsetposition [_icon_x, FLOAT_POS_Y];
			_ctrl_icon ctrlCommit 0;
		}forEach _ctrl_icons;
		
		//update sentences
		
		private _text_y  = FLOAT_POS_Y - 0.1;
		private _ctrl_sentences = (_display getvariable ["pr0_dialogue_sentence_list" ,[]]);
		for "_i" from (count _ctrl_sentences) - 1 to 0 step -1 do{
			Private _ctrl_sentence = _ctrl_sentences # _i;
			
			private _removeTime = _ctrl_sentence getVariable ["_removeTime",-1];
			
			private _type = _ctrl_sentence getVariable ["_type",TYPE_QUESTION];
			
			if(time > _removeTime && {_type != TYPE_QUESTION})then{
				private _fadeTime = _ctrl_sentence getVariable ["_fadeTime",-1];
				
				if(_fadeTime == -1)then{
					_ctrl_sentence setVariable ["_fadeTime",time+FLOAT_FADE_TIME];
					
					//fade sentence
					_ctrl_sentence ctrlSetFade 1;
					_ctrl_sentence ctrlCommit FLOAT_FADE_TIME;
					
					diag_log "_ctrl_sentence ctrlSetFade 1;";
					
					//fade icon if needed
					private _ctrl_icon = _ctrl_sentence getVariable ["_ctrl_icon",controlNull];
					private _ctrl_sentences_icon = _ctrl_icon getVariable ["_ctrl_sentences",[]];
					
					diag_log str [_ctrl_icon, _ctrl_sentences_icon];
					if(count _ctrl_sentences_icon == 1)then{
						_ctrl_icon ctrlSetFade 1;
						_ctrl_icon ctrlCommit FLOAT_FADE_TIME;
						diag_log "_ctrl_icon ctrlSetFade 1;";
						//fade frame if empty
						private _ctrl_icons = _display getvariable ["pr0_dialogue_icon_list" ,[]];
						if(count _ctrl_icons == 1)then{
							private _hud =  _display getvariable ["pr0_dialogue_hud" ,controlNull];
							diag_log "_hud ctrlSetFade 1";
							_hud ctrlSetFade 1;
							_hud ctrlCommit FLOAT_FADE_TIME;
						};
					};
					
				}else{
					if(time > _fadeTime)then{
						[_ctrl_sentence] call pr0_fnc_dialogue_removeSentence;
					};
				};			
			};
			
			//update position
			private _size_y = (ctrlPosition _ctrl_sentence) # 3;
			_text_y = _text_y - _size_y - 0.003;
			_ctrl_sentence ctrlsetposition [0, _text_y];
			_ctrl_sentence ctrlCommit 0;	
		};
		
	}] call BIS_fnc_addStackedEventHandler;
};

_hud;//return new create HUD