# Vindicta

## What is it?
It is a multiplayer Co-Op mission for ARMA III. The goal of this project is to make a guerrilla warfare scenario for ARMA III, hugely influenced by a similar mission by Barbolani: Antistasi (http://www.a3antistasi.enjin.com/).

## How do I run it??
You should download the mission from steam workshop. **The GitHub releases are severely outdated.**
https://steamcommunity.com/sharedfiles/filedetails/?id=1964186045

**For running on your dedicated server, install the folder you download from Workshop as a mod.**

## Key features
* Multi-level AI (commander, garrison, group, unit level) which can plan ahead and execute different tasks (attacks on spotted targets/locations, sending reinforcements, dispatching patrols, managing its logistics)
* Unit caching system, which lets AIs far away perform actions while being despawned without draining server performance
* Gaining intel about enemy forces at outposts and about future actions performed by enemy commander (convoys, attacks, etc)
* Usage of the gathered intel to perform tactical maneuvers (intercepting convoys, withdrawing our own forces prior to attack, etc)
* Convenient UI for commanding forces of player's faction
* Dynamic creation of new locations (camps, roadblocks, etc) by enemy and player side
* Undercover system which takes into account player's loadout, actions, exposure in vehicle 

## Current state of development
The project is in 'Alpha' stage. Most of the features are implemented.

## Links
Steam WorkShop download: https://steamcommunity.com/sharedfiles/filedetails/?id=1964186045

BI Forum thread: https://forums.bohemia.net/forums/topic/227302-mpcoop-vindicta-alpha/

Our Discord: https://discord.gg/rDhxKBp

Guide: https://vindicta-team.github.io/Vindicta-Docs/

## Technical implementation
* Most of the code is being developed with OOP-Light (https://github.com/Sparker95/OOP-Light), a custom OOP implementation for SQF.
OOP paradigm helps to produce manageable code for complex systems.
* Low level AI is being handled by a custom GOAP (Goal-Oriented Action Planning) AI framework. GOAP is a technology which was first used in fameous F.E.A.R. first person shooter. GOAP should help manage the complexity of creation of complex AI behaviours that involve replannable chains of actions. More on GOAP here: http://aigamedev.com/open/article/fear-sdk/ http://alumni.media.mit.edu/~jorkin/

## Used SQF tools
BI's tool support for their SQF language is non-existant. We are using these tools during the development and we are grateful to their authors:
* Arma Debug Engine and Arma Script Profiler by Dedmen Miller (https://github.com/dedmen/)
* SQF-VM by X39 (https://github.com/SQFvm/vm)
* SQDev by Krzmbrzl (https://github.com/Krzmbrzl/SQDev)
* SQFLint by SkaceKamen (https://github.com/SkaceKamen/sqflint)
* VSCode_SQF by Armitxes (https://github.com/Armitxes/VSCode_SQF)

## Other used projects and tools
* GPS by AmouryD (https://github.com/AmauryD/A3GPS)
* KP Liberation builder (https://github.com/KillahPotatoes/KP-Liberation/tree/master/_tools)
* Arma3 AddOn Project template by ACE team (https://github.com/KillahPotatoes/KP-Liberation/tree/master/_tools)
