

params[
	["_fnc","",[""]],
	["_args",[]],
	["_target",0,[0]],	//0 allplayers and headless clients, -2 allplayers and headless clients
	["_obj",objNull,[objNull]]
];

if(_target == -2 && !isServerDedicated)then{_target = 0;};

private _jip_deleteEvent = _obj getVariable ["_jip_deleteEvent",-1];
if(_jip_deleteEvent == -1)then{
	_obj addEventHandler ["Deleted", {
		params ["_obj"];
		private _jip_messages = _obj getVariable ["_jip_messages",[]];
		{
			if (_x != "") then { remoteExec ["", _x];};
		}forEach _jip_messages;
	}];
};

_jip_message = _args remoteExec [_fnc, _target, true];

private _jip_messages = _obj getVariable ["_jip_messages",[]];
_jip_messages pushBack _jip_message;
_obj getVariable ["_jip_messages",_jip_messages];




