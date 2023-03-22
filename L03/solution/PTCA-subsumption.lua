-- Example code of a possible implementation of the subsumption architecure
-- for phototaxis with collision avoidance.
-- Version 1
--
-- LEVELS:
-- 2) OA
-- 1) PT
-- 0) RW
--
-- Notes:
--  - The implementation of behaviours is just an example.
--  - This implementation is rather simple and limited to one actuator only; in the case of more actuators,
--    more locks have to be introduced.
--  - The implementation adheres to the idea that each level computes its own output signals in parallel.
--
-- Course: Intelligent Robotic Systems (A.Y. 2022/2023), Andrea Roli



-- Put your global variables here

MOVE_STEPS = 15
MAX_VELOCITY = 15
VFACTOR = 5
PROX_THRESHOLD = 0.2
LIGHT_THRESHOLD = 0.01 -- it should be set to a value higher than noise
n_steps = -1


function limit_velocity(v)
  if v > MAX_VELOCITY then
    return MAX_VELOCITY
  elseif v < -MAX_VELOCITY then
    return -MAX_VELOCITY
  else
    return v
  end
end



function random_walk(lock,velocities)
	mylock = true
	myvelocities = {}
	n_steps = n_steps + 1
	if n_steps % MOVE_STEPS == 0 then
		left_v = robot.random.uniform(0,MAX_VELOCITY)
		right_v = robot.random.uniform(0,MAX_VELOCITY)
	end

	myvelocities = {left = limit_velocity(left_v), right = limit_velocity(right_v)}
	
	if not lock then
-- 		log("RW")
		robot.leds.set_all_colors("black")
		return mylock,myvelocities
	else
		return lock,velocities
	end
end



function collision_avoidance(lock,velocities)
	mylock = false
	myvelocities = {}
  value = -1 -- highest value found so far
	idx = -1   -- index of the highest value
	for i=1,#robot.proximity do
		if value < robot.proximity[i].value then
			idx = i
			value = robot.proximity[i].value
		end
	end
	prox_value = robot.proximity[idx].value
	prox_angle = robot.proximity[idx].angle
	if prox_value > PROX_THRESHOLD and prox_angle > 0 and prox_angle <= math.pi/2 then --closest obstacle on front left
	  left_v = prox_value * MAX_VELOCITY
		right_v = 0
		mylock = true
	elseif prox_value > PROX_THRESHOLD and prox_angle < 0 and prox_angle >= -math.pi/2 then --closest obstacle on fron right
		left_v = 0
	  right_v = prox_value * MAX_VELOCITY
		mylock = true
	end
	
	myvelocities = {left = limit_velocity(left_v), right = limit_velocity(right_v)}
	
	if not lock and mylock then
-- 		log("CA")
		robot.leds.set_all_colors("red")
		return mylock,myvelocities
	else
		return lock,velocities
	end
end




function photo_taxis(lock,velocities)
	mylock = false
	myvelocities = {}
	
	value = 0
	idx = -1
	for i = 1,#robot.light do
		if value < robot.light[i].value then
			value = robot.light[i].value
			idx = i
		end
	end

	if value > LIGHT_THRESHOLD then
		if idx == 1 or idx == 24 then
			myvelocities = {left = MAX_VELOCITY , right = MAX_VELOCITY}
			mylock = true
		elseif idx > 1 and idx <= 12 then
			myvelocities = {left = 0, right = MAX_VELOCITY}
			mylock = true
		elseif idx < 24 and idx >= 13 then
			myvelocities = {left = MAX_VELOCITY, right = 0}
			mylock = true
		end
	end

	if not lock and mylock then
-- 		log("PT")
		robot.leds.set_all_colors("yellow")
		return mylock,myvelocities
	else
		return lock,velocities
	end
end








--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
  n_steps = -1
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
end





--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
	
	lock,velocities =	random_walk(photo_taxis(collision_avoidance(false,{})))
	robot.wheels.set_velocity(velocities.left,velocities.right)

end



--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
  n_steps = -1
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
end



--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
end
