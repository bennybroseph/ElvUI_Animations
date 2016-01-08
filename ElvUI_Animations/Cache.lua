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

local _ElvUI_Animations = E:GetModule('ElvUI_Animations', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0'); -- Create a plug-in within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.

local _AddonName, _AddonTable = ... -- See http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2


_AddonTable._Cache = { } -- Creates an empty cache table. This gets cleared on load/reload
local _Cache = _AddonTable._Cache

local _DataBase

function _AddonTable._Cache:Animation(KeyName, AnimationKeyName)
	local AnimKey = AnimationKeyName		-- Expose the argument's name in full but use an internal alias

	if type(KeyName) ~= "string" then error("'CacheAnimation' expects a string as a parameter 'KeyName'", 2) return end
	if type(AnimKey) ~= "string" then error("'CacheAnimation' expects a string as a parameter 'AnimationKeyName'", 2) return end
	
	local AnimationGroup = _AddonTable._NotKept.Animations[KeyName].AnimationGroup		-- The local 'AddonTable' should always point to the relevant 'Animations' table
	local DataBase = _DataBase[KeyName]
	local Cache = self[KeyName].Animation[AnimKey]		-- The local 'Cache' should always point to the relevant animation configuration tab cache

	for i = 1, #DataBase.Config.Frame do
		if GetClickFrame(DataBase.Config.Frame[i]) ~= nil then
			local Animation = AnimationGroup[i].Animation[AnimKey]		-- The local 'Animation' should always point to the relevant animation
		
			Animation:SetDuration(Cache.Duration.Time)

			Animation:SetStartDelay(Cache.Duration.Delay.Start)
			Animation:SetEndDelay(Cache.Duration.Delay.End)

			Animation:SetSmoothing(Cache.Smoothing)
			Animation:SetOrder(Cache.Order)

			if Cache.AnimationName == "Alpha" then
				Animation:SetChange(Cache.Alpha.End - Cache.Alpha.Start)

				Animation:SetScript("OnPlay",
					function()
						if not Cache.Enabled then Animation:Stop() return end

						GetClickFrame(DataBase.Config.Frame[i]):SetAlpha(Cache.Alpha.Start)
					end)
				Animation:GetParent():SetScript("OnFinished",
					function()
						GetClickFrame(DataBase.Config.Frame[i]):SetAlpha(Cache.Alpha.End)
					end)
			end
		end
	end
end
function _AddonTable._Cache:AnimationTabOption(KeyName, AnimationKeyName)
	local AnimKey = AnimationKeyName		-- Expose the argument's name in full but use an internal alias
	
	if KeyName == nil or KeyName == "Default_Tab" then
		for k, v in pairs(_DataBase) do
			if string.find(k, "_Tab") and k ~= "Default_Tab" then
				self:AnimationTabOption(k, AnimKey)
			end
		end
	elseif AnimKey == nil then
		for k, v in pairs(_DataBase[KeyName].Animation) do
			if string.find(k, "_Tab") then
				self:AnimationTabOption(KeyName, k)
			end
		end
	else
	
		if type(KeyName) ~= "string" then error("'CacheAnimationTabOption' expects a string as a parameter 'KeyName'\nGot "..KeyName, 2) return end
		if type(AnimKey) ~= "string" then error("'CacheAnimationTabOption' expects a string as a parameter 'AnimationKeyName'\nGot "..AnimKey, 2) return end
	
		local Cache = self[KeyName].Animation				-- The local 'Cache' should always point to the relevant animation configuration
	
		local DataBase = _DataBase[KeyName].Animation		-- The local 'DataBase' should always point to the relevant animation database
		if DataBase.UseDefaults then
			DataBase = _DataBase['Default_Tab'].Animation
		end
	
		Cache.DefaultDuration = DataBase.DefaultDuration

		local Duration = DataBase.DefaultDuration
		if DataBase[AnimKey].CustomDuration.Enabled then
			Duration = DataBase[AnimKey].CustomDuration
		end
	
		Cache[AnimKey] = DataBase[AnimKey]		-- After determining which settings to use, cache the proper settings
		Cache[AnimKey].Duration = Duration		-- Except 'Duration' which does not exist, but will be used when parsing the animation cache

		self:Animation(KeyName, AnimKey)
	end
end

function _AddonTable._Cache:CombatAnimation(KeyName)
	if type(KeyName) ~= "string" then error("'CacheCombatAnimation' expects a string as a parameter 'KeyName'", 2) return end

	local DataBase = _DataBase[KeyName]
	local Cache = self[KeyName].Combat

	for i = 1, #DataBase.Config.Frame do
		if GetClickFrame(DataBase.Config.Frame[i]) ~= nil then
			local Animation = _AddonTable._NotKept.CombatAnimations[KeyName].Animation[i]

			Animation.In:SetDuration(Cache.Duration.In)
			Animation.Out:SetDuration(Cache.Duration.Out)

			Animation.In:SetSmoothing(Cache.Smoothing.In)
			Animation.Out:SetSmoothing(Cache.Smoothing.Out)
		
			Animation.In:SetScript("OnPlay", 
				function()
					Animation.In:SetChange(Cache.Alpha.In - GetClickFrame(DataBase.Config.Frame[i]):GetAlpha())
				end)
			Animation.Out:SetScript("OnPlay",
				function()
					Animation.Out:SetChange(Cache.Alpha.Out - GetClickFrame(DataBase.Config.Frame[i]):GetAlpha())
				end)

			Animation.In:GetParent():SetScript("OnFinished", 
				function()
					GetClickFrame(DataBase.Config.Frame[i]):SetAlpha(Cache.Alpha.In)
				end)
			Animation.Out:GetParent():SetScript("OnFinished", 
				function()
					GetClickFrame(DataBase.Config.Frame[i]):SetAlpha(Cache.Alpha.Out)
				end)
		end
	end
end
function _AddonTable._Cache:Initialize()
	_DataBase = E.db.ElvUI_Animations

	for k, v in pairs(_DataBase) do
		self[k] = { Animation = { }, Combat = { }, }
	end
end

function _AddonTable._Cache:CombatAnimationTabOption(KeyName)
	if KeyName == nil or KeyName == "Default_Tab" then
		for k, v in pairs(_DataBase) do
			if string.find(k, "_Tab") and k ~= "Default_Tab" then
				self:CombatAnimationTabOption(k)
			end
		end
	else
		if type(KeyName) ~= "string" then error("'CacheCombatAnimation' expects a string as a parameter 'KeyName'", 2) return end

		local Cache = self[KeyName]
	
		local DataBase = _DataBase[KeyName]
		if DataBase.Combat.UseDefaults then
			DataBase = _DataBase['Default_Tab']
		end
	
		Cache.Combat = DataBase.Combat
	
		self:CombatAnimation(KeyName)
	end
end

_AddonTable._Cache.Anim = _AddonTable._Cache.Animation
_AddonTable._Cache.AnimTab = _AddonTable._Cache.AnimationTabOption

_AddonTable._Cache.CombatAnim = _AddonTable._Cache.CombatAnimation
_AddonTable._Cache.CombatAnimTab = _AddonTable._Cache.CombatAnimationTabOption

_AddonTable._Cache.Init = _AddonTable._Cache.Initialize