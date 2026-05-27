"""Servo backends for Coco: pigpio (GPIO), optional legacy ServoKit, or mock."""

import logging
import os
import socket

# BCM pins: feetL, feetR, hipR, hipL (same order as iv channel indices)
from iv import servoGpios

PULSE_MIN_US = 500
PULSE_MAX_US = 2500


def angle_to_pulse_us(angle):
    angle = max(0.0, min(180.0, float(angle)))
    span = PULSE_MAX_US - PULSE_MIN_US
    return int(PULSE_MIN_US + (angle / 180.0) * span)


class ServoMockup:
    def __init__(self, index):
        self.index = index

    @property
    def angle(self):
        return None

    @angle.setter
    def angle(self, value):
        logging.getLogger("servo.mock").info("servo[%s].angle = %s", self.index, value)


class SKitMockup:
    def __init__(self, n_motors=4):
        self.servo = [ServoMockup(i) for i in range(n_motors)]

    def close(self):
        pass


class _ServoAngle:
    __slots__ = ("_set_angle",)

    def __init__(self, set_angle):
        self._set_angle = set_angle

    @property
    def angle(self):
        return None

    @angle.setter
    def angle(self, value):
        self._set_angle(value)


class PigpioKit:
    def __init__(self, pi, gpios):
        self._pi = pi
        self._gpios = list(gpios)
        self.servo = [
            _ServoAngle(lambda a, g=gpio: self._write(g, a))
            for gpio in self._gpios
        ]
        log = logging.getLogger("servo.pigpio")
        for gpio in self._gpios:
            self._pi.set_mode(gpio, self._pi.OUTPUT)
            log.info("servo on GPIO %s", gpio)

    def _write(self, gpio, angle):
        pulse = angle_to_pulse_us(angle)
        self._pi.set_servo_pulsewidth(gpio, pulse)

    def close(self):
        for gpio in self._gpios:
            self._pi.set_servo_pulsewidth(gpio, 0)
        self._pi.stop()


def _pigpiod_running(host=None, port=None):
    host = host or os.environ.get("PIGPIO_ADDR", "localhost")
    port = int(port or os.environ.get("PIGPIO_PORT", "8888"))
    try:
        with socket.create_connection((host, port), timeout=0.2):
            return True
    except OSError:
        return False


def _make_pigpio_kit(log):
    if not _pigpiod_running():
        raise RuntimeError("pigpio daemon not running (start with: sudo pigpiod)")

    import pigpio

    pi = pigpio.pi()
    if not pi.connected:
        pi.stop()
        raise RuntimeError("pigpio daemon not running (start with: sudo pigpiod)")
    log.info("using pigpio on GPIOs %s", servoGpios)
    return PigpioKit(pi, servoGpios)


def _make_servokit(log):
    from adafruit_servokit import ServoKit

    kit = ServoKit(channels=16)
    log.info("using Adafruit ServoKit (legacy PCA9685)")
    return kit


def make_servo_kit(logger=None):
    """
    Return a kit object with .servo[i].angle for i in 0..3.
    Backend order: COCO_SERVO_BACKEND env, else pigpio, ServoKit, mock.
    """
    log = logger or logging.getLogger("servo")
    backend = os.environ.get("COCO_SERVO_BACKEND", "").strip().lower()

    if backend == "mock":
        log.warning("COCO_SERVO_BACKEND=mock")
        return SKitMockup()

    if backend == "servokit":
        return _make_servokit(log)

    if backend == "pigpio":
        return _make_pigpio_kit(log)

    for name, factory in (
        ("pigpio", _make_pigpio_kit),
        ("servokit", _make_servokit),
    ):
        try:
            return factory(log)
        except Exception as e:
            log.warning("%s unavailable: %s", name, e)

    log.warning("using servo mock (no hardware backend)")
    return SKitMockup()
