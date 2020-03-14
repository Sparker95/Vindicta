params[
	["_fnc","",[""]],
	["_args",[]],
	["_target",0,[0]],
	["_obj",objNull,[objNull]],
	["_call",false,[true]]
];

private _jip_deleteEvent = _obj getVariable "_jip_deleteEvent";
if(isnil "_jip_deleteEvent")then{
	_obj addEventHandler ["Deleted", {
		params ["_obj"];

		private _jip_messages_call = _obj getVariable ["_jip_messages_call",[]];
		{
			if (_x != "") then { remoteExecCall ["", _x];};
		}forEach _jip_messages_call;

		private _jip_messages = _obj getVariable ["_jip_messages",[]];
		{
			if (_x != "") then { remoteExec ["", _x];};
		}forEach _jip_messages;
	}];
};

if(_target == -2 && !isDedicated)then{_target = 0};


private _jip_message = -1;
if(_call)then{
	private _jip_message = _args remoteExecCall [_fnc, _target,  true];
	private _jip_messages = _obj getVariable ["_jip_messages_call",[]];
	_jip_messages pushBack _jip_message;
	_obj getVariable ["_jip_messages_call",_jip_messages];
}else{
	private _jip_message = _args remoteExec [_fnc, _target,  true];
	private _jip_messages = _obj getVariable ["_jip_messages",[]];
	_jip_messages pushBack _jip_message;
	_obj getVariable ["_jip_messages",_jip_messages];
};


_jip_message;