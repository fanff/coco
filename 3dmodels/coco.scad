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
leg_len      = 56.0;   // hip shaft to foot-servo shaft (Z)
wall         = 3.6;
clearance    = 0.40;

// --- foot (MG90S laid in the sole, shaft pointing backward / −X) ---
sole_t       = 4.0;
toe_reach    = 43.0;   // forward-most toe centre, from the shaft
heel_lip     = 2.0;    // keep the heel short so the shin flange clears
foot_boss_h  = 6.5;
foot_boss_d  = 22.0;
ankle_h      = MG90S_BODY_W / 2 + clearance + wall + sole_t;

// Well footprint in foot XY after mg90s_orient_foot (left foot, shaft at origin).
function coco_foot_well_xmin() = -wall;
function coco_foot_well_xmax() = mg90s_horn_z() + wall;
function coco_foot_well_ymin() = -(mg90s_body_xmax() + wall);
function coco_foot_well_ymax() = -(mg90s_body_xmin() - wall);
function coco_foot_sole_x() = (coco_foot_well_xmin() + coco_foot_well_xmax()) / 2;
function coco_foot_sole_y() = (coco_foot_well_ymin() + coco_foot_well_ymax()) / 2;
// Slight tuck under the well walls; the sole then hulls forward to the toes.
hug_inset = 2.0;
// Round window in the front socket wall (opposite the shaft). Millimetres.
front_hole_d = 4.0;
// Laid-down motor top (world +Z). Everything above this plane is cut away
// so the servo can slide into the well from above.
function coco_foot_motor_top_z() = MG90S_BODY_W / 2;

// Four overlapping gnome-toe blobs (flattened spheres), inboard → outboard.
// Centres are close enough that the balls collide instead of splitting.
coco_toe_x = [38.0, toe_reach, 42.0, 37.0];
coco_toe_y = [-12.5, -5.0, 2.0, 9.0];
coco_toe_d = [16.0, 15.0, 14.0, 10.0];
toe_z_scale = 0.65;   // squash the spheres in Z (a bit taller than a flat slab)

// --- leg (U-channel shin; bottom bolts to the foot-servo horn) ---
hip_flange_d = 26.0;
hip_flange_h = 6.5;
u_wall       = 3.6;    // U arm / web thickness
u_inner_w    = 30.0;   // inside width along X (fore–aft)
u_inner_d    = 28.0;   // inside depth along −Y (inboard of the horn plane)
u_ankle_clear = 18.0;  // U stops this far above the foot-servo shaft
u_web_top_z  = -14.0;  // web stays below the hip servo body

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

// Preview-only RGB triad (not used by printable parts).
// Robot / left-foot frame: +X forward (toes), +Y left, +Z up.
// Origin is the foot-servo output shaft; −X is the shaft / heel.
module coco_axis_arrow(len, d = 2.0) {
    fn = 16;
    cylinder(d = d, h = len, $fn = fn);
    translate([0, 0, len])
        cylinder(d1 = d * 2.4, d2 = 0.15, h = 6.5, $fn = fn);
}

module coco_axes(len = 32) {
    color("White")
        sphere(d = 4.0, $fn = 20);
    // +X forward (toes)
    color("Red") {
        rotate([0, 90, 0])
            coco_axis_arrow(len);
        translate([len + 10, -7, 6])
            coco_label("+X", size = 6, h = 1.4);
    }
    // −X shaft / heel (shorter)
    color("Maroon") {
        rotate([0, -90, 0])
            coco_axis_arrow(len * 0.42);
        translate([-(len * 0.42 + 10), -7, 6])
            coco_label("-X", size = 5, h = 1.4);
    }
    // +Y left (outboard on the left foot)
    color("LimeGreen") {
        rotate([-90, 0, 0])
            coco_axis_arrow(len);
        translate([7, len + 10, 6])
            coco_label("+Y", size = 6, h = 1.4);
    }
    // +Z up
    color("DodgerBlue") {
        coco_axis_arrow(len);
        translate([8, 7, len + 10])
            coco_label("+Z", size = 6, h = 1.4);
    }
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
// Foot — MG90S lives in the sole, laid down, shaft pointing backward (−X).
// Origin: output shaft. Horn plane is YZ at x = 0 (horn toward −X).
// Body occupies +X (forward). Print sole-down.
// The well is sliced at the motor top (world +Z = BODY_W/2) so the servo
// slides in from above; nothing green sits above that plane.
// The ground plate is a compact gnome foot: short heel (shin clearance),
// a little margin around the motor, four overlapping flattened-sphere toes.
// =====================================================================

// Axis-aligned rounded outline of the motor well in foot XY.
module coco_foot_well_2d() {
    w = coco_foot_well_xmax() - coco_foot_well_xmin();
    d = coco_foot_well_ymax() - coco_foot_well_ymin();
    translate([coco_foot_sole_x(), coco_foot_sole_y()])
        coco_rounded_rect([w, d], r = 4);
}

// Pad under the well only (heel clipped). Used to keep the socket walls
// hugging the motor instead of flaring out along the toe plate.
module coco_foot_well_pad_2d() {
    w = coco_foot_well_xmax() - coco_foot_well_xmin() - 2 * hug_inset;
    d = coco_foot_well_ymax() - coco_foot_well_ymin() - 2 * hug_inset;
    intersection() {
        translate([coco_foot_sole_x(), coco_foot_sole_y()])
            coco_rounded_rect([w, d], r = 5);
        translate([heel_lip - 1, -40])
            square([90, 80]);
    }
}

// Ground plate: well pad hulled forward to the toes so the sole is one
// piece from the motor housing to the gnome balls. Left foot; right is Y-mirrored.
module coco_foot_sole_2d() {
    hull() {
        coco_foot_well_pad_2d();
        // Forefoot plate under the balls (not a matching disk per toe,
        // which made a coplanar kiss with the sphere cuts).
        for (i = [0 : 3])
            translate([coco_toe_x[i] - 4, coco_toe_y[i]])
                circle(d = coco_toe_d[i] * 0.70);
    }
}

// Flattened sphere sitting on the sole bed, overlapping its neighbours.
// Sunk into the plate so the union is a volume, not a tangent kiss.
module coco_foot_toe_ball(i) {
    r = coco_toe_d[i] / 2;
    translate([coco_toe_x[i], coco_toe_y[i], r * toe_z_scale - 1.0])
        scale([1, 1, toe_z_scale])
            sphere(d = coco_toe_d[i]);
}

module coco_foot_positive() {
    sole_z = -ankle_h;
    union() {
        translate([0, 0, sole_z]) {
            linear_extrude(sole_t)
                coco_foot_sole_2d();
            for (i = [0 : 3])
                coco_foot_toe_ball(i);
        }
        // Well walls hug the motor; they hull only onto the well pad, not
        // the toe plate, so the socket does not flare toward the toes.
        hull() {
            mg90s_orient_foot()
                coco_servo_cage_solid(pad = wall);
            translate([0, 0, sole_z + 0.3])
                linear_extrude(sole_t - 0.3)
                    coco_foot_well_pad_2d();
        }
    }
}

// Open-top slot at the cable end so the lead drops in with the servo.
// Local +Y is world +Z after mg90s_orient_foot, so the cube runs up
// through the motor-top plane and out the wall (local −X / outboard).
module coco_foot_wire_notch() {
    nw = 8.0;
    translate([
        mg90s_body_xmin() - 28,
        -4.0,
        -1.0
    ])
        cube([26, 24, nw]);
}

// Round window in the front socket wall, opposite the shaft (−X / heel).
// Coaxial with the output shaft; diameter is `front_hole_d`.
module coco_foot_front_hole() {
    translate([mg90s_horn_z() - 2, 0, 0])
        rotate([0, 90, 0])
            cylinder(d = front_hole_d, h = wall + 8);
}

module coco_foot_cuts() {
    sole_z = -ankle_h;
    mg90s_orient_foot()
        union() {
            mg90s_pocket(clearance = clearance, extra_shaft = 18, extra_cable = 4);
            mg90s_tab_screws(d = 2.2, h = 36);
            coco_foot_wire_notch();
        }
    coco_foot_front_hole();
    // Slice at the motor top: remove all green plastic above this plane.
    translate([0, 0, coco_foot_motor_top_z() + 50])
        cube([200, 200, 100], center = true);
    // Open the heel above the sole so the shin flange can sit on the horn.
    translate([-12, 0, 6])
        cube([24, foot_boss_d + 10, 32], center = true);
    // Zip-tie across the foot (world Y), under the body.
    translate([mg90s_horn_z() * 0.45, coco_foot_sole_y(), -MG90S_BODY_W / 2 - 0.8])
        rotate([90, 0, 0])
            cylinder(d = 3.4, h = 80, center = true);
    // Inset tread on the mid-sole (not the toe balls — offset would pinch them).
    translate([0, 0, sole_z])
        intersection() {
            translate([0, 0, -0.2])
                linear_extrude(2.0)
                    coco_foot_sole_2d();
            for (x = [10, 18, 26, 34])
                translate([x, coco_foot_sole_y(), 0.85])
                    cube([3.0, 16, 1.8], center = true);
        }
    // Flatten anything that dipped below the sole bed (sphere bottoms).
    translate([0, 0, sole_z - 50])
        cube([200, 200, 100], center = true);
}

module coco_foot(side = 1) {
    difference() {
        mirror([0, side < 0 ? 1 : 0, 0])
            coco_foot_positive();
        mirror([0, side < 0 ? 1 : 0, 0])
            coco_foot_cuts();
    }
}

// =====================================================================
// Leg — U-channel shin
// Origin: hip shaft, horn plane at y = 0.
// The U opens outboard (+Y). Bottom of the shin is a round-horn flange
// facing −X, which bolts onto the foot servo (shaft pointing backward).
// =====================================================================
function coco_u_x_inner() = u_inner_w / 2;
function coco_u_y_web() = -(u_inner_d + u_wall);

module coco_leg_u_2d() {
    w = u_inner_w;
    d = u_inner_d;
    t = u_wall;
    difference() {
        translate([-(w / 2 + t), -(d + t)])
            square([w + 2 * t, d + t]);
        translate([-w / 2, -d])
            square([w, d + t + 8]);
    }
}

module coco_leg_positive() {
    z_bot = -leg_len + u_ankle_clear;
    u_h = -z_bot + u_web_top_z + 2;
    union() {
        // Hip horn flange (plastic outboard of the hip horn).
        rotate([-90, 0, 0])
            cylinder(d = hip_flange_d, h = hip_flange_h);
        // U-channel from below the hip servo, stopping above the foot.
        translate([0, 0, z_bot])
            linear_extrude(u_h)
                coco_leg_u_2d();
        hull() {
            translate([0, 0.4, 0])
                rotate([-90, 0, 0])
                    cylinder(d = 20, h = hip_flange_h - 0.4);
            translate([
                -(coco_u_x_inner() + u_wall),
                -4,
                u_web_top_z - 2
            ])
                cube([u_inner_w + 2 * u_wall, 7, 8]);
        }
        // Foot-servo horn flange: disk in YZ, plastic toward −X (behind the horn).
        translate([0, 0, -leg_len])
            rotate([0, -90, 0])
                cylinder(d = foot_boss_d, h = foot_boss_h);
        // Rear slab from the U web to the horn, occupying the heel notch.
        translate([-foot_boss_h, coco_u_y_web(), -leg_len - 8])
            cube([foot_boss_h, -coco_u_y_web() + 3, 16]);
        // Fuse the slab into the rear of the U (overlap the rear arm).
        hull() {
            translate([-foot_boss_h, coco_u_y_web(), -leg_len + 6])
                cube([foot_boss_h, u_wall + 2, 4]);
            translate([
                -(coco_u_x_inner() + u_wall),
                coco_u_y_web(),
                z_bot
            ])
                cube([u_wall + 3, u_wall + 2, 5]);
        }
    }
}

module coco_leg_cuts() {
    // Hip horn seat + through-holes. Screw comes in from +Y.
    rotate([-90, 0, 0])
        mg90s_horn_cuts(h = 22, seat = 1.4);
    rotate([-90, 0, 0])
        translate([0, 0, -1])
            cylinder(d = 3.2, h = hip_flange_h + 10);
    translate([0, hip_flange_h - 1.5, 0])
        rotate([-90, 0, 0])
            cylinder(d1 = 3.4, d2 = 6.5, h = 2.0);
    // Foot-servo horn seat, facing −X (matches mg90s_orient_foot).
    translate([0, 0, -leg_len])
        rotate([0, -90, 0])
            mg90s_horn_cuts(h = 22, seat = 1.4);
    translate([0, 0, -leg_len])
        rotate([0, -90, 0])
            translate([0, 0, -1])
                cylinder(d = 3.2, h = foot_boss_h + 10);
    translate([-foot_boss_h + 1.5, 0, -leg_len])
        rotate([0, -90, 0])
            cylinder(d1 = 3.4, d2 = 6.5, h = 2.0);
    // Flatten the ankle flange so it stays above the sole.
    translate([0, 0, -leg_len - 40 - 9])
        cube([50, 50, 80], center = true);
    // Cable slot through the rear arm, down toward the foot servo.
    translate([-coco_u_x_inner() - u_wall / 2, -10, -leg_len + u_ankle_clear + 8])
        cube([u_wall + 4, 8, 6], center = true);
}

module coco_leg(side = 1) {
    difference() {
        mirror([0, side < 0 ? 1 : 0, 0])
            coco_leg_positive();
        mirror([0, side < 0 ? 1 : 0, 0])
            coco_leg_cuts();
        translate([
            coco_u_x_inner() + u_wall + 0.15,
            side * (-u_inner_d * 0.45),
            -leg_len * 0.52
        ])
            rotate([0, -90, 0])
                coco_stamp_lr(side, h = 1.8);
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
    // Inboard web on the bed, U opening upward (outboard).
    translate([0, 0, u_inner_d + u_wall])
        rotate([90, 0, 0])
            coco_leg(side);
}

module coco_base_print() {
    coco_base_plate();
}
