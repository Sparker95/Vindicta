---
layout: default
title: How to Report a Problem
nav_order: 4
---

# How to Report a Problem

## Categories of Problem

### Gameplay

This is a potentially subjective problem with the in-game mechanics or balance. e.g. It is too difficult to find building supplies.  
Before reporting these, please check the [Frequently Asked Questions](faq.md), and the [Quick Start](quick-start.md) to confirm 
that this behaviour is not expected.
Once confirmed you should report this direct to the discord #help channel.

### In-game Technical

This is a problem where a feature appears to broken, e.g. saves are not showing up, the scenario won't initialize, etc.
To diagnose this kind of problem we need your .rpt file, your save file, and a description of your setup environment
(dedicated server, host, locally hosted, single player), and any relavant context.
Once you have gathered these things you can either make an issue on our GitHub page (link above), or open a support ticket on our Discord (link above).

### Server Configuration

This is outside the scope of our support (assuming you followed the [Quick Start Guide](quick-start.md)).  
Please refer to general server configuration guides, your server hosts documentation, or 
ask others for help in the Arma Discord or our Discord #help channel.

## Where is my .rpt file?
These are named like `Arma3_x64_2019-06-07_12-47-26.rpt`.

If you are using a 3rd party server host (e.g. armahosts) this will vary. Just get on ftp and look in some likely looking folders until you find them. 
If you haven't got ftp access then firstly consider a new host, then use their online interface to find the files. If they you can't find them then
contact your host, don't tell us as we can't do anything about it.

If you are self hosting or playing single player then paste `%localappdata%\Arma 3` into the Windows Explorer bar and press enter. 
The .rpt files should be in that folder (`C:\Users\<user name>\AppData\Local\Arma 3`).

## Where is my save file?

If you are using a 3rd party server host, again this will vary. Follow the same advice as for the .rpt file above, but looking for a file like 
`<something>.vars.Arma3Profile`.

If you are self hosting or playing single player then paste `%userprofile%\Documents\Arma 3` into the Windows Explorer bar and press enter.
This should take you to a directory like `C:\Users\<user name>\Documents\Arma 3`.
There should be a file in there called `<profile name>.vars.Arma3Profile`, this is your saves. Normally this file is only a few KB in size, 
Vindicta saves will cause it to be anywhere from 5MB to >100MB depending on how many saves you have. When it grows beyond 30MB or so it can cause
significat slow down in starting up Arma 3.
