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

local _DataBase
local _Options

local _ElvUI_Animations = E:GetModule('ElvUI_Animations', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0'); -- Create a plug-in within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.

local _AddonName, _AddonTable = ... -- See http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2

_AddonTable.Cache = { }
local _Cache = _AddonTable.Cache

function _AddonTable:CacheAnimation(KeyName, AnimationKeyName)
	local AnimKey = AnimationKeyName		-- Expose the argument's name in full but use an internal alias

	if type(KeyName) ~= "string" then error("'CacheAnimation' expects a string as a parameter 'KeyName'", 2) return end
	if type(AnimKey) ~= "string" then error("'CacheAnimation' expects a string as a parameter 'AnimationKeyName'", 2) return end
	
	local AddonTable = _AddonTable.Animations[KeyName].Animation		-- The local 'AddonTable' should always point to the relevant 'Animations' table
	
	for k, v in pairs(AddonTable) do
		local Cache = _Cache[KeyName].Animation[AnimKey]		-- The local 'Cache' should always point to the relevant animation configuration tab cache
		local Animation = AddonTable[k]							-- The local 'Animation' should always point to the relevant animation
			
		Animation:SetDuration(Cache.Duration.Time)

		Animation:SetStartDelay(Cache.Duration.Delay.Start)
		Animation:SetEndDelay(Cache.Duration.Delay.End)
			
		if Cache.AnimationName == "Alpha" then
			Animation:SetChange(Cache.Alpha.Change)
		end

		Animation:SetSmoothing(Cache.Smoothing)
		Animation:SetOrder(Cache.Order)
	end
end

function _AddonTable:CacheAnimationTabOptions(KeyName, AnimationKeyName)
	local AnimKey = AnimationKeyName		-- Expose the argument's name in full but use an internal alias

	if type(KeyName) ~= "string" then error("'CacheAnimationTabOption' expects a string as a parameter 'KeyName'", 2) return end
	if type(AnimKey) ~= "string" then error("'CacheAnimationTabOption' expects a string as a parameter 'AnimationKeyName'", 2) return end
	
	local Cache = _Cache[KeyName].Animation				-- The local 'Cache' should always point to the relevant animation configuration
	
	local DataBase = _DataBase[KeyName].Animation		-- The local 'DataBase' should always point to the relevant animation database
	if DataBase.UseDefaults then
		DataBase = _DataBase['Defaults'].Animation
	end
	
	local Duration = DataBase.DefaultDuration
	if DataBase[AnimKey].CustomDuration.Enabled then
		Duration = DataBase[AnimKey].CustomDuration
	end
	
	Cache[AnimKey] = DataBase[AnimKey]		-- After determining which settings to use, cache the proper settings
	Cache[AnimKey].Duration = Duration		-- Except 'Duration' which does not exist, but will be used when parsing the animation cache
end

function _AddonTable.Cache:InitializeCache()
	_DataBase = E.db.ElvUI_Animations
	_Options = E.Options.args.ElvUI_Animations.args
end

_AddonTable.CacheAnim = _AddonTable.CacheAnimation
_AddonTable.CacheAnimTab = _AddonTable.CacheAnimationTabOptions

_AddonTable.Cache.InitCache = _AddonTable.Cache.InitializeCache