# Export printable STLs from this folder.
# Requires OpenSCAD (https://openscad.org/) on PATH.

PARTS = foot_left foot_right leg_left leg_right base_plate
STLS  = $(addprefix stl/, $(addsuffix .stl, $(PARTS)))

.PHONY: stl clean

stl: $(STLS)

stl/%.stl: %.scad coco.scad mg90s.scad
	mkdir -p stl
	openscad -o $@ $<

clean:
	rm -rf stl
