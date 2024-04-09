local IsMainPawn = false

sdk.hook(
    sdk.find_type_definition("app.ItemManager"):get_method("getStorageWeight"),
	function(args)
        local characterId = sdk.to_int64(args[3])

        if characterId == 2283028347 then
            IsMainPawn = true
        else
            IsMainPawn = false
        end
    end,
    function(rtval)
        if IsMainPawn then
            rtval = sdk.to_float(0.0)
        end
		return rtval
	end
)
