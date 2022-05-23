// parametric fan size adapter
// b.kenyon.w@gmail.com CC-BY-SA

// For angled adapters (angle>0), install the BOSL2 library.
// For straight adapters (angle=0), you can just ignore the "can't open" warning.
// https://github.com/revarbat/BOSL2
include <BOSL2/std.scad>;

// fake enums
default = -2;
auto = -1;
none = 0;
thread = 1;
exact = 2;
through = 3;

// Fan size. Outside dimension of the square frame. Usually specify a standard fan size here like "40" or "120". If you want to specify an arbitrary/non-standard size, then you have to supply both *_fan_size and *_bolt_pattern, and may also want to change cowling_thickness or *_inside_diameter, as otherwise the ID will increase with the exterior size. May also want to manually specify *_screw_size, as the automatic screw size will increase at certain threshholds like >40. IE, if you want to use say a 40mm fan, but want the flanges to be 2mm wider, but don't want the ID to be larger, you manually specify, fan_A_size=42, fan_A_inside_diameter=38, fan_A_bolt_pattern=32, fan_A_screw_size=3.
fan_A_size = 60;
// Override bolt pattern spacing: -1=auto  Default is looked up from a table of standard fan sizes.
fan_A_bolt_pattern = auto;
// Override screw hole diameter: -1=auto  0=none  Default is looked up from a table of standard fan size ranges.
fan_A_screw_size = auto;
// Override screw hole type: 1=thread - hole smaller than *_screw_size for thread-forming, and disable pockets.  2=exact - hole exactly *screw_size for manual control.  3=through - hole larger than *_screw_size for pass-through. Default is through if angle=0 and thread if angle>0, and default is angle=0.
fan_A_mount_hole_type = auto;
// Override screw pocket diameter: -1=auto  0=disable  No effect when/where pockets are disabled, ex: _type=thread or angle>0. Default is *_screw_size*2.
fan_A_screw_pocket_diameter = auto;
// Override flange thickness: -1=default  Default is default_flange_thickness.
fan_A_flange_thickness = default;
// Override inside diameter: -1=auto  Default is *_fan_size-(cowling_thickness*2)
fan_A_inside_diameter = auto;

fan_B_size = 40;
fan_B_bolt_pattern = auto;
fan_B_screw_size = auto;
fan_B_mount_hole_type = auto;
fan_B_screw_pocket_diameter = auto;
fan_B_flange_thickness = default;
fan_B_inside_diameter = auto;

// creates an angled adapter - angle>0 requires github.com/revarbat/BOSL2 - Screw head pockets are disabled by default when angle>0. To force enable pockets, override the -1/auto value for *_mount_hole_type, ex: "fan_B_mount_hole_type = through; //-1;" would enable pockets for the fan_B flange, and change the hole dimension from being smaller than nominal (for thread-forming) to being larger than nominal (for pass-through).
angle = 0;
// like $fn but just for the main arc of an angled adapter - higher = smoother surface and longer render time
fn = 96;

// default flange thickness - if the flanges were flat, this would need to be more like 3 or 4, but they are not flat
default_flange_thickness = 2;

// For any holes with a screw head pocket enabled, minumum thickness of material under screw heads, regardless of other settings
minimum_screw_flange_thickness = 2;

// tunnel length: -1=auto  Distance between the two flanges, not including the flanges themselves. Default is whatever distance creates a 45 degree cone/funnel between the given fan sizes. For angled adapter, it's the arc length through the center of the bent tube, and may be longer depending on the angle between the flanges, but the minimum arc length is the same as the straght adapter, so that at very shallow angles, the flanges do not come any closer than for a straight adapter. For straight adapter, this may shorten the tunnel to anywhere from default to 0. For angled adapter, this will not shorten less than auto, but may lengthen.
tunnel_length = auto;

// move the fan_A flange off-center - Only for straight adapters. abs((fan_A_size-fan_B_size))/2 makes the 2 flanges exactly flush on one side.
xoffset = 0;
yoffset = 0;

// subtracted (*2) from *_fan_size to determine the default inside diameter
cowling_thickness = 1;

// angled adapter flange back thickness is automatic, but some combinations of options can result in too little, even 0 flange back thickness
minimum_angled_flange_back_thickness = 4;

// tunnel length is automatic, but some combinations of options can result in 0 tunnel length, which is ok in some cases but not always. This is only used if tunnel_length=auto and the auto would come out less than this. If you manually set tunnel_length, even to 0, it is used.
minimum_default_tunnel_length = 4;

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
fan_A_id =
 fan_A_inside_diameter > auto ? fan_A_inside_diameter :
 fan_A_size - cowling_thickness * 2;
fan_B_id =
 fan_B_inside_diameter > auto ? fan_B_inside_diameter :
 fan_B_size - cowling_thickness * 2;

// mount hole nominal diameter - M3, M4 etc
fan_A_mhnd =
 fan_A_screw_size > auto ? fan_A_screw_size :
 fbs(fan_A_size) ;
fan_B_mhnd =
 fan_B_screw_size > auto ? fan_B_screw_size :
 fbs(fan_B_size) ;
 
// mount hole type
fan_A_mht =
 fan_A_mount_hole_type > auto ? fan_A_mount_hole_type :
 angle > 0 ? thread :
 through ;
fan_B_mht =
 fan_B_mount_hole_type > auto ? fan_B_mount_hole_type :
 angle > 0 ? thread :
 through ;

// mount hole actual/adjusted diameter - M3 cutting threads, M3 pass through, etc
fan_A_mhad =
 fan_A_mht == exact ? fan_A_mhnd :
 fan_A_mht == thread ? screw_id(fan_A_mhnd) :
 screw_od(fan_A_mhnd) ;
fan_B_mhad =
 fan_B_mht == exact ? fan_B_mhnd :
 fan_B_mht == thread ? screw_id(fan_B_mhnd) :
 screw_od(fan_B_mhnd) ;

echo ("fan_A mount holes: nominal, actual",fan_A_mhnd,fan_A_mhad);
echo ("fan_B mount holes: nominal, actual",fan_B_mhnd,fan_B_mhad);

// mount hole pocket diameter
fan_A_pd =
 fan_A_mht == thread ? 0 :
 fan_A_size == fan_B_size ? 0 :
 fan_A_screw_pocket_diameter > auto ? fan_A_screw_pocket_diameter :
 fan_A_mhnd * 2;
fan_B_pd =
 fan_B_mht == thread ? 0 :
 fan_B_size == fan_A_size ? 0 :
 fan_B_screw_pocket_diameter > auto ? fan_B_screw_pocket_diameter :
 fan_B_mhnd * 2;

 // mount hole bolt pattern
fan_A_bp =
 fan_A_bolt_pattern > auto ? fan_A_bolt_pattern :
 fbp(fan_A_size);
assert(fan_A_bp > 0,"Unrecognized size for fan_A fan. See function fbp() for list of fan sizes.");
fan_B_bp =
 fan_B_bolt_pattern > auto ? fan_B_bolt_pattern :
 fbp(fan_B_size);
assert(fan_B_bp > 0,"Unrecognized size for fan_B fan. See function fbp() for list of fan sizes.");

// flange corner diameter
fan_A_cd = fan_A_size - fan_A_bp;
fan_B_cd = fan_B_size - fan_B_bp;

// flange thickness
fan_A_ft =
 fan_A_flange_thickness > auto ? fan_A_flange_thickness :
 default_flange_thickness ;
fan_B_ft =
 fan_B_flange_thickness > auto ? fan_B_flange_thickness :
 default_flange_thickness ;

// thickness under screw heads
fan_A_sft =
 fan_A_ft > minimum_screw_flange_thickness ? fan_A_ft :
 minimum_screw_flange_thickness ;
fan_B_sft =
 fan_B_ft > minimum_screw_flange_thickness ? fan_B_ft :
 minimum_screw_flange_thickness ;

// tunnel length - default 45 degree cone
def_tl = max(abs((fan_B_size-fan_A_size)/2),minimum_default_tunnel_length);
tl = tunnel_length > auto ? tunnel_length : def_tl;

assert(fan_A_ft+tl+fan_B_ft>0,"At least one of fan_A_flange_thickness, fan_B_flange_thickness, or tunnel_length must be thicker than 0!");

//////////////////////////////////////////////////////////////////////////////////
/// OUTPUT ///////////////////////////////////////////////////////////////////////

if(angle<=0) {
///////////////////////////////////////
////////   straight adapter   /////////

 difference() {
  group () {

   if(fan_A_ft>0) hull() c4(s=fan_A_bp,z=fan_A_ft,d=fan_A_cd); // flange A OD

   translate([0,0,fan_A_ft]) {
    if(tl<def_tl) hull() { // minimum wall when shallow angle would have left none or not enough
     if (fan_A_size>fan_B_size) c4(s=fan_A_bp,z=cowling_thickness,d=fan_A_cd);
     else translate([0,0,tl-cowling_thickness+o]) c4(s=fan_B_bp,z=cowling_thickness,d=fan_B_cd);
    }
    hull() { // normal transition tunnel
     c4(s=fan_A_bp,z=o,d=fan_A_cd,center=true); // fan_A end of transition OD
     translate ([xoffset,yoffset,tl]) c4(s=fan_B_bp,z=o,d=fan_B_cd,center=true); // fan_B end of transition OD
    }
   }

   if(fan_B_ft>0) translate ([xoffset,yoffset,fan_A_ft+tl]) hull() c4(s=fan_B_bp,z=fan_B_ft,d=fan_B_cd); // flange B OD

  }

  group() {
   hl = o+fan_A_ft+tl+fan_B_ft+o; // length to cut a hole through the entire body
   translate([0,0,-o]) cylinder(h=o+fan_A_ft+o,d=fan_A_id); // flange A ID

   translate([0,0,fan_A_ft]) hull() { // transition ID
    cylinder(h=o+o,d=fan_A_id,center=true);
    translate([xoffset,yoffset,tl]) cylinder(h=o+o,d=fan_B_id,center=true);
   }

   translate([xoffset,yoffset,-o+fan_A_ft+tl]) cylinder(h=o+fan_B_ft+o,d=fan_B_id); // fan_A flange ID

   translate([0,0,-o]) {
    c4(s=fan_A_bp,z=hl,d=fan_A_mhad); // fan_A mount holes
    translate([xoffset,yoffset,0]) c4(s=fan_B_bp,z=hl,d=fan_B_mhad); // fan_B mount holes
   }
   if (fan_A_pd > 0) translate([0,0,fan_A_sft+o+o]) c4(s=fan_A_bp,z=hl,d=fan_A_pd); // fan_A pockets
   if (fan_B_pd > 0) translate([xoffset,yoffset,-fan_B_sft-o-o]) c4(s=fan_B_bp,z=hl,d=fan_B_pd); // fan_B pockets
  } // /group

 } // /difference

} else {
/////////////////////////////////////
////////   angled adapter   /////////

 if (fan_A_mhad>fan_A_mhnd) echo("WARNING: Screw head pockets are generally incompatible with an angled adapter. Suggest using fan_A_mount_hole_type=thread to produce a small mount hole that you thread a screw directly into from the fan side.");
 if (fan_B_mhad>fan_B_mhnd) echo("WARNING: Screw head pockets are generally incompatible with an angled adapter. Suggest using fan_B_mount_hole_type=thread to produce a small mount hole that you thread a screw directly into from the fan side.");

 difference() {
  _tl = max(tl,def_tl); // minimum tunnel length def_tl or larger
  _r = max(fan_A_size,fan_B_size)/2; // minimum arc radius = larger fan radius
  _al = PI * _r * (angle/180); // minimum arc length based on angle & minimum arc radius
  al = max(_tl,_al); // arc length = larger of minimum tunnel length or minumim arc length
  r = max(_r,al/(angle*(PI/180))); // radius needed to get desired arc length
  tb = max(def_tl/2,minimum_angled_flange_back_thickness); // flange back thickness
  union () {
   flange(s=fan_A_size,d=0,t=fan_A_ft,b=fan_A_bp,m=fan_A_mhad,pt=fan_A_sft,pd=fan_A_pd,tb=tb); // fan_A flange
   translate([r,0,fan_A_ft]) rotate([0,angle,0]) translate([-r,0,fan_B_ft]) rotate([180,0,0]) flange(s=fan_B_size,d=0,t=fan_B_ft,b=fan_B_bp,m=fan_B_mhad,pt=fan_B_sft,pd=fan_B_pd,tb=tb); // fan_B flange
   translate([0,0,fan_A_ft]) bent_cone(a=angle,r=r,s1=fan_A_size,s2=fan_B_size,fn=fn,e=o); // bent cone OD
  }
  translate([0,0,fan_A_ft]) bent_cone(a=angle,r=r,s1=fan_A_id,s2=fan_B_id,fn=fn,e=max(fan_A_ft,fan_B_ft)+o); // bent cone ID
  // ugh.. for some combinations a little bit of the flange back pokes through the opposite flange face at shallow angles
  _tb = tb+1;
  translate([0,0,-_tb/2+o/2]) cube([fan_A_size+1,fan_A_size+1,_tb],center=true);
  translate([r,0,fan_A_ft]) rotate([0,angle,0]) translate([-r,0,fan_B_ft+_tb/2-o/2]) cube([fan_B_size+1,fan_B_size+1,_tb],center=true);
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
