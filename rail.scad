use <./trapezoid.scad>
tolerance=0.98; // used as multiplicator. 0.1=10%, 0.9=90%
sum_length=298;
// make sure to account for wedge length. so length of part must be +wedge_length long
total_length=161;
wedge_length=40;
slider_width=20;

// put rail for permanent spool and put in dent for insertion of sliders. --_--- instead of -----
initial_spool=true;
// put wedge on right side
wedge_right=true;
wedge_left=false;

assert(wedge_left != initial_spool, "You can only have the initial spool bit or a wedge on the left, not both at once!");

function value_if(condition, value) = condition ? value : 0;

module wedge(length, width, height) {
    difference() {
        cube([length,width,height]);
        rotate([0,-atan(height/length),0]) translate([0,-0.1,0]) cube([length*1.5,width+1,height+1]);
    };
}
// wedge(100,30,5);

module connector(length, width, height) {
    difference() {
        union() {
            wedge(length, width, height);
            translate([length-length/2,(width-height)/2,0]) cube([length/2,height,height]);
        }
        translate([0,(width-height)/2,0]) cube([length/2,height,height]);
    }
}
// connector(40,30,5);

module rail(initial_spool=initial_spool, wedge_right=wedge_right, wedge_left=wedge_left, total_length=total_length, rail_width=30, rail_height=5) {
    l = value_if(wedge_right, wedge_length) + value_if(wedge_left, wedge_length) + value_if(initial_spool, 2*slider_width);
    echo("Min length l=", l);
    assert(total_length > l, "Rail too short!");
    
    actual_width=rail_width*tolerance;
    short_side=actual_width-2*(rail_height*cos(45))/sqrt(1-pow(cos(45),2));
    difference() {
        translate([0,0,rail_height]) rotate([-90,0,0]) Trapezoid(b=actual_width,angle=45,H=rail_height,height=total_length);
        
        // remove rail for area for inserting sliders
        if (initial_spool) {
            w = slider_width*(2-tolerance);
            translate([-20,w,-1]) cube([50,w, 30]);
        }
        if (wedge_right) {
            translate([-rail_width/2,total_length-wedge_length,rail_height]) rotate([0,180,-90]) connector(wedge_length,rail_width,rail_height);
        }
        if (wedge_left) {
            translate([-rail_width/2,wedge_length,0]) rotate([0,0,-90]) connector(wedge_length,rail_width,rail_height);
        }
    }
    
    // add support back in
    if (initial_spool) {
        translate([-short_side/2,slider_width,0]) cube([short_side,slider_width+10, 2]);
    };
};
rail(wedge_left=false, initial_spool=true, wedge_right=true, total_length=81+40);
// translate([0,100,0]) 
// rail(wedge_left=true, initial_spool=false, wedge_right=false, total_length=length);
