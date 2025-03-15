-- for map
local maps = {}
local current_map_index = 1
-- for cps
local clickcount = 0
local cps = 0
local timer = 0
local interval = 0.5

local div_clr = 255

function love.load()

	screen_width , screen_height = love.graphics.getDimensions()

	--[[vudu = require "libraries/vudu"
	vudu:initialize()]]
	box = require "libraries/box"
	wf = require "libraries/windfield/windfield"
	-- newWorld args : (gx (gravity on the x axis) , gy (gravity on y axis))
	-- our game is top-down game so there will be no gravity in our game on the both axises 
	world = wf.newWorld(0 , 0 , true)
	world:setQueryDebugDrawing(true)
	animte = require "libraries/anim8/anim8"
	sti = require "libraries/Simple-Tiled-Implementation/sti"
	camera = require "libraries/hump/camera"
	-- require "conf"
	-- sti("path to map.lua") - (loads a map)
	maps[1] = sti("maps/map1.lua")
	maps[2] = sti("maps/test-map1.lua")
	maps[3] = sti("maps/test-map3.lua")

	game_map = maps[current_map_index]

	local map_width = game_map.width * game_map.tilewidth
	local map_height = game_map.height * game_map.tileheight

	--[[
	-- function for loading maps
	function map_sti(fn)
		if type(fn) ~= "string" then
			return
		else
			sti(fn)
		end
	end]]


	-- camera() - (makes a new camera)
	cam = camera()
	fullscreen = true
	love.mouse.setVisible(false)
	love.graphics.setDefaultFilter("nearest" , "nearest")
	player = {}
	player.x = 911
	player.y = 381
	-- the player speed (the impulse of the player on the "x , y" axises)
	player.speed = 400
	player.spritesheet = love.graphics.newImage("images/player-sheet.png")
	player.rotation = nil
	player.row = 4
	player.col = 4
	player.width = math.floor(player.spritesheet:getWidth() / player.row)
	player.height = math.floor(player.spritesheet:getHeight() / player.col)
	player.size = 6
	player.gap = 20
	player.collider = world:newBSGRectangleCollider(player.x , player.y , (player.width * player.size - player.gap) , (player.height * player.size - player.gap) , 14)
	player.collider:setFixedRotation(true)
	--[[

	player.size - (the size of the player which will be used in the sx and sy in the animation / draw args
				   in the draw function and (sx , sy) stands for scalex , scaley)

	Note : if you put the size in one axis it will be added for the both axises
		   for example if you put 6 in the scalex it will be the same as scalex = 6 , scaley = 6
		   because Love2d automatically adds the same number to scale x / y so the object's width and height
		   that you will draw will be multiplayied by the number in scale x / y for example if your
		   object's width / height are 32 x 32 and you put 6 in scalex (one scale axis) then the width / height
		   will be 32 * 6 x 32 * 6 which equals to 192 x 192 so the object's width / height will be 192 x 192
		   (6 times bigger than the usual)

	]]

	sounds = {}
	sounds.footStep = love.audio.newSource("audios/footstep-1.wav", "stream")
	sounds.birdNoise = love.audio.newSource("audios/mus_birdnoise.ogg" , "stream")


	sounds.birdNoise:setVolume(0.2)
	sounds.birdNoise:setLooping(true)
	sounds.birdNoise:play()

	menu = {}
	menu.image = love.graphics.newImage("images/menu-bg.png")
	menu.scalex = screen_width / menu.image:getWidth()
	menu.scaley = screen_height / menu.image:getHeight()
	menu.opacity = 0
	menu.opacityTarget = nil
	menu.opacityAnimSpeed = 5

	characters = {}

	characters[1] = {
		name = "Sam" ,
		sprite = love.graphics.newImage("images/main-mini.png") ,
		spritesheet = love.graphics.newImage("images/player-sheet.png") ,
		opacity = 1 ,
		opacityTarget = 1 ,
		scale = 3 ,
		scaleTarget = 3 ,
		selected = true
	}

	characters[2] = {
		name = "Sans" ,
		sprite = love.graphics.newImage("images/sans-mini.png") ,
		spritesheet = love.graphics.newImage("images/sans-movement.png") ,
		opacity = 0.5 ,
		opacityTarget = 0.5 ,
		scale = 2 ,
		scaleTarget = 2 ,
		selected = false
	}

	selectedCharIndex = 1
	charAnimSpeed = 5

	particle_image = love.graphics.newImage("images/particle.png")

    particles = love.graphics.newParticleSystem(particle_image, 1000)
    particles:setParticleLifetime(0.40, 0.85)  -- Particles live 0.5-1 seconds
    particles:setEmissionRate(20)  -- Start with no emission
    particles:setSizeVariation(1)
    particles:setLinearAcceleration(-20, -10, 20, 50 ) -- Slight spread and gravity
    particles:setColors(1, 1, 1, 0.5, 1 , 1 , 1 , 0)  -- White to transparent
    particles:setSizes(1 , 0.5 , 0.25)  -- Particles shrink over time
    particles:setSpread(math.pi * 4)  -- Spread angle
    particles:setSpeed(50, 100)  -- Particle speed
    particles:setLinearDamping(2, 4)  -- Slow down over time
    particles:setSpin(0, 2)  -- Slight rotation

    emitterX, emitterY = player.x, player.y + player.height + 20

	--[[Grid Args :
			( Each frame width , Each frame height , the width of the player sprite sheet (whole sprite sheet) ,
			 the height of the player sprite sheet (whole sprite sheet) )
	]]
	player.grid = animte.newGrid(player.width , player.height , player.spritesheet:getWidth() , player.spritesheet:getHeight())
	player.zoom = 1
	player.targetZoom = nil
	player.zoomSpeed = 8
	player.animation = {}

	--[[

	newAnimation Args (two args) :

	(
	the grid of the sprite sheet you will use for the animation , 
	the speed / time between two frames to be changed / motivated 
	) 

	the grid itself has (two args) which is :

	1 : the number of frames which has a starter frame and ending frame in my case it is from 1 to 4 ("1-4")
		so i am using 4 frames you can add more (based on the sprite sheet you are using)
	2 : which row has the frames for example if you use player.grid("1-4" , 1) then it means that you will
		use frames from 1 to 4 in the first row of the sprite sheet

	]]
	player.animation.down = animte.newAnimation(player.grid("1-4" , 1) , 0.2)
	player.animation.left = animte.newAnimation(player.grid("1-4" , 2) , 0.2)
	player.animation.right = animte.newAnimation(player.grid("1-4" , 3) , 0.2)
	player.animation.up = animte.newAnimation(player.grid("1-4" , 4) , 0.2)
	player.anim = player.animation.down

	mouse_x , mouse_y = love.mouse.getPosition() 
	cursor = love.graphics.newImage("images/cursor.png")
	default_cursor = true

	mouse_mode = {}
	mouse_mode.zero = {num = 1.5 , bool = false}
	mouse_mode.one = {num = 2 , bool = true}
	mouse_mode.two = {num = 3 , bool = false}
	mouse_mode.three = {num = 3.5 , bool = false}
	mouse_mode.mods = mouse_mode.one.num

	screen_width , screen_height = love.graphics.getDimensions()
	--[[
	background = love.graphics.newImage("images/background1.png")
	background_width = background:getWidth()
	background_height = background:getHeight()
	scalex = screen_width / background_width
	scaley = screen_height / background_height
	]]

	--[[arrow = {}
	arrow.spritesheet = love.graphics.newImage("images/arrow_spritesheet.png")
	arrow.grid = animte.newGrid(32 , 32 , arrow.spritesheet:getWidth() , arrow.spritesheet:getHeight())]]

	--[[arrow.animation = {}
	arrow.animation.down = animte.newAnimation(arrow.grid("1-2" , 1) , 0.2)
	arrow.animation.left = animte.newAnimation(arrow.grid("1-2" , 2) , 0.2)
	arrow.animation.right = animte.newAnimation(arrow.grid("1-2" , 3) , 0.2)
	arrow.animation.up = animte.newAnimation(arrow.grid("1-2" , 4) , 0.2)
	arrow.anim = arrow.animation.down]]

	-- local map_width = game_map.width * game_map.tilewidth
	-- local map_height = game_map.height * game_map.tileheight

	walls = {}

	if game_map.layers["colliders"] then
		for i , obj in pairs(game_map.layers["colliders"].objects) do
			local wall = world:newRectangleCollider(obj.x , obj.y , obj.width , obj.height)
			wall:setType("static")
			table.insert(walls , wall)
		end
	end

	--[[font = love.graphics.newFont("fonts/font_as.ttf")
	love.graphics.setFont(font)]]
	love.graphics.setNewFont("fonts/font_as.ttf" , 35)
	texts = {
		first = {
		"Esc - Exit" ,
		"WASD / Arrows - Player Movement" ,
		"F11 - Fullscreen / Minimized-Screen" ,
		"C / Right-Shift - Sprint" ,
		"Z - Zoom" ,
		"1/2/3/4 - Mouse Scale Controlling" ,
		"Alt + D - My Discord Server"
		} ,

		second = {
			"Alt + T + B - Black Transparent Cursor" ,
			"Alt + T + W - White Transparent Cursor" ,
			"Alt + C + W - White Cursor (The Default Cursor)" ,
			"Alt + C + B - Black Cursor"
		}
	}

	head = {
		first = "Controls :" ,
		middle = "Credits :" ,
		last = "Mouse Appearances :"
	}

	copy_rights = "© Power Crew"
	game_maker = "Mohamed Eldeeb"

	palestine = love.graphics.newImage("images/palestine.png")

end

function love.update(dt)

	if toggle_menu then
		menu.opacityTarget = 1
	else
		menu.opacityTarget = 0
	end

	local opacity_diff = menu.opacityTarget - menu.opacity
	menu.opacity = menu.opacity + opacity_diff * menu.opacityAnimSpeed * dt

	for i , char in ipairs(characters) do
		if char.selected then
			char.opacityTarget = 1
			char.scaleTarget = 3
		else
			char.opacityTarget = 0.5
			char.scaleTarget = 2
		end

		local scale_diff = char.scaleTarget - char.scale
		char.scale = char.scale + scale_diff * charAnimSpeed * dt

		local opacity_diff = char.opacityTarget - char.opacity
		char.opacity = char.opacity + opacity_diff * charAnimSpeed * dt
	end

	if zoomed then
		player.targetZoom = 2    	
	else
		player.targetZoom = 1
    end

    local zoom_diff = player.targetZoom - player.zoom
    player.zoom = player.zoom + zoom_diff * player.zoomSpeed * dt

    cam:zoomTo(player.zoom)

    screen_width = love.graphics.getWidth() / player.zoom
    screen_height = love.graphics.getHeight() / player.zoom

	emitterX = player.x
	emitterY = player.y + player.height + 20

	if emitYBoolean then
		emitterY = player.y + player.height + 10
	end

	timer = timer + dt

	if timer >= interval then
		cps = math.floor(clickcount / interval)
		clickcount = 0
		timer = timer - interval
	end

	--[[if player.x >= 1915 and map1 == true then
		ptm = "maps/map2.lua"
		game_map = sti(ptm)
		map1 = false
		map2 = true
		map3 = false
	elseif map2 == true and player.x >= 1915 then
		ptm = "maps/map1.lua"
		game_map = sti(ptm)
		map1 = true
		map2 = false
		map3 = false
	end]]

	local ismoving = false

	local vx = 0
	local vy = 0

	player.anim:update(dt)

	cam:lookAt(player.x , player.y)

	mouse_x , mouse_y = love.mouse.getPosition()

	if love.keyboard.isDown("right" , "d") then
		vx = player.speed
		player.anim = player.animation.right
		ismoving = true
	end
	if love.keyboard.isDown("left" , "a") then
		vx = -player.speed
		player.anim = player.animation.left
		ismoving = true
	end
	if love.keyboard.isDown("up" , "w") then
		vy = -player.speed
		player.anim = player.animation.up
		ismoving = true
	end
	if love.keyboard.isDown("down" , "s") then
		vy = player.speed
		player.anim = player.animation.down
		ismoving = true
	end

	player.collider:setLinearVelocity(vx , vy)

	if ismoving == false then
		player.anim:gotoFrame(2)
	end

	if ismoving then
		sounds.footStep:setVolume(0.9)
		sounds.footStep:play()

		particles:setEmissionRate(30)  -- Emit 30 particles per second
        particles:setPosition(emitterX, emitterY)
    else
        particles:setEmissionRate(0)  -- Stop emitting when not moving
	end

	particles:update(dt)

	world:update(dt)
	player.x = player.collider:getX()
	player.y = player.collider:getY()


	 -- Map transition logic
    -- Map transition logic
local map_width = game_map.width * game_map.tilewidth
local map_height = game_map.height * game_map.tileheight

    if cam.x < screen_width / 2 then
        cam.x = screen_width / 2
    end

    if cam.y < screen_height / 2 then
        cam.y = screen_height / 2
    end

    if cam.x > (map_width - screen_width / 2) then
        cam.x = (map_width - screen_width / 2)
    end

    if cam.y > (map_height - screen_height / 2) then
        cam.y = (map_height - screen_height / 2)
    end

if player.x > map_width then
    -- Move to the next map (right)
    current_map_index = current_map_index + 1
    if current_map_index > #maps then
        current_map_index = 1  -- Loop back to the first map
    end
    game_map = maps[current_map_index]

    -- Reset player position to the left edge of the new map
    player.x = 0
    player.collider:setX(player.x)

    -- Rebuild colliders for the new map
    rebuildColliders()

    -- Update camera bounds for the new map
    updateCameraBounds()

    removeText()

    if current_map_index == 1 then
    	restoreText()
    end
elseif player.x < 0 then
    -- Move to the previous map (left)
    current_map_index = current_map_index - 1
    if current_map_index < 1 then
        current_map_index = #maps  -- Loop back to the last map
    end
    game_map = maps[current_map_index]

    -- Reset player position to the right edge of the new map
    player.x = game_map.width * game_map.tilewidth
    player.collider:setX(player.x)

    -- Rebuild colliders for the new map
    rebuildColliders()

    -- Update camera bounds for the new map
    updateCameraBounds()

    removeText()


    if current_map_index == 1 then
    	restoreText()
    end
end

function rebuildColliders()
    -- Destroy existing colliders
    for i, wall in ipairs(walls) do
        wall:destroy()
    end
    walls = {}

    -- Create new colliders for the current map
    if game_map.layers["colliders"] then
        for i, obj in pairs(game_map.layers["colliders"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType("static")
            table.insert(walls, wall)
        end
    end
end

function updateCameraBounds()
    -- Recalculate the map's width and height
    local map_width = game_map.width * game_map.tilewidth
    local map_height = game_map.height * game_map.tileheight

    -- Update the camera's bounds to match the new map's dimensions
    if cam.x < screen_width / 2 then
        cam.x = screen_width / 2
    end

    if cam.y < screen_height / 2 then
        cam.y = screen_height / 2
    end

    if cam.x > (map_width - screen_width / 2) then
        cam.x = (map_width - screen_width / 2)
    end

    if cam.y > (map_height - screen_height / 2) then
        cam.y = (map_height - screen_height / 2)
    end
end

function removeText()
    -- Clear the texts table
    texts = {
        first = {} ,  -- Reset the first set of texts
        second = {}  -- Reset the second set of texts
    }

    head = {
    	first = "" , 
    	middle = "" ,
    	last = ""
    }

    -- Clear other text-related variables
    copy_rights = ""  -- Set to an empty string
    game_maker = ""   -- Set to an empty string

    -- Clear the palestine flag (set to nil or a blank image)
    palestine = nil  -- Or use: palestine = love.graphics.newImage("images/blank.png") if you have a blank image
end

function restoreText()
        -- Restore the texts table
        texts = {
            first = {
                "Esc - Exit",
                "WASD / Arrows - Player Movement",
                "F11 - Fullscreen / Minimized-Screen",
                "C / Right-Shift - Sprint",
                "Z - Zoom",
                "1/2/3/4 - Mouse Scale Controlling",
                "Alt + D - My Discord Server"
            },
            second = {
                "Alt + T + B - Black Transparent Cursor",
                "Alt + T + W - White Transparent Cursor",
                "Alt + C + W - White Cursor (The Default Cursor)",
                "Alt + C + B - Black Cursor"
            }
        }

        -- Restore the head table
        head = {
            first = "Controls:",
            middle = "Credits:",
            last = "Mouse Appearances:"
        }

        -- Restore other text-related variables
        copy_rights = "© Power Crew"
        game_maker = "Mohamed Eldeeb"

        -- Restore the palestine flag
        palestine = love.graphics.newImage("images/palestine.png")
    end

    -- Update the current map
    --[[function load_map(map_file)
    	local game_map = sti(map_file)

    	local map_width = game_map.width * game_map.tilewidth
    	local map_height = game_map.height * game_map.tileheight
    	print("map loaded" .. "width : " .. map_width)
    	print("height : " .. map_height)
	end]]

	-- if cam.x > (map_width - screen_width / 2) then
	-- 	cam.x = (map_width - screen_width / 2)
	-- end

	-- if cam.y > (map_height - screen_height / 2) then
	-- 	cam.y = (map_height - screen_height / 2)
	-- end

	--[[if player.x >= map_width then
		game_map = sti("maps/map2.lua")
		player.x = game_map.width + 200
		if player.x <= map_width then
			game_map = sti("maps/test-map5.lua")
		end
	end]]

	--[[rect = {}
	rect.m = "fill"
	rect.w = 0
	rect.h = map_height
	rect.x = 0
	rect.y = 0
	decr = false
	incr = false]]

	--[[if player.x >= map_width then
		-- ptm = path to map
		ptm = "maps/map2.lua"
		rect.w = rect.w + 5
	end]]

	if love.keyboard.isDown("lalt" , "ralt") and love.keyboard.isDown("d") then
		love.system.openURL("https://discord.com/invite/JSd6T2MTBm")
	end

	if love.keyboard.isDown("lalt" , "ralt") and love.keyboard.isDown("t") and love.keyboard.isDown("b") then
		cursor = love.graphics.newImage("images/cursor_transparent_black.png")
		default_cursor = false
	end

	if love.keyboard.isDown("lalt" , "ralt") and love.keyboard.isDown("t") and love.keyboard.isDown("w") then
		cursor = love.graphics.newImage("images/cursor_transparent_white.png")
		default_cursor = false
	end

	if default_cursor == false then
		if love.keyboard.isDown("lalt" , "ralt") and love.keyboard.isDown("c") and love.keyboard.isDown("w") then
			cursor = love.graphics.newImage("images/cursor.png")
			default_cursor = true
		end
	end

	if love.keyboard.isDown("lalt" , "ralt") and love.keyboard.isDown("c") and love.keyboard.isDown("b") then
		cursor = love.graphics.newImage("images/cursor1.png")
		default_cursor = false
	end

end

function love.draw()
	--[[

	cam:attach() - (everything inside it doesnt attach with the camera so the camera can ignore it)

	]]
	cam:attach()
		game_map:drawLayer(game_map.layers["ground"])
		game_map:drawLayer(game_map.layers["tree"])
		love.graphics.setColor(1 , 1 , 1 , 0.8)
		for i = 1 , #texts.first do
			love.graphics.print(texts.first[i] , 80 , 100 + 24 * i)
		end

		for i = 1 , #texts.second do
			love.graphics.print(texts.second[i] , 1400 , 130 + 26 * i)
		end
		if game_maker and game_maker ~= "" then
			love.graphics.print("Made by : " .. game_maker , 805 , 150)			
		end
		if copy_rights and copy_rights ~= "" then
			love.graphics.print(copy_rights , 860 , 190)
		end
		-- love.graphics.draw(drawable, x, y, r, sx, sy, ox, oy, kx, ky)
		love.graphics.setColor(1 , 1 , 1)
		if palestine then
            love.graphics.draw(palestine, 880, 235, nil, 3.4, 1.7)
        end
		love.graphics.setColor(1 , 1 , 1, 0.8)
		if head then
			love.graphics.print(head.first , 200 , 43)
			love.graphics.print(head.middle , 897 , 43)
			love.graphics.print(head.last , 1542 , 43)
		end

		love.graphics.setBlendMode("add")  -- Additive blending for a glowing effect
        love.graphics.draw(particles)
        love.graphics.setBlendMode("alpha")  -- Reset blending mode
        
		love.graphics.setColor(1 , 1 , 1)
		--[[love.graphics.rectangle(rect.m, rect.x, rect.y, rect.w, rect.h)]]
		player.anim:draw(player.spritesheet , player.x , player.y , nil , player.size , nil , player.width / 2 , player.height / 2)
	--[[
	
	cam:detach() - (everything below it attaches with the camera so it will move with you)

	For example if you have a text below the cam detach it will follow the camera 

	]]
		-- setColor args : (r (red) , g (green) , b (blue) , a (alpha))
		-- alpha is the transparent vlaue of the color
		-- the world:draw() draws every collider in the world and it seems like the hitbox in some games
		-- world:draw()
	cam:detach()
    	if menu.opacity > 0 then
    		love.graphics.setColor(1 , 1 , 1 , menu.opacity)
    		love.graphics.draw(menu.image, 0, 0, nil, menu.scalex, menu.scaley)

    		for i , char in ipairs(characters) do
    			local gap = 200
    			local charX = (love.graphics.getWidth() / 4) + i * gap
    			local charY = love.graphics.getHeight() / 4

    			love.graphics.setColor(1 , 1 , 1 , char.opacity * menu.opacity)

    			love.graphics.draw(char.sprite , charX + (char.sprite:getWidth() / 2) , charY + (char.sprite:getHeight() / 2) , nil , char.scale , char.scale , char.sprite:getWidth() / 2 , char.sprite:getHeight() / 2)

    			local boxW = 100
    			local boxH = 100

    			love.graphics.print(char.name, charX - 10, charY + 70)

    			if char.selected then
    				love.graphics.rectangle("line", charX - (boxW / 2) + (math.floor(char.sprite:getWidth() / 2)) , charY - (boxH / 2) + (math.floor(char.sprite:getHeight() / 2)) , boxW, boxH)
    			end
    		end


    		love.graphics.setColor(1 , 1 , 1 , 1)
    	end
	-- love.graphics.rectangle(mode, x, y, width, height, rx, ry, segments)
	love.graphics.draw(cursor , mouse_x , mouse_y , nil , mouse_mode.mods)


	if debugging then

		cam:attach()

		world:draw()

		cam:detach()
        -- Get map dimensions
        local map_width = game_map.width * game_map.tilewidth
        local map_height = game_map.height * game_map.tileheight

        -- Draw grid lines
        love.graphics.setColor(1, 1, 1, 0.6)  -- Set translucent white color
        for x = 0, map_width, 32 do
            love.graphics.line(x, 0, x, map_height)  -- Vertical grid lines
        end
        for y = 0, map_height, 32 do
            love.graphics.line(0, y, map_width, y)  -- Horizontal grid lines
        end

        -- Draw debug information
        love.graphics.setColor(1, 1, 1)
        love.graphics.setColor(69/div_clr, 255/div_clr, 208/div_clr)  -- Reset color to full white
        love.graphics.print("Debug Mode", screen_width / 2 - 70, 30)
        love.graphics.print("Player X: " .. math.floor(player.x) .. ", Y: " .. math.floor(player.y), 10, 10)
        love.graphics.print("Mouse X: " .. mouse_x .. ", Mouse Y: " .. mouse_y, 10, 40)
        love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 70)
        love.graphics.print("Current Map: " .. current_map_index, 230, 10)
        love.graphics.print("Map Width : " .. map_width , 10 , 100)
        love.graphics.print("Map Height : " .. map_height , 10 , 130)
        love.graphics.print("Player velocity: " .. math.floor(player.collider:getLinearVelocity()) , 100  , 70)
        love.graphics.print("CPS : " .. cps , 190 , 100)
        love.graphics.setColor(1 , 1 , 1)
    end

end

 	-- the below codes arent neccecary

 debuging = false
 toggle_menu = false
 zoomed = false
 emitYBoolean = false

function love.keypressed(key)

	if key == "m" then
		toggle_menu = not toggle_menu -- returns the opposite boolean (true)
	end

	if toggle_menu then
		if key == "right" or key == "d" then
			characters[selectedCharIndex].selected = false
			selectedCharIndex = selectedCharIndex % #characters + 1
			characters[selectedCharIndex].selected = true
		elseif key == "left" or key == "a" then
			characters[selectedCharIndex].selected = false
			selectedCharIndex = selectedCharIndex - 1
			if selectedCharIndex < 1 then
				selectedCharIndex = #characters
			end
			characters[selectedCharIndex].selected = true
		elseif key == "return" or key == "space" then
			player.spritesheet = characters[selectedCharIndex].spritesheet
			player.row = 4
			player.col = 4
			player.width = math.floor(player.spritesheet:getWidth() / player.row)
			player.height = math.floor(player.spritesheet:getHeight() / player.col)
			if selectedCharIndex == 1 then
				player.size = 6
			elseif selectedCharIndex == 2 then
				player.size = 3.5
			end

			emitYBoolean = not emitYBoolean

			player.grid = animte.newGrid(player.width , player.height , player.spritesheet:getWidth() , player.spritesheet:getHeight())

			player.animation.down = animte.newAnimation(player.grid("1-4" , 1) , 0.2)
			player.animation.left = animte.newAnimation(player.grid("1-4" , 2) , 0.2)
			player.animation.right = animte.newAnimation(player.grid("1-4" , 3) , 0.2)
			player.animation.up = animte.newAnimation(player.grid("1-4" , 4) , 0.2)

			player.anim = player.animation.down
		end
	end

	if key == "f5" then
        debugging = not debugging  -- Toggle debug mode
    end


	if key == "escape" then
		love.event.quit()
	end

	if key == "1" or key == "kp1" then
		mouse_mode.mods = mouse_mode.zero.num
		mouse_mode.zero.bool = true
		mouse_mode.one.bool = false
		mouse_mode.two.bool = false
		mouse_mode.three.bool = false
	end

	if mouse_mode.one.bool == false then
		if key == "2" or key == "kp2" then
			mouse_mode.mods = mouse_mode.one.num
			mouse_mode.zero.bool = false
			mouse_mode.one.bool = true
			mouse_mode.two.bool = false
			mouse_mode.three.bool = false			
		end
	end

	if mouse_mode.two.bool == false then
		if key == "3" or key == "kp3" then
			mouse_mode.mods = mouse_mode.two.num
			mouse_mode.zero.bool = false
			mouse_mode.one.bool = false
			mouse_mode.two.bool = true
			mouse_mode.three.bool = false
		end
	end

	if mouse_mode.three.bool == false then
		if key == "4" or key == "kp4" then
			mouse_mode.mods = mouse_mode.three.num
			mouse_mode.zero.bool = false
			mouse_mode.one.bool = false
			mouse_mode.two.bool = false
			mouse_mode.three.bool = true
		end
	end

	if key == "c" or key == "rshift" then
		player.speed = 540
		player.animation.down = animte.newAnimation(player.grid("1-4" , 1) , 0.1)
		player.animation.left = animte.newAnimation(player.grid("1-4" , 2) , 0.1)
		player.animation.right = animte.newAnimation(player.grid("1-4" , 3) , 0.1)
		player.animation.up = animte.newAnimation(player.grid("1-4" , 4) , 0.1)
		sounds.footStep:setPitch(1.2)
	end

	if key == "z" then
		zoomed = not zoomed
	end

	if key == "f11" then
		fullscreen = not fullscreen -- (not true = false)
		love.window.setFullscreen(false , "desktop")
		screen_width = 1000
		screen_height = 720
	end

	if fullscreen ~= true then
		if key == "f11" then
			fullscreen = fullscreen -- (true)
			love.window.setFullscreen(true , "desktop")
			screen_width = love.graphics.getWidth()
			screen_height = love.graphics.getHeight()
		end
	end

end

function love.keyreleased(key)
	if key == "c" or key == "rshift" then
		player.speed = 400
		player.animation.down = animte.newAnimation(player.grid("1-4" , 1) , 0.2)
		player.animation.left = animte.newAnimation(player.grid("1-4" , 2) , 0.2)
		player.animation.right = animte.newAnimation(player.grid("1-4" , 3) , 0.2)
		player.animation.up = animte.newAnimation(player.grid("1-4" , 4) , 0.2)
		sounds.footStep:setPitch(1)
	end

	if key == "z" then
		zoomed = false
	end

end

function love.mousepressed(x, y, button, istouch, presses)
	if button == 1 then
		clickcount = clickcount + 1
	end
end