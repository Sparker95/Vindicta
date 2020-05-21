#include "..\..\common.h"

private _dlg0 = NEW("DialogOneTabButtons", []);
CALLM1(_dlg0, "setHeadlineText", "Basic dialog");
CALLM1(_dlg0, "setHintText", "Hint: class name of this is: DialogOneTabButtons");

private _texts = ["OK", "Cancel", "What", "WTF"];
CALLM1(_dlg0, "createButtons", _texts);

private _text = "Hi there!\nThis is a multi line text box with some buttons under it\nIt can auto resize its height to fit text height if needed\nIt can have any amount of buttons created dynamicly\nWe can use it as a base class for other dialogs like that.\nNice! I like!";
CALLM1(_dlg0, "setText", _text);