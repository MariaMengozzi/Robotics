-- implemented with subsumption architecture
-- Put your global variables here

MAXRANGE = 30 --30 cm of radius

MOVE_STEPS = 15
MAX_VELOCITY = 15
VFACTOR = 5
PROX_THRESHOLD = 0.01
n_steps = -1


W = 0.1
S = 0.01
PSmax = 0.99
PWmin = 0.005
alpha = 0.1
beta = 0.05
Ds = 0.9 -- se sono sul nero lo metto, altrimenti no
Dw = 0.001 -- se sono sul nero lo metto, altrimenti no

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

	n_steps = n_steps + 1
	if n_steps % MOVE_STEPS == 0 then
		left_v = robot.random.uniform(0,MAX_VELOCITY)
		right_v = robot.random.uniform(0,MAX_VELOCITY)
	end

	return limit_velocity(left_v),  limit_velocity(right_v)
end



function collision_avoidance()
  left_v, right_v = random_walk()
  prox_value, prox_angle, idx = findmax(robot.proximity)

	if prox_value > PROX_THRESHOLD and prox_angle > 0 and prox_angle <= math.pi/2 then --closest obstacle on front left
	  left_v = prox_value * MAX_VELOCITY
		right_v = 0
		mylock = true
	elseif prox_value > PROX_THRESHOLD and prox_angle < 0 and prox_angle >= -math.pi/2 then --closest obstacle on fron right
		left_v = 0
	  right_v = prox_value * MAX_VELOCITY
		mylock = true
	end
	
	return limit_velocity(left_v),  limit_velocity(right_v)
end

function aggregate()
  N = CountRAB()
  t = robot.random.uniform() -- random number
  
  if moving then 

    Ps = math.min(PSmax,S+alpha*N + (Ds * on_spot()))

    if t <= Ps then
      -- send something to signal your presence (not moving) to the other robots
      robot.range_and_bearing.set_data(1,1)
      moving = false
      return 0, 0
    else
      -- send something to signal to the other robots that you are moving
      robot.range_and_bearing.set_data(1,0)
      moving = true
      return collision_avoidance()

    end

  else
    Pw = math.max(PWmin,W-beta*N - (Dw * on_spot()))

    if t <= Pw then
        -- send something to signal to the other robots that you are moving
      robot.range_and_bearing.set_data(1,0)
      moving = true
      return collision_avoidance()
    else 
      -- send something to signal your presence (not moving) to the other robots
      robot.range_and_bearing.set_data(1,1)
      moving = false
      return 0, 0
    end
  end
end

function on_spot()
  -- Check if on spot
  spot = 0
  for i=1,4 do
    if robot.motor_ground[i].value == 0 then
      spot = 1
      break
    end
  end

  return spot


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

  left_v, right_v = aggregate()
  if moving == true then
      robot.leds.set_all_colors("green")
  else
    	robot.leds.set_all_colors("red")
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