# Coco Walker

Software for **Coco**, a small **bipedal** walking robot. Coco has **two legs** and is driven by **four hobby servos**—a foot and a hip on each side (see `iv.py`). The repo runs on a **Raspberry Pi Zero W** with **pigpio** driving servo PWM on GPIO, and includes tools to design gaits, run them live, and control the robot from a browser.

Python dependencies are managed with **[uv](https://docs.astral.sh/uv/)** (`pyproject.toml` + `uv.lock`).

## Hardware

- **Computer**: Raspberry Pi Zero W
- **Biped**: two legs, four degrees of freedom total
- **4 servos** (2 per leg): foot + hip on left and right (mapping in `iv.py`)
- **Servo control**: [pigpio](https://abyz.me.uk/rpi/pigpio/) on four GPIO lines (`servoGpios` in `iv.py`); legacy PCA9685 ServoKit still supported via `servo_kit.py`
- **3D-printed parts**: STL models in `3dmodels/` (`body.stl`, `leg.stl`, `feet.stl`)

### Power

**2S Li-ion** (two 18650 in series, **~7.4 V** nominal) through a **2S BMS**, then **two switching BECs** (common ground at the pack):

| Rail | Source | Notes |
|------|--------|--------|
| **Pi Zero W** | 5 V BEC, **~1 A** | Do not power the Pi from the servo BEC. |
| **Servo bus** | 5 V BEC, **3–4 A** | Servo **red/black** only from this rail—not from the Pi 5 V pin. |

Use BECs with an input range that covers **~6–8.4 V** (full 2S span). Add bulk capacitance on the servo 5 V rail near the connectors.

Servo **signal** wires go to the Pi GPIO pins in `iv.py`. PWM is **3.3 V**; most hobby servos accept it. Tie Pi GND and servo GND together once (star ground).

### GPIO wiring (default)

| Name   | Index | GPIO (BCM) | Leg   | Joint   |
|--------|-------|------------|-------|---------|
| feetL  | 0     | 17         | Left  | Foot    |
| feetR  | 1     | 18         | Right | Foot    |
| hipR   | 2     | 27         | Right | Hip     |
| hipL   | 3     | 22         | Left  | Hip     |

Change `servoGpios` in `iv.py` to match your harness. Home angles are in `iv=[...]`.

## How it works

```text
  Vue UI (frt/)          WebSocket (flsrv.py)         Pattern playback (readPulp.py)
        |                         |                              |
        +---- ws://host:8765 -----+---- cocoWalker.py ------------+
                                          |
                              servo_kit (pigpio / mock)
```

1. **`cocoWalker.py`** — Core motion layer. A background thread smoothly interpolates each servo toward target angles; `move()` and `setRot()` update targets without blocking the gait loop.
2. **`flsrv.py`** — Real-time walker. Sine-based forward gait on **port 8765**; accepts JSON (`freqfact`, `amplfact`) over WebSocket to adjust speed and amplitude. Uses pigpio when the daemon is running, otherwise a mock.
3. **`readPulp.py`** — Plays back keyframe curves from `file.json` (or UI exports), samples them with linear segments, and replays the motion a configurable number of times.
4. **`patterns/`** — Example gait JSON (`forward.json`, `rotateCW.json`, …) with time-series points per leg.
5. **`frt/`** — Vue 2 UI (`cocoui`) to draw leg curves per motor, export `file.json`, and connect over WebSocket. Set the host IP in the Vue sources to your board’s LAN address.

## Setup (uv)

Install [uv](https://docs.astral.sh/uv/getting-started/installation/), then from the repo root:

```bash
uv sync
```

This creates `.venv` and installs locked dependencies from `uv.lock`. Python **3.10+** is required (see `.python-version`).

Run scripts through uv so they use the project environment:

```bash
uv run python flsrv.py      # live WebSocket gait server
uv run python readPulp.py   # play file.json pattern (needs hardware)
uv run python test.py       # WebSocket smoke test
```

On the Pi, install and start the pigpio daemon, then use the same commands after `uv sync`:

```bash
sudo apt install pigpio python3-pigpio   # or build from pigpio repo
sudo pigpiod
sudo systemctl enable pigpiod            # optional: start on boot
```

Set `COCO_SERVO_BACKEND=mock` to force the software mock (laptops/CI). Use `servokit` for the legacy Adafruit HAT.

### Web UI

```bash
cd frt
npm install
npm run serve
```

## Repository layout

| Path | Description |
|------|-------------|
| `pyproject.toml` | Project metadata and Python dependencies |
| `uv.lock` | Locked dependency versions (commit this file) |
| `cocoWalker.py` | Servo controller with threaded interpolation |
| `iv.py` | Home angles, GPIO map, motor name map |
| `servo_kit.py` | pigpio / ServoKit / mock factory |
| `flsrv.py` | WebSocket gait server (port 8765) |
| `readPulp.py` | JSON pattern sampler and playback |
| `patterns/` | Saved gait curves |
| `frt/` | Vue control / pattern editor UI |
| `3dmodels/` | Printable robot parts (STL) |
| `Untitled.ipynb` | Experiments and prototyping |

## Notes

- **Flask** packages are listed for experiments; the main control path uses **asyncio** and **websockets** in `flsrv.py`.
- **pigpio** needs `pigpiod` on the Pi. Off-device, `servo_kit.make_servo_kit()` falls back to a mock unless you set `COCO_SERVO_BACKEND`.
- The UI references a LAN IP (e.g. `192.168.1.58`); change it to match your robot host.
- `flsrv.py` accepts WebSocket messages as JSON with numeric fields such as `freqfact` and `amplfact` to tune the live gait.

## License

See [fanff/coco](https://github.com/fanff/coco) for authorship and licensing if applicable.
