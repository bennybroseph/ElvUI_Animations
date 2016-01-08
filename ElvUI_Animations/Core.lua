---------------------------------------------------
-- File:			Core.lua
-- Author:			Benjamin Odom
-- Date Created:	12-28-2015
--
-- Brief:	Essentially the main.cpp
--	Holds all of the add-ons basic callbacks 	
---------------------------------------------------

local E, L, V, P, G = unpack(ElvUI); -- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local _AddonName, _AddonTable = ... -- See http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2


_AddonTable._Core = CreateFrame("Frame", "ElvUI_Animation_UIParent", UIParent)

local _Core = _AddonTable._Core
local _Cache = _AddonTable._Cache
local _Config = _AddonTable._Config
local _Animations = _AddonTable._NotKept.Animations
local _CombatAnimations = _AddonTable._NotKept.CombatAnimations

local _DataBase

--function ElvUI_Animations:Appear(Index)
--	if E.db.ElvUI_Animations[Index].Animation.Enabled then
--		--ElvUI_Animations:AttemptTranslate(Index)
--		--ElvUI_Animations:AttemptFade(Index)		
--	end
--end

--function ElvUI_Animations:AttemptAnimation(Index)
--	local DataBase = E.db.ElvUI_Animations[Index].Animation

--	local Alpha = {
--		Index = 0,
--	}
--	local Trans = {
--		Index = 0,
--	}

--	for i = 1, #DataBase do
--		if DataBase[i].AnimationName == "Alpha" and Alpha.Index ~= DataBase[i].Order then
--			ElvUI_Animations:AttemptFade(Index, i)
--			Alpha.Index = DataBase[i].Order
--		end
--		if DataBase[i].AnimationName == "Translation" and Trans.Index ~= DataBase[i].Order then
--			ElvUI_Animations:AttemptTranslate(Index, i)

--			Trans.Index = DataBase[i].Order
--		end
--	end
--	for i = 1, #E.db.ElvUI_Animations[Index].Config.Frame do
--		if V.ElvUI_Animations.Animation.AnimationGroup[Index][i] ~= nil then
--			V.ElvUI_Animations.Animation.AnimationGroup[Index][i]:Play()
--		end
--	end
--end

--function ElvUI_Animations:AttemptTranslate(Index, AnimIndex)
--	local DataBase = E.db.ElvUI_Animations[Index].Animation

--	if DataBase[AnimIndex].Enabled then
--		if DataBase.UseDefaults then
--			DataBase = E.db.ElvUI_Animations[1].Animation
--		end

--		local Duration = DataBase.Default.Duration
--		local Delay = DataBase.Default.Delay
--		local Order = 1

--		if DataBase[AnimIndex].Duration.Enabled then
--			Duration = DataBase[AnimIndex].Duration.Length
--			Delay = DataBase[AnimIndex].Duration.Delay
--			Order = DataBase[AnimIndex].Order
--		end

--		ElvUI_Animations:Translate(
--			E.db.ElvUI_Animations[Index].Config.Frame, 
--			Index,
--			AnimIndex,
--			Duration, 
--			DataBase[AnimIndex].Offset, 
--			DataBase[AnimIndex].Distance, 
--			DataBase[AnimIndex].Smoothing, 
--			Delay,
--			Order)
--	end	
--end

--function ElvUI_Animations:AttemptFade(Index, AnimIndex)
--	local DataBase = E.db.ElvUI_Animations[Index].Animation

--	if DataBase[AnimIndex].Enabled then
--		if DataBase.UseDefaults then
--			DataBase = E.db.ElvUI_Animations[1].Animation
--		end

--		local Duration = DataBase.Default.Duration
--		local Delay = DataBase.Default.Delay
--		local Order = 1

--		if DataBase[AnimIndex].Duration.Enabled then
--			Duration = DataBase[AnimIndex].Duration.Length
--			Delay = DataBase[AnimIndex].Duration.Delay
--			Order = DataBase[AnimIndex].Order
--		end

--		ElvUI_Animations:Fade(
--			E.db.ElvUI_Animations[Index].Config.Frame,
--			Index,
--			AnimIndex, 
--			Duration, 
--			DataBase[AnimIndex].Alpha,
--			DataBase[AnimIndex].Smoothing, 
--			Delay,
--			Order)
--	end
--end

--function ElvUI_Animations:Translate(FrameString, Index, AnimIndex, Duration, Offset, Distance, Smoothing, Delay, Order)	
--	local Point, RelativeTo, RelativePoint, PosX, PosY = { }, { }, { }, { }, { }

--	for i = 1, #FrameString do
--		local Frame = GetClickFrame(FrameString[i])

--		if Frame ~= nil and Frame:IsShown() == true then
--			local AnimGroup = V.ElvUI_Animations.Animation.AnimationGroup[Index][i]
--			local TransAnim = V.ElvUI_Animations.Animation.AlphaAnimation[Index][i][AnimIndex]

--			TransAnim:SetDuration(Duration)

--			TransAnim:SetStartDelay(Delay.Start)
--			TransAnim:SetEndDelay(Delay.End)

--			TransAnim:SetOffset(Distance.X, Distance.Y)

--			TransAnim:SetSmoothing(Smoothing)

--			TransAnim:SetOrder(Order)			

--			if Order == 1 then 
--				AnimGroup:HookScript("OnPlay",
--					function()
--						local Point, RelativeTo, RelativePoint, PosX, PosY = Frame:GetPoint()

--						Frame:ClearAllPoints()
--						Frame:SetPoint(Point, RelativeTo, RelativePoint, 
--							PosX + Offset.X, 
--							PosY + Offset.Y)
--					end)

--				AnimGroup:HookScript("OnFinished", 
--					function()
--						local Point, RelativeTo, RelativePoint, PosX, PosY = Frame:GetPoint()

--						Frame:ClearAllPoints()
--						Frame:SetPoint(Point, RelativeTo, RelativePoint, 
--							PosX - Offset.X, 
--							PosY - Offset.Y)
--					end)
--			end
--		end
--	end
--end

--function ElvUI_Animations:Fade(FrameString, Index, AnimIndex, Duration, Alpha, Smoothing, Delay, Order)
--	for i = 1, #FrameString do
--		local Frame = GetClickFrame(FrameString[i])

--		if Frame ~= nil and Frame:IsShown() == true then
--			local AnimGroup = V.ElvUI_Animations.Animation.AnimationGroup[Index][i]
--			local AlphaAnim = V.ElvUI_Animations.Animation.AlphaAnimation[Index][i][AnimIndex]

--			AlphaAnim:SetDuration(Duration)

--			AlphaAnim:SetStartDelay(Delay.Start)
--			AlphaAnim:SetEndDelay(Delay.End)

--			AlphaAnim:SetChange(Alpha.End - Alpha.Start)

--			AlphaAnim:SetSmoothing(Smoothing)

--			AlphaAnim:SetOrder(Order)

--			if Order == 1 then
--				AnimGroup:HookScript("OnPlay",
--					function()
--						Frame:SetAlpha(Alpha.Start)
--					end)
--				AnimGroup:HookScript("OnFinished",
--					function()
--						Frame:SetAlpha(Alpha.End)
--					end)
--			end	
--		end
--	end
--end

--function ElvUI_Animations:AttemptCombatFade(Index, Option)
--	local DataBase = E.db.ElvUI_Animations[Index]

--	if DataBase.Combat.Enabled then	
--		if DataBase.Combat.UseDefaults then
--			DataBase = E.db.ElvUI_Animations[1]
--		end
--		ElvUI_Animations:CombatFade(
--			E.db.ElvUI_Animations[Index].Config.Frame, 
--			Index, 
--			DataBase.Combat.Duration[Option],
--			DataBase.Combat.Alpha[Option],
--			DataBase.Combat.Smoothing[Option])
--	end
--end

--function ElvUI_Animations:CombatFade(FrameString, Index, Duration, Alpha, Smoothing)
--	for i = 1, #FrameString do
--		local Frame = GetClickFrame(FrameString[i])

--		if Frame ~= nil and Frame:IsShown() == true then
--			local AnimGroup = V.ElvUI_Animations.Combat.AnimationGroup[Index][i]
--			local AlphaAnim = V.ElvUI_Animations.Combat.AlphaAnimation[Index][i]

--			AnimGroup:Stop()

--			AlphaAnim:SetDuration(Duration)

--			AlphaAnim:SetChange(Alpha - Frame:GetAlpha())

--			AlphaAnim:SetSmoothing(Smoothing)

--			AnimGroup:Play()

--			AnimGroup:SetScript("OnFinished",
--				function()
--					Frame:SetAlpha(Alpha)
--				end)
--		end
--	end
--end

--function ElvUI_Animations:AttemptMouseOverFade(Index, DeltaTime, Option)
--	local DataBase = E.db.ElvUI_Animations[Index]

--	if DataBase.Combat.Enabled then
--		if DataBase.Combat.UseDefaults then
--			DataBase = E.db.ElvUI_Animations[1]
--		end

--		local Alpha = { Start = DataBase.Combat.Alpha.In, End = DataBase.Combat.Mouse.Alpha }
--		local Duration = DataBase.Combat.Mouse.Duration.On

--		if Option ~= "Focus" then
--			Alpha.Start = DataBase.Combat.Mouse.Alpha
--			Duration = DataBase.Combat.Mouse.Duration.Off
--			if not InCombat then
--				Alpha.End = DataBase.Combat.Alpha.Out
--			else
--				Alpha.End = DataBase.Combat.Alpha.In
--			end
--		else
--			if not InCombat then
--				Alpha.Start = DataBase.Combat.Alpha.Out
--			end
--		end

--		local DeltaAlpha = abs(Alpha.End - Alpha.Start)

--		if DataBase.Combat.Mouse.Enabled then
--			ElvUI_Animations:MouseOverFade(
--				E.db.ElvUI_Animations[Index].Config.Frame,
--				Index,
--				Alpha.End,
--				(DeltaAlpha/Duration)*DeltaTime)
--		end
--	end
--end

--function ElvUI_Animations:MouseOverFade(FrameString, Index, Alpha, Speed)	
--	for i = 1, #FrameString do
--		local Frame = GetClickFrame(FrameString[i])

--		if Frame ~= nil and Frame:IsShown() == true and not V.ElvUI_Animations.Animation.AnimationGroup[Index][i]:IsPlaying() then
--			if abs(V.ElvUI_Animations.AlphaBuildUp[Index][i] + Speed) > 0.01 then				
--				if Frame:GetAlpha() < Alpha then
--					if  Frame:GetAlpha() + Speed + V.ElvUI_Animations.AlphaBuildUp[Index][i] >= Alpha then
--						Frame:SetAlpha(Alpha)
--					else 
--						Frame:SetAlpha(Frame:GetAlpha() + Speed + V.ElvUI_Animations.AlphaBuildUp[Index][i])
--					end
--				end
--				if Frame:GetAlpha() > Alpha then
--					if Frame:GetAlpha() - Speed - V.ElvUI_Animations.AlphaBuildUp[Index][i] <= Alpha then
--						Frame:SetAlpha(Alpha)
--					else
--						Frame:SetAlpha(Frame:GetAlpha() - Speed - V.ElvUI_Animations.AlphaBuildUp[Index][i])
--					end
--				end

--				V.ElvUI_Animations.AlphaBuildUp[Index][i] = 0
--			else
--				V.ElvUI_Animations.AlphaBuildUp[Index][i] = V.ElvUI_Animations.AlphaBuildUp[Index][i] + Speed	
--			end
--		end
--	end
--end
function _AddonTable._Core:Animate(KeyName)
	if KeyName == nil then
		for k, v in pairs(_DataBase) do
			if string.find(k, "_Tab") and k ~= "Default_Tab" then
				self:Animate(k)
			end
		end
	else
		if _DataBase[KeyName].Animation.Enabled then
			for i = 1, #_DataBase[KeyName].Config.Frame do
				if _Animations[KeyName].AnimationGroup[i] ~= nil and GetClickFrame(_DataBase[KeyName].Config.Frame[i]):IsVisible()  then
					_Animations[KeyName].AnimationGroup[i]:Play()
				end
			end
		end
	end
end

function _AddonTable._Core:CombatAnimate(KeyName)
	if KeyName == nil then
		for k, v in pairs(_DataBase) do
			if string.find(k, "_Tab") and k ~= "Default_Tab" then
				self:CombatAnimate(k)
			end
		end
	else
		if _DataBase[KeyName].Combat.Enabled then
			for i = 1, #_DataBase[KeyName].Config.Frame do
				if _CombatAnimations[KeyName].AnimationGroup[i] ~= nil and GetClickFrame(_DataBase[KeyName].Config.Frame[i]):IsVisible() then
					if self.InCombat then
						_CombatAnimations[KeyName].AnimationGroup[i].In:Play()
					elseif not self.InCombat then
						_CombatAnimations[KeyName].AnimationGroup[i].Out:Play()
					end
				end
			end
		end
	end
end

function _AddonTable._Core:OnLoad()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
	self:RegisterEvent("PLAYER_STARTED_MOVING", "OnEvent")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEvent")
	self:RegisterEvent("PLAYER_FLAGS_CHANGED", "OnEvent")
	
	self:SetScript("OnEvent", self.OnEvent)
--	self:SetScript("OnUpdate",
--		function(self, elapsed)
--			ElvUI_Animations:OnUpdate(elapsed)
--		end)

	self.MyWorldFrame = CreateFrame("Frame", "Test", WorldFrame)

	self.MyWorldFrame:SetPropagateKeyboardInput(true)

	self.MyWorldFrame:SetScript("OnKeyDown", 
		function(self, button)
			_AddonTable._Core:OnEvent("PLAYER_STARTED_MOVING")
		end)

	self.ShouldAppear = false
	self.InCombat = false
end

function _AddonTable._Core:OnEvent(Event, ...)
	if Event == "PLAYER_ENTERING_WORLD" then
		_DataBase = E.db.ElvUI_Animations
		_Cache:Init()
		_Config:Init()

		_Animations:SetAnimGroups()
		_Cache:AnimTab()

		_CombatAnimations:SetAnimGroups()
		_Cache:CombatAnimTab()
		
		if _DataBase.Animate then
			if _DataBase.Lag then
				UIParent:Hide()
			else
				UIParent:SetAlpha(0)
			end

			self.MyWorldFrame:Show()
			self.ShouldAppear = true
		end
	end

	if (Event == "PLAYER_STARTED_MOVING" or Event == "PLAYER_REGEN_DISABLED") and self.ShouldAppear and _DataBase.Animate then
		if _DataBase.Lag then
			UIParent:Show()
		else
			UIParent:SetAlpha(1)
		end
		self.MyWorldFrame:Hide()
		UIParent:Show()
		self:Animate()
		self.ShouldAppear = false		
	end
	if Event == "PLAYER_FLAGS_CHANGED" and UnitIsAFK("player") and _DataBase.Animate and _DataBase.AFK then
		self.MyWorldFrame:Show()
		self.ShouldAppear = true
	end

	if Event == "PLAYER_REGEN_DISABLED" then
		self.InCombat = true
		self:CombatAnimate()
	end
	if Event == "PLAYER_REGEN_ENABLED" then
		self.InCombat = false
		self:CombatAnimate()
	end
end

--function ElvUI_Animations:OnUpdate(DeltaTime)
--	local FocusFrame = GetMouseFocus()

--	local TouchingChildFrame

--	if FocusFrame ~= nil and E.db.ElvUI_Animations.Combat then
--		for i = 2, #E.db.ElvUI_Animations do
--			TouchingChildFrame = false
--			for j = 1, #E.db.ElvUI_Animations[i].Config.Frame do
--				local FrameAtIndex = GetClickFrame(E.db.ElvUI_Animations[i].Config.Frame[j])
--				if FrameAtIndex ~= nil and (MouseIsOver(FrameAtIndex) and FrameAtIndex:IsShown()) then
--					TouchingChildFrame = true
--					ElvUI_Animations:AttemptMouseOverFade(i, DeltaTime, "Focus")
--				end
--			end
--			if not TouchingChildFrame then
--				ElvUI_Animations:AttemptMouseOverFade(i, DeltaTime, "Non-Focus")
--			end
--		end
--	end

--	PrevFocusFrame = FocusFrame

--	--collectgarbage()
--end

_AddonTable._Core:OnLoad()

---------------------------------------------------------------------------------------------------------------------------------------
-- End of Core.lua
---------------------------------------------------------------------------------------------------------------------------------------