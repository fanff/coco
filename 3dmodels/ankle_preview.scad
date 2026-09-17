// Coco — left U-shin on the left foot, at the two anchors (not printable).
// Rear orange pin = shaft / horn. Front magenta pin = 4 mm mirror hole.
include <coco.scad>

$vpr = [72, 0, 40];
$vpt = [16, -4, 8];
$vpd = 180;

color("YellowGreen")
    coco_foot(side = 1);

color("SteelBlue")
    mg90s_orient_foot()
        mg90s_dummy();

color("Tomato")
    translate([0, 0, leg_len])
        coco_leg(side = 1);

coco_axes(len = 22);
coco_foot_anchor_markers();
