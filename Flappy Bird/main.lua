---------------------------------------------------------------------------
--
-- main.lua
--
---------------------------------------------------------------------------

require('dahlia')

local composer = require('composer')
local session = require('sdk.shared.session')

session:initialize()

-- Your code here

display.setDefault('minTextureFilter', 'nearest')
display.setDefault('magTextureFilter', 'nearest')

composer.gotoScene('scenes.game')
