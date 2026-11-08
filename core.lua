local _, ns = ...

local Quartz3 = LibStub("AceAddon-3.0"):GetAddon("Quartz3")
local MODNAME = "Rank"
local QuartzRank = Quartz3:NewModule(MODNAME, "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Quartz3")

-- Classic clients expose the global; the modern client used by Forever may only provide C_Spell
local GetSpellSubtext = GetSpellSubtext or (C_Spell and C_Spell.GetSpellSubtext) or function() return nil end

-- Quartz Redux (Midnight / Forever client) can hand us "secret" values that addon code
-- must not compare or concatenate. issecretvalue does not exist on Classic clients.
local function IsSecret(value)
	return issecretvalue ~= nil and issecretvalue(value)
end

local getOptions, oldCastBarFunc, oldSpellcastFunc, oldSpellcastChannelFunc, castingSpellID, db

local defaults = {
	profile = {
		ranktextposition = "right",
		ranktext = LEVEL_ABBR .. " ",
	}
}

-- Turns a localized format such as "Rank %d" or "%d-й уровень" into a Lua pattern that
-- captures the number. Pattern magic characters in the format are escaped first.
local function ReplaceRank(rankFormat, subText)
	if type(rankFormat) ~= "string" then
		return nil
	end

	local pattern = string.gsub(rankFormat, "[%^%$%(%)%.%[%]%*%+%-%?]", "%%%0")
	pattern = string.gsub(pattern, "%%d", "(%%d+)")

	return string.match(subText, pattern)
end

local function GetTextSpellRank(spellID)
	local subText = GetSpellSubtext(spellID)
	local rankString

	if subText and not IsSecret(subText) then
		local translation = ns.CASTING_TRANSLATIONS and ns.CASTING_TRANSLATIONS[GetLocale()]
		if translation then
			rankString = ReplaceRank(translation, subText)
		else
			rankString = ReplaceRank(TRADESKILL_RANK_HEADER, subText)
		end

		if (rankString) then
			return rankString
		end

		rankString = ReplaceRank(FLOOR_NUMBER, subText)

		if (rankString) then
			return rankString
		end
	end

	return nil
end

local function GetDisplayRank(name)
	local rank

	if castingSpellID and not IsSecret(castingSpellID) then
		rank = GetTextSpellRank(castingSpellID)
		if rank then
			return (db["ranktext"] or (LEVEL_ABBR .. " ")) .. rank
		end
		rank = GetSpellSubtext(castingSpellID)
	else
		rank = GetSpellSubtext(name)
	end

	if IsSecret(rank) or rank == nil or rank == "" then
		return nil
	end

	return rank
end

-- Decorates the spell name and delegates to Quartz's own SetNameText, so target-name
-- formatting (and Quartz Redux's secret-value handling) stays owned by Quartz.
local function SetNameText(self, name)
	if self.unit == "player" and name and not IsSecret(name) then
		local rank = GetDisplayRank(name)
		if rank then
			if db["ranktextposition"] == "left" then
				name = string.format("(%s) %s", rank, name)
			else
				name = string.format("%s (%s)", name, rank)
			end
		end
	end

	oldCastBarFunc(self, name)
end


function QuartzRank:OnInitialize()
	db = Quartz3.db:RegisterNamespace(MODNAME, defaults).profile

	self:SetEnabledState(Quartz3:GetModuleEnabled(MODNAME))
	Quartz3:RegisterModuleOptions(MODNAME, getOptions, "Rank")
end

local function UNIT_SPELLCAST_START_HOOK(self, event, unit, guid, spellID)
	castingSpellID = spellID
	oldSpellcastFunc(self, event, unit, guid, spellID)
end

local function UNIT_SPELLCAST_CHANNEL_START_HOOK(self, event, unit, guid, spellID)
	castingSpellID = spellID
	oldSpellcastChannelFunc(self, event, unit, guid, spellID)
end

function QuartzRank:OnEnable()
	oldCastBarFunc = Quartz3.CastBarTemplate.template.SetNameText
	Quartz3.CastBarTemplate.template.SetNameText = SetNameText

	oldSpellcastFunc = Quartz3.CastBarTemplate.template.UNIT_SPELLCAST_START
	Quartz3.CastBarTemplate.template.UNIT_SPELLCAST_START = UNIT_SPELLCAST_START_HOOK

	oldSpellcastChannelFunc = Quartz3.CastBarTemplate.template.UNIT_SPELLCAST_CHANNEL_START
	Quartz3.CastBarTemplate.template.UNIT_SPELLCAST_CHANNEL_START = UNIT_SPELLCAST_CHANNEL_START_HOOK
end

function QuartzRank:OnDisable()
	Quartz3.CastBarTemplate.template.SetNameText = oldCastBarFunc
	Quartz3.CastBarTemplate.template.UNIT_SPELLCAST_START = oldSpellcastFunc
	Quartz3.CastBarTemplate.template.UNIT_SPELLCAST_CHANNEL_START = oldSpellcastChannelFunc
end

do
	local options
	function getOptions()
		local function getOptRank(info)
			return db[info.arg or ("rank"..info[#info])]
		end

		local function setOptRank(info, value)
			db[info.arg or ("rank"..info[#info])] = value
		end

		if not options then
			options = {
				type = "group",
				name = "Rank",
				order = 200,
				args = {
					toggle = {
						type = "toggle",
						name = L["Enable"],
						desc = L["Enable"],
						get = function()
							return Quartz3:GetModuleEnabled(MODNAME)
						end,
						set = function(_, v)
							Quartz3:SetModuleEnabled(MODNAME, v)
						end,
					},
					text = {
						type = "group",
						name = "Text Config",
						order = 101,
						get = getOptRank,
						set = setOptRank,
						args = {
							textposition = {
								type = "select",
								name = "Rank Text Position",
								values = {["left"] = L["Left"], ["right"] = L["Right"]},
								order = 99
							},
							nlf = {
								type = "description",
								name = "",
								order = 100,
							},
							text = {
								type = "input",
								name = "Rank Text",
								order = 101
							},
						}
					}
				},
			}
		end
		return options
	end
end
