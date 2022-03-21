
local hex2rgb = function(hex)
    hex = hex:gsub("#","")
    return {
        r = tonumber("0x"..hex:sub(1,2)),
        g = tonumber("0x"..hex:sub(3,4)),
        b = tonumber("0x"..hex:sub(5,6)),
    }
end

local function rgb2hsv(rgb)
    local h, s, v

    local min = rgb.r
    if rgb.g < min then
        min = rgb.g
    end
    if rgb.b < min then
        min = rgb.b
    end
    local v = rgb.r
    if rgb.g > v then
        v = rgb.g
    end
    if rgb.b > v then
        v = rgb.b
    end

    local C = v - min
    local s = 0.0

    if v ~= 0 then
        s = C / v
    end

    h = 0.0
    if min ~= v then
        if v == rgb.r then
            _, h = math.modf((rgb.g-rgb.b)/C, 6.0)
        end
        if v == rgb.g then
            h = (rgb.b-rgb.r)/C + 2.0
        end
        if v == rgb.b then
            h = (rgb.r-rgb.g)/C + 4.0
        end
        h = h * 60.0
        if h < 0.0 then
            h = h + 360.0
        end
    end

    local hsv = {
        h = h,
        s = s,
        v = v/255,
    }

    local rgb = function()
        local h = hsv.h / 360
        if hsv.s == 0 then
            return {
                r = hsv.v * 255,
                g = hsv.v * 255,
                b = hsv.v * 255,
            }
        end
        local var_h = h * 6
        if var_h == 6 then var_h = 0 end
        local var_i, _ = math.modf(var_h)
        local var_1 = hsv.v * (1 - hsv.s)
        local var_2 = hsv.v * (1 - hsv.s * (var_h - var_i))
        local var_3 = hsv.v * (1 - hsv.s * (1 - (var_h - var_i)))

        local r, g, b

        if     var_i == 0 then r = hsv.v ; g = var_3 ; b = var_1
        elseif var_i == 1 then r = var_2 ; g = hsv.v ; b = var_1
        elseif var_i == 2 then r = var_1 ; g = hsv.v ; b = var_3
        elseif var_i == 3 then r = var_1 ; g = var_2 ; b = hsv.v
        elseif var_i == 4 then r = var_3 ; g = var_1 ; b = hsv.v
        else                   r = hsv.v ; g = var_1 ; b = var_2 end

        return {
            r = r * 255,
            g = g * 255,
            b = b * 255,
        }
    end

    local hex = function()
        local rgb = rgb()
        return "#" .. string.format('%02x', math.modf(rgb.r)) ..
            string.format('%02x', math.modf(rgb.g)) ..
            string.format('%02x', math.modf(rgb.b))
    end

    hsv.rgb = rgb
    hsv.hex = hex

    return hsv
end

local function hex2hsv(hex)
    return rgb2hsv(hex2rgb(hex))
end

return {
    hex2hsv = hex2hsv,
}
