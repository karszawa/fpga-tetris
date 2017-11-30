`timescale 1ns/1ps

module	monitor_model #(
parameter WIDTH = 1024,
parameter HEIGHT = 768,
parameter PPM_BASE_NAME    = "display_1024x768_0"
)(
disp_clk,
rst_disp_n,
DE_OUT_VSYNC,
DE_OUT_HSYNC,
DE_OUT_DE,
DE_OUT_RGB
);
input        disp_clk;
input        rst_disp_n;
input        DE_OUT_HSYNC;
input        DE_OUT_VSYNC;
input        DE_OUT_DE;
input [29:0] DE_OUT_RGB;

reg	[70*8-1:0] OutputPpmBaseName;
reg	[ 4*8-1:0] OutputFrameNumber;
reg	[70*8-1:0] OutputPpmName;

//`include "tb_ids_package.h"


integer	fp_OutputPpmFile;

initial begin
	OutputPpmBaseName = PPM_BASE_NAME;
	OutputFrameNumber = "0000";
    fp_OutputPpmFile  = 0;
end


// Pixel data generation

reg DE_OUT_VSYNC_D;
reg [32-1:0] cnt;
always @(posedge disp_clk or negedge rst_disp_n) begin
	if (~rst_disp_n) begin
		cnt	<= 0;
	end else if (DE_OUT_VSYNC&~DE_OUT_VSYNC_D) begin
		cnt	<= 0;
	end else begin
		cnt	<= cnt+1;
	end
	if(DE_OUT_HSYNC && DE_OUT_DE && (fp_OutputPpmFile != 0)) begin
	
        if (^DE_OUT_RGB[29:20] === 1'bx) begin
		$fwrite(fp_OutputPpmFile, " %4d", 8'b0);
        end
        else begin
		$fwrite(fp_OutputPpmFile, " %4d",  DE_OUT_RGB[29:20]);	// R
        end

        if (^DE_OUT_RGB[19:10] === 1'bx) begin
		$fwrite(fp_OutputPpmFile, " %4d", 8'b0);
        end
        else begin
		$fwrite(fp_OutputPpmFile, " %4d",  DE_OUT_RGB[19:10]);	// G
        end
        
        if (^DE_OUT_RGB[ 9: 0] === 1'bx) begin
		$fwrite(fp_OutputPpmFile, " %4d\n", 8'b0);
        end else begin
		$fwrite(fp_OutputPpmFile, " %4d\n",  DE_OUT_RGB[ 9: 0]);	// B
        end      
        
                  
	end
end

// Open PPM file & check image format

always @(posedge disp_clk) begin
    DE_OUT_VSYNC_D <= DE_OUT_VSYNC;
end

always @(posedge DE_OUT_VSYNC)	begin
	if (fp_OutputPpmFile != 0) begin
        $write ("\nclose %d file\n",fp_OutputPpmFile); 
        $fclose(fp_OutputPpmFile);
        fp_OutputPpmFile = 0;
    end
end

always @(posedge DE_OUT_VSYNC_D)	begin

	if (OutputFrameNumber[ 8-1: 0] == "9") begin
		if (OutputFrameNumber[16-1: 8] =="9") begin
			if (OutputFrameNumber[24-1:16] =="9") begin
				OutputFrameNumber[32-1: 0] <= {OutputFrameNumber[32-1:24]+1, "000"};
			end else begin
				OutputFrameNumber[24-1: 0] <= {OutputFrameNumber[24-1:16]+1, "00"};
			end
		end else begin
			OutputFrameNumber[16-1: 8] <= {OutputFrameNumber[16-1:8]+1, "0"};
		end
	end else begin
		OutputFrameNumber[ 8-1: 0] <= OutputFrameNumber[ 8-1: 0] + 1;
	end

//	if (fp_OutputPpmFile != 0) begin
//       $write ("\nclose %d file\n",fp_OutputPpmFile); 
//       fp_OutputPpmFile = 0;
//       $fclose(fp_OutputPpmFile);
//  end

	OutputPpmName = {OutputPpmBaseName, OutputFrameNumber, ".ppm"};

	fp_OutputPpmFile = $fopen(OutputPpmName, "w");
	if (fp_OutputPpmFile == 0) begin
		$write ("\nCan not open input PPM file\n");
		$stop;
	end
	$write("DISP: Output frame count = %s (time=%t)\n", OutputFrameNumber, $time);
	$write("DISP: Output video : %s\n", OutputPpmName);

/*{{{*/
/*
`define S3840x2160    8'h00
`define S4096x2160    8'h01
`define S1920x2160    8'h02
`define S2048x2160    8'h03
`define S1920x1080    8'h10
`define S540x1080     8'h11
`define S720x480      8'h20

if (PARAM_DISP_FHD == 8'h00) begin
    $fdisplay(fp_OutputPpmFile, "P3");
    $fdisplay(fp_OutputPpmFile, "3840 216");
    $fdisplay(fp_OutputPpmFile, "1023");
end else if (PARAM_DISP_FHD == 8'h01) begin
    $fdisplay(fp_OutputPpmFile, "P3");
    $fdisplay(fp_OutputPpmFile, "4096 216");
    $fdisplay(fp_OutputPpmFile, "1023");    
end else if (PARAM_DISP_FHD == 8'h02) begin 
    $fdisplay(fp_OutputPpmFile, "P3");
    $fdisplay(fp_OutputPpmFile, "1920 216");
    $fdisplay(fp_OutputPpmFile, "1023");   
end else if (PARAM_DISP_FHD == 8'h03) begin 
    $fdisplay(fp_OutputPpmFile, "P3");
    $fdisplay(fp_OutputPpmFile, "2048 216");
    $fdisplay(fp_OutputPpmFile, "1023");          
end else if (PARAM_DISP_FHD == 8'h10) begin
    $fdisplay(fp_OutputPpmFile, "P3");
    $fdisplay(fp_OutputPpmFile, "1920 108");
    $fdisplay(fp_OutputPpmFile, "1023");    
end else if (PARAM_DISP_FHD == 8'h11) begin 
    $fdisplay(fp_OutputPpmFile, "P3");
    $fdisplay(fp_OutputPpmFile, "540 108");
    $fdisplay(fp_OutputPpmFile, "1023");     
end else if (PARAM_DISP_FHD == 8'h20) begin   
    $fdisplay(fp_OutputPpmFile, "P3");
    $fdisplay(fp_OutputPpmFile, "720 48");
    $fdisplay(fp_OutputPpmFile, "1023");     
end else begin
    $fdisplay(fp_OutputPpmFile, "P3");
    $fdisplay(fp_OutputPpmFile, "1920 108");
    $fdisplay(fp_OutputPpmFile, "1023");      
end
*/
/*}}}*/

    $fdisplay(fp_OutputPpmFile, "P3");
    $fdisplay(fp_OutputPpmFile, "%3d %3d", WIDTH, HEIGHT);
    $fdisplay(fp_OutputPpmFile, "1023");

    
end

endmodule

