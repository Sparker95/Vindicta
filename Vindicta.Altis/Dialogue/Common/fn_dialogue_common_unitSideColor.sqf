#define BLUEFOR_COLOR "#0073e6"
#define OPFOR_COLOR "#cc0000"
#define CIVILIAN_COLOR "#b800e6"
#define UNKOWN_COLOR "#e6c700"
#define ERROR_COLOR "#ff9900"


//default 	[blufor, 	opfor, 		civilian,		sideEmpty]
//			["#004C99",	"#800000",	"#660080",		"#B29900"]
// i used https://www.w3schools.com/colors/colors_picker.asp to make brither colors

params [["_unit",objNull,[objNull]]];


if(side _unit isEqualTo sideEmpty)exitWith{UNKOWN_COLOR};

private _color = "#ff9900";

//if player doesnt know about the unit he doesnt know what side he is on
if(player knowsAbout _unit == 4)then{
	private _index = side _unit find [blufor, opfor, civilian];
	_color = [BLUEFOR_COLOR, OPFOR_COLOR,CIVILIAN_COLOR] select _index;
}else{
	_color = ERROR_COLOR;
};

_color



