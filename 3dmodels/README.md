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

Each hip servo lives in a well on the base. The matching **leg** bolts onto the stock round horn. A **16 mm pipe** runs down the outboard side of the shin (clear of the hip screw) and is fused into the ankle cage. Each **foot** bolts onto the ankle servo’s round horn. Left and right parts are mirrors; soles are stamped **L** / **R** on the toe.

Default layout in `coco.scad` (edit these to retune stance):

| Parameter | Default | Meaning |
|-----------|---------|---------|
| `hip_span` | 72 mm | Hip shaft to hip shaft (Y) |
| `leg_len` | 52 mm | Hip shaft to ankle shaft (Z) |
| `ankle_h` | 22 mm | Ankle shaft above the ground |
| `sole_l` × `sole_w` | 64 × 36 mm | Footprint |
| `boom_d` | 16 mm | Shin pipe outer diameter |
| `clearance` | 0.40 mm | MG90S pocket clearance |

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

- **Feet** — sole on the bed. Ankle column and horn boss print upward; no supports.
- **Legs** — inboard cage wall toward the bed, boom along the printer Y (`coco_leg_print` already rotates and lifts the mesh). Light supports only if the ankle-cage overhang sags.
- **Base plate** — floor on the bed, wells facing up

Each foot and each leg exports as **one printable shell** (no floating chips). The shin pipe has an open cable duct from the ankle pocket to a rear exit under the hip flange.

## Assembly

1. Drop the two **hip** MG90S units into the base wells, cables toward the Pi. Tabs sit in the side slots; optional M2 screws through the tab holes. Shafts point **outboard**.
2. Fit a round horn on each hip. Bolt `leg_left` / `leg_right` onto those horns (horn screw through the printed flange).
3. Drop an MG90S into each shin cage, shaft outboard. Zip-tie through the hole below the body if you are not using tab screws. Feed the ankle lead into the pipe duct and out the rear hole under the hip flange.
4. Fit round horns on the ankle servos. Bolt the matching feet on (**L** / **R** stamps on the toes).
5. Mount the Pi Zero W on the four standoffs (USB/HDMI toward the rear). Strap the 2S pack under the deck. Sit the BECs on the raised pads. Route foot-servo wires up the boom ducts and through the rim holes next to each hip.
6. Home angles and GPIO are still those in `iv.py`; power the servo rail from the 3–4 A BEC, not from the Pi 5 V pin.

Tune `clearance` in `coco.scad` if a clone body is tight or sloppy. Tune `hip_span`, `leg_len`, `ankle_h`, `sole_l`, and `boom_d` there if you change stance, footprint, or shin length.
