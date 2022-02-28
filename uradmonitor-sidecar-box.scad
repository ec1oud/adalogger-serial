// Derived from https://www.thingiverse.com/thing:1519333 by Martin Schiller
// That in turn was derived from https://www.thingiverse.com/thing:82533 by Aaron Newsome
// License: Creative Commons - Attribution

boardWidth = 23;
boardLength = 51.5;
boardHeight = 1.65;
totalInnerHeight = 24;
topStickout = 20;

wallThickness = 1.5;
//preview[view:south, tilt:bottom]
//Number of facets
$fn = 32;
//(x axis)
width = boardLength + wallThickness * 2;
//(y axis)
//~ depth = boardWidth + 2 + wallThickness * 2;
depth = 28 + wallThickness * 2;
//(z axis)
height = totalInnerHeight / 2+ wallThickness;
hingeOuter = 8.5;
hingeInner = 4.5;
hingeInnerSlop = .5;
hingeFingerSlop = .5;

fingerSize = 6.5;
topFingerSize = fingerSize;
latchWidth = 8;

//style at top cover
hole = 0; //[0:No holes,1:Circle,2:Square]
hole_diameter = 5;
//between hole centers
hole_spacing =10;
//border width without holes - measured from edge
hole_border =7.5;
//edge style
chamfer = 1; //[0:Sharp edges,1:Chamfer]

z = 0*width; //to be ignored by customizer
pos = -depth/2;
fingerLength = hingeOuter/1.65;

module corner_rounded_cube(l, w, h, r)
{
        union() {
                translate([0, r, 0])
                        cube([l, w - r * 2, h]);
                translate([r, 0, 0])
                        cube([l - r * 2, w, h]);
                translate([r, r, 0])
                        cylinder(r = r, h = h);
                translate([l - r, r, 0])
                        cylinder(r = r, h = h);
                translate([r, w - r, 0])
                        cylinder(r = r, h = h);
                translate([l - r, w - r, 0])
                        cylinder(r = r, h = h);
        }
}

module boardCutout() {
	corner_rounded_cube(boardLength, boardWidth, boardHeight + 2, 2);
	// SD slot
	translate([boardLength - 4, (boardWidth - 16) / 2, boardHeight])
		cube([20, 16, 3]);
}

module pegs() {
	radius = 4;
	$fn=16;
	xLeft = -width - fingerLength;
	translate([xLeft, boardWidth / 2 - 5, 1])
			cube([6, 6, 5]);
	translate([xLeft, boardWidth / -2 - 1, 1])
			cube([6, 6, 5]);
	translate([xLeft + boardLength - 3, boardWidth/ 2 - 5, 1])
			cube([6, 6, 5]);
	translate([xLeft + boardLength - 3, boardWidth / -2 - 1, 1])
			cube([6, 6, 5]);
}


if (chamfer == 1) {
	difference() {
		bottom();
		chamfer_bottom();
   	}
} else {
		bottom();
}

if (chamfer == 1) {
	difference() {
		top();
		chamfer_top();
   	}
	} else {
		top();
}


module chamfer_bottom() {
   difference() {
		translate([-width - fingerLength -0.2, -depth/2 -0.2, -0.1]) {
			cube([width+0.4,depth+0.4,wallThickness+0.1]);
		}
	   rotate(a=[180,0,0]) {
			translate([-width/2 - fingerLength, 0, -wallThickness-0.15]) {
				linear_extrude(height = wallThickness+0.3, center = false, convexity = 10,
				scale=([(width-2*wallThickness)/width,(depth-2*wallThickness)/depth] ))
		 		square([width+0.2,depth+0.2], true);
			}
		}
	}
}

module chamfer_top() {
   difference() {
		translate([ fingerLength -0.1, -depth/2 -0.2, -0.1]) {
			cube([width+0.4 + topStickout,depth+0.4,wallThickness]);
		}
	   rotate(a=[180,0,0]) {
			translate([width/2 + fingerLength + topStickout / 2, 0, -wallThickness -0.15]) {
				linear_extrude(height = wallThickness+0.3, center = false, convexity = 10,
				scale=([(width-2*wallThickness)/width,(depth-2*wallThickness)/depth] ))
		 		square([width+0.2 + topStickout,depth+0.2], true);
				}
		}
	}
}

module bottom() {
	difference() {
		union() {
			// main box and cutout
			difference() {
				translate([-width - fingerLength, -depth/2, 0]) {
					cube([width,depth,height]);
				}

				translate([(-width - fingerLength) + wallThickness, -depth/2 + wallThickness, wallThickness]) {
					cube([width - (wallThickness * 2), depth - (wallThickness * 2), height]);
				}
			}

			pegs();

			difference() {
				hull() {
					translate([0,-depth/2,height]) {
						rotate([-90,0,0]) {
							cylinder(r = hingeOuter/2, h = depth);
						}
					}
					translate([-fingerLength - .1, -depth/2,height - hingeOuter]){
						cube([.1,depth,hingeOuter]);
					}
					translate([-fingerLength, -depth/2,height-.1]){
						cube([fingerLength,depth,.1]);
					}
					translate([0, -depth/2,height]){
						rotate([0,45,0]) {
							cube([hingeOuter/2,depth,.01]);
						}
					}
				}

				// finger cutouts
				for  (i = [-depth/2 + fingerSize:fingerSize*2:depth/2]) {
					translate([-fingerLength,i - (fingerSize/2) - (hingeFingerSlop/2),0]) {
						cube([fingerLength*2,fingerSize + hingeFingerSlop,height*2]);
					}
				}
			}

			// center rod
			translate([0, -depth/2, height]) {
				rotate([-90,0,0]) {
					cylinder(r = hingeInner /2, h = depth);
				}
			}
		}
		translate([-boardLength - 7, -11.5, 3])
			boardCutout();
	}
}

module top() {
	union() {
		difference() {
			translate([fingerLength, -depth/2, 0]) {
				union() {
					cube([width + topStickout,depth,height - .5]);
					translate([fingerLength + boardLength, 0, 0]) {
						cube([topStickout - wallThickness - 2.5,depth,height * 3 - .5]);
					}
				}
			}

			translate([fingerLength + wallThickness, -depth/2 + wallThickness, wallThickness]) {
				cube([width + topStickout - wallThickness - 1.5, depth - (wallThickness * 2), height + 100]);
			}
		}

		difference() {
			hull() {
				translate([0,-depth/2,height]) {
					rotate([-90,0,0]) {
						cylinder(r = hingeOuter/2, h = depth);
					}
				}
				translate([fingerLength, -depth/2,height - hingeOuter - .5]){
					cube([.1,depth,hingeOuter - .5]);
				}
				translate([-fingerLength/2, -depth/2,height-.1]){
					cube([fingerLength,depth,.1]);
				}
				translate([0, -depth/2,height]){
					rotate([0,45,0]) {
						cube([hingeOuter/2,depth,.01]);
					}
				}
			}
			// finger cutouts
			for  (i = [-depth/2:fingerSize*2:depth/2 + fingerSize]) {
				translate([-fingerLength,i - (fingerSize/2) - (hingeFingerSlop/2),0]) {
					cube([fingerLength*2,fingerSize + hingeFingerSlop,height*2]);
				}
				if (depth/2 - i < (fingerSize * 1.5)) {
					translate([-fingerLength,i - (fingerSize/2) - (hingeFingerSlop/2),0]) {
						cube([fingerLength*2,depth,height*2]);
					}
				}
			}

			// center cutout
			translate([0, -depth/2, height]) {
				rotate([-90,0,0]) {
					cylinder(r = hingeInner /2 + hingeInnerSlop, h = depth);
				}
			}
		}
	}
}

//~ translate([-boardLength - 8, -8, 3])
//~ boardCutout();
