-- Put your global variables here
local vector = require "vector"

MAXRANGE = 40 --40 cm of radius

MOVE_STEPS = 15
MAX_VELOCITY = 15

PROX_THRESHOLD = 0.01
RANDOM_WALK_THRESHOLD = 0.01
n_steps = 0
L = robot.wheels.axis_length

W = 0.1
S = 0.01
PSmax = 0.99
PWmin = 0.005
alpha = 0.1
beta = 0.05

moving = true


-- Count the number of stopped robots sensed close to the robot
function CountRAB()
  number_robot_sensed = 0
  for i = 1, #robot.range_and_bearing do
    -- for each robot seen, check if it is close enough.
    if robot.range_and_bearing[i].range < MAXRANGE and
      robot.range_and_bearing[i].data[1]==1 then
      number_robot_sensed = number_robot_sensed + 1
    end
  end
  return number_robot_sensed
end

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

	 -- Motor schema
    if (valueOA < RANDOM_WALK_THRESHOLD) then
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

function toDifferential(v)
    return {
        left = 1 * v.length * MAX_VELOCITY - L / 2 * v.angle,
        right = 1 * v.length * MAX_VELOCITY + L / 2 * v.angle
    }
end

function move()
  behaviors = {
        random_walk(),
        collision_avoidance()
    }

	sumV = {length = 0.0, angle = 0.0}

	for i=1,#behaviors do
        sumV = vector.vec2_polar_sum(sumV, behaviors[i])
    end

	-- to differential
	velocities = toDifferential(sumV)

	return limit_velocity(velocities.left), limit_velocity(velocities.right)

end


--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
  left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
  robot.wheels.set_velocity(left_v,right_v)
  moving = true
end



--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
  N = CountRAB()
  t = robot.random.uniform() -- random number


  if moving then 

    Ps = math.min(PSmax,S+alpha*N)

    if t <= Ps then
      -- send something to signal your presence (not moving) to the other robots
      robot.range_and_bearing.set_data(1,1)
      left_v = 0
      right_v = 0
      moving = false
    else
      -- send something to signal to the other robots that you are moving
    robot.range_and_bearing.set_data(1,0)
    left_v, right_v = move()
    moving = true
    end

  else
    Pw = math.max(PWmin,W-beta*N)

    if t <= Pw then
        -- send something to signal to the other robots that you are moving
      robot.range_and_bearing.set_data(1,0)
      left_v, right_v = move()
      moving = true
    else 
      -- send something to signal your presence (not moving) to the other robots
      robot.range_and_bearing.set_data(1,1)
      left_v = 0
      right_v = 0
      moving = false
    end

  end

	robot.wheels.set_velocity(left_v,right_v)

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
