local function dot(x , y , range , color , w , h)
	local x = x or 0
	local y = y or 0
	local color = color or {1 , 1 , 1}
	local w = w or 1
	local h = h or 1

	if type(range) ~= "number" or type(color) ~= "table" then
		return
	end

	love.graphics.setColor(color)
	
	for i = 1 , love.graphics.getWidth() , range do
		for j = 1 , love.graphics.getHeight() , range do
			love.graphics.rectangle("fill" , i , j , w , h)
		end
	end

	love.graphics.setColor(1 , 1 , 1)
end

function diameter(lots)
	if type(lots) ~= "number" then
		return
	end
	print("The diameter of the square equals to : " .. lots .. "√2")
end