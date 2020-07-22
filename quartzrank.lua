local MAJOR_VERS = 1
local MINOR_VERS = 0
local vers = tostring(MAJOR_VERS) .. "." .. tostring(MINOR_VERS)


local Quartz3 = LibStub("AceAddon-3.0"):GetAddon("Quartz3")
local MODNAME = "Rank"
local QuartzRank = Quartz3:NewModule(MODNAME, "AceEvent-3.0")
local Player = Quartz3:GetModule("Player")
local L = LibStub("AceLocale-3.0"):GetLocale("Quartz3")

local getOptions, oldCastBarFunc

local function SetNameText(self, name)
	local rank 

	if self.unit == "player" then
		rank = GetSpellSubtext(spell)
	end

	if self.config.targetname and self.targetName and self.targetName ~= "" then
		if rank then
			self.Text:SetFormattedText("%s (%s) -> %s", name, rank, self.targetName)
		else
			self.Text:SetFormattedText("%s -> %s", name, self.targetName)
		end
	else
		if rank then
			self.Text:SetFormattedText("%s (%s)", name, rank)
		else
			self.Text:SetText(name)
		end
	end
end


function QuartzRank:OnInitialize()
	self:SetEnabledState(Quartz3:GetModuleEnabled(MODNAME))
	Quartz3:RegisterModuleOptions(MODNAME, getOptions, "Rank")
end

function QuartzRank:OnEnable()
	oldCastBarFunc = Quartz3.CastBarTemplate.template.SetNameText
	Quartz3.CastBarTemplate.template.SetNameText = SetNameText
end

function QuartzRank:OnDisable()
	Quartz3.CastBarTemplate.template.SetNameText = oldCastBarFunc
end

do
	local options
	function getOptions()
		if not options then
			options = {
				type = "group",
				name = "Rank",
				order = 600,
				args = {
					toggle = {
						type = "toggle",
						name = L["Enable"],
						desc = L["Enable"],
						get = function()
							return Quartz3:GetModuleEnabled(MODNAME)
						end,
						set = function(info, v)
							Quartz3:SetModuleEnabled(MODNAME, v)
						end,
					},
				},
			}
		end
		return options
	end
end
