// Coco — assembled preview (not a printable part).
// Opens in OpenSCAD F5 to check fit: 4× MG90S, two U-shaped legs, two feet, deck.
// Default camera looks in from the rear-left so the in-foot motors are visible
// (laid down in the green soles, shafts pointing backward).

include <coco.scad>

$vpr = [68, 0, 148];
$vpt = [hip_x - 8, 0, coco_hip_z_world() * 0.28];
$vpd = 290;

module coco_hip_servo(side) {
    translate([hip_x, coco_hip_y(side), coco_hip_z_world()])
        mg90s_orient_shaft_y(side)
            mg90s_dummy();
}

module coco_foot_servo(side) {
    translate([hip_x, coco_hip_y(side), ankle_h])
        mirror([0, side < 0 ? 1 : 0, 0])
            mg90s_orient_foot()
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

        coco_foot_servo(s);

        translate([hip_x, coco_hip_y(s), ankle_h - e * 16])
            color(s > 0 ? "YellowGreen" : "OliveDrab")
                coco_foot(s);
    }

    // World / left-foot frame at the left ankle shaft (coco.scad origin).
    // +X forward, +Y left, +Z up, −X shaft/heel. Right foot is a Y-mirror.
    translate([hip_x, coco_hip_y(1), ankle_h])
        coco_axes(len = 24);
}

exploded = 0; // set to 1 for an exploded preview
coco_assembly(exploded = exploded);
