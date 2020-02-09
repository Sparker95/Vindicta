---
layout: default
title: Frequently Asked Questions
nav_order: 3
---

# Frequently Asked Questions

### How do we claim an outpost?
> Press U, strategic tab, there should be 'claim' button.

### What is the difference between a camp and an outpost?
> Currently there is none.

### How do I open build menu?
> You must be at an owned location, indicated at the top of the screen, then use mouse wheel (action) menu option.

### What is "attach to garrison" for? 
> Use it to take "ownership" of a vehicle, and to ensure that it will respawn when you load your savegame. Must be used at an owned location, like a camp or an outpost. Use it on crates that contain building resources to gain access to them in the build menu.

### Are there any air units in the mission?
> Not yet

### How do I get building resources? 
> From ammoboxes found in enemy police stations and outposts.

### What mods are compatible?
> No AI mods are compatible, and no other mods are officially supported, although they may work without problems. 

### Where do I find the .RPT file?
> Paste in explorer: `%LOCALAPPDATA%/Arma 3`

### Will there be singleplayer mode?
> It is implemented already, but not well tested. Self hosted MP is still recommended.

### I can't find the mission in game??
> Host a MP game:
> ![Screenshot](https://cdn.discordapp.com/attachments/553300822583279616/666270214983254044/unknown.png)
> If it's not there, make sure you've loaded CBA and ACE.

### How can I holster my pistol?
> Press 0 (zero key) to use the ACE holster weapon action.

### How can I skip time?
> This isn't recommended as the delayed actions and intel timestamps the AI uses will be invalidated, however you can use server `skipTime` command if necessary (expect interesting results).

### How do I run it on a dedicated server?
> If you have got the files from Workshop, then you have addon-type .pbo files, not user-mission-type .pbo files.  
> You DO NOT need to put them into mpmissions folder.  
> Make sure the addon is loaded! Treat the workshop download as an addon, it must be loaded with -mod parameters, clients need it to play on your server!  
> See the server.cfg setup below: note that versions might be different!  
> ```cpp
> class Missions
> {
>     class vin001
>     {
>         template = "Vindicta_Altis_v0_24_186.Altis";
>         difficulty = "veteran";
>         class Params {};
>     };
>     class vin002
>     {
>         template = "Vindicta_Enoch_v0_24_187.Enoch";
>         difficulty = "veteran";
>         class Params {};
>     };
> };
> ```  

### Headless Client Support?
> Not now because it would require large scale code changes. Maybe later.

### Where are the saved games stored?
> In the `vars.arma3profile` file

### When?
> When it's done

### How often?
> As often as it's done
