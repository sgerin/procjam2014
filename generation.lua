function generate_obstacles(player, worldspeed)
	local type = math.random(1, 2)
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
	wall.obstacle_type = "wall"
	wall.color = {"blue"}
	wall.position = {x, y, width, height}
	local n = 1
	obstacle.n = n
	obstacle.shape[n] = wall

	wall = Collider:addRectangle(x+70, y+10, width, height+50)
	wall.obstacle_type = "wall"
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

	local double_j = Collider:addRectangle(love.window.getWidth()+50, love.graphics.getHeight()/2-100, 5, 20)
	double.obstacle_type = "double_j"
	double.color = "white"
	double.position = {love.window.getWidth()*2, 10, 50, 10}
	local n = 1
	obstacle.n = n
	obstacle.shape[n] = double_j

	double_j = Collider:addRectangle(love.window.getWidth()+50, love.graphics.getHeight()/2-160, 5, 20)
	double.obstacle_type = "double_j"
	double.color = "white"
	double.position = {love.window.getWidth()*2, 10, 90, 40}
	local n = 1
	obstacle.n = n
	obstacle.shape[n] = double_j

	return obstacle
end

function generate_spikes(player, worldspeed)
	local obstacle = {}
	obstacle.shape = {}
	local spikes = Collider:addRectangle(love.window.getWidth()*2, 300, 50, 10)
	spikes.obstacle_type = "spikes"
	spikes.color = "red"
	spikes.position = {love.window.getWidth()*2, 300, 50, 10}
	local n = 1
	obstacle.n = n
	obstacle.shape[n] = spikes
	return obstacle
end


function generate_doublejump_obstacle(player, worldspeed)
	local obstacle = {}
	return obstacle
end

function generate_dash_obstacle(player, worldspeed)
	local obstacle = {}
	return obstacle
end