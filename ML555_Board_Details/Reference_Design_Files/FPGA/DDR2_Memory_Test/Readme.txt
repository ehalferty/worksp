DDR2 Memory Test for ML555

This design is based on a MIG generated design and modified for the ML555 SODIMM
This design calibrates the I/O SERDES and does an infinite loop of read/write cycles and compares the data
    

LED(left or front of board) indicates a single bit error.  If lit there has be at least one error.
LED(middle)  indicates the current status of the compare logic.  If LED is lit most of the data compares are correct.  Probe this LED to verify if any toggling is occuring when LED (left) is on this will determine if the error is repeating or a one time error on LED (left)
LED(right or back of board) indicates that data valid for compare logic.  LED will be dim if data valid.  Reset button (middle) will show if the LED is brighter.  You can also probe this LED to verify the design is in the compare mode

The test is good if LED(left) is off, LED(middle) is on and LED(right) is dim.



The .cpj file is there for chipscope.  This project triggers if any of the 16 compare bits are indicating an error to verify that the LEDs are operating.

The directory struction for this design is



|_BitFiles
|        |_ DDR2_Memory_Test.bit
|        |_ DDR2_Memory_Test.cpj
|
|
|
|_Chipscope
|        |_ chipscope files for design regeneration
|
|
|
|_Ucf
|   |_ML555_DDR2_Memory_Test.ucf 
|
|
|
|_Verilog
        |_ verilog design files for design regeneration



If regeneration is needed use the following setting for implementation
Also ISE 9.1i is reccomended for regeneration

Synthesis
	Optimization Goal = Speed
	Optimization      = High
     	MaxFanout         = 50

Implmentation
	Map
		Placer Effort Level  = High
		Placer Extra Effort  = Normal
     		Optimization Stategy = Balanced
		Pack I/O Registers   = For Inputs & Outputs

	PAR
		Place and Route Mode         = Route Only
		Place and Route Effort Level = High
		Exta Effort Level            = Normal

Configuration
	Unused IOB Pins = Pull Down