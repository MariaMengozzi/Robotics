-- Put your global variables here

MOVE_STEPS = 15
MAX_VELOCITY = 20
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


function step()
	n_steps = n_steps + 1

	if (robot.light[1].value < robot.light[21].value) or (robot.light[12].value < robot.light[18].value) then
		-- turn right
		left_v = MAX_VELOCITY
		right_v = 0
		robot.wheels.set_velocity(left_v, right_v)
	elseif (robot.light[1].value < robot.light[3].value) or (robot.light[12].value < robot.light[9].value) then
		-- turn left
		left_v = 0
		right_v = MAX_VELOCITY
		robot.wheels.set_velocity(left_v, right_v)
	elseif (robot.light[1].value < robot.light[12].value) then
		-- rotate
		left_v = -MAX_VELOCITY
		right_v = MAX_VELOCITY
		robot.wheels.set_velocity(left_v, right_v)
	elseif (robot.light[1].value > robot.light[3].value) then
		-- proceeds in that direction
		left_v = MAX_VELOCITY
		right_v = MAX_VELOCITY
		robot.wheels.set_velocity(left_v, right_v)
	elseif (robot.light[1].value == 0) or (robot.light[12].value == 0) then
		-- moves randomically
		left_v = robot.random.uniform(0,MAX_VELOCITY)
		right_v = robot.random.uniform(0,MAX_VELOCITY)
		robot.wheels.set_velocity(left_v, right_v)
	end
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
