params ["_name","_icon"];


private _actionID = player addAction [
	"",
	"call po_interaction_action",
	[],
	6, 
	true, 
	true, 
	"",
	"true", // _target, _this, _originalTarget
	50,
	false,
	"",
	""
];
player setVariable ["p0_interaction_actionID",_actionID];

player setUserActionText [_actionID,_name,"","<img size='3' color='#ffffff' image='a3\ui_f\data\IGUI\Cfg\Actions\talk_ca.paa'/>"];