require("AnAL")
require 'generation'
HC = require "hardoncollider"
Gamestate = require "hump.gamestate"
Timer = require "hump.timer"

function on_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
	print("collision")
end

function collision_stop(dt, shape_a, shape_b)
	print("collision stop")
end

function love.load()
    local joysticks = love.joystick.getJoysticks()
    joystick = joysticks[1]
	
	love.window.setMode(960, 320)
	
	--load_sprites()
	
	Collider = HC(100, on_collision, collision_stop)
	
    worldspeed = 100
	worldacceleration = 50
    playerspeed = 100
    jumpspeed = 300
    ground = 300 -- height of ground
    gravity = 700
    player = {
        x = 40,
        y = 200,
        r = 15,
        v = jumpspeed, 
		height = 24,
		width = 24
    }
	
	player.collider = Collider:addRectangle(player.x+player.width/2, player.y+player.height/2, 12, 14)
	
	stars = {}
    max_stars = 200
	for i=1, max_stars do   -- generate the coords of our stars
         local x = math.random(0, love.graphics.getWidth())   -- generate a "random" number for the x coord of this star
         local y = math.random(0, ground)   -- both coords are limited to the screen size, minus 5 pixels of padding
         stars[i] = {x, y}   -- stick the values into the table
     end
	 
	 obstacles = {}
	 generation_timer = 0   
end

function love.update(dt)	
	generation_timer = generation_timer+dt
	if generation_timer >= 2 then
		generation_timer = generation_timer - 2
		obstacle = generate_obstacles("spikes", player, worldspeed)
		obstacles[#obstacles+1] = obstacle
	end
    if player.v ~= 0 then
        player.v = player.v + (dt * gravity)
        player.y = player.y + (player.v * dt)
    end
    if player.y > ground - player.r then
        player.y = ground - player.r
        player.v = 0
    end
	
	--print(#obstacles)
	for i=1, #obstacles do
		for j=1, obstacles[i].n do
			obstacles[i].shape[j]:move(-dt*worldspeed, 0)
			obstacles[i].position[j][1] = obstacles[i].position[j][1] - dt*worldspeed
		end
	end
	
	Collider:update(dt)

	for i=1, #stars do   
		--x = stars[i]
		stars[i][1] = stars[i][1] - dt*worldspeed
		if(stars[i][1] < 0) then
			stars[i][1] = love.graphics.getWidth()--math.random(love.graphics.getWidth(), love.graphics.getWidth())
		end
    end

	if worldspeed < 100 then
		worldacceleration = 50
	elseif worldspeed < 250 then
		worldacceleration = 30 
	elseif worldspeed < 400 then
		worldacceleration = 20
	elseif worldspeed < 800 then 
		worldacceleration = 10
	end
	
	if worldspeed < 800 then
		worldspeed = worldspeed + worldacceleration*dt
	end
	
    --[[if joystick ~= nil and math.abs(joystick:getAxis(1)) > 0.2 then
        player.x = player.x + dt*joystick:getAxis(1)*playerspeed
	elseif love.keyboard.isDown("right") then
		player.x = player.x + dt*playerspeed
    end

    if joystick ~= nil and math.abs(joystick:getAxis(4)) > 0.2 then
        player.x = player.x + dt*joystick:getAxis(4)*playerspeed
	elseif love.keyboard.isDown("left") then
        player.x = player.x - dt*playerspeed
    end]]--
	
	local time = love.timer.getTime()
	
    if((joystick ~= nil and joystick:isGamepadDown("a")) or love.keyboard.isDown(" ") )then --and player.v == 0) then
        if timer_start == nil or (time-timer_start)*1000 < timer_limit then
			if timer_start == nil then
				timer_start = time
				timer_limit = 0.4375 * worldspeed
				--print(timer_limit)
			end
			player.v = -jumpspeed
		end
        --current_animation = jump_animation
	end
    if(player.v == 0) then
		if timer_start ~= nil then
			print(time-timer_start)
		end
		timer_start = nil
        --current_animation = walk_animation
	end
	player.collider:moveTo(player.x+player.width/2, player.y+player.height/2)
    --current_animation:update(dt) 
end


function love.draw()
	love.graphics.line(0, ground, love.graphics.getWidth(), ground)
    --current_animation:draw(player.x, player.y)
	love.graphics.rectangle("line", player.x, player.y, player.width, player.height)
	player.collider:draw('fill')
	-- draw stars
	for i=1, #stars do   -- loop through all of our stars
		love.graphics.point(stars[i][1], stars[i][2])   -- draw each point
	end
	
	love.graphics.print("Current world speed: "..tostring(worldspeed), 6, 10)
	love.graphics.print("Current world acceleration: "..tostring(worldacceleration), 6, 30)
	
	love.graphics.print("Current player speed: "..tostring(playerspeed), 6, 50)
	 
 	for i=1, #obstacles do
		--print("obstacle at:", obstacles[i].shape:center())
		for j=1, obstacles[i].n do
 			obstacles[i].shape[j]:draw('line')
		    love.graphics.setColor(200, 20, 20)
			local x = obstacles[i].position[j][1]
			local y = obstacles[i].position[j][2]
			local w = obstacles[i].position[j][3]
			local h = obstacles[i].position[j][4]
			love.graphics.rectangle("fill", x, y, w, h)
		    love.graphics.setColor(255, 255, 255)
		end
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
