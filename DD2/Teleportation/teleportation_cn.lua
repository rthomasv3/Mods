local re = re
local sdk = sdk
local imgui = imgui
local log = log
local json = json
local Vector2f = Vector2f

local Hotkeys = require("Hotkeys/Hotkeys")

local CN_FONT_NAME = 'NotoSansJP-Regular.otf'

local CN_FONT_SIZE = 18
local CJK_GLYPH_RANGES = {
    0x0020, 0x00FF, -- Basic Latin + Latin Supplement
    0x2000, 0x206F, -- General Punctuation
    0x3000, 0x30FF, -- CJK Symbols and Punctuations, Hiragana, Katakana
    0x31F0, 0x31FF, -- Katakana Phonetic Extensions
    0xFF00, 0xFFEF, -- Half-width characters
    0x4e00, 0x9FAF, -- CJK Ideograms
    0
}

local FontCN = imgui.load_font(CN_FONT_NAME, CN_FONT_SIZE, CJK_GLYPH_RANGES)

local FerrystoneController = sdk.get_managed_singleton("app.FerrystoneFlowController")
-- local ItemManager = sdk.get_managed_singleton("app.ItemManager")
local CharacterManager = sdk.get_managed_singleton("app.CharacterManager")

local ConfigFilePath = "rthomasv3\\teleportation_config.json"

local ShowTeleportWindow = false
local SelectedLocationIndex = 1
local SelectedBonusLocationIndex = 1
local WindowInitialized = false
local WriteInfoLogs = false
local RequireTeleportWindowOpen = true
local PreventFerrystoneUsage = false

local LocationNames = {}
local BonusLocationNames = {}
local NewLocationName = nil

local TeleportLocations = {
    { name = "巴克巴塔爾",      position = "-1370.932, 108.404, 386.952" },
    { name = "國境監視團營地",  position = "360.551, 202.090, -2523.438" },
    { name = "關口旅宿之鎮",    position = "-1925.309, 236.477, -917.067" },
    { name = "龍鐵匠",          position = "-1024.074, -0.826, -229.069" },
    { name = "艾妮的家",        position = "161.006, 247.738, -2779.449" },
    { name = "挖掘場",          position = "319.194, 101.405, 1283.226" },
    { name = "哈波村",          position = "-403.743, 2.830, -719.719" },
    { name = "梅爾威",          position = "140.602, 153.463, -2121.792" },
    { name = "無名村",          position = "1591.937, 35.921, -1371.444" },
    { name = "聖樹之村",        position = "-503.591, 125.331, -2196.583" },
    { name = "火山島營地",      position = "-258.599, 28.778, 1104.794" },
    { name = "菲倫瓦思",        position = "472.869, 27.787, -1043.214" },
}

local BonusLocations = {
    { name = "食龍塔",         position = "-2139.95,254.651,1036.64" },
    { name = "邊境神殿",       position = "-2382.91,272.15,-678.725" },
    { name = "山岳神殿",       position = "-1242.96,193.368,-1654.86" },
    { name = "雷拉巴塔爾風穴", position = "-1980.15,74.0373,845.271" },
    { name = "清風之家",       position = "-977.074,15.142,1121.04" },
    { name = "探求之證 1",     position = "1511.327, 72.29001, -1454.527" },
    { name = "探求之證 2",     position = "-1182.551, 83.09478, -972.6376" },
    { name = "探求之證 3",     position = "380.501, 50.62649, -1409.562" },
    { name = "探求之證 4",     position = "-1348.226, 124.496, -945.648" },
    { name = "探求之證 5",     position = "1444.965, 37.94048, -1504.567" },
    { name = "探求之證 6",     position = "-708.2896, 30.65974, 1312.785" },
    { name = "探求之證 7",     position = "-1836.352, 99.18828, -257.8879" },
    { name = "探求之證 8",     position = "-2323.327, 58.20417, 328.1359" },
    { name = "探求之證 9",     position = "-997.5818, 99.78221, -1169.883" },
    { name = "探求之證 10",    position = "-208.7119, 75.84951, -1270.892" },
    { name = "探求之證 11",    position = "-1877.725, 70.39024, 215.3207" },
    { name = "探求之證 12",    position = "1253.95, 93.48993, -1971.472" },
    { name = "探求之證 13",    position = "-151.6821, 54.35305, -1577.464" },
    { name = "探求之證 14",    position = "-421.618, 40.72049, -1217.373" },
    { name = "探求之證 15",    position = "-425.1481, 31.82341, -1511.35" },
    { name = "探求之證 16",    position = "-726.9548, 15.69018, -1057.383" },
    { name = "探求之證 17",    position = "-1844.405, 49.34726, 53.74813" },
    { name = "探求之證 18",    position = "-1175.155, 115.4653, -1422.364" },
    { name = "探求之證 19",    position = "-1425.139, 136.3351, 322.1707" },
    { name = "探求之證 20",    position = "-954.4528, 59.04977, -1495.011" },
    { name = "探求之證 21",    position = "-128.7886, 101.7482, -2144.956" },
    { name = "探求之證 22",    position = "-562.379, 105.0297, -1933.341" },
    { name = "探求之證 23",    position = "-1700.205, 220.8857, -1115.413" },
    { name = "探求之證 24",    position = "-1627.802, 162.3504, -1446.844" },
    { name = "探求之證 25",    position = "-114.8202, 30.86584, -1187.828" },
    { name = "探求之證 26",    position = "-1864.822, 82.608, 400.1776" },
    { name = "探求之證 27",    position = "-1754.728, 205.8057, -927.3947" },
    { name = "探求之證 28",    position = "-1388.847, 83.21184, 230.7781" },
    { name = "探求之證 29",    position = "-143.9213, 97.7899, -1969.956" },
    { name = "探求之證 30",    position = "333.059, 236.0416, -2672.068" },
    { name = "探求之證 31",    position = "-588.8615, 51.29575, -1191.052" },
    { name = "探求之證 32",    position = "-351.0987, 72.58118, -1797.945" },
    { name = "探求之證 33",    position = "-1969.172, 42.60961, 569.0708" },
    { name = "探求之證 34",    position = "-74.45094, 28.65137, -1228.852" },
    { name = "探求之證 35",    position = "-461.6025, 88.31136, 1461.9" },
    { name = "探求之證 36",    position = "1427.493, 35.8315, -1567.728" },
    { name = "探求之證 37",    position = "1241.345, 171.7751, -2249.933" },
    { name = "探求之證 38",    position = "-868.9569, 15.14516, 902.671" },
    { name = "探求之證 39",    position = "-562.1972, 27.44761, -1582.972" },
    { name = "探求之證 40",    position = "-1983.061, 264.5901, -890.088" },
    { name = "探求之證 41",    position = "-1473.602, 158.7904, -1017.371" },
    { name = "探求之證 42",    position = "576.5875, 28.66201, -1301.384" },
    { name = "探求之證 43",    position = "1301.607, 0.6638163, -1370.327" },
    { name = "探求之證 44",    position = "-1037.706, 61.63612, -1543.092" },
    { name = "探求之證 45",    position = "-2290.82, 113.6292, -406.696" },
    { name = "探求之證 46",    position = "1158.227, 3.896768, -1204.033" },
    { name = "探求之證 47",    position = "67.42051, 142.9019, -2126.103" },
    { name = "探求之證 48",    position = "-2275.997, 71.59417, -392.5833" },
    { name = "探求之證 49",    position = "-537.8214, 8.304099, 1173.693" },
    { name = "探求之證 50",    position = "-2045.45, 244.2061, -653.381" },
    { name = "探求之證 51",    position = "-1624.109, 69.67034, 1044.009" },
    { name = "探求之證 52",    position = "-1154.636, 99.41915, -1496.902" },
    { name = "探求之證 53",    position = "368.6974, 192.1294, -2312.887" },
    { name = "探求之證 54",    position = "966.6755, 68.71934, -1654.37" },
    { name = "探求之證 55",    position = "-531.8324, 140.7443, -2164.448" },
    { name = "探求之證 56",    position = "-2231.03, 282.9688, -817.4234" },
    { name = "探求之證 57",    position = "-731.689, 24.34222, -1557.463" },
    { name = "探求之證 58",    position = "-1800.555, 70.33961, 381.2898" },
    { name = "探求之證 59",    position = "-669.8233, 5.020011, -940.93" },
    { name = "探求之證 60",    position = "-452.4744, 94.03584, -1944.387" },
    { name = "探求之證 61",    position = "-2073.348, 87.33474, 13.64392" },
    { name = "探求之證 62",    position = "-1264.083, 103.8367, -1354.126" },
    { name = "探求之證 63",    position = "-2058.721, 57.39219, 513.1974" },
    { name = "探求之證 64",    position = "-443.0493, 42.20091, -663.1949" },
    { name = "探求之證 65",    position = "-239.6361, 8.631701, -838.8901" },
    { name = "探求之證 66",    position = "878.4819, 10.14215, -1337.172" },
    { name = "探求之證 67",    position = "-27.64818, 0.6451912, -998.9725" },
    { name = "探求之證 68",    position = "1085.92, 61.37453, -1263.965" },
    { name = "探求之證 69",    position = "505.3856, 63.05507, -907.8718" },
    { name = "探求之證 70",    position = "-2209.501, 67.62506, 502.0663" },
    { name = "探求之證 71",    position = "-1169.348, 114.5239, -1078.889" },
    { name = "探求之證 72",    position = "-1744.333, 67.46979, 256.7256" },
    { name = "探求之證 73",    position = "396.9378, 85.66324, -820.0371" },
    { name = "探求之證 74",    position = "-2239.501, 290.0148, 1015.552" },
    { name = "探求之證 75",    position = "-1063.11, 136.2313, 416.3393" },
    { name = "探求之證 76",    position = "1133.997, 190.9401, -2244.319" },
    { name = "探求之證 77",    position = "1164.265, 46.84266, -1690.47" },
    { name = "探求之證 78",    position = "879.8962, 193.0155, -2363.888" },
    { name = "探求之證 79",    position = "-1957.176, 90.54247, -293.5216" },
    { name = "探求之證 80",    position = "-321.8596, 62.14732, 861.4832" },
    { name = "探求之證 81",    position = "100.7216, 179.9064, -2105.341" },
    { name = "探求之證 82",    position = "-2357.598, 83.993, -196.4987" },
    { name = "探求之證 83",    position = "-2226.387, 130.6572, -345.0266" },
    { name = "探求之證 84",    position = "-24.78811, 9.76271, -1184.259" },
    { name = "探求之證 85",    position = "991.0721, 75.88528, -1753.271" },
    { name = "探求之證 86",    position = "-957.5068, 43.63776, -1013.708" },
    { name = "探求之證 87",    position = "-1810.451, 37.58649, 857.5712" },
    { name = "探求之證 88",    position = "-2052.696, 158.5537, 966.871" },
    { name = "探求之證 89",    position = "-1143.138, 87.47182, -1574.525" },
    { name = "探求之證 90",    position = "196.2978, 167.8351, -2355.079" },
    { name = "探求之證 91",    position = "-1412.043, 157, 334.4911" },
    { name = "探求之證 92",    position = "-1669.654, 50.81789, 966.7512" },
    { name = "探求之證 93",    position = "-2000.453, 83.90808, -85.11404" },
    { name = "探求之證 94",    position = "-2288.28, 61.76313, 160.2155" },
    { name = "探求之證 95",    position = "-1744.999, 52.29864, 729.0167" },
    { name = "探求之證 96",    position = "1213.163, 7.444563, -1307.155" },
    { name = "探求之證 97",    position = "1451.397, 30.69706, -1425.217" },
    { name = "探求之證 98",    position = "1246.022, 85.96709, -1719.665" },
    { name = "探求之證 99",    position = "-377.4244, 25.65013, 1072.151" },
    { name = "探求之證 100",   position = "-362.2318, 27.21784, 1137.943" },
    { name = "探求之證 101",   position = "-311.1265, 46.33576, -1172.065" },
    { name = "探求之證 102",   position = "-1863.659, 53.75474, 564.1379" },
    { name = "探求之證 103",   position = "87.88998, 275.9138, -2699.498" },
    { name = "探求之證 104",   position = "497.4532, 66.13264, -931.752" },
    { name = "探求之證 105",   position = "-1947.701, 106.3777, -142.9371" },
    { name = "探求之證 106",   position = "-1992.826, 211.1146, -553.046" },
    { name = "探求之證 107",   position = "-1916.496, 243.5359, -897.6821" },
    { name = "探求之證 108",   position = "-413.092, 100.2532, -1961.737" },
    { name = "探求之證 109",   position = "-2087.02, 41.7835, 196.835" },
    { name = "探求之證 110",   position = "155.5486, 85.44305, 1108.05" },
    { name = "探求之證 111",   position = "-215.3959, 39.77499, -1228.676" },
    { name = "探求之證 112",   position = "406.3369, 45.64609, -978.3323" },
    { name = "探求之證 113",   position = "-662.3477, 22.74153, -1335.208" },
    { name = "探求之證 114",   position = "-471.8372, 30.35632, 1167.059" },
    { name = "探求之證 115",   position = "-985.4307, 48.5821, -302.3444" },
    { name = "探求之證 116",   position = "-691.2465, 17.03014, 674.2273" },
    { name = "探求之證 117",   position = "44.64841, 148.8826, -2307.236" },
    { name = "探求之證 118",   position = "-2050.989, 114.8949, -383.0466" },
    { name = "探求之證 119",   position = "-1410.486, 144.7303, -1389.202" },
    { name = "探求之證 120",   position = "-1040.184, 0.4392352, 1258.829" },
    { name = "探求之證 121",   position = "-452.9087, 0.796546, 741.597" },
    { name = "探求之證 122",   position = "334.2993, 100.3809, 1323.854" },
    { name = "探求之證 123",   position = "-1558.879, 85.9902, 429.7581" },
    { name = "探求之證 124",   position = "1253.134, 67.67858, -1870.294" },
    { name = "探求之證 125",   position = "-2175.953, 75.2403, 513.1131" },
    { name = "探求之證 126",   position = "486.8091, 24.38745, -1054.205" },
    { name = "探求之證 127",   position = "-1145.974, 46.43586, -255.1327" },
    { name = "探求之證 128",   position = "802.7636, 10.00694, -1275.782" },
    { name = "探求之證 129",   position = "-257.8826, 50.04342, 769.1068" },
    { name = "探求之證 130",   position = "-256.1795, 29.35168, 1128.872" },
    { name = "探求之證 131",   position = "-29.33716, 164.9512, -2487.574" },
    { name = "探求之證 132",   position = "-2438.648, 297.7558, -729.283" },
    { name = "探求之證 133",   position = "-1735.35, 67.04755, 604.192" },
    { name = "探求之證 134",   position = "-2437.834, 75.30431, -279.8528" },
    { name = "探求之證 135",   position = "-1467.244, 167.842, -972.6749" },
    { name = "探求之證 136",   position = "-1144.316, 59.95095, -37.65364" },
    { name = "探求之證 137",   position = "-2205.891, 37.86744, 416.3837" },
    { name = "探求之證 138",   position = "-1325.521, 153.6144, 318.1047" },
    { name = "探求之證 139",   position = "-1726.722, 96.89873, 19.04225" },
    { name = "探求之證 140",   position = "-1455.78, 107.9478, 276.0348" },
    { name = "探求之證 141",   position = "14.76145, 190.1257, -2412.495" },
    { name = "探求之證 142",   position = "-2081.739, 81.17527, -169.5074" },
    { name = "探求之證 143",   position = "-2195.761, 82.26016, -148.4175" },
    { name = "探求之證 144",   position = "509.7451, 20.81026, -1124.374" },
    { name = "探求之證 145",   position = "-1128.958, 78.22768, 389.9597" },
    { name = "探求之證 146",   position = "378.7181, 44.0754, -1047.653" },
    { name = "探求之證 147",   position = "1094.016, 61.32773, -1263.995" },
    { name = "探求之證 148",   position = "-1059.732, 80.43699, 239.3768" },
    { name = "探求之證 149",   position = "-300.6327, 22.67523, -1187.099" },
    { name = "探求之證 150",   position = "-2117.376, 223.6917, 1044.149" },
    { name = "探求之證 151",   position = "-2096.548, 143.9485, 897.7155" },
    { name = "探求之證 152",   position = "-1017.941, 26.8972, 160.796" },
    { name = "探求之證 153",   position = "-1190.294, 102.4365, 319.5692" },
    { name = "探求之證 154",   position = "889.1685, 20.1433, -1190.647" },
    { name = "探求之證 155",   position = "-930.7362, 37.33437, -730.5226" },
    { name = "探求之證 156",   position = "81.20549, 69.3, -1748.368" },
    { name = "探求之證 157",   position = "928.5052, 240.082, -2586.659" },
    { name = "探求之證 158",   position = "1074.255, 49.43904, -1615.228" },
    { name = "探求之證 159",   position = "-1385.482, 110.7523, -1279.451" },
    { name = "探求之證 160",   position = "-175.3369, 75.17094, -1411.751" },
    { name = "探求之證 161",   position = "-1893.107, 35.35776, 756.4501" },
    { name = "探求之證 162",   position = "-489.7266, 18.02133, -1064.699" },
    { name = "探求之證 163",   position = "1215.604, 76.60162, -1907.77" },
    { name = "探求之證 164",   position = "-1623.225, 86.3857, 291.1531" },
    { name = "探求之證 165",   position = "371.4242, 78.0455, -881.5969" },
    { name = "探求之證 166",   position = "-1547.166, 69.55149, 1078.691" },
    { name = "探求之證 167",   position = "923.5192, 195.4502, -2313.818" },
    { name = "探求之證 168",   position = "-593.5593, 50.08264, -1789.409" },
    { name = "探求之證 169",   position = "-967.5819, 13.6438, -234.7076" },
    { name = "探求之證 170",   position = "-554.0727, 35.60732, -1033.871" },
    { name = "探求之證 171",   position = "-1707.572, 85.18982, 114.9935" },
    { name = "探求之證 172",   position = "-1307.999, 148.0497, -1420.194" },
    { name = "探求之證 173",   position = "-1058.136, 97.33194, 400.906" },
    { name = "探求之證 174",   position = "1284.713, 29.37333, -1253.282" },
    { name = "探求之證 175",   position = "-1737.472, 191.269, -1190.988" },
    { name = "探求之證 176",   position = "-2144.98, 237.7022, 931.1352" },
    { name = "探求之證 177",   position = "-744.014, 37.91385, -1269.364" },
    { name = "探求之證 178",   position = "-2206.928, 76.91254, 370.2791" },
    { name = "探求之證 179",   position = "824.2649, 231.7646, -2651.551" },
    { name = "探求之證 180",   position = "-460.4371, 21.96133, -868.7405" },
    { name = "探求之證 181",   position = "530.9937, -1.72881, -949.6918" },
    { name = "探求之證 182",   position = "459.0298, 76.78581, -719.246" },
    { name = "探求之證 183",   position = "-1907.512, 194.0277, -539.9005" },
    { name = "探求之證 184",   position = "310.7063, 2.663232, -1093.182" },
    { name = "探求之證 185",   position = "-2090.685, 87.91904, -252.9724" },
    { name = "探求之證 186",   position = "-1545.581, 168.1623, -1526.813" },
    { name = "探求之證 187",   position = "-900.6052, -0.4724793, -41.89881" },
    { name = "探求之證 188",   position = "1188.915, 38.70578, -1399.902" },
    { name = "探求之證 189",   position = "-1592.083, 166.3117, -1439.994" },
    { name = "探求之證 190",   position = "59.92789, 221.4001, -2591.599" },
    { name = "探求之證 191",   position = "17.31717, 95.44806, -2068.056" },
    { name = "探求之證 192",   position = "1294.648, 32.48453, -1162.289" },
    { name = "探求之證 193",   position = "-988.0832, 29.20226, 1193.494" },
    { name = "探求之證 194",   position = "1087.994, 42.86492, -1509.454" },
    { name = "探求之證 195",   position = "390.7802, 24.44314, -1063.17" },
    { name = "探求之證 196",   position = "334.6868, 206.1537, -2521.229" },
    { name = "探求之證 197",   position = "1180.006, 65.77381, -1937.357" },
    { name = "探求之證 198",   position = "-892.7271, 29.77627, -720.5415" },
    { name = "探求之證 199",   position = "542.3516, 15.91502, -1215.642" },
    { name = "探求之證 200",   position = "1506.107, 28.23366, -1357.404" },
    { name = "探求之證 201",   position = "-2200.933, 296.0031, 1054.443" },
    { name = "探求之證 202",   position = "458.9755, 46.67035, -1029.605" },
    { name = "探求之證 203",   position = "-1860.29, 85.47575, -437.5429" },
    { name = "探求之證 204",   position = "-1121.143, 79.09875, -1639.249" },
    { name = "探求之證 205",   position = "942.6032, -0.3656093, -1232.318" },
    { name = "探求之證 206",   position = "-477.5305, 87.42719, 1420.187" },
    { name = "探求之證 207",   position = "1091.268, 25.77886, -1428.777" },
    { name = "探求之證 208",   position = "-1820.409, 98.10882, -87.64505" },
    { name = "探求之證 209",   position = "-996.6234, 104.1155, -1290.778" },
    { name = "探求之證 210",   position = "-806.2393, 30.66521, -947.8731" },
    { name = "探求之證 211",   position = "180.126, 26.03245, -1161.688" },
    { name = "探求之證 212",   position = "-1670.075, 99.82407, -1280.521" },
    { name = "探求之證 213",   position = "-1101.613, 114.1108, 612.7404" },
    { name = "探求之證 214",   position = "512.6115, 44.41759, -960.8672" },
    { name = "探求之證 215",   position = "-597.4287, 0.2458094, -842.9684" },
    { name = "探求之證 216",   position = "1148.682, 23.13101, -1390.438" },
    { name = "探求之證 217",   position = "-1709.469, 53.84142, 1102.876" },
    { name = "探求之證 218",   position = "-2390.223, 272.1731, -619.5712" },
    { name = "探求之證 219",   position = "-546.9639, 96.17853, -1880.174" },
    { name = "探求之證 220",   position = "-2008.847, 124.2037, 945.9615" },
    { name = "探求之證 221",   position = "-2403.851, 315.0301, -879.7818" },
    { name = "探求之證 222",   position = "-313.1738, 49.01183, 1247.046" },
    { name = "探求之證 223",   position = "-492.7277, 130.1809, -2259.106" },
    { name = "探求之證 224",   position = "597.8867, 80.00896, -854.4315" },
    { name = "探求之證 225",   position = "-1346.704, 120.433, 398.7322" },
    { name = "探求之證 226",   position = "-1941.606, 77.46495, -340.7309" },
    { name = "探求之證 227",   position = "-804.2957, 44.27563, -1351.228" },
    { name = "探求之證 228",   position = "-347.2373, 53,32834, -884.2132" },
    { name = "探求之證 229",   position = "1564.457, 62.45671, -1439.98" },
    { name = "探求之證 230",   position = "-1787.815, 48.46006, 669.9354" },
    { name = "探求之證 231",   position = "-661.7025, 38.82969, -1069.028" },
    { name = "探求之證 232",   position = "-1101.07, 98.0107, -1134.8" },
    { name = "探求之證 233",   position = "888.7634, 0.3689132, -1230.208" },
    { name = "探求之證 234",   position = "-939.8016, 67.41076, -1248.607" },
    { name = "探求之證 235",   position = "-1929.849, 179.5838, -1146.239" },
    { name = "探求之證 236",   position = "1055.01, 50.11625, -1245.982" },
    { name = "探求之證 237",   position = "-2454.656, 158.9566, -551.7483" },
    { name = "探求之證 238",   position = "-759.3116, 16.65483, 1249.993" },
    { name = "探求之證 239",   position = "494.4174, 14.7665, -1284.163" },
    { name = "探求之證 240",   position = "-381.5288, 8.838051, -827.5795" },
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

local Config = {
    RequireTeleportWindowOpen = RequireTeleportWindowOpen,
    CustomTeleportLocations = {},
    Hotkeys = DefaultHotkeys
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
        table.insert(LocationNames, location.name)
    end

    for _, location in ipairs(Config.CustomTeleportLocations) do
        table.insert(LocationNames, location.name)
    end
end

-- Only need to load bonus locations once
for _, location in ipairs(BonusLocations) do
    table.insert(BonusLocationNames, location.name)
end

load_config()

Hotkeys.setup_hotkeys(Config.Hotkeys, DefaultHotkeys)

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

        imgui.push_font(FontCN)

        imgui.text("按下快捷鍵以傳送到指定位置。")
        imgui.spacing()
        imgui.spacing()
        imgui.spacing()

        imgui.begin_table("1", 2, nil, Vector2f.new(325, 100), 10.0)
        imgui.table_setup_column("快捷鍵")
        imgui.table_setup_column("位置")
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
            imgui.text(location.name)
            imgui.spacing()
        end

        imgui.table_next_column()
        imgui.spacing()
        local windowKey = " " .. tostring(Config.Hotkeys["Teleport Window Key"])
        imgui.text(windowKey)
        imgui.spacing()

        imgui.table_next_column()
        imgui.spacing()
        imgui.text("顯示此視窗")
        imgui.spacing()

        imgui.end_table()

		imgui.pop_font()
        imgui.end_window()
    end
end)

re.on_draw_ui(function ()
    if imgui.tree_node("Teleportation") then
        imgui.push_font(FontCN)
        imgui.spacing()

        imgui.text("位置")
        imgui.push_item_width(190)

        _, SelectedLocationIndex = imgui.combo(" ", SelectedLocationIndex, LocationNames)

        imgui.same_line()
        if imgui.button(" 傳送 ") then
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

        imgui.text("名稱")
        imgui.push_item_width(190)
        _, NewLocationName = imgui.input_text(nil, NewLocationName, 256)
        imgui.same_line()
        imgui.spacing()
        imgui.same_line()
        if imgui.button("加入此位置") and NewLocationName ~= "" then
            add_custom_location(NewLocationName)
            update_location_names()
            save_config()
            NewLocationName = nil
        end

        imgui.spacing()
        imgui.spacing()

        if imgui.tree_node("更多位置") then
            imgui.spacing()
            imgui.spacing()

            imgui.push_item_width(190)
            _, SelectedBonusLocationIndex = imgui.combo(" ", SelectedBonusLocationIndex, BonusLocationNames)
    
            imgui.same_line()
            if imgui.button(" 傳送 ") then
                teleport(BonusLocations[SelectedBonusLocationIndex].position)
            end

            imgui.spacing()
            imgui.tree_pop()
        end

        imgui.spacing()
        imgui.spacing()

        if imgui.tree_node("快捷鍵設定") then
            imgui.spacing()
            imgui.spacing()

            imgui.text("傳送視窗快捷鍵")
            local hotkeyChanged = Hotkeys.hotkey_setter("Teleport Window Key")
            if hotkeyChanged then
                Hotkeys.update_hotkey_table(Config.Hotkeys)
                save_config()
            end

            imgui.spacing()
            imgui.spacing()
            local windowOpenChanged, windowOpenValue = imgui.checkbox("傳送時要求開啓視窗", Config.RequireTeleportWindowOpen)
            if windowOpenChanged then
                Config.RequireTeleportWindowOpen = windowOpenValue
                save_config()
            end

            imgui.spacing()
            imgui.spacing()
            imgui.spacing()
            local text = ShowTeleportWindow and "隱藏 " or "顯示 "
            if imgui.button(text .. "快捷鍵視窗") then
                ShowTeleportWindow = not ShowTeleportWindow
            end

            imgui.spacing()
            imgui.tree_pop()
        end

        imgui.new_line()
		imgui.pop_font()
        imgui.tree_pop()
    end
end)
