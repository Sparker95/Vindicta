// Called on server, when civilian is surrendering and wants to say something silly

params ["_civ"];

private _text = selectRandom [
	"Don't shoot! Please!",
	"Please, don't shoot!",
	"Fuck this shit!",
	"Put the gun away!",
	"I surrender!",
	"I am not armed!",
	"Don't kill me! I have a family!",
	"What do you want??",
	"Leave me alone! Please!",
	"I'm not the guy you are looking for!",
	"Please, put the weapon away!",
	"I have no weapon!",
	"Oh My God!",
	"I am not ready to die!",
	"Someone, help me!"
];

[_civ, _text, objNull] call  Dialog_fnc_hud_createSentence;