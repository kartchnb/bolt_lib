/* [General Parameters] */
// The length of each bolt
Bolt_Length = 10;

// Display all supported bolt names?
Display_Bolt_Names = true;

// The amount the expand the negatives
Negative_Expansion = 0.501;



/* [Advanced] */
// The value to use for creating the model preview (lower is faster)
Preview_Quality_Value = 32;

// The value to use for creating the final model render (higher is more detailed)
Render_Quality_Value = 64;



include<bolt_lib/bolt_lib.scad>



module Generate(bolt_index = 0)
{
    bolt_name = BoltLib_Valid_Bolt_Names[bolt_index];

    echo();
    echo();
    echo();
    echo("-----------------------------------------");
    echo(str("Parameters for a '", bolt_name, "' bolt:"));

    supported = BoltLib_BoltNameIsValid(bolt_name);
    echo(supported=supported);
    if (supported)
    {
        echo(str("Shaft Diameter: ", BoltLib_ShaftDiameter(bolt_name)));
        echo(str("Head Diameter: ", BoltLib_HeadDiameter(bolt_name)));
        echo(str("Head Height: ", BoltLib_HeadHeight(bolt_name)));
        echo(str("Nut Flat Diameter: ", BoltLib_NutFlatDiameter(bolt_name)));
        echo(str("Nut Envelope Diameter: ", BoltLib_NutEnvelopeDiameter(bolt_name)));
        echo(str("Nut Height: ", BoltLib_NutHeight(bolt_name)));

        translate([0, 0, BoltLib_NutHeight(bolt_name) * 2])
        {
            BoltLib_GenerateBoltModel(bolt_name, Bolt_Length);
            %BoltLib_GenerateBoltNegative(bolt_name, Bolt_Length, Negative_Expansion);
        }

        BoltLib_GenerateNutModel(bolt_name);

        translate([0, -BoltLib_HeadDiameter(bolt_name) * (1 + bolt_index%2), 0])
            text(bolt_name, size=4, halign="center", valign="top");
    }
    
    else
    {
        echo(str ("'", bolt_name, "; is not a supported bolt name"));
    }
    
    if (bolt_index < len(BoltLib_Valid_Bolt_Names) - 1)
    {
        x_offset = BoltLib_HeadDiameter(bolt_name) + 10;
        translate([x_offset, 0, 0])
            Generate(bolt_index + 1);
    }
}



// Global parameters
iota = 0.001;
$fn = $preview ? Preview_Quality_Value : Render_Quality_Value;



// Generate the model
Generate();
    
if (Display_Bolt_Names)
{
    echo(str("All supported bolt names: ", BoltLib_Valid_Bolt_Names));
}
