local _, ns = ...

-- Options panel strings. Keys are the English text; missing keys fall back to English.
-- "Enable", "Left" and "Right" come from Quartz's own locale and are not listed here.
local translations = {
	deDE = {
		["Rank"] = "Rang",
		["Text Config"] = "Texteinstellungen",
		["Rank Text Position"] = "Position des Rangtexts",
		["Rank Text"] = "Rangtext",
	},
	esES = {
		["Rank"] = "Rango",
		["Text Config"] = "Configuración del texto",
		["Rank Text Position"] = "Posición del texto de rango",
		["Rank Text"] = "Texto de rango",
	},
	frFR = {
		["Rank"] = "Rang",
		["Text Config"] = "Configuration du texte",
		["Rank Text Position"] = "Position du texte de rang",
		["Rank Text"] = "Texte de rang",
	},
	itIT = {
		["Rank"] = "Grado",
		["Text Config"] = "Configurazione testo",
		["Rank Text Position"] = "Posizione del testo del grado",
		["Rank Text"] = "Testo del grado",
	},
	koKR = {
		["Rank"] = "등급",
		["Text Config"] = "텍스트 설정",
		["Rank Text Position"] = "등급 텍스트 위치",
		["Rank Text"] = "등급 텍스트",
	},
	ptBR = {
		["Rank"] = "Grau",
		["Text Config"] = "Configuração do texto",
		["Rank Text Position"] = "Posição do texto de grau",
		["Rank Text"] = "Texto de grau",
	},
	ruRU = {
		["Rank"] = "Уровень",
		["Text Config"] = "Настройки текста",
		["Rank Text Position"] = "Положение текста уровня",
		["Rank Text"] = "Текст уровня",
	},
	zhCN = {
		["Rank"] = "等级",
		["Text Config"] = "文本设置",
		["Rank Text Position"] = "等级文本位置",
		["Rank Text"] = "等级文本",
	},
	zhTW = {
		["Rank"] = "等級",
		["Text Config"] = "文字設定",
		["Rank Text Position"] = "等級文字位置",
		["Rank Text"] = "等級文字",
	},
}
translations.esMX = translations.esES

ns.L = setmetatable(translations[GetLocale()] or {}, {
	__index = function(_, key)
		return key
	end,
})
