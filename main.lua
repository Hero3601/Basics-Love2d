function love.load()
	--[[vudu = require "libraries/vudu"
	vudu:initialize()]]
	wf = require "libraries/windfield/windfield"
	-- newWorld args : (gx (gravity on the x axis) , gy (gravity on y axis))
	-- our game is top-down game so there will be no gravity in our game on the both axises 
	world = wf.newWorld(0 , 0)
	animte = require "libraries/anim8/anim8"
	sti = require "libraries/Simple-Tiled-Implementation/sti"
	camera = require "libraries/hump/camera"
	-- require "conf"
	-- sti("path to map.lua") - (loads a map)
	ptm = "maps/map1.lua"
	game_map = sti(ptm)
	local map_width = game_map.width * game_map.tilewidth
	local map_height = game_map.height * game_map.tileheight
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
	player.collider = world:newBSGRectangleCollider(player.x , player.y , 50 , 90 , 14)
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
	player.size = 6
	--[[Grid Args :
			( Each frame width , Each frame height , the width of the player sprite sheet (whole sprite sheet) ,
			 the height of the player sprite sheet (whole sprite sheet) )
	]]
	player.grid = animte.newGrid(player.spritesheet:getWidth() / player.row , player.spritesheet:getHeight() / player.col , player.spritesheet:getWidth() , player.spritesheet:getHeight())
	player.zoom = 1

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




	map1 = true
	map2 = false
	map3 = false
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

	local map_width = game_map.width * game_map.tilewidth
	local map_height = game_map.height * game_map.tileheight

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

	world:update(dt)
	player.x = player.collider:getX()
	player.y = player.collider:getY()

	if cam.x < screen_width / 2 then
		cam.x = screen_width / 2
	end

	if cam.y < screen_height / 2 then
		cam.y = screen_height / 2
	end

	local map_width = game_map.width * game_map.tilewidth
	local map_height = game_map.height * game_map.tileheight

	if cam.x > (map_width - screen_width / 2) then
		cam.x = (map_width - screen_width / 2)
	end

	if cam.y > (map_height - screen_height / 2) then
		cam.y = (map_height - screen_height / 2)
	end

	--[[if player.x >= map_width then
		game_map = sti("maps/map2.lua")
		player.x = game_map.width + 200
		if player.x <= map_width then
			game_map = sti("maps/test-map5.lua")
		end
	end]]

	rect = {}
	rect.m = "fill"
	rect.w = 0
	rect.h = map_height
	rect.x = 0
	rect.y = 0
	decr = false
	incr = false

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
		love.graphics.print("Made by : " .. game_maker , 805 , 150)
		love.graphics.print(copy_rights , 860 , 190)
		-- love.graphics.draw(drawable, x, y, r, sx, sy, ox, oy, kx, ky)
		love.graphics.setColor(1 , 1 , 1)
		love.graphics.draw(palestine , 880 , 235 , nil , 3.4 , 1.7)
		love.graphics.setColor(1 , 1 , 1, 0.8)
		love.graphics.print(head.first , 200 , 43)
		love.graphics.print(head.middle , 897 , 43)
		love.graphics.print(head.last , 1542 , 43)
		love.graphics.setColor(1 , 1 , 1)
		--[[love.graphics.rectangle(rect.m, rect.x, rect.y, rect.w, rect.h)]]
		player.anim:draw(player.spritesheet , player.x , player.y , nil , player.size , nil , 6 , 9)
	--[[
	
	cam:detach() - (everything below it attaches with the camera so it will move with you)

	For example if you have a text below the cam detach it will follow the camera 

	]]
		-- setColor args : (r (red) , g (green) , b (blue) , a (alpha))
		-- alpha is the transparent vlaue of the color
		-- the world:draw() draws every collider in the world and it seems like the hitbox in some games
		-- world:draw()
	cam:detach()
	-- love.graphics.rectangle(mode, x, y, width, height, rx, ry, segments)
	love.graphics.draw(cursor , mouse_x , mouse_y , nil , mouse_mode.mods)

	if debugging then
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
        love.graphics.setColor(1, 1, 1)  -- Reset color to full white
        love.graphics.print("Debug Mode", screen_width / 2 - 70, 30)
        love.graphics.print("Player X: " .. math.floor(player.x) .. ", Y: " .. math.floor(player.y), 10, 10)
        love.graphics.print("Mouse X: " .. mouse_x .. ", Mouse Y: " .. mouse_y, 10, 40)
        love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 70)
    end
end

 	-- the below codes arent neccecary

 debuging = false

function love.keypressed(key)

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
	end

	if key == "z" then
		player.zoom = 2
	    cam:zoomTo(player.zoom)
	    screen_width = love.graphics.getWidth() / player.zoom
	    screen_height = love.graphics.getHeight() / player.zoom
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
	end

	if key == "z" then
		player.zoom = 1
	    cam:zoomTo(player.zoom)
	    screen_width = love.graphics.getWidth() / player.zoom
	    screen_height = love.graphics.getHeight() / player.zoom
	end

end

--[[function love.mousepressed(x, y, button, istouch, presses)
	if button == 1 then
		print("You Pressed the mouse at : " .. mouse_x .. " , " .. mouse_y)
	end
end]]