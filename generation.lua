function generate_building(player, worldspeed, previous_building)
	local x = 0
	if previous_building ~= nil then
		x = previous_building.shape.position[1] + previous_building.shape.position[3]
	end
	
	local floor = {}
	local max_gap = worldspeed * 2/3
	local min_gap = worldspeed * 1/3
	local gap = math.random(min_gap, max_gap)
	local min_building = love.window.getWidth()-gap
	local max_building = min_building*2
	local width = math.random(min_building, max_building)
	
	print("gap " .. gap)
	print("width " .. width)

	
	local y = 300
	local height = 8
	floor.shape = Collider:addRectangle(x+gap, y, width, height)
	floor.shape.position = {x+gap, y, width, height}
	floor.shape.type = "floor"
	floor.shape.building = floor
	return floor
end	

function generate_obstacles(player, worldspeed)
	local type = math.random(1, 3)
	if type == 1 then
		obstacle = generate_walls(player, worldspeed)
	elseif type == 2 then
		obstacle = generate_spikes(player, worldspeed)
	elseif type == 3 then
		obstacle = generate_doublejump_obstacle(player, worldspeed)
	elseif type == 4 then
		obstacle = generate_dash_obstacle(player, worldspeed)
	end
	return obstacle
end

function generate_walls(player, worldspeed)
	local obstacle = {}
	obstacle.shape = {}
	local x = love.window.getWidth()
	local y = 150
	local height = 100
	local width = 10
	local wall = Collider:addRectangle(x, y, width, height)
	wall.type = "wall"
	wall.color = {"blue"}
	wall.position = {x, y, width, height}
	local n = 1
	obstacle.n = n
	obstacle.shape[n] = wall

	wall = Collider:addRectangle(x+150, y+10, width, height+50)
	wall.type = "wall"
	wall.color = {"blue"}
	wall.position = {x, y, width, height}
	n = n + 1
	obstacle.n = n
	obstacle.shape[n] = wall
	return obstacle
end

function generate_doublejump_obstacle(player, worldspeed)
	local obstacle = {}
	obstacle.shape = {}
	local x = love.window.getWidth()
	local height = 100
	local width = 10

	--local double_j = Collider:addRectangle(love.window.getWidth()+50, love.graphics.getHeight()/2-100, 5, 20)
	local double_j = Collider:addRectangle(love.window.getWidth()+100, love.graphics.getHeight()/2+50, 50, 5)	
	double_j.type = "double_j"
	double_j.color = "white"
	double_j.position = {love.window.getWidth()*2, 10, 50, 10}
	local n = 1
	obstacle.n = n
	obstacle.shape[n] = double_j

	--double_j = Collider:addRectangle(love.window.getWidth()+50, love.graphics.getHeight()/2-160, 5, 20)
	double_j = Collider:addRectangle(love.window.getWidth(), love.graphics.getHeight()/2+100, 50, 5)
	double_j.type = "double_j"
	double_j.color = "white"
	double_j.position = {love.window.getWidth()*2, 10, 90, 40}
	n = n + 1
	obstacle.n = n
	obstacle.shape[n] = double_j

	return obstacle
end

function generate_spikes(player, worldspeed)
	local obstacle = {}
	obstacle.shape = {}
	local spikes = Collider:addRectangle(love.window.getWidth()*2, 300, 50, 10)
	spikes.type = "spikes"
	spikes.color = "red"
	spikes.position = {love.window.getWidth()*2, 300, 50, 10}
	local n = 1
	obstacle.n = n
	obstacle.shape[n] = spikes
	return obstacle
end


function generate_dash_obstacle(player, worldspeed)
	local obstacle = {}
	return obstacle
end