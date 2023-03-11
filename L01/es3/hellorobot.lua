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

	if value == 0 or 
	(robot.proximity[1].value == 0 and 
	robot.proximity[3].value < 0.001 and 
	robot.proximity[22].value < 0.001 and
	robot.proximity[6].value < 0.001 and 
	robot.proximity[19].value < 0.001) then
		-- if no obstacle the behaviour is set in order to reach the light
	if (robot.light[1].value < robot.light[21].value) or (robot.light[12].value < robot.light[18].value) then
			-- turn right
			left_v = robot.random.uniform(0,MAX_VELOCITY)
			right_v = 0
		elseif (robot.light[1].value < robot.light[3].value) or (robot.light[12].value < robot.light[9].value) then
			-- turn left
			left_v = 0
			right_v = robot.random.uniform(0,MAX_VELOCITY)
		elseif (robot.light[1].value < robot.light[12].value) then
			-- rotate
			left_v = -MAX_VELOCITY
			right_v = MAX_VELOCITY
		elseif (robot.light[1].value > robot.light[3].value) then
			-- proceeds in that direction
			left_v = robot.random.uniform(0,MAX_VELOCITY)
			right_v = robot.random.uniform(0,MAX_VELOCITY)
		elseif (robot.light[1].value == 0) or (robot.light[12].value == 0) then
			-- moves randomically
			left_v = robot.random.uniform(0,MAX_VELOCITY)
			right_v = robot.random.uniform(0,MAX_VELOCITY)
		end
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

--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
	n_steps = -1
end



--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
   x = robot.positioning.position.x
   y = robot.positioning.position.y
   d = math.sqrt((1-x)^2 + (1-y)^2)
   log("distance: "..d)
end
