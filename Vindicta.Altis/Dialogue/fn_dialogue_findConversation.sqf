


params ["_conversation_id"];

private _script = {};
{
	_x params ["_id","_script_search"];
	if(_id isEqualTo _conversation_id)exitWith{
		_script = _script_search;
	};
}foreach pr0_dialogue_array;

_script;