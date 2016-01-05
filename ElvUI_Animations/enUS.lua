---------------------------------------------------
-- File:			enUS.lua
-- Author:			Benjamin Odom
-- Date Created:	01-02-2016
--
-- Brief:	Creates a localization for enUS and 
--	enGB	
---------------------------------------------------

-- English localization file for enUS and enGB.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local L = AceLocale:NewLocale("ElvUI", "enUS", true);
if not L then return; end

-- Animations
L["Fade"] = true
L["Alpha"] = true

L["Slide"] = true
L["Translate"] = true
L["Offset"] = true

L["Bounce"] = true

-- Default Tab Names
L["Default"] = true
L["Frame"] = true

L["Player Frame"] = true
L["Target Frame"] = true

L["Party Frames"] = true

L["Raid Frames"] = true
L["Raid-40 Frames"] = true

L["Panel"] = true

L["Left Chat Panel"] = true
L["Right Chat Panel"] = true

L["Objectives Frame"] = true

L["Minimap"] = true
L["Player Buffs"] = true

L["Bar"] = true

L["Top Panel"] = true
L["Bottom Panel"] = true