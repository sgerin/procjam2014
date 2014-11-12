function generate_obstacles(type, player, worldspeed)
	if type == "wall" then
		obstacle = generate_walls(player, worldspeed)
	elseif type == "spikes" then
		obstacle = generate_spikes(player, worldspeed)
	elseif type == "doublejump" then
		obstacle = generate_doublejump_obstacle(player, worldspeed)
	elseif type == "dash" then 
		obstacle = generate_dash_obstacle(player, worldspeed)
	end
	return obstacle
end

function generate_walls(player, worldspeed)
	local obstacle = {}
	return obstacle
end

function generate_spikes(player, worldspeed)
	local obstacle = {}
	local spikes = Collider:addRectangle(love.window.getWidth()*2, 300+player.r, 50, 10)
	obstacle.shape = spikes
	obstacle.type = "spikes"
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