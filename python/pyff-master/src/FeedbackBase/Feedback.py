# Feedback.py -
# Copyright (C) 2007-2011  Bastian Venthur
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

"""
This module contains the Feedback class, which is the baseclass of all
feedbacks.
"""


import logging
import threading
import datetime
import sys
import cPickle as pickle
from threading import Event, Timer
import socket
import json


class Feedback(object):
    """
    Base class for all feedbacks.

    This class provides methods which are called by the FeedbackController on
    certain events. Override the methods as needed.

    As a bare minimum you should override the :func:`on_play` method in your
    derived class to do anything useful.

    To get the data from control signals, you can use the `_data` variable
    in your feedback which will always hold the latest control signal.

    To get the data from the interaction signals, you can use the variable
    names just as sent by the GUI.

    This class provides the :func:`send_parallel` method which you can use to
    send arbitrary data to the parallel port. You don't have to override this
    method in your feedback.

    Example::

        from FeedbackBase.Feedback import Feedback

        class MyFeedback(Feedback):

        def on_init(self):
            self.logger.debug("Feedback successfully loaded.")

        def on_play(self):
            self.logger.debug("Feedback started.")

        def on_quit(self):
            self.logger.debug("Feedback quit.")

    """

    def __init__(self, port_num=None):
        """
        Initializes the feedback.

        You should not override this method, override on_init instead. If you
        must override this method, make sure to call
        ``Feedback.__init__(self, pp)`` before anything else in your overridden
        __init__ method.
        """

        self._data = None
        self.logger = logging.getLogger("FB." + self.__class__.__name__)
        """Inherited by all sub classes. Use this for logging."""

        self.logger.debug("Loaded my logger.")
        # Setup the parallel port
        self._pport = None
        if sys.platform == 'win32':
            try:
                from ctypes import windll
                self._pport = windll.inpout32
            except:
                self.logger.warning("Could not load inpout32.dll. Please make sure it is located in the system32 directory")
        else:
            try:
                import parallel
                self._pport = parallel.Parallel()
            except:
                self.logger.warning("Unable to open parallel port! Please install pyparallel to use it.")
        if port_num != None:
            self._port_num = port_num # used in windows only''
        else:
            self._port_num = 0x378
        self._playEvent = Event()
        self._shouldQuit = False

        # Initialize with dummy values so we cann call safely .cancel
        self._triggerResetTimer = Timer(0, None)
        self._triggerResetTime = 0.01

        self.udp_markers_host = '127.0.0.1'
        self.udp_markers_port = 12344

        #self.tcp_markers_enable = False
        #self.tcp_markers_host = '127.0.0.1'
        #self.tcp_markers_port = 12344


    #
    # Internal routines not inteded for overwriting
    #
    def _on_control_event(self, data):
        """
        Store the data in the feedback and call on_control_event.

        You should not override this method, use on_control_event instead.
        """
        self._data = data
        self.on_control_event(data)

    def _on_interaction_event(self, data):
        """
        Store the variable-value pairs in the feedback and call
        on_interaction_event.

        You should not override this method, use on_interaction_event instead.
        """
        data2 = dict()
        for key in data:
            # Oh man, das wird sich nochmal raechen!
            # Originalversion:
            #self.__setattr__(key, data[key])
            # Problem: Variablen wie feedback_opt.fb_port oder
            # fedback_opt(1).bla
            # Loesung: nehme nur den Namen nach dem letzten Punkt
            key2 = key.split(".")[ - 1]
            #self.__setattr__(self.PREFIX+key2, data[key])
            self.__setattr__(key2, data[key])
            data2[key2] = data[key]

        self.on_interaction_event(data2)

    def _on_init(self):
        """
        Calls on_init.

        You should not override this method, use on_init instead.
        """
        self.on_init()

    def _on_play(self):
        """
        Calls on_play.

        You should not override this method, use on_play instead.
        """
        self._udp_markers_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        #if self.tcp_markers_enable:
        #    self.logger.info("Connecting to " + self.tcp_markers_host + ":" + str(self.tcp_markers_port))
        #    self._tcp_markers_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        #    self._tcp_markers_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        #    self._tcp_markers_socket.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        #    self._tcp_markers_socket.connect((self.tcp_markers_host, self.tcp_markers_port))
        #    self.logger.info("Sending markers via TCP/IP enabled.")
        self.on_play()

    def _on_pause(self):
        """
        Calls on_pause.

        You should not override this method, use on_pause instead.
        """
        self.on_pause()

    def _on_stop(self):
        """
        Calls on_stop.

        You should not override this method, use on_stop instead.
        """
        self.on_stop()

    def _on_quit(self):
        """
        Calls on_quit.

        You should not override this method, use on_quit instead.
        """
        self._shouldQuit = True
        self._playEvent.set()
        self.on_quit()


    #
    # Empty routines intended to be overwritten by derived classes
    #
    def on_init(self):
        """
        This method is called right after the feedback object was loaded by the
        FeedbackController.

        Override this method to initialize everything you need before the
        feedback starts.
        """
        self.logger.debug("on_init not implemented yet!")


    def on_play(self):
        """
        This method is called by the FeedbackController when it received a
        "Play" event via interaction signal.

        Override this method to actually start your feedback.
        """
        self.logger.debug("on_play not implemented yet!")


    def on_pause(self):
        """
        This method is called by the FeedbackController when it received a
        "Pause" event via interaction signal.

        Override this method to pause your feedback.
        """
        self.logger.debug("on_pause not implemented yet!")


    def on_stop(self):
        """
        This method is called by the FeedbackController when it received a
        "Stop" event.

        Override this method to stop your feedback. It should be possible to
        start again when receiving the :func:`on_start` event.
        """
        self.logger.debug("on_stop not implemented yet!")


    def on_quit(self):
        """
        This Method is called just before the FeedbackController will destroy
        the feedback object. The FeedbackController will not destroy the
        feedback object until this method has returned.

        Override this method to cleanup everything as needed or save information
        before the object gets destroyed.
        """
        self.logger.debug("on_quit not implemented yet!")


    def on_interaction_event(self, data):
        """
        This method is called after the FeedbackController received a
        interaction signal. The FeedbackController parses the signal, extracts
        the variable-value pairs, stores them as object-variables in your
        feedback and calls this method.

        If the FeedbackController detects a "play", "pause" or "quit"
        signal, it calls the appropriate ``on-method`` after this method has
        returned.

        If the FeedbackController detects an "init" signal, it calls
        :func:`on_init` before :func:`on_interaction_event`!

        Override this method if you want to react on interaction events.


        :param data: The content of the interaction signal.
        :type data: dict

        """
        self.logger.debug("on_interaction_event not implemented yet!")


    def on_control_event(self, data):
        """
        This method is called after the FeedbackController received a control
        signal. The FeedbackController parses the signal, extracts the values
        stores the resulting tuple in the object-variable "data" and calls this
        method.

        Override this method if you want to react on control events.

        :param data: The content of the control signal
        :type data: dict

        """
        self.logger.debug("on_control_event not implemented yet!")


    #
    # Common routines for all feedbacks
    #
    def send_parallel(self, data, reset=True):
        """Sends the data to the parallel port.

        The data is sent to the parallel port. After a short amount of
        time the parallel port is reset automatically.

        :param data: Data to be sent to the parallel port
        :type data: int

        """
        self.logger.info("Trigger: %s :%s" % (str(datetime.datetime.now()), str(data)))
        if reset == True:
            # A new trigger arrived before we could reset the old one
            self._triggerResetTimer.cancel()
        if self._pport:
            if sys.platform == 'win32':
                self._pport.Out32(self._port_num, data)
            else:
                self._pport.setData(data)
            if reset:
                self._triggerResetTimer = threading.Timer(self._triggerResetTime, self.send_parallel, (0x0, False))
                self._triggerResetTimer.start()


    def send_udp(self, data):
        """Sends the data to UDP.

        Similar to :func:`send_parallel`. The data is send through UDP.
        ``send_udp`` will append an ``'\n'`` character to the end of
        ``data`` before sending it.

        :param data: Data to be sent to the UDP port.
        :type data: str
            the marker.

        """
        self._udp_markers_socket.sendto(data + '\n',
                                        (self.udp_markers_host, self.udp_markers_port))

    #def send_tcp(self, data):
    #    """Sends marker via TCP/IP.
    #
    #    Parameters
    #    ----------
    #    data : str
    #        the marker. The string must end with '\n'.
    #
    #    """
    #    self._tcp_markers_socket.send(data)


    def _get_variables(self):
        """Return a dictionary of variables and their values."""
        # try everything from self.__dict__:
        # must be pickable
        self.logger.debug("Preparing variables.")
        d = {}
        for key, val in self.__dict__.iteritems():
            if key.startswith("_"):
                continue
            try:
                self.logger.debug("Trying to pickle %s %s" % (key, val))
                s = pickle.dumps(val, pickle.HIGHEST_PROTOCOL)
            except:
                self.logger.warning("Unable to pickle %s" % key)
                continue
            d[key] = val
        self.logger.debug("Returning variables.")
        return d

    def save_variables(self, filename):
        """Save all variables which are pickleable in JSON format.

        :param filename: The file where to store the variables.
        :type filename: str

        """
        # the json pickler cannot pickle everything the python pickler can,
        # prune away the variables which are not pickable, to avoid exception
        var_clean = dict()
        for k, v in self.__dict__.iteritems():
            if k.startswith("_"):
                continue
            try:
                json.dumps(v)
            except TypeError:
                continue
            var_clean[k] = v
        filehandle = open(filename, 'w')
        json.dump(var_clean, filehandle, indent=4, sort_keys=True)
        filehandle.close()

    def load_variables(self, filename):
        """Load variables from file and (over)write object attributes with
        their values.

        :param filename: The file where the variables are stored.
        :type filename: str

        This method expects the file to be in the same format as the
        save_variables method produces (currently JSON).
        """
        filehandle = open(filename, 'r')
        var = json.load(filehandle)
        filehandle.close()
        self.__dict__.update(var)

    def _playloop(self):
        """Loop which ensures that on_play always runs in main thread.

        Do not overwrite in derived classes unless you know what you're doing.
        """
        self._shouldQuit = False
        while 1:
            self._playEvent.wait()
            if self._shouldQuit:
                break
            try:
                self.logger.debug("Starting on_play.")
                self._on_play()
            except:
                # The feedback's main thread crashed and we need to take care
                # that the pipe does not run full, otherwise the feedback
                # controller freezes on the last pipe[foo].send()
                # So let's just terminate the feedback process.
                self.logger.exception("on_play threw an exception:")
                return
            self._playEvent.clear()
            self.logger.debug("on_play terminated.")
        self.logger.debug("_playloop terminated.")

