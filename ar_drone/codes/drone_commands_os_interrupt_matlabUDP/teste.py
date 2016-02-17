# import os
# os.system("rostopic pub -1 /ardrone/land std_msgs/Empty")
import termios, fcntl, sys, subprocess, os
from time import sleep
import socket
execfile("drone_commands.py")

# os.system("rostopic pub -1 /ardrone/land std_msgs/Empty")

UDP_IP = "127.0.0.1"
UDP_PORT = 5005

sock = socket.socket(socket.AF_INET, # Internet
socket.SOCK_DGRAM) # UDP
sock.bind((UDP_IP, UDP_PORT))

pause = 1.4

p = subprocess.Popen(rot_stop)
sleep(pause)
subprocess.Popen.terminate(p)

p = subprocess.Popen(rot_stop)
sleep(pause)
subprocess.Popen.terminate(p) 

fd = sys.stdin.fileno()

oldterm = termios.tcgetattr(fd)
newattr = termios.tcgetattr(fd)
newattr[3] = newattr[3] & ~termios.ICANON & ~termios.ECHO
termios.tcsetattr(fd, termios.TCSANOW, newattr)

oldflags = fcntl.fcntl(fd, fcntl.F_GETFL)
fcntl.fcntl(fd, fcntl.F_SETFL, oldflags | os.O_NONBLOCK)

try:
    while 1:
        try:
            c, addr = sock.recvfrom(1024) # buffer size is 1024 bytes
            print "received message:", c
            print "Got character", str(c)
            if str(c) == "t":
            	print "Got character", str(c)
            	# tafe off
            	p = subprocess.Popen(["rostopic", "pub", "-1", "/ardrone/takeoff", "std_msgs/Empty"])
            	sleep(pause)
            	subprocess.Popen.terminate(p)
            if str(c) == "l":
            	print "Got character", str(c)
            	# land
            	p = subprocess.Popen(["rostopic", "pub", "-1", "/ardrone/land", "std_msgs/Empty"])
            	sleep(pause)
            	subprocess.Popen.terminate(p)
            if str(c) == "a":
            	print "Got character", str(c)
            	# rotate left
            	p = subprocess.Popen(rot_left)
            	sleep(pause)
            	subprocess.Popen.terminate(p)
            	# subprocess.Popen.wait(p)
            if str(c) == "d":
            	# rotate right
            	print "Got character", str(c)
            	p = subprocess.Popen(rot_right)
            	sleep(pause)
            	subprocess.Popen.terminate(p)
            if str(c) == "x":
            	# stop rotation
            	print "Got character", str(c)
            	p = subprocess.Popen(rot_stop)
            	sleep(pause)
            	subprocess.Popen.terminate(p)            	
            if str(c) == "w":
            	print "Got character", str(c)
            	p = subprocess.Popen(forward)
            	sleep(pause)
            	subprocess.Popen.terminate(p) 
            if str(c) == "e":
            	print "Got character", str(c)
            	p = subprocess.Popen(flyup)
            	sleep(pause)
            	subprocess.Popen.terminate(p)
            if str(c) == "q":
            	print "Got character", str(c)
            	p = subprocess.Popen(flydown)
            	sleep(pause)
            	subprocess.Popen.terminate(p)  
    			# move forward
    		# if str(c) == "s":
    			# move backward

        except IOError:
            sleep(1)
            print "error 1" 
            pass
        	
finally:
    print "error 2"
    termios.tcsetattr(fd, termios.TCSAFLUSH, oldterm)
    fcntl.fcntl(fd, fcntl.F_SETFL, oldflags)