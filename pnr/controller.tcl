# proc is a function. this is used later to connect all the vdd! and vss! together.
proc connectGlobalNets {} {
	globalNetConnect vdd! -type pgpin -pin vdd! -all
	globalNetConnect vss! -type pgpin -pin vss! -all
	globalNetConnect vdd! -type tiehi -all
	globalNetConnect vss! -type tielo -all
	applyGlobalNets
}

# set the top level module name (used elsewhere in the scripts)
set design_toplevel control

# set the verilog file to pnr
set init_verilog synth/outputs/$design_toplevel.v

# set the lef file of your standard cells
# when you add your regfile lef, it is here
# if you want to supply more than one lef use the following syntax:
# set init_lef_file "1.lef 2.lef"
set init_lef_file "stdcells.lef"

# actually set the top level cell name
set init_top_cell $design_toplevel

# set power and ground net names
set init_pwr_net vdd!
set init_gnd_net vss!

# set multi-mode multi-corner file
# this file contains the operating conditions used to evaluate timing
# for your design. In our case, we just use the single lib file as our corner.
# In ECE 498HK, this will contain slow, typical and fast corners
# for the wires and the standard cells
set init_mmmc_file mmmc.tcl

# actually init the design
init_design

# connect all the global nets in the design together (vdd!, vss!)
# the function is defined above.
connectGlobalNets

# TODO floorplan your design. Put the size of your chip that you want here.
floorPlan -site CoreSite -s 20 20 10 10 10 10

# create the horizontal vdd! and vss! wires used by the standard cells.
sroute -allowJogging 0 -allowLayerChange 0 -crossoverViaLayerRange { metal7 metal1 } -layerChangeRange { metal7 metal1 } -nets { vss! vdd! }

# create a power ring around your processor, connecting all the vss! and vdd! together physically.
addRing \
	-follow core \
	-offset {top 2 bottom 2 left 2 right 2} \
	-spacing {top 2 bottom 2 left 2 right 2} \
	-width {top 2 bottom 2 left 2 right 2} \
	-layer {top metal7 bottom metal7 left metal8 right metal8} \
	-nets { vss! vdd! }

# TODO add power grid
# addStripe ...

# TODO restrict routing to only metal 6
setDesignMode -process 45 -bottomRoutingLayer metal1 -topRoutingLayer metal6

# TODO for the regfile part, place the regfile marco
# placeInstance ...

# TODO specify where are the pins
editPin -pin { clk imem_rdata[31:0] cmp_lt cmp_eq cmp_a_31 cmp_b_31 } \
  -side LEFT -spreadType CENTER -layer metal3

editPin -pin { 
    dmem_write dmem_wmask[3:0]
    rs1_sel[31:0] rs2_sel[31:0] rd_sel[31:0]
    alu_mux_1_sel alu_mux_2_sel alu_inv_rs2 alu_cin alu_op[1:0]
    shift_msb shift_dir cmp_mux_sel pc_mux_sel
    mem_mux_sel[2:0] rd_mux_sel[2:0]
    cmp_out imm[31:0]
} -side RIGHT -spreadType CENTER -layer metal3




# TODO uncomment the two below command to do pnr. These steps takes innovus more time.

# place all the standard cells in your design. This command is actually a series of many
# mini commands and settings, but it tries to optimally place the standard cells in your design
# considering area, timing, routing congestion, routing length, and other things.
# See "man place_design" to find out more.
place_design

routeDesign

#connectGlobalNets

# TODO find the command that checks DRC
verify_drc > drc.rpt

# save your design as a GDSII, which you can open in Virtuoso
streamOut controller.gdsii -mapFile "/class/ece425/innovus.map"

# save the design, so innovus can open it later
saveDesign controller
