#include "OOP_Light\OOP_Light.h"

#define pr private

diag_log "[vin_advertizer]: init";

0 spawn {
  diag_log "[vin_advertizer]: waiting for displays to init...";
  waitUntil {!isNull (findDisplay 12)};
  waitUntil {!isNull (findDisplay 46)};
  waitUntil {!isNull player};

  diag_log "[vin_advertizer]: showing dialog";

  pr _dlg = NEW("DialogOneTabButtons", []);

  pr _text = "";
  _text = _text + "   \n    Hello!\n\n";
  _text = _text + "    Vindicta has moved!\n\n";
  _text = _text + "    Use the button below to copy the download link.\n\n";
  _text = _text + "    This branch will no longer be maintained, because now Vindicta is hosted from\n";
  _text = _text + "our new Steam account to ease automated deployment to Steam in the future.\n\n";

  CALLM1(_dlg, "setText", _text);
  CALLM1(_dlg, "setHintText", "");
  CALLM1(_dlg, "setHeadlineText", "New Vindicta update");
  CALLM2(_dlg, "setContentSize", 0.65, 0.45);

  CALLM1(_dlg, "createButtons", ["COPY LINK" ARG "CLOSE"]);

  pr _btn = CALLM1(_dlg, "getButtonControl", 1);
  _btn setVariable ["_dlgObj", _dlg];

  pr _codeClickClose = {
      params ["_ctrl"];
      pr _thisObject = _ctrl getVariable "_dlgObj";
      CALLM0(_thisObject, "deleteOnNextFrame");
  };

  CALLM2(_dlg, "addButtonClickHandler", 1, _codeClickClose);

  pr _codeClickCopy = {
      copyToClipboard "https://github.com/Sparker95/Vindicta";
  };
  CALLM2(_dlg, "addButtonClickHandler", 0, _codeClickCopy);
};
