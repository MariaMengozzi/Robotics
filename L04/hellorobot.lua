-- Put your global variables here

local vector = require "vector"

MOVE_STEPS = 15
MAX_VELOCITY = 15
VFACTOR = 5
PROX_THRESHOLD = 0.2
LIGHT_THRESHOLD = 0.01 -- it should be set to a value higher than noise
RANDOM_WALK_THRESHOLD = 0.01
n_steps = -1
L = robot.wheels.axis_length



function limit_velocity(v)
  if v > MAX_VELOCITY then
    return MAX_VELOCITY
  elseif v < -MAX_VELOCITY then
    return -MAX_VELOCITY
  else
    return v
  end
end

-- Return max value along with its angle and index of an array of sensor readings 
function findmax(sensor)
  value = sensor[1].value
  idx = 1
  for i=2,#sensor do
    if value < sensor[i].value then
      idx = i
      value = sensor[i].value
    end
  end
  return value, sensor[idx].angle, idx
end


function random_walk()
	-- get the vale from the sensors
	valueOA, angleOA, idxOA = findmax(robot.proximity)
	valueP, angleP, idxP = findmax(robot.light)

	if (valueOA <= RANDOM_WALK_THRESHOLD and valueP <= RANDOM_WALK_THRESHOLD) then
		return {length = 1, angle = robot.random.uniform(0, math.pi)}
	else
		return {length = 0, angle = 0}
	end

end



function collision_avoidance()
	value, angle, idx = findmax(robot.proximity)
	if angle < 0 then 
		return {length = value, angle = math.pi + angle} --repulsive force
	else 
		return {length = value, angle = angle - math.pi}
	end
end


function photo_taxis()
	value, angle, idx = findmax(robot.light)
	return {length = 1 - value, angle = angle} --actractive force
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
	n_steps = n_steps + 1
	randomV = random_walk()
	pV = photo_taxis()
	oaV = collision_avoidance()

	sumV = vector.vec2_polar_sum(randomV, pV)
	sumV = vector.vec2_polar_sum(sumV, oaV)

	left_v = limit_velocity((MAX_VELOCITY * 1 * sumV.length) - (sumV.angle * L/2))
	right_v = limit_velocity((MAX_VELOCITY * 1 * sumV.length) + (sumV.angle * L/2))

	
	robot.wheels.set_velocity(left_v, right_v)

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
