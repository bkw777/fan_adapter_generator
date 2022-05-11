// simple parametric fan size adapter
// b.kenyon.w@gmail.com

// +0 is just a trick to hide a variable from the thingiverse customizer
// fake enums
default = -2+0;
auto = -1+0;
none = 0+0;
thread = 1+0;
exact = 2+0;
pass = 3+0;

// _mount_hole_size: nominal screw size, ex: 4 for M4 etc, not the exact diameter of the hole
//   auto = automatic based on fan size
//   none = no screw holes
//   #>0 = manually specified size
//   
// _mount_hole_type modifies _mount_hole_size
//   exact = holes will be exactly _size
//   thread = holes will be smaller than _size for screw to cut threads into material
//   pass = holes will be larger than _size to allow screw to pass through, and a pocket will be added for screw head or nut

// Use explicit numbers instead of enums below to make the settings visible in thingiverse customizer.
// ex: ..._type = 3; instead of ..._type = pass;

// 20 25 30 35 38 40 45 50 60 70 80 92 120 135 140 150 160 176 180 200 205 225 230 250
small_fan_size = 30;
// screw hole diameter: -1 = automatic, 0 = no screw holes
small_mount_hole_size = auto;
// 1=thread 2=exact 3=pass : 1/thread = screw hole smaller than _mount_hole_size to screw directly into material, also disables pocket, 2/exact = screw hole exactly _mount_hole_size diameter for manual control, 3/pass = screw hole larger than _mount_hole_size to pass screw through
small_mount_hole_type = pass;
// screw head pocket diameter: -1 = automatic based on screw size, ignored when _type=thread
small_screw_pocket_diameter = auto;
// -1 = auto
small_flange_thickness = auto;

large_fan_size = 40;
large_mount_hole_size = auto;
large_mount_hole_type = pass;
large_screw_pocket_diameter = auto;
large_flange_thickness = auto;

// additional body thickness beyond the exact height of the transition cone - 0 creates the thinnest possible adapter while still maintaining a 45 degree transition cone, which doesn't provide a lot of material for the screws, 3 is a good default, if _mount_hole_type=pass and flange_thickness>minimum_screw_flange_thickness then this is also the thickness of material left under the screw heads (sets how deep the mount hole pockets go)
additional_thickness = 2;

// if _mount_hole_type=pass, then the material under the screw heads will be at least this thick. if flange_thickness is greater, the material under the screw heads will be flange_thickness thick.
minimum_screw_flange_thickness = 2;

cowling_thickness = 1+0;

// given fan size, return bolt pattern
function fbp(x) =
 x == 20 ? 16 :
 x == 25 ? 20 :
 x == 30 ? 24 :
 x == 35 ? 29 :
 x == 38 ? 32 :
 x == 40 ? 32 :
 x == 45 ? 37 :
 x == 50 ? 40 :
 x == 60 ? 50 :
 x == 70 ? 61.5 :
 x == 80 ? 71.5 :
 x == 90 ? 82.5 :  // not a real fan size
 x == 92 ? 82.5 :
 x == 120 ? 105 :
 x == 135 ? 122 :  // also 110 & 113.3, but not all 4 corners
// x == 145 ?  :
 x == 140 ? 125 :
 x == 150 ? 122.3 :
 x == 160 ? 138.5 :
// x == 170 ?  :
 x == 176 ? 152.6 :
 x == 180 ? 152.6 :
 x == 200 ? 154 :
 x == 205 ? 174 :
 x == 225 ? 170 :
 x == 230 ? 170 :
 x == 250 ? 170 :
 0 ;

// given fan size, return bolt size
function fbs(x) =
 x <= 20 ? 2 :
 x <= 35 ? 2.5 :
 x <= 40 ? 3 :
 x <= 140 ? 4 :
 5 ;

o = 0.01+0;
//$fn = 72;
$fs = 0.5;
$fa = 1;

tunnel_length = (large_fan_size - small_fan_size) / 2;

// flange inside diameter
small_id = small_fan_size - cowling_thickness * 2;
large_id = large_fan_size - cowling_thickness * 2;

// mount hole nominal diameter - M3, M4 etc
small_mhnd =
 small_mount_hole_size > auto ? small_mount_hole_size :
 fbs(small_fan_size) ;
large_mhnd =
 large_mount_hole_size > auto ? large_mount_hole_size :
 fbs(large_fan_size) ;

// mount hole actual/adjusted diameter - M3 cutting threads, M3 pass through, etc
small_mhad =
 small_mount_hole_type == exact ? small_mhnd :
 small_mount_hole_type == thread ? screw_id(small_mhnd) :
 screw_od(small_mhnd) ;
large_mhad =
 large_mount_hole_type == exact ? large_mhnd :
 large_mount_hole_type == thread ? screw_id(large_mhnd) :
 screw_od(large_mhnd) ;

echo ("small mount holes: nominal, actual",small_mhnd,small_mhad);
echo ("large mount holes: nominal, actual",large_mhnd,large_mhad);

// mount hole pocket diameter
small_pd =
 small_mount_hole_type == thread ? 0 :
 small_screw_pocket_diameter > auto ? small_screw_pocket_diameter :
 small_mhnd * 2;
large_pd =
 large_mount_hole_type == thread ? 0 :
 large_screw_pocket_diameter > auto ? large_screw_pocket_diameter :
 large_mhnd * 2;

 // mount hole bolt pattern
small_bp = fbp(small_fan_size);
assert(small_bp > 0,"Unrecognized size for small fan. See function fbp() for list of fan sizes.");
large_bp = fbp(large_fan_size);
assert(large_bp > 0,"Unrecognized size for large fan. See function fbp() for list of fan sizes.");

// flange corner diameter
small_cd = small_fan_size - small_bp;
large_cd = large_fan_size - large_bp;

// additional "flange" thickness - not really a flange any more
// thickness of the plate shapes used with hull() to create the main body
// can be tiny but must be >0, so o is used if <o
ft =
 additional_thickness > o ? additional_thickness :
 o ;

// thickness under screw heads
small_ft =
 small_flange_thickness >= minimum_screw_flange_thickness ? small_flange_thickness :
 minimum_screw_flange_thickness ;
large_ft =
 large_flange_thickness >= minimum_screw_flange_thickness ? large_flange_thickness :
 minimum_screw_flange_thickness ;

/// OUTPUT //////////////////////////////////////////////////////////////////////////
difference() {

 // add main body 
 hull() {
  // small flange corners
  c4(s=small_bp,z=ft,d=small_cd);
  // large flange corners
  translate ([0,0,tunnel_length])
   c4(s=large_bp,z=ft,d=large_cd);
 }

 group() {
  hl = o+tunnel_length+ft+o;

  // cut small_id to large_id transition cone
  translate([0,0,tunnel_length/2+ft/2+o])
   cylinder(h=tunnel_length,d1=small_id,d2=large_id,center=true);
  // cut small flange id
  translate([0,0,hl/2-o])
   cylinder(h=hl,d=o+small_id+o,center=true);
  // cut large flange id
  translate([0,0,hl/2+tunnel_length+ft/2-o])
   cylinder(h=hl,d=large_id,center=true);

  // cut mount holes
  translate([0,0,-o]) {
   c4(s=small_bp,z=hl,d=small_mhad);
   c4(s=large_bp,z=hl,d=large_mhad);
  }

  // cut mount hole pockets
  if (small_pd > 0)
   translate([0,0,small_ft-o])
    c4(s=small_bp,z=hl,d=small_pd);
  if (large_pd > 0)
   translate([0,0,-large_ft-o])
    c4(s=large_bp,z=hl,d=large_pd);
 }
}
//////////////////////////////////////////////////////////////////////////////////

// 4 cylinders
module c4 (s,z,d) {
 ts = s/2;
 tz = z/2;
 mirror_copy([0,1,0])
  translate([0,ts,0])
   mirror_copy([1,0,0])
    translate([ts,0,tz])
     cylinder(h=z,d=d,center=true);
}

module mirror_copy(v) {
 children();
 mirror(v) children();
}

// bore diameter for screw to cut threads
function screw_id(x) = x - x/15;

// bore diameter for screw to pass through
function screw_od(x) = x + x/15;
