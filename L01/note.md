# Notes lab 1

https://www.argos-sim.info/plow2015/

![img](https://www.argos-sim.info/plow2015/foot-bot.png)

the robot has a symmetric center

the robot has proximity and led sensors that are for very short distance

it has ambient light detector, in fact in argos we can put some light bulbs in the ambient, so these sensors are connected to these bulbs.

it is also possible have virtual sensors to put over these ones

the range and bearing system is used as communication system between robots, it is like broadcast

the distance sensor has a large range than proximity.

it has a gripper used for grabbing some objects

the ground sensor reflect the ground as black and white.



for starting to program it we have to describe the environment. 

each simulation has a one file.argos in which we describe the ambient and the robot, and a controller file.lua that contain the scripts for the behavior of the robot and it is the entry point, then we can have other lua files for libraries.

in the example is not set, but it is recommended to set the random seed number in order to have reproducibility. in fact if we don´t set it, it gets the time in second as seed



to test the robot in a simil real condition in the lua file you need also to set the noise level, general is from 0.1 to 5 not more

the footbot_proximity sensor is used to detect obstacle

We can have more than one controllers that control the robot.

use the editor of argos only for debugging reasons



Every tic of the simulator the step function of each controller is called, for this reason it is better not having complicated functions performed by the robot inside the step function. so as much is shorter the step more safer is the program. during the step usually the robot not change the environment. generally we have parallel operation during this phase.

in the link above we have a description of the robot, so you can watch how the sensors are distributed in the robot