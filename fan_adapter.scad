// simple parametric fan adapter
// b.kenyon.w@gmail.com

// +0 is just a trick to hide the variable from the thingiverse customizer

M3 = 3+0;
M4 = 4+0;
auto = -1+0;
none = 0+0;
thread = 1+0;
exact = 2+0;
pass = 3+0;

mount_hole_size = auto;
mount_hole_type = thread;

// _mount_hole_type modifies _mount_hole_size
// _type = "exact" -> mount holes will be exactly _size
// _type = "thread" -> mount holes will be smaller than _size for screw to cut threads into material
// _type = "pass" -> mount holes will be larger than _size to allow screw to pass through
// _type = anything-else -> _type = mount_hole_type

// fan sizes:  30 35 38 40 45 50 60 70 80 92 120 140
small_fan_size = 30;
small_mount_hole_size = mount_hole_size;
small_mount_hole_type = mount_hole_type;
small_mount_hole_pocket_diameter = auto;

large_fan_size = 40;
large_mount_hole_size = mount_hole_size;
large_mount_hole_type = mount_hole_type;
large_mount_hole_pocket_diameter = auto;

flange_thickness = 3;
min_screw_flange_thickness = 2;
cowling_thickness = 1+0;

// given fan size, return bolt pattern
function fbp(x) =
 x == 30 ? 24 :
 x == 35 ? 29 :
 x == 38 ? 32 :
 x == 40 ? 32 :
 x == 45 ? 37 :
 x == 50 ? 40 :
 x == 60 ? 50 :
 x == 70 ? 61.5 :
 x == 80 ? 71.5 :
 x == 90 ? 82.5 :
 x == 92 ? 82.5 :
 x == 120 ? 105 :
 x == 140 ? 125 :
 0 ;

// given fan size, return nominal mount hole size
function fmhnd(x) =
 x <= 40 ? M3 :
 M4 ;

o = 0.001+0;
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
 fmhnd(small_fan_size) ;
large_mhnd =
 large_mount_hole_size > auto ? large_mount_hole_size :
 fmhnd(large_fan_size) ;

// mount hole actual/adjusted diameter - M3 cutting threads, M3 pass through, etc
small_mhad =
 small_mount_hole_type == exact ? small_mhnd :
 small_mount_hole_type == thread ? screw_id(small_mhnd) :
 screw_od(small_mhnd) ;
large_mhad =
 large_mount_hole_type == exact ? large_mhnd :
 large_mount_hole_type == thread ? screw_id(large_mhnd) :
 screw_od(large_mhnd) ;

//echo ("small mount holes: nominal, actual",small_mhnd,small_mhad);
//echo ("large mount holes: nominal, actual",large_mhnd,large_mhad);

// mount hole pocket diameter
small_pd =
 small_mount_hole_pocket_diameter > auto ? small_mount_hole_pocket_diameter :
 small_mhnd * 2;
large_pd =
 large_mount_hole_pocket_diameter > auto ? large_mount_hole_pocket_diameter :
 large_mhnd * 2;

 // mount hole bolt pattern
small_bp = fbp(small_fan_size);
large_bp = fbp(large_fan_size);

// flange corner diameter
small_cd = small_fan_size - small_bp;
large_cd = large_fan_size - large_bp;

// minimum flange thickness
min_ft = o ;
ft =
 flange_thickness > min_ft ? flange_thickness :
 min_ft ;
// minimum thickness under screw heads
screw_ft =
 ft >= min_screw_flange_thickness ? ft :
 min_screw_flange_thickness ;

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
  if (small_mount_hole_type == pass)
   translate([0,0,screw_ft-o])
    c4(s=small_bp,z=hl,d=small_pd);
  if (large_mount_hole_type == pass)
   translate([0,0,-screw_ft-o])
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
