// s@ecloud.org 2022
// License: Creative Commons - Attribution

boardWidth = 23;
boardLength = 51.5;
boardHeight = 1.65;
totalInnerHeight = 24;
topStickout = 18;

headerCutoutLength = 16;
headerCutoutWidth = 3;

wallThickness = 1.5;
velcroThickness = 5;
//preview[view:south, tilt:box]
//Number of facets
$fn = 24;
//(x axis) - actually length
width = boardLength + topStickout + wallThickness * 2;
//(y axis) - actually width
//~ depth = boardWidth + 2 + wallThickness * 2;
depth = 28;
//(z axis)
height = totalInnerHeight + wallThickness;

module quad(length, width) {
	children([0:$children-1]);
	translate([length, 0, 0])
		children([0:$children-1]);
	translate([length, width, 0])
		children([0:$children-1]);
	translate([0, width, 0])
		children([0:$children-1]);
}

module round4CornersCube(dims, r=1, centerXY=false)
{
	translate(centerXY ? [dims[0] / -2, dims[1] / -2, 0] : [0,0,0])
	union() {
		translate([0, r, 0])
			cube([dims[0], dims[1] - r * 2, dims[2]]);
		translate([r, 0, 0])
			cube([dims[0] - r * 2, dims[1], dims[2]]);
		translate([r, r, 0])
			quad(dims[0] - r * 2, dims[1] - r * 2)
				cylinder(r = r, h = dims[2]);
	}
}

module roundedCube( x, y, z, r ) {
	hull() {
		translate([r, r, r]) sphere(r);
		translate([r, y-r, r]) sphere(r);
		translate([r, r, z-r]) sphere(r);
		translate([r, y-r, z-r]) sphere(r);
		translate([x-r, r, r]) sphere(r);
		translate([x-r, y-r, r]) sphere(r);
		translate([x-r, r, z-r]) sphere(r);
		translate([x-r, y-r, z-r]) sphere(r);
	}
}

module boardCutout() {
	round4CornersCube([boardLength, boardWidth, boardHeight + 2], 2);
	// SD slot
	translate([boardLength - 4, (boardWidth - 16) / 2, boardHeight])
		cube([20, 16, 3]);
}

module pegs() {
	radius = 4;
	$fn=16;
	xLeft = topStickout - 1;
	translate([xLeft, boardWidth / 2 - 5, 1])
			cube([6, 6, 5]);
	translate([xLeft, boardWidth / -2 - 1, 1])
			cube([6, 6, 5]);
	translate([xLeft + boardLength - 3, boardWidth/ 2 - 5, 1])
			cube([6, 6, 5]);
	translate([xLeft + boardLength - 3, boardWidth / -2 - 1, 1])
			cube([6, 6, 5]);
}

module box() {
	difference() {
		union() {
			// main box and cutout
			difference() {
				translate([0, -depth/2, -velcroThickness]) {
					round4CornersCube([width,depth,height + velcroThickness + wallThickness], 2);
				}

				translate([wallThickness, -depth/2 + wallThickness, wallThickness]) {
					round4CornersCube([width - (wallThickness * 2), depth - (wallThickness * 2), height + 1], 1.5);
				}
			}

			pegs();
		}
		translate([wallThickness + topStickout, -boardWidth/2, 3])
			boardCutout();
		translate([wallThickness, -depth/2 + wallThickness, wallThickness - velcroThickness])
			cube([headerCutoutLength, depth - wallThickness * 2, 30]);
		translate([wallThickness, 3 - headerCutoutWidth / 2, -20])
			cube([headerCutoutLength, headerCutoutWidth, 40]);
		// maybe would fit the edge profile of the uradmonitor case, but also would make it harder to print
		//~ translate([-5, -depth/2, -20 + wallThickness - velcroThickness])
			//~ roundedCube(width + 10, depth, 20, 5);
		translate([topStickout, -7, -velcroThickness])
			cube([width, 14, velcroThickness]);
		translate([wallThickness / 2, wallThickness / 2 -depth/2, totalInnerHeight + wallThickness])
			cube([100, depth - wallThickness, 1]);
		translate([width - wallThickness - 1.5, -depth/2, totalInnerHeight + wallThickness])
			cube([10, depth, 3]);
	}
}

box();
