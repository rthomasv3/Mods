local re = re
local sdk = sdk
local draw = draw
local imgui = imgui
local Vector3f = Vector3f
local Vector2f = Vector2f

local PawnManager = sdk.get_managed_singleton("app.PawnManager")
local PawnDataContextType = sdk.find_type_definition("app.PawnDataContext"):get_runtime_type()
local FontSize = 28
local Font = imgui.load_font("times.ttf", FontSize)

local PawnStatuses = {}

local function UpdatePawnPossessionStatuses()
    PawnStatuses = {}
    local pawnList = PawnManager:get_PawnCharacterList()

    for i = 0, pawnList:get_Count() - 1 do
        local pawn = pawnList:get_Item(i)

        local pos = nil
        local x = 0.0
        local y = 0.0
        local z = 0.0

        local gameObject = pawn:get_GameObject()

        if gameObject then
            local transform = gameObject:get_Transform()
            if transform then
                local position = transform:get_position()
                if position then
                    pos = position
                end

                local joints = transform:get_Joints();
                if joints then
                    local head = joints:get_Item(63)

                    if head then
                        local headPosition = head:get_Position()
                        x = headPosition.x
                        y = headPosition.y
                        z = headPosition.z
                    end
                end
            end
        end

        local pawnId = pawn:get_CharaIDString()
        local generateInfo = pawn:get_GenerateInfo()
        local contextHolder = generateInfo:get_Context()
        local pawnDataContextInfo = contextHolder.Contexts[PawnDataContextType]
        local pawnDataContext = pawnDataContextInfo:get_CurrentContext()

        local pawnName = pawnDataContext:get_field("_Name")

        if(pawnName:match("%W")) then
            pawnName = pawnDataContext:get_field("_Nickname")
        end

        local possessionLevel = pawnDataContext:get_field("_PossessionLv")
        local isMain = pawnId == "ch100000_00"

        table.insert(PawnStatuses, { Name = pawnName, PossessionLevel = possessionLevel, IsMain = isMain, HeadX = x, HeadY = y, HeadZ = z, Position = pos })
    end
end

re.on_frame(function()
    UpdatePawnPossessionStatuses()

    if #PawnStatuses > 0 then
        imgui.push_font(Font)

        for _, pawnStatus in ipairs(PawnStatuses) do
            if pawnStatus.PossessionLevel > 0 then
                draw.world_text(pawnStatus.PossessionLevel, Vector3f.new(pawnStatus.HeadX, pawnStatus.HeadY + 0.1, pawnStatus.HeadZ), 0x711C1CFF)
            end
        end

        imgui.pop_font()
    end
end)

re.on_draw_ui(function ()
    if imgui.tree_node("Dragonsplague Counter") then
        imgui.spacing()

        if #PawnStatuses > 0 then
            imgui.begin_table("1", 2, nil, Vector2f.new(325, 100), 10.0)
            imgui.table_setup_column("Pawn Name")
            imgui.table_setup_column("Possession Level")
            imgui.table_headers_row()

            for index, pawnStatus in ipairs(PawnStatuses) do
                imgui.table_next_column()
                if index % 2 == 0 then
                    imgui.table_set_bg_color(1, 0xFF262727, 1)
                end
                imgui.spacing()
                imgui.text(pawnStatus.Name)
                imgui.spacing()

                imgui.table_next_column()
                if index % 2 == 0 then
                    imgui.table_set_bg_color(1, 0xFF262727, 1)
                end
                imgui.spacing()
                imgui.text(pawnStatus.PossessionLevel)
                imgui.spacing()
            end

            imgui.end_table()
        else
            imgui.text("No Pawns Found")
        end

        imgui.spacing()
        imgui.tree_pop()
    end
end)
