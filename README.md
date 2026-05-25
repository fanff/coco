# Coco Walker

Software for **Coco**, a small **bipedal** walking robot. Coco has **two legs** and is driven by **four hobby servos**—a foot and a hip on each side (see `iv.py`). The repo runs on a Raspberry Pi (or similar) with an [Adafruit ServoKit](https://www.adafruit.com/product/2327) (PCA9685), and includes tools to design gaits, run them live, and control the robot from a browser.

Python dependencies are managed with **[uv](https://docs.astral.sh/uv/)** (`pyproject.toml` + `uv.lock`).

## Hardware

- **Computer**: Raspberry Pi Zero W (I2C enabled for the servo HAT)
- **Biped**: two legs, four degrees of freedom total
- **4 servos** (2 per leg): foot + hip on left and right (channel mapping in `iv.py`)
- **Servo driver**: Adafruit ServoKit (16-channel PCA9685 board)
- **3D-printed parts**: STL models in `3dmodels/` (`body.stl`, `leg.stl`, `feet.stl`)

### Power

Use **two supplies** (common ground between Pi and HAT; do not power four servos from the Pi’s 5 V pin):

| Rail | Typical supply | Notes |
|------|----------------|--------|
| **Pi Zero W** | **5 V, ~1 A** | Enough for Wi‑Fi and gait software; use a bit more headroom if you add USB peripherals. |
| **Servo bus** (HAT screw terminals) | **5–6 V, 2–4 A** | **2 A** for light duty with small hobby servos; **3–4 A** safer when all four move or stall during walking. |

Servos must be **5 V–compatible**; PWM logic is **3.3 V** from the Pi. See the [Adafruit Servo HAT guide](https://learn.adafruit.com/adafruit-16-channel-pwm-servo-hat-for-raspberry-pi) for wiring.

Neutral / home angles and motor names are defined in `iv.py`:

| Name   | Index | Leg   | Joint   |
|--------|-------|-------|---------|
| feetL  | 0     | Left  | Foot    |
| feetR  | 1     | Right | Foot    |
| hipR   | 2     | Right | Hip     |
| hipL   | 3     | Left  | Hip     |

## How it works

```text
  Vue UI (frt/)          WebSocket (flsrv.py)         Pattern playback (readPulp.py)
        |                         |                              |
        +---- ws://host:8765 -----+---- cocoWalker.py ------------+
                                          |
                                    ServoKit (or mock)
```

1. **`cocoWalker.py`** — Core motion layer. A background thread smoothly interpolates each servo toward target angles; `move()` and `setRot()` update targets without blocking the gait loop.
2. **`flsrv.py`** — Real-time walker. Sine-based forward gait on **port 8765**; accepts JSON (`freqfact`, `amplfact`) over WebSocket to adjust speed and amplitude. Uses ServoKit when available, otherwise a mock.
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

On a Raspberry Pi with ServoKit and I2C enabled, use the same commands after `uv sync`.

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
| `iv.py` | Initial angles and motor name map |
| `flsrv.py` | WebSocket gait server (port 8765) |
| `readPulp.py` | JSON pattern sampler and playback |
| `patterns/` | Saved gait curves |
| `frt/` | Vue control / pattern editor UI |
| `3dmodels/` | Printable robot parts (STL) |
| `Untitled.ipynb` | Experiments and prototyping |

## Notes

- **Flask** packages are listed for experiments; the main control path uses **asyncio** and **websockets** in `flsrv.py`.
- **Adafruit ServoKit** only talks to real hardware on supported boards (e.g. Raspberry Pi with I2C). Off-device, `flsrv.py` falls back to a mock.
- The UI references a LAN IP (e.g. `192.168.1.58`); change it to match your robot host.
- `flsrv.py` accepts WebSocket messages as JSON with numeric fields such as `freqfact` and `amplfact` to tune the live gait.

## License

See [fanff/coco](https://github.com/fanff/coco) for authorship and licensing if applicable.
