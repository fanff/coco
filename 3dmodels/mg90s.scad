// MG90S micro servo — dimensions, preview solid, and cutters.
// Units: millimetres.
//
// Local frame (matches common SG90/MG90S drawings):
//   origin  = output-shaft axis, at the bottom of the body
//   +Z      = toward the horn (along the shaft)
//   +X      = toward the cable, along the body length
//   +Y      = body width
//
// Clone bodies vary by a few tenths of a millimetre. Pockets use
// `clearance` so a typical FDM print (0.4 mm nozzle) still accepts the servo.

$fn = $fn ? $fn : 48;

// --- Nominal body (Tower Pro / common metal-gear clones) ---
MG90S_BODY_L = 23.0;
MG90S_BODY_W = 12.4;
MG90S_BODY_H = 22.8;

// Shaft is closer to one end of the 23 mm body (the gear/turret end).
MG90S_SHAFT_FROM_FRONT = 6.0;

MG90S_WING_L = 32.5;
MG90S_WING_T = 2.5;
MG90S_WING_Z = 16.0;          // bottom of body -> bottom of wings
MG90S_HOLE_SPACING = 27.8;
MG90S_HOLE_D = 2.0;

MG90S_TURRET_D = 11.8;
MG90S_TURRET_H = 4.6;
MG90S_SPLINE_D = 4.8;
MG90S_SPLINE_H = 3.2;

MG90S_CABLE_W = 4.0;
MG90S_CABLE_H = 1.4;
MG90S_CABLE_L = 8.0;

// Stock round horn (used as the mechanical adapter to printed parts).
MG90S_HORN_D = 20.0;
MG90S_HORN_T = 1.6;
MG90S_HORN_SCREW_D = 2.3;     // included horn screw ~M2
MG90S_HORN_HOLE_R = 7.5;      // 4-hole pattern on round horn
MG90S_HORN_HOLE_D = 1.6;

function mg90s_body_xmin() = -MG90S_SHAFT_FROM_FRONT;
function mg90s_body_xmax() = MG90S_BODY_L - MG90S_SHAFT_FROM_FRONT;
function mg90s_wing_zmid() = MG90S_WING_Z + MG90S_WING_T / 2;
function mg90s_shaft_z() = MG90S_BODY_H + MG90S_TURRET_H + MG90S_SPLINE_H / 2;
function mg90s_horn_z() = MG90S_BODY_H + MG90S_TURRET_H;

// Place children so the horn / turret plane is at the origin and the
// output shaft points along world ±Y (dir = 1 → +Y, dir = -1 → −Y).
// The servo body then lies toward the opposite Y (inboard on Coco).
// spin rotates about the shaft (local Z) before that mapping; 180 sends
// the cable toward world −X (rear of the robot).
module mg90s_orient_shaft_y(dir = 1, spin = 180) {
    rotate([dir * -90, 0, 0])
        translate([0, 0, -mg90s_horn_z()])
            rotate([0, 0, spin])
                children();
}

// Foot servo: 90° about world +Z from the hip Y-shaft pose.
// Shaft points world −X (backward). Body is laid down in the sole
// (local width → +Z); the 23 mm body occupies +X (toward the toes).
module mg90s_orient_foot(spin = 180) {
    rotate([0, 0, 90])
        mg90s_orient_shaft_y(dir = 1, spin = spin)
            children();
}

module mg90s_body_cube(extra = 0) {
    translate([
        mg90s_body_xmin() - extra,
        -MG90S_BODY_W / 2 - extra,
        -extra
    ])
        cube([
            MG90S_BODY_L + 2 * extra,
            MG90S_BODY_W + 2 * extra,
            MG90S_BODY_H + 2 * extra
        ]);
}

module mg90s_wing_cube(extra = 0) {
    translate([
        -MG90S_WING_L / 2 + (mg90s_body_xmin() + mg90s_body_xmax()) / 2 - extra,
        -MG90S_BODY_W / 2 - extra,
        MG90S_WING_Z - extra
    ])
        cube([
            MG90S_WING_L + 2 * extra,
            MG90S_BODY_W + 2 * extra,
            MG90S_WING_T + 2 * extra
        ]);
}

// Visual dummy (not for printing). Colour it in the assembly file.
module mg90s_dummy() {
    color("SteelBlue")
        difference() {
            union() {
                mg90s_body_cube();
                mg90s_wing_cube();
                translate([0, 0, MG90S_BODY_H])
                    cylinder(d = MG90S_TURRET_D, h = MG90S_TURRET_H);
                translate([0, 0, MG90S_BODY_H + MG90S_TURRET_H])
                    cylinder(d = MG90S_SPLINE_D, h = MG90S_SPLINE_H);
            }
            for (s = [-1, 1]) {
                x = (mg90s_body_xmin() + mg90s_body_xmax()) / 2
                    + s * MG90S_HOLE_SPACING / 2;
                translate([x, 0, MG90S_WING_Z - 0.5])
                    cylinder(d = MG90S_HOLE_D, h = MG90S_WING_T + 1);
            }
        }
    color("Orange")
        translate([
            mg90s_body_xmin() - MG90S_CABLE_L,
            -MG90S_CABLE_W / 2,
            1.0
        ])
            cube([MG90S_CABLE_L, MG90S_CABLE_W, MG90S_CABLE_H]);
}

// Subtract from a solid to leave a drop-in well + turret tunnel + cable slot.
// extra_shaft: how far the turret tunnel continues past the spline (through a wall).
module mg90s_pocket(clearance = 0.4, extra_shaft = 12, extra_cable = 10) {
    union() {
        mg90s_body_cube(extra = clearance);
        mg90s_wing_cube(extra = clearance);
        translate([0, 0, MG90S_BODY_H])
            cylinder(
                d = MG90S_TURRET_D + 2 * clearance + 0.6,
                h = MG90S_TURRET_H + MG90S_SPLINE_H + extra_shaft
            );
        // cable exit at the back of the body
        translate([
            mg90s_body_xmin() - extra_cable,
            -MG90S_CABLE_W / 2 - clearance,
            -clearance
        ])
            cube([
                extra_cable + clearance + 2,
                MG90S_CABLE_W + 2 * clearance,
                5
            ]);
    }
}

// Through-holes on the real servo tab axis (local +Z, along the shaft).
module mg90s_tab_screws(d = 2.2, h = 30) {
    for (s = [-1, 1]) {
        x = (mg90s_body_xmin() + mg90s_body_xmax()) / 2
            + s * MG90S_HOLE_SPACING / 2;
        translate([x, 0, mg90s_wing_zmid()])
            cylinder(d = d, h = h, center = true);
    }
}

// Flat flange that sandwiches a stock round horn.
// Origin at the shaft axis; flange occupies z = [0, h], sitting on the horn.
module mg90s_horn_flange(h = 5.0, od = 22.0) {
    difference() {
        cylinder(d = od, h = h);
        translate([0, 0, -0.2])
            cylinder(d = MG90S_HORN_SCREW_D + 0.4, h = h + 0.4);
        for (a = [0 : 90 : 270])
            rotate(a)
                translate([MG90S_HORN_HOLE_R, 0, -0.2])
                    cylinder(d = MG90S_HORN_HOLE_D + 0.3, h = h + 0.4);
        // shallow seat so the round horn centres itself
        translate([0, 0, -0.01])
            cylinder(d = MG90S_HORN_D + 0.4, h = 1.4);
    }
}

// Same cuts as the flange, for use inside difference() of a larger boss.
module mg90s_horn_cuts(h = 12, seat = 1.4) {
    translate([0, 0, -0.2])
        cylinder(d = MG90S_HORN_SCREW_D + 0.4, h = h);
    for (a = [0 : 90 : 270])
        rotate(a)
            translate([MG90S_HORN_HOLE_R, 0, -0.2])
                cylinder(d = MG90S_HORN_HOLE_D + 0.3, h = h);
    translate([0, 0, -0.01])
        cylinder(d = MG90S_HORN_D + 0.4, h = seat);
}
