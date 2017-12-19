#include "UICommanderIDC.hpp";

params ["_text"];

private _displayMap = findDisplay 12;
private _ctrlText = (_displayMap displayCtrl IDC_GROUP_DATA_TEXT_0);
_ctrlText ctrlSetText _text;