require("AnAL")
require 'generation'
HC = require "hardoncollider"
Gamestate = require "hump.gamestate"
Timer = require "hump.timer"

function on_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
	if shape_a == player.collider or shape_b == player.collider then
		if shape_a.obstacle_type == "wall" or shape_b.obstacle_type == "wall" then
			print("wall")
			player.dir = -player.dir
			player.x = player.x + player.dir*dt*worldspeed
			player.collider:moveTo(player.x+10, player.y+18)
			player.can_jump = true
			timer_start = nil
			Timer.clear()
			Timer.add(1, function() if player.dir < 0 then player.dir = -player.dir end end)
			--worldspeed = worldspeed * 2/3
			--player.dir = -player.dir
		end
		if shape_a.type == "floor" or shape_b.type == "floor" then
			local building = shape_a.building or shape_b.building
	--print(building)
			if building ~= current_building then 
				print("changing building")
				building_changed = true
			end
			current_building = building
			player.can_jump = true
			timer_start = nil
			colliding_with_floor = true
		end		
	end
end

function collision_stop(dt, shape_a, shape_b)
	if shape_a == player.collider or shape_b == player.collider then
		if shape_a.type == "floor" or shape_b.type == "floor" then
			colliding_with_floor = false
		end
	end
end

function love.keyreleased(key)
   if key == " " then
	   player.can_jump = false
   end
end

function love.load()
	-- joystick, window and collider init
	local joysticks = love.joystick.getJoysticks()
    joystick = joysticks[1]
	love.window.setMode(960, 320)
	Collider = HC(100, on_collision, collision_stop)
	math.randomseed(os.time())
	
	bg_scroll_factor = 0.15
	mg_scroll_factor = 0.4
	fg_scroll_factor = 1
    worldspeed = 100
	worldacceleration = 50
    jumpspeed = 300
    ground = 300 -- height of ground
    gravity = 700
    player = {
        x = 70,
        y = 200,
        r = 15,
        v = jumpspeed, 
		height = 24,
		width = 24, 
		dir = 1,
		can_jump = true,
		is_jumping = false
    }
	player.collider = Collider:addRectangle(player.x+10, player.y+20, 12, 14)
	
	stars = {}
    max_stars = 200
	for i=1, max_stars do   -- generate the coords of our stars
         local x = math.random(0, love.graphics.getWidth())   -- generate a "random" number for the x coord of this star
         local y = math.random(0, ground)   -- both coords are limited to the screen size, minus 5 pixels of padding
         stars[i] = {x, y}   -- stick the values into the table
     end
	 
	 obstacles = {}
	 buildings = {}
	 buildings[1] = generate_building(player, worldspeed, nil)
	 buildings[2] = generate_building(player, worldspeed, buildings[1])
	 current_building = buildings[1]
	 building_changed = false
	 colliding_with_floor = true
	 generation_timer = 0   
end

function love.update(dt)
    Timer.update(dt)
	
	if building_changed then
		buildings[#buildings+1] = generate_building(player, worldspeed, buildings[#buildings])
		building_changed = false
	end
	
	print(#buildings)
	--generation_timer = generation_timer+dt
	if generation_timer >= 1 then
		generation_timer = generation_timer - 1
		obstacle = generate_obstacles(player, worldspeed)
		obstacles[#obstacles+1] = obstacle
	end
	
    if player.v ~= 0 then -- if the player vertical velocity (which is negative when jumping) is different from zero then 
        player.v = player.v + (dt * gravity) -- we increase it (getting it to zero)
        player.y = player.y + (player.v * dt) -- and change the player vertical position (upward if player.v < 0 and downward otherwise)
	end
	if colliding_with_floor and player.v > 0 then
        player.y = ground
        player.v = 0
    end
	if player.y > love.window.getHeight() then
		print("falling")
	end
	
	for i=1, #obstacles do
		for j=1, obstacles[i].n do
			shape = obstacles[i].shape[j]
			shape:move(-dt*worldspeed*player.dir, 0)
			shape.position[1] = shape.position[1] - dt*worldspeed*player.dir
			obstacles[i].shape[j] = shape
		end
	end
	
	for i=1, #buildings do
		shape = buildings[i].shape
		shape:move(-dt*worldspeed*player.dir, 0)
		shape.position[1] = shape.position[1] - dt*worldspeed*player.dir
		buildings[i].shape = shape
	end
	
	Collider:update(dt)

	for i=1, #stars do   
		--x = stars[i]
		stars[i][1] = stars[i][1] - dt*worldspeed*bg_scroll_factor*player.dir
		if(stars[i][1] < -100) then
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
	elseif worldspeed > 800 then
		worldacceleration = 0
	end
	
	worldspeed = worldspeed + worldacceleration*dt
	
	local time = love.timer.getTime()
	
    if(player.can_jump == true and ((joystick ~= nil and joystick:isGamepadDown("a")) or love.keyboard.isDown(" ")))then --and player.v == 0) then
        if timer_start == nil or (time-timer_start)*1000 < timer_limit then
			if timer_start == nil then
				timer_start = time
				timer_limit = 0.4375 * worldspeed
				--print(timer_limit)
			end
			player.v = -jumpspeed
			player.is_jumping = true
		end
        --current_animation = jump_animation
	end
    if(player.v == 0) then
		if timer_start ~= nil then
			print(time-timer_start)
		end
		timer_start = nil
		player.can_jump= true
        --current_animation = walk_animation
	end
	player.collider:moveTo(player.x+10, player.y+18)
    --current_animation:update(dt) 
end


function love.draw()
	-- draw horizon
	--love.graphics.line(0, ground, love.graphics.getWidth(), ground)

	-- draw player "sprites" and hitbox
	love.graphics.rectangle("line", player.x, player.y, player.width, player.height)
	player.collider:draw('fill')

	-- draw stars
	for i=1, #stars do   -- loop through all of our stars
		love.graphics.point(stars[i][1], stars[i][2])   -- draw each point
	end
	
	 
 	for i=1, #obstacles do
		for j=1, obstacles[i].n do
			shape = obstacles[i].shape[j]
 			shape:draw('line')
		    love.graphics.setColor(200, 20, 20)
			local x = shape.position[1]
			local y = shape.position[2]
			local w = shape.position[3]
			local h = shape.position[4]
 		    love.graphics.setColor(255, 255, 255)
		end
 	end
	
 	for i=1, #buildings do
		shape = buildings[i].shape
 		shape:draw('line')
 	end
	
	-- draw game infos
	love.graphics.print("Current world speed: "..tostring(worldspeed), 6, 10)
	love.graphics.print("Current world acceleration: "..tostring(worldacceleration), 6, 30)
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
