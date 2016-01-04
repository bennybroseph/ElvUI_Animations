---------------------------------------------------
-- File:			defaults.lua
-- Author:			Benjamin Odom
-- Date Created:	01-04-2016
--
-- Brief:	Essentially the main.cpp
--	Holds all of the add-ons basic callbacks 	
---------------------------------------------------

local E, L, V, P, G = unpack(ElvUI);	-- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local _ElvUI_Animations = E:NewModule('ElvUI_Animations', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');	-- Create a plugin within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.

local _AddonName, _AddonTable = ... -- See http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2


local function _AddonTable:Copy(Table)
	if type(Table) ~= "table" then return Table end

	local Meta = getmetatable(Table)

	local Target = {}
	for k, v in pairs(Table) do 
		Target[k] = v 
	end
	setmetatable(Target, Meta)

	return Target
end

--region Setting default values to parse
_AddonTable._Defaults = {
	_Tabs = {
		_Names = {
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
		_Default = {								-- The default values for a configuration tab

			Animation = {							-- The settings for animations played after loading screens and afk
				Enabled = true,						-- If this frame should be animated
	
				UseDefaults = true,					-- If the default tab settings should be used instead of this one

				DefaultDuration = {					-- Default timing settings for the animation as a whole. Not to be confused with the default tab 
					Duration = 1.5,
		
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

						Duration = 0.3,

						Delay = {
							Start = 0,
							End = 0,
						},
					},

					AnimationSpecific = {
						Start = 0,
						End = 0.9,
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

			Config = { },						-- This is created but not populated because we don't know what 'Config.Frame', 'Config.Name' ect.. could defaulted to
		},
		--endregion
	},
}
--endregion

--region Setting up default profile variables

-- Set up the table, but leave it empty
P.ElvUI_Animations = { Animate = true, AFK = true, Combat = true, Lag = true, { }, }

-- Created the defaults table for the addon. ElvUI does some magic here, somehow it ends up being named the same
for k, v in pairs(addonTable._Defaults._Tabs._Names) do
	P.ElvUI_Animations[k] = addonTable:Copy(addonTable._Defaults._Tabs._Default)
end

P.ElvUI_Animations['Default_Tab'].Config = {
	Order = 1,					-- Order that this tab should show up in the configuration
	Frame = { "All" },			-- The name of the frames affected by this tabs settings
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

for i = 12, 17 do
	P.ElvUI_Animations['Bar'..i..'_Tab'].Config = {
		KeyName = "Bar_" .. i - AfterUF + 1,
		Frame = { "ElvUI_Bar"..i - AfterUF + 1, 
			Fade = { }, 
		},
		Name = L['Bar'].." ".. i - AfterUF + 1,
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

--region Setting up Animation Groups

--endregion
---------------------------------------------------------------------------------------------------------------------------------------
-- End of Defaults
---------------------------------------------------------------------------------------------------------------------------------------