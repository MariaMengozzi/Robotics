-- Put your global variables here

local vector = require "vector"

MOVE_STEPS = 15
MAX_VELOCITY = 15

PROX_THRESHOLD = 0.2
LIGHT_THRESHOLD = 0.01 -- it should be set to a value higher than noise
RANDOM_WALK_THRESHOLD = 0.01
n_steps = 0
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

	 -- Motor schema
    if (valueP < RANDOM_WALK_THRESHOLD) and (valueOA < RANDOM_WALK_THRESHOLD) then
        -- move random
        if n_steps % MOVE_STEPS == 0 then
            randomAngle = robot.random.uniform(-math.pi, math.pi)
            n_steps = 0
        end
        n_steps = n_steps + 1
        return {length = 1, angle = randomAngle}
    end
    
    return {length = 0.0, angle = 0.0}

end



function collision_avoidance()
	value, proximityAngle, idx = findmax(robot.proximity)
	return { length = value, angle = (-(proximityAngle/proximityAngle)*math.pi + proximityAngle)  }
end


function photo_taxis()
	value, lightAngle, idx = findmax(robot.light)
	return {length = 1 - value, angle = lightAngle} --actractive force
end


function toDifferential(v)
    return {
        left = 1 * v.length * MAX_VELOCITY - L / 2 * v.angle,
        right = 1 * v.length * MAX_VELOCITY + L / 2 * v.angle
    }
end

--[[ This function is executed every time you press the 'execute'
     button ]]
function init()

end



--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()

	behaviors = {
        random_walk(),
		photo_taxis(),
        collision_avoidance()
    }

	sumV = {length = 0.0, angle = 0.0}

	for i=1,#behaviors do
        sumV = vector.vec2_polar_sum(sumV, behaviors[i])
    end

	-- to differential
	velocities = toDifferential(sumV)

	robot.wheels.set_velocity(limit_velocity(velocities.left), limit_velocity(velocities.right))

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
