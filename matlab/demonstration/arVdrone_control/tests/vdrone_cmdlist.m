open_first_view = 'rosrun image_view image_view image:=/ardrone/image_raw &';

take_off = 'rostopic pub -1 /ardrone/takeoff std_msgs/Empty';

land = 'rostopic pub -1 /ardrone/land std_msgs/Empty';

rot_left = 'rostopic pub -r 10 /cmd_vel geometry_msgs/Twist ''{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0, y: 0.0, z: 1.0}}''';

rot_right = 'rostopic pub -r 10 /cmd_vel geometry_msgs/Twist  ''{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0, y: 0.0, z: -1.0}}''';

rot_stop = 'rostopic pub -r 10 /cmd_vel geometry_msgs/Twist  ''{linear:  {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0, y: 0.0, z: 0.0}}''';

forward = 'rostopic pub -r 10 /cmd_vel geometry_msgs/Twist  ''{linear:  {x: 1.0, y: 0.0, z: 0.0}, angular: {x: 0.0, y: 0.0, z: 0.0}}''';

flyup = 'rostopic pub -r 10 /cmd_vel geometry_msgs/Twist  ''{linear:  {x: 0.0, y: 0.0, z: 1.0}, angular: {x: 0.0, y: 0.0, z: 0.0}}''';

flydown = 'rostopic pub -r 10 /cmd_vel geometry_msgs/Twist  ''{linear:  {x: 0.0, y: 0.0, z: -1.0}, angular: {x: 0.0, y: 0.0, z: 0.0}}''';