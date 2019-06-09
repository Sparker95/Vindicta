#ifndef _SQF_VM

#define DIK_6 0x07

g_debug_menu = [
	["Testing", "Debug Menu", "popup"],
	[
		// ["Hello World!", {
		// 	hint "Hello World";
		// 	true
		// }, "", "", [], 0x12, true, true ] 
	] 
];
pr0_fnc_debug_menu = { g_debug_menu };

pr0_fnc_addDebugMenuItem = {
	params ["_text", "_code"];
	g_debug_menu#1 pushBack [_text, _code, "", "", [], -1, true, true ];
};

pr0_fnc_initDebugMenu = {
	[
		"Project 0",
		"Open Menu",
		["player", [], -100, "_this call pr0_fnc_debug_menu"],
		[DIK_6, false, false, false]
	] call CBA_fnc_registerKeybindToFleximenu;
};

#else 

pr0_fnc_addDebugMenuItem = {};
pr0_fnc_initDebugMenu = {};

#endif