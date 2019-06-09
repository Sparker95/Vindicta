#ifndef _SQF_VM

#define DIK_6 0x07

g_debug_menu = [
	["Debug Menu", "Debug Menu", "popup"],
	[]
];
pr0_fnc_debug_menu = { g_debug_menu };

pr0_fnc_addDebugMenuItem = {
	params ["_menu", "_text", "_code"];
	// private _idx = g_debug_menu findIf { _x#0 isEqualTo _menu };
	// if(_idx == -1) then {
	// 	g_debug_menu pushBack [_menu, _menu, "popup"];
	// 	g_debug_menu pushBack [];
	// 	_idx = count g_debug_menu - 2;
	// };
	// g_debug_menu#(_idx+1) pushBack [_text, _code, "", "", [], -1, true, true ];
	g_debug_menu#1 pushBack [
		format["%1>%2", _menu, _text],
		_code, "", "", [], -1, true, true 
	];
};

pr0_fnc_initDebugMenu = {
	[
		"Project 0",
		"Open Menu",
		["player", [], -100, "_this call pr0_fnc_debug_menu"],
		[DIK_6, false, false, false]
	] call CBA_fnc_registerKeybindToFleximenu;
};

["Player", "Kill self", {
	player setDamage 1;
	systemChat "I KILL U!";
}] call pr0_fnc_addDebugMenuItem;

["Player", "Toggle god mode", {
	if(isDamageAllowed player) then {
		player allowDamage false;
		player enableFatigue false;
		systemChat "GOD MODE ENABLED!";
	} else {
		player allowDamage false;
		player enableFatigue false;
		systemChat "GOD MODE DISABLED!";
	};
}] call pr0_fnc_addDebugMenuItem;

#else 

pr0_fnc_addDebugMenuItem = {};
pr0_fnc_initDebugMenu = {};

#endif