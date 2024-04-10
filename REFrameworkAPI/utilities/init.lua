local sdk = sdk
local json = json

---Writes the value to the parent at the given offset
---@param parent_obj any
---@param offset number
---@param value any
local function write_valuetype(parent_obj, offset, value)
    for i = 0, value.type:get_valuetype_size() - 1 do
        parent_obj:write_byte(offset + i, value:read_byte(i))
    end
end

---Finds the index of the given item in the table.
---Returns -1 if the item is not found.
---@param table table
---@param value any
---@param key any
---@return integer
local function find_index(table, value, key)
    local index = -1

    if key ~= nil then
        for i, item in ipairs(table) do
            if item[key] == value then
                index = i
                break
            end
        end
    else
        for i, item in ipairs(table) do
            if item == value then
                index = i
                break
            end
        end
    end

    return index
end

---Returns true if the table contains the given item
---@param table table
---@param item any
---@return boolean
local function table_contains(table, item)
    local containsItem = false

    for _, value in ipairs(table) do
        if value == item then
            containsItem = true
            break
        end
    end

    return containsItem
end

---Merges the two tables into one
---@param table_a table
---@param table_b table
---@param no_overwrite boolean
---@return table
local function merge_tables(table_a, table_b, no_overwrite)
    table_a = table_a or {}
    table_b = table_b or {}

    if no_overwrite then
        for key_b, value_b in pairs(table_b) do
            if table_a[key_b] == nil then
                table_a[key_b] = value_b
            end
        end
    else
        for key_b, value_b in pairs(table_b) do table_a[key_b] = value_b end
    end

    return table_a
end

---Returns the static fields as a table
---@param typename string
---@return table
local function generate_statics(typename)
    local statics = {}
    local typeDefinition = sdk.find_type_definition(typename)

    if typeDefinition then
        local fields = typeDefinition:get_fields()
        local enum_string = "\ncase \"" .. typename .. "\":" .. "\n    enum {"

        for _, field in ipairs(fields) do
            if field:is_static() then
                local name = field:get_name()
                local raw_value = field:get_data(nil)
                enum_string = enum_string .. "\n        " .. name .. " = " .. tostring(raw_value) .. ","
                statics[name] = raw_value
            end
        end
    end

    return statics
end

---Saves the configuration to the given file path
---@param filePath string
---@param config table
---@return boolean,string
local function save_config(filePath, config)
    local errString = ""
    local success, err = pcall(json.dump_file, filePath, config)
    if err then
        errString = tostring(err)
    end
    return success, errString
end

---Loads the configuration from the given file path as a table
---@param filePath string
---@return table
local function load_config(filePath)
    local config = {}
    local file = io.open(filePath, "r")
    if file then
        file:close()
        local status, data = pcall(json.load_file, filePath)
        if status and data then
            config = data
        end
    end
    return config
end

---Returns a string representation of the given vector
---@param vec Vector2f
---@return string|nil
local function vec2_tostring(vec)
    local vecString = nil

    if vec then
        vecString = "("..tostring(vec.x)..","..tostring(vec.y)..")"
    end

    return vecString
end

---Returns a string representation of the given vector
---@param vec Vector3f
---@return string|nil
local function vec3_tostring(vec)
    local vecString = nil

    if vec then
        vecString = "("..tostring(vec.x)..","..tostring(vec.y)..","..tostring(vec.z)..")"
    end

    return vecString
end

---Returns a string representation of the given vector
---@param vec Vector4f
---@return string|nil
local function vec4_tostring(vec)
    local vecString = nil

    if vec then
        vecString = "("..tostring(vec.x)..","..tostring(vec.y)..","..tostring(vec.z)..","..tostring(vec.w)..")"
    end

    return vecString
end

return {
    write_valuetype = write_valuetype,
    find_index = find_index,
    merge_tables = merge_tables,
    table_contains = table_contains,
    generate_statics = generate_statics,
    save_config = save_config,
    load_config = load_config,
    vec2_tostring = vec2_tostring,
    vec3_tostring = vec3_tostring,
    vec4_tostring = vec4_tostring,
}
