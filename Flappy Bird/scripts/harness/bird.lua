-- Custom object harness script

local class = require('sdk.helper.class')

local harness = require('sdk.object.harness')
local resource = require('sdk.shared.resource')

local bird = class({
    name = 'bird',
    extends = harness
})

function bird:new(data)
    -- Do not modify this function
    self:super(data)
end

function bird:scaffold()
    local data = self.data
    local x, y = data.position[1], data.position[2]
    --
    local sheet = resource:acquire('sheet', 'bird')
    local sequence = {
        name = 'fly',
        start = 1,
        count = 3,
        time = 300,
        loopDirection = 'forward'
    }
    --
    self.container = display.newSprite(sheet.item, sequence)
    self.container.x, self.container.y = x, y
end

function bird:fly()
    self.container:play()
    --
    transition.to(self.container, {y = -50, delta = true, time = 300})
    transition.to(self.container, {rotation = -22, time = 300, transition = easing.outSine})
end

function bird:serialize()
    -- Called when the editor saves this object to the scene file
    -- Modify `self.data` here before it is serialized
end

function bird:destroy()
    -- Called right before the object is discarded
    -- Do not call `self.container:removeSelf()`
end

return bird
