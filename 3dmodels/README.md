# 3D-printed parts — Coco biped

OpenSCAD sources for a small **biped** walker built around **four MG90S** micro servos (two per leg). Print these five parts:

| File | Qty | Role |
|------|-----|------|
| `foot_left.scad` | 1 | Left gnome sole (4 toes) + laid-down MG90S well (`feetL`) |
| `foot_right.scad` | 1 | Right gnome sole (4 toes) + laid-down MG90S well (`feetR`) |
| `leg_left.scad` | 1 | Left U-channel shin: hip horn at the top, foot-servo horn at the bottom |
| `leg_right.scad` | 1 | Right U-channel shin (mirror) |
| `base_plate.scad` | 1 | Deck where both **hip** servos plug in, plus Pi Zero W / BEC / battery straps |

Shared libraries (not printed on their own):

| File | Role |
|------|------|
| `mg90s.scad` | MG90S body, pocket cutter, round-horn pattern, `mg90s_orient_foot` |
| `coco.scad` | Robot dimensions and the part modules |
| `assembly.scad` | Preview of the full robot (F5) — **do not print**. RGB axes at the left ankle. |
| `foot_preview.scad` | Left foot + motor + XYZ triad at the shaft — **do not print** |

All dimensions are millimetres. The `.scad` files are the source of truth; export STL when you are ready to slice.

## Kinematics

Two degrees of freedom per leg, matching `iv.py` (`feetL` / `feetR` / `hipL` / `hipR`):

```text
                    +Z up
                    |
                    |      base plate (Pi Zero W, BECs, 2S pack)
           hipL ●---+---● hipR     shafts along ±Y (leg swings forward/back)
                |         |
            leg L      leg R       U-channel shin (opens outboard)
                |         |
             foot L     foot R     MG90S in the sole, laid down
                ●         ●        shafts along −X (backward; foot pitches)
                    |
                    +X forward
```

Each hip servo lives in a well on the base. The matching **leg** bolts onto the stock round horn. The shin is a **U-channel** that opens **outboard** (toward the side of the robot): two arms (fore and aft) and an inboard web.

Each **foot** servo lives *in the sole* (the green part in `assembly.scad`), laid down so the 12.4 mm body width is vertical. That pose is the hip Y-shaft orientation turned **90° about +Z**, then **180° about the shaft (world X)**: the output shaft still points **backward** (−X), the 23 mm body occupies +X (toward the toes), and the round horn sticks out the heel. The 4 mm front window stays on that same shaft axis, opposite the horn. The well is sliced by a horizontal plane at the **motor top**, so there is no roof or wall above the servo — it slides in from above. A **notch from the top** of the **inboard** wall lets the servo lead pass through as the motor drops in.

The ground plate is a compact **gnome foot**: four overlapping flattened-sphere toes in front (the balls collide so they are not split fingers; the outboard toe is the smallest), a sole that **runs from the motor housing out to the toes**, and a **short heel** so the shin flange still clears at the back. Around the well the pad still **hugs the socket** (walls do not flare). The front wall of the well — opposite the shaft / heel horn — has a round **through-hole** on the shaft axis (`front_hole_d`, default 4 mm). Well walls may rise in Z around the motor and a bit toward the front. The bottom of the shin is a horn flange that bolts onto that horn, so commanding `feetL` / `feetR` pitches the foot. Left and right parts are mirrors.

Default layout in `coco.scad` (edit these to retune stance):

| Parameter | Default | Meaning |
|-----------|---------|---------|
| `hip_span` | 72 mm | Hip shaft to hip shaft (Y) |
| `leg_len` | 56 mm | Hip shaft to foot-servo shaft (Z) |
| `ankle_h` | 14.2 mm | Foot-servo shaft above the ground (`BODY_W/2 + clearance + wall + sole_t`) |
| `toe_reach` | 43 mm | Forward-most toe-ball centre, from the foot-servo shaft |
| `coco_toe_d` | 16, 15, 14, 10 mm | Toe-ball diameters (inboard → outboard) |
| `front_hole_d` | 4 mm | Round hole in the front socket wall (shaft axis) |
| `hug_inset` | 2 mm | How far the well pad tucks under the socket walls |
| `heel_lip` | 2 mm | Sole behind the shaft (kept short for the shin) |
| `u_inner_w` × `u_inner_d` | 30 × 28 mm | U-channel inside (X × Y) |
| `u_wall` | 3.6 mm | U arm / web thickness |
| `u_ankle_clear` | 18 mm | U bottom stays this far above the foot shaft |
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

Or: `make stl`. Open `assembly.scad` or `foot_preview.scad` and press **F5** to inspect the fit before printing. Both draw an RGB triad at the left foot-servo shaft: **+X** red (forward / toes), **+Y** green (left / outboard), **+Z** blue (up), **−X** maroon (shaft / heel). That is the frame `coco.scad` uses; the right foot is a Y-mirror of it.

## Print settings

| | |
|--|--|
| Material | PLA or PETG |
| Layer height | 0.20 mm |
| Infill | 20–30 %, gyroid or grid |
| Perimeters | 3 |
| Supports | None for feet and the U-shaped legs. Light supports only if a hip-well overhang sags on the base plate. |

Suggested bed orientation (already applied in the printable files):

- **Feet** — sole on the bed. Well is open at the motor top (no roof); no supports.
- **Legs** — inboard web on the bed, U opening up (`coco_leg_print`). No supports.
- **Base plate** — floor on the bed, wells facing up

Each foot and each leg exports as **one printable shell** (no floating chips). The foot servo **slides** into the sole from above (the well is cut off at the motor top); a zip-tie through the well retains it if you skip the tab screws. The shin flange sits on the horn at the heel.

## Assembly

1. Drop the two **hip** MG90S units into the base wells, cables toward the Pi. Tabs sit in the side slots; optional M2 screws through the tab holes. Shafts point **outboard**.
2. Fit a round horn on each hip. Bolt `leg_left` / `leg_right` onto those horns (horn screw through the printed flange).
3. Slide an MG90S into each **foot** well from above, body laid down, shaft pointing **backward** (out the heel). The well has no roof — it is cut off at the motor top. Drop the servo lead through the open notch in the **inboard** wall (toward the other foot). Optional M2 screws through the tab holes; otherwise zip-tie through the well.
4. Fit a round horn on each foot servo. Bolt the matching shin’s bottom flange onto that horn.
5. Mount the Pi Zero W on the four standoffs (USB/HDMI toward the rear). Strap the 2S pack under the deck. Sit the BECs on the raised pads. Route foot-servo wires up the U and through the rim holes next to each hip.
6. Home angles and GPIO are still those in `iv.py`; power the servo rail from the 3–4 A BEC, not from the Pi 5 V pin.

Tune `clearance` in `coco.scad` if a clone body is tight or sloppy. Tune `hip_span`, `leg_len`, `ankle_h`, `toe_reach`, `coco_toe_*`, `front_hole_d`, `hug_inset`, and `u_inner_w` / `u_inner_d` there if you change stance, footprint, hole size, or shin section.
