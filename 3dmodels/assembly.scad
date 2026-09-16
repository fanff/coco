// Coco — assembled preview (not a printable part).
// Opens in OpenSCAD F5 to check fit: 4× MG90S, two U-shaped legs, two feet, deck.
// Default camera looks in from the left so the U-channel is visible.

include <coco.scad>

$vpr = [70, 0, 32];
$vpt = [hip_x, 0, coco_hip_z_world() * 0.35];
$vpd = 300;

module coco_hip_servo(side) {
    translate([hip_x, coco_hip_y(side), coco_hip_z_world()])
        mg90s_orient_shaft_y(side)
            mg90s_dummy();
}

module coco_ankle_servo(side) {
    translate([hip_x, coco_hip_y(side), ankle_h])
        mg90s_orient_shaft_y(side)
            mg90s_dummy();
}

module coco_assembly(exploded = 0) {
    base_z = coco_hip_z_world() - hip_z;
    e = exploded;

    translate([0, 0, base_z + e * 25])
        color("SlateGray")
            coco_base_plate();

    for (s = [1, -1]) {
        coco_hip_servo(s);

        translate([hip_x, coco_hip_y(s), coco_hip_z_world() + e * 18])
            color(s > 0 ? "Tomato" : "Orange")
                coco_leg(s);

        coco_ankle_servo(s);

        translate([hip_x, coco_hip_y(s), ankle_h - e * 16])
            color(s > 0 ? "YellowGreen" : "OliveDrab")
                coco_foot(s);
    }
}

exploded = 0; // set to 1 for an exploded preview
coco_assembly(exploded = exploded);
