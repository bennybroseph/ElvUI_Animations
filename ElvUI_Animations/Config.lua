---------------------------------------------------
-- File:			Config.lua
-- Author:			Benjamin Odom
-- Date Created:	01-02-2016
--
-- Brief:	Holds all code related to the creation
--	of the configuration for the add-on. 	
---------------------------------------------------

local E, L, V, P, G = unpack(ElvUI);	-- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local _DataBase
local _Options

local _ElvUI_Animations = E:NewModule('ElvUI_Animations', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');	-- Create a plug-in within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.
_ElvUI_Animations.version = GetAddOnMetadata("ElvUI_Animations", "Version")

E:RegisterModule(_ElvUI_Animations:GetName()) -- Register the module with ElvUI. ElvUI will now call _ElvUI_Animations:Initialize() when ElvUI is ready to load our plug-in.

local _EP = LibStub("LibElvUIPlugin-1.0") -- We can use this to automatically insert our GUI tables when ElvUI_Config is loaded.

local _AddonName, _AddonTable = ... -- See http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2

_AddonTable._Config = { }

local _System = _AddonTable._System
local _Cache = _AddonTable._Cache

local _Core
local _Animations 
local _CombatAnimations

--region Function we can call when a setting changes.
local function UpdateState(KeyName)
	local DataBase = _DataBase[KeyName]										-- The local 'DataBase' should always point to the relevant animation configuration tab's data
	local AnimationOptions = _Options[KeyName].args.AnimationOptions		-- The local 'AnimationOptions' should always point to the relevant animation configuration tab
	local Combat = _Options[KeyName].args.CombatOptions						-- The local 'Combat' should always point to the relevant combat animation configuration tab

	if KeyName ~= "Default_Tab" then		-- If we've been told by the caller of the function to update the something other than the default tab's state
		--region Start disabling all the things
		AnimationOptions.disabled = not _DataBase.Animate
		AnimationOptions.args.GeneralOptions.disabled = true
		AnimationOptions.args.GeneralOptions.args.UseDefaults.disabled = true

		for k, v in pairs(DataBase.Animation) do		-- Iterate through each key in 'DataBase.Animation' and only stop on key which end in "_Tab"
			if string.find(k, "_Tab") then		
				AnimationOptions.args[k].args.GeneralOptions.disabled = true
				AnimationOptions.args[k].args.Enabled.disabled = true
				AnimationOptions.args[k].args.CustomDurationOptions.disabled = true
				AnimationOptions.args[k].args.CustomDurationOptions.args.Enabled.disabled = true
				
				_Cache:AnimTab(KeyName, k)
			end
		end
		--endregion
		
		--region Traverse through each limiting option and enable things that should be enabled
		if E.db.ElvUI_Animations.Animate then
			if DataBase.Animation.Enabled then
				AnimationOptions.args.GeneralOptions.args.UseDefaults.disabled = false

				if not DataBase.Animation.UseDefaults then
					AnimationOptions.args.GeneralOptions.disabled = false
					for k, v in pairs(DataBase.Animation) do
						if string.find(k, "_Tab") then
							AnimationOptions.args[k].args.Enabled.disabled = false

							if DataBase.Animation[k].Enabled then
								AnimationOptions.args[k].args.GeneralOptions.disabled = false

								AnimationOptions.args[k].args.CustomDurationOptions.args.Enabled.disabled = false
								if DataBase.Animation[k].CustomDuration.Enabled then
									AnimationOptions.args[k].args.CustomDurationOptions.disabled = false
								end
							end
						end
					end
				end
			end	
		end
		--endregion

		Combat.disabled = true
		Combat.args.UseDefaults.disabled = true

		Combat.args.AlphaOptions.disabled = true
		Combat.args.DurationOptions.disabled = true
		Combat.args.SmoothingOptions.disabled = true	

		Combat.args.MouseOptions.disabled = true
		Combat.args.MouseOptions.args.Enabled.disabled = true

		if _DataBase.Combat then
			Combat.disabled = false

			if DataBase.Combat.Enabled then
				Combat.args.UseDefaults.disabled = false
				if not DataBase.Combat.UseDefaults then
					Combat.args.AlphaOptions.disabled = false
					Combat.args.DurationOptions.disabled = false
					Combat.args.SmoothingOptions.disabled = false

					Combat.args.MouseOptions.args.Enabled.disabled = false
					if DataBase.Combat.Mouse.Enabled then
						Combat.args.MouseOptions.disabled = false
					end
				end
			end
		end
		_Cache:CombatAnimTab(KeyName)
	else 
		AnimationOptions.disabled = true
		for k, v in pairs(DataBase.Animation) do
			if string.find(k, "_Tab") then
				AnimationOptions.args[k].args.GeneralOptions.disabled = true
				AnimationOptions.args[k].args.Enabled.disabled = false
				AnimationOptions.args[k].args.CustomDurationOptions.disabled = true
				AnimationOptions.args[k].args.CustomDurationOptions.args.Enabled.disabled = true

				if _DataBase.Animate then
					AnimationOptions.disabled = false

					if DataBase.Animation[k].Enabled then
						AnimationOptions.args[k].args.GeneralOptions.disabled = false

						AnimationOptions.args[k].args.CustomDurationOptions.args.Enabled.disabled = false
						if DataBase.Animation[k].CustomDuration.Enabled then
							AnimationOptions.args[k].args.CustomDurationOptions.disabled = false
						end
					end
				end
			end
		end

		Combat.args.MouseOptions.disabled = true
		Combat.args.MouseOptions.args.Enabled.disabled = false


		if DataBase.Combat.Mouse.Enabled then
			Combat.args.MouseOptions.disabled = false
		end

		_Cache:AnimTab()
		_Cache:CombatAnimTab()
	end
end
--endregion

local function UpdateMoveButtonState(KeyName)
	if KeyName ~= "Default_Tab" then
		local Options = _Options[KeyName].args[KeyName.."Config"]

		if _DataBase[KeyName].Config.Order == 2 then
			Options.args.MoveUp.name = "|cff333333Move Up|r"
			Options.args.MoveUp.disabled = true
		else
			Options.args.MoveUp.name = "Move Up"
			Options.args.MoveUp.disabled = false
		end
		if _DataBase[KeyName].Config.Order == _DataBase.CurrentTabs then
			Options.args.MoveDown.name = "|cff333333Move Down|r"
			Options.args.MoveDown.disabled = true
		else
			Options.args.MoveDown.name = "Move Down"
			Options.args.MoveDown.disabled = false
		end
	end
end

local function ValidateFrames(KeyName)
	local GoobyPls = false
	local DataBase = _DataBase[KeyName]
	local Options = _Options[KeyName]
	
	DataBase.Config.Error = { }
	
	for i = 1, #DataBase.Config.Frame do
		if GetClickFrame(DataBase.Config.Frame[i]) == nil then
			DataBase.Config.Error[i] = true
			GoobyPls = true
		end
	end

	if GoobyPls then
--		if i <= #P.ElvUI_Animations and E.db.ElvUI_Animations[i].Config.Frame ~= P.ElvUI_Animations[i].Config.Frame then
--			print("Wait a sec are u trying to set one of "..E.db.ElvUI_Animations[i].Config.Name.."'s Frames to a nil value?")
--			print("gooby pls")
--		end
		if #DataBase.Config.Frame == #DataBase.Config.Error then
			Options.args.AnimationOptions.disabled = true
			Options.args.CombatOptions.disabled = true
		end
	elseif #DataBase.Config.Frame == 0 then
		Options.args.AnimationOptions.disabled = true
		Options.args.CombatOptions.disabled = true
	else
		Options.args.AnimationOptions.disabled = false
		Options.args.CombatOptions.disabled = false
	end
end

local function CreateConfigTab(KeyName)
	local TabConfig = { }		-- Create the return table
	
	local DataBase = _DataBase[KeyName]		-- The local 'DataBase' should always point to the relevant configuration tab

	TabConfig = {
		order = DataBase.Config.Order + 5,
		type = "group",
		name = DataBase.Config.Name.." Config",
		--guiInline = true,
		args = {
			Name = {
				order = 1,
				type = "input",
				name = "Rename Tab",
				get = 
					function(info)
						return DataBase.Config.Name
					end,
				set = 
					function(info, value)
						DataBase.Config.Name = value
						_Options[KeyName].name = DataBase.Config.Name
						TabConfig.name = DataBase.Config.Name.." Config"
					end,
			},
			Frames = {
				order = 5,
				type = "input",
				name = "Change Frames",
				desc = "Enter the name of the frame that you would like to be affected by this tabs configuration.\nFormat is:\n\n%Frame1%; %Frame2%;\n\nYou can put a 'return' in between frames.\n\nUse /framestack to check the names of frames",
				multiline = true,
				get = 
					function(info)
						local ReturnString = ""

						for j = 1, #DataBase.Config.Frame do
							if DataBase.Config.Error[j] then
								ReturnString = ReturnString.."|cffFF1010"
							end

							ReturnString = ReturnString..DataBase.Config.Frame[j]

							if DataBase.Config.Error[j] then
								ReturnString = ReturnString.."|r"
							end
							
							ReturnString = ReturnString..";\n"
						end

						return ReturnString
					end,
				set = 
					function(info, value)
						local Parse = string.gsub(value, "%s+", "")
						local Current = { Start = 1, End = string.len(Parse) }	

						DataBase.Config.Frame = { Fade = DataBase.Config.Frame.Fade, }
						local j = 1
									
						while string.find(Parse, "|cff") do
							Current.Start = string.find(Parse, "|cff") + 10
							Current.End = string.find(Parse,"|r")
   
							Parse = string.sub(Parse, 1, Current.Start - 11)..string.sub(Parse, Current.Start, Current.End -1)..string.sub(Parse, Current.End + 2, string.len(Parse))  
						end
						j = 1
						while string.find(Parse, ";") do
							Current.End = string.find(Parse, ";")
							
							DataBase.Config.Frame[j] = string.sub(Parse, 1, Current.End - 1)
									
							Parse = string.sub(Parse, Current.End + 1, string.len(Parse))

							j = j + 1
						end
						ValidateFrames(KeyName)

						_Animations:SetAnimGroups(KeyName)
						_CombatAnimations:SetAnimationGroups(KeyName)
			
						_Cache:AnimTab(KeyName)
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
				for k, v in pairs(_DataBase) do
					if string.find(k, "_Tab") then
						local DataBaseToMove = _DataBase[k]
						local OptionToMove = _Options[k]
						
						if DataBaseToMove.Config.Order == DataBase.Config.Order - 1 then
							DataBaseToMove.Config.Order = DataBaseToMove.Config.Order + 1
							OptionToMove.order = DataBaseToMove.Config.Order
				
							UpdateMoveButtonState(k)
							break
						end
					end
				end
				DataBase.Config.Order = DataBase.Config.Order - 1
				_Options[KeyName].order = DataBase.Config.Order

				UpdateMoveButtonState(KeyName)
			end,
	}
	TabConfig.args.MoveDown = {
		order = 3,
		type = "execute",	
		name = "Move Down",
		desc = "Move this tab Down one space",
		func = 
			function()										
				for k, v in pairs(_DataBase) do
					if string.find(k, "_Tab") then
						local DataBaseToMove = _DataBase[k]
						local OptionToMove = _Options[k]
						
						if DataBaseToMove.Config.Order == DataBase.Config.Order + 1 then
							DataBaseToMove.Config.Order = DataBaseToMove.Config.Order - 1
							OptionToMove.order = DataBaseToMove.Config.Order

							UpdateMoveButtonState(k)
							break
						end
					end
				end
				DataBase.Config.Order = DataBase.Config.Order + 1
				_Options[KeyName].order = DataBase.Config.Order

				UpdateMoveButtonState(KeyName)
			end,
	}
	
	return TabConfig
end

local function CreateAnimationPage(KeyName, AnimationKeyName, Order)	
	local AnimKey = AnimationKeyName
	
	local DataBase = _DataBase[KeyName].Animation[AnimKey]
	local Cache = _Cache[KeyName].Animation
	
	local AnimationPage = { }
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
						if KeyName ~= "Default_Tab" then
							return Cache[AnimKey].Enabled
						else
							return DataBase.Enabled
						end				
					end,
				set = 
					function(info, value)
						DataBase.Enabled = value
						UpdateState(KeyName)	-- We changed a toggle, call our Update function				
					end,
			},
			GeneralOptions = {
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
								if KeyName ~= "Default_Tab" then
									return Cache[AnimKey].Smoothing
								else
									return DataBase.Smoothing
								end
							end,
						set = 
							function(info, value)
								DataBase.Smoothing = value

								_Cache:AnimTab(KeyName, AnimKey)
							end,
					},
				},
			},
			
			CustomDurationOptions = {
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
								if KeyName ~= "Default_Tab" then
									return Cache[AnimKey].CustomDuration.Enabled
								else
									return DataBase.CustomDuration.Enabled
								end
							end,
						set = 
							function(info, value)
								DataBase.CustomDuration.Enabled = value
								UpdateState(KeyName)	-- We changed a toggle, call our Update function
							end,
					},	
					Time = {
						order = 2,
						type = "range",
						name = DataBase.Name.." Duration",
						desc = "How long it will take to "..DataBase.Name.." the frame",
						min = 0,
						max = 5,
						step = 0.1,
						get = function(info)
							if KeyName ~= "Default_Tab" then
								return Cache[AnimKey].Duration.Time
							else
								return DataBase.CustomDuration.Time
							end
						end,
						set = function(info, value)
							DataBase.CustomDuration.Time = value
							
							_Cache:AnimTab(KeyName, AnimKey)
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
								if KeyName ~= "Default_Tab" then
									return Cache[AnimKey].Duration.Delay.Start
								else
									return DataBase.CustomDuration.Delay.Start
								end
							end,
						set = 
							function(info, value)
								DataBase.CustomDuration.Delay.Start = value

								_Cache:AnimTab(KeyName, AnimKey)
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
								if KeyName ~= "Default_Tab" then
									return Cache[AnimKey].Duration.Delay.End
								else
									return DataBase.CustomDuration.Delay.End
								end
							end,
						set = 
							function(info, value)
								DataBase.CustomDuration.Delay.End = value

								_Cache:AnimTab(KeyName, AnimKey)
							end,
					},
				},
			},				
		},
	}
	
	if DataBase.AnimationName == "Alpha" then
		AnimationPage.args.GeneralOptions.args["Start"..DataBase.Effect] = {
			order = 1,
			type = "range",
			name = "Start "..DataBase.Effect,
			desc = "What "..DataBase.Effect.." the animation should start at",
			min = 0,
			max = 1,
			step = 0.01,
			get = 
				function(info)
					if KeyName ~= "Default_Tab" then
						return Cache[AnimKey].Alpha.Start
					else
						return DataBase.Alpha.Start
					end					
				end,
			set = 
				function(info, value)
					DataBase.Alpha.Start = value
			
					_Cache:AnimTab(KeyName, AnimKey)
				end,									
		}
		AnimationPage.args.GeneralOptions.args["End"..DataBase.Effect] = {
			order = 2,
			type = "range",
			name = "End "..DataBase.Effect,
			desc = "What "..DataBase.Effect.." the animation should end at",
			min = 0,
			max = 1,
			step = 0.01,
			get = 
				function(info)
					if KeyName ~= "Default_Tab" then
						return Cache[AnimKey].Alpha.End
					else
						return DataBase.Alpha.End
					end					
				end,
			set = 
				function(info, value)
					DataBase.Alpha.End = value
			
					_Cache:AnimTab(KeyName, AnimKey)
				end,									
		}
	end
	if DataBase.AnimationName == "Translation" then
		AnimationPage.args.GeneralOptions.args[DataBase.Effect.."X"] = {
			order = 1,
			type = "range",
			name = DataBase.Effect.."X",
			desc = "What X "..DataBase.Effect.." the animation should start at",
			min = -150,
			max = 150,
			step = 5,
			get = 
				function(info)
					return DataBase.Offset.X
				end,
			set = 
				function(info, value)
					DataBase.Offset.X = value
				end,									
		}
		AnimationPage.args.GeneralOptions.args[DataBase.Effect.."Y"] = {
			order = 2,
			type = "range",
			name = DataBase.Effect.."Y",
			desc = "What Y "..DataBase.Effect.." the animation should start at",
			min = -150,
			max = 150,
			step = 5,
			get = 
				function(info)
					return DataBase.Offset.Y
				end,
			set = 
				function(info, value)
					DataBase.Offset.Y = value
				end,				
		}
		AnimationPage.args.GeneralOptions.args["DistanceX"] = {
			order = 3,
			type = "range",
			name = "DistanceX",
			desc = "How far in the X direction the frame should travel",
			min = -150,
			max = 150,
			step = 5,
			get = 
				function(info)
					return DataBase.Distance.X
				end,
			set = 
				function(info, value)
					DataBase.Distance.X = value
				end,
		}
		AnimationPage.args.GeneralOptions.args["DistanceY"] = {
			order = 4,
			type = "range",
			name = "DistanceY",
			desc = "How far in the Y direction the frame should travel",
			min = -150,
			max = 150,
			step = 5,
			get = function(info)
				return DataBase.Distance.Y
			end,
			set = function(info, value)
				DataBase.Distance.Y = value
			end,
		}
	end
	
	if KeyName == "Default_Tab" then
		AnimationPage.args.TestButton = {
			order = - 1,
			type = "execute",
			name = "Test It!",
			desc = DataBase.Name.." the selected frame",
			func = 
				function()
					for k, v in pairs(_DataBase) do
						if string.find(k, "_Tab") and k ~= "Default_Tab" then
							for kk, vv in pairs(_DataBase[k].Animation) do
								if string.find(kk, "_Tab") and kk ~= AnimKey then
									for i = 1, #_DataBase[k].Config.Frame do
										print(k, i, kk)
										_Animations[k].AnimationGroup[i].Animation[kk]:SetScript("OnPlay", 
											function()
												self:Stop()
											end)
									end
								end
							end
							_Core:Animate(k)
						end
					end
				end,
		}
	else
		AnimationPage.args.TestButton = {
			order = - 1,
			type = "execute",
			name = "Test It!",
			desc = DataBase.Name.." the selected frame",
			func = 
				function()
					for k, v in pairs(_DataBase[KeyName].Animation) do
						if string.find(k, "_Tab") and k ~= AnimKey then
							for i = 1, #_DataBase[KeyName].Config.Frame do
								print(KeyName, i, k)
								_Animations[KeyName].AnimationGroup[i].Animation[k]:SetScript("OnPlay", 
									function()
										self:Stop()
									end)
							end
						end
					end
					_Core:Animate(KeyName)
				end,
		}
	end

	return AnimationPage
end

local function CreateTreeElement(KeyName)
	local DataBase = _DataBase[KeyName]
	local Cache = _Cache[KeyName]

	local TreeElement
	
	TreeElement = {
		order = DataBase.Config.Order,
		type = "group",
		name = DataBase.Config.Name,
		childGroups = "tab",	
		args = {
			CombatOptions = {
				order = 1,
				type = "group",
				name = "Combat Fade Options",
				args = {
					AlphaOptions = {
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
										if KeyName ~= "Default_Tab" then
											return Cache.Combat.Alpha.In
										else
											return DataBase.Combat.Alpha.In
										end
									end,
								set = 
									function(info, value)
										DataBase.Combat.Alpha.In = value
				
										_Cache:CombatAnimTab(KeyName)
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
										if KeyName ~= "Default_Tab" then
											return Cache.Combat.Alpha.Out
										else
											return DataBase.Combat.Alpha.Out
										end
										
									end,
								set = 
									function(info, value)
										DataBase.Combat.Alpha.Out = value

										_Cache:CombatAnimTab(KeyName)
									end,
							},
						},
					},
					DurationOptions = {
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
										if KeyName ~= "Default_Tab" then
											return Cache.Combat.Duration.In
										else
											return DataBase.Combat.Duration.In
										end
									end,
								set = 
									function(info, value)
										DataBase.Combat.Duration.In = value

										_Cache:CombatAnimTab(KeyName)
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
										if KeyName ~= "Default_Tab" then
											return Cache.Combat.Duration.Out
										else
											return DataBase.Combat.Duration.Out
										end
									end,
								set = 
									function(info, value)
										DataBase.Combat.Duration.Out = value

										_Cache:CombatAnimTab(KeyName)
									end,
							},									
						},
					},
					SmoothingOptions = {
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
										if KeyName ~= "Default_Tab" then
											return Cache.Combat.Smoothing.In
										else
											return DataBase.Combat.Smoothing.In
										end
									end,
								set = 
									function(info, value)
										DataBase.Combat.Smoothing.In = value

										_Cache:CombatAnimTab(KeyName)
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
										if KeyName ~= "Default_Tab" then
											return Cache.Combat.Smoothing.Out
										else
											return DataBase.Combat.Smoothing.Out
										end
									end,
								set = 
									function(info, value)
										DataBase.Combat.Smoothing.Out = value

										_Cache:CombatAnimTab(KeyName)
									end,
							},
						},
					},
					MouseOptions = {
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
										if KeyName ~= "Default_Tab" then
											return Cache.Combat.Mouse.Enabled
										else
											return DataBase.Combat.Mouse.Enabled
										end
									end,
								set = 
									function(info, value)
										DataBase.Combat.Mouse.Enabled = value
										UpdateState(KeyName)	-- We changed a toggle, call our Update function
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
									if KeyName ~= "Default_Tab" then
										return Cache.Combat.Mouse.Duration.On
									else
										return DataBase.Combat.Mouse.Duration.On
									end									
								end,
								set = function(info, value)
									DataBase.Combat.Mouse.Duration.On = value

									_Cache:CombatAnimTab(KeyName)
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
									if KeyName ~= "Default_Tab" then
										return Cache.Combat.Mouse.Duration.Off
									else
										return DataBase.Combat.Mouse.Duration.Off
									end
								end,
								set = function(info, value)
									DataBase.Combat.Mouse.Duration.Off = value

									_Cache:CombatAnimTab(KeyName)
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
									if KeyName ~= "Default_Tab" then
										return Cache.Combat.Mouse.Alpha
									else
										return DataBase.Combat.Mouse.Alpha
									end
								end,
								set = function(info, value)
									DataBase.Combat.Mouse.Alpha = value

									_Cache:CombatAnimTab(KeyName)
								end,
							},
						},
					}
				},
			},
					
			AnimationOptions = {
				order = 2,
				type = "group",
				name = "Animation Options",	
				args = {
					GeneralOptions = {
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
										if KeyName ~= "Default_Tab" then
											return Cache.Animation.DefaultDuration.Delay.Start
										else
											return DataBase.Animation.DefaultDuration.Delay.Start
										end										
									end,
								set = 
									function(info, value)
										DataBase.Animation.DefaultDuration.Delay.Start = value

										_Cache:AnimTab(KeyName)											
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
										if KeyName ~= "Default_Tab" then
											return Cache.Animation.DefaultDuration.Delay.End
										else
											return DataBase.Animation.DefaultDuration.Delay.End
										end										
									end,
								set = 
									function(info, value)
										DataBase.Animation.DefaultDuration.Delay.End = value
										
										_Cache:AnimTab(KeyName)
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
										if KeyName ~= "Default_Tab" then
											return Cache.Animation.DefaultDuration.Time
										else
											return DataBase.Animation.DefaultDuration.Time
										end										
									end,
								set = 
									function(info, value)
										DataBase.Animation.DefaultDuration.Time = value
								
										_Cache:AnimTab(KeyName)
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
		},
	}

	for k, v in pairs(DataBase.Animation) do
		if string.find(k, "_Tab") then
			TreeElement.args.AnimationOptions.args[k] = CreateAnimationPage(KeyName, k)
		end
	end
				
	if KeyName == "Default_Tab" then
		TreeElement.args.AnimationOptions.args.TestAll = {
			order = 1,
			type = "execute",
			name = "Test All!",
			desc = "Test all the animations at the same time",
			func = 
				function()
					_Core:Animate()
				end,
		}
		TreeElement.args.TabConfig = {
			order = -1,
			type = "group",
			name = "Configure",
			childGroups = "select",
			args = { },
		}
	else
		TreeElement.args[KeyName.."Config"] = CreateConfigTab(KeyName)

		TreeElement.args.CombatOptions.args.Enabled = {
			order = 1,
			type = "toggle",
			name = "Enabled",
			desc = "Whether or not to fade the frame based on combat flags",
			get = 
				function(info)
					return DataBase.Combat.Enabled
				end,
			set = 
				function(info, value)
					DataBase.Combat.Enabled = value
					print(DataBase.Combat.Enabled)
					UpdateState(KeyName)	-- We changed a toggle, call our Update function
				end,
		}
		TreeElement.args.CombatOptions.args.UseDefaults = {
			order = 2,
			type = "toggle",
			name = "Use Defaults",
			desc = "Whether or not to use the default values or set up individual values for this frame",
			get = 
				function(info)
					return DataBase.Combat.UseDefaults
				end,
			set = 
				function(info, value)
					DataBase.Combat.UseDefaults = value
					UpdateState(KeyName)	-- We changed a toggle, call our Update function
				end,
		}
		TreeElement.args.AnimationOptions.args.Enabled = {
			order = 1,
			type = "toggle",
			name = "Enabled",
			desc = "Whether or not to animate this Frame",
			get = 
				function(info)
					return DataBase.Animation.Enabled
				end,
			set = 
				function(info, value)
					DataBase.Animation.Enabled = value
					UpdateState(KeyName)	-- We changed a toggle, call our Update function
				end,
		}
		TreeElement.args.AnimationOptions.args.TestAll = {
			order = 2,
			type = "execute",
			name = "Test All!",
			desc = "Test all the animations at the same time",
			func = 
				function()
					_Core:Animate(KeyName)
				end,
		}
		TreeElement.args.AnimationOptions.args.GeneralOptions.args.UseDefaults = {
			order = 1,
			type = "toggle",
			name = "Use Defaults",
			desc = "Whether or not to use the default values or set up individual values for this frame",
			get = 
				function(info)
					return DataBase.Animation.UseDefaults
				end,
			set = 
				function(info, value)
					DataBase.Animation.UseDefaults = value
					UpdateState(KeyName)	-- We changed a toggle, call our Update function
				end,
		}
	end

	return TreeElement
end

-- This function inserts our GUI table into the ElvUI Config. You can read about AceConfig here: http://www.wowace.com/addons/ace3/pages/ace-config-3-0-options-tables/
function _ElvUI_Animations:InsertOptions()
	E.Options.args.ElvUI_Animations = {
		order = 100,
		type = "group",
		name = "|cff00b3ffAnimations|r",
		args = { },
	}

	_DataBase = E.db.ElvUI_Animations
	_Options = E.Options.args.ElvUI_Animations.args

	_Options.Animate = {
		order = 1,
		type = "toggle",
		name = "Enable Animations",
		desc = "Whether or not to animate the frames after a load screen",
		get = function(info)
			return _DataBase.Animate
		end,
		set = function(info, value)
			_DataBase.Animate = value
			for k, v in pairs(_DataBase) do
				if string.find(k, "_Tab") then
					UpdateState(k)
				end
			end
		end,
	}
	_Options.Combat = {
		order = 2,
		type = "toggle",
		name = "Enable Combat Fade",
		desc = "Whether or not to fade based on combat flags options",
		get = function(info)
			return _DataBase.Combat
		end,
		set = function(info, value)
			_DataBase.Combat = value
			for k, v in pairs(_DataBase) do
				if string.find(k, "_Tab") then
					UpdateState(k)
				end
			end
		end,
	}
	_Options.Lagging = {
		order = 3,
		type = "toggle",
		name = "After Load Lag",
		desc = "\"Halp! I'm lagging after loading when it's playing the load animation!\"\n\nTry DIS-abling this toggle to speed up the after load animation. It may cause a graphical error though :(",
		get = function(info)
			return _DataBase.Lag
		end,
		set = function(info, value)
			_DataBase.Lag = value
		end,
	}
	_Options.AFKAnimation = {
		order = 4,
		type = "toggle",
		name = "Enable After AFK Animation",
		desc = "Allow the after load animations to also play when returning from AFK",
		get = function(info)
			return E.db.ElvUI_Animations.AFK
		end,
		set = function(info, value)
			_DataBase.AFK = value
		end,
	}
	_Options.RestoreDefaults = {
		order = 5,
		type = "execute",
		name = "Restore Defaults",
		desc = "Restore all values back to default, but just for this add-on not ElvUI don't worry!",
		func = function()
			E:StaticPopup_Show("RestoreDefaults")
		end,
	}
	_Options.Header1 = 
	{
		order = 9,
		type = "header",
		name = "",
	}
	_Options.NewTab = {
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
				_DataBase.CurrentTabs = _DataBase.CurrentTabs + 1
				_DataBase["Custom_Tab".._DataBase.CurrentTabs] = _System:Copy(_AddonTable._Defaults.Tab.Default)

				_DataBase["Custom_Tab".._DataBase.CurrentTabs].Config = {
					Order = _DataBase.CurrentTabs,			-- The name of the key in the table. ex: E.Options.args.ElvUI_Animations.args[%THIS_VALUE_HERE%]
					Frame = { "Enter Frames Here",			-- The name of the frames affected by this tabs settings
						Fade = { }, 
					},									
					Name = value,							-- The name displayed to the user for this tab
					Error = { 
						Fade = {  }, 
					},								
				}
				
				_Options["Custom_Tab".._DataBase.CurrentTabs] = CreateTreeElement("Custom_Tab".._DataBase.CurrentTabs)
				_Options.TabSelection.values["Custom_Tab".._DataBase.CurrentTabs] = value
				--E:RefreshGUI()
			end,
	}
	_Options.Header2 = {
		order = 11,
		type = "header",
		name = "",
	}
	_Options.TabSelection = {
		order = 12,
		type = "select",
		name = "",
		values = { },
		get = 
			function(info)
				return _AddonTable._NotKept.TabToDelete
			end,
		set = 
			function(info, value)
				_AddonTable._NotKept.TabToDelete = value
			end,				
	}
	_Options.DeleteThis = {
		order = 13,
		type = "execute",
		name = "Delete Tab",
		desc = "Delete the selected Tab",
		func = 
			function()
				E.PopupDialogs.DeleteThis.text = "You are about to delete the ".._DataBase[_AddonTable._NotKept.TabToDelete].Config.Name.." tab!\nThis cannot be reversed. Are you sure?"
				E:StaticPopup_Show("DeleteThis")
			end,
	}
	
	for k, v in pairs(_DataBase) do
		if string.find(k, "_Tab") then 
			if k ~= "Default_Tab" then
				_Options.TabSelection.values[k] = _DataBase[k].Config.Name
			end
			_Options[k] = CreateTreeElement(k)
			
			UpdateMoveButtonState(k)
			UpdateState(k)
		end
	end

	for k, v in pairs(_DataBase) do
		if k ~= "Default_Tab" and string.find(k, "_Tab") then
			_Options['Default_Tab'].args.TabConfig.args[k.."Config"] = _Options[k].args[k.."Config"]
		end
	end				

	-- Setup Restore Defaults confirmation popup
	E.PopupDialogs.RestoreDefaults = {
		text = "You are about to set ALL values back to default.\n This cannot be reversed. Are you sure?",
		button1 = "Yes",
		button2 = "No",
		OnAccept = 
			function() 
				E:CopyTable(E.db.ElvUI_Animations, P.ElvUI_Animations)

				_Cache:AnimTab()

				E:RefreshGUI()
			end,
		timeout = 0,
		whileDead = 1,
		preferredIndex = 3,
	}
	E.PopupDialogs.DeleteThis = {
		text = "",
		button1 = "Yes",
		button2 = "No",
		OnAccept = 
			function() 
				local DeleteThis = _System:Copy(_DataBase[_AddonTable._NotKept.TabToDelete].Config.Order)

				_Options[_AddonTable._NotKept.TabToDelete] = nil
				_DataBase[_AddonTable._NotKept.TabToDelete] = nil

				_Options.TabSelection.values[_AddonTable._NotKept.TabToDelete] = nil

				for k, v in pairs(_DataBase) do
					if string.find(k, "_Tab") then
						local Config = _DataBase[k].Config

						if Config.Order > DeleteThis then
							Config.Order = Config.Order - 1
							_Options[k].order = Config.Order
						end
					end
				end
				E:RefreshGUI()
			end,
		timeout = 0,
		whileDead = 1,
		preferredIndex = 3,
	}
end

function _AddonTable._Config:Initialize()
	_DataBase = E.db.ElvUI_Animations
	
	_Core = _AddonTable._Core 

	_Animations = _AddonTable._NotKept.Animations
	_CombatAnimations = _AddonTable._NotKept.CombatAnimations
end

function _ElvUI_Animations:Initialize()
	-- Register plug-in so options are properly inserted when config is loaded
	_EP:RegisterPlugin(_AddonName, _ElvUI_Animations.InsertOptions)
end

_AddonTable._Config.Init = _AddonTable._Config.Initialize
---------------------------------------------------------------------------------------------------------------------------------------
-- End of Config.lua
---------------------------------------------------------------------------------------------------------------------------------------