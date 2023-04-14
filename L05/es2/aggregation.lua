-- implement with subsumption architecture
-- Put your global variables here

MAXRANGE = 40 --40 cm of radius

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
Ds = 0.99 -- se sono sul nero lo metto, altrimenti no
Dw = 0.01 -- se sono sul nero lo metto, altrimenti no

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

function on_spot(lock, velocities)
  mylock = true
	myvelocities = {}
	n_steps = n_steps + 1
	
  -- Check if on spot
  spot = false
  for i=1,4 do
    if robot.motor_ground[i].value == 0 then
      spot = true
      break
    end
  end

  if spot == true then
    left_v = 0
    right_v = 0
  end
  

	myvelocities = {left = limit_velocity(left_v), right = limit_velocity(right_v)}
	
	if not lock then
		return mylock,myvelocities
	else
		return lock,velocities
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
		return mylock,myvelocities
	else
		return lock,velocities
	end
end



function collision_avoidance(lock, velocities)
	mylock = false
	myvelocities = {}

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
	
	myvelocities = {left = limit_velocity(left_v), right = limit_velocity(right_v)}
	
	if not lock and mylock then
		return mylock,myvelocities
	else
		return lock,velocities
	end
end

function move()

  lock,velocities =	on_spot(random_walk(collision_avoidance(false,{})))

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
    D = 0
    if on_spot() == true then
      D = Ds
    end

    Ps = math.min(PSmax,S+alpha*N+D)

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
    D = 0
    if on_spot() then
      D = Ds
    end

    Pw = math.max(PWmin,W-beta*N+D)

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
