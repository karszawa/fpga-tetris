#!/bin/bash

NCVERILOG_FLAGS='+gui +ncaccess+rwc'

ncverilog ${NCVERILOG_FLAGS} -y ${XILINX}/verilog/src/unisims -y ${XILINX}/verilog/src/XilinxCoreLib +incdir+${XILINX}/verilog/src ${XILINX}/verilog/src/glbl.v \
 +libext+.v sim_top.v ../rtl/*.v ../rtl/lcd/*.v ../{pll,pll2}.v
