local function copy (t) -- shallow-copy a table
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do target[k] = v end
    setmetatable(target, meta)
    return target
end

--[[
    This is a framework showing how to create a plugin for ElvUI.
    It creates some default options and inserts a GUI table to the ElvUI Config.
    If you have questions then ask in the Tukui lua section: http://www.tukui.org/forums/forum.php?id=27
]]

local E, L, V, P, G = unpack(ElvUI); -- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local ElvUI_Animations = E:NewModule('ElvUI_AnimationsName', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0'); -- Create a plugin within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.
ElvUI_Animations.version = GetAddOnMetadata("ElvUI_Animations", "Version")

local EP = LibStub("LibElvUIPlugin-1.0") -- We can use this to automatically insert our GUI tables when ElvUI_Config is loaded.
local addonName, addonTable = ... -- See http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2

local MyWorldFrame -- Will be used to create an invisible frame parented to the actual WorldFrame
local MyUIParent

local CombatAnimationGroup = { { } }
local CombatAlphaAnimation = { { } }

local PrevFocusFrame = nil
local InCombat = false

local AlphaBuildUp = { } -- For some reason adding less than 0.01 alpha to a frame seems to cause floating point error where it isn't added to the overall alpha of the frame

ANIMATION_TABLE = {
	{	
		TableName = "Fade",
	},
	{
		TableName = "Slide",
	},
	{
		TableName = "Bounce",
	},
}

local DEFAULT = {
	Enabled = true,

	UseDefaults = true,

	Default = 
	{
		Duration = 1.5,
		
		Delay = 
		{
			Start = 0,
			End = 0,
		},
	},
	
	Combat = 
	{
		Enabled = true,
		
		UseDefaults = true,

		Duration = 
		{
			In = 0.3,
			Out = 1,
		},

		Alpha = 
		{
			In = 0.1,
			Out = 0.9,
		},
		
		Smoothing = 
		{
			In = "IN",
			Out = "IN",
		},
		
		Mouse = 
		{
			Enabled = true,
		
			Duration = 
			{
				On = 0.2,
				Off = 0.2,
			},
			
			Alpha = 1,
		},
	},

	Fade =
	{
		Enabled = true,

		Duration =
		{
			Enabled = false,

			Length = 0.3,

			Delay = 
			{
				Start = 0,
				End = 0,
			},
		},

		Alpha = 
		{
			Start = 0,
			End = 1,
		},

		Smoothing = "IN",
	},
	Slide =
	{
		Enabled = false,

		Duration =
		{
			Enabled = false,

			Length = 0.3,

			Delay = 
			{
				Start = 0,
				End = 0,
			},
		},

		Offset =
		{
			X = -5,
			Y = -10,
		},
		Distance = 
		{
			X = 5,
			Y = 10,
		},

		Smoothing = "NONE",
	},
	Bounce =
	{
		Enabled = false,

		Duration =
		{
			Enabled = false,

			Length = 0.3,

			Delay = 
			{
				Start = 0,
				End = 0,
			},
		},

		Offset =
		{
			X = -5,
			Y = -10,
		},
		Distance = 
		{
			X = 5,
			Y = 10,
		},

		Smoothing = "NONE",
	},

	UI_Table = { },
}

local DEFAULT_MAX_FRAMES = 14

-- Set up the table, but leave it empty
P.ElvUI_Animations = { Animate = true, Combat = true, { }, }

-- Created the defaults table for the addon. ElvUI does some magic here, somehow it ends up being named the same
for i = 1, DEFAULT_MAX_FRAMES do
	P.ElvUI_Animations[i] = copy(DEFAULT)
end

P.ElvUI_Animations[1].UI_Table =
{
	TableName = "Default",
	Frame = { "All" },
	Name = "Default",
	Error = false,
}
P.ElvUI_Animations[2].UI_Table = 
{
	TableName = "Player",
	Frame = { "ElvUF_Player", Fade = { "ElvUF_Player.Portrait" }, },
	Name = "Player Frame",
	Error = { },
}	
P.ElvUI_Animations[3].UI_Table = 
{
	TableName = "Target",
	Frame = { "ElvUF_Target", Fade = { "ElvUF_Target.Portrait" }, },
	Name = "Target Frame",
	Error = { },
}

P.ElvUI_Animations[4].UI_Table = 
{
	TableName = "LeftChatPanel",
	Frame = { "LeftChatPanel", "ElvUI_ExperienceBar", "LeftChatToggleButton", Fade = { }, },
	Name = "Left Chat Panel",
	Error = { },
}
P.ElvUI_Animations[5].UI_Table = 
{
	TableName = "RightChatPanel",
	Frame = { "RightChatPanel", "ElvUI_ReputationBar", "RightChatToggleButton", Fade = { }, },
	Name = "Right Chat Panel",
	Error = { },
}

P.ElvUI_Animations[6].UI_Table = 
{
	TableName = "ObjectiveFrame",
	Frame = { "ObjectiveTrackerFrame", Fade = { }, },
	Name = "Objective Frame",
	Error = { },
}

P.ElvUI_Animations[7].UI_Table = 
{
	TableName = "MiniMap",
	Frame = { "MinimapCluster", "MinimapButtonBar", Fade = { }, },
	Name = "MiniMap",
	Error = { },
}

local AfterUF = 8

for i = AfterUF, AfterUF + 6 do
	P.ElvUI_Animations[i].UI_Table = 
	{
		TableName = "Bar_" .. i - AfterUF + 1,
		Frame = { "ElvUI_Bar"..i - AfterUF + 1, Hide = { }, },
		Name = "Bar " .. i - AfterUF + 1,
		Error = { },
	}
end

P.ElvUI_Animations[AfterUF + 6].UI_Table = 
{
	TableName = "BottomPanel",
	Frame = { "ElvUI_BottomPanel", Hide = { }, },
	Name = "Bottom Panel",
	Error = { },
}

function ElvUI_Animations:ReloadCombatAnimationGroup()
	for i = 1, #E.db.ElvUI_Animations do
		if i ~= 1 then
			CombatAnimationGroup[i] = { }
			CombatAlphaAnimation[i] = { }
			for j = 1, #E.db.ElvUI_Animations[i].UI_Table.Frame do
				local FrameAtIndex = GetClickFrame(E.db.ElvUI_Animations[i].UI_Table.Frame[j])

				if  FrameAtIndex ~= nil then
					CombatAnimationGroup[i][j] = FrameAtIndex:CreateAnimationGroup()
					CombatAlphaAnimation[i][j] = CombatAnimationGroup[i][j]:CreateAnimation("Alpha")
				end
			end
		end

		AlphaBuildUp[i] = 0
	end
end

-- Function we can call when a setting changes.
function ElvUI_Animations:Update(Index)
	ElvUI_Animations:ReloadCombatAnimationGroup()

	-- I had to shorten these variables, they are WAY too long
	local DataBase = E.db.ElvUI_Animations[Index]
	local Animation = E.Options.args.ElvUI_Animations.args[DataBase.UI_Table.TableName].args.Animation
	local Combat = E.Options.args.ElvUI_Animations.args[DataBase.UI_Table.TableName].args.Combat

	if Index ~= 1 then
		Animation.disabled = true
		Animation.args.General.disabled = true
		Animation.args.General.args.UseDefaults.disabled = true
		for i = 1, #ANIMATION_TABLE do
			Animation.args[ANIMATION_TABLE[i].TableName].args.General.disabled = true
			Animation.args[ANIMATION_TABLE[i].TableName].args.Enabled.disabled = true
			Animation.args[ANIMATION_TABLE[i].TableName].args.Duration.disabled = true
			Animation.args[ANIMATION_TABLE[i].TableName].args.Duration.args.Enabled.disabled = true
		end

		if E.db.ElvUI_Animations.Animate then
			Animation.disabled = false
			if DataBase.Enabled then
				Animation.args.General.args.UseDefaults.disabled = false

				if not DataBase.UseDefaults then
					Animation.args.General.disabled = false
					for i = 1, #ANIMATION_TABLE do
						Animation.args[ANIMATION_TABLE[i].TableName].args.Enabled.disabled = false

						if DataBase[ANIMATION_TABLE[i].TableName].Enabled then
							Animation.args[ANIMATION_TABLE[i].TableName].args.General.disabled = false

							Animation.args[ANIMATION_TABLE[i].TableName].args.Duration.args.Enabled.disabled = false
							if DataBase[ANIMATION_TABLE[i].TableName].Duration.Enabled then
								Animation.args[ANIMATION_TABLE[i].TableName].args.Duration.disabled = false
							end
						end
					end
				end
			end	
		end

		Combat.disabled = true
		Combat.args.UseDefaults.disabled = true

		Combat.args.Alpha.disabled = true
		Combat.args.Duration.disabled = true
		Combat.args.Smoothing.disabled = true	

		Combat.args.Mouse.disabled = true
		Combat.args.Mouse.args.Enabled.disabled = true

		if E.db.ElvUI_Animations.Combat then
			Combat.disabled = false

			if DataBase.Combat.Enabled then
				Combat.args.UseDefaults.disabled = false
				if not DataBase.Combat.UseDefaults then
					Combat.args.Alpha.disabled = false
					Combat.args.Duration.disabled = false
					Combat.args.Smoothing.disabled = false

					Combat.args.Mouse.args.Enabled.disabled = false
					if DataBase.Combat.Mouse.Enabled then
						Combat.args.Mouse.disabled = false
					end
				end
			end
		end		
	else 
		Animation.disabled = true
		for i = 1, #ANIMATION_TABLE do
			Animation.args[ANIMATION_TABLE[i].TableName].args.General.disabled = true
			Animation.args[ANIMATION_TABLE[i].TableName].args.Enabled.disabled = false
			Animation.args[ANIMATION_TABLE[i].TableName].args.Duration.disabled = true
			Animation.args[ANIMATION_TABLE[i].TableName].args.Duration.args.Enabled.disabled = true

			if E.db.ElvUI_Animations.Animate then
				Animation.disabled = false

				if DataBase[ANIMATION_TABLE[i].TableName].Enabled then
					Animation.args[ANIMATION_TABLE[i].TableName].args.General.disabled = false

					Animation.args[ANIMATION_TABLE[i].TableName].args.Duration.args.Enabled.disabled = false
					if DataBase[ANIMATION_TABLE[i].TableName].Duration.Enabled then
						Animation.args[ANIMATION_TABLE[i].TableName].args.Duration.disabled = false
					end
				end
			end
		end

		Combat.args.Mouse.disabled = true
		Combat.args.Mouse.args.Enabled.disabled = false


		if DataBase.Combat.Mouse.Enabled then
			Combat.args.Mouse.disabled = false
		end
	end
end

function ElvUI_Animations:Appear(Index)
	if E.db.ElvUI_Animations[Index].Enabled then
		ElvUI_Animations:AttemptSlide(Index)
		ElvUI_Animations:AttemptFade(Index)		
	end
end

function ElvUI_Animations:AttemptSlide(Index)
	local DataBase = E.db.ElvUI_Animations[Index]

	if DataBase.UseDefaults then
		DataBase = E.db.ElvUI_Animations[1]
	end

	for i = 2, 3 do
		local Parameters = { }
		local SetPos = false

		if ANIMATION_TABLE[i].TableName == "Slide" then
			Parameters = DataBase.Slide
			SetPos = true
		end			
		if ANIMATION_TABLE[i].TableName == "Bounce" then
			Parameters = DataBase.Bounce	
		end

		if Parameters.Enabled then
			local Duration = DataBase.Default.Duration
			local Delay = DataBase.Default.Delay

			if Parameters.Duration.Enabled then
				Duration = Parameters.Duration.Length
				Delay = Parameters.Duration.Delay
			end

			ElvUI_Animations:Slide(
				E.db.ElvUI_Animations[Index].UI_Table.Frame, 
				Duration, 
				Parameters.Offset, 
				Parameters.Distance, 
				Parameters.Smoothing, 
				Delay,
				SetPos)
		end
	end
end

function ElvUI_Animations:AttemptFade(Index)
	local DataBase = E.db.ElvUI_Animations[Index]

	if DataBase.UseDefaults then
		DataBase = E.db.ElvUI_Animations[1]
	end

	if DataBase.Fade.Enabled then
		local Duration = DataBase.Default.Duration
		local Delay = DataBase.Default.Delay

		if DataBase.Fade.Duration.Enabled then
			Duration = DataBase.Fade.Duration.Length
			Delay = DataBase.Fade.Duration.Delay
		end

		ElvUI_Animations:Fade(
			E.db.ElvUI_Animations[Index].UI_Table.Frame, 
			Duration, 
			DataBase.Fade.Alpha,
			DataBase.Fade.Smoothing, 
			Delay)
	end
end

function ElvUI_Animations:Slide(FrameString, Duration, Offset, Distance, Smoothing, Delay, SetPos)	
	for i = 1, #FrameString do
		local Frame = GetClickFrame(FrameString[i])

		if Frame ~= nil and Frame:IsShown() == true then	
			for j = 1, #FrameString.Hide do
				GetClickFrame(FrameString.Hide[j]):Hide()
			end

			local Point, RelativeTo, RelativePoint, PosX, PosY = { }, { }, { }, { }, { }
			Point[i], RelativeTo[i], RelativePoint[i], PosX[i], PosY[i] = Frame[i]:GetPoint()

			Frame:ClearAllPoints()
			Frame:SetPoint(Point[i], RelativeTo[i], RelativePoint[i],
					PosX[i] + Offset.X,
					PosY[i] + Offset.Y)

			local AnimationGroup = Frame[i]:CreateAnimationGroup()
			local TranslateFrame = AnimationGroup:CreateAnimation("Translation")

			TranslateFrame:SetDuration(Duration)

			TranslateFrame:SetStartDelay(Delay.Start)
			TranslateFrame:SetEndDelay(Delay.End)

			TranslateFrame:SetOffset(Distance.X, Distance.Y)

			TranslateFrame:SetSmoothing(Smoothing)

			AnimationGroup:Play()

			if SetPos then
				AnimationGroup:SetScript("OnFinished",
				function()
					Frame:ClearAllPoints()
					Frame:SetPoint(Point[i], RelativeTo[i], RelativePoint[i], PosX[i], PosY[i])
					for i = j, #Frame.Hide do
						GetClickFrame(FrameString.Hide[j]):Show()
					end
				end )
			end
		end
	end
end

function ElvUI_Animations:Fade(FrameString, Duration, Alpha, Smoothing, Delay)
	for i = 1, #FrameString do
		local Frame = GetClickFrame(FrameString[i])

		if Frame ~= nil and Frame:IsShown() == true then
			Frame:SetAlpha(Alpha.Start)

			local AnimationGroup = Frame:CreateAnimationGroup()

			local FadeFrame = AnimationGroup:CreateAnimation("Alpha")
			FadeFrame:SetDuration(Duration)

			FadeFrame:SetStartDelay(Delay.Start)
			FadeFrame:SetEndDelay(Delay.End)

			FadeFrame:SetChange(Alpha.End - Alpha.Start)

			FadeFrame:SetSmoothing(Smoothing)

			AnimationGroup:Play()

			AnimationGroup:SetScript("OnFinished",
			function()
				Frame:SetAlpha(Alpha.End)
			end )
		end
	end
end

function ElvUI_Animations:AttemptCombatFade(Index, Option)
	local DataBase = E.db.ElvUI_Animations[Index]
	
	if DataBase.Combat.Enabled then	
		if DataBase.Combat.UseDefaults then
			DataBase = E.db.ElvUI_Animations[1]
		end
		ElvUI_Animations:CombatFade(
			E.db.ElvUI_Animations[Index].UI_Table.Frame, 
			Index, 
			DataBase.Combat.Duration[Option],
			DataBase.Combat.Alpha[Option],
			DataBase.Combat.Smoothing[Option])
	end
end

function ElvUI_Animations:CombatFade(FrameString, Index, Duration, Alpha, Smoothing)
	for i = 1, #FrameString do
		local Frame = GetClickFrame(FrameString[i])

		if Frame ~= nil and Frame:IsShown() == true then
			CombatAnimationGroup[Index][i]:Stop()

			CombatAlphaAnimation[Index][i]:SetDuration(Duration)

			CombatAlphaAnimation[Index][i]:SetChange(Alpha - Frame:GetAlpha())

			CombatAlphaAnimation[Index][i]:SetSmoothing(Smoothing)

			CombatAnimationGroup[Index][i]:Play()

			CombatAnimationGroup[Index][i]:SetScript("OnFinished",
				function()
					Frame:SetAlpha(Alpha)
				end )
		end
	end
end

function ElvUI_Animations:AttemptMouseOverFade(Index, DeltaTime, Option)
	local DataBase = E.db.ElvUI_Animations[Index]

	if DataBase.Combat.Enabled then
		if DataBase.Combat.UseDefaults then
			DataBase = E.db.ElvUI_Animations[1]
		end

		local Alpha = { Start = DataBase.Combat.Alpha.In, End = DataBase.Combat.Mouse.Alpha }
		local Duration = DataBase.Combat.Mouse.Duration.On

		if Option ~= "Focus" then
			Alpha.Start = DataBase.Combat.Mouse.Alpha
			Duration = DataBase.Combat.Mouse.Duration.Off
			if not InCombat then
				Alpha.End = DataBase.Combat.Alpha.Out
			else
				Alpha.End = DataBase.Combat.Alpha.In
			end
		else
			if not InCombat then
				Alpha.Start = DataBase.Combat.Alpha.Out
			end
		end

		local DeltaAlpha = abs(Alpha.End - Alpha.Start)

		if DataBase.Combat.Mouse.Enabled then
			ElvUI_Animations:MouseOverFade(
				E.db.ElvUI_Animations[Index].UI_Table.Frame,
				Index,
				Alpha.End,
				(DeltaAlpha/Duration)*DeltaTime)
		end
	end
end

function ElvUI_Animations:MouseOverFade(FrameString, Index, Alpha, Speed)	
	for i = 1, #FrameString do
		local Frame = GetClickFrame(FrameString[i])

		if Frame ~= nil and Frame:IsShown() == true then
			if abs(AlphaBuildUp[Index] + Speed) > 0.01 then				
				if Frame:GetAlpha() < Alpha then
					if  Frame:GetAlpha() + Speed + AlphaBuildUp[Index] >= Alpha then
						Frame:SetAlpha(Alpha)
					else 
						Frame:SetAlpha(Frame:GetAlpha() + Speed + AlphaBuildUp[Index])
					end
				end
				if Frame:GetAlpha() > Alpha then
					if Frame:GetAlpha() - Speed - AlphaBuildUp[Index] <= Alpha then
						Frame:SetAlpha(Alpha)
					else
						Frame:SetAlpha(Frame:GetAlpha() - Speed - AlphaBuildUp[Index])
					end
				end

				AlphaBuildUp[Index] = 0
			else
				AlphaBuildUp[Index] = AlphaBuildUp[Index] + Speed	
			end
		end
	end
end

function ElvUI_Animations:CreateAnimationPage(Index, Option, Order)	
	local AnimationPage = { }
	
	AnimationPage =
	{
		order = Order,
		type = "group",
		name = Option,
		args =
		{
			Enabled =
			{
				order = 1,
				type = "toggle",
				name = "Enabled",
				desc = "Whether or not to "..Option.." this frame",
				get = function(info)
					return E.db.ElvUI_Animations[Index][Option].Enabled
				end,
				set = function(info, value)
					E.db.ElvUI_Animations[Index][Option].Enabled = value
					ElvUI_Animations:Update(Index)
					-- We changed a setting, call our Update function
				end,
			},
			General = 
			{
				order = 2,
				type = "group",
				name = "General Options",
				guiInline = true,
				args = 
				{
					Smoothing = 
					{
						order = -1,
						type = "select",
						name = "Smoothing",
						desc = "The type of smoothing to use for the animation",
						values =
						{
							NONE = "None",
							IN = "In",
							OUT = "Out",
							IN_OUT = "In/Out",
						},
						get = function(info)
							return E.db.ElvUI_Animations[Index][Option].Smoothing
						end,
						set = function(info, value)
							E.db.ElvUI_Animations[Index][Option].Smoothing = value
						end,
					},
				},
			},
			
			Duration = 
			{
				order = -1,
				type = "group",
				name = "Individual Duration",
				guiInline = true,
				args = 
				{
					Enabled =
					{
						order = 1,
						type = "toggle",
						name = "Enabled",
						desc = "Whether or not to use an individual animation duration",
						get = function(info)
							return E.db.ElvUI_Animations[Index][Option].Duration.Enabled
						end,
						set = function(info, value)
							E.db.ElvUI_Animations[Index][Option].Duration.Enabled = value
							ElvUI_Animations:Update(Index)
							-- We changed a setting, call our Update function
						end,
					},	
					Length = 
					{
						order = 2,
						type = "range",
						name = Option.." Duration",
						desc = "How long it will take to "..Option.." the frame",
						min = 0,
						max = 5,
						step = 0.1,
						get = function(info)
							return E.db.ElvUI_Animations[Index][Option].Duration.Length
						end,
						set = function(info, value)
							E.db.ElvUI_Animations[Index][Option].Duration.Length = value
						end,
					},				
					StartDelay = 
					{
						order = 3,
						type = "range",
						name = Option.." Start Delay",
						desc = "How long to wait until the animation should start",
						min = 0,
						max = 5,
						step = 0.1,
						get = function(info)
							return E.db.ElvUI_Animations[Index][Option].Duration.Delay.Start
						end,
						set = function(info, value)
							E.db.ElvUI_Animations[Index][Option].Duration.Delay.Start = value
						end,
					},
					EndDelay = 
					{
						order = 4,
						type = "range",
						name = Option.." End Delay",
						desc = "How long to wait after the animation has stopped until it should be considered finished",
						min = 0,
						max = 5,
						step = 0.1,
						get = function(info)
							return E.db.ElvUI_Animations[Index][Option].Duration.Delay.End
						end,
						set = function(info, value)
							E.db.ElvUI_Animations[Index][Option].Duration.Delay.End = value
						end,
					},
				},
			},
			TestButton =
			{
				order = - 1,
				type = "execute",
				name = "Test It!",
				desc = Option.." the selected frame",
				func = function()
					local Loop = { Start = Index, End = Index,}

					if Index == 1 then
						Loop = { Start = 2, End = #E.db.ElvUI_Animations, }
					end
						
					for i = 2, Loop.End do
						if Option == "Fade" then
							ElvUI_Animations:AttemptFade(i)
						end
						if Option == "Slide" or Option == "Bounce" then
							ElvUI_Animations:AttemptSlide(i)
						end
					end
				end,
			},
				
		},
	}
	
	if Option == "Fade" then
		local OptionAnimation = "Alpha"
		AnimationPage.args.General.args["Start"..OptionAnimation] = 
		{
			order = 1,
			type = "range",
			name = "Start "..OptionAnimation,
			desc = "What "..OptionAnimation.." the animation should start at",
			min = 0,
			max = 1,
			step = 0.01,
			get = function(info)
				return E.db.ElvUI_Animations[Index].Fade.Alpha.Start
			end,
			set = function(info, value)
				E.db.ElvUI_Animations[Index].Fade.Alpha.Start = value
			end,									
		}
		AnimationPage.args.General.args["End"..OptionAnimation] = 
		{
			order = 2,
			type = "range",
			name = "End "..OptionAnimation,
			desc = "What "..OptionAnimation.." the animation should end at",
			min = 0,
			max = 1,
			step = 0.01,
			get = function(info)
				return E.db.ElvUI_Animations[Index].Fade.Alpha.End
			end,
			set = function(info, value)
				E.db.ElvUI_Animations[Index].Fade.Alpha.End = value
			end,									
		}
	end
	if Option == "Slide" or Option == "Bounce" then
		local OptionAnimation = "Offset"
		AnimationPage.args.General.args[OptionAnimation.."X"] = 
		{
			order = 1,
			type = "range",
			name = OptionAnimation.."X",
			desc = "What X "..OptionAnimation.." the animation should start at",
			min = -150,
			max = 150,
			step = 5,
			get = function(info)
				return E.db.ElvUI_Animations[Index][Option].Offset.X
			end,
			set = function(info, value)
				E.db.ElvUI_Animations[Index][Option].Offset.X = value
			end,									
		}
		AnimationPage.args.General.args[OptionAnimation.."Y"] = 
		{
			order = 2,
			type = "range",
			name = OptionAnimation.."Y",
			desc = "What Y "..OptionAnimation.." the animation should start at",
			min = -150,
			max = 150,
			step = 5,
			get = function(info)
				return E.db.ElvUI_Animations[Index][Option].Offset.Y
			end,
			set = function(info, value)
				E.db.ElvUI_Animations[Index][Option].Offset.Y = value
			end,									
		}
		AnimationPage.args.General.args["DistanceX"] = 
		{
			order = 3,
			type = "range",
			name = "DistanceX",
			desc = "How far in the X direction the frame should travel",
			min = -150,
			max = 150,
			step = 5,
			get = function(info)
				return E.db.ElvUI_Animations[Index][Option].Distance.X
			end,
			set = function(info, value)
				E.db.ElvUI_Animations[Index][Option].Distance.X = value
			end,
		}
		AnimationPage.args.General.args["DistanceY"] = 
		{
			order = 4,
			type = "range",
			name = "DistanceY",
			desc = "How far in the Y direction the frame should travel",
			min = -150,
			max = 150,
			step = 5,
			get = function(info)
				return E.db.ElvUI_Animations[Index][Option].Distance.Y
			end,
			set = function(info, value)
				E.db.ElvUI_Animations[Index][Option].Distance.Y = value
			end,
		}
	end
	
	return AnimationPage
end

-- This function inserts our GUI table into the ElvUI Config. You can read about AceConfig here: http://www.wowace.com/addons/ace3/pages/ace-config-3-0-options-tables/
function ElvUI_Animations:InsertOptions()		
	E.Options.args.ElvUI_Animations = {
		order = 100,
		type = "group",
		name = "|cff00b3ffAnimations|r",
		args =
		{
			Animate = 
			{
				order = 1,
				type = "toggle",
				name = "Enable Animations",
				desc = "Whether or not to animate the frames after a load screen",
				get = function(info)
					return E.db.ElvUI_Animations.Animate
				end,
				set = function(info, value)
					E.db.ElvUI_Animations.Animate = value
					for i = 1, #E.db.ElvUI_Animations do
						ElvUI_Animations:Update(i)
					end
				end,
			},
			Combat = 
			{
				order = 2,
				type = "toggle",
				name = "Enable Combat Fade",
				desc = "Whether or not to fade based on combat flags options",
				get = function(info)
					return E.db.ElvUI_Animations.Combat
				end,
				set = function(info, value)
					E.db.ElvUI_Animations.Combat = value
					for i = 1, #E.db.ElvUI_Animations do
						ElvUI_Animations:Update(i)
					end
				end,
			},
			Delete = 
			{
				order = 5,
				type = "execute",
				name = "Restore Defaults",
				desc = "Restore all values back to default, but just for this addon not ElvUI don't worry!",
				func = function()
					E.db.ElvUI_Animations = P.ElvUI_Animations
					for i = 1, #E.db.ElvUI_Animations do
						ElvUI_Animations:Update(i)
					end
				end,
			},			
		},
	}
	
	for i = 1, #E.db.ElvUI_Animations do					
		E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].UI_Table.TableName] = {
			order = i + 10 + #E.db.ElvUI_Animations,
			type = "group",
			name = E.db.ElvUI_Animations[i].UI_Table.Name,
			childGroups = "tab",	
			args =
			{
				Combat = 
				{
					order = 1,
					type = "group",
					name = "Combat Fade Options",
					args = 
					{
						Alpha = 
						{
							order = 5,
							type = "group",
							name = "Alpha Options",
							guiInline = true,
							args = 
							{
								In =
								{
									order = 1,
									type = "range",
									name = "In Combat Alpha",
									desc = "What alpha the frame should be set to when in combat",
									min = 0,
									max = 1,
									step = 0.01,
									get = function(info)
										return E.db.ElvUI_Animations[i].Combat.Alpha.In
									end,
									set = function(info, value)
										E.db.ElvUI_Animations[i].Combat.Alpha.In = value
									end,
								},
								Out =
								{
									order = 2,
									type = "range",
									name = "Out of Combat Alpha",
									desc = "What alpha the frame should be set to when not in combat",
									min = 0,
									max = 1,
									step = 0.01,
									get = function(info)
										return E.db.ElvUI_Animations[i].Combat.Alpha.Out
									end,
									set = function(info, value)
										E.db.ElvUI_Animations[i].Combat.Alpha.Out = value
									end,
								},
							},
						},
						Duration = 
						{
							order = 6,
							type = "group",
							name = "Duration Options",
							guiInline = true,
							args = 
							{
								In =
								{
									order = 1,
									type = "range",
									name = "To In Combat Alpha",
									desc = "How long it should take to fade to the in combat alpha",
									min = 0,
									max = 5,
									step = 0.1,
									get = function(info)
										return E.db.ElvUI_Animations[i].Combat.Duration.In
									end,
									set = function(info, value)
										E.db.ElvUI_Animations[i].Combat.Duration.In = value
									end,
								},
								Out =
								{
									order = 2,
									type = "range",
									name = "To Out of Combat Alpha",
									desc = "How long it should take to fade to the out of combat alpha",
									min = 0,
									max = 5,
									step = 0.1,
									get = function(info)
										return E.db.ElvUI_Animations[i].Combat.Duration.Out
									end,
									set = function(info, value)
										E.db.ElvUI_Animations[i].Combat.Duration.Out = value
									end,
								},
									
							},
						},
						Smoothing = 
						{
							order = 7,
							type = "group",
							name = "Smoothing Options",
							guiInline = true,
							args = 
							{
								In = 
								{
									order = 1,
									type = "select",
									name = "In Combat Smoothing",
									desc = "The type of smoothing to use when fading to the in combat alpha",
									values =
									{
										NONE = "None",
										IN = "In",
										OUT = "Out",
										IN_OUT = "In/Out",
									},
									get = function(info)
										return E.db.ElvUI_Animations[i].Combat.Smoothing.In
									end,
									set = function(info, value)
										E.db.ElvUI_Animations[i].Combat.Smoothing.In = value
									end,
								},
								Out = 
								{
									order = 1,
									type = "select",
									name = "Out of Combat Smoothing",
									desc = "The type of smoothing to use when fading to the out of combat alpha",
									values =
									{
										NONE = "None",
										IN = "In",
										OUT = "Out",
										IN_OUT = "In/Out",
									},
									get = function(info)
										return E.db.ElvUI_Animations[i].Combat.Smoothing.Out
									end,
									set = function(info, value)
										E.db.ElvUI_Animations[i].Combat.Smoothing.Out = value
									end,
								},
							},
						},
						Mouse = 
						{
							order = -1,
							type = "group",
							name = "Mouse Options",
							guiInline = true,
							args = 
							{
								Enabled = 
								{
									order = 1,
									type = "toggle",
									name = "Enable Mouse-Over",
									desc = "Whether or not to fade the frame based on current mouse focus",
									get = function(info)
										return E.db.ElvUI_Animations[i].Combat.Mouse.Enabled
									end,
									set = function(info, value)
										E.db.ElvUI_Animations[i].Combat.Mouse.Enabled = value
										ElvUI_Animations:Update(i)
										-- We changed a setting, call our Update function
									end,
								},
								DurationOn =
								{
									order = 2,
									type = "range",
									name = "To Mouse-Over Alpha",
									desc = "How long it should take to fade to the mouse-over alpha",
									min = 0,
									max = 5,
									step = 0.1,
									get = function(info)
										return E.db.ElvUI_Animations[i].Combat.Mouse.Duration.On
									end,
									set = function(info, value)
										E.db.ElvUI_Animations[i].Combat.Mouse.Duration.On = value
									end,
								},
								DurationOff =
								{
									order = 3,
									type = "range",
									name = "From Mouse-Over Alpha",
									desc = "How long it should take to fade back to it's original alpha",
									min = 0,
									max = 5,
									step = 0.1,
									get = function(info)
										return E.db.ElvUI_Animations[i].Combat.Mouse.Duration.Off
									end,
									set = function(info, value)
										E.db.ElvUI_Animations[i].Combat.Mouse.Duration.Off = value
									end,
								},
								Alpha =
								{
									order = 4,
									type = "range",
									name = "Mouse-Over Alpha",
									desc = "What alpha to set the frame to when moused over",
									min = 0,
									max = 1,
									step = 0.01,
									get = function(info)
										return E.db.ElvUI_Animations[i].Combat.Mouse.Alpha
									end,
									set = function(info, value)
										E.db.ElvUI_Animations[i].Combat.Mouse.Alpha = value
									end,
								},
							},
						}
					},
				},
					
				Animation =
				{
					order = 3,
					type = "group",
					name = "Animation Options",	
					args =
					{
						General = 
						{
							order = 5,
							type = "group",
							name = "General Options",
							guiInline = true,
							args = 
							{
								StartDelay =
								{
									order = 2,
									type = "range",
									name = "Animation Start Delay",
									desc = "How long to wait until the animation should start",
									min = 0,
									max = 5,
									step = 0.1,
									get = function(info)
										return E.db.ElvUI_Animations[i].Default.Delay.Start
									end,
									set = function(info, value)
										E.db.ElvUI_Animations[i].Default.Delay.Start = value
									end,
								},
								EndDelay =
								{
									order = 3,
									type = "range",
									name = "Animation End Delay",
									desc = "How long to wait after the animation has stopped until it should be considered finished",
									min = 0,
									max = 5,
									step = 0.1,
									get = function(info)
										return E.db.ElvUI_Animations[i].Default.Delay.End
									end,
									set = function(info, value)
										E.db.ElvUI_Animations[i].Default.Delay.End = value
									end,
								},
								Duration =
								{
									order = 4,
									type = "range",
									name = "Animation Duration",
									desc = "How long the animations will take",
									min = 0,
									max = 5,
									step = 0.1,
									get = function(info)
										return E.db.ElvUI_Animations[i].Default.Duration
									end,
									set = function(info, value)
										E.db.ElvUI_Animations[i].Default.Duration = value
									end,
								},
							},
						},	
						Division = 
						{
							order = 6,
							type = "header",
							name = "Animations",
						},				
					},
				},
			},
		}
		for j = 1, #ANIMATION_TABLE do 
			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].UI_Table.TableName].args.Animation.args[ANIMATION_TABLE[j].TableName] = ElvUI_Animations:CreateAnimationPage(i, ANIMATION_TABLE[j].TableName, j+5)
		end
				
		if i == 1 then
			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].UI_Table.TableName].args.Animation.args.TestAll = 
			{
				order = 1,
				type = "execute",
				name = "Test All!",
				desc = "Test all the animations at the same time",
				func = function()
					for i = 2, #E.db.ElvUI_Animations do
						ElvUI_Animations:Appear(i)
					end
				end,
			}
		else
			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].UI_Table.TableName.."Config"] = 
			{
				order = i + 10,
				type = "group",
				name = E.db.ElvUI_Animations[i].UI_Table.Name.." Configuration",
				guiInline = true,
				args =	
				{
					Name = 
					{
						order = 1,
						type = "input",
						name = "Rename Tab",
						get = function(info)
							return E.db.ElvUI_Animations[i].UI_Table.Name
						end,
						set = function(info, value)
							E.db.ElvUI_Animations[i].UI_Table.Name = value
								
							E.Options.args.ElvUI_Animations.args[string.gsub(value, "%s+", "")] = copy(E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].UI_Table.TableName])
				
							E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].UI_Table.TableName] = nil
								
							E.db.ElvUI_Animations[i].UI_Table.TableName = string.gsub(value, "%s+", "")
							ElvUI_Animations:InsertOptions()
						end,
					},
					Frames = 
					{
						order = 5,
						type = "input",
						name = "Change Frames",
						multiline = true,
						get = function(info)
							local ReturnString = ""

							for j = 1, #E.db.ElvUI_Animations[i].UI_Table.Frame do
								if E.db.ElvUI_Animations[i].UI_Table.Error[j] then
									--ReturnString = ReturnString.."|cffFF1010"	-- Not yet young one
								end

								ReturnString = ReturnString..E.db.ElvUI_Animations[i].UI_Table.Frame[j]..";\n"

								if E.db.ElvUI_Animations[i].UI_Table.Error[j] then
									--ReturnString = ReturnString.."|r" -- Not yet young one
								end
							end

							return ReturnString
						end,
						set = function(info, value)
								local Parse = string.gsub(value, "%s+", "")
								local Current = { Start = 1, End = string.len(Parse) }								
								
								local j = 1
								while string.find(Parse, ";") do
									Current.End = string.find(Parse, ";")
									E.db.ElvUI_Animations[i].UI_Table.Frame[j] = string.sub(Parse, Current.Start, Current.End - 1)
									
									Parse = string.sub(Parse, Current.End + 1, string.len(Parse))
					
									j = j + 1
								end

								ElvUI_Animations:InsertOptions()
						end,
					},	
					Header = 
					{
						order = 4,
						type = "header",
						name = "",
					},				
				},
			}
			
			if i ~= 2 then
				E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].UI_Table.TableName.."Config"].args.MoveUp =
				{
					order = 2,
					type = "execute",	
					name = "Move Up",
					desc = "Move this tab up one space",
					func = function()						
						local TableHolder = E.db.ElvUI_Animations[i]
					
						E.db.ElvUI_Animations[i] = E.db.ElvUI_Animations[i-1]
						E.db.ElvUI_Animations[i-1] = TableHolder					
						
						ElvUI_Animations:InsertOptions()
					end,
				}
			end
			if i ~= #E.db.ElvUI_Animations then
				E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].UI_Table.TableName.."Config"].args.MoveDown =
				{
					order = 3,
					type = "execute",	
					name = "Move Down",
					desc = "Move this tab Down one space",
					func = function()						
						local TableHolder = E.db.ElvUI_Animations[i]
					
						E.db.ElvUI_Animations[i] = E.db.ElvUI_Animations[i+1]
						E.db.ElvUI_Animations[i+1] = TableHolder					
						
						ElvUI_Animations:InsertOptions()
					end,
				}
			end

			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].UI_Table.TableName].args.Combat.args.Enabled = 
			{
				order = 1,
				type = "toggle",
				name = "Enabled",
				desc = "Whether or not to fade the frame based on combat flags",
				get = function(info)
					return E.db.ElvUI_Animations[i].Combat.Enabled
				end,
				set = function(info, value)
					E.db.ElvUI_Animations[i].Combat.Enabled = value
					ElvUI_Animations:Update(i)
					-- We changed a setting, call our Update function
				end,
			}
			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].UI_Table.TableName].args.Combat.args.UseDefaults = 
			{
				order = 2,
				type = "toggle",
				name = "Use Defaults",
				desc = "Whether or not to use the default values or set up individual values for this frame",
				get = function(info)
					return E.db.ElvUI_Animations[i].Combat.UseDefaults
				end,
				set = function(info, value)
					E.db.ElvUI_Animations[i].Combat.UseDefaults = value
					ElvUI_Animations:Update(i)
					-- We changed a setting, call our Update function
				end,
			}
			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].UI_Table.TableName].args.Animation.args.Enabled =
			{
				order = 1,
				type = "toggle",
				name = "Enabled",
				desc = "Whether or not to animate this Frame",
				get = function(info)
					return E.db.ElvUI_Animations[i].Enabled
				end,
				set = function(info, value)
					E.db.ElvUI_Animations[i].Enabled = value
					ElvUI_Animations:Update(i)
					-- We changed a setting, call our Update function
				end,
			}
			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].UI_Table.TableName].args.Animation.args.TestAll = 
			{
				order = 2,
				type = "execute",
				name = "Test All!",
				desc = "Test all the animations at the same time",
				func = function()
					ElvUI_Animations:Appear(i)
				end,
			}
			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].UI_Table.TableName].args.Animation.args.General.args.UseDefaults =
			{
				order = 1,
				type = "toggle",
				name = "Use Defaults",
				desc = "Whether or not to use the default values or set up individual values for this frame",
				get = function(info)
					return E.db.ElvUI_Animations[i].UseDefaults
				end,
				set = function(info, value)
					E.db.ElvUI_Animations[i].UseDefaults = value
					ElvUI_Animations:Update(i)
					-- We changed a setting, call our Update function
				end,
			}
		end
		ElvUI_Animations:Update(i)
		
--		local GoobyPls = false
--		E.db.ElvUI_Animations[i].UI_Table.Error = { }

--		for j = 1, #E.db.ElvUI_Animations[i].UI_Table.Frame do
--			if GetClickFrame(E.db.ElvUI_Animations[i].UI_Table.Frame[j]) == nil  and i ~= 1 then
--				E.db.ElvUI_Animations[i].UI_Table.Error[#E.db.ElvUI_Animations[i].UI_Table.Error + 1] = j
--				GoobyPls = true
--			end
--		end

--		if GoobyPls then
--			if E.db.ElvUI_Animations[i].UI_Table.Frame ~= P.ElvUI_Animations[i].UI_Table.Frame then
--				print("Wait a sec are u trying to set one of "..E.db.ElvUI_Animations[i].UI_Table.Name.."'s Frames to a nil value?")
--				print("gooby pls")
--			end

--			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].UI_Table.TableName].disabled = true
--		else
--			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].UI_Table.TableName].disabled = false
--		end
	end
end

function ElvUI_Animations:Initialize()
	-- Register plugin so options are properly inserted when config is loaded
	EP:RegisterPlugin(addonName, ElvUI_Animations.InsertOptions)
end

function ElvUI_Animations:OnLoad()
	ElvUI_Animations:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
	ElvUI_Animations:RegisterEvent("PLAYER_STARTED_MOVING", "OnEvent")
	ElvUI_Animations:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
	ElvUI_Animations:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEvent")
	ElvUI_Animations:RegisterEvent("PLAYER_FLAGS_CHANGED", "OnEvent")

	MyWorldFrame = CreateFrame("Frame", "Test", WorldFrame)

	MyWorldFrame:SetPropagateKeyboardInput(true)

	MyWorldFrame:SetScript("OnKeyDown", 
		function(self, button)
			ElvUI_Animations:OnEvent("PLAYER_STARTED_MOVING")
		end)

	MyUIParent = CreateFrame("Frame", "MyUIParent", UIParent)

	MyUIParent:SetScript("OnUpdate",
		function(self, elapsed)
			ElvUI_Animations:OnUpdate(elapsed)
		end)
end

function ElvUI_Animations:OnEvent(Event, ...)
	if Event == "PLAYER_ENTERING_WORLD" then	
		ElvUI_Animations:ReloadCombatAnimationGroup()

		if E.db.ElvUI_Animations.Animate then
			UIParent:Hide()
			MyWorldFrame:Show()
			ShouldAppear = true
		end
	end

	if (Event == "PLAYER_STARTED_MOVING" or Event == "PLAYER_REGEN_DISABLED") and ShouldAppear and E.db.ElvUI_Animations.Animate then
		UIParent:Show()
		MyWorldFrame:Hide()
		for i = 2, #E.db.ElvUI_Animations do
			ElvUI_Animations:Appear(i)
		end
		ShouldAppear = false		
	end
	if Event == "PLAYER_FLAGS_CHANGED" and UnitIsAFK("player") and E.db.ElvUI_Animations.Animate then
		MyWorldFrame:Show()
		ShouldAppear = true
	end

	if Event == "PLAYER_REGEN_DISABLED" then
		InCombat = true
		if E.db.ElvUI_Animations.Combat then
			for i = 2, #E.db.ElvUI_Animations do
				ElvUI_Animations:AttemptCombatFade(i, "In")
			end
		end
	end
	if Event == "PLAYER_REGEN_ENABLED" then
		InCombat = false
		if E.db.ElvUI_Animations.Combat then
			for i = 2, #E.db.ElvUI_Animations do
				ElvUI_Animations:AttemptCombatFade(i, "Out")
			end
		end
	end
end

function ElvUI_Animations:OnUpdate(DeltaTime)
	local FocusFrame = GetMouseFocus()

	local TouchingChildFrame

	if FocusFrame ~= nil and E.db.ElvUI_Animations.Combat then
		for i = 2, #E.db.ElvUI_Animations do
			TouchingChildFrame = false
			for j = 1, #E.db.ElvUI_Animations[i].UI_Table.Frame do
				local FrameAtIndex = GetClickFrame(E.db.ElvUI_Animations[i].UI_Table.Frame[j])
				if FrameAtIndex ~= nil and (MouseIsOver(FrameAtIndex) and FrameAtIndex:IsShown()) then
					TouchingChildFrame = true
					ElvUI_Animations:AttemptMouseOverFade(i, DeltaTime, "Focus")
				end
			end
			if not TouchingChildFrame then
				ElvUI_Animations:AttemptMouseOverFade(i, DeltaTime, "Non-Focus")
			end
		end
	end

	PrevFocusFrame = FocusFrame

	--collectgarbage()
end

local ShouldAppear = false

ElvUI_Animations:OnLoad()
E:RegisterModule(ElvUI_Animations:GetName()) -- Register the module with ElvUI. ElvUI will now call ElvUI_Animations:Initialize() when ElvUI is ready to load our plugin.