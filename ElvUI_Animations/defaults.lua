---------------------------------------------------
-- File:			defaults.lua
-- Author:			Benjamin Odom
-- Date Created:	01-04-2016
--
-- Brief:	Sets up all variables to be used upon 
--	launching the game 	
---------------------------------------------------

local E, L, V, P, G = unpack(ElvUI);	-- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local _AddonName, _AddonTable = ... -- See http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2


_AddonTable._System = { }
local _System = _AddonTable._System

--region Setting up system functions
function _AddonTable._System:GetKey(Table, Value)
	for k, v in pairs(Table) do
		if (v == Value) then
			return k
		end
	end
	
	return nil -- If the passed value was not found
end
function _AddonTable._System:Copy(Table)
	if type(Table) ~= "table" then return Table end

	local Meta = getmetatable(Table)

	local Target = { }
	for k, v in pairs(Table) do 
		Target[k] = v 
	end
	setmetatable(Target, Meta)

	return Target
end
--endregion

--region Setting default values to parse
_AddonTable._Defaults = {
	Tab = {
		Names = {
			"Default_Tab", 
			"Player_Tab", "Target_Tab",
			"Party_Tab", "Raid_Tab", "Raid40_Tab",
			"LeftChat_Tab", "RightChat_Tab",
			"Objective_Tab",
			"Minimap_Tab",
			"Buffs_Tab",
			"Bar1_Tab", "Bar2_Tab", "Bar3_Tab", "Bar4_Tab", "Bar5_Tab", "Bar6_Tab",
			"TopPanel_Tab", "BottomPanel_Tab",
		},
		--region Defaults Table
		Default = {								-- The default values for a configuration tab

			Animation = {							-- The settings for animations played after loading screens and afk
				Enabled = true,						-- If this frame should be animated
	
				UseDefaults = true,					-- If the default tab settings should be used instead of this one

				DefaultDuration = {					-- Default timing settings for the animation as a whole. Not to be confused with the default tab 
					Time = 1.5,
		
					Delay = {
						Start = 0,
						End = 0,
					}, 
				},
		
				FadeAnimation_Tab = {				-- 'Alpha' animation settings
					Enabled = true,
		
					Order = 1,			

					Name = L['Fade'],
					AnimationName = "Alpha",
					Effect = L['Alpha'],

					CustomDuration = {
						Enabled = false,

						Time = 0.3,

						Delay = {
							Start = 0,
							End = 0,
						},
					},

					Alpha = {
						Start = 0,
						End = 0.9
					},

					Smoothing = "IN",
				},
		--region Not Yet Yung 1
		--		{									-- Translation animation settings
		--			Enabled = false,

		--			Order = 1,

		--			Name = L['Slide'],
		--			AnimationName = "Translation",
		--			Effect = L['Offset'],

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

		--			Name = L['Bounce'],
		--			AnimationName = "Translation",
		--			Effect = L['Offset'],

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
	
			Combat = {						-- Settings relating to combat fading/alpha animation
				Enabled = true,				-- If this frame should be animated
		
				UseDefaults = true,			-- If the default tab settings should be used instead of this one

				Duration = {
					In = 0.3,				-- Time to animate for in combat flag
					Out = 1,				-- Time to animate for out of combat flag
				},

				Alpha = {
					In = 0.25,				-- In combat alpha
					Out = 0.9,				-- Out of combat alpha
				},
		
				Smoothing = {
					In = "IN",
					Out = "IN",
				},
		
				Mouse = {					-- Settings related to mouse-over fading
					Enabled = true,
		
					Duration = {
						On = 0.2,
						Off = 0.5,
					},
			
					Alpha = 1,
				},
			},

			Config = { },					-- This is created but not populated because we don't know what 'Config.Frame', 'Config.Name' ect.. could defaulted to
		},
		--endregion
	},
}
--endregion

--region Setting up default profile variables

-- Set up the table, but leave it empty
P.ElvUI_Animations = { CurrentTabs = 19, Animate = true, AFK = true, Combat = true, Lag = true, { }, }

-- Created the defaults table for the addon. ElvUI does some magic here, somehow it ends up being named the same
for i = 1, #_AddonTable._Defaults.Tab.Names do
	P.ElvUI_Animations[_AddonTable._Defaults.Tab.Names[i]] = _System:Copy(_AddonTable._Defaults.Tab.Default)
end

P.ElvUI_Animations['Default_Tab'].Config = {
	Order = 1,					-- Order that this tab should show up in the configuration
	Frame = nil,				-- The name of the frames affected by this tabs settings
	Name = L['Default'],		-- The name displayed to the user for this tab
	Error = false,
}

P.ElvUI_Animations['Player_Tab'].Config = {
	Order = 2,
	Frame = { "ElvUF_Player", "ElvUF_Focus", "ElvUF_FocusTarget", 
		Fade = {  },				-- 'Fade' refers to frames which should fade in after a translation animation plays since they are tightly anchored and do not animate properly
	},									
	Name = L['Player Frame'],
	Error = { 
		Fade = {  },				-- The index of a frame which is currently nil as set by the user. Used to tell the user they goofed on the frame's name
	},		
}	
P.ElvUI_Animations['Target_Tab'].Config = {
	Order = 3,
	Frame = { "ElvUF_Target", "ElvUF_TargetTarget", "ElvUF_TargetTargetTarget",
		Fade = {  }, 
	},
	Name = L['Target Frame'],
	Error = { 
		Fade = {  }, 
	},
}

P.ElvUI_Animations['Party_Tab'].Config = {
	Order = 4,
	Frame = { "ElvUF_Party",
		Fade = {  }, 
	},
	Name = L['Party Frames'],
	Error = { 
		Fade = {  }, 
	},
}

P.ElvUI_Animations['Raid_Tab'].Config = {
	Order = 5,
	Frame = { "ElvUF_Raid",
		Fade = {  }, 
	},
	Name = L['Raid Frames'],
	Error = { 
		Fade = {  }, 
	},
}
P.ElvUI_Animations['Raid40_Tab'].Config = {
	Order = 6,
	Frame = { "ElvUF_Raid40",
		Fade = {  }, 
	},
	Name = L['Raid-40 Frames'],
	Error = { 
		Fade = {  }, 
	},
}

P.ElvUI_Animations['LeftChat_Tab'].Config = {
	Order = 7,
	Frame = { "LeftChatPanel", "ElvUI_ExperienceBar", "LeftChatToggleButton", 
		Fade = { }, 
	},
	Name = L['Left Chat Panel'],
	Error = { 
		Fade = {  }, 
	},
}
P.ElvUI_Animations['RightChat_Tab'].Config = {
	Order = 8,
	Frame = { "RightChatPanel", "ElvUI_ReputationBar", "RightChatToggleButton", 
		Fade = { }, 
	},
	Name = L['Right Chat Panel'],
	Error = { 
		Fade = {  }, 
	},
}

P.ElvUI_Animations['Objective_Tab'].Config = {
	Order = 9,
	Frame = { "ObjectiveTrackerFrame", 
		Fade = { }, 
	},
	Name = L['Objective Frame'],
	Error = { 
		Fade = {  }, 
	},
}

P.ElvUI_Animations['Minimap_Tab'].Config = {
	Order = 10,
	Frame = { "MinimapCluster", "MinimapButtonBar", 
		Fade = { }, 
	},
	Name = L['MiniMap'],
	Error = { 
		Fade = {  }, 
	},
}

P.ElvUI_Animations['Buffs_Tab'].Config = {
	Order = 11,
	Frame = { "ElvUIPlayerBuffs", "ElvUIPlayerDebuffs",
		Fade = { }, 
	},
	Name = L['Player Buffs'],
	Error = { 
		Fade = {  }, 
	},
}

for i = 1, 6 do
	P.ElvUI_Animations['Bar'..i..'_Tab'].Config = {
		Order = 11 + i,
		Frame = { "ElvUI_Bar"..i, 
			Fade = { }, 
		},
		Name = L['Bar'].." ".. i,
		Error = { 
			Fade = {  }, 
		},
	}
end

P.ElvUI_Animations['TopPanel_Tab'].Config = {
	Order = 18,
	Frame = { "ElvUI_TopPanel", "TitanPanelLootTypeButton", "TitanPanelRepairButton", "TitanPanelGoldButton", "TitanPanelXPButton", "TitanPanelLocationButton",
		Fade = { }, 
	},
	Name = L['Top Panel'],
	Error = { 
		Fade = {  }, 
	},
}
P.ElvUI_Animations['BottomPanel_Tab'].Config = {
	Order = 19,
	Frame = { "ElvUI_BottomPanel", 
		Fade = { }, 
	},
	Name = L['Bottom Panel'],
	Error = { 
		Fade = {  }, 
	},
}
--endregion

--region Setting up loose variables that don't need to carry over per session
_AddonTable._NotKept = { }

--region Setting up Animation Groups
_AddonTable._NotKept.Animations = { }

_AddonTable._NotKept.CombatAnimations = { }
--endregion
_AddonTable._NotKept.ShouldAppear = false
_AddonTable._NotKept.TabToDelete = ""

_AddonTable._NotKept.CombatAnimations.AlphaBuildUp = { }		-- For some reason adding less than 0.01 alpha to a frame seems to cause floating point error where it isn't added to the overall alpha of the frame

--region Animation Group Functions and Alias
--region Animation Group
function _AddonTable._NotKept.Animations:SetAnimationGroups(KeyName)
	local _DataBase = E.db.ElvUI_Animations

	if KeyName == nil then
		for k, v in pairs(_DataBase) do
			if string.find(k, "_Tab") and k ~= "Default_Tab" then
				self:SetAnimationGroups(k)
			end
		end
	else
		_AddonTable._NotKept.Animations[KeyName] = { AnimationGroup = { }, }

		local Animations = _AddonTable._NotKept.Animations[KeyName]
		local DataBase = _DataBase[KeyName]			
			
		for i = 1, #DataBase.Config.Frame do
			local Frame = GetClickFrame(DataBase.Config.Frame[i])

			if Frame ~= nil then					
				Animations.AnimationGroup[i] = Frame:CreateAnimationGroup()
				Animations.AnimationGroup[i].Animation = { }
				for k, v in pairs(DataBase.Animation) do
					if string.find(k, "_Tab") then
						Animations.AnimationGroup[i].Animation[k] = Animations.AnimationGroup[i]:CreateAnimation(DataBase.Animation[k].AnimationName)
					end
				end
			end
		end
	end
end
--endregion

--region Combat Animation Group
function _AddonTable._NotKept.CombatAnimations:SetAnimationGroups(KeyName)
	local _DataBase = E.db.ElvUI_Animations

	if KeyName == nil then
		for k, v in pairs(_DataBase) do
			if string.find(k, "_Tab") and k ~= "Default_Tab" then
				self:SetAnimationGroups(k)
			end
		end
	else
		_AddonTable._NotKept.CombatAnimations[KeyName] = { AnimationGroup = { }, Animation = { }, }

		local Animations = _AddonTable._NotKept.CombatAnimations[KeyName]
		local DataBase = _DataBase[KeyName]
			
		for i = 1, #DataBase.Config.Frame do
			local Frame = GetClickFrame(DataBase.Config.Frame[i])
				
			if Frame ~= nil then
				Animations.AnimationGroup[i] = { In = { }, Out = { }, }
				Animations.Animation[i] = { In = { }, Out = { }, }

				Animations.AnimationGroup[i].In = Frame:CreateAnimationGroup()
				Animations.Animation[i].In = Animations.AnimationGroup[i].In:CreateAnimation("Alpha")
				
				Animations.AnimationGroup[i].Out = Frame:CreateAnimationGroup()
				Animations.Animation[i].Out = Animations.AnimationGroup[i].Out:CreateAnimation("Alpha")
			end
		end
	end 
end
--endregion

_AddonTable._NotKept.Animations.SetAnimGroups = _AddonTable._NotKept.Animations.SetAnimationGroups

_AddonTable._NotKept.CombatAnimations.SetAnimGroups = _AddonTable._NotKept.CombatAnimations.SetAnimationGroups
--endregion
--endregion
---------------------------------------------------------------------------------------------------------------------------------------
-- End of defaults.lua
---------------------------------------------------------------------------------------------------------------------------------------