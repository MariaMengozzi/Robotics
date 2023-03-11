-- Put your global variables here

MOVE_STEPS = 15
MAX_VELOCITY = 20
LIGHT_THRESHOLD = 1.5

n_steps = 0

function init()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
end


function step()
	n_steps = n_steps + 1
	value = robot.proximity[1].value
	idx = 1 
	for i=2,#robot.proximity do
		if value < robot.proximity[i].value then
			idx = i
			value = robot.proximity[i].value
			if value == 1 then 
				log("collisione ", i ) 
			end
		end
	end

	--[[ log("1 ->",robot.proximity[1].value)
	log("3 ->",robot.proximity[3].value)
	log("21 ->",robot.proximity[21].value)
	log("6 ->",robot.proximity[18].value) ]]

	if value == 0 or 
	(robot.proximity[1].value == 0 and 
	robot.proximity[3].value < 0.01 and 
	robot.proximity[22].value < 0.01 and
	robot.proximity[6].value < 0.01 and 
	robot.proximity[19].value < 0.01) then
		-- moves randomically
		left_v = robot.random.uniform(0,MAX_VELOCITY)
		right_v = robot.random.uniform(0,MAX_VELOCITY)
	else	
		if (idx >=1 and idx <= 3) or (idx >=22 and idx <= 24) then
			-- rotate on itself randomically
			left_v = robot.random.uniform(0,MAX_VELOCITY)
			right_v = -robot.random.uniform(0,MAX_VELOCITY)
		elseif (robot.proximity[6].value > robot.proximity[19].value) or 
		(robot.proximity[3].value > robot.proximity[22].value) then
			-- turn right
			left_v = robot.random.uniform(0,MAX_VELOCITY)
			right_v = 0
		elseif (robot.proximity[6].value < robot.proximity[19].value) or 
		(robot.proximity[3].value < robot.proximity[22].value) then
			-- turn left
			left_v = 0
			right_v = robot.random.uniform(0,MAX_VELOCITY)
		else 
			-- rotate on itself
			left_v = -MAX_VELOCITY
			right_v = MAX_VELOCITY
		end
	end
	robot.wheels.set_velocity(left_v, right_v)
end

function reset()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
end


function destroy()
   -- put your code here
end
