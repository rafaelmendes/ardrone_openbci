import rospy

# Import the messages we're interested in sending and receiving
from geometry_msgs.msg import Twist  	 # for sending commands to the drone
from std_msgs.msg import Empty       	 # for land/takeoff/emergency
from ardrone_autonomy.msg import Navdata # for receiving navdata feedback

# Some Constants
COMMAND_PERIOD = 100 #ms

# Allow the controller to publish to the /ardrone/takeoff, land and reset topics
pubTakeoff = rospy.Publisher('/ardrone/takeoff', Empty, queue_size=1)

rospy.init_node('ardrone_keyboard_controller')

pubTakeoff.publish(Empty())