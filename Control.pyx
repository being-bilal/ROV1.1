# cython: language_level=3
import pigpio
import numpy as np
import pygame
from PID import PID
import time
import threading
import queue
import socket
import json
from datetime import datetime

cdef class Controller:
    cdef public object joystick
    cdef public tuple axis_map
    cdef float STICK_DEADBAND

    def __init__(self, axis_map):
        self.axis_map = axis_map
        self.joystick = None
        self.STICK_DEADBAND = 0.05

    def update(self):
        pygame.event.pump()

    cpdef float _getAxis(self, int k):
        j = self.axis_map[k]
        val = self.joystick.get_axis(abs(j))
        if abs(val) < self.STICK_DEADBAND:
            val = 0
        return (-1 if j < 0 else 1) * val

    cpdef float getThrottle(self):
        return self._getAxis(0)

    cpdef float getRoll(self):
        return self._getAxis(1)

    cpdef float getPitch(self):
        return self._getAxis(2)

    cpdef float getYaw(self):
        return self._getAxis(3)

cdef class _GameController(Controller):
    cdef int button_id

    def __init__(self, axis_map, button_id):
        super().__init__(axis_map)
        self.button_id = button_id

    cpdef int _getAuxValue(self):
        return self.joystick.get_button(self.button_id)

    cpdef int getAux(self):
        return self._getAuxValue()

controllers = {
    '2In1 USB Joystick': _GameController((-1, 2, -3, 0), 5),
    'Logitech Logitech Extreme 3D': _GameController((-3, 0, -1, 2), 0),
}

cdef class Control(Controller):
    cdef public int THRUSTER_1, THRUSTER_2, THRUSTER_3, THRUSTER_4
    cdef object control_queue
    cdef object pi

    def __init__(self, int THRUSTER_1, int THRUSTER_2, int THRUSTER_3, int THRUSTER_4):
        self.THRUSTER_1 = THRUSTER_1
        self.THRUSTER_2 = THRUSTER_2
        self.THRUSTER_3 = THRUSTER_3
        self.THRUSTER_4 = THRUSTER_4
        self.control_queue = queue.Queue()
        self.pi = pigpio.pi()

        for pin in [THRUSTER_1, THRUSTER_2, THRUSTER_3, THRUSTER_4]:
            self.pi.set_servo_pulsewidth(pin, 1500)

    cpdef get_controller(self):
        pygame.display.init()
        pygame.joystick.init()
        joystick = pygame.joystick.Joystick(0)
        joystick.init()
        name = joystick.get_name()
        if name not in controllers:
            raise ValueError(f"Unrecognized controller: {name}")
        controller = controllers[name]
        controller.joystick = joystick
