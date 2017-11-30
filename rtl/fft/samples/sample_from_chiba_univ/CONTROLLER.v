module CONTROLLER(START, DONE, SEL, CLK, RESET);
input START;
output DONE;
output SEL;
input CLK;
input RESET;
					    
reg [5:0] STATE;    // STATE にはコントローラの状態を記憶
					// 全34状態を記憶するため 6ビットを用意する
reg LAST_START;

always@(posedge CLK) begin
	if(RESET) begin
		LAST_START <= 0;
	end else begin
		LAST_START <= START;
		/* 直前のクロックにおける START の値を LAST_START に記憶しておく */
	end
end

always@(posedge CLK) begin
	if(RESET) begin
		STATE <= 0;
	end else begin
		case(STATE)
			 /* START 信号が立ち上がったとき、STATEを 1 にし、演算開始 */
			0:    STATE <= (~LAST_START & START) ? 1 : 0;
			33:    STATE <= 0;    // 演算終了時には初期状態 0 に戻す
			default:
				STATE <= STATE+1;    // 演算中は原則、STATE を1増加
			endcase
	end
end 

assign SEL = (STATE == 17);
		/* 16個の入力値をすべて入力し終え、フーリエ変換の演算を終えたときに
		パラレルシリアル変換器に演算結果を並列入力させる    */
assign DONE = (STATE == 18);

/* 続いて、演算結果逐次出力開始と同時に DONE 信号をオンにする    */

endmodule
