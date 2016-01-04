---------------------------------------------------
-- File:			Config.lua
-- Author:			Benjamin Odom
-- Date Created:	01-02-2016
--
-- Brief:	Holds all code related to the creation
--	of the configuration for the add-on. 	
---------------------------------------------------

function copy (t) -- shallow-copy a table
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do target[k] = v end
    setmetatable(target, meta)
    return target
end

local E, L, V, P, G = unpack(ElvUI);	-- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local ElvUI_Animations = E:NewModule('ElvUI_Animations', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');	-- Create a plugin within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.

local DEFAULT_MAX_TABS = 16 			-- Default amount of tabs

--region Defaults Table
local DEFAULT = {						-- The default values for a configuration tab

	Animation = {						-- The settings for animations played after loading screens and afk
		Enabled = true,					-- If this frame should be animated
	
		UseDefaults = true,				-- If the default tab settings should be used instead of this one

		Default = {						-- Default timing settings for the animation as a whole. Not to be confused with the default tab 
			Duration = 1.5,
		
			Delay = {
				Start = 0,
				End = 0,
			}, 
		},
		
		{									-- Alpha animation settings
			Enabled = true,
		
			Order = 1,			

			Name = L["Fade"],
			AnimationName = "Alpha",
			Effect = L["Alpha"],

			Duration = {
				Enabled = false,

				Length = 0.3,

				Delay = {
					Start = 0,
					End = 0,
				},
			},

			Alpha = {
				Start = 0,
				End = 0.9,
			},

			Smoothing = "IN",
		},
--region Not Yet Yung 1
--		{									-- Translation animation settings
--			Enabled = false,

--			Order = 1,

--			Name = L["Slide"],
--			AnimationName = "Translation",
--			Effect = L["Offset"],

--			Duration = {
--				Enabled = false,

--				Length = 0.3,

--				Delay = {
--					Start = 0,
--					End = 0,
--				},
--			},

--			Offset = {
--				X = -5,
--				Y = -10,
--			},
--			Distance = {
--				X = 5,
--				Y = 10,
--			},

--			Smoothing = "NONE",
--		},
--		{									-- Translation animation settings for a second translation animation that gets called on the 'OnFinished' script of the first one
--			Enabled = false,

--			Order = 2,

--			Name = L["Bounce"],
--			AnimationName = "Translation",
--			Effect = L["Offset"],

--			Duration = {
--				Enabled = true,

--				Length = 0.3,

--				Delay = {
--					Start = 0,
--					End = 0,
--				},
--			},

--			Offset = {
--				X = 0,
--				Y = 0,
--			},
--			Distance = {
--				X = -5,
--				Y = -10,
--			},

--			Smoothing = "NONE",
--		},
--endregion
	},
	
	Combat = {							-- Settings relating to combat fading/alpha animation
		Enabled = true,					-- If this frame should be animated
		
		UseDefaults = true,				-- If the default tab settings should be used instead of this one

		Duration = {
			In = 0.3,					-- Time to animate for in combat flag
			Out = 1,					-- Time to animate for out of combat flag
		},

		Alpha = {
			In = 0.25,
			Out = 0.9,
		},
		
		Smoothing = {
			In = "IN",
			Out = "IN",
		},
		
		Mouse = {						-- Settings related to mouse-over fading
			Enabled = true,
		
			Duration = {
				On = 0.2,
				Off = 0.5,
			},
			
			Alpha = 1,
		},
	},

	Config = { },								-- This is created but not populated because we don't know what 'Config.Frame', 'Config.Name' ect.. could defaulted to
}
--endregion

--region Setting up default profile variables

-- Set up the table, but leave it empty
P.ElvUI_Animations = { Animate = true, AFK = true, Combat = true, Lag = true, { }, }

-- Created the defaults table for the addon. ElvUI does some magic here, somehow it ends up being named the same
for i = 1, DEFAULT_MAX_TABS do
	P.ElvUI_Animations[i] = copy(DEFAULT)
end

P.ElvUI_Animations[1].Config = {
	KeyName = "Default",		-- The name of the key in the table. ex: E.Options.args.ElvUI_Animations.args[%THIS_VALUE_HERE%]
	Frame = { "All" },			-- The name of the frames affected by this tabs settings
	Name = L["Default"],		-- The name displayed to the user for this tab
	Error = false,
}

P.ElvUI_Animations[2].Config = {
	KeyName = "Player",
	Frame = { "ElvUF_Player", "ElvUF_Focus", "ElvUF_FocusTarget", 
		Fade = {  },				-- 'Fade' refers to frames which should fade in after a translation animation plays since they are tightly anchored and do not animate properly
	},									
	Name = L["Player Frame"],
	Error = { 
		Fade = {  },				-- The index of a frame which is currenlty nil as set by the user. Used to tell the user they goofed on the frame's name
	},		
}	
P.ElvUI_Animations[3].Config = {
	KeyName = "Target",
	Frame = { "ElvUF_Target", "ElvUF_TargetTarget", "ElvUF_TargetTargetTarget",
		Fade = {  }, 
	},
	Name = L["Target Frame"],
	Error = { 
		Fade = {  }, 
	},
}

--P.ElvUI_Animations[4].Config = {
--	KeyName = "Party",
--	Frame = { "ElvUF_Party",
--		Fade = {  }, 
--	},
--	Name = L["Party Frames"],
--	Error = { 
--		Fade = {  }, 
--	},
--}

--P.ElvUI_Animations[5].Config = {
--	KeyName = "Raid",
--	Frame = { "ElvUF_Raid",
--		Fade = {  }, 
--	},
--	Name = L["Raid Frames"],
--	Error = { 
--		Fade = {  }, 
--	},
--}
--P.ElvUI_Animations[6].Config = {
--	KeyName = "Raid40",
--	Frame = { "ElvUF_Raid40",
--		Fade = {  }, 
--	},
--	Name = L["Raid-40 Frames"],
--	Error = { 
--		Fade = {  }, 
--	},
--}

P.ElvUI_Animations[4].Config = {
	KeyName = "LeftChatPanel",
	Frame = { "LeftChatPanel", "ElvUI_ExperienceBar", "LeftChatToggleButton", 
		Fade = { }, 
	},
	Name = L["Left Chat Panel"],
	Error = { 
		Fade = {  }, 
	},
}
P.ElvUI_Animations[5].Config = {
	KeyName = "RightChatPanel",
	Frame = { "RightChatPanel", "ElvUI_ReputationBar", "RightChatToggleButton", 
		Fade = { }, 
	},
	Name = L["Right Chat Panel"],
	Error = { 
		Fade = {  }, 
	},
}

P.ElvUI_Animations[6].Config = {
	KeyName = "ObjectiveFrame",
	Frame = { "ObjectiveTrackerFrame", 
		Fade = { }, 
	},
	Name = L["Objective Frame"],
	Error = { 
		Fade = {  }, 
	},
}

P.ElvUI_Animations[7].Config = {
	KeyName = "MiniMap",
	Frame = { "MinimapCluster", "MinimapButtonBar", 
		Fade = { }, 
	},
	Name = L["MiniMap"],
	Error = { 
		Fade = {  }, 
	},
}

P.ElvUI_Animations[8].Config = {
	KeyName = "PlayerBuffs",
	Frame = { "ElvUIPlayerBuffs", "ElvUIPlayerDebuffs",
		Fade = { }, 
	},
	Name = L["Player Buffs"],
	Error = { 
		Fade = {  }, 
	},
}
local AfterUF = 9 -- After Unit Frames Index

for i = AfterUF, AfterUF + 6 do
	P.ElvUI_Animations[i].Config = {
		KeyName = "Bar_" .. i - AfterUF + 1,
		Frame = { "ElvUI_Bar"..i - AfterUF + 1, 
			Fade = { }, 
		},
		Name = L["Bar"].." ".. i - AfterUF + 1,
		Error = { 
			Fade = {  }, 
		},
	}
end

P.ElvUI_Animations[AfterUF + 6].Config = {
	KeyName = "TopPanel",
	Frame = { "ElvUI_TopPanel", "TitanPanelLootTypeButton", "TitanPanelRepairButton", "TitanPanelGoldButton", "TitanPanelXPButton", "TitanPanelLocationButton",
		Fade = { }, 
	},
	Name = L["Top Panel"],
	Error = { 
		Fade = {  }, 
	},
}
P.ElvUI_Animations[AfterUF + 7].Config = {
	KeyName = "BottomPanel",
	Frame = { "ElvUI_BottomPanel", 
		Fade = { }, 
	},
	Name = L["Bottom Panel"],
	Error = { 
		Fade = {  }, 
	},
}
--endregion

---------------------------------------------------------------------------------------------------------------------------------------
-- End of Defaults
---------------------------------------------------------------------------------------------------------------------------------------

V.ElvUI_Animations = {
	Combat = {
		AnimationGroup = { },
		AlphaAnimation = { },
	},
	Animation = {
		AnimationGroup = { },
		AlphaAnimation = { },
		TranslationAnimation = { },
	},

	AlphaBuildUp = { },	-- For some reason adding less than 0.01 alpha to a frame seems to cause floating point error where it isn't added to the overall alpha of the frame
	
	DeleteTab = "",
}

function ElvUI_Animations:ReloadCombatAnimationGroup()	
	for i = 1, #E.db.ElvUI_Animations do
		if i ~= 1 then
			V.ElvUI_Animations.Combat.AnimationGroup[i] = V.ElvUI_Animations.Combat.AnimationGroup[i] or { }
			V.ElvUI_Animations.Combat.AlphaAnimation[i] = V.ElvUI_Animations.Combat.AlphaAnimation[i] or { }
			
			V.ElvUI_Animations.AlphaBuildUp[i] = V.ElvUI_Animations.AlphaBuildUp[i] or { }
			
			for j = 1, #E.db.ElvUI_Animations[i].Config.Frame do
				local FrameAtIndex = GetClickFrame(E.db.ElvUI_Animations[i].Config.Frame[j])

				if  FrameAtIndex ~= nil then
					V.ElvUI_Animations.Combat.AnimationGroup[i][j] = FrameAtIndex:CreateAnimationGroup()
					V.ElvUI_Animations.Combat.AlphaAnimation[i][j] = V.ElvUI_Animations.Combat.AnimationGroup[i][j]:CreateAnimation("Alpha")
				
					V.ElvUI_Animations.AlphaBuildUp[i][j] = 0
				end
			end
		end
	end

	for i = 1, #E.db.ElvUI_Animations do
		if i ~= 1 then
			V.ElvUI_Animations.Animation.AnimationGroup[i] = V.ElvUI_Animations.Animation.AnimationGroup[i] or { }
			V.ElvUI_Animations.Animation.AlphaAnimation[i] = V.ElvUI_Animations.Animation.AlphaAnimation[i] or { }
			
			for j = 1, #E.db.ElvUI_Animations[i].Config.Frame do
				local FrameAtIndex = GetClickFrame(E.db.ElvUI_Animations[i].Config.Frame[j])

				if  FrameAtIndex ~= nil then
					V.ElvUI_Animations.Animation.AnimationGroup[i][j] = FrameAtIndex:CreateAnimationGroup()
					V.ElvUI_Animations.Animation.AlphaAnimation[i][j] = V.ElvUI_Animations.Animation.AlphaAnimation[i][j] or { }

					for k = 1, #E.db.ElvUI_Animations[i].Animation do
							V.ElvUI_Animations.Animation.AlphaAnimation[i][j][k] = V.ElvUI_Animations.Animation.AnimationGroup[i][j]:CreateAnimation(E.db.ElvUI_Animations[i].Animation[k].AnimationName)
					end
				end
			end
		end
	end
end

-- Function we can call when a setting changes.
local function Update(Index)
	ElvUI_Animations:ReloadCombatAnimationGroup()

	-- I had to shorten these variables, they are WAY too long
	local DataBase = E.db.ElvUI_Animations[Index]
	local Animation = E.Options.args.ElvUI_Animations.args[DataBase.Config.KeyName].args.Animation
	local Combat = E.Options.args.ElvUI_Animations.args[DataBase.Config.KeyName].args.Combat

	if Index ~= 1 then
		Animation.disabled = not E.db.ElvUI_Animations.Animate
		Animation.args.General.disabled = true
		Animation.args.General.args.UseDefaults.disabled = true
		for k = 1, #DataBase.Animation do
			local Key = "Animation_"..k

			Animation.args[Key].args.General.disabled = true
			Animation.args[Key].args.Enabled.disabled = true
			Animation.args[Key].args.Duration.disabled = true
			Animation.args[Key].args.Duration.args.Enabled.disabled = true
		end

		if E.db.ElvUI_Animations.Animate then
			--Animation.disabled = false
			if DataBase.Animation.Enabled then
				Animation.args.General.args.UseDefaults.disabled = false

				if not DataBase.Animation.UseDefaults then
					Animation.args.General.disabled = false
					for k = 1, #DataBase.Animation do
						local Key = "Animation_"..k

						Animation.args[Key].args.Enabled.disabled = false

						if DataBase.Animation[k].Enabled then
							Animation.args[Key].args.General.disabled = false

							Animation.args[Key].args.Duration.args.Enabled.disabled = false
							if DataBase.Animation[k].Duration.Enabled then
								Animation.args[Key].args.Duration.disabled = false
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
		for k = 1, #DataBase.Animation do
			Key = "Animation_"..k
			Animation.args[Key].args.General.disabled = true
			Animation.args[Key].args.Enabled.disabled = false
			Animation.args[Key].args.Duration.disabled = true
			Animation.args[Key].args.Duration.args.Enabled.disabled = true

			if E.db.ElvUI_Animations.Animate then
				Animation.disabled = false

				if DataBase.Animation[k].Enabled then
					Animation.args[Key].args.General.disabled = false

					Animation.args[Key].args.Duration.args.Enabled.disabled = false
					if DataBase.Animation[k].Duration.Enabled then
						Animation.args[Key].args.Duration.disabled = false
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

local function CreateConfigTab(Index, Order)
	local TabConfig = { }

	TabConfig = {
		order = Index,
		type = "group",
		name = E.db.ElvUI_Animations[Index].Config.Name.." Configuration",
		guiInline = true,
		args = {
			Name = {
				order = 1,
				type = "input",
				name = "Rename Tab",
				get = 
					function(info)
						return E.db.ElvUI_Animations[Index].Config.Name
					end,
				set = 
					function(info, value)
						E.db.ElvUI_Animations[Index].Config.Name = value
								
						--E:CopyTable(E.Options.args.ElvUI_Animations.args[string.gsub(value, "%s+", "")], E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[Index].Config.KeyName])
				
						--E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[Index].Config.KeyName] = nil
								
						--E.db.ElvUI_Animations[Index].Config.KeyName = string.gsub(value, "%s+", "")
						ElvUI_Animations:InsertOptions()
					end,
			},
			Frames = {
				order = 5,
				type = "input",
				name = "Change Frames",
				desc = "Enter the name of the frame that you would like to be affected by this tabs configuration.\nFormat is:\n%Frame1%; %Frame2%;\n\nYou can put a 'return' inbetween frames.\n\nUse /framestack to check the names of frames",
				multiline = true,
				get = 
					function(info)
						local ReturnString = ""

						for j = 1, #E.db.ElvUI_Animations[Index].Config.Frame do
							if E.db.ElvUI_Animations[Index].Config.Error[j] then
								ReturnString = ReturnString.."|cffFF1010"
							end

							ReturnString = ReturnString..E.db.ElvUI_Animations[Index].Config.Frame[j]

							if E.db.ElvUI_Animations[Index].Config.Error[j] then
								ReturnString = ReturnString.."|r"
							end
							
							ReturnString = ReturnString..";\n"
						end
--								if i == 3 then print(ReturnString) end
						return ReturnString
					end,
				set = 
					function(info, value)
							local Parse = string.gsub(value, "%s+", "")
							local Current = { Start = 1, End = string.len(Parse) }	
							
--									local ToPrint = ""
--									for j = 1, string.len(value) do ToPrint = ToPrint.." "..string.sub(value, j, j) end
--									print(ToPrint)
							E.db.ElvUI_Animations[Index].Config.Frame = { Fade = E.db.ElvUI_Animations[Index].Config.Frame.Fade, }
							local j = 1
									
							while string.find(Parse, "|cff") do
								Current.Start = string.find(Parse, "|cff") + 10
								Current.End = string.find(Parse,"|r")
   
								Parse = string.sub(Parse, 1, Current.Start - 11)..string.sub(Parse, Current.Start, Current.End -1)..string.sub(Parse, Current.End + 2, string.len(Parse))  
							end
							j = 1
							while string.find(Parse, ";") do
								Current.End = string.find(Parse, ";")
							
								E.db.ElvUI_Animations[Index].Config.Frame[j] = string.sub(Parse, 1, Current.End - 1)
									
								Parse = string.sub(Parse, Current.End + 1, string.len(Parse))

								j = j + 1
							end

							ElvUI_Animations:InsertOptions()
					end,
			},				
		},
	}
	TabConfig.args.MoveUp = {
		order = 2,
		type = "execute",	
		name = "Move Up",
		desc = "Move this tab up one space",
		func = 
			function()						
				local TableHolder = E.db.ElvUI_Animations[Index]
				print(TableHolder, E.db.ElvUI_Animations[Index])
				E.db.ElvUI_Animations[Index] = E.db.ElvUI_Animations[Index-1]
				print(TableHolder, E.db.ElvUI_Animations[Index])
				E.db.ElvUI_Animations[Index-1] = TableHolder					
						
				ElvUI_Animations:InsertOptions()
			end,
	}
	TabConfig.args.MoveDown = {
		order = 3,
		type = "execute",	
		name = "Move Down",
		desc = "Move this tab Down one space",
		func = 
			function()						
				local TableHolder = E.db.ElvUI_Animations[Index]
					
				E.db.ElvUI_Animations[Index] = E.db.ElvUI_Animations[Index+1]
				E.db.ElvUI_Animations[Index+1] = TableHolder					
						
				ElvUI_Animations:InsertOptions()
			end,
	}
	if Index == 2 then
		TabConfig.args.MoveUp.name = "|cff333333Move Up|r"
		TabConfig.args.MoveUp.disabled = true
	end
	if Index == #E.db.ElvUI_Animations then
		TabConfig.args.MoveDown.name = "|cff333333Move Down|r"
		TabConfig.args.MoveDown.disabled = true
	end

	
	return TabConfig
end

local function CreateAnimationPage(Index, AnimIndex, Order)	
	local AnimationPage = { }
	
	local DataBase = E.db.ElvUI_Animations[Index].Animation[AnimIndex]

	AnimationPage = {
		order = Order,
		type = "group",
		name = DataBase.Name,
		args = {
			Enabled = {
				order = 1,
				type = "toggle",
				name = "Enabled",
				desc = "Whether or not to "..DataBase.Name.." this frame",
				get = 
					function(info)
						return E.db.ElvUI_Animations[Index].Animation[AnimIndex].Enabled
					end,
				set = 
					function(info, value)
						E.db.ElvUI_Animations[Index].Animation[AnimIndex].Enabled = value
						Update(Index)	-- We changed a toggle, call our Update function						
					end,
			},
			General = {
				order = 2,
				type = "group",
				name = "General Options",
				guiInline = true,
				args = {
					Smoothing = {
						order = -1,
						type = "select",
						name = "Smoothing",
						desc = "The type of smoothing to use for the animation",
						values = {
							NONE = "None",
							IN = "In",
							OUT = "Out",
							IN_OUT = "In/Out",
						},
						get = 
							function(info)
								return E.db.ElvUI_Animations[Index].Animation[AnimIndex].Smoothing
							end,
						set = 
							function(info, value)
								E.db.ElvUI_Animations[Index].Animation[AnimIndex].Smoothing = value
							end,
					},
				},
			},
			
			Duration = {
				order = -1,
				type = "group",
				name = "Individual Duration",
				guiInline = true,
				args = {
					Enabled = {
						order = 1,
						type = "toggle",
						name = "Enabled",
						desc = "Whether or not to use an individual animation duration",
						get = 
							function(info)
								return E.db.ElvUI_Animations[Index].Animation[AnimIndex].Duration.Enabled
							end,
						set = 
							function(info, value)
								E.db.ElvUI_Animations[Index].Animation[AnimIndex].Duration.Enabled = value
								Update(Index)	-- We changed a toggle, call our Update function
							end,
					},	
					Length = {
						order = 2,
						type = "range",
						name = DataBase.Name.." Duration",
						desc = "How long it will take to "..DataBase.Name.." the frame",
						min = 0,
						max = 5,
						step = 0.1,
						get = function(info)
							return E.db.ElvUI_Animations[Index].Animation[AnimIndex].Duration.Length
						end,
						set = function(info, value)
							E.db.ElvUI_Animations[Index].Animation[AnimIndex].Duration.Length = value
						end,
					},				
					StartDelay = {
						order = 3,
						type = "range",
						name = DataBase.Name.." Start Delay",
						desc = "How long to wait until the animation should start",
						min = 0,
						max = 5,
						step = 0.1,
						get = 
							function(info)
								return E.db.ElvUI_Animations[Index].Animation[AnimIndex].Duration.Delay.Start
							end,
						set = 
							function(info, value)
								E.db.ElvUI_Animations[Index].Animation[AnimIndex].Duration.Delay.Start = value
							end,
					},
					EndDelay = {
						order = 4,
						type = "range",
						name = DataBase.Name.." End Delay",
						desc = "How long to wait after the animation has stopped until it should be considered finished",
						min = 0,
						max = 5,
						step = 0.1,
						get = 
							function(info)
								return E.db.ElvUI_Animations[Index].Animation[AnimIndex].Duration.Delay.End
							end,
						set = 
							function(info, value)
								E.db.ElvUI_Animations[Index].Animation[AnimIndex].Duration.Delay.End = value
							end,
					},
				},
			},
			TestButton = {
				order = - 1,
				type = "execute",
				name = "Test It!",
				desc = DataBase.Name.." the selected frame",
				func = 
					function()
						local Loop = { Start = Index, End = Index,}
						
						ElvUI_Animations:ReloadCombatAnimationGroup()

						if Index == 1 then
							Loop = { Start = 2, End = #E.db.ElvUI_Animations, }
						end
						
						for i = 2, Loop.End do
							if DataBase.AnimationName == "Alpha" then
								ElvUI_Animations:AttemptFade(i, AnimIndex)
							end
							if DataBase.AnimationName == "Translation" then
								ElvUI_Animations:AttemptTranslate(i, AnimIndex)
							end							
						end

						for i = 2, Loop.End do
							for f = 1, #E.db.ElvUI_Animations[Index].Config.Frame do
								if V.ElvUI_Animations.Animation.AnimationGroup[i][f] ~= nil then
									V.ElvUI_Animations.Animation.AnimationGroup[i][f]:Play()
								end
							end
						end
					end,
			},				
		},
	}
	
	if DataBase.AnimationName == "Alpha" then
		AnimationPage.args.General.args["Start"..DataBase.Effect] = {
			order = 1,
			type = "range",
			name = "Start "..DataBase.Effect,
			desc = "What "..DataBase.Effect.." the animation should start at",
			min = 0,
			max = 1,
			step = 0.01,
			get = 
				function(info)
					return E.db.ElvUI_Animations[Index].Animation[AnimIndex].Alpha.Start
				end,
			set = 
				function(info, value)
					E.db.ElvUI_Animations[Index].Animation[AnimIndex].Alpha.Start = value
				end,									
		}
		AnimationPage.args.General.args["End"..DataBase.Effect] = {
			order = 2,
			type = "range",
			name = "End "..DataBase.Effect,
			desc = "What "..DataBase.Effect.." the animation should end at",
			min = 0,
			max = 1,
			step = 0.01,
			get = 
				function(info)
					return E.db.ElvUI_Animations[Index].Animation[AnimIndex].Alpha.End
				end,
			set = 
				function(info, value)
					E.db.ElvUI_Animations[Index].Animation[AnimIndex].Alpha.End = value
				end,									
		}
	end
	if DataBase.AnimationName == "Translation" then
		AnimationPage.args.General.args[DataBase.Effect.."X"] = {
			order = 1,
			type = "range",
			name = DataBase.Effect.."X",
			desc = "What X "..DataBase.Effect.." the animation should start at",
			min = -150,
			max = 150,
			step = 5,
			get = 
				function(info)
					return E.db.ElvUI_Animations[Index].Animation[AnimIndex].Offset.X
				end,
			set = 
				function(info, value)
					E.db.ElvUI_Animations[Index].Animation[AnimIndex].Offset.X = value
				end,									
		}
		AnimationPage.args.General.args[DataBase.Effect.."Y"] = {
			order = 2,
			type = "range",
			name = DataBase.Effect.."Y",
			desc = "What Y "..DataBase.Effect.." the animation should start at",
			min = -150,
			max = 150,
			step = 5,
			get = 
				function(info)
					return E.db.ElvUI_Animations[Index].Animation[AnimIndex].Offset.Y
				end,
			set = 
				function(info, value)
					E.db.ElvUI_Animations[Index].Animation[AnimIndex].Offset.Y = value
				end,				
		}
		AnimationPage.args.General.args["DistanceX"] = {
			order = 3,
			type = "range",
			name = "DistanceX",
			desc = "How far in the X direction the frame should travel",
			min = -150,
			max = 150,
			step = 5,
			get = 
				function(info)
					return E.db.ElvUI_Animations[Index].Animation[AnimIndex].Distance.X
				end,
			set = 
				function(info, value)
					E.db.ElvUI_Animations[Index].Animation[AnimIndex].Distance.X = value
				end,
		}
		AnimationPage.args.General.args["DistanceY"] = {
			order = 4,
			type = "range",
			name = "DistanceY",
			desc = "How far in the Y direction the frame should travel",
			min = -150,
			max = 150,
			step = 5,
			get = function(info)
				return E.db.ElvUI_Animations[Index].Animation[AnimIndex].Distance.Y
			end,
			set = function(info, value)
				E.db.ElvUI_Animations[Index].Animation[AnimIndex].Distance.Y = value
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
		args = {
			Animate = {
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
						Update(i)
					end
				end,
			},
			Combat = {
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
						Update(i)
					end
				end,
			},
			Lagging = {
				order = 3,
				type = "toggle",
				name = "After Load Lag",
				desc = "\"Halp! I'm lagging after loading when it's playing the load animation!\"\n\nTry DIS-abling this toggle to speed up the after load animation. It may cause a graphical error though :(",
				get = function(info)
					return E.db.ElvUI_Animations.Lag
				end,
				set = function(info, value)
					E.db.ElvUI_Animations.Lag = value
				end,
			},
			AFKAnimation = {
				order = 4,
				type = "toggle",
				name = "Enable After AFK Animation",
				desc = "Allow the after load animations to also play when returning from AFK",
				get = function(info)
					return E.db.ElvUI_Animations.AFK
				end,
				set = function(info, value)
					E.db.ElvUI_Animations.AFK = value
				end,
			},
			RestoreDefaults = {
				order = 5,
				type = "execute",
				name = "Restore Defaults",
				desc = "Restore all values back to default, but just for this addon not ElvUI don't worry!",
				func = function()
					E:StaticPopup_Show("RestoreDefaults")
				end,
			},
			Header1 = 
			{
				order = 9,
				type = "header",
				name = "",
			},
			NewTab = {
				order = 10,
				type = "input",
				name = "Create New Tab",
				desc = "Create a new tab to configure for a new set of frames.\n\nJust don't forget to actually add frames to the configuration or it won't do anything",
				get = 
					function(info)
						return ""
					end,
				set = 
					function(info, value)
						E.db.ElvUI_Animations[#E.db.ElvUI_Animations] = copy(DEFAULT)

						E.db.ElvUI_Animations[#E.db.ElvUI_Animations].Config = {
							KeyName = "Tab"..(#E.db.ElvUI_Animations ),			-- The name of the key in the table. ex: E.Options.args.ElvUI_Animations.args[%THIS_VALUE_HERE%]
							Frame = { "Nothing Yet...",							-- The name of the frames affected by this tabs settings
								Fade = { }, 
							},									
							Name = value,										-- The name displayed to the user for this tab
							Error = { 
								Fade = {  }, 
							},								
						}

						ElvUI_Animations:InsertOptions()
					end,
			},
			Header2 = {
				order = 11,
				type = "header",
				name = "",
			},
			TabSelection = {
				order = 12,
				type = "select",
				name = "",
				values = { },
				get = 
					function(info)
						return V.ElvUI_Animations.DeleteTab
					end,
				set = 
					function(info, value)
						V.ElvUI_Animations.DeleteTab = value
					end,
				
			},
			DeleteThis = {
				order = 13,
				type = "execute",
				name = "Delete Tab",
				desc = "Delete the selected Tab",
				func = 
					function()
						E:StaticPopup_Show("DeleteTab")
					end,
			},
		},
	}
	for i = 2, #E.db.ElvUI_Animations do
		E.Options.args.ElvUI_Animations.args.TabSelection.values[tostring(i)] = E.db.ElvUI_Animations[i].Config.Name
	end

	for i = 1, #E.db.ElvUI_Animations do					
		E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].Config.KeyName] = {
			order = i + 10 + #E.db.ElvUI_Animations,
			type = "group",
			name = E.db.ElvUI_Animations[i].Config.Name,
			childGroups = "tab",	
			args = {
				Combat = {
					order = 1,
					type = "group",
					name = "Combat Fade Options",
					args = {
						Alpha = {
							order = 5,
							type = "group",
							name = "Alpha Options",
							guiInline = true,
							args = {
								In = {
									order = 1,
									type = "range",
									name = "In Combat Alpha",
									desc = "What alpha the frame should be set to when in combat",
									min = 0,
									max = 1,
									step = 0.01,
									get = 
										function(info)
											return E.db.ElvUI_Animations[i].Combat.Alpha.In
										end,
									set = 
										function(info, value)
											E.db.ElvUI_Animations[i].Combat.Alpha.In = value
										end,
								},
								Out = {
									order = 2,
									type = "range",
									name = "Out of Combat Alpha",
									desc = "What alpha the frame should be set to when not in combat",
									min = 0,
									max = 1,
									step = 0.01,
									get = 
										function(info)
											return E.db.ElvUI_Animations[i].Combat.Alpha.Out
										end,
									set = 
										function(info, value)
											E.db.ElvUI_Animations[i].Combat.Alpha.Out = value
										end,
								},
							},
						},
						Duration = {
							order = 6,
							type = "group",
							name = "Duration Options",
							guiInline = true,
							args = {
								In = {
									order = 1,
									type = "range",
									name = "To In Combat Alpha",
									desc = "How long it should take to fade to the in combat alpha",
									min = 0,
									max = 5,
									step = 0.1,
									get = 
										function(info)
											return E.db.ElvUI_Animations[i].Combat.Duration.In
										end,
									set = 
										function(info, value)
											E.db.ElvUI_Animations[i].Combat.Duration.In = value
										end,
								},
								Out = {
									order = 2,
									type = "range",
									name = "To Out of Combat Alpha",
									desc = "How long it should take to fade to the out of combat alpha",
									min = 0,
									max = 5,
									step = 0.1,
									get = 
										function(info)
											return E.db.ElvUI_Animations[i].Combat.Duration.Out
										end,
									set = 
										function(info, value)
											E.db.ElvUI_Animations[i].Combat.Duration.Out = value
										end,
								},									
							},
						},
						Smoothing = {
							order = 7,
							type = "group",
							name = "Smoothing Options",
							guiInline = true,
							args = {
								In = {
									order = 1,
									type = "select",
									name = "In Combat Smoothing",
									desc = "The type of smoothing to use when fading to the in combat alpha",
									values = {
										NONE = "None",
										IN = "In",
										OUT = "Out",
										IN_OUT = "In/Out",
									},
									get = 
										function(info)
											return E.db.ElvUI_Animations[i].Combat.Smoothing.In
										end,
									set = 
										function(info, value)
											E.db.ElvUI_Animations[i].Combat.Smoothing.In = value
										end,
								},
								Out = {
									order = 1,
									type = "select",
									name = "Out of Combat Smoothing",
									desc = "The type of smoothing to use when fading to the out of combat alpha",
									values = {
										NONE = "None",
										IN = "In",
										OUT = "Out",
										IN_OUT = "In/Out",
									},
									get = 
										function(info)
											return E.db.ElvUI_Animations[i].Combat.Smoothing.Out
										end,
									set = 
										function(info, value)
											E.db.ElvUI_Animations[i].Combat.Smoothing.Out = value
										end,
								},
							},
						},
						Mouse = {
							order = -1,
							type = "group",
							name = "Mouse Options",
							guiInline = true,
							args = {
								Enabled = {
									order = 1,
									type = "toggle",
									name = "Enable Mouse-Over",
									desc = "Whether or not to fade the frame based on current mouse focus",
									get = 
										function(info)
											return E.db.ElvUI_Animations[i].Combat.Mouse.Enabled
										end,
									set = 
										function(info, value)
											E.db.ElvUI_Animations[i].Combat.Mouse.Enabled = value
											Update(i)	-- We changed a toggle, call our Update function
										end,
								},
								DurationOn = {
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
								DurationOff = {
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
								Alpha = {
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
					
				Animation = {
					order = 3,
					type = "group",
					name = "Animation Options",	
					args = {
						General = {
							order = 5,
							type = "group",
							name = "General Options",
							guiInline = true,
							args = {
								StartDelay = {
									order = 2,
									type = "range",
									name = "Animation Start Delay",
									desc = "How long to wait until the animation should start",
									min = 0,
									max = 5,
									step = 0.1,
									get = 
										function(info)
											return E.db.ElvUI_Animations[i].Animation.Default.Delay.Start
										end,
									set = 
										function(info, value)
											E.db.ElvUI_Animations[i].Animation.Default.Delay.Start = value
										end,
								},
								EndDelay = {
									order = 3,
									type = "range",
									name = "Animation End Delay",
									desc = "How long to wait after the animation has stopped until it should be considered finished",
									min = 0,
									max = 5,
									step = 0.1,
									get = 
										function(info)
											return E.db.ElvUI_Animations[i].Animation.Default.Delay.End
										end,
									set = 
										function(info, value)
											E.db.ElvUI_Animations[i].Animation.Default.Delay.End = value
										end,
								},
								Duration = {
									order = 4,
									type = "range",
									name = "Animation Duration",
									desc = "How long the animations will take",
									min = 0,
									max = 5,
									step = 0.1,
									get = 
										function(info)
											return E.db.ElvUI_Animations[i].Animation.Default.Duration
										end,
									set = 
										function(info, value)
											E.db.ElvUI_Animations[i].Animation.Default.Duration = value
										end,
								},
							},
						},	
						Division = {
							order = 6,
							type = "header",
							name = "Animations",
						},				
					},
				},
				TabConfig = {
					order = -1,
					type = "group",
					name = "Configure",
					args = { },
				},
			},
		}

		for j = 1, #E.db.ElvUI_Animations[i].Animation do
			Key = "Animation_"..j 
			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].Config.KeyName].args.Animation.args[Key] = CreateAnimationPage(i, j, j + 5)
		end
				
		if i == 1 then
			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].Config.KeyName].args.Animation.args.TestAll = {
				order = 1,
				type = "execute",
				name = "Test All!",
				desc = "Test all the animations at the same time",
				func = 
					function()
						ElvUI_Animations:ReloadCombatAnimationGroup()

						for i = 2, #E.db.ElvUI_Animations do
							ElvUI_Animations:AttemptAnimation(i)
						end
					end,
			}			
			for j = 2, #E.db.ElvUI_Animations do
				E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].Config.KeyName].args.TabConfig.args[E.db.ElvUI_Animations[j].Config.KeyName.."Config"] = CreateConfigTab(j)
			end		
		else
			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].Config.KeyName].args.TabConfig.args[E.db.ElvUI_Animations[i].Config.KeyName.."Config"] = CreateConfigTab(i)

			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].Config.KeyName].args.Combat.args.Enabled = {
				order = 1,
				type = "toggle",
				name = "Enabled",
				desc = "Whether or not to fade the frame based on combat flags",
				get = 
					function(info)
						return E.db.ElvUI_Animations[i].Combat.Enabled
					end,
				set = 
					function(info, value)
						E.db.ElvUI_Animations[i].Combat.Enabled = value
						Update(i)	-- We changed a toggle, call our Update function
					end,
			}
			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].Config.KeyName].args.Combat.args.UseDefaults = {
				order = 2,
				type = "toggle",
				name = "Use Defaults",
				desc = "Whether or not to use the default values or set up individual values for this frame",
				get = 
					function(info)
						return E.db.ElvUI_Animations[i].Combat.UseDefaults
					end,
				set = 
					function(info, value)
						E.db.ElvUI_Animations[i].Combat.UseDefaults = value
						Update(i)	-- We changed a toggle, call our Update function
					end,
			}
			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].Config.KeyName].args.Animation.args.Enabled = {
				order = 1,
				type = "toggle",
				name = "Enabled",
				desc = "Whether or not to animate this Frame",
				get = 
					function(info)
						return E.db.ElvUI_Animations[i].Animation.Enabled
					end,
				set = 
					function(info, value)
						E.db.ElvUI_Animations[i].Animation.Enabled = value
						Update(i)	-- We changed a toggle, call our Update function
					end,
			}
			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].Config.KeyName].args.Animation.args.TestAll = {
				order = 2,
				type = "execute",
				name = "Test All!",
				desc = "Test all the animations at the same time",
				func = 
					function()
						ElvUI_Animations:ReloadCombatAnimationGroup()

						ElvUI_Animations:AttemptAnimation(i)
					end,
			}
			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].Config.KeyName].args.Animation.args.General.args.UseDefaults = {
				order = 1,
				type = "toggle",
				name = "Use Defaults",
				desc = "Whether or not to use the default values or set up individual values for this frame",
				get = 
					function(info)
						return E.db.ElvUI_Animations[i].Animation.UseDefaults
					end,
				set = 
					function(info, value)
						E.db.ElvUI_Animations[i].Animation.UseDefaults = value
						Update(i)	-- We changed a toggle, call our Update function
					end,
			}
		end
		Update(i)
		
		local GoobyPls = false
		E.db.ElvUI_Animations[i].Config.Error = { }

		for j = 1, #E.db.ElvUI_Animations[i].Config.Frame do
			if GetClickFrame(E.db.ElvUI_Animations[i].Config.Frame[j]) == nil  and i ~= 1 then
				E.db.ElvUI_Animations[i].Config.Error[j] = true
				GoobyPls = true
			end
		end

--		if GoobyPls then
--			if i <= #P.ElvUI_Animations and E.db.ElvUI_Animations[i].Config.Frame ~= P.ElvUI_Animations[i].Config.Frame then
--				print("Wait a sec are u trying to set one of "..E.db.ElvUI_Animations[i].Config.Name.."'s Frames to a nil value?")
--				print("gooby pls")
--			end
--			if #E.db.ElvUI_Animations[i].Config.Frame == #E.db.ElvUI_Animations[i].Config.Error then
--				E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].Config.KeyName].args.Animation.disabled = true
--				E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].Config.KeyName].args.Combat.disabled = true
--			end
--		elseif #E.db.ElvUI_Animations[i].Config.Frame == 0 then
--			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].Config.KeyName].args.Animation.disabled = true
--			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].Config.KeyName].args.Combat.disabled = true
--		else
--			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].Config.KeyName].args.Animation.disabled = false
--			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[i].Config.KeyName].args.Combat.disabled = false
--		end
	end
end

-- Setup Restore Defaults confirmation popup
E.PopupDialogs.RestoreDefaults = {
	text = "You are about to set ALL values back to default.\n This cannot be reversed. Are you sure?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = 
		function() 
			E.db.ElvUI_Animations = copy(P.ElvUI_Animations)
			E:RefreshGUI()
		end,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3,
}
E.PopupDialogs.DeleteTab = {
	text = "You are about to delete the selected tab!\nThis cannot be reversed. Are you sure?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = 
		function() 
			E.Options.args.ElvUI_Animations.args[E.db.ElvUI_Animations[tonumber(V.ElvUI_Animations.DeleteTab)].Config.KeyName] = nil
			table.remove(E.db.ElvUI_Animations, tonumber(V.ElvUI_Animations.DeleteTab))
			ElvUI_Animations:InsertOptions()
			E:RefreshGUI()
		end,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3,
}

E:RegisterModule(ElvUI_Animations:GetName()) -- Register the module with ElvUI. ElvUI will now call ElvUI_Animations:Initialize() when ElvUI is ready to load our plugin.