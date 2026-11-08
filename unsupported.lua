-- Loaded alone by the fallback TOC on clients without spell ranks, so it carries its own strings.
local messages = {
	deDE = "Quartz-Zauberränge werden in dieser WoW-Version nicht unterstützt",
	esES = "Los rangos de hechizos de Quartz no son compatibles con esta versión de WoW",
	esMX = "Los rangos de hechizos de Quartz no son compatibles con esta versión de WoW",
	frFR = "Les rangs de sorts de Quartz ne sont pas pris en charge sur cette version de WoW",
	itIT = "I gradi degli incantesimi di Quartz non sono supportati in questa versione di WoW",
	koKR = "현재 WoW 버전에서는 Quartz 주문 등급이 지원되지 않습니다",
	ptBR = "Os graus de feitiço do Quartz não são compatíveis com esta versão do WoW",
	ruRU = "Уровни заклинаний Quartz не поддерживаются в текущей версии WoW",
	zhCN = "当前魔兽世界版本不支持 Quartz 法术等级",
	zhTW = "目前的魔獸世界版本不支援 Quartz 法術等級",
}

local message = messages[GetLocale()] or "Quartz spell ranks are not supported on current WoW version"
DEFAULT_CHAT_FRAME:AddMessage("|cffff0000" .. (ERROR_CAPS or "ERROR") .. "|r: |cff42f5ad" .. message .. "|r")
