local connect_once = function(obj, event, cb)
    local f
    f = function(...)
        obj.disconnect_signal(event, f)
        cb(...)
    end
    obj.connect_signal(event, f)
end

return {
    connect_once = connect_once,
}
