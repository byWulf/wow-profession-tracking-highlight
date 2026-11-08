local _, ns = ...

-- English is the base; every other locale only overrides what it translates.
-- Spell names (Find Herbs, Find Minerals, ...) come from the game client, so they always match your language.
local L = {
    TITLE = "Profession Tracking Highlight",

    OPT_HEADER_TRACKING = "Tracking",
    OPT_OTHER = "Also mark other tracking",
    -- %s: three example trackings
    OPT_OTHER_TIP = "Also marks class and racial tracking abilities while they're active, e.g. %s, %s or %s.",
    OPT_HEADER_LOOK = "Look",
    OPT_THICKNESS = "Border thickness",
    OPT_THICKNESS_TIP = "Thickness of the border around the button of the active tracking.",
    OPT_GLOW = "Glow",
    OPT_GLOW_TIP = "Lets the button of the active tracking glow in addition to the border.",
    -- %s: name of the tracking spell
    OPT_COLOR = "Color: %s",
    OPT_COLOR_TIP = "Border and glow while %s is active.",
    OPT_COLOR_OTHER = "Color: other tracking",
    OPT_COLOR_OTHER_TIP = "Border and glow of class and racial tracking (see \"Also mark other tracking\").",
}

local locales = {}

locales.deDE = {
    OPT_HEADER_TRACKING = "Aufspüren",
    OPT_OTHER = "Auch anderes Aufspüren markieren",
    OPT_OTHER_TIP = "Markiert auch Aufspür-Fähigkeiten von Klasse und Volk, solange sie aktiv sind, z. B. %s, %s oder %s.",
    OPT_HEADER_LOOK = "Aussehen",
    OPT_THICKNESS = "Rahmendicke",
    OPT_THICKNESS_TIP = "Dicke des Rahmens um den Button des aktiven Aufspürens.",
    OPT_GLOW = "Leuchten",
    OPT_GLOW_TIP = "Lässt den Button des aktiven Aufspürens zusätzlich zum Rahmen leuchten.",
    OPT_COLOR = "Farbe: %s",
    OPT_COLOR_TIP = "Rahmen und Leuchten, solange %s aktiv ist.",
    OPT_COLOR_OTHER = "Farbe: anderes Aufspüren",
    OPT_COLOR_OTHER_TIP = "Rahmen und Leuchten für Aufspür-Fähigkeiten von Klasse und Volk (siehe „Auch anderes Aufspüren markieren“).",
}

locales.frFR = {
    OPT_HEADER_TRACKING = "Pistage",
    OPT_OTHER = "Marquer aussi les autres pistages",
    OPT_OTHER_TIP = "Marque aussi les techniques de pistage de classe et de race tant qu'elles sont actives, par ex. %s, %s ou %s.",
    OPT_HEADER_LOOK = "Apparence",
    OPT_THICKNESS = "Épaisseur de la bordure",
    OPT_THICKNESS_TIP = "Épaisseur de la bordure autour du bouton du pistage actif.",
    OPT_GLOW = "Lueur",
    OPT_GLOW_TIP = "Fait briller le bouton du pistage actif en plus de la bordure.",
    OPT_COLOR = "Couleur : %s",
    OPT_COLOR_TIP = "Bordure et lueur tant que %s est actif.",
    OPT_COLOR_OTHER = "Couleur : autres pistages",
    OPT_COLOR_OTHER_TIP = "Bordure et lueur des pistages de classe et de race (voir « Marquer aussi les autres pistages »).",
}

locales.esES = {
    OPT_HEADER_TRACKING = "Rastreo",
    OPT_OTHER = "Marcar también otros rastreos",
    OPT_OTHER_TIP = "Marca también las habilidades de rastreo de clase y raza mientras están activas, p. ej. %s, %s o %s.",
    OPT_HEADER_LOOK = "Aspecto",
    OPT_THICKNESS = "Grosor del borde",
    OPT_THICKNESS_TIP = "Grosor del borde alrededor del botón del rastreo activo.",
    OPT_GLOW = "Brillo",
    OPT_GLOW_TIP = "Hace brillar el botón del rastreo activo además del borde.",
    OPT_COLOR = "Color: %s",
    OPT_COLOR_TIP = "Borde y brillo mientras %s está activo.",
    OPT_COLOR_OTHER = "Color: otros rastreos",
    OPT_COLOR_OTHER_TIP = "Borde y brillo de los rastreos de clase y raza (ver «Marcar también otros rastreos»).",
}

-- Latin American Spanish: same texts as esES.
locales.esMX = locales.esES

locales.ptBR = {
    OPT_HEADER_TRACKING = "Rastreamento",
    OPT_OTHER = "Marcar também outros rastreamentos",
    OPT_OTHER_TIP = "Marca também as habilidades de rastreamento de classe e raça enquanto estão ativas, p. ex. %s, %s ou %s.",
    OPT_HEADER_LOOK = "Aparência",
    OPT_THICKNESS = "Espessura da borda",
    OPT_THICKNESS_TIP = "Espessura da borda ao redor do botão do rastreamento ativo.",
    OPT_GLOW = "Brilho",
    OPT_GLOW_TIP = "Faz o botão do rastreamento ativo brilhar, além da borda.",
    OPT_COLOR = "Cor: %s",
    OPT_COLOR_TIP = "Borda e brilho enquanto %s estiver ativo.",
    OPT_COLOR_OTHER = "Cor: outros rastreamentos",
    OPT_COLOR_OTHER_TIP = "Borda e brilho dos rastreamentos de classe e raça (veja \"Marcar também outros rastreamentos\").",
}

locales.ruRU = {
    OPT_HEADER_TRACKING = "Выслеживание",
    OPT_OTHER = "Отмечать и другое выслеживание",
    OPT_OTHER_TIP = "Также отмечает способности выслеживания класса и расы, пока они активны, например: %s, %s или %s.",
    OPT_HEADER_LOOK = "Внешний вид",
    OPT_THICKNESS = "Толщина рамки",
    OPT_THICKNESS_TIP = "Толщина рамки вокруг кнопки активного выслеживания.",
    OPT_GLOW = "Свечение",
    OPT_GLOW_TIP = "Кнопка активного выслеживания светится в дополнение к рамке.",
    OPT_COLOR = "Цвет: %s",
    OPT_COLOR_TIP = "Рамка и свечение, пока активно «%s».",
    OPT_COLOR_OTHER = "Цвет: другое выслеживание",
    OPT_COLOR_OTHER_TIP = "Рамка и свечение для выслеживания класса и расы (см. «Отмечать и другое выслеживание»).",
}

locales.koKR = {
    OPT_HEADER_TRACKING = "추적",
    OPT_OTHER = "다른 추적도 표시",
    OPT_OTHER_TIP = "직업 및 종족 추적 능력도 활성화되어 있는 동안 표시합니다. 예: %s, %s, %s.",
    OPT_HEADER_LOOK = "모양",
    OPT_THICKNESS = "테두리 두께",
    OPT_THICKNESS_TIP = "활성화된 추적 버튼 주위 테두리의 두께입니다.",
    OPT_GLOW = "빛나기",
    OPT_GLOW_TIP = "테두리와 함께 활성화된 추적의 버튼이 빛납니다.",
    OPT_COLOR = "색상: %s",
    OPT_COLOR_TIP = "%s 활성화 중일 때의 테두리와 빛입니다.",
    OPT_COLOR_OTHER = "색상: 다른 추적",
    OPT_COLOR_OTHER_TIP = "직업 및 종족 추적의 테두리와 빛입니다 (\"다른 추적도 표시\" 참조).",
}

locales.zhCN = {
    OPT_HEADER_TRACKING = "追踪",
    OPT_OTHER = "同时标记其他追踪",
    OPT_OTHER_TIP = "职业和种族的追踪技能在激活时也会被标记，例如%s、%s或%s。",
    OPT_HEADER_LOOK = "外观",
    OPT_THICKNESS = "边框粗细",
    OPT_THICKNESS_TIP = "当前追踪按钮周围边框的粗细。",
    OPT_GLOW = "发光",
    OPT_GLOW_TIP = "除边框外，让当前追踪的按钮发光。",
    OPT_COLOR = "颜色：%s",
    OPT_COLOR_TIP = "%s激活时的边框和光效。",
    OPT_COLOR_OTHER = "颜色：其他追踪",
    OPT_COLOR_OTHER_TIP = "职业和种族追踪的边框和光效（见“同时标记其他追踪”）。",
}

locales.zhTW = {
    OPT_HEADER_TRACKING = "追蹤",
    OPT_OTHER = "同時標示其他追蹤",
    OPT_OTHER_TIP = "職業和種族的追蹤技能啟用時也會被標示，例如%s、%s或%s。",
    OPT_HEADER_LOOK = "外觀",
    OPT_THICKNESS = "邊框粗細",
    OPT_THICKNESS_TIP = "目前追蹤按鈕周圍邊框的粗細。",
    OPT_GLOW = "發光",
    OPT_GLOW_TIP = "除了邊框外，讓目前追蹤的按鈕發光。",
    OPT_COLOR = "顏色：%s",
    OPT_COLOR_TIP = "%s啟用時的邊框和光效。",
    OPT_COLOR_OTHER = "顏色：其他追蹤",
    OPT_COLOR_OTHER_TIP = "職業和種族追蹤的邊框和光效（見「同時標示其他追蹤」）。",
}

local override = locales[GetLocale()]
if override then
    for key, value in pairs(override) do
        L[key] = value
    end
end

ns.L = L
