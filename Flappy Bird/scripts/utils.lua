local utils = {}

local sox, soy = display.screenOriginX, display.screenOriginY

function utils.isOffLeft(object)
    local bounds = object.contentBounds
    --
    if bounds.xMax < sox then return true end
    if bounds.yMax < soy then return true end
    --
    return false
end

function utils.collision(object1, object2)
    local bounds1 = object1.contentBounds
    local bounds2 = object2.contentBounds
    --
    if bounds1.xMin < bounds2.xMax and bounds1.xMax > bounds2.xMin then
        return true
    end
end

function utils.collision2(object1, object2)
    local bounds1 = object1.contentBounds
    local bounds2 = object2.contentBounds
    --
    if bounds1.xMin < bounds2.xMax and bounds1.xMax > bounds2.xMin and bounds1.yMin < bounds2.yMax and bounds1.yMax > bounds2.yMin then
        return true
    end
end

return utils
