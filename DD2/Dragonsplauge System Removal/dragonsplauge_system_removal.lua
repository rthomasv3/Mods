sdk.hook(
    sdk.find_type_definition("app.FacilityManager"):get_method("judgPossession"),
    nil,
    function(rtval)
        rtval = (sdk.to_int64(0) & 1) == 1
        return rtval
    end
)

sdk.hook(
    sdk.find_type_definition("app.PawnDataContext"):get_method("setPossessionLv"),
    function(args)
        args[3] = sdk.to_int64(0)
    end,
    nil
)
