# AGENTS.md — Coco Walker

Guidance for AI agents and automated tooling working in this repository.

## Project summary

**Coco Walker** is control software for **Coco**, a small **bipedal** robot with **four hobby servos** (left/right foot and hip). The stack runs on a **Raspberry Pi Zero W** with an **Adafruit ServoKit** (PCA9685, 16 channels) and optional **Vue 2** web UI for gait design.

- **Repo**: [fanff/coco](https://github.com/fanff/coco) on GitHub
- **Python**: 3.10+ via [uv](https://docs.astral.sh/uv/) (`pyproject.toml`, `uv.lock`)
- **Frontend**: Vue 2 app in `frt/` (`cocoui`)

## Architecture

```text
frt/ (Vue UI)  --WebSocket-->  flsrv.py (port 8765)
                                    |
                              cocoWalker.py (interpolation thread)
                                    |
                              ServoKit / mock
```

| Component | Role |
|-----------|------|
| `cocoWalker.py` | `CocoWalker` class: threaded smooth servo moves; `setRot`, `move`, `setAtIv` |
| `iv.py` | Home angles `iv=[...]` and motor name → channel map (`nameMap`) |
| `flsrv.py` | Live sine gait + WebSocket control (`freqfact`, `amplfact`) |
| `readPulp.py` | Playback of `file.json` keyframe curves (linear segments) |
| `patterns/*.json` | Example saved gaits (normalized time `x`, offset `y` per motor) |
| `frt/` | Pattern editor UI; exports `file.json`; connects to robot WebSocket |

### Motor mapping (`iv.py`)

| Name | Channel | Leg | Joint |
|------|---------|-----|-------|
| `feetL` | 0 | Left | Foot |
| `feetR` | 1 | Right | Foot |
| `hipR` | 2 | Right | Hip |
| `hipL` | 3 | Left | Hip |

Gait code applies per-motor scales in `flsrv.py` / `readPulp.py`: `[80, 80, -64, -64]` multiplied by pattern values before `setRot`.

## Hardware (do not assume in CI)

- **Board**: **Raspberry Pi Zero W** + Adafruit 16-channel PWM/Servo HAT (PCA9685)
- **Servos**: 4× hobby servos; angles clamped 0–180° in `cocoWalker.py`
- **Power** (two rails, common ground; see README):
  - **Pi Zero W**: **5 V, ~1 A**
  - **Servo bus** (HAT V+/GND): **5–6 V, 2–4 A** (prefer **3–4 A** for walking)
- **Off-device**: `flsrv.py` catches import failures and uses `SKitMockup` / `ServoMockup` so gait logic runs without hardware.

Enable I2C on the Pi Zero W before using real `ServoKit`. Do not document generic “any Pi” as the target board unless the user changes hardware.

## Commands agents should use

From repo root:

```bash
uv sync
uv run python flsrv.py      # WebSocket server :8765
uv run python readPulp.py   # plays ./file.json (needs hardware)
uv run python test.py       # WebSocket smoke test (expects flsrv running)
```

Web UI:

```bash
cd frt && npm install && npm run serve
```

Update hardcoded robot IPs in `frt/src/Cocoapp.vue` (e.g. `ws://192.168.1.58:8765`) when testing against a real host.

## WebSocket protocol (`flsrv.py`)

- **Listen**: `0.0.0.0:8765`
- **Client → server**: JSON string with numeric fields, e.g. `{"freqfact": 1.0, "amplfact": 1.0}`
- **Smoothing**: Exponential blend (`gamma = 0.20`) into `currentConfig` each loop
- **Gait**: `forward()` + `posgen()` sine waves; not the same format as `patterns/*.json`

`test.py` sends a plain string (`"Hello, World"`), which will fail `json.loads` in the handler—use JSON for real control tests.

## Pattern JSON format

Used by `readPulp.py`, `file.json`, and `patterns/`:

```json
{
  "feetL": [{"x": 0.0, "y": 0.5}, {"x": 1.0, "y": 0.2}],
  "feetR": [...],
  "hipL": [...],
  "hipR": [...]
}
```

- `x`: normalized time in \([0, 1]\) over `dursec` (default 3 s in `readPulp.py`)
- `y`: unitless offset; scaled per motor before adding to `iv[mot]`

## Coding conventions for agents

1. **Minimize scope** — Prefer small, focused changes. Do not refactor unrelated Flask experiments unless asked.
2. **Match existing style** — Plain Python, minimal typing, `logging` for debug, threading in `cocoWalker.py`.
3. **Preserve motor indices** — Changes to `nameMap` or channel order affect hardware wiring; update README table and any UI motor labels together.
4. **Run via `uv run`** — Do not assume a global venv; use project lockfile.
5. **Tests** — No formal test suite; `test.py` is a manual WebSocket check. Add tests only when requested or they cover non-trivial behavior.
6. **Dependencies** — Edit `pyproject.toml` and run `uv lock` / `uv sync`; commit `uv.lock`.
7. **3D assets** — `3dmodels/*.stl` are printable parts; do not binary-edit in agents.
8. **Notebook** — `Untitled.ipynb` is experimental; avoid depending on it for production paths.

## Files agents touch often

| Path | Notes |
|------|--------|
| `cocoWalker.py` | Core motion; thread lifecycle (`startThread` / `stopThread`) |
| `flsrv.py` | Asyncio + websockets; mock fallback |
| `readPulp.py` | JSON sampling loop; `repeat`, `dursec`, `sleepPause` at top of file |
| `iv.py` | Single source for home pose and names |
| `frt/src/Cocoapp.vue` | WebSocket URL and UI |
| `frt/src/components/cav.vue` | Canvas gait editor |
| `README.md` | User-facing docs; keep in sync with behavior changes |

## Common tasks

| Task | Where to work |
|------|----------------|
| Change default stance | `iv.py` |
| Tune live walk speed/amplitude | `flsrv.py` (`forward`, `scales`, WebSocket keys) |
| New recorded gait | `patterns/` or UI export → `file.json` |
| Safer servo limits | `cocoWalker.py` (`nextposcapped` clamp) |
| UI-only work | `frt/` |
| Deps / Python version | `pyproject.toml`, `.python-version`, `uv.lock` |

## Pitfalls

- **Two control paths**: Live WebSocket gait (`flsrv.py`) vs JSON playback (`readPulp.py`); formats differ.
- **Blocking in asyncio**: `flsrv.py` `bgjob` uses `time.sleep` inside async loop for initial delay; avoid adding long blocking calls without review.
- **Flask packages** in `pyproject.toml` are legacy/experimental; primary server is **websockets**, not Flask.
- **No `package = true`** — `pyproject.toml` sets `[tool.uv] package = false`; this is an application repo, not a publishable library.

## License / upstream

Authorship and license details may be noted in README; link [fanff/coco](https://github.com/fanff/coco) when documenting external contributions.
