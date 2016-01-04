---------------------------------------------------
-- File:			Cache.lua
-- Author:			Benjamin Odom
-- Date Created:	01-04-2016
--
-- Brief:	Holds all code related to sorting 
--	and caching variables into a globally 
--	accessible table
---------------------------------------------------

local E, L, V, P, G = unpack(ElvUI); -- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local _DataBase = E.db.ElvUI_Animations
local _
local _Options = E.Options.args.ElvUI_Animations.args

local _ElvUI_Animations = E:GetModule('_ElvUI_Animations', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0'); -- Create a plugin within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.

local _AddonName, _AddonTable = ... -- See http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2

_AddonTable.Cache = { }
local _Cache = _AddonTable.Cache

local function CacheAnimationTabOption(KeyName, AnimationKeyName)
	local AnimKey = AnimationKeyName

	if type(KeyName) ~= "string" then error("'CacheAnimationTabOption' expects a string as a parameter 'KeyName'", 2) return end
	if type(AnimKey) ~= "string" then error("'CacheAnimationTabOption' expects a string as a parameter 'AnimationKeyName'", 2) return end
	
	local Cache = _Cache[KeyName].Animation				-- The cache should always
	
	local DataBase = _DataBase[KeyName].Animation
	if DataBase.UseDefaults then
		DataBase = _DataBase['Defaults'].Animation
	end
	
	local Duration = DataBase.DefaultDuration
	if DataBase[AnimKey].Duration.Enabled then
		Duration = DataBase[AnimKey].CustomDuration
	end
	
	Cache[AnimKey]
end

addonTable.CacheAnim = CacheAnimationTabOption