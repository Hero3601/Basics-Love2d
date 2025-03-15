function println(text , x , y , size , fontf , gap , rptx , rpty)
    -- text : text is used to print any text (you can even print a table)
    -- x : the position of the text on x-axis
    -- y : the position of the text on y-axis
    -- size : the size of the text
    -- gap : the gap between two texts (or between the vlaues in the table (array))
    -- rptx : is used only while printing values inside the table and it prints all the values inside the table with the gap you choosed on the x-axis
    -- rpty : is used only while printing values inside the table and it prints all the values inside the table with the gap you choosed on the y-axis 
    size = size or 16
    rptx = rptx or nil
    rpty = rpty or nil
    gap = gap or nil
    fontf = fontf or nil

    if type(fontf) ~= "string" then
        love.event.quit()
        print("the type of fontf should be a string")
    end
    -- love.graphics.setNewFont(filename, size)
    love.graphics.setNewFont(fontf , size)
    if type(text) == "table" and rptx == true then
        for i , v in pairs(text) do
            love.graphics.print(tostring(v) , x + gap * i , y)
        end
    elseif type(text) == "table" and rpty == true then
        for i , v in pairs(text) do
            love.graphics.print(tostring(v) , x , y + gap * i)
        end
    else
        love.graphics.print(text , x , y)
    end

    love.graphics.setNewFont(16)
end