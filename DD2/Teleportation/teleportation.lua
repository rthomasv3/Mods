local re = re
local sdk = sdk
local imgui = imgui
local log = log
local json = json
local Vector2f = Vector2f

local Hotkeys = require("Hotkeys/Hotkeys")

local FerrystoneController = sdk.get_managed_singleton("app.FerrystoneFlowController")
local CharacterManager = sdk.get_managed_singleton("app.CharacterManager")

local ConfigFilePath = "rthomasv3\\teleportation_config.json"

local ShowTeleportWindow = false
local SelectedLanguageIndex = 1
local SelectedLocationIndex = 1
local SelectedBonusLocationIndex = 1
local SelectedCustomLocationIndex = 1
local WindowInitialized = false
local WriteInfoLogs = false
local RequireTeleportWindowOpen = true
local PreventFerrystoneUsage = false
local LoadBeetleLocations = true
local LoadSeekerLocations = true
local Language = "EN"

local LocationNames = {}
local BonusLocationNames = {}
local CustomLocationNames = {}
local BonusLocationPositions = {}
local NewLocationName = nil

local TeleportLocations = {
    { name = "Bakbattahl",           position = "-1370.932, 108.404, 386.952" },
    { name = "Borderwatch Outpost",  position = "360.551, 202.090, -2523.438" },
    { name = "Checkpoint Rest Town", position = "-1925.309, 236.477, -917.067" },
    { name = "Dragonforged",         position = "-1024.074, -0.826, -229.069" },
    { name = "Eini's Home",          position = "161.006, 247.738, -2779.449" },
    { name = "Excavation Site",      position = "319.194, 101.405, 1283.226" },
    { name = "Harve Village",        position = "-403.743, 2.830, -719.719" },
    { name = "Melve",                position = "140.602, 153.463, -2121.792" },
    { name = "Nameless Village",     position = "1591.937, 35.921, -1371.444" },
    { name = "Sacred Arbor",         position = "-503.591, 125.331, -2196.583" },
    { name = "Volcanic Island Camp", position = "-258.599, 28.778, 1104.794" },
    { name = "Vernworth",            position = "472.869, 27.787, -1043.214" },
}

local BonusLocations = {
    { name = "Ancient Ruins",                    position = "-1433.19,94.7102,-1304.27" },
    { name = "Dragonsbreath Tower",              position = "-2139.95,254.651,1036.64" },
    { name = "Frontier Shrine (Sphinx)",         position = "-2382.91,272.15,-678.725" },
    { name = "Mountain Shrine (Sphinx)",         position = "-1242.96,193.368,-1654.86" },
    { name = "Moonglint Tower 3F",               position = "323.271,530.557,1667.2" },
    { name = "Nera'Battahl Windrift (Medusa)",   position = "-1980.15,74.0373,845.271" },
    { name = "Reverent Shrine",                  position = "-1847.94,82.5907,-256.025" },
	{ name = "Seafloor Shrine - Sacred Grounds", position = "-483.634,-16.3329,-255.672" },
    { name = "Windwalker's Home",                position = "-977.074,15.142,1121.04" },
}

local BeetleLocations = {
    { name = "Golden Trove Beetle 1",            position = "127.463608, 26.4215832, -1462.31458" },
    { name = "Golden Trove Beetle 2",            position = "-1822.886, 86.14401, -301.010254" },
    { name = "Golden Trove Beetle 3",            position = "-873.5627, 57.07011, -1046.872" },
    { name = "Golden Trove Beetle 4",            position = "-383.864868, 21.204277, 1104.48621" },
    { name = "Golden Trove Beetle 5",            position = "-384.605438, 51.1824875, -1605.39111" },
    { name = "Golden Trove Beetle 6",            position = "-1402.08411, 96.92353, -1291.90881" },
    { name = "Golden Trove Beetle 7",            position = "-2472.712, 288.0979, -742.2973" },
    { name = "Golden Trove Beetle 8",            position = "1408.631, 2.22223854, -1249.7522" },
    { name = "Golden Trove Beetle 9",            position = "550.371643, 219.236008, -2504.25317" },
    { name = "Golden Trove Beetle 10",           position = "-495.9517, 84.0051, -1933.951" },
    { name = "Golden Trove Beetle 11",           position = "8.803507, 17.1846867, -1126.4165" },
    { name = "Golden Trove Beetle 12",           position = "-1726.75244, 25.66582, 1068.63916" },
    { name = "Golden Trove Beetle 13",           position = "1245.04749, 6.52237, -1391.365" },
    { name = "Golden Trove Beetle 14",           position = "-1887.488, 49.83932, 101.6016" },
    { name = "Golden Trove Beetle 15",           position = "723.205566, 20.6012135, -1387.82068" },
    { name = "Golden Trove Beetle 16",           position = "-1181.8999, 102.652191, -1081.63452" },
    { name = "Golden Trove Beetle 17",           position = "-443.254761, 4.732752, -728.690063" },
    { name = "Golden Trove Beetle 18",           position = "37.8479, 60.0003777, -1673.22388" },
    { name = "Golden Trove Beetle 19",           position = "-573.40094, 23.7682343, -1083.415" },
    { name = "Golden Trove Beetle 20",           position = "-1088.56287, 75.71896, -1450.20984" },
    { name = "Golden Trove Beetle 21",           position = "-205.728012, 99.44869, -2015.62781" },
    { name = "Golden Trove Beetle 22",           position = "1256.87146, 47.8308029, -1631.99084" },
    { name = "Golden Trove Beetle 23",           position = "-248.012833, 65.53823, -1697.99963" },
    { name = "Golden Trove Beetle 24",           position = "-795.0527, 9.06031, 1247.12585" },
    { name = "Golden Trove Beetle 25",           position = "1004.19751, 61.7079048, -1771.04822" },
    { name = "Golden Trove Beetle 26",           position = "-1913.9917, 60.51098, 361.513916" },
    { name = "Golden Trove Beetle 27",           position = "-1787.036, 42.84941, 863.6902" },
    { name = "Golden Trove Beetle 28",           position = "-2041.52832, 242.308044, -663.1417" },
    { name = "Golden Trove Beetle 29",           position = "-339.9539, 38.07144, -856.5341" },
    { name = "Golden Trove Beetle 30",           position = "919.0245, 53.7597923, -1562.05774" },
    { name = "Golden Trove Beetle 31",           position = "-1936.0697, 40.1504745, 155.911118" },
    { name = "Golden Trove Beetle 32",           position = "-2121.29321, 31.39778, 446.759216" },
    { name = "Golden Trove Beetle 33",           position = "-1593.50732, 78.8637, 311.620117" },
    { name = "Golden Trove Beetle 34",           position = "-1102.78638, 98.57493, -1126.38879" },
    { name = "Golden Trove Beetle 35",           position = "1054.48059, 33.84521, -1466.98914" },
    { name = "Golden Trove Beetle 36",           position = "-2237.23853, 76.76702, 433.040222" },
    { name = "Golden Trove Beetle 37",           position = "-1885.09106, 234.881561, -974.5075" },
    { name = "Golden Trove Beetle 38",           position = "109.991714, 156.226349, -2307.48315" },
    { name = "Golden Trove Beetle 39",           position = "-942.688965, 38.306118, -922.445251" },
    { name = "Golden Trove Beetle 40",           position = "1327.89075, 165.974976, -2188.787" },
    { name = "Golden Trove Beetle 41",           position = "903.6399, 27.60398, -1389.276" },
    { name = "Golden Trove Beetle 42",           position = "-1060.6698, 16.8385487, -49.3175" },
    { name = "Golden Trove Beetle 43",           position = "-2209.286, 275.5489, -867.3634" },
    { name = "Golden Trove Beetle 44",           position = "1225.46167, 140.3045, -2007.863" },
    { name = "Golden Trove Beetle 45",           position = "-665.6786, 34.9326, -1377.918" },
    { name = "Golden Trove Beetle 46",           position = "-405.863373, 128.037537, -2067.96777" },
    { name = "Golden Trove Beetle 47",           position = "-1096.3418, 91.804184, -903.972534" },
    { name = "Golden Trove Beetle 48",           position = "439.2124, 17.5531979, -1183.02686" },
    { name = "Golden Trove Beetle 49",           position = "-1310.99316, 125.689445, -998.266846" },
    { name = "Golden Trove Beetle 50",           position = "-2318.65479, 63.5754662, 358.164551" },
    { name = "Golden Trove Beetle 51",           position = "-142.612411, 50.2356758, -1300.16687" },
    { name = "Golden Trove Beetle 52",           position = "15.6794853, 1.43400836, -1035.19666" },
    { name = "Golden Trove Beetle 53",           position = "1308.92786, 21.444746, -1459.62134" },
    { name = "Golden Trove Beetle 54",           position = "1308.45361, 17.165966, -1270.05151" },
    { name = "Golden Trove Beetle 55",           position = "-1920.65833, 59.2007027, 889.2559" },
    { name = "Golden Trove Beetle 56",           position = "-2234.688, 110.020195, -284.347382" },
    { name = "Golden Trove Beetle 57",           position = "799.8036, 14.91647, -1248.854" },
    { name = "Golden Trove Beetle 58",           position = "112.992149, 264.453979, -2836.76" },
    { name = "Golden Trove Beetle 59",           position = "-411.402924, 18.4645958, -1103.42273" },
    { name = "Golden Trove Beetle 60",           position = "-1757.29846, 123.097694, -1248.98474" },
    { name = "Golden Trove Beetle 61",           position = "1239.47009, 77.00824, -1788.43469" },
    { name = "Golden Trove Beetle 62",           position = "-1691.31372, 41.2277679, 651.8175" },
    { name = "Golden Trove Beetle 63",           position = "-730.8379, 28.73455, -1290.00562" },
    { name = "Golden Trove Beetle 64",           position = "-1575.384, 71.08968, 1117.024" },
    { name = "Golden Trove Beetle 65",           position = "167.108047, 249.438171, -2772.60059" },
    { name = "Golden Trove Beetle 66",           position = "-2000.328, 85.731, -70.20517" },
    { name = "Golden Trove Beetle 67",           position = "-2075.2688, 178.422409, 1004.22754" },
    { name = "Golden Trove Beetle 68",           position = "21.88608, 165.3432, -2382.095" },
    { name = "Golden Trove Beetle 69",           position = "-924.598, 60.73502, -597.5295" },
    { name = "Golden Trove Beetle 70",           position = "-1703.251, 44.16369, 506.7962" },
    { name = "Golden Trove Beetle 71",           position = "-1644.61255, 207.76387, -1125.73254" },
    { name = "Golden Trove Beetle 72",           position = "-2407.76, 73.4363, -218.933411" },
    { name = "Golden Trove Beetle 73",           position = "-1848.324, 29.74838, 694.2729" },
    { name = "Golden Trove Beetle 74",           position = "874.627, 180.2334, -2324.938" },
    { name = "Golden Trove Beetle 75",           position = "-487.413269, 56.8413239, -1702.04431" },
    { name = "Golden Trove Beetle 76",           position = "941.0727, 10.761487, -1149.68616" },
    { name = "Golden Trove Beetle 77",           position = "-283.9367, 125.041756, -2092.15576" },
    { name = "Golden Trove Beetle 78",           position = "112.869659, 224.177414, -2657.095" },
}

local SeekerLocations = {
    { name = "Seeker's Token 1",                 position = "1511.327, 72.29001, -1454.527" },
    { name = "Seeker's Token 2",                 position = "-1182.551, 83.09478, -972.6376" },
    { name = "Seeker's Token 3",                 position = "380.501, 50.62649, -1409.562" },
    { name = "Seeker's Token 4",                 position = "-1348.226, 124.496, -945.648" },
    { name = "Seeker's Token 5",                 position = "1444.965, 37.94048, -1504.567" },
    { name = "Seeker's Token 6",                 position = "-708.2896, 30.65974, 1312.785" },
    { name = "Seeker's Token 7",                 position = "-1836.352, 99.18828, -257.8879" },
    { name = "Seeker's Token 8",                 position = "-2323.327, 58.20417, 328.1359" },
    { name = "Seeker's Token 9",                 position = "-997.5818, 99.78221, -1169.883" },
    { name = "Seeker's Token 10",                position = "-208.7119, 75.84951, -1270.892" },
    { name = "Seeker's Token 11",                position = "-1877.725, 70.39024, 215.3207" },
    { name = "Seeker's Token 12",                position = "1253.95, 93.48993, -1971.472" },
    { name = "Seeker's Token 13",                position = "-151.6821, 54.35305, -1577.464" },
    { name = "Seeker's Token 14",                position = "-421.618, 40.72049, -1217.373" },
    { name = "Seeker's Token 15",                position = "-425.1481, 31.82341, -1511.35" },
    { name = "Seeker's Token 16",                position = "-726.9548, 15.69018, -1057.383" },
    { name = "Seeker's Token 17",                position = "-1844.405, 49.34726, 53.74813" },
    { name = "Seeker's Token 18",                position = "-1175.155, 115.4653, -1422.364" },
    { name = "Seeker's Token 19",                position = "-1425.139, 136.3351, 322.1707" },
    { name = "Seeker's Token 20",                position = "-954.4528, 59.04977, -1495.011" },
    { name = "Seeker's Token 21",                position = "-128.7886, 101.7482, -2144.956" },
    { name = "Seeker's Token 22",                position = "-562.379, 105.0297, -1933.341" },
    { name = "Seeker's Token 23",                position = "-1700.205, 220.8857, -1115.413" },
    { name = "Seeker's Token 24",                position = "-1627.802, 162.3504, -1446.844" },
    { name = "Seeker's Token 25",                position = "-114.8202, 30.86584, -1187.828" },
    { name = "Seeker's Token 26",                position = "-1864.822, 82.608, 400.1776" },
    { name = "Seeker's Token 27",                position = "-1754.728, 205.8057, -927.3947" },
    { name = "Seeker's Token 28",                position = "-1388.847, 83.21184, 230.7781" },
    { name = "Seeker's Token 29",                position = "-143.9213, 97.7899, -1969.956" },
    { name = "Seeker's Token 30",                position = "333.059, 236.0416, -2672.068" },
    { name = "Seeker's Token 31",                position = "-588.8615, 51.29575, -1191.052" },
    { name = "Seeker's Token 32",                position = "-351.0987, 72.58118, -1797.945" },
    { name = "Seeker's Token 33",                position = "-1969.172, 42.60961, 569.0708" },
    { name = "Seeker's Token 34",                position = "-74.45094, 28.65137, -1228.852" },
    { name = "Seeker's Token 35",                position = "-461.6025, 88.31136, 1461.9" },
    { name = "Seeker's Token 36",                position = "1427.493, 35.8315, -1567.728" },
    { name = "Seeker's Token 37",                position = "1241.345, 171.7751, -2249.933" },
    { name = "Seeker's Token 38",                position = "-868.9569, 15.14516, 902.671" },
    { name = "Seeker's Token 39",                position = "-562.1972, 27.44761, -1582.972" },
    { name = "Seeker's Token 40",                position = "-1983.061, 264.5901, -890.088" },
    { name = "Seeker's Token 41",                position = "-1473.602, 158.7904, -1017.371" },
    { name = "Seeker's Token 42",                position = "576.5875, 28.66201, -1301.384" },
    { name = "Seeker's Token 43",                position = "1301.607, 0.6638163, -1370.327" },
    { name = "Seeker's Token 44",                position = "-1037.706, 61.63612, -1543.092" },
    { name = "Seeker's Token 45",                position = "-2290.82, 113.6292, -406.696" },
    { name = "Seeker's Token 46",                position = "1158.227, 3.896768, -1204.033" },
    { name = "Seeker's Token 47",                position = "67.42051, 142.9019, -2126.103" },
    { name = "Seeker's Token 48",                position = "-2275.997, 71.59417, -392.5833" },
    { name = "Seeker's Token 49",                position = "-537.8214, 8.304099, 1173.693" },
    { name = "Seeker's Token 50",                position = "-2045.45, 244.2061, -653.381" },
    { name = "Seeker's Token 51",                position = "-1624.109, 69.67034, 1044.009" },
    { name = "Seeker's Token 52",                position = "-1154.636, 99.41915, -1496.902" },
    { name = "Seeker's Token 53",                position = "368.6974, 192.1294, -2312.887" },
    { name = "Seeker's Token 54",                position = "966.6755, 68.71934, -1654.37" },
    { name = "Seeker's Token 55",                position = "-531.8324, 140.7443, -2164.448" },
    { name = "Seeker's Token 56",                position = "-2231.03, 282.9688, -817.4234" },
    { name = "Seeker's Token 57",                position = "-731.689, 24.34222, -1557.463" },
    { name = "Seeker's Token 58",                position = "-1800.555, 70.33961, 381.2898" },
    { name = "Seeker's Token 59",                position = "-669.8233, 5.020011, -940.93" },
    { name = "Seeker's Token 60",                position = "-452.4744, 94.03584, -1944.387" },
    { name = "Seeker's Token 61",                position = "-2073.348, 87.33474, 13.64392" },
    { name = "Seeker's Token 62",                position = "-1264.083, 103.8367, -1354.126" },
    { name = "Seeker's Token 63",                position = "-2058.721, 57.39219, 513.1974" },
    { name = "Seeker's Token 64",                position = "-443.0493, 42.20091, -663.1949" },
    { name = "Seeker's Token 65",                position = "-239.6361, 8.631701, -838.8901" },
    { name = "Seeker's Token 66",                position = "878.4819, 10.14215, -1337.172" },
    { name = "Seeker's Token 67",                position = "-27.64818, 0.6451912, -998.9725" },
    { name = "Seeker's Token 68",                position = "1085.92, 61.37453, -1263.965" },
    { name = "Seeker's Token 69",                position = "505.3856, 63.05507, -907.8718" },
    { name = "Seeker's Token 70",                position = "-2209.501, 67.62506, 502.0663" },
    { name = "Seeker's Token 71",                position = "-1169.348, 114.5239, -1078.889" },
    { name = "Seeker's Token 72",                position = "-1744.333, 67.46979, 256.7256" },
    { name = "Seeker's Token 73",                position = "396.9378, 85.66324, -820.0371" },
    { name = "Seeker's Token 74",                position = "-2239.501, 290.0148, 1015.552" },
    { name = "Seeker's Token 75",                position = "-1063.11, 136.2313, 416.3393" },
    { name = "Seeker's Token 76",                position = "1133.997, 190.9401, -2244.319" },
    { name = "Seeker's Token 77",                position = "1164.265, 46.84266, -1690.47" },
    { name = "Seeker's Token 78",                position = "879.8962, 193.0155, -2363.888" },
    { name = "Seeker's Token 79",                position = "-1957.176, 90.54247, -293.5216" },
    { name = "Seeker's Token 80",                position = "-321.8596, 62.14732, 861.4832" },
    { name = "Seeker's Token 81",                position = "100.7216, 179.9064, -2105.341" },
    { name = "Seeker's Token 82",                position = "-2357.598, 83.993, -196.4987" },
    { name = "Seeker's Token 83",                position = "-2226.387, 130.6572, -345.0266" },
    { name = "Seeker's Token 84",                position = "-24.78811, 9.76271, -1184.259" },
    { name = "Seeker's Token 85",                position = "991.0721, 75.88528, -1753.271" },
    { name = "Seeker's Token 86",                position = "-957.5068, 43.63776, -1013.708" },
    { name = "Seeker's Token 87",                position = "-1810.451, 37.58649, 857.5712" },
    { name = "Seeker's Token 88",                position = "-2052.696, 158.5537, 966.871" },
    { name = "Seeker's Token 89",                position = "-1143.138, 87.47182, -1574.525" },
    { name = "Seeker's Token 90",                position = "196.2978, 167.8351, -2355.079" },
    { name = "Seeker's Token 91",                position = "-1412.043, 157, 334.4911" },
    { name = "Seeker's Token 92",                position = "-1669.654, 50.81789, 966.7512" },
    { name = "Seeker's Token 93",                position = "-2000.453, 83.90808, -85.11404" },
    { name = "Seeker's Token 94",                position = "-2288.28, 61.76313, 160.2155" },
    { name = "Seeker's Token 95",                position = "-1744.999, 52.29864, 729.0167" },
    { name = "Seeker's Token 96",                position = "1213.163, 7.444563, -1307.155" },
    { name = "Seeker's Token 97",                position = "1451.397, 30.69706, -1425.217" },
    { name = "Seeker's Token 98",                position = "1246.022, 85.96709, -1719.665" },
    { name = "Seeker's Token 99",                position = "-377.4244, 25.65013, 1072.151" },
    { name = "Seeker's Token 100",               position = "-362.2318, 27.21784, 1137.943" },
    { name = "Seeker's Token 101",               position = "-311.1265, 46.33576, -1172.065" },
    { name = "Seeker's Token 102",               position = "-1863.659, 53.75474, 564.1379" },
    { name = "Seeker's Token 103",               position = "87.88998, 275.9138, -2699.498" },
    { name = "Seeker's Token 104",               position = "497.4532, 66.13264, -931.752" },
    { name = "Seeker's Token 105",               position = "-1947.701, 106.3777, -142.9371" },
    { name = "Seeker's Token 106",               position = "-1992.826, 211.1146, -553.046" },
    { name = "Seeker's Token 107",               position = "-1916.496, 243.5359, -897.6821" },
    { name = "Seeker's Token 108",               position = "-413.092, 100.2532, -1961.737" },
    { name = "Seeker's Token 109",               position = "-2087.02, 41.7835, 196.835" },
    { name = "Seeker's Token 110",               position = "155.5486, 85.44305, 1108.05" },
    { name = "Seeker's Token 111",               position = "-215.3959, 39.77499, -1228.676" },
    { name = "Seeker's Token 112",               position = "406.3369, 45.64609, -978.3323" },
    { name = "Seeker's Token 113",               position = "-662.3477, 22.74153, -1335.208" },
    { name = "Seeker's Token 114",               position = "-471.8372, 30.35632, 1167.059" },
    { name = "Seeker's Token 115",               position = "-985.4307, 48.5821, -302.3444" },
    { name = "Seeker's Token 116",               position = "-691.2465, 17.03014, 674.2273" },
    { name = "Seeker's Token 117",               position = "44.64841, 148.8826, -2307.236" },
    { name = "Seeker's Token 118",               position = "-2050.989, 114.8949, -383.0466" },
    { name = "Seeker's Token 119",               position = "-1410.486, 144.7303, -1389.202" },
    { name = "Seeker's Token 120",               position = "-1040.184, 0.4392352, 1258.829" },
    { name = "Seeker's Token 121",               position = "-452.9087, 0.796546, 741.597" },
    { name = "Seeker's Token 122",               position = "334.2993, 100.3809, 1323.854" },
    { name = "Seeker's Token 123",               position = "-1558.879, 85.9902, 429.7581" },
    { name = "Seeker's Token 124",               position = "1253.134, 67.67858, -1870.294" },
    { name = "Seeker's Token 125",               position = "-2175.953, 75.2403, 513.1131" },
    { name = "Seeker's Token 126",               position = "486.8091, 24.38745, -1054.205" },
    { name = "Seeker's Token 127",               position = "-1145.974, 46.43586, -255.1327" },
    { name = "Seeker's Token 128",               position = "802.7636, 10.00694, -1275.782" },
    { name = "Seeker's Token 129",               position = "-257.8826, 50.04342, 769.1068" },
    { name = "Seeker's Token 130",               position = "-256.1795, 29.35168, 1128.872" },
    { name = "Seeker's Token 131",               position = "-29.33716, 164.9512, -2487.574" },
    { name = "Seeker's Token 132",               position = "-2438.648, 297.7558, -729.283" },
    { name = "Seeker's Token 133",               position = "-1735.35, 67.04755, 604.192" },
    { name = "Seeker's Token 134",               position = "-2437.834, 75.30431, -279.8528" },
    { name = "Seeker's Token 135",               position = "-1467.244, 167.842, -972.6749" },
    { name = "Seeker's Token 136",               position = "-1144.316, 59.95095, -37.65364" },
    { name = "Seeker's Token 137",               position = "-2205.891, 37.86744, 416.3837" },
    { name = "Seeker's Token 138",               position = "-1325.521, 153.6144, 318.1047" },
    { name = "Seeker's Token 139",               position = "-1726.722, 96.89873, 19.04225" },
    { name = "Seeker's Token 140",               position = "-1455.78, 107.9478, 276.0348" },
    { name = "Seeker's Token 141",               position = "14.76145, 190.1257, -2412.495" },
    { name = "Seeker's Token 142",               position = "-2081.739, 81.17527, -169.5074" },
    { name = "Seeker's Token 143",               position = "-2195.761, 82.26016, -148.4175" },
    { name = "Seeker's Token 144",               position = "509.7451, 20.81026, -1124.374" },
    { name = "Seeker's Token 145",               position = "-1128.958, 78.22768, 389.9597" },
    { name = "Seeker's Token 146",               position = "378.7181, 44.0754, -1047.653" },
    { name = "Seeker's Token 147",               position = "1094.016, 61.32773, -1263.995" },
    { name = "Seeker's Token 148",               position = "-1059.732, 80.43699, 239.3768" },
    { name = "Seeker's Token 149",               position = "-300.6327, 22.67523, -1187.099" },
    { name = "Seeker's Token 150",               position = "-2117.376, 223.6917, 1044.149" },
    { name = "Seeker's Token 151",               position = "-2096.548, 143.9485, 897.7155" },
    { name = "Seeker's Token 152",               position = "-1017.941, 26.8972, 160.796" },
    { name = "Seeker's Token 153",               position = "-1190.294, 102.4365, 319.5692" },
    { name = "Seeker's Token 154",               position = "889.1685, 20.1433, -1190.647" },
    { name = "Seeker's Token 155",               position = "-930.7362, 37.33437, -730.5226" },
    { name = "Seeker's Token 156",               position = "81.20549, 69.3, -1748.368" },
    { name = "Seeker's Token 157",               position = "928.5052, 240.082, -2586.659" },
    { name = "Seeker's Token 158",               position = "1074.255, 49.43904, -1615.228" },
    { name = "Seeker's Token 159",               position = "-1385.482, 110.7523, -1279.451" },
    { name = "Seeker's Token 160",               position = "-175.3369, 75.17094, -1411.751" },
    { name = "Seeker's Token 161",               position = "-1893.107, 35.35776, 756.4501" },
    { name = "Seeker's Token 162",               position = "-489.7266, 18.02133, -1064.699" },
    { name = "Seeker's Token 163",               position = "1215.604, 76.60162, -1907.77" },
    { name = "Seeker's Token 164",               position = "-1623.225, 86.3857, 291.1531" },
    { name = "Seeker's Token 165",               position = "371.4242, 78.0455, -881.5969" },
    { name = "Seeker's Token 166",               position = "-1547.166, 69.55149, 1078.691" },
    { name = "Seeker's Token 167",               position = "923.5192, 195.4502, -2313.818" },
    { name = "Seeker's Token 168",               position = "-593.5593, 50.08264, -1789.409" },
    { name = "Seeker's Token 169",               position = "-967.5819, 13.6438, -234.7076" },
    { name = "Seeker's Token 170",               position = "-554.0727, 35.60732, -1033.871" },
    { name = "Seeker's Token 171",               position = "-1707.572, 85.18982, 114.9935" },
    { name = "Seeker's Token 172",               position = "-1307.999, 148.0497, -1420.194" },
    { name = "Seeker's Token 173",               position = "-1058.136, 97.33194, 400.906" },
    { name = "Seeker's Token 174",               position = "1284.713, 29.37333, -1253.282" },
    { name = "Seeker's Token 175",               position = "-1737.472, 191.269, -1190.988" },
    { name = "Seeker's Token 176",               position = "-2144.98, 237.7022, 931.1352" },
    { name = "Seeker's Token 177",               position = "-744.014, 37.91385, -1269.364" },
    { name = "Seeker's Token 178",               position = "-2206.928, 76.91254, 370.2791" },
    { name = "Seeker's Token 179",               position = "824.2649, 231.7646, -2651.551" },
    { name = "Seeker's Token 180",               position = "-460.4371, 21.96133, -868.7405" },
    { name = "Seeker's Token 181",               position = "530.9937, -1.72881, -949.6918" },
    { name = "Seeker's Token 182",               position = "459.0298, 76.78581, -719.246" },
    { name = "Seeker's Token 183",               position = "-1907.512, 194.0277, -539.9005" },
    { name = "Seeker's Token 184",               position = "310.7063, 2.663232, -1093.182" },
    { name = "Seeker's Token 185",               position = "-2090.685, 87.91904, -252.9724" },
    { name = "Seeker's Token 186",               position = "-1545.581, 168.1623, -1526.813" },
    { name = "Seeker's Token 187",               position = "-900.6052, -0.4724793, -41.89881" },
    { name = "Seeker's Token 188",               position = "1188.915, 38.70578, -1399.902" },
    { name = "Seeker's Token 189",               position = "-1592.083, 166.3117, -1439.994" },
    { name = "Seeker's Token 190",               position = "59.92789, 221.4001, -2591.599" },
    { name = "Seeker's Token 191",               position = "17.31717, 95.44806, -2068.056" },
    { name = "Seeker's Token 192",               position = "1294.648, 32.48453, -1162.289" },
    { name = "Seeker's Token 193",               position = "-988.0832, 29.20226, 1193.494" },
    { name = "Seeker's Token 194",               position = "1087.994, 42.86492, -1509.454" },
    { name = "Seeker's Token 195",               position = "390.7802, 24.44314, -1063.17" },
    { name = "Seeker's Token 196",               position = "334.6868, 206.1537, -2521.229" },
    { name = "Seeker's Token 197",               position = "1180.006, 65.77381, -1937.357" },
    { name = "Seeker's Token 198",               position = "-892.7271, 29.77627, -720.5415" },
    { name = "Seeker's Token 199",               position = "542.3516, 15.91502, -1215.642" },
    { name = "Seeker's Token 200",               position = "1506.107, 28.23366, -1357.404" },
    { name = "Seeker's Token 201",               position = "-2200.933, 296.0031, 1054.443" },
    { name = "Seeker's Token 202",               position = "458.9755, 46.67035, -1029.605" },
    { name = "Seeker's Token 203",               position = "-1860.29, 85.47575, -437.5429" },
    { name = "Seeker's Token 204",               position = "-1121.143, 79.09875, -1639.249" },
    { name = "Seeker's Token 205",               position = "942.6032, -0.3656093, -1232.318" },
    { name = "Seeker's Token 206",               position = "-477.5305, 87.42719, 1420.187" },
    { name = "Seeker's Token 207",               position = "1091.268, 25.77886, -1428.777" },
    { name = "Seeker's Token 208",               position = "-1820.409, 98.10882, -87.64505" },
    { name = "Seeker's Token 209",               position = "-996.6234, 104.1155, -1290.778" },
    { name = "Seeker's Token 210",               position = "-806.2393, 30.66521, -947.8731" },
    { name = "Seeker's Token 211",               position = "180.126, 26.03245, -1161.688" },
    { name = "Seeker's Token 212",               position = "-1670.075, 99.82407, -1280.521" },
    { name = "Seeker's Token 213",               position = "-1101.613, 114.1108, 612.7404" },
    { name = "Seeker's Token 214",               position = "512.6115, 44.41759, -960.8672" },
    { name = "Seeker's Token 215",               position = "-597.4287, 0.2458094, -842.9684" },
    { name = "Seeker's Token 216",               position = "1148.682, 23.13101, -1390.438" },
    { name = "Seeker's Token 217",               position = "-1709.469, 53.84142, 1102.876" },
    { name = "Seeker's Token 218",               position = "-2390.223, 272.1731, -619.5712" },
    { name = "Seeker's Token 219",               position = "-546.9639, 96.17853, -1880.174" },
    { name = "Seeker's Token 220",               position = "-2008.847, 124.2037, 945.9615" },
    { name = "Seeker's Token 221",               position = "-2403.851, 315.0301, -879.7818" },
    { name = "Seeker's Token 222",               position = "-313.1738, 49.01183, 1247.046" },
    { name = "Seeker's Token 223",               position = "-492.7277, 130.1809, -2259.106" },
    { name = "Seeker's Token 224",               position = "597.8867, 80.00896, -854.4315" },
    { name = "Seeker's Token 225",               position = "-1346.704, 120.433, 398.7322" },
    { name = "Seeker's Token 226",               position = "-1941.606, 77.46495, -340.7309" },
    { name = "Seeker's Token 227",               position = "-804.2957, 44.27563, -1351.228" },
    { name = "Seeker's Token 228",               position = "-347.2373, 53.32834, -884.2132" },
    { name = "Seeker's Token 229",               position = "1564.457, 62.45671, -1439.98" },
    { name = "Seeker's Token 230",               position = "-1787.815, 48.46006, 669.9354" },
    { name = "Seeker's Token 231",               position = "-661.7025, 38.82969, -1069.028" },
    { name = "Seeker's Token 232",               position = "-1101.07, 98.0107, -1134.8" },
    { name = "Seeker's Token 233",               position = "888.7634, 0.3689132, -1230.208" },
    { name = "Seeker's Token 234",               position = "-939.8016, 67.41076, -1248.607" },
    { name = "Seeker's Token 235",               position = "-1929.849, 179.5838, -1146.239" },
    { name = "Seeker's Token 236",               position = "1055.01, 50.11625, -1245.982" },
    { name = "Seeker's Token 237",               position = "-2454.656, 158.9566, -551.7483" },
    { name = "Seeker's Token 238",               position = "-759.3116, 16.65483, 1249.993" },
    { name = "Seeker's Token 239",               position = "494.4174, 14.7665, -1284.163" },
    { name = "Seeker's Token 240",               position = "-381.5288, 8.838051, -827.5795" },
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
	SelectedLanguageIndex = SelectedLanguageIndex,
    CustomTeleportLocations = {},
	LoadBeetleLocations = LoadBeetleLocations,
	LoadSeekerLocations = LoadSeekerLocations,
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
    CustomLocationNames = {}

    for _, location in ipairs(TeleportLocations) do
        table.insert(LocationNames, location.name)
    end

    for _, location in ipairs(Config.CustomTeleportLocations) do
        table.insert(LocationNames, location.name)
        table.insert(CustomLocationNames, location.name)
    end
end

local function update_bonuslocation_names()
	BonusLocationNames = {}

	for _, location in ipairs(BonusLocations) do
        table.insert(BonusLocationNames, location.name)
	end

	if Config.LoadBeetleLocations then
		for _, location in ipairs(BeetleLocations) do
            table.insert(BonusLocationNames, location.name)
		end
	end

	if Config.LoadSeekerLocations then
		for _, location in ipairs(SeekerLocations) do
            table.insert(BonusLocationNames, location.name)
		end
	end
end

local function update_bonuslocation_positions()
	BonusLocationPositions = {}

	for _, location in ipairs(BonusLocations) do
		table.insert(BonusLocationPositions, location.position)
	end

	if Config.LoadBeetleLocations then
		for _, location in ipairs(BeetleLocations) do
			table.insert(BonusLocationPositions, location.position)
		end
	end

	if Config.LoadSeekerLocations then
		for _, location in ipairs(SeekerLocations) do
			table.insert(BonusLocationPositions, location.position)
		end
	end
end

load_config()

Hotkeys.setup_hotkeys(Config.Hotkeys, DefaultHotkeys)

update_location_names()

update_bonuslocation_names()

update_bonuslocation_positions()

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

        imgui.text("Enter a hotkey below to teleport to the given location.")
        imgui.spacing()
        imgui.spacing()
        imgui.spacing()

        imgui.begin_table("1", 2, 1 << 7, Vector2f.new(325.0, 100.0), 10.0)
        imgui.table_setup_column("Hotkey")
        imgui.table_setup_column("Location")
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
        imgui.text("Window Visibility")
        imgui.spacing()

        imgui.end_table()

        imgui.end_window()
    end
end)

re.on_draw_ui(function ()
    if imgui.tree_node("Teleportation") then
        imgui.spacing()

        imgui.text("Locations")
        imgui.push_item_width(190)

        _, SelectedLocationIndex = imgui.combo(" ", SelectedLocationIndex, LocationNames)

        imgui.same_line()
        imgui.spacing()
        imgui.same_line()
        if imgui.button(" Teleport ") then
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

        imgui.text("Name")
        imgui.push_item_width(190)
        _, NewLocationName = imgui.input_text("\t", NewLocationName, 32)
        imgui.same_line()
        if imgui.button("Add Current Location") and NewLocationName ~= "" then
            add_custom_location(NewLocationName)
            update_location_names()
            save_config()
            NewLocationName = nil
        end

        imgui.spacing()
        imgui.spacing()

        if imgui.tree_node("Bonus Locations") then
            imgui.spacing()
            imgui.spacing()

            imgui.push_item_width(190)
            _, SelectedBonusLocationIndex = imgui.combo(" ", SelectedBonusLocationIndex, BonusLocationNames)

            imgui.same_line()
            imgui.spacing()
            imgui.same_line()
            if imgui.button(" Teleport ") then
                teleport(BonusLocationPositions[SelectedBonusLocationIndex])
            end

            imgui.spacing()
            imgui.tree_pop()
        end

        imgui.spacing()
        imgui.spacing()

        if imgui.tree_node("Hotkey Window Settings") then
            imgui.spacing()
            imgui.spacing()

            local hotkeyChanged = Hotkeys.hotkey_setter("Teleport Window Key")
            if hotkeyChanged then
                Hotkeys.update_hotkey_table(Config.Hotkeys)
                save_config()
            end

            imgui.spacing()
            imgui.spacing()
            local windowOpenChanged, windowOpenValue = imgui.checkbox("Require Window Open", Config.RequireTeleportWindowOpen)
            if windowOpenChanged then
                Config.RequireTeleportWindowOpen = windowOpenValue
                save_config()
            end

            imgui.spacing()
            imgui.spacing()
            imgui.spacing()
            local text = ShowTeleportWindow and "Hide " or "Show "
            if imgui.button(text .. "Hotkeys Window") then
                ShowTeleportWindow = not ShowTeleportWindow
            end

            imgui.spacing()
            imgui.tree_pop()
        end

        imgui.spacing()
        imgui.spacing()

        if CustomLocationNames and #CustomLocationNames > 0 then
            if imgui.tree_node("Delete Custom Locations") then
                imgui.spacing()
                imgui.spacing()

                imgui.text("Be careful here - deleted locations cannot be recovered.")

                imgui.spacing()
                imgui.spacing()

                imgui.push_item_width(190)
                _, SelectedCustomLocationIndex = imgui.combo(" ", SelectedCustomLocationIndex, CustomLocationNames)

                imgui.same_line()
                if imgui.button(" Delete ") then
                    table.remove(Config.CustomTeleportLocations, SelectedCustomLocationIndex)
                    save_config()
                    update_location_names()
                end

                imgui.spacing()
                imgui.tree_pop()
            end
        end

        if imgui.tree_node("Options") then
            imgui.spacing()
            imgui.spacing()
            local LoadBeetleLocationsChanged, LoadBeetleLocationsValue = imgui.checkbox("Load Beetle Locations", Config.LoadBeetleLocations)
            if LoadBeetleLocationsChanged then
                Config.LoadBeetleLocations = LoadBeetleLocationsValue
                save_config()
				update_bonuslocation_names()
				update_bonuslocation_positions()
            end

            imgui.spacing()
            imgui.spacing()
            local LoadSeekerLocationsChanged, LoadSeekerLocationsValue = imgui.checkbox("Load Seeker Locations", Config.LoadSeekerLocations)
            if LoadSeekerLocationsChanged then
                Config.LoadSeekerLocations = LoadSeekerLocationsValue
                save_config()
				update_bonuslocation_names()
				update_bonuslocation_positions()
            end

            imgui.spacing()
            imgui.tree_pop()
        end

        imgui.new_line()
        imgui.tree_pop()
    end
end)
