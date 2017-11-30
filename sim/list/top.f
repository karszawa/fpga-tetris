# RTL LIST
dvi/DVI.v
dvi/DVIData.v
dvi/DVIInitial.v
dvi/IORegister.v
dvi/Register.v
dvi/SDR2DDR.v
dvi/PixelCounter.v
dvi/FIFOInitial.v
dvi/FIFORegister.v
dvi/FIFORegControl.v
dvi/FIFOShiftRound.v
dvi/I2CMaster.v
dvi/I2CDRAMMaster.v
dvi/Counter.v
dvi/CountCompare.v
dvi/CountRegion.v
dvi/ShiftRegister.v
dvi/HardRegister.v
dvi/sync_gen.v
dvi/display.v
dvi/disp_digit.v
dvi/disp_digit_seg.v
dvi/draw_rect.v
dvi/move_rect.v
dvi/button_detector.v
dvi/CPG.v
dvi/DVI_TOP.v


# TELE_TXRX
txrx/tele_tx.v
txrx/tele_rx.v
txrx/tele_err.v
txrx/tele_crg.v

# sysele
sysele/adc_sync.v
sysele/adc_test.v
sysele/control.v
sysele/dac_delay.v
sysele/lfsr32.v
sysele/rstgen.v
sysele/switch.v
sysele/sysele.v

sysele/comm/bpsk_inv.v
sysele/comm/bpsk.v
sysele/comm/collect_bpsk.v
sysele/comm/collect_qam16.v
sysele/comm/collect_qpsk.v
sysele/comm/comm_recv.v
sysele/comm/comm_send.v
sysele/comm/comm.v
sysele/comm/fftfifo.v
sysele/comm/iqdemap_bpsk.v
sysele/comm/iqdemap_qam16.v
sysele/comm/iqdemap_qpsk.v
sysele/comm/iqmap_bpsk.v
sysele/comm/iqmap_qam16.v
sysele/comm/iqmap_qpsk.v
sysele/comm/qam16_inv.v
sysele/comm/qam16.v
sysele/comm/qpsk_inv.v
sysele/comm/qpsk.v
sysele/comm/rescale.v
sysele/comm/slice_bpsk.v
sysele/comm/slice_qam16.v
sysele/comm/slice_qpsk.v
sysele/comm/variable_delay.v
sysele/comm/compmult/compmult.v

sysele/ec/ec_comm.v
sysele/ec/ec.v

sysele/lcd/ber.v
sysele/lcd/bin2bcd32.v
sysele/lcd/lcd_ber_top.v
sysele/lcd/lcd_ctrl_top.v
sysele/lcd/lcd_comm.v
sysele/lcd/lcd_control.v
sysele/lcd/lcd_memory.v
sysele/lcd/lcd.v
sysele/lcd/num2char.v
sysele/lcd/key2char.v
sysele/lcd_top.v

sysele/spi/spi_chunk.v
sysele/spi/spi.v

# FFT
fft/butterfly2.v
fft/cross_switch.v
fft/delay.v
fft/dpram.v
fft/fft16_stage.v
fft/fft32_stage.v
fft/fft64_stage.v
fft/fft64_top.v
fft/fft64.v
fft/fft_reorder.v
fft/fifo_2w1r_fwft.v
fft/ifft64.v
fft/interlace.v
fft/twiddle4.v

# AUDIO
audio/audio.v
audio/audio_if.v
audio/audio_proc.v

# PS/2
ps2/ps2_top.v
ps2/ps2_mouse.v
ps2/ps2_keyboard.v
ps2/ps2_keyboard_ctrl.v
ps2/ps2_command_out.v
ps2/ps2_data_in.v

# TB LIST
tb/crg.v
tb/tb.v
tb/monitor_model.v

# FPGA LIST
fpga/fpga_top.v

