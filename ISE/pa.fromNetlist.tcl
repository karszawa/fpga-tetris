
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

hdi::project new -name ISE -dir "/home/jikken17/FPGA_TOP/ISE/planAhead_run_1" -netlist "/home/jikken17/FPGA_TOP/ISE/fpga_top.ngc" -search_path { {/home/jikken17/FPGA_TOP/ISE} }
hdi::project setArch -name ISE -arch virtex5
hdi::param set -name project.paUcfFile -svalue "/home/jikken17/FPGA_TOP/fpga/fpga_top.ucf"
hdi::floorplan new -name floorplan_1 -part xc5vlx50ff676-1 -project ISE
hdi::pconst import -project ISE -floorplan floorplan_1 -file "/home/jikken17/FPGA_TOP/fpga/fpga_top.ucf"
