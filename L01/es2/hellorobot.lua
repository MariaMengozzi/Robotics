-- Put your global variables here

MOVE_STEPS = 15
MAX_VELOCITY = 15
LIGHT_THRESHOLD = 1.5

n_steps = 0


--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
end



--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
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

	if value == 0 then
		left_v = robot.random.uniform(0,MAX_VELOCITY)
		right_v = robot.random.uniform(0,MAX_VELOCITY)
	else
		if (robot.proximity[6].value > robot.proximity[19].value) or 
		(robot.proximity[3].value > robot.proximity[22].value) then
			left_v = MAX_VELOCITY
			right_v = 0
		elseif (robot.proximity[6].value < robot.proximity[19].value) or 
		(robot.proximity[3].value < robot.proximity[22].value)  then
			left_v = 0
			right_v = MAX_VELOCITY
		elseif idx >= 6 and idx <= 18 then
			left_v = robot.random.uniform(0,MAX_VELOCITY)
			right_v = robot.random.uniform(0,MAX_VELOCITY)
		else 
			left_v = -MAX_VELOCITY
			right_v = MAX_VELOCITY
		end
	end
	robot.wheels.set_velocity(left_v, right_v)
end

--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
end



--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end
