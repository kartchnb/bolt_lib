// Bolt modeling library
//
// Simplifies (for me, anyway) generating models of and for common bolts and nuts
//
// Share and enjoy!
//
// 3 Jun 2022 - Brad Kartchner - v1.0.0
//  Initial release
// 25 Jun 2022 - Brad Kartchner - v1.0.1
//  Added support for screws with tapering heads

BoltLib_Version = "1.0.0";



// Include bolt parameter files
include<bolt_parameters/#8.scad>
include<bolt_parameters/10-24.scad>



// Assemble bolt parameters into one table
BoltLib_Bolt_Parameters = 
concat
(
    BoltLib_8_Parameters,
    BoltLib_10_24_Parameters
);

BoltLib_Valid_Bolt_Names = [ for (x = BoltLib_Bolt_Parameters) x[0] ];


// Checks if a given bolt name is recognized by the library
// Returns true if it is, false otherwise
function BoltLib_BoltNameIsValid(bolt_name) =
    let
    (
        bolt_name_index = search([bolt_name], BoltLib_Bolt_Parameters)[0]
    )
    bolt_name_index != [];



// Generate a negative for a specified bolt
module BoltLib_GenerateBoltNegative(bolt_name, length=0, expansion=0, valign="base")
{
    shaft_diameter = BoltLib_ShaftDiameter(bolt_name) + expansion*2;
    head_diameter_top = BoltLib_HeadDiameter(bolt_name) + expansion*2;
    head_diameter_base = BoltLib_HeadTaper(bolt_name) ? shaft_diameter : head_diameter_top;
    head_height = BoltLib_HeadHeight(bolt_name);

    // Determine how to align the negative vertically
    z_offset = 
        valign == "top" ? -length - head_height :
        valign == "head" ? -length :
        0;

    // Generate the negative
    translate([0, 0, z_offset])
    {
        // Generate the shaft
        cylinder(d=shaft_diameter, length);

        // Generate the head
        translate([0, 0, length])
            cylinder(d1=head_diameter_base, d2=head_diameter_top, head_height);
        
        // Expand the top of the head upward to make sure it clears the surrounding geometry
        translate([0, 0, length + head_height])
            cylinder(d=head_diameter_top, expansion);
    }
}



// Generate a model of a specified Bolt
module BoltLib_GenerateBoltModel(bolt_name, length=0, valign="base")
{
    BoltLib_GenerateBoltNegative(bolt_name, length, 0, valign);
}



// Generate a model of the nut for a specified bolt
module BoltLib_GenerateNutModel(bolt_name, valign="base")
{
    sides = BoltLib_NutSides();
    nut_envelope_diameter = BoltLib_NutEnvelopeDiameter(bolt_name);
    nut_height = BoltLib_NutHeight(bolt_name);
    shaft_diameter = BoltLib_ShaftDiameter(bolt_name);

    // Determine how to align the nut vertically
    z_offset = 
        valign == "top" ? -nut_height :
        valign == "center" ? -nut_height/2 :
        0;

    // Generate the nut model
    translate([0, 0, z_offset])
    {
        difference()
        {
            cylinder(d=nut_envelope_diameter, nut_height, $fn=sides);
            translate([0, 0, -0.01])
                cylinder(d=shaft_diameter, nut_height + 0.02);
        }
    }
}


// Retrieve the shaft diameter for a specified bolt
function BoltLib_ShaftDiameter(bolt_name) =
    _BoltLib_RetrieveParameter(bolt_name, "shaft diameter");



// Retrieve the head diameter for a specified Bolt
function BoltLib_HeadDiameter(bolt_name) =
    _BoltLib_RetrieveParameter(bolt_name, "head diameter");



// Retrieve the head height for a specified Bolt
function BoltLib_HeadHeight(bolt_name) =
    _BoltLib_RetrieveParameter(bolt_name, "head height");



// Retrieve whether the head of a specified bolt tapers in or not
function BoltLib_HeadTaper(bolt_name) =
    _BoltLib_RetrieveParameter(bolt_name, "head taper");



// Retrieve the nut flat diameter for a specified Bolt
function BoltLib_NutFlatDiameter(bolt_name) =
    _BoltLib_RetrieveParameter(bolt_name, "nut flat diameter");



// Calculate the length of a single side of the nut for a specified bolt
function BoltLib_NutSideLength(bolt_name) = 
    let
    (
        flat_diameter = BoltLib_NutFlatDiameter(bolt_name),
        sides = BoltLib_NutSides(),
        side_angle = 180/sides,
        side_length = 2 * flat_diameter * tan(side_angle)
    )
    side_length;



// Calculate the nut envelope diameter for a specified bolt
function BoltLib_NutEnvelopeDiameter(bolt_name) =
    // Calculate the envelope diameter from the flat diameter
    let
    (
        sides = BoltLib_NutSides(),
        theta = 360 / sides / 2,
        flat_diameter = BoltLib_NutFlatDiameter(bolt_name),
        envelope_diameter = flat_diameter / cos(theta)
    )
    envelope_diameter;



// Retrieve the nut height for a specified bolt
function BoltLib_NutHeight(bolt_name) = 
    _BoltLib_RetrieveParameter(bolt_name, "nut height");



// Retrieve the number of sides for all bolts
function BoltLib_NutSides() = 6;



//-----------------------------------------------------------------------------
// "Private" functions



// Retrieve the parameters for a specified Bolt
function _BoltLib_RetrieveParameter(bolt_name, key) =
    let
    (
        bolt_specific_table_index = search([bolt_name], BoltLib_Bolt_Parameters) [0],
        bolt_specific_table = BoltLib_Bolt_Parameters [bolt_specific_table_index] [1],
        parameter_index = search([key], bolt_specific_table) [0],
        parameter = bolt_specific_table [parameter_index] [1]
    )
    _BoltLib_ReturnIfBoltNameIsValid(bolt_name, parameter);



// Return the specified value if the Bolt name is valid
function _BoltLib_ReturnIfBoltNameIsValid(bolt_name, value) =
    BoltLib_BoltNameIsValid(bolt_name)
    ? value
    : assert(false, str("Bolt name \"", bolt_name, "\" is not currently supported by bolt_lib"));
