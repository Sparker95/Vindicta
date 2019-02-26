undercover = compile preprocessFileLineNumbers "Undercover\Undercover.sqf";
call compile preprocessFileLineNumbers "Undercover\CivObjects.sqf";
[player] spawn undercover;