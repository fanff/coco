# 3D-printed parts — Coco biped

OpenSCAD sources for a small **biped** walker built around **four MG90S** micro servos (two per leg). Print these five parts:

| File | Qty | Role |
|------|-----|------|
| `foot_left.scad` | 1 | Left sole + ankle horn mount (`feetL`) |
| `foot_right.scad` | 1 | Right sole + ankle horn mount (`feetR`) |
| `leg_left.scad` | 1 | Left shin: hip horn at the top, MG90S cage at the ankle |
| `leg_right.scad` | 1 | Right shin (mirror) |
| `base_plate.scad` | 1 | Deck where both **hip** servos plug in, plus Pi Zero W / BEC / battery straps |

Shared libraries (not printed on their own):

| File | Role |
|------|------|
| `mg90s.scad` | MG90S body, pocket cutter, round-horn pattern |
| `coco.scad` | Robot dimensions and the part modules |
| `assembly.scad` | Preview of the full robot (F5 in OpenSCAD) — **do not print** |

All dimensions are millimetres. The `.scad` files are the source of truth; export STL when you are ready to slice.

## Kinematics

Two degrees of freedom per leg, matching `iv.py` (`feetL` / `feetR` / `hipL` / `hipR`):

```text
                    +Z up
                    |
                    |      base plate (Pi Zero W, BECs, 2S pack)
           hipL ●---+---● hipR     shafts along ±Y (leg swings forward/back)
                |         |
            leg L      leg R       tubular boom
                |         |
         ankleL ●         ● ankleR  MG90S in the shin, shafts along ±Y
                |         |
             foot L     foot R
                    |
                    +X forward
```

Each hip servo lives in a well on the base. The matching **leg** bolts onto the stock round horn. Each **foot** bolts onto the ankle servo’s round horn. Left and right parts are mirrors; they are stamped **L** / **R**.

## Bill of materials (hardware)

- 4× **MG90S** (or SG90-sized clones — pockets have 0.4 mm clearance)
- 4× stock **round horns** and horn screws
- 8× M2×8 mm screws for servo mounting tabs (optional; zip-ties also work)
- Raspberry Pi Zero W (M2.5×8 mm into the four standoffs)
- Two 5 V BECs and a 2S 18650 pack (zip-tie slots under the deck)
- 4× hobby-servo 3-pin leads to the GPIO map in `iv.py`

## Export STL

Install [OpenSCAD](https://openscad.org/) 2021.01 or newer, then from this folder:

```bash
mkdir -p stl
openscad -o stl/foot_left.stl   foot_left.scad
openscad -o stl/foot_right.stl  foot_right.scad
openscad -o stl/leg_left.stl    leg_left.scad
openscad -o stl/leg_right.stl   leg_right.scad
openscad -o stl/base_plate.stl  base_plate.scad
```

Or: `make stl`. Open `assembly.scad` and press **F5** to inspect the fit before printing.

## Print settings

| | |
|--|--|
| Material | PLA or PETG |
| Layer height | 0.20 mm |
| Infill | 20–30 %, gyroid or grid |
| Perimeters | 3 |
| Supports | Usually none. Light supports only if the ankle-cage overhang sags. |

Suggested bed orientation (already applied in the printable files):

- **Feet** — sole on the bed
- **Legs** — inboard (horn) face on the bed
- **Base plate** — floor on the bed, wells facing up

## Assembly

1. Drop the two **hip** MG90S units into the base wells, cables toward the Pi. Tabs sit in the side slots; optional M2 screws through the tab holes. Shafts point **outboard**.
2. Fit a round horn on each hip. Bolt `leg_left` / `leg_right` onto those horns (horn screw through the printed flange).
3. Drop an MG90S into each shin cage, shaft outboard. Zip-tie through the slot if you are not using tab screws.
4. Fit round horns on the ankle servos. Bolt the matching feet on (L / R labels on the soles).
5. Mount the Pi Zero W on the four standoffs (USB/HDMI toward the rear). Strap the 2S pack under the deck. Sit the BECs on the raised pads. Route foot-servo wires up the boom ducts and through the rim holes next to each hip.
6. Home angles and GPIO are still those in `iv.py`; power the servo rail from the 3–4 A BEC, not from the Pi 5 V pin.

Tune `clearance` in `coco.scad` if a clone body is tight or sloppy. Tune `hip_span`, `leg_len`, and `ankle_h` there if you change stance or shin length.
