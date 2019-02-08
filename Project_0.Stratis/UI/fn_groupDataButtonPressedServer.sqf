params ["_hcGroups", "_text"];
diag_log "fn_groupDataButtonPressedServer has been called!";
switch(_text) do
{
	case "get in":
	{
		diag_log format ["fn_groupDataButtonPressedServer: get in button pressed! HC Groups: %1", _hcGroups];
		{
			/*{
				_x doMove (getPos _x);
			}forEach (units _x);*/
			(units _x) orderGetIn true;
		}forEach _hcGroups;
	};

	case "get out":
	{

	};
};
