local Quartz3 = LibStub("AceAddon-3.0"):GetAddon("Quartz3")
local MODNAME = "Rank"
local QuartzRank = Quartz3:NewModule(MODNAME, "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Quartz3")

local getOptions, oldCastBarFunc, oldSpellcastFunc, oldSpellcastChannelFunc, castingSpellID, db

local defaults = {
	profile = {
		ranktextposition = "right",
		ranktext = LEVEL_ABBR .. " ",
	}
}

local function ReplaceRank(rankString, subText)
	rankString = string.gsub(rankString, "%%d", "(%%%d%%%d?)")
	if subText then
		local result = string.match(subText, rankString)
		if result then
			return result
		end
	end

	return nil
end

local function GetTextSpellRank(spellID)
	local subText = GetSpellSubtext(spellID)
	local rankString

	if subText then
		if CASTING_TRANSLATIONS and CASTING_TRANSLATIONS[GetLocale()] then
			rankString = ReplaceRank(CASTING_TRANSLATIONS[GetLocale()], subText)
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

local function SetNameText(self, name)
	local rank

	if self.unit == "player" then
		if (castingSpellID) then
			rank = GetTextSpellRank(castingSpellID)
			if rank then
				local rankText = LEVEL_ABBR .. " "
				if (db["ranktext"]) then
					rankText = db["ranktext"]
				end
				rank = rankText .. rank
			else
				rank = GetSpellSubtext(castingSpellID)
			end
		else
			rank = GetSpellSubtext(name)
		end
	end

	if self.config.targetname and self.targetName and self.targetName ~= "" then
		if rank == nil or rank == '' then
			self.Text:SetFormattedText("%s -> %s", name, self.targetName)
		else
			if db["ranktextposition"] == "left" then
				self.Text:SetFormattedText("(%s) %s -> %s", rank, name, self.targetName)
			else
				self.Text:SetFormattedText("%s (%s) -> %s", name, rank, self.targetName)
			end
		end
	else
		if rank == nil or rank == '' then
			self.Text:SetText(name)
		else
			if db["ranktextposition"] == "left" then
				self.Text:SetFormattedText("(%s) %s", rank, name)
			else
				self.Text:SetFormattedText("%s (%s)", name, rank)
			end
		end
	end
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
