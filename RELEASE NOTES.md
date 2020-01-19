# 0.24
- Added: new respawn screen to replace the BI respawn screen
- Added: SP support (possible with the new respawn screen).
- Added: flashlights attachments to default handguns when you respawn so that you are not lost at night
- Fixed: U-menu not showing up in some cases
- Fixed: magazines for some weapons were missing in enemy ammo boxes
- Tweaked: position and rotation of objects built with the build menu is synchronized better now for clients

# 0.23
- Added a quick fix for being unable to save. Might have to wait for a while if SQF errors have happened in game.
- Removed keys temporarily until they are fixed.

# 0.22
- Improved undercover system.
- Added CBA cba_setting.sqf file to force-disable the ACE map illumination, since it makes the map totally black on respawn screen.
- Fixed police reinforcements moving to destination police stations instantly.
- Fixed RHS LDF loadouts.
- Fixed arsenal errors.
- Fixed minor things in UI.
- Fixed AI 'move' action not returning success state
- Fixed AI repair action not working (as consequence of above fix)
- Fixed damange event handlers being added to player, while should be added to AI only