require("AnAL")

function love.load()
    local joysticks = love.joystick.getJoysticks()
    joystick = joysticks[1]
	
	load_sprites()
	
    --if joystick then print(joystick:getAxisCount()) end 
    speed = 300
    jumpspeed = 160
    ground = 300
    gravity = 500
    p = {
        x = 40,
        y = 300,
        r = 15,
        v = jumpspeed
    }
	
	stars = {}
    max_stars = 200
	for i=1, max_stars do   -- generate the coords of our stars
         local x = math.random(0, love.graphics.getWidth())   -- generate a "random" number for the x coord of this star
         local y = math.random(0, love.graphics.getHeight()-ground)   -- both coords are limited to the screen size, minus 5 pixels of padding
         stars[i] = {x, y}   -- stick the values into the table
     end
end

function love.update(dt)	
    if p.v ~= 0 then
        p.v = p.v + (dt * gravity)
        p.y = p.y + (p.v * dt)
    end
    if p.y > ground - p.r then
        print("p.y > ground - p.r")
        p.y = ground - p.r
        p.v = 0
    end

    if not joystick then return end

    --if(math.abs(joystick:getAxis(1)) > 0.2) then
        --p.x = p.x + 
		for i=1, #stars do   
			--x = stars[i]
			stars[i][1] = stars[i][1] - 0.01*150
			if(stars[i][1] < 0) then
				stars[i][1] = love.graphics.getWidth()--math.random(love.graphics.getWidth(), love.graphics.getWidth())
			end
	     end
    --end

    if(joystick:isGamepadDown("a") and p.v == 0) then
        p.v = -jumpspeed
        current_animation = jump_animation
    elseif(p.v == 0) then
        current_animation = walk_animation
    end
    current_animation:update(dt) 
end

function love.draw()
    love.graphics.line(0, ground, love.graphics.getWidth(), ground)
    current_animation:draw(p.x, p.y)
	
	-- draw stars
	for i=1, #stars do   -- loop through all of our stars
	      love.graphics.point(stars[i][1], stars[i][2])   -- draw each point
	 end
end

function load_sprites()
    p1_spritesheet = love.image.newImageData("p1_spritesheet.png")
    p1_coordinates = {}
    
    file = love.filesystem.newFile("p1_spritesheet.txt")
    file:open("r")
    lines = file:lines()
    for line in lines do
        local key, p1, p2, p3, p4 = string.match(line, "(%a%d%p%a+%d*)%s*=%s*(%d+)%s*(%d+)%s*(%d+)%s(%d+)")
        p1_coordinates[key] = {p1, p2, p3, p4}
    end

        
    p1_walk_sprites = love.image.newImageData(11*72, 97)
    walk_names = { "p1_walk01", "p1_walk02", "p1_walk03", "p1_walk04", "p1_walk05", "p1_walk06", "p1_walk07", "p1_walk08", "p1_walk09", "p1_walk10", "p1_walk11" }

    for i=1, #walk_names do
        name = walk_names[i]
        local sx, sy, sw, sh = (p1_coordinates[name])[1], (p1_coordinates[name])[2],(p1_coordinates[name])[3], (p1_coordinates[name])[4] 
        print(sx, sy, sw, sh)
        p1_walk_sprites:paste(p1_spritesheet, 72*(i-1), 0, sx, sy, sw, sh)
    end

    p1_walk_sprites = love.graphics.newImage(p1_walk_sprites)
    walk_animation = newAnimation(p1_walk_sprites, 72, 97, 0.01, 0)

    jump_name = "p1_jump"
    p1_jump_sprites = nil
    sx, sy, sw, sh = (p1_coordinates[jump_name])[1], (p1_coordinates[jump_name])[2],(p1_coordinates[jump_name])[3], (p1_coordinates[jump_name])[4]
    print("jump", sx, sy, sw, sh)
    p1_jump_sprites = love.image.newImageData(sw, sh)
    p1_jump_sprites:paste(p1_spritesheet, 0, 0, sx, sy, sw, sh)
    p1_jump_sprites = love.graphics.newImage(p1_jump_sprites)
    jump_animation = newAnimation(p1_jump_sprites, sw, sh, 0.1, 0) 
    current_animation = walk_animation
end
