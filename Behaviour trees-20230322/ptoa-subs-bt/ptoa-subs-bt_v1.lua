-- Example code with BT implementing a subsumption architecure
-- for phototaxis with obstacle avoidance.
-- Version 1
-- Note: the implementation of behaviours is just an example
-- Course: Intelligent Robotic Systems (Andrea Roli)


local luabt = require "luabt"

-- Put your global variables here
MOVE_STEPS = 15
VELOCITY_FACTOR = 4 -- DEPENDENCE: light intensity and height
MAX_VELOCITY = 10
PROX_THRESHOLD = 0.1
LIGHT_THRESHOLD = 0.1
MAX_ANGLE = math.pi/2.5

n_steps = -1


-- To be sure to satisfy the constraint on the maximum velocity (abs)
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




-------- Behaviours --------

function OA_behaviour()
  prox_value, prox_angle, idx = findmax(robot.proximity)
  OArun = false
	if idx >= 0 and prox_value > PROX_THRESHOLD then
		if prox_angle > 0 and prox_angle <= MAX_ANGLE then --closest obstacle on front left
			OArun = true
			left_v = prox_value * MAX_VELOCITY
			right_v = 0
		elseif prox_angle < 0 and prox_angle >= -MAX_ANGLE then --closest obstacle on fron right
			OArun = true
			left_v = 0
			right_v = prox_value * MAX_VELOCITY
		end
	end	
	if OArun then
			robot.wheels.set_velocity(limit_velocity(left_v),limit_velocity(right_v))
    return true --(running)
  else
    return false, false -- (not running , fail)
  end
end


function PT_behaviour()
  sum_l = 0
  for i=1,12 do
    sum_l = sum_l + robot.light[i].value
  end
  sum_r = 0
  for i=13,24 do
    sum_r = sum_r + robot.light[i].value
  end
  if sum_l > LIGHT_THRESHOLD or sum_r > LIGHT_THRESHOLD then
    left_v = MAX_VELOCITY - limit_velocity(sum_l * VELOCITY_FACTOR)
    right_v = MAX_VELOCITY - limit_velocity(sum_r * VELOCITY_FACTOR)
    robot.wheels.set_velocity(limit_velocity(left_v),limit_velocity(right_v))
  return true
  else
    return false, false
  end
end


function RW_behaviour()
  n_steps = n_steps + 1
  if n_steps % MOVE_STEPS == 0 then
    left_v = robot.random.uniform(0,MAX_VELOCITY)
    right_v = robot.random.uniform(0,MAX_VELOCITY)
  end
  robot.wheels.set_velocity(limit_velocity(left_v),limit_velocity(right_v))
  return true, false -- (running, fail)
end



-------- BT --------

ptoa_root_node = {
  type = "selector",
  children = {
--     OA
	function()
	  log("Tick: OA")
	  return OA_behaviour()
	end,
-- PT
	function()
	  log("Tick: PT")
	  return PT_behaviour()
	end,
--     RW
    function()
      log("Tick: RW")
      return RW_behaviour()
    end,
  }
}




--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
  n_steps = -1
  ptoa_bt = luabt.create(ptoa_root_node)
end



--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
  ptoa_bt()
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
  -- Output the Euclidean distance from the light
  -- DEPENDENCE: argos file
  x = robot.positioning.position.x
  y = robot.positioning.position.y
  d = math.sqrt((x-1.5)^2 + y^2)
  print('f_distance ' .. d)
end
