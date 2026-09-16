// Coco biped — printable parts for 4× MG90S (2 per leg) + electronics deck.
// Units: millimetres. Robot frame: +X forward, +Y left, +Z up.
//
// side = +1 → left, side = −1 → right (mirror of the left solid).

include <mg90s.scad>

$fn = $fn ? $fn : 48;
eps = 0.08;

// --- layout ---
hip_span     = 72.0;   // hip shaft to hip shaft (Y)
hip_x        = 36.0;   // hip shafts forward of plate centre
leg_len      = 52.0;   // hip shaft to ankle shaft (Z)
ankle_h      = 22.0;   // ankle shaft above ground
wall         = 3.4;
clearance    = 0.40;

// --- foot ---
sole_l       = 64.0;
sole_w       = 36.0;
sole_t       = 5.0;
toe_len      = 36.0;
heel_len     = 28.0;
foot_boss_h  = 9.0;
foot_boss_d  = 26.0;
sole_cy      = 11.0;   // sole centre in +Y (outboard of the horn plane)

// --- leg ---
hip_flange_d = 26.0;
hip_flange_h = 6.5;
boom_d       = 16.0;
boom_y       = 9.0;    // pipe sits outboard of the horn plane
boom_id      = 4.4;    // cable duct through the pipe

// --- base plate ---
plate_x      = 114.0;
plate_y      = 82.0;
floor_t      = 4.0;
rim_h        = 8.0;
rim_t        = 2.2;
hip_z        = 11.0;   // hip shaft height above plate bottom

// Pi Zero W (65 × 30), holes 58 × 23, M2.5 — sits behind the hip pods
pi_hole_dx    = 58.0;
pi_hole_dy    = 23.0;
pi_standoff_h = 6.0;
pi_standoff_d = 6.5;
pi_hole_d     = 2.7;
pi_cx         = -24.0;
pi_cy         = 0.0;

function coco_hip_y(side) = side * hip_span / 2;
function coco_hip_z_world() = ankle_h + leg_len;

module coco_rounded_rect(size, r, center = true) {
    x = size[0];
    y = size[1];
    rr = min(r, x / 2 - 0.1, y / 2 - 0.1);
    translate(center ? [0, 0] : [x / 2, y / 2])
        offset(r = rr)
            square([x - 2 * rr, y - 2 * rr], center = true);
}

module coco_label(txt, size = 6, h = 0.7) {
    linear_extrude(h)
        text(
            txt,
            size = size,
            font = "Liberation Sans:style=Bold",
            halign = "center",
            valign = "center"
        );
}

// Manifold L/R stamps for soles (font text can leave a detached CGAL chip).
module coco_stamp_L(h = 1.2) {
    linear_extrude(h) {
        translate([-2.4, -3.2])
            square([1.7, 6.4]);
        translate([-2.4, -3.2])
            square([5.2, 1.7]);
    }
}

module coco_stamp_R(h = 1.2) {
    linear_extrude(h) {
        translate([-2.4, -3.2])
            square([1.7, 6.4]);
        translate([-2.4, 1.8])
            square([4.8, 1.6]);
        translate([-2.4, -0.4])
            square([4.4, 1.6]);
        translate([1.5, -0.4])
            square([1.6, 3.8]);
        translate([0.8, -3.2])
            square([1.7, 2.9]);
    }
}

module coco_stamp_lr(side = 1, h = 1.2) {
    if (side > 0)
        coco_stamp_L(h = h);
    else
        coco_stamp_R(h = h);
}

// Solid envelope used before subtracting mg90s_pocket().
module coco_servo_cage_solid(pad = 3.2) {
    translate([
        mg90s_body_xmin() - pad,
        -MG90S_BODY_W / 2 - pad,
        -pad
    ])
        cube([
            MG90S_BODY_L + 2 * pad,
            MG90S_BODY_W + 2 * pad,
            mg90s_horn_z() + pad
        ]);
}

// World +Z hatch so a servo drops in from above. dir matches mg90s_orient_shaft_y.
module coco_servo_hatch(dir = 1) {
    translate([
        (mg90s_body_xmin() + mg90s_body_xmax()) / 2,
        dir * MG90S_BODY_W / 2 + dir * 8,
        MG90S_BODY_H / 2
    ])
        cube([MG90S_BODY_L + 1.2, 16, MG90S_BODY_H + 6], center = true);
}

// =====================================================================
// Foot
// Origin: ankle shaft. Horn plane at y = 0; plastic in +Y (outboard).
// The column is a single hull from the horn boss into the sole so the
// mesh stays one CGAL volume.
// =====================================================================
module coco_foot_sole_2d() {
    hull() {
        translate([toe_len - 9, 0])
            circle(d = 18);
        translate([-(heel_len - 8), 0])
            circle(d = 16);
        coco_rounded_rect([sole_l - 10, sole_w - 12], r = 7);
    }
}

module coco_foot_positive() {
    sole_z = -ankle_h;
    union() {
        translate([0, sole_cy, sole_z])
            linear_extrude(sole_t)
                coco_foot_sole_2d();
        // Ankle column: horn boss fused into a pad that sits inside the sole.
        hull() {
            translate([0, -0.4, 0])
                rotate([-90, 0, 0])
                    cylinder(d = foot_boss_d, h = foot_boss_h + 0.4);
            translate([0, sole_cy, sole_z + 0.8])
                linear_extrude(sole_t - 0.6)
                    coco_rounded_rect([32, 22], r = 6);
        }
    }
}

module coco_foot_cuts() {
    sole_z = -ankle_h;
    rotate([-90, 0, 0])
        mg90s_horn_cuts(h = foot_boss_h + 8, seat = 1.4);
    rotate([-90, 0, 0])
        translate([0, 0, -1])
            cylinder(d = 3.2, h = foot_boss_h + 12);
    translate([0, foot_boss_h - 1.6, 0])
        rotate([-90, 0, 0])
            cylinder(d1 = 3.4, d2 = 6.5, h = 2.2);
    translate([0, sole_cy, sole_z])
        intersection() {
            translate([0, 0, -0.2])
                linear_extrude(2.2)
                    offset(-6)
                        coco_foot_sole_2d();
            for (x = [-18, -6, 6, 18])
                translate([x, 0, 0.9])
                    cube([3.2, 16, 1.8], center = true);
        }
}

module coco_foot(side = 1) {
    difference() {
        mirror([0, side < 0 ? 1 : 0, 0])
            coco_foot_positive();
        mirror([0, side < 0 ? 1 : 0, 0])
            coco_foot_cuts();
        translate([24, side * sole_cy, -ankle_h + sole_t - 1.5])
            coco_stamp_lr(side, h = 2.0);
    }
}

// =====================================================================
// Leg
// Origin: hip shaft, horn plane at y = 0 (inboard face of the flange).
// Ankle servo sits inboard (y < 0) with its horn at [0, 0, -leg_len].
// A 16 mm pipe runs outboard of the horn plane and is hulled into both
// the hip flange and the ankle cage so the part is one solid.
// =====================================================================
module coco_boom_axis() {
    // Children centred on the pipe axis, z = 0 at the hip shaft.
    translate([0, boom_y, 0])
        children();
}

module coco_leg_left() {
    cage_pad = wall + clearance;
    boom_top_z = -8;
    boom_bot_z = -leg_len + 10;
    difference() {
        union() {
            // Hip horn flange (sits on the stock round horn, plastic outboard).
            rotate([-90, 0, 0])
                cylinder(d = hip_flange_d, h = hip_flange_h);
            // Pipe between hip and ankle.
            coco_boom_axis()
                translate([0, 0, boom_bot_z])
                    cylinder(d = boom_d, h = boom_top_z - boom_bot_z);
            // Hip joint: flange disk fused into the top of the pipe.
            hull() {
                translate([0, hip_flange_h / 2, 0])
                    rotate([90, 0, 0])
                        cylinder(d = 20, h = hip_flange_h, center = true);
                coco_boom_axis()
                    translate([0, 0, boom_top_z])
                        sphere(d = boom_d);
            }
            // Ankle MG90S cage.
            translate([0, 0, -leg_len])
                mg90s_orient_shaft_y(1)
                    coco_servo_cage_solid(pad = cage_pad);
            // Outboard lip so the cage reaches the pipe (cage only extends
            // ~pad past the horn plane on +Y).
            hull() {
                coco_boom_axis()
                    translate([0, 0, boom_bot_z])
                        sphere(d = boom_d);
                translate([0, 2, -leg_len])
                    rotate([-90, 0, 0])
                        cylinder(d = 22, h = boom_y);
                translate([-8, 0, -leg_len - 8])
                    cube([16, boom_y + 2, 16]);
            }
        }
        // Hip horn seat + through-holes. Screw comes in from +Y.
        rotate([-90, 0, 0])
            mg90s_horn_cuts(h = 22, seat = 1.4);
        rotate([-90, 0, 0])
            translate([0, 0, -1])
                cylinder(d = 3.2, h = hip_flange_h + 10);
        translate([0, hip_flange_h - 1.5, 0])
            rotate([-90, 0, 0])
                cylinder(d1 = 3.4, d2 = 6.5, h = 2.0);
        // Ankle servo pocket, tab screws, top hatch.
        translate([0, 0, -leg_len])
            mg90s_orient_shaft_y(1)
                union() {
                    mg90s_pocket(clearance = clearance, extra_shaft = 18);
                    mg90s_tab_screws(d = 2.2, h = 28);
                    coco_servo_hatch(dir = 1);
                }
        // Cable duct through the pipe, open at both ends (not a closed cavity).
        coco_boom_axis()
            translate([0, 0, boom_bot_z - 2])
                cylinder(d = boom_id, h = boom_top_z - boom_bot_z + 6);
        // Hip exit: rear of the boom, intersecting the duct.
        translate([2, boom_y, boom_top_z - 1])
            rotate([0, -90, 0])
                cylinder(d = boom_id, h = 18);
        // Ankle: duct meets the MG90S cable slot (local −X / world rear).
        translate([-8, boom_y, boom_bot_z + 2])
            cube([20, boom_id + 1, boom_id + 1], center = true);
        translate([-12, 4, -leg_len])
            cube([16, 12, 6], center = true);
        // Zip-tie through the cage floor (world X), in solid wall below the body.
        translate([0, -mg90s_horn_z() * 0.35, -leg_len - (MG90S_BODY_W / 2 + 1.2)])
            rotate([0, 90, 0])
                cylinder(d = 3.4, h = 50, center = true);
    }
}

module coco_leg(side = 1) {
    difference() {
        mirror([0, side < 0 ? 1 : 0, 0])
            coco_leg_left();
        translate([0, side * (boom_y + boom_d / 2 - 0.2), -leg_len / 2])
            rotate([90, 90, 0])
                coco_label(side > 0 ? "L" : "R", size = 5.5, h = 1.2);
    }
}

// =====================================================================
// Base plate — hip servos + Pi Zero W + BEC / battery tie-downs
// Origin: plate centre, z = 0 at the bottom of the floor.
// =====================================================================
module coco_hip_pod_solid(side) {
    translate([hip_x, coco_hip_y(side), hip_z])
        mg90s_orient_shaft_y(side)
            coco_servo_cage_solid(pad = wall);
}

module coco_hip_pod_cut(side) {
    translate([hip_x, coco_hip_y(side), hip_z])
        mg90s_orient_shaft_y(side)
            union() {
                mg90s_pocket(clearance = clearance, extra_shaft = 16);
                mg90s_tab_screws(d = 2.2, h = 28);
                coco_servo_hatch(dir = side);
            }
}

module coco_pi_standoffs() {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([
            pi_cx + sx * pi_hole_dx / 2,
            pi_cy + sy * pi_hole_dy / 2,
            floor_t - 1.2
        ])
            difference() {
                cylinder(d = pi_standoff_d, h = pi_standoff_h + 1.2);
                translate([0, 0, -eps])
                    cylinder(d = pi_hole_d, h = pi_standoff_h + 2.0);
            }
    }
}

module coco_base_plate() {
    difference() {
        union() {
            linear_extrude(floor_t)
                coco_rounded_rect([plate_x, plate_y], r = 6);
            difference() {
                linear_extrude(rim_h)
                    coco_rounded_rect([plate_x, plate_y], r = 6);
                translate([0, 0, -eps])
                    linear_extrude(rim_h + 2 * eps)
                        coco_rounded_rect(
                            [plate_x - 2 * rim_t, plate_y - 2 * rim_t],
                            r = 5
                        );
            }
            coco_hip_pod_solid(1);
            coco_hip_pod_solid(-1);
            coco_pi_standoffs();
            for (s = [-1, 1])
                translate([pi_cx + 6, s * 24, floor_t - 0.4])
                    cube([24, 15, 1.6], center = true);
        }
        coco_hip_pod_cut(1);
        coco_hip_pod_cut(-1);
        // extra world-+Z hatches so each hip roof is fully open
        for (s = [-1, 1])
            translate([hip_x - 2, coco_hip_y(s) - s * 14, hip_z + 10])
                cube([24, 18, 16], center = true);
        for (sx = [-1, 1], sy = [-1, 1])
            translate([
                pi_cx + sx * pi_hole_dx / 2,
                pi_cy + sy * pi_hole_dy / 2,
                -eps
            ])
                cylinder(d = pi_hole_d, h = floor_t + pi_standoff_h + 1);
        // 2S pack straps under the Pi
        for (sx = [-1, 1], sy = [-1, 1])
            translate([pi_cx + sx * 16, sy * 14, floor_t / 2])
                cube([12, 2.2, 3.4], center = true);
        // hip-wire wells toward GPIO
        for (s = [-1, 1])
            translate([hip_x - 20, s * 10, -eps])
                cylinder(d = 6.5, h = floor_t + 2);
        // ankle-wire holes at the Y rim, beside each hip shaft
        for (s = [-1, 1])
            translate([hip_x - 8, s * (plate_y / 2 - 5), -eps])
                cylinder(d = 5.5, h = rim_h + 2);
        // cable well between the hip pods
        translate([hip_x - 8, 0, -eps])
            linear_extrude(floor_t + 2)
                coco_rounded_rect([14, 16], r = 3);
        translate([pi_cx + 4, 0, floor_t - 0.35])
            coco_label("COCO", size = 6, h = 0.55);
        // flatten anything that dipped below the bed
        translate([0, 0, -50])
            cube([plate_x + 20, plate_y + 20, 100], center = true);
    }
}

module coco_foot_print(side = 1) {
    translate([0, 0, ankle_h])
        coco_foot(side);
}

module coco_leg_print(side = 1) {
    // Inboard cage wall toward the bed; boom along the printer Y.
    // Slicers that auto-drop to z = 0 will sit the same face down.
    translate([0, 0, 34])
        rotate([90, 0, 0])
            coco_leg(side);
}

module coco_base_print() {
    coco_base_plate();
}
