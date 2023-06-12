-- Scene script

local composer = require('composer')
local session = require('sdk.shared.session')

local utils = require('scripts.utils')
local deltatime = require('scripts.deltatime')

local READY = 1
local PLAYING = 2
local GAMEOVER = 3

local speed = 0.08

local _random = math.random

---------------------------------------------------------------------------

local scene = composer.newScene()

---------------------------------------------------------------------------

function scene:create(event)
    local sceneGroup = self.view
    self.best, self.points = 0, 0
    --
    self.sceneObject = session:loadScene('game')
    self.sceneObject:render(sceneGroup)
    --
    self.bird = self.sceneObject:search('bird')
    self.score = self.sceneObject:search('score')
    --
    local backdrop = self.sceneObject:search('backdrop')
    self.game_over = self.sceneObject:search('game_over')
    --
    self.pipe1 = self.sceneObject:search('pipe1')
    self.sensor1 = self.pipe1:search('sensor')
    --
    self.pipeHi1 = self.pipe1:search('pipeHi').container
    self.pipeLo1 = self.pipe1:search('pipeLo').container
    --
    self.pipe2 = self.sceneObject:search('pipe2')
    self.sensor2 = self.pipe2:search('sensor')
    --
    self.pipeHi2 = self.pipe2:search('pipeHi').container
    self.pipeLo2 = self.pipe2:search('pipeLo').container
    --
    self.pipe3 = self.sceneObject:search('pipe3')
    self.sensor3 = self.pipe3:search('sensor')
    --
    self.pipeHi3 = self.pipe3:search('pipeHi').container
    self.pipeLo3 = self.pipe3:search('pipeLo').container
    --
    self.sensor1:setInvisible()
    self.sensor2:setInvisible()
    self.sensor3:setInvisible()
    --
    self.ground1 = self.sceneObject:search('ground1').container
    self.ground2 = self.sceneObject:search('ground2').container
    --
    backdrop.container:addEventListener('touch',
        function(event)
            if event.phase ~= 'ended' then
                return true
            end
            --
            if self.status == READY then
                self:start()
            elseif self.status == PLAYING then
                self.bird:fly()
            elseif self.status == GAMEOVER then
                self:setup(true)
            end
            --
            return true
        end
    )
    --
    self._update = function() self:update() end
end

---------------------------------------------------------------------------

function scene:setup(restart)
    self.bird:setOpacity(0)
    self.game_over:setOpacity(0)
    --
    local title = self.sceneObject:search('title')
    transition.to(title.container,
        {
            y = 256,
            time = 900,
            transition = easing.outBounce,
            onComplete = function()
                self.status = READY
            end
        }
    )
    --
    if restart then
        local stats = self.sceneObject:search('stats')
        transition.to(stats.container, {x = -370, time = 700, transition = easing.inBack})
        --
        self.bird:moveTo(120, 240)
        self.bird:rotateTo(0)
        --
        self.pipe1:moveTo(430)
        self.pipe2:moveTo(610)
        self.pipe3:moveTo(790)
        --
        self.score.container:setProperty('text', '0')
    end
end

---------------------------------------------------------------------------

function scene:start()
    local title = self.sceneObject:search('title')
    local score = self.sceneObject:search('score')
    --
    transition.to(title.container, {y = -256, time = 700, transition = easing.inBack})
    transition.to(score.container, {y = 50, time = 700, transition = easing.outBounce})
    --
    transition.to(self.bird.container, {alpha = 1, time = 700})
    --
    timer.performWithDelay(900,
        function()
            self.status = PLAYING
            Runtime:addEventListener('enterFrame', self._update)
        end
    )
end

---------------------------------------------------------------------------

function scene:gameover()
    Runtime:removeEventListener('enterFrame', self._update)
    --
    transition.to(self.game_over.container, {alpha = 1, time = 700})
    transition.to(self.bird.container, {y = 444, rotation = 90, time = 700})
    --
    local stats = self.sceneObject:search('stats')
    transition.to(stats.container, {x = 144, time = 700, transition = easing.outBounce})
    --
    if self.points >= self.best then
        self.best = self.points
    end
    --
    local score = self.sceneObject:search('current_score')
    score.container:setProperty('text', tostring(self.points))
    --
    local scoreCounter = self.sceneObject:search('score')
    transition.to(scoreCounter.container, {y = -50, time = 700, transition = easing.inBack})
    --
    local best = self.sceneObject:search('best_score')
    best.container:setProperty('text', tostring(self.best))
    --
    local silver = self.sceneObject:search('silver')
    local gold = self.sceneObject:search('gold')
    --
    if self.points < 5 then
        gold:setInvisible()
        silver:setInvisible()
    elseif self.points < 10 then
        gold:setInvisible()
        silver:setVisible()
    else
        gold:setVisible()
        silver:setInvisible()
    end
    --
    deltatime.restart()
    self.points = 0
    --
    timer.performWithDelay(900,
        function()
            self.status = GAMEOVER
        end
    )
end

---------------------------------------------------------------------------

function scene:update()
    local dt = deltatime.getTime()
    --
    local moveX = -speed * dt
    local moveY = speed * dt
    --
    self.ground1:translate(moveX, 0)
    self.ground2:translate(moveX, 0)
    --
    if utils.isOffLeft(self.ground1) then
        self.ground1.x = self.ground2.x + 336
    end
    --
    if utils.isOffLeft(self.ground2) then
        self.ground2.x = self.ground1.x + 336
    end
    --
    self.pipe1.container:translate(moveX, 0)
    self.pipe2.container:translate(moveX, 0)
    self.pipe3.container:translate(moveX, 0)
    --
    if utils.isOffLeft(self.pipe1.container) then
        self.pipe1.container.x = self.pipe3.container.x + 180
        self.pipe1.container.y = _random(206, 306)
        self.sensor1.blocked = false
    elseif utils.isOffLeft(self.pipe2.container) then
        self.pipe2.container.x = self.pipe1.container.x + 180
        self.pipe2.container.y = _random(206, 306)
        self.sensor2.blocked = false
    elseif utils.isOffLeft(self.pipe3.container) then
        self.pipe3.container.x = self.pipe2.container.x + 180
        self.pipe3.container.y = _random(206, 306)
        self.sensor3.blocked = false
    end
    --
    self.bird.container:translate(0, moveY)
    --
    if self.bird.container.rotation < 22 then
        self.bird.container:rotate(moveY)
        --
        if self.bird.container.rotation > 22 then
            self.bird.container.rotation = 22
        end
    end
    --
    if utils.collision(self.bird.container, self.sensor1.container) then
        if not self.sensor1.blocked then
            self.sensor1.blocked = true
            self.points = self.points + 1
            self.score.container:setProperty('text', tostring(self.points))
        end
    elseif utils.collision(self.bird.container, self.sensor2.container) then
        if not self.sensor2.blocked then
            self.sensor2.blocked = true
            self.points = self.points + 1
            self.score.container:setProperty('text', tostring(self.points))
        end
    elseif utils.collision(self.bird.container, self.sensor3.container) then
        if not self.sensor3.blocked then
            self.sensor3.blocked = true
            self.points = self.points + 1
            self.score.container:setProperty('text', tostring(self.points))
        end
    end
    if utils.collision2(self.bird.container, self.pipeHi1) then
        self:gameover()
    elseif utils.collision2(self.bird.container, self.pipeLo1) then
        self:gameover()
    elseif utils.collision2(self.bird.container, self.pipeHi2) then
        self:gameover()
    elseif utils.collision2(self.bird.container, self.pipeLo2) then
        self:gameover()
    elseif utils.collision2(self.bird.container, self.pipeHi3) then
        self:gameover()
    elseif utils.collision2(self.bird.container, self.pipeLo3) then
        self:gameover()
    elseif utils.collision2(self.bird.container, self.ground1) then
        self:gameover()
    elseif utils.collision2(self.bird.container, self.ground2) then
        self:gameover()
    end
end

---------------------------------------------------------------------------

function scene:show(event)
    local phase = event.phase
    local sceneGroup = self.view
    --
    if phase == 'will' then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
    elseif phase == 'did' then
        self:setup()
    end
end

function scene:hide(event)
    local phase = event.phase
    local sceneGroup = self.view
    --
    if phase == 'will' then
        -- Code here runs when the scene is on screen (but is about to go off screen)
    elseif phase == 'did' then
        -- Code here runs immediately after the scene goes entirely off screen
    end
end

---------------------------------------------------------------------------

function scene:destroy(event)
    local sceneGroup = self.view
    -- Code here runs prior to removal of the scene's view
end

---------------------------------------------------------------------------

scene:addEventListener('create', scene)
scene:addEventListener('show', scene)
scene:addEventListener('hide', scene)
scene:addEventListener('destroy', scene)

---------------------------------------------------------------------------

return scene
