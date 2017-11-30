`timescale 1ns/1ps

module display (
	input					disp_clk			,
	input					rst_disp_n			,

	input					i_disp_wen			, // WRITE TO DISP
	input					i_disp_men			,
	input		[ 7-1: 0]	i_disp_adr			,
	input		[ 4-1: 0]	i_disp_d			,

	output	    			o_sync_vs			,
	output	    			o_sync_hs			,
	output	    			o_sync_va			,
	output	    			o_sync_ha			,
	output	    			o_sync_de			,
	output	    [ 8-1: 0]	o_red    			,
	output	    [ 8-1: 0]	o_grn				,
	output	    [ 8-1: 0]	o_blu				,					
	output					o_area
);

wire sync_o_vs;
wire sync_o_hs;
wire sync_o_va;
wire sync_o_ha;
wire sync_o_de;


sync_gen A0_SYNC_GEN (
.disp_clk		(disp_clk		),//i
.rst_disp_n		(rst_disp_n		),//i
.o_sync_vs		(sync_o_vs		),//o
.o_sync_hs		(sync_o_hs		),//o
.o_sync_va		(sync_o_va		),//o
.o_sync_ha		(sync_o_ha		),//o
.o_sync_de		(sync_o_de		) //o
);

disp_digit A1_DISP_DIGIT (
.disp_clk		(disp_clk		),//i
.rst_disp_n		(rst_disp_n		),//i
.i_sync_vs		(sync_o_vs		),//i
.i_sync_hs		(sync_o_hs		),//i
.i_sync_va		(sync_o_va		),//i
.i_sync_ha		(sync_o_ha		),//i
.i_sync_de		(sync_o_de		),//i
.i_disp_wen		(i_disp_wen		),//i
.i_disp_men		(i_disp_men		),//i
.i_disp_adr		(i_disp_adr		),//i[ 7-1: 0]
.i_disp_d		(i_disp_d		),//i[ 4-1: 0]
.o_sync_vs		(o_sync_vs		),//o
.o_sync_hs		(o_sync_hs		),//o
.o_sync_va		(o_sync_va		),//o
.o_sync_ha		(o_sync_ha		),//o
.o_sync_de		(o_sync_de		),//o
.o_red    		(o_red    		),//o[ 8-1: 0]
.o_grn			(o_grn			),//o[ 8-1: 0]
.o_blu			(o_blu			),//o[ 8-1: 0]
.o_area			(o_area			)
);

endmodule

