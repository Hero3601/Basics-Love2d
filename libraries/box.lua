--[[function love.load(args, unfilteredArgs)
	gap = 100
	img = "cursor.png"
end

function love.update(dt)

end

function love.draw()
	for i = 1 , love.graphics.getHeight() , gap do
		for j = 1 , love.graphics.getWidth() , gap do
			box(j + 20 , i + 20 , 50 , 50 , "image" , img , {1 , 1 , 1 , 0.8} , 3 , 25)
		end	
	end
	print(type(img))
end]]

function box(x , y , width , height , backgroundType , backgroundcolor , bordercolor , bodersize , borderRadius)

	borderRadius = borderRadius or 0
	width = width or 100
	height = height or 50
	x = x or love.graphics.getWidth() / 2 - width / 2
	y = y or love.graphics.getHeight() / 2 - height / 2
	backgroundcolor = backgroundcolor or {1 , 1 , 0 , 0.5} -- semi-transparent black color
	bordercolor = bordercolor or {1 , 1 , 1 , 0.8} -- semi-transparent white color
	bordersize = bordersize or 5
	default_clr = {1 , 1 , 1 , 1}

	if borderRadius == width / 2 or borderRadius == height / 2 then
		borderRadius = math.floor(borderRadius / 2)
	end

	if type(backgroundcolor) == "table" and backgroundType == "color" then
		love.graphics.setColor(bordercolor)
		love.graphics.rectangle("fill" , x - bordersize ,  y - bordersize , width + (bordersize * 2) , height + (bordersize * 2) , borderRadius , borderRadius )
		love.graphics.setColor(default_clr)
		love.graphics.setColor(backgroundcolor) -- accepts table variable type
		love.graphics.rectangle("fill" , x , y , width , height )
		love.graphics.setColor(default_clr) -- reset to default color which is white
	elseif type(backgroundcolor) == "string" and backgroundType == "image" then
		backgroundcolor_im = love.graphics.newImage(backgroundcolor)
		backgroundcolorW = backgroundcolor_im:getWidth() + width
		backgroundcolorH = backgroundcolor_im:getHeight() + height
		love.graphics.setColor(bordercolor)
		love.graphics.rectangle("fill", x - bordersize, y - bordersize, backgroundcolorW + (bordersize * 2), backgroundcolorH + (bordersize * 2), borderRadius, borderRadius)
		love.graphics.setColor(default_clr)
		love.graphics.draw(backgroundcolor_im, x + (backgroundcolorW / 2) + (width / 2) , y + (backgroundcolorH / 2) + (height / 2), nil, nil, nil, backgroundcolorW / 2, backgroundcolorH / 2)
	else
		print("the type of backgroundcolor have to be a table or a string , was" , type(backgroundcolor))
	end
end