// parametric fan size adapter
// b.kenyon.w@gmail.com CC-BY-SA

// For angled adapters (angle>0), install the BOSL2 library.
// For straight adapters (angle=0), you can just ignore the "can't open" warning.
// https://github.com/revarbat/BOSL2
include <BOSL2/std.scad>;

// fake enums
default = -2+0; // +0 = trick to hide from thingiverse customizer
auto = -1+0;
none = 0+0;
thread = 1+0;
exact = 2+0;
through = 3+0;

// To make settings visible in thingiverse customizer,
// use numbers instead of variables/enums below.
// Example: foo=-1; instead of foo=auto;

// Fan size. Outside dimension of the square frame. Usually specify a standard fan size here like "40" or "120". If you want to specify an arbitrary/non-standard size, then you have to supply both *_fan_size and *_bolt_pattern, and may also want to change cowling_thickness or *_inside_diameter, as otherwise the ID will increase with the exterior size. May also want to manually specify *_screw_size, as the automatic screw size will increase at certain threshholds like >40. IE, if you want to use say a 40mm fan, but want the flanges to be 2mm wider, but don't want the ID to be larger, you manually specify, small_fan_size=42, small_inside_diameter=38, small_bolt_pattern=32, small_screw_size=3.
small_fan_size = 40;
// Override bolt pattern spacing: -1=auto  Default is looked up from a table of standard fan sizes.
small_bolt_pattern = -1;
// Override screw hole diameter: -1=auto  0=none  Default is looked up from a table of standard fan size ranges.
small_screw_size = -1;
// Override screw hole type: 1=thread - hole smaller than *_screw_size for thread-forming, and disable pockets.  2=exact - hole exactly *screw_size for manual control.  3=through - hole larger than *_screw_size for pass-through. Default is through if angle=0 and thread if angle>0, and default is angle=0.
small_mount_hole_type = -1;
// Override screw pocket diameter: -1=auto  0=disable  No effect when/where pockets are disabled, ex: _type=thread or angle>0. Default is *_screw_size*2.
small_screw_pocket_diameter = -1;
// Override flange thickness: -1=default  Default is default_flange_thickness.
small_flange_thickness = -1;
// Override inside diameter: -1=auto  Default is *_fan_size-(cowling_thickness*2)
small_inside_diameter = -1;

large_fan_size = 60;
large_bolt_pattern = -1;
large_screw_size = -1;
large_mount_hole_type = -1;
large_screw_pocket_diameter = -1;
large_flange_thickness = -1;
large_inside_diameter = -1;

// creates an angled adapter - angle>0 requires github.com/revarbat/BOSL2 - Screw head pockets are disabled by default when angle>0. To force enable pockets, override the -1/auto value for *_mount_hole_type, ex: "large_mount_hole_type = through; //-1;" would enable pockets for the large flange, and change the hole dimension from being smaller than nominal (for thread-forming) to being larger than nominal (for pass-through).
angle = 0;
// like $fn but just for the main arc of an angled adapter - higher = smoother surface and longer render time
fn = 96;

// default flange thickness - if the flanges were flat, this would need to be more like 3 or 4, but they are not flat
default_flange_thickness = 2;

// For any holes with a screw head pocket enabled, minumum thickness of material under screw heads, regardless of other settings
minimum_screw_flange_thickness = 2;

// tunnel length: -1=auto  Distance between the two flanges, not including the flanges themselves. Default is whatever distance creates a 45 degree cone/funnel between the given fan sizes. For angled adapter, it's the arc length through the center of the bent tube, and may be longer depending on the angle between the flanges, but the minimum arc length is the same as the straght adapter, so that at very shallow angles, the flanges do not come any closer than for a straight adapter. For straight adapter, this may shorten the tunnel to anywhere from default to 0. For angled adapter, this will not shorten less than auto, but may lengthen.
tunnel_length = -1;

// move the small flange off-center - Only for straight adapters. (large_fan_size-small_fan_size)/2 makes the 2 flanges exactly flush on one side.
xoffset = 0;
yoffset = 0;

// subtracted (*2) from *_fan_size to determine the default inside diameter
cowling_thickness = 1;

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

o = 1/128;
//$fn = 72;
$fs = 0.5;
$fa = 1;

// flange inside diameter
small_id =
 small_inside_diameter > auto ? small_inside_diameter :
 small_fan_size - cowling_thickness * 2;
large_id =
 large_inside_diameter > auto ? large_inside_diameter :
 large_fan_size - cowling_thickness * 2;

// mount hole nominal diameter - M3, M4 etc
small_mhnd =
 small_screw_size > auto ? small_screw_size :
 fbs(small_fan_size) ;
large_mhnd =
 large_screw_size > auto ? large_screw_size :
 fbs(large_fan_size) ;
 
// mount hole type
small_mht =
 small_mount_hole_type > auto ? small_mount_hole_type :
 angle > 0 ? thread :
 through ;
large_mht =
 large_mount_hole_type > auto ? large_mount_hole_type :
 angle > 0 ? thread :
 through ;

// mount hole actual/adjusted diameter - M3 cutting threads, M3 pass through, etc
small_mhad =
 small_mht == exact ? small_mhnd :
 small_mht == thread ? screw_id(small_mhnd) :
 screw_od(small_mhnd) ;
large_mhad =
 large_mht == exact ? large_mhnd :
 large_mht == thread ? screw_id(large_mhnd) :
 screw_od(large_mhnd) ;

echo ("small mount holes: nominal, actual",small_mhnd,small_mhad);
echo ("large mount holes: nominal, actual",large_mhnd,large_mhad);

// mount hole pocket diameter
small_pd =
 small_mht == thread ? 0 :
 small_screw_pocket_diameter > auto ? small_screw_pocket_diameter :
 small_mhnd * 2;
large_pd =
 large_mht == thread ? 0 :
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

// tunnel length - auto 45 degree funnel
def_tl = abs(large_fan_size-small_fan_size)/2;
tl = tunnel_length > auto ? tunnel_length : def_tl;

//////////////////////////////////////////////////////////////////////////////////
/// OUTPUT ///////////////////////////////////////////////////////////////////////

if(angle<=0) {
///////////////////////////////////////
////////   straight adapter   /////////

 difference() {
  group () {
   hull() {
    c4(s=large_bp,z=o+large_ft,d=large_cd); // large flange
    translate ([xoffset,yoffset,large_ft+tl-o]) c4(s=small_bp,z=o,d=small_cd); // small end of transition
   }
   hull() translate ([xoffset,yoffset,large_ft+tl]) c4(s=small_bp,z=small_ft,d=small_cd); // small flange
  }

  group() {
   hl = o+large_ft+tl+small_ft+o; // length to cut a hole through the entire body
   hull(){
    translate([0,0,-o/2+large_ft/2]) cylinder(h=o+large_ft,d=large_id,center=true); // large flange ID
    translate([xoffset,yoffset,large_ft+tl]) cylinder(h=o,d=small_id,center=true); // transition ID
   }
   if (small_ft > 0) translate([xoffset,yoffset,large_ft+tl+small_ft/2]) cylinder(h=o+small_ft+o,d=small_id,center=true); // small flange ID
   translate([0,0,-o]) {
    c4(s=large_bp,z=hl+o,d=large_mhad); // large mount holes
    translate([xoffset,yoffset,0]) c4(s=small_bp,z=hl+o,d=small_mhad); // small mount holes
   }
   if (large_pd > 0) translate([0,0,large_sft]) c4(s=large_bp,z=hl,d=large_pd); // large pockets
   if (small_pd > 0) translate([xoffset,yoffset,-o-o-small_sft]) c4(s=small_bp,z=hl,d=small_pd); // small pockets
  }
 }

} else {
/////////////////////////////////////
////////   angled adapter   /////////

 if (small_mhad>small_mhnd) echo("WARNING: Screw head pockets are generally incompatible with an angled adapter. Suggest using small_mount_hole_type=thread to produce a small mount hole that you thread a screw directly into from the fan side.");
 if (large_mhad>large_mhnd) echo("WARNING: Screw head pockets are generally incompatible with an angled adapter. Suggest using large_mount_hole_type=thread to produce a small mount hole that you thread a screw directly into from the fan side.");

 difference() {
  _tl = max(tl,def_tl); // minimum tunnel length def_tl or larger
  _r = max(small_fan_size,large_fan_size)/2; // minimum arc radius = large fan radius
  _al = PI * _r * (angle/180); // minimum arc length based on angle & minimum arc radius
  al = max(_tl,_al); // arc length = larger of minimum tunnel length or minumim arc length
  r = max(_r,al/(angle*(PI/180))); // radius needed to get desired arc length
  tb = def_tl/2; // flange back thickness
  union () {
   flange(s=large_fan_size,d=0,t=large_ft,b=large_bp,m=large_mhad,pt=large_sft,pd=large_pd,tb=tb); // large flange
   translate([r,0,large_ft]) rotate([0,angle,0]) translate([-r,0,small_ft]) rotate([180,0,0]) flange(s=small_fan_size,d=0,t=small_ft,b=small_bp,m=small_mhad,pt=small_sft,pd=small_pd,tb=tb); // small flange
   translate([0,0,large_ft]) bent_cone(a=angle,r=r,s1=large_fan_size,s2=small_fan_size,fn=fn,e=o); // bent cone OD
  }
  translate([0,0,large_ft]) bent_cone(a=angle,r=r,s1=large_id,s2=small_id,fn=fn,e=max(large_ft,small_ft)+o); // bent cone ID
 }
}

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

// bore diameter for screw to cut threads
function screw_id(x) = round((x-x/15)*10)/10;

// bore diameter for screw to pass through
function screw_od(x) = round((x+x/15)*10)/10;

// 4 cylinders
module c4 (s,z,d,center=false) {
 p = s/2;
 l = [[-p,-p,0],[-p,p,0],[p,p,0],[p,-p,0]];
 for(v=l) translate(v) cylinder(h=z,d=d,center=center);
}

module flange(s=50,d=-1,t=3,b=40,m=3,tb=-1,pt=0,pd=0,center=false) {
 _d = d<0 ? s-2 : d ;
 _z = center ? 0 : t/2 ;
 _tb = tb>auto ? tb : default_flange_thickness ;
 translate([0,0,_z]) {
  difference() {
   hull() {
    translate([0,0,o/2]) c4(s=b,z=t+o,d=s-b,center=true); // main plate
    if (_tb>0) translate([0,0,-_z+t+_tb]) cylinder(d=s-_tb*2,h=o); // extra back side thickness
   }
   group() {
    if(_d>0) cylinder(h=t+1,d=_d,center=true); // main hole
    if(m>0) translate([0,0,-o-_z]) c4(s=b,z=o+t+_tb+o,d=m); // mount holes
    if(pd>0) translate([0,0,-_z+pt]) c4(s=b,z=t+_tb,d=pd); // pockets
   }
  }
 }
}

module bent_cone(a=90,r=-1,s1=10,s2=20,fn=-1,e=0) {
 _r = r<0 ? max(s1,s2)/2 : r;
 sh = circle(d=s1);
 _fn = fn>0 ? fn : $fn>0 ? $fn : 36;
 nv = max(1,round(_fn/(360/a)));
 sc = ((s2/s1)-1)/nv;
 T = [for(i=[0:nv]) yrot(a*i/nv,cp=[_r,0,0])*scale([1+i*sc,1+i*sc,1])];
 sweep(sh,T);
 if (e>0) {
  translate([0,0,-e]) linear_extrude(height=o+e) polygon(sh);
  translate([_r,0,0]) rotate([0,a,0]) translate([-_r,0,-o]) linear_extrude(height=o+e) scale([1+nv*sc,1+nv*sc,1]) polygon(sh);
 }
}
