// parametric fan size adapter
// b.kenyon.w@gmail.com CC-BY-SA

// +0 is just a trick to hide a variable from the thingiverse customizer
// fake enums
default = -2+0;
auto = -1+0;
none = 0+0;
thread = 1+0;
exact = 2+0;
through = 3+0;

// *_mount_hole_size: nominal screw size, ex: 4 for M4 etc, not the exact diameter of the hole
//   auto = automatic based on fan size
//   none = no screw holes
//   
// *_mount_hole_type modifies *_mount_hole_size
//   exact = holes will be exactly *_mount_hole_size diameter
//   thread = holes will be smaller than *_mount_hole_size for screw to cut threads into material, and *_screw_pocket_diameter will be ignored, no screw head pockets will be added
//   through = holes will be larger than *_mount_hole_size to allow screw to pass through

// To make settings visible in thingiverse customizer,
// use numbers instead of variables/enums below.
// Example: foo=-1; instead of foo=auto;

// Fan size, which is the outside dimension of the square frame. Usually specify a standard fan size here like "40" or "120". You may specify an arbitrary/non-standard size, in which case you also need to manually supply *_bolt_pattern, and may also want to change cowling_thickness.
small_fan_size = 40;
// Override bolt pattern spacing: -1=auto
small_bolt_pattern = -1; //auto
// Override screw hole diameter: -1=auto, 0=none
small_screw_size = -1; //auto;
// Override screw hole type: 1=thread 2=exact 3=through : 1/thread = make hole smaller than *_screw_size to cut threads into material, and disable screw head pocket. 2/exact = make hole exactly *_screw_size diameter, use for arbitrary manual control. 3/through = make hole larger than *_screw_size so screw passes through.
small_mount_hole_type = 3; //through;
// Override screw pocket diameter: -1=auto, no effect when _type=thread as pockets are disabled
small_screw_pocket_diameter = -1; //auto;
// Override flange thickness: -1=default
small_flange_thickness = -1; //default;

large_fan_size = 60;
large_bolt_pattern = -1; //auto
large_screw_size = -1; //auto;
large_mount_hole_type = 3; //through;
large_screw_pocket_diameter = -1; //auto;
large_flange_thickness = -1; //default;

// default flange thickness
default_flange_thickness = 2;

// For any holes with a screw head pocket enabled, minumum thickness of material under screw heads, regardless of other settings
minimum_screw_flange_thickness = 2;

// transition/tunnel length - makes a 45 degree funnel regardless what the fan sizes are
tl = (large_fan_size - small_fan_size) / 2;

// move the small side off-center - hint: "tl" (a variable you can't see in the thingiverse customizer: (large_fan_size-small_fan_size)/2 ) makes the 2 flanges exactly flush on one side (unless you changed tl too).
xoffset = 0;
yoffset = 0;

// Because of the way fan sizes are defined by the frame's outside square dimension not the fan blades diameter, and the inside circle is determined by subtracting from that, you're not really free to modify this much. IE, if you wanted 2mm thick walls, it would just shrink the circle into the fan blades.
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
 x == 52 ? 42 :
 x == 60 ? 50 :
 x == 70 ? 61.5 :
 x == 75 ? 67 :
 x == 80 ? 71.5 :
 x == 90 ? 82.5 :  // not a real fan size, just a convenience instead of generating an error when you really meant 92
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
 x == 190 ? 150.6 : // automotive radiator
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
 x == 190 ? 6 :
 x <= 140 ? 4 :
 5 ;

o = 0.001+0;
//$fn = 72;
$fs = 0.5;
$fa = 1;

// flange inside diameter
small_id = small_fan_size - cowling_thickness * 2;
large_id = large_fan_size - cowling_thickness * 2;

// mount hole nominal diameter - M3, M4 etc
small_mhnd =
 small_screw_size > auto ? small_screw_size :
 fbs(small_fan_size) ;
large_mhnd =
 large_screw_size > auto ? large_screw_size :
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
small_bp = 
 small_bolt_pattern > auto ? small_bolt_pattern :
 fbp(small_fan_size);
assert(small_bp > 0,"Unrecognized size for small fan. See function fbp() for list of fan sizes.");
large_bp =
 large_bolt_pattern > auto ? large_bolt_pattern :
 fbp(large_fan_size);
assert(large_bp > 0,"Unrecognized size for large fan. See function fbp() for list of fan sizes.");

// flange corner diameter
small_cd = small_fan_size - small_bp;
large_cd = large_fan_size - large_bp;

// flange thickness
small_ft =
 small_flange_thickness > auto ? small_flange_thickness :
 default_flange_thickness ;
large_ft =
 large_flange_thickness > auto ? large_flange_thickness :
 default_flange_thickness ;

// thickness under screw heads
small_sft =
 small_ft > minimum_screw_flange_thickness ? small_ft :
 minimum_screw_flange_thickness ;
large_sft =
 large_ft > minimum_screw_flange_thickness ? large_ft :
 minimum_screw_flange_thickness ;

/// OUTPUT //////////////////////////////////////////////////////////////////////////
difference() {

 // add main body
 group () {
  hull() {
   // large face & large flange body
   c4(s=large_bp,z=o+large_ft,d=large_cd);
   // small face
   translate ([xoffset,yoffset,large_ft+tl-o])
    c4(s=small_bp,z=o,d=small_cd);
  }
 // small flange body
 hull()
  translate ([xoffset,yoffset,large_ft+tl])
   c4(s=small_bp,z=small_ft,d=small_cd);
 }

 group() {
  // length to cut a hole through the entire body
  hl = o+large_ft+tl+small_ft+o;

  // cut large flange id and large to small transition cone
  hull(){
   translate([0,0,-o/2+large_ft/2])
    cylinder(h=o+large_ft,d=large_id,center=true);
   translate([xoffset,yoffset,large_ft+tl])
    cylinder(h=o,d=small_id,center=true);
  }

  // cut small flange id
  if (small_ft > 0)
   translate([xoffset,yoffset,large_ft+tl+small_ft/2])
    cylinder(h=o+small_ft+o,d=small_id,center=true);

  // cut mount holes
  translate([0,0,-o]) {
   c4(s=large_bp,z=hl+o,d=large_mhad);
   translate([xoffset,yoffset,0])
    c4(s=small_bp,z=hl+o,d=small_mhad);
  }

  // cut mount hole pockets
  if (large_pd > 0)
   translate([0,0,large_sft])
    c4(s=large_bp,z=hl,d=large_pd);
  if (small_pd > 0)
   translate([xoffset,yoffset,-o-o-small_sft])
    c4(s=small_bp,z=hl,d=small_pd);
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
