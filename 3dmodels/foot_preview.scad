// Coco — left foot + motor + world axes (not a printable part).
// Origin is the output shaft, same frame as coco.scad:
//   +X forward (toes), +Y left (outboard), +Z up, −X shaft / heel.
// Open in OpenSCAD (F5) when editing the gnome sole.

include <coco.scad>

// 3/4 view (default). Top-down XY: $vpr=[0,0,0]; $vpt=[12,0,0]; $vpd=140.
$vpr = [68, 0, 48];
$vpt = [14, 0, -2];
$vpd = 130;

color("YellowGreen")
    coco_foot(side = 1);

color("SteelBlue")
    mg90s_orient_foot()
        mg90s_dummy();

coco_axes(len = 28);
coco_foot_anchor_markers();
