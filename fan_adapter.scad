// parametric fan size adapter
// b.kenyon.w@gmail.com CC-BY-SA

// Install BOSL2 library and uncomment to make angled adapters. (angle>0)
// You can comment this out for a straight adapter. (angle=0)
// https://github.com/revarbat/BOSL2
//include <BOSL2/std.scad>;

// +0 is just a trick to hide a variable from the thingiverse customizer
// fake enums
default = -2+0;
auto = -1+0;
none = 0+0;
thread = 1+0;
exact = 2+0;
through = 3+0;

// To make settings visible in thingiverse customizer,
// use numbers instead of variables/enums below.
// Example: foo=-1; instead of foo=auto;

// Fan size, which is the outside dimension of the square frame. Usually specify a standard fan size here like "40" or "120". You may specify an arbitrary/non-standard size, in which case you also need to manually supply *_bolt_pattern, and may also want to change cowling_thickness.
small_fan_size = 40;
// Override bolt pattern spacing: -1=auto
small_bolt_pattern = -1;
// Override screw hole diameter: -1=auto, 0=none
small_screw_size = -1;
// Override screw hole type: 1=thread 2=exact 3=through : 1/thread = make hole smaller than *_screw_size to cut threads into material, and disable screw head pocket. 2/exact = make hole exactly *_screw_size diameter, use for arbitrary manual control. 3/through = make hole larger than *_screw_size so screw passes through.
small_mount_hole_type = -1;
// Override screw pocket diameter: -1=auto, 0=none, no effect when _type=thread as pockets are disabled
small_screw_pocket_diameter = -1;
// Override flange thickness: -1=default
small_flange_thickness = -1;

large_fan_size = 60;
large_bolt_pattern = -1;
large_screw_size = -1;
large_mount_hole_type = -1;
large_screw_pocket_diameter = -1;
large_flange_thickness = -1;

// creates an angled adapter - REQUIRES github.com/revarbat/BOSL2 - NOTE: When making an angled adapter, it usually isn't practical to have screw head pockets, as the pockets would cut into the tube. So this design intentionally adds the tube after cutting the pockets, usually resulting in the the pockets having some intrusion from the tube. You can try it and see if you're ok with what you get. For some size combinations it works ok. But it is suggested to just use *_mount_hole_type=thread when making an angled adapter. *_mount_hole_type=-1 (auto) will use _type=thread when angle>0. For very small angles, you should manually increase tunnel_length so that the flanges seperate.
angle = 0;
// like $fn but just for the main arc of an angled adapter - higher = smoother and slower
fn = 96;

// default flange thickness
default_flange_thickness = 2;

// For any holes with a screw head pocket enabled, minumum thickness of material under screw heads, regardless of other settings
minimum_screw_flange_thickness = 2;

// tunnel length: -1=auto   Distance between the two flanges, not including the flanges. For angled adapter, it's arc length through the center of the bent tube. For a straight adapter, auto means whatever length needed to produce a 45 degree funnel. For an angled adapter, auto means arc radius == large fan radius (pivots on the edge of the larger flange, for the smallest possible adapter). For angled adapter, has no effect until you specify a value that's larger than the minimum.
tunnel_length = -1;

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

o = 1/128;
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
tl = tunnel_length > auto ? tunnel_length : (large_fan_size - small_fan_size) / 2;
 
/// OUTPUT //////////////////////////////////////////////////////////////////////////
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
  r = max(max(small_fan_size,large_fan_size)/2,tl/(angle*(PI/180))); // radius needed to make arc_length = tl, minimum large_fan/2
  tb = tl/2;
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
    translate([0,0,o/2]) c4(s=b,z=t+o,d=s-b,center=true);
    if (_tb>0) translate([0,0,-_z+t+_tb]) cylinder(d=s-_tb*2,h=o);
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
