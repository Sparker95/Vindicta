#include "..\..\common.h"

//if (!isNil "gDialogBase") then {DELETE(gDialogBase);};

// Show a confirmation dialog
private _args = [format ["Test test test some text. And some more text. This is a lot of text to test the resizing of this confirmation dialog."],
	[],
	{},
	[], {}];
NEW("DialogConfirmAction", _args);
