#define BLUEFOR_COLOR "#0073e6"
#define OPFOR_COLOR "#cc0000"
#define CIVILIAN_COLOR "#b800e6"
#define UNKOWN_COLOR "#e6c700"
#define ERROR_COLOR "#ff9900"


//default 	[blufor, 	opfor, 		civilian,		sideEmpty]
//			["#004C99",	"#800000",	"#660080",		"#B29900"]
// i used https://www.w3schools.com/colors/colors_picker.asp to make brither colors

params [["_unit",objNull,[objNull]]];


private _index = [blufor, opfor, civilian] find side _unit;

private _color = if(_index == -1)then{
	UNKOWN_COLOR;
}else{
	//if player doesnt know about the unit he doesnt know what side he is on
	if(player knowsAbout _unit == 4)then{
		[BLUEFOR_COLOR, OPFOR_COLOR,CIVILIAN_COLOR] select _index;
	}else{
		UNKOWN_COLOR;
	};
};

_color;



