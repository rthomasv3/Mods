local re = re
local sdk = sdk
local imgui = imgui
local log = log
local json = json
local Vector2f = Vector2f

local zh_CN_FONT_NAME = 'NotoSansSC-Regular.otf'
local zh_TW_FONT_NAME = 'NotoSansJP-Regular.otf'

local zh_HANT_FONT_SIZE = 18

local CJK_GLYPH_RANGES = {
    0x0020, 0x00FF, -- Basic Latin + Latin Supplement
    0x2000, 0x206F, -- General Punctuation
    0x3000, 0x30FF, -- CJK Symbols and Punctuations, Hiragana, Katakana
    0x31F0, 0x31FF, -- Katakana Phonetic Extensions
    0xFF00, 0xFFEF, -- Half-width characters
    0x4e00, 0x9FAF, -- CJK Ideograms
    0
}

local font_zh_TW = imgui.load_font(zh_TW_FONT_NAME, zh_HANT_FONT_SIZE, CJK_GLYPH_RANGES)
local font_zh_CN = imgui.load_font(zh_CN_FONT_NAME, zh_HANT_FONT_SIZE, CJK_GLYPH_RANGES)

local Hotkeys = require("Hotkeys/Hotkeys")

local FerrystoneController = sdk.get_managed_singleton("app.FerrystoneFlowController")
-- local ItemManager = sdk.get_managed_singleton("app.ItemManager")
local CharacterManager = sdk.get_managed_singleton("app.CharacterManager")

local ConfigFilePath = "rthomasv3\\teleportation_config.json"

local ShowTeleportWindow = false
local SelectedLanguageIndex = 1
local SelectedLocationIndex = 1
local SelectedBonusLocationIndex = 1
local WindowInitialized = false
local WriteInfoLogs = false
local RequireTeleportWindowOpen = true
local PreventFerrystoneUsage = false
local Language = "EN"

local LocationNames = {}
local BonusLocationNames = {}
local lblTexts = {}
local NewLocationName = nil

-- local Languages = {"EN","zh_TW","zh_CN","JP","KR"}
local Languages = {"EN","zh_TW","zh_CN"}
--local langIndex = FindIndex(Languages, Language)

local TeleportLocations = {
    { name_EN = "Bakbattahl",           name_zh_TW = "巴克巴塔爾",    name_zh_CN = "巴克巴塔尔",     position = "-1370.932, 108.404, 386.952" },
    { name_EN = "Borderwatch Outpost",  name_zh_TW = "國境監視團營地", name_zh_CN = "国境监视团营地", position = "360.551, 202.090, -2523.438" },
    { name_EN = "Checkpoint Rest Town", name_zh_TW = "關口旅宿之鎮",  name_zh_CN = "关口旅宿之镇",    position = "-1925.309, 236.477, -917.067" },
    { name_EN = "Dragonforged",         name_zh_TW = "海灣神廟",      name_zh_CN = "海湾神庙",      position = "-1024.074, -0.826, -229.069" },
    { name_EN = "Eini's Home",          name_zh_TW = "艾妮的家",      name_zh_CN = "艾妮的家",      position = "161.006, 247.738, -2779.449" },
    { name_EN = "Excavation Site",      name_zh_TW = "挖掘場",       name_zh_CN = "挖掘场",        position = "319.194, 101.405, 1283.226" },
    { name_EN = "Harve Village",        name_zh_TW = "哈波村",       name_zh_CN = "哈波村",        position = "-403.743, 2.830, -719.719" },
    { name_EN = "Melve",                name_zh_TW = "梅爾威",       name_zh_CN = "梅尔威",        position = "140.602, 153.463, -2121.792" },
    { name_EN = "Nameless Village",     name_zh_TW = "無名村",       name_zh_CN = "无名村",        position = "1591.937, 35.921, -1371.444" },
    { name_EN = "Sacred Arbor",         name_zh_TW = "聖樹之村",      name_zh_CN = "圣树之村",      position = "-503.591, 125.331, -2196.583" },
    { name_EN = "Volcanic Island Camp", name_zh_TW = "火山島營地",    name_zh_CN = "火山岛营地",     position = "-258.599, 28.778, 1104.794" },
    { name_EN = "Vernworth",            name_zh_TW = "菲倫瓦思",      name_zh_CN = "菲伦瓦思",      position = "472.869, 27.787, -1043.214" },
}

local BonusLocations = {
    { name_EN = "Dragonsbreath Tower",            name_zh_TW = "食龍塔",         name_zh_CN = "食龙塔",        position = "-2139.95,254.651,1036.64" },
    { name_EN = "Frontier Shrine (Sphinx)",       name_zh_TW = "邊境神殿",       name_zh_CN = "边境庙",       position = "-2382.91,272.15,-678.725" },
    { name_EN = "Mountain Shrine (Sphinx)",       name_zh_TW = "山岳神殿",       name_zh_CN = "山神庙",       position = "-1242.96,193.368,-1654.86" },
    { name_EN = "Nera'Battahl Windrift (Medusa)", name_zh_TW = "雷拉巴塔爾風穴",  name_zh_CN = "雷拉巴塔尔风穴",  position = "-1980.15,74.0373,845.271" },
    { name_EN = "Windwalker's Home",              name_zh_TW = "清風之家",       name_zh_CN = "清风之家",       position = "-977.074,15.142,1121.04" },
    { name_EN = "Seeker's Token 1",               name_zh_TW = "探求之證 1",     name_zh_CN = "探求之证 1",     position = "1511.327, 72.29001, -1454.527" },
    { name_EN = "Seeker's Token 2",               name_zh_TW = "探求之證 2",     name_zh_CN = "探求之证 2",     position = "-1182.551, 83.09478, -972.6376" },
    { name_EN = "Seeker's Token 3",               name_zh_TW = "探求之證 3",     name_zh_CN = "探求之证 3",     position = "380.501, 50.62649, -1409.562" },
    { name_EN = "Seeker's Token 4",               name_zh_TW = "探求之證 4",     name_zh_CN = "探求之证 4",     position = "-1348.226, 124.496, -945.648" },
    { name_EN = "Seeker's Token 5",               name_zh_TW = "探求之證 5",     name_zh_CN = "探求之证 5",     position = "1444.965, 37.94048, -1504.567" },
    { name_EN = "Seeker's Token 6",               name_zh_TW = "探求之證 6",     name_zh_CN = "探求之证 6",     position = "-708.2896, 30.65974, 1312.785" },
    { name_EN = "Seeker's Token 7",               name_zh_TW = "探求之證 7",     name_zh_CN = "探求之证 7",     position = "-1836.352, 99.18828, -257.8879" },
    { name_EN = "Seeker's Token 8",               name_zh_TW = "探求之證 8",     name_zh_CN = "探求之证 8",     position = "-2323.327, 58.20417, 328.1359" },
    { name_EN = "Seeker's Token 9",               name_zh_TW = "探求之證 9",     name_zh_CN = "探求之证 9",     position = "-997.5818, 99.78221, -1169.883" },
    { name_EN = "Seeker's Token 10",              name_zh_TW = "探求之證 10",    name_zh_CN = "探求之证 10",    position = "-208.7119, 75.84951, -1270.892" },
    { name_EN = "Seeker's Token 11",              name_zh_TW = "探求之證 11",    name_zh_CN = "探求之证 11",    position = "-1877.725, 70.39024, 215.3207" },
    { name_EN = "Seeker's Token 12",              name_zh_TW = "探求之證 12",    name_zh_CN = "探求之证 12",    position = "1253.95, 93.48993, -1971.472" },
    { name_EN = "Seeker's Token 13",              name_zh_TW = "探求之證 13",    name_zh_CN = "探求之证 13",    position = "-151.6821, 54.35305, -1577.464" },
    { name_EN = "Seeker's Token 14",              name_zh_TW = "探求之證 14",    name_zh_CN = "探求之证 14",    position = "-421.618, 40.72049, -1217.373" },
    { name_EN = "Seeker's Token 15",              name_zh_TW = "探求之證 15",    name_zh_CN = "探求之证 15",    position = "-425.1481, 31.82341, -1511.35" },
    { name_EN = "Seeker's Token 16",              name_zh_TW = "探求之證 16",    name_zh_CN = "探求之证 16",    position = "-726.9548, 15.69018, -1057.383" },
    { name_EN = "Seeker's Token 17",              name_zh_TW = "探求之證 17",    name_zh_CN = "探求之证 17",    position = "-1844.405, 49.34726, 53.74813" },
    { name_EN = "Seeker's Token 18",              name_zh_TW = "探求之證 18",    name_zh_CN = "探求之证 18",    position = "-1175.155, 115.4653, -1422.364" },
    { name_EN = "Seeker's Token 19",              name_zh_TW = "探求之證 19",    name_zh_CN = "探求之证 19",    position = "-1425.139, 136.3351, 322.1707" },
    { name_EN = "Seeker's Token 20",              name_zh_TW = "探求之證 20",    name_zh_CN = "探求之证 20",    position = "-954.4528, 59.04977, -1495.011" },
    { name_EN = "Seeker's Token 21",              name_zh_TW = "探求之證 21",    name_zh_CN = "探求之证 21",    position = "-128.7886, 101.7482, -2144.956" },
    { name_EN = "Seeker's Token 22",              name_zh_TW = "探求之證 22",    name_zh_CN = "探求之证 22",    position = "-562.379, 105.0297, -1933.341" },
    { name_EN = "Seeker's Token 23",              name_zh_TW = "探求之證 23",    name_zh_CN = "探求之证 23",    position = "-1700.205, 220.8857, -1115.413" },
    { name_EN = "Seeker's Token 24",              name_zh_TW = "探求之證 24",    name_zh_CN = "探求之证 24",    position = "-1627.802, 162.3504, -1446.844" },
    { name_EN = "Seeker's Token 25",              name_zh_TW = "探求之證 25",    name_zh_CN = "探求之证 25",    position = "-114.8202, 30.86584, -1187.828" },
    { name_EN = "Seeker's Token 26",              name_zh_TW = "探求之證 26",    name_zh_CN = "探求之证 26",    position = "-1864.822, 82.608, 400.1776" },
    { name_EN = "Seeker's Token 27",              name_zh_TW = "探求之證 27",    name_zh_CN = "探求之证 27",    position = "-1754.728, 205.8057, -927.3947" },
    { name_EN = "Seeker's Token 28",              name_zh_TW = "探求之證 28",    name_zh_CN = "探求之证 28",    position = "-1388.847, 83.21184, 230.7781" },
    { name_EN = "Seeker's Token 29",              name_zh_TW = "探求之證 29",    name_zh_CN = "探求之证 29",    position = "-143.9213, 97.7899, -1969.956" },
    { name_EN = "Seeker's Token 30",              name_zh_TW = "探求之證 30",    name_zh_CN = "探求之证 30",    position = "333.059, 236.0416, -2672.068" },
    { name_EN = "Seeker's Token 31",              name_zh_TW = "探求之證 31",    name_zh_CN = "探求之证 31",    position = "-588.8615, 51.29575, -1191.052" },
    { name_EN = "Seeker's Token 32",              name_zh_TW = "探求之證 32",    name_zh_CN = "探求之证 32",    position = "-351.0987, 72.58118, -1797.945" },
    { name_EN = "Seeker's Token 33",              name_zh_TW = "探求之證 33",    name_zh_CN = "探求之证 33",    position = "-1969.172, 42.60961, 569.0708" },
    { name_EN = "Seeker's Token 34",              name_zh_TW = "探求之證 34",    name_zh_CN = "探求之证 34",    position = "-74.45094, 28.65137, -1228.852" },
    { name_EN = "Seeker's Token 35",              name_zh_TW = "探求之證 35",    name_zh_CN = "探求之证 35",    position = "-461.6025, 88.31136, 1461.9" },
    { name_EN = "Seeker's Token 36",              name_zh_TW = "探求之證 36",    name_zh_CN = "探求之证 36",    position = "1427.493, 35.8315, -1567.728" },
    { name_EN = "Seeker's Token 37",              name_zh_TW = "探求之證 37",    name_zh_CN = "探求之证 37",    position = "1241.345, 171.7751, -2249.933" },
    { name_EN = "Seeker's Token 38",              name_zh_TW = "探求之證 38",    name_zh_CN = "探求之证 38",    position = "-868.9569, 15.14516, 902.671" },
    { name_EN = "Seeker's Token 39",              name_zh_TW = "探求之證 39",    name_zh_CN = "探求之证 39",    position = "-562.1972, 27.44761, -1582.972" },
    { name_EN = "Seeker's Token 40",              name_zh_TW = "探求之證 40",    name_zh_CN = "探求之证 40",    position = "-1983.061, 264.5901, -890.088" },
    { name_EN = "Seeker's Token 41",              name_zh_TW = "探求之證 41",    name_zh_CN = "探求之证 41",    position = "-1473.602, 158.7904, -1017.371" },
    { name_EN = "Seeker's Token 42",              name_zh_TW = "探求之證 42",    name_zh_CN = "探求之证 42",    position = "576.5875, 28.66201, -1301.384" },
    { name_EN = "Seeker's Token 43",              name_zh_TW = "探求之證 43",    name_zh_CN = "探求之证 43",    position = "1301.607, 0.6638163, -1370.327" },
    { name_EN = "Seeker's Token 44",              name_zh_TW = "探求之證 44",    name_zh_CN = "探求之证 44",    position = "-1037.706, 61.63612, -1543.092" },
    { name_EN = "Seeker's Token 45",              name_zh_TW = "探求之證 45",    name_zh_CN = "探求之证 45",    position = "-2290.82, 113.6292, -406.696" },
    { name_EN = "Seeker's Token 46",              name_zh_TW = "探求之證 46",    name_zh_CN = "探求之证 46",    position = "1158.227, 3.896768, -1204.033" },
    { name_EN = "Seeker's Token 47",              name_zh_TW = "探求之證 47",    name_zh_CN = "探求之证 47",    position = "67.42051, 142.9019, -2126.103" },
    { name_EN = "Seeker's Token 48",              name_zh_TW = "探求之證 48",    name_zh_CN = "探求之证 48",    position = "-2275.997, 71.59417, -392.5833" },
    { name_EN = "Seeker's Token 49",              name_zh_TW = "探求之證 49",    name_zh_CN = "探求之证 49",    position = "-537.8214, 8.304099, 1173.693" },
    { name_EN = "Seeker's Token 50",              name_zh_TW = "探求之證 50",    name_zh_CN = "探求之证 50",    position = "-2045.45, 244.2061, -653.381" },
    { name_EN = "Seeker's Token 51",              name_zh_TW = "探求之證 51",    name_zh_CN = "探求之证 51",    position = "-1624.109, 69.67034, 1044.009" },
    { name_EN = "Seeker's Token 52",              name_zh_TW = "探求之證 52",    name_zh_CN = "探求之证 52",    position = "-1154.636, 99.41915, -1496.902" },
    { name_EN = "Seeker's Token 53",              name_zh_TW = "探求之證 53",    name_zh_CN = "探求之证 53",    position = "368.6974, 192.1294, -2312.887" },
    { name_EN = "Seeker's Token 54",              name_zh_TW = "探求之證 54",    name_zh_CN = "探求之证 54",    position = "966.6755, 68.71934, -1654.37" },
    { name_EN = "Seeker's Token 55",              name_zh_TW = "探求之證 55",    name_zh_CN = "探求之证 55",    position = "-531.8324, 140.7443, -2164.448" },
    { name_EN = "Seeker's Token 56",              name_zh_TW = "探求之證 56",    name_zh_CN = "探求之证 56",    position = "-2231.03, 282.9688, -817.4234" },
    { name_EN = "Seeker's Token 57",              name_zh_TW = "探求之證 57",    name_zh_CN = "探求之证 57",    position = "-731.689, 24.34222, -1557.463" },
    { name_EN = "Seeker's Token 58",              name_zh_TW = "探求之證 58",    name_zh_CN = "探求之证 58",    position = "-1800.555, 70.33961, 381.2898" },
    { name_EN = "Seeker's Token 59",              name_zh_TW = "探求之證 59",    name_zh_CN = "探求之证 59",    position = "-669.8233, 5.020011, -940.93" },
    { name_EN = "Seeker's Token 60",              name_zh_TW = "探求之證 60",    name_zh_CN = "探求之证 60",    position = "-452.4744, 94.03584, -1944.387" },
    { name_EN = "Seeker's Token 61",              name_zh_TW = "探求之證 61",    name_zh_CN = "探求之证 61",    position = "-2073.348, 87.33474, 13.64392" },
    { name_EN = "Seeker's Token 62",              name_zh_TW = "探求之證 62",    name_zh_CN = "探求之证 62",    position = "-1264.083, 103.8367, -1354.126" },
    { name_EN = "Seeker's Token 63",              name_zh_TW = "探求之證 63",    name_zh_CN = "探求之证 63",    position = "-2058.721, 57.39219, 513.1974" },
    { name_EN = "Seeker's Token 64",              name_zh_TW = "探求之證 64",    name_zh_CN = "探求之证 64",    position = "-443.0493, 42.20091, -663.1949" },
    { name_EN = "Seeker's Token 65",              name_zh_TW = "探求之證 65",    name_zh_CN = "探求之证 65",    position = "-239.6361, 8.631701, -838.8901" },
    { name_EN = "Seeker's Token 66",              name_zh_TW = "探求之證 66",    name_zh_CN = "探求之证 66",    position = "878.4819, 10.14215, -1337.172" },
    { name_EN = "Seeker's Token 67",              name_zh_TW = "探求之證 67",    name_zh_CN = "探求之证 67",    position = "-27.64818, 0.6451912, -998.9725" },
    { name_EN = "Seeker's Token 68",              name_zh_TW = "探求之證 68",    name_zh_CN = "探求之证 68",    position = "1085.92, 61.37453, -1263.965" },
    { name_EN = "Seeker's Token 69",              name_zh_TW = "探求之證 69",    name_zh_CN = "探求之证 69",    position = "505.3856, 63.05507, -907.8718" },
    { name_EN = "Seeker's Token 70",              name_zh_TW = "探求之證 70",    name_zh_CN = "探求之证 70",    position = "-2209.501, 67.62506, 502.0663" },
    { name_EN = "Seeker's Token 71",              name_zh_TW = "探求之證 71",    name_zh_CN = "探求之证 71",    position = "-1169.348, 114.5239, -1078.889" },
    { name_EN = "Seeker's Token 72",              name_zh_TW = "探求之證 72",    name_zh_CN = "探求之证 72",    position = "-1744.333, 67.46979, 256.7256" },
    { name_EN = "Seeker's Token 73",              name_zh_TW = "探求之證 73",    name_zh_CN = "探求之证 73",    position = "396.9378, 85.66324, -820.0371" },
    { name_EN = "Seeker's Token 74",              name_zh_TW = "探求之證 74",    name_zh_CN = "探求之证 74",    position = "-2239.501, 290.0148, 1015.552" },
    { name_EN = "Seeker's Token 75",              name_zh_TW = "探求之證 75",    name_zh_CN = "探求之证 75",    position = "-1063.11, 136.2313, 416.3393" },
    { name_EN = "Seeker's Token 76",              name_zh_TW = "探求之證 76",    name_zh_CN = "探求之证 76",    position = "1133.997, 190.9401, -2244.319" },
    { name_EN = "Seeker's Token 77",              name_zh_TW = "探求之證 77",    name_zh_CN = "探求之证 77",    position = "1164.265, 46.84266, -1690.47" },
    { name_EN = "Seeker's Token 78",              name_zh_TW = "探求之證 78",    name_zh_CN = "探求之证 78",    position = "879.8962, 193.0155, -2363.888" },
    { name_EN = "Seeker's Token 79",              name_zh_TW = "探求之證 79",    name_zh_CN = "探求之证 79",    position = "-1957.176, 90.54247, -293.5216" },
    { name_EN = "Seeker's Token 80",              name_zh_TW = "探求之證 80",    name_zh_CN = "探求之证 80",    position = "-321.8596, 62.14732, 861.4832" },
    { name_EN = "Seeker's Token 81",              name_zh_TW = "探求之證 81",    name_zh_CN = "探求之证 81",    position = "100.7216, 179.9064, -2105.341" },
    { name_EN = "Seeker's Token 82",              name_zh_TW = "探求之證 82",    name_zh_CN = "探求之证 82",    position = "-2357.598, 83.993, -196.4987" },
    { name_EN = "Seeker's Token 83",              name_zh_TW = "探求之證 83",    name_zh_CN = "探求之证 83",    position = "-2226.387, 130.6572, -345.0266" },
    { name_EN = "Seeker's Token 84",              name_zh_TW = "探求之證 84",    name_zh_CN = "探求之证 84",    position = "-24.78811, 9.76271, -1184.259" },
    { name_EN = "Seeker's Token 85",              name_zh_TW = "探求之證 85",    name_zh_CN = "探求之证 85",    position = "991.0721, 75.88528, -1753.271" },
    { name_EN = "Seeker's Token 86",              name_zh_TW = "探求之證 86",    name_zh_CN = "探求之证 86",    position = "-957.5068, 43.63776, -1013.708" },
    { name_EN = "Seeker's Token 87",              name_zh_TW = "探求之證 87",    name_zh_CN = "探求之证 87",    position = "-1810.451, 37.58649, 857.5712" },
    { name_EN = "Seeker's Token 88",              name_zh_TW = "探求之證 88",    name_zh_CN = "探求之证 88",    position = "-2052.696, 158.5537, 966.871" },
    { name_EN = "Seeker's Token 89",              name_zh_TW = "探求之證 89",    name_zh_CN = "探求之证 89",    position = "-1143.138, 87.47182, -1574.525" },
    { name_EN = "Seeker's Token 90",              name_zh_TW = "探求之證 90",    name_zh_CN = "探求之证 90",    position = "196.2978, 167.8351, -2355.079" },
    { name_EN = "Seeker's Token 91",              name_zh_TW = "探求之證 91",    name_zh_CN = "探求之证 91",    position = "-1412.043, 157, 334.4911" },
    { name_EN = "Seeker's Token 92",              name_zh_TW = "探求之證 92",    name_zh_CN = "探求之证 92",    position = "-1669.654, 50.81789, 966.7512" },
    { name_EN = "Seeker's Token 93",              name_zh_TW = "探求之證 93",    name_zh_CN = "探求之证 93",    position = "-2000.453, 83.90808, -85.11404" },
    { name_EN = "Seeker's Token 94",              name_zh_TW = "探求之證 94",    name_zh_CN = "探求之证 94",    position = "-2288.28, 61.76313, 160.2155" },
    { name_EN = "Seeker's Token 95",              name_zh_TW = "探求之證 95",    name_zh_CN = "探求之证 95",    position = "-1744.999, 52.29864, 729.0167" },
    { name_EN = "Seeker's Token 96",              name_zh_TW = "探求之證 96",    name_zh_CN = "探求之证 96",    position = "1213.163, 7.444563, -1307.155" },
    { name_EN = "Seeker's Token 97",              name_zh_TW = "探求之證 97",    name_zh_CN = "探求之证 97",    position = "1451.397, 30.69706, -1425.217" },
    { name_EN = "Seeker's Token 98",              name_zh_TW = "探求之證 98",    name_zh_CN = "探求之证 98",    position = "1246.022, 85.96709, -1719.665" },
    { name_EN = "Seeker's Token 99",              name_zh_TW = "探求之證 99",    name_zh_CN = "探求之证 99",    position = "-377.4244, 25.65013, 1072.151" },
    { name_EN = "Seeker's Token 100",             name_zh_TW = "探求之證 100",   name_zh_CN = "探求之证 100",   position = "-362.2318, 27.21784, 1137.943" },
    { name_EN = "Seeker's Token 101",             name_zh_TW = "探求之證 101",   name_zh_CN = "探求之证 101",   position = "-311.1265, 46.33576, -1172.065" },
    { name_EN = "Seeker's Token 102",             name_zh_TW = "探求之證 102",   name_zh_CN = "探求之证 102",   position = "-1863.659, 53.75474, 564.1379" },
    { name_EN = "Seeker's Token 103",             name_zh_TW = "探求之證 103",   name_zh_CN = "探求之证 103",   position = "87.88998, 275.9138, -2699.498" },
    { name_EN = "Seeker's Token 104",             name_zh_TW = "探求之證 104",   name_zh_CN = "探求之证 104",   position = "497.4532, 66.13264, -931.752" },
    { name_EN = "Seeker's Token 105",             name_zh_TW = "探求之證 105",   name_zh_CN = "探求之证 105",   position = "-1947.701, 106.3777, -142.9371" },
    { name_EN = "Seeker's Token 106",             name_zh_TW = "探求之證 106",   name_zh_CN = "探求之证 106",   position = "-1992.826, 211.1146, -553.046" },
    { name_EN = "Seeker's Token 107",             name_zh_TW = "探求之證 107",   name_zh_CN = "探求之证 107",   position = "-1916.496, 243.5359, -897.6821" },
    { name_EN = "Seeker's Token 108",             name_zh_TW = "探求之證 108",   name_zh_CN = "探求之证 108",   position = "-413.092, 100.2532, -1961.737" },
    { name_EN = "Seeker's Token 109",             name_zh_TW = "探求之證 109",   name_zh_CN = "探求之证 109",   position = "-2087.02, 41.7835, 196.835" },
    { name_EN = "Seeker's Token 110",             name_zh_TW = "探求之證 110",   name_zh_CN = "探求之证 110",   position = "155.5486, 85.44305, 1108.05" },
    { name_EN = "Seeker's Token 111",             name_zh_TW = "探求之證 111",   name_zh_CN = "探求之证 111",   position = "-215.3959, 39.77499, -1228.676" },
    { name_EN = "Seeker's Token 112",             name_zh_TW = "探求之證 112",   name_zh_CN = "探求之证 112",   position = "406.3369, 45.64609, -978.3323" },
    { name_EN = "Seeker's Token 113",             name_zh_TW = "探求之證 113",   name_zh_CN = "探求之证 113",   position = "-662.3477, 22.74153, -1335.208" },
    { name_EN = "Seeker's Token 114",             name_zh_TW = "探求之證 114",   name_zh_CN = "探求之证 114",   position = "-471.8372, 30.35632, 1167.059" },
    { name_EN = "Seeker's Token 115",             name_zh_TW = "探求之證 115",   name_zh_CN = "探求之证 115",   position = "-985.4307, 48.5821, -302.3444" },
    { name_EN = "Seeker's Token 116",             name_zh_TW = "探求之證 116",   name_zh_CN = "探求之证 116",   position = "-691.2465, 17.03014, 674.2273" },
    { name_EN = "Seeker's Token 117",             name_zh_TW = "探求之證 117",   name_zh_CN = "探求之证 117",   position = "44.64841, 148.8826, -2307.236" },
    { name_EN = "Seeker's Token 118",             name_zh_TW = "探求之證 118",   name_zh_CN = "探求之证 118",   position = "-2050.989, 114.8949, -383.0466" },
    { name_EN = "Seeker's Token 119",             name_zh_TW = "探求之證 119",   name_zh_CN = "探求之证 119",   position = "-1410.486, 144.7303, -1389.202" },
    { name_EN = "Seeker's Token 120",             name_zh_TW = "探求之證 120",   name_zh_CN = "探求之证 120",   position = "-1040.184, 0.4392352, 1258.829" },
    { name_EN = "Seeker's Token 121",             name_zh_TW = "探求之證 121",   name_zh_CN = "探求之证 121",   position = "-452.9087, 0.796546, 741.597" },
    { name_EN = "Seeker's Token 122",             name_zh_TW = "探求之證 122",   name_zh_CN = "探求之证 122",   position = "334.2993, 100.3809, 1323.854" },
    { name_EN = "Seeker's Token 123",             name_zh_TW = "探求之證 123",   name_zh_CN = "探求之证 123",   position = "-1558.879, 85.9902, 429.7581" },
    { name_EN = "Seeker's Token 124",             name_zh_TW = "探求之證 124",   name_zh_CN = "探求之证 124",   position = "1253.134, 67.67858, -1870.294" },
    { name_EN = "Seeker's Token 125",             name_zh_TW = "探求之證 125",   name_zh_CN = "探求之证 125",   position = "-2175.953, 75.2403, 513.1131" },
    { name_EN = "Seeker's Token 126",             name_zh_TW = "探求之證 126",   name_zh_CN = "探求之证 126",   position = "486.8091, 24.38745, -1054.205" },
    { name_EN = "Seeker's Token 127",             name_zh_TW = "探求之證 127",   name_zh_CN = "探求之证 127",   position = "-1145.974, 46.43586, -255.1327" },
    { name_EN = "Seeker's Token 128",             name_zh_TW = "探求之證 128",   name_zh_CN = "探求之证 128",   position = "802.7636, 10.00694, -1275.782" },
    { name_EN = "Seeker's Token 129",             name_zh_TW = "探求之證 129",   name_zh_CN = "探求之证 129",   position = "-257.8826, 50.04342, 769.1068" },
    { name_EN = "Seeker's Token 130",             name_zh_TW = "探求之證 130",   name_zh_CN = "探求之证 130",   position = "-256.1795, 29.35168, 1128.872" },
    { name_EN = "Seeker's Token 131",             name_zh_TW = "探求之證 131",   name_zh_CN = "探求之证 131",   position = "-29.33716, 164.9512, -2487.574" },
    { name_EN = "Seeker's Token 132",             name_zh_TW = "探求之證 132",   name_zh_CN = "探求之证 132",   position = "-2438.648, 297.7558, -729.283" },
    { name_EN = "Seeker's Token 133",             name_zh_TW = "探求之證 133",   name_zh_CN = "探求之证 133",   position = "-1735.35, 67.04755, 604.192" },
    { name_EN = "Seeker's Token 134",             name_zh_TW = "探求之證 134",   name_zh_CN = "探求之证 134",   position = "-2437.834, 75.30431, -279.8528" },
    { name_EN = "Seeker's Token 135",             name_zh_TW = "探求之證 135",   name_zh_CN = "探求之证 135",   position = "-1467.244, 167.842, -972.6749" },
    { name_EN = "Seeker's Token 136",             name_zh_TW = "探求之證 136",   name_zh_CN = "探求之证 136",   position = "-1144.316, 59.95095, -37.65364" },
    { name_EN = "Seeker's Token 137",             name_zh_TW = "探求之證 137",   name_zh_CN = "探求之证 137",   position = "-2205.891, 37.86744, 416.3837" },
    { name_EN = "Seeker's Token 138",             name_zh_TW = "探求之證 138",   name_zh_CN = "探求之证 138",   position = "-1325.521, 153.6144, 318.1047" },
    { name_EN = "Seeker's Token 139",             name_zh_TW = "探求之證 139",   name_zh_CN = "探求之证 139",   position = "-1726.722, 96.89873, 19.04225" },
    { name_EN = "Seeker's Token 140",             name_zh_TW = "探求之證 140",   name_zh_CN = "探求之证 140",   position = "-1455.78, 107.9478, 276.0348" },
    { name_EN = "Seeker's Token 141",             name_zh_TW = "探求之證 141",   name_zh_CN = "探求之证 141",   position = "14.76145, 190.1257, -2412.495" },
    { name_EN = "Seeker's Token 142",             name_zh_TW = "探求之證 142",   name_zh_CN = "探求之证 142",   position = "-2081.739, 81.17527, -169.5074" },
    { name_EN = "Seeker's Token 143",             name_zh_TW = "探求之證 143",   name_zh_CN = "探求之证 143",   position = "-2195.761, 82.26016, -148.4175" },
    { name_EN = "Seeker's Token 144",             name_zh_TW = "探求之證 144",   name_zh_CN = "探求之证 144",   position = "509.7451, 20.81026, -1124.374" },
    { name_EN = "Seeker's Token 145",             name_zh_TW = "探求之證 145",   name_zh_CN = "探求之证 145",   position = "-1128.958, 78.22768, 389.9597" },
    { name_EN = "Seeker's Token 146",             name_zh_TW = "探求之證 146",   name_zh_CN = "探求之证 146",   position = "378.7181, 44.0754, -1047.653" },
    { name_EN = "Seeker's Token 147",             name_zh_TW = "探求之證 147",   name_zh_CN = "探求之证 147",   position = "1094.016, 61.32773, -1263.995" },
    { name_EN = "Seeker's Token 148",             name_zh_TW = "探求之證 148",   name_zh_CN = "探求之证 148",   position = "-1059.732, 80.43699, 239.3768" },
    { name_EN = "Seeker's Token 149",             name_zh_TW = "探求之證 149",   name_zh_CN = "探求之证 149",   position = "-300.6327, 22.67523, -1187.099" },
    { name_EN = "Seeker's Token 150",             name_zh_TW = "探求之證 150",   name_zh_CN = "探求之证 150",   position = "-2117.376, 223.6917, 1044.149" },
    { name_EN = "Seeker's Token 151",             name_zh_TW = "探求之證 151",   name_zh_CN = "探求之证 151",   position = "-2096.548, 143.9485, 897.7155" },
    { name_EN = "Seeker's Token 152",             name_zh_TW = "探求之證 152",   name_zh_CN = "探求之证 152",   position = "-1017.941, 26.8972, 160.796" },
    { name_EN = "Seeker's Token 153",             name_zh_TW = "探求之證 153",   name_zh_CN = "探求之证 153",   position = "-1190.294, 102.4365, 319.5692" },
    { name_EN = "Seeker's Token 154",             name_zh_TW = "探求之證 154",   name_zh_CN = "探求之证 154",   position = "889.1685, 20.1433, -1190.647" },
    { name_EN = "Seeker's Token 155",             name_zh_TW = "探求之證 155",   name_zh_CN = "探求之证 155",   position = "-930.7362, 37.33437, -730.5226" },
    { name_EN = "Seeker's Token 156",             name_zh_TW = "探求之證 156",   name_zh_CN = "探求之证 156",   position = "81.20549, 69.3, -1748.368" },
    { name_EN = "Seeker's Token 157",             name_zh_TW = "探求之證 157",   name_zh_CN = "探求之证 157",   position = "928.5052, 240.082, -2586.659" },
    { name_EN = "Seeker's Token 158",             name_zh_TW = "探求之證 158",   name_zh_CN = "探求之证 158",   position = "1074.255, 49.43904, -1615.228" },
    { name_EN = "Seeker's Token 159",             name_zh_TW = "探求之證 159",   name_zh_CN = "探求之证 159",   position = "-1385.482, 110.7523, -1279.451" },
    { name_EN = "Seeker's Token 160",             name_zh_TW = "探求之證 160",   name_zh_CN = "探求之证 160",   position = "-175.3369, 75.17094, -1411.751" },
    { name_EN = "Seeker's Token 161",             name_zh_TW = "探求之證 161",   name_zh_CN = "探求之证 161",   position = "-1893.107, 35.35776, 756.4501" },
    { name_EN = "Seeker's Token 162",             name_zh_TW = "探求之證 162",   name_zh_CN = "探求之证 162",   position = "-489.7266, 18.02133, -1064.699" },
    { name_EN = "Seeker's Token 163",             name_zh_TW = "探求之證 163",   name_zh_CN = "探求之证 163",   position = "1215.604, 76.60162, -1907.77" },
    { name_EN = "Seeker's Token 164",             name_zh_TW = "探求之證 164",   name_zh_CN = "探求之证 164",   position = "-1623.225, 86.3857, 291.1531" },
    { name_EN = "Seeker's Token 165",             name_zh_TW = "探求之證 165",   name_zh_CN = "探求之证 165",   position = "371.4242, 78.0455, -881.5969" },
    { name_EN = "Seeker's Token 166",             name_zh_TW = "探求之證 166",   name_zh_CN = "探求之证 166",   position = "-1547.166, 69.55149, 1078.691" },
    { name_EN = "Seeker's Token 167",             name_zh_TW = "探求之證 167",   name_zh_CN = "探求之证 167",   position = "923.5192, 195.4502, -2313.818" },
    { name_EN = "Seeker's Token 168",             name_zh_TW = "探求之證 168",   name_zh_CN = "探求之证 168",   position = "-593.5593, 50.08264, -1789.409" },
    { name_EN = "Seeker's Token 169",             name_zh_TW = "探求之證 169",   name_zh_CN = "探求之证 169",   position = "-967.5819, 13.6438, -234.7076" },
    { name_EN = "Seeker's Token 170",             name_zh_TW = "探求之證 170",   name_zh_CN = "探求之证 170",   position = "-554.0727, 35.60732, -1033.871" },
    { name_EN = "Seeker's Token 171",             name_zh_TW = "探求之證 171",   name_zh_CN = "探求之证 171",   position = "-1707.572, 85.18982, 114.9935" },
    { name_EN = "Seeker's Token 172",             name_zh_TW = "探求之證 172",   name_zh_CN = "探求之证 172",   position = "-1307.999, 148.0497, -1420.194" },
    { name_EN = "Seeker's Token 173",             name_zh_TW = "探求之證 173",   name_zh_CN = "探求之证 173",   position = "-1058.136, 97.33194, 400.906" },
    { name_EN = "Seeker's Token 174",             name_zh_TW = "探求之證 174",   name_zh_CN = "探求之证 174",   position = "1284.713, 29.37333, -1253.282" },
    { name_EN = "Seeker's Token 175",             name_zh_TW = "探求之證 175",   name_zh_CN = "探求之证 175",   position = "-1737.472, 191.269, -1190.988" },
    { name_EN = "Seeker's Token 176",             name_zh_TW = "探求之證 176",   name_zh_CN = "探求之证 176",   position = "-2144.98, 237.7022, 931.1352" },
    { name_EN = "Seeker's Token 177",             name_zh_TW = "探求之證 177",   name_zh_CN = "探求之证 177",   position = "-744.014, 37.91385, -1269.364" },
    { name_EN = "Seeker's Token 178",             name_zh_TW = "探求之證 178",   name_zh_CN = "探求之证 178",   position = "-2206.928, 76.91254, 370.2791" },
    { name_EN = "Seeker's Token 179",             name_zh_TW = "探求之證 179",   name_zh_CN = "探求之证 179",   position = "824.2649, 231.7646, -2651.551" },
    { name_EN = "Seeker's Token 180",             name_zh_TW = "探求之證 180",   name_zh_CN = "探求之证 180",   position = "-460.4371, 21.96133, -868.7405" },
    { name_EN = "Seeker's Token 181",             name_zh_TW = "探求之證 181",   name_zh_CN = "探求之证 181",   position = "530.9937, -1.72881, -949.6918" },
    { name_EN = "Seeker's Token 182",             name_zh_TW = "探求之證 182",   name_zh_CN = "探求之证 182",   position = "459.0298, 76.78581, -719.246" },
    { name_EN = "Seeker's Token 183",             name_zh_TW = "探求之證 183",   name_zh_CN = "探求之证 183",   position = "-1907.512, 194.0277, -539.9005" },
    { name_EN = "Seeker's Token 184",             name_zh_TW = "探求之證 184",   name_zh_CN = "探求之证 184",   position = "310.7063, 2.663232, -1093.182" },
    { name_EN = "Seeker's Token 185",             name_zh_TW = "探求之證 185",   name_zh_CN = "探求之证 185",   position = "-2090.685, 87.91904, -252.9724" },
    { name_EN = "Seeker's Token 186",             name_zh_TW = "探求之證 186",   name_zh_CN = "探求之证 186",   position = "-1545.581, 168.1623, -1526.813" },
    { name_EN = "Seeker's Token 187",             name_zh_TW = "探求之證 187",   name_zh_CN = "探求之证 187",   position = "-900.6052, -0.4724793, -41.89881" },
    { name_EN = "Seeker's Token 188",             name_zh_TW = "探求之證 188",   name_zh_CN = "探求之证 188",   position = "1188.915, 38.70578, -1399.902" },
    { name_EN = "Seeker's Token 189",             name_zh_TW = "探求之證 189",   name_zh_CN = "探求之证 189",   position = "-1592.083, 166.3117, -1439.994" },
    { name_EN = "Seeker's Token 190",             name_zh_TW = "探求之證 190",   name_zh_CN = "探求之证 190",   position = "59.92789, 221.4001, -2591.599" },
    { name_EN = "Seeker's Token 191",             name_zh_TW = "探求之證 191",   name_zh_CN = "探求之证 191",   position = "17.31717, 95.44806, -2068.056" },
    { name_EN = "Seeker's Token 192",             name_zh_TW = "探求之證 192",   name_zh_CN = "探求之证 192",   position = "1294.648, 32.48453, -1162.289" },
    { name_EN = "Seeker's Token 193",             name_zh_TW = "探求之證 193",   name_zh_CN = "探求之证 193",   position = "-988.0832, 29.20226, 1193.494" },
    { name_EN = "Seeker's Token 194",             name_zh_TW = "探求之證 194",   name_zh_CN = "探求之证 194",   position = "1087.994, 42.86492, -1509.454" },
    { name_EN = "Seeker's Token 195",             name_zh_TW = "探求之證 195",   name_zh_CN = "探求之证 195",   position = "390.7802, 24.44314, -1063.17" },
    { name_EN = "Seeker's Token 196",             name_zh_TW = "探求之證 196",   name_zh_CN = "探求之证 196",   position = "334.6868, 206.1537, -2521.229" },
    { name_EN = "Seeker's Token 197",             name_zh_TW = "探求之證 197",   name_zh_CN = "探求之证 197",   position = "1180.006, 65.77381, -1937.357" },
    { name_EN = "Seeker's Token 198",             name_zh_TW = "探求之證 198",   name_zh_CN = "探求之证 198",   position = "-892.7271, 29.77627, -720.5415" },
    { name_EN = "Seeker's Token 199",             name_zh_TW = "探求之證 199",   name_zh_CN = "探求之证 199",   position = "542.3516, 15.91502, -1215.642" },
    { name_EN = "Seeker's Token 200",             name_zh_TW = "探求之證 200",   name_zh_CN = "探求之证 200",   position = "1506.107, 28.23366, -1357.404" },
    { name_EN = "Seeker's Token 201",             name_zh_TW = "探求之證 201",   name_zh_CN = "探求之证 201",   position = "-2200.933, 296.0031, 1054.443" },
    { name_EN = "Seeker's Token 202",             name_zh_TW = "探求之證 202",   name_zh_CN = "探求之证 202",   position = "458.9755, 46.67035, -1029.605" },
    { name_EN = "Seeker's Token 203",             name_zh_TW = "探求之證 203",   name_zh_CN = "探求之证 203",   position = "-1860.29, 85.47575, -437.5429" },
    { name_EN = "Seeker's Token 204",             name_zh_TW = "探求之證 204",   name_zh_CN = "探求之证 204",   position = "-1121.143, 79.09875, -1639.249" },
    { name_EN = "Seeker's Token 205",             name_zh_TW = "探求之證 205",   name_zh_CN = "探求之证 205",   position = "942.6032, -0.3656093, -1232.318" },
    { name_EN = "Seeker's Token 206",             name_zh_TW = "探求之證 206",   name_zh_CN = "探求之证 206",   position = "-477.5305, 87.42719, 1420.187" },
    { name_EN = "Seeker's Token 207",             name_zh_TW = "探求之證 207",   name_zh_CN = "探求之证 207",   position = "1091.268, 25.77886, -1428.777" },
    { name_EN = "Seeker's Token 208",             name_zh_TW = "探求之證 208",   name_zh_CN = "探求之证 208",   position = "-1820.409, 98.10882, -87.64505" },
    { name_EN = "Seeker's Token 209",             name_zh_TW = "探求之證 209",   name_zh_CN = "探求之证 209",   position = "-996.6234, 104.1155, -1290.778" },
    { name_EN = "Seeker's Token 210",             name_zh_TW = "探求之證 210",   name_zh_CN = "探求之证 210",   position = "-806.2393, 30.66521, -947.8731" },
    { name_EN = "Seeker's Token 211",             name_zh_TW = "探求之證 211",   name_zh_CN = "探求之证 211",   position = "180.126, 26.03245, -1161.688" },
    { name_EN = "Seeker's Token 212",             name_zh_TW = "探求之證 212",   name_zh_CN = "探求之证 212",   position = "-1670.075, 99.82407, -1280.521" },
    { name_EN = "Seeker's Token 213",             name_zh_TW = "探求之證 213",   name_zh_CN = "探求之证 213",   position = "-1101.613, 114.1108, 612.7404" },
    { name_EN = "Seeker's Token 214",             name_zh_TW = "探求之證 214",   name_zh_CN = "探求之证 214",   position = "512.6115, 44.41759, -960.8672" },
    { name_EN = "Seeker's Token 215",             name_zh_TW = "探求之證 215",   name_zh_CN = "探求之证 215",   position = "-597.4287, 0.2458094, -842.9684" },
    { name_EN = "Seeker's Token 216",             name_zh_TW = "探求之證 216",   name_zh_CN = "探求之证 216",   position = "1148.682, 23.13101, -1390.438" },
    { name_EN = "Seeker's Token 217",             name_zh_TW = "探求之證 217",   name_zh_CN = "探求之证 217",   position = "-1709.469, 53.84142, 1102.876" },
    { name_EN = "Seeker's Token 218",             name_zh_TW = "探求之證 218",   name_zh_CN = "探求之证 218",   position = "-2390.223, 272.1731, -619.5712" },
    { name_EN = "Seeker's Token 219",             name_zh_TW = "探求之證 219",   name_zh_CN = "探求之证 219",   position = "-546.9639, 96.17853, -1880.174" },
    { name_EN = "Seeker's Token 220",             name_zh_TW = "探求之證 220",   name_zh_CN = "探求之证 220",   position = "-2008.847, 124.2037, 945.9615" },
    { name_EN = "Seeker's Token 221",             name_zh_TW = "探求之證 221",   name_zh_CN = "探求之证 221",   position = "-2403.851, 315.0301, -879.7818" },
    { name_EN = "Seeker's Token 222",             name_zh_TW = "探求之證 222",   name_zh_CN = "探求之证 222",   position = "-313.1738, 49.01183, 1247.046" },
    { name_EN = "Seeker's Token 223",             name_zh_TW = "探求之證 223",   name_zh_CN = "探求之证 223",   position = "-492.7277, 130.1809, -2259.106" },
    { name_EN = "Seeker's Token 224",             name_zh_TW = "探求之證 224",   name_zh_CN = "探求之证 224",   position = "597.8867, 80.00896, -854.4315" },
    { name_EN = "Seeker's Token 225",             name_zh_TW = "探求之證 225",   name_zh_CN = "探求之证 225",   position = "-1346.704, 120.433, 398.7322" },
    { name_EN = "Seeker's Token 226",             name_zh_TW = "探求之證 226",   name_zh_CN = "探求之证 226",   position = "-1941.606, 77.46495, -340.7309" },
    { name_EN = "Seeker's Token 227",             name_zh_TW = "探求之證 227",   name_zh_CN = "探求之证 227",   position = "-804.2957, 44.27563, -1351.228" },
    { name_EN = "Seeker's Token 228",             name_zh_TW = "探求之證 228",   name_zh_CN = "探求之证 228",   position = "-347.2373, 53,32834, -884.2132" },
    { name_EN = "Seeker's Token 229",             name_zh_TW = "探求之證 229",   name_zh_CN = "探求之证 229",   position = "1564.457, 62.45671, -1439.98" },
    { name_EN = "Seeker's Token 230",             name_zh_TW = "探求之證 230",   name_zh_CN = "探求之证 230",   position = "-1787.815, 48.46006, 669.9354" },
    { name_EN = "Seeker's Token 231",             name_zh_TW = "探求之證 231",   name_zh_CN = "探求之证 231",   position = "-661.7025, 38.82969, -1069.028" },
    { name_EN = "Seeker's Token 232",             name_zh_TW = "探求之證 232",   name_zh_CN = "探求之证 232",   position = "-1101.07, 98.0107, -1134.8" },
    { name_EN = "Seeker's Token 233",             name_zh_TW = "探求之證 233",   name_zh_CN = "探求之证 233",   position = "888.7634, 0.3689132, -1230.208" },
    { name_EN = "Seeker's Token 234",             name_zh_TW = "探求之證 234",   name_zh_CN = "探求之证 234",   position = "-939.8016, 67.41076, -1248.607" },
    { name_EN = "Seeker's Token 235",             name_zh_TW = "探求之證 235",   name_zh_CN = "探求之证 235",   position = "-1929.849, 179.5838, -1146.239" },
    { name_EN = "Seeker's Token 236",             name_zh_TW = "探求之證 236",   name_zh_CN = "探求之证 236",   position = "1055.01, 50.11625, -1245.982" },
    { name_EN = "Seeker's Token 237",             name_zh_TW = "探求之證 237",   name_zh_CN = "探求之证 237",   position = "-2454.656, 158.9566, -551.7483" },
    { name_EN = "Seeker's Token 238",             name_zh_TW = "探求之證 238",   name_zh_CN = "探求之证 238",   position = "-759.3116, 16.65483, 1249.993" },
    { name_EN = "Seeker's Token 239",             name_zh_TW = "探求之證 239",   name_zh_CN = "探求之证 239",   position = "494.4174, 14.7665, -1284.163" },
    { name_EN = "Seeker's Token 240",             name_zh_TW = "探求之證 240",   name_zh_CN = "探求之证 240",   position = "-381.5288, 8.838051, -827.5795" },
}

local DefaultHotkeys = {
    ["Teleport Window Key"] = "T",
    ["Teleport Hotkey 1"]   = "F1",
    ["Teleport Hotkey 2"]   = "F2",
    ["Teleport Hotkey 3"]   = "F3",
    ["Teleport Hotkey 4"]   = "F4",
    ["Teleport Hotkey 5"]   = "F5",
    ["Teleport Hotkey 6"]   = "F6",
    ["Teleport Hotkey 7"]   = "F7",
    ["Teleport Hotkey 8"]   = "F8",
    ["Teleport Hotkey 9"]   = "F9",
    ["Teleport Hotkey 10"]  = "F10",
    ["Teleport Hotkey 11"]  = "F11",
    ["Teleport Hotkey 12"]  = "F12",
}

local TextLabels = {
    { lbl_EN = "Enter a hotkey below to teleport to the given location.", lbl_zh_TW = "按下快捷鍵以傳送到指定位置。", lbl_zh_CN = "按下快捷键以传送到指定位置。" }, -- lblText[1]
    { lbl_EN = "Hotkey",                                                  lbl_zh_TW = "快捷鍵",                   lbl_zh_CN = "热键" }, -- lblText[2]
    { lbl_EN = "Location",                                                lbl_zh_TW = "地點",                    lbl_zh_CN = "地点" }, -- lblText[3]
    { lbl_EN = "Window Visibility",                                       lbl_zh_TW = "顯示此視窗",               lbl_zh_CN = "显示此窗口" }, -- lblText[4]
    { lbl_EN = "Locations",                                               lbl_zh_TW = "地點",                    lbl_zh_CN = "地点" }, -- lblText[5]
    { lbl_EN = " Teleport ",                                              lbl_zh_TW = " 傳送 ",                  lbl_zh_CN = " 传送 " }, -- lblText[6]
    { lbl_EN = "Name",                                                    lbl_zh_TW = "名稱",                    lbl_zh_CN = "名称" }, -- lblText[7]
    { lbl_EN = "Add Current Location",                                    lbl_zh_TW = "加入此位置",               lbl_zh_CN = "加入此位置" }, -- lblText[8]
    { lbl_EN = "Bonus Locations",                                         lbl_zh_TW = "額外地點",                 lbl_zh_CN = "额外地点" }, -- lblText[9]
    { lbl_EN = "Hotkey Window Settings",                                  lbl_zh_TW = "快捷鍵設定",               lbl_zh_CN = "热键设定" }, -- lblText[10]
	{ lbl_EN = "Teleport Window Key",                                     lbl_zh_TW = "傳送視窗快捷鍵",            lbl_zh_CN = "传送窗口热键" }, -- lblText[11]
    { lbl_EN = "Require Window Open",                                     lbl_zh_TW = "傳送時要求開啓視窗",         lbl_zh_CN = "传送时要求开启窗口" }, -- lblText[12]
    { lbl_EN = "Hide ",                                                   lbl_zh_TW = "隱藏 ",                   lbl_zh_CN = "隐藏 " }, -- lblText[13]
    { lbl_EN = "Show ",                                                   lbl_zh_TW = "顯示 ",                   lbl_zh_CN = "显示 " }, -- lblText[14]
    { lbl_EN = "Hotkeys Window",                                          lbl_zh_TW = "快捷鍵視窗",               lbl_zh_CN = "热键窗口" }, -- lblText[15]
}

local Config = {
    RequireTeleportWindowOpen = RequireTeleportWindowOpen,
    CustomTeleportLocations = {},
    Hotkeys = DefaultHotkeys,
	Language = Language
}

local function write_valuetype(parent_obj, offset, value)
    for i = 0, value.type:get_valuetype_size() - 1 do
        parent_obj:write_byte(offset + i, value:read_byte(i))
    end
end

local function log_info(infoMessage)
    if WriteInfoLogs then
        log.info("rthomasv3 > Teleportation: " .. infoMessage)
    end
end

local function log_error(errorMessage)
    log.error("rthomasv3 > Teleportation: " .. errorMessage)
end

local function save_config()
    local success, err = pcall(json.dump_file, ConfigFilePath, Config)
    if not success then
        log_error("Error saving custom locations: " .. tostring(err))
    else
        log_info("Successfully saved custom locations")
    end
end

local function load_config()
    local file = io.open(ConfigFilePath, "r")
    if file then
        file:close()
        local status, data = pcall(json.load_file, ConfigFilePath)
        if status and data then
            Config = data

            if not Config.CustomTeleportLocations then
                Config.CustomTeleportLocations = {}
            end
        else
            log_error("Error loading custom locations: Data is corrupt or invalid.")
            save_config()
        end
    end
end

local function get_player_position()
    local position = nil

    local character = CharacterManager:get_field("<ManualPlayer>k__BackingField")

    if character then
        local gameObject = character:get_GameObject()

        if gameObject then
            local transform = gameObject:get_Transform()

            if transform then
                local universalPosition = transform:get_UniversalPosition()
                position = universalPosition:ToString()
                
                log_info("Player Universal Position: " .. position)
            end
        end
    end

    return position
end

local function update_location_names()
    LocationNames = {}

    for _, location in ipairs(TeleportLocations) do
        -- table.insert(LocationNames, location.name)
		if Config.Language == "zh_TW" then 
			table.insert(LocationNames, location.name_zh_TW)
		elseif Config.Language == "zh_CN" then
			table.insert(LocationNames, location.name_zh_CN)
		else
			table.insert(LocationNames, location.name_EN)
		end
    end

    for _, location in ipairs(Config.CustomTeleportLocations) do
        -- table.insert(LocationNames, location.name)
		if Config.Language == "zh_TW" then 
			table.insert(LocationNames, location.name_zh_TW)
		elseif Config.Language == "zh_CN" then
			table.insert(LocationNames, location.name_zh_CN)
		else
			table.insert(LocationNames, location.name_EN)
		end
    end
end

local function update_language_labels()
    lblTexts = {}

    for _, label in ipairs(TextLabels) do
        if Config.Language == "zh_TW"  then 
            table.insert(lblTexts, label.lbl_zh_TW)
        elseif Config.Language == "zh_CN"  then
            table.insert(lblTexts, label.lbl_zh_CN)
        else
            table.insert(lblTexts, label.lbl_EN)
        end
    end
end

-- Only need to load bonus locations once
for _, location in ipairs(BonusLocations) do
	-- table.insert(BonusLocationNames, location.name)
	if Config.Language == "zh_TW" then 
		table.insert(BonusLocationNames, location.name_zh_TW)
	elseif Config.Language == "zh_CN" then
		table.insert(BonusLocationNames, location.name_zh_CN)
	else
		table.insert(BonusLocationNames, location.name_EN)
	end
end

load_config()

Hotkeys.setup_hotkeys(Config.Hotkeys, DefaultHotkeys)

update_language_labels()

update_location_names()

-- Initialization Done

local function add_custom_location(name)
    local position = get_player_position()

    if position and name then
        log_info("Adding new location: " .. name .. " at " .. position)
        table.insert(Config.CustomTeleportLocations, { name = name, position = position })
        update_location_names()
        save_config()
    else
        log_error("Failed to add custom location: Name " .. (name or "nil") .. " at " .. (position or "nil"))
    end
end

local function teleport(position)
    local character = CharacterManager:get_field("<ManualPlayer>k__BackingField")

    -- If the character is in the scene
    if character then
        -- Add a ferrystone with no notification
        -- ItemManager:getItem(80, 1, 2891076981, false, false, false, 0)
        PreventFerrystoneUsage = true

        -- Set teleportation position
        local teleportPosition = FerrystoneController.TeleportPosition:Parse(position)
        write_valuetype(FerrystoneController, 0x30, teleportPosition)

        -- Get pawns and teleport
        FerrystoneController:gatherTeleportCharactersAndLostDeadPawns()
        FerrystoneController:activateFlow()
    end
end

sdk.hook(
    sdk.find_type_definition("app.ItemManager"):get_method("deleteItem"),
    function(args)
        if PreventFerrystoneUsage then
            PreventFerrystoneUsage = false
            local itemDeleted = sdk.to_int64(args[3])
            if itemDeleted == 80 then
                return sdk.PreHookResult.SKIP_ORIGINAL
            end
        end
    end,
    nil
)

re.on_frame(function()
    if Hotkeys.check_hotkey("Teleport Window Key", false, true) then
        ShowTeleportWindow = not ShowTeleportWindow
    end

    if ShowTeleportWindow or not Config.RequireTeleportWindowOpen then
        local count = math.min(12, #TeleportLocations)
        for i = 1, count do
            if Hotkeys.check_hotkey("Teleport Hotkey " .. tostring(i), false, true) then
                teleport(TeleportLocations[i].position)
                ShowTeleportWindow = false
                break
            end
        end
    end

    if ShowTeleportWindow then
		if Config.Language == "zh_TW"  then imgui.push_font(font_zh_TW) end
        if Config.Language == "zt_CN"  then imgui.push_font(font_zh_CN) end
		
        if not WindowInitialized then
            local displaySize = imgui.get_display_size()
            local windowWidth = 350
            local windowHeight = 455
            local centerX = (displaySize.x / 2)
            local centerTopY = (displaySize.y / 2)
            
            imgui.set_next_window_pos(Vector2f.new(centerX, centerTopY), 0, Vector2f.new(0.5, 0.5))
            imgui.set_next_window_size(Vector2f.new(windowWidth, windowHeight), 0)
            WindowInitialized = true
        end

        ShowTeleportWindow = imgui.begin_window("Teleportation", true, 0)
        imgui.indent(10)
        imgui.spacing()
        imgui.spacing()
        imgui.spacing()

        imgui.text(lblTexts[1])
        imgui.spacing()
        imgui.spacing()
        imgui.spacing()

        imgui.begin_table("1", 2, nil, Vector2f.new(325, 100), 10.0)
        imgui.table_setup_column(lblTexts[2])
        imgui.table_setup_column(lblTexts[3])
        imgui.table_headers_row()

        local count = math.min(12, #TeleportLocations)

        for index = 1, count do
            local location = TeleportLocations[index]
            local key = " F" .. tostring(index)

            imgui.table_next_column()
            if index % 2 == 0 then
                imgui.table_set_bg_color(1, 0xFF262727, 1)
            end
            imgui.spacing()
            imgui.text(key)
            imgui.spacing()

            imgui.table_next_column()
            if index % 2 == 0 then
                imgui.table_set_bg_color(1, 0xFF262727, 1)
            end
            imgui.spacing()
            --imgui.text(location.name)
			if Config.Language == "zh_TW" then
				imgui.text(location.name_zh_TW)
			elseif Config.Language == "zh_CN" then
				imgui.text(location.name_zh_CN)
			else
				imgui.text(location.name_EN)
			end
            imgui.spacing()
        end

        imgui.table_next_column()
        imgui.spacing()

        local windowKey = " " .. tostring(Config.Hotkeys["Teleport Window Key"])
        imgui.text(windowKey)
        imgui.spacing()

        imgui.table_next_column()
        imgui.spacing()
        imgui.text(lblTexts[4])
        imgui.spacing()

        imgui.end_table()

        if Config.Language == "zh_TW" or Config.Language == "zt_CN" then imgui.pop_font() end

        imgui.end_window()
    end
end)

re.on_draw_ui(function ()
    if imgui.tree_node("Teleportation") then
        imgui.spacing()
		
		local langChanged, SelectedLanguageIndex = imgui.combo("Language", SelectedLanguageIndex, Languages)

        if langChanged then
            update_language_labels()
            Config.Language = Languages[SelectedBonusLocationIndex]
            save_config()
        end

        if Config.Language == "zh_TW"  then imgui.push_font(font_zh_TW) end
        if Config.Language == "zh_CN"  then imgui.push_font(font_zh_CN) end
		
        imgui.spacing()
		
        imgui.text(lblTexts[5])
        imgui.push_item_width(190)

        _, SelectedLocationIndex = imgui.combo(" ", SelectedLocationIndex, LocationNames)

        imgui.same_line()
        if imgui.button(lblTexts[6]) then
            local location

            if SelectedLocationIndex <= #TeleportLocations then
                location = TeleportLocations[SelectedLocationIndex]
            else
                location = Config.CustomTeleportLocations[SelectedLocationIndex - #TeleportLocations]
            end

            teleport(location.position)
        end

        imgui.spacing()
        imgui.spacing()

        imgui.text(lblTexts[7])
        imgui.push_item_width(190)
        _, NewLocationName = imgui.input_text(nil, NewLocationName, 256)
        imgui.same_line()
        imgui.spacing()
        imgui.same_line()
        if imgui.button(lblTexts[8]) and NewLocationName ~= "" then
            add_custom_location(NewLocationName)
            update_location_names()
            save_config()
            NewLocationName = nil
        end

        imgui.spacing()
        imgui.spacing()

        if imgui.tree_node(lblTexts[9]) then
            imgui.spacing()
            imgui.spacing()

            imgui.push_item_width(190)
            _, SelectedBonusLocationIndex = imgui.combo(" ", SelectedBonusLocationIndex, BonusLocationNames)
    
            imgui.same_line()
            if imgui.button(lblTexts[6]) then
                teleport(BonusLocations[SelectedBonusLocationIndex].position)
            end

            imgui.spacing()
            imgui.tree_pop()
        end

        imgui.spacing()
        imgui.spacing()

        if imgui.tree_node(lblTexts[10]) then
            imgui.spacing()
            imgui.spacing()
			
			if not(Config.Language == "EN")  then
				imgui.text(lblTexts[11])
			end
            local hotkeyChanged = Hotkeys.hotkey_setter("Teleport Window Key")
            if hotkeyChanged then
                Hotkeys.update_hotkey_table(Config.Hotkeys)
                save_config()
            end

            imgui.spacing()
            imgui.spacing()
            local windowOpenChanged, windowOpenValue = imgui.checkbox(lblTexts[12], Config.RequireTeleportWindowOpen)
            if windowOpenChanged then
                Config.RequireTeleportWindowOpen = windowOpenValue
                save_config()
            end

            imgui.spacing()
            imgui.spacing()
            imgui.spacing()
            local text = ShowTeleportWindow and lblTexts[13] or lblTexts[14]
            if imgui.button(text .. lblTexts[15]) then
                ShowTeleportWindow = not ShowTeleportWindow
            end

            imgui.spacing()
            imgui.tree_pop()
        end

        if Config.Language == "zh_TW" or Config.Language == "zt_CN" then imgui.pop_font() end

        imgui.new_line()
        imgui.tree_pop()
    end
end)
