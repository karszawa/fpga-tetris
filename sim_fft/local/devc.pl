#!/usr/bin/perl

use warnings;


    my $vhdl_opt =             " -64bit -message -update -pragma -work work -append_log ";
	   $vhdl_opt = $vhdl_opt . " -v93 -smartorder -smartlib -nowarn mrstar ";
	   $vhdl_opt = $vhdl_opt . " -logfile log.vhdl ";

    my $vlog_opt =             " -64bit -message -update -pragma -nowarn mrstar -append_log ";
#	   $vlog_opt = $vlog_opt . " -define VIRAGE_FAST_VERILOG -define MEM_CHECK_OFF ";
#	   $vlog_opt = $vlog_opt . " -define MACROSAFE ";
 	   $vlog_opt = $vlog_opt . " -define MODELSIM  ";
 	   $vlog_opt = $vlog_opt . " -define FOR_SIM  ";
 	   $vlog_opt = $vlog_opt . " -define SIMULATION  ";
#	   $vlog_opt = $vlog_opt . " -sv "; 
	   $vlog_opt = $vlog_opt . " -logfile log.vlog "; 
#	   $vlog_opt = $vlog_opt . " -define FPGA_USAGE ";

#	my $inc_path = "Training/";
#      if ($ARGV[0] =~ "dev") {
#        $inc_path = $inc_path . "dev";
#	  } elsif ($ARGV[0] =~ "trunk") {
#        $inc_path = $inc_path . "trunk";
#	  } elsif ($ARGV[0] =~ "var") {
#        $inc_path = $inc_path . "dev/var";
#	  }

    my $vlog_inc =             " -incdir ./../../include";

    open (IFILE, "<$ARGV[1]");

    while(<IFILE>) {

       chop;
       
       my $file = $_;

       if($file !~ m/^#/) {
           if($file =~ m/^rtl\//) {  
                $file =~ s/^rtl\///;
		      if ($ARGV[0] =~ "dev") {
                $file = "../rtl/" . $file;
			  } elsif ($ARGV[0] =~ "trunk") {
                $file = "../../trunk/rtl/" . $file;
			  } elsif ($ARGV[0] =~ "rqc") {
                $file = "../rqc/rtl/" . $file;
			  } elsif ($ARGV[0] =~ "var") {
                $file = "../var/rtl/" . $file;
			  }
            } elsif($file =~ m/^model\//) {  
                $file = "../" . $file;
            } elsif($file =~ m/^tb\//) {  
                $file =~ s/^tb\///;
                $file = "../../tb/" . $file;
            } elsif($file =~ m/^dvi\//) {  
                $file =~ s/^dvi\///;
                $file = "../../rtl/dvi/" . $file;
            } elsif($file =~ m/^txrx\//) {  
                $file =~ s/^txrx\///;
                $file = "../../rtl/tele_txrx/" . $file;
            } elsif($file =~ m/^fft\//) {  
                $file =~ s/^fft\///;
                $file = "../../rtl/fft/" . $file;
            } elsif($file =~ m/^FFT16\//) {  
                $file =~ s/^FFT16\///;
                $file = "../../rtl/FFT16/" . $file;
            } elsif($file =~ m/^sysele\//) {  
                $file =~ s/^sysele\///;
                $file = "../../rtl/sysele/" . $file;
            } elsif($file =~ m/^audio\//) {  
                $file =~ s/^audio\///;
                $file = "../../rtl/audio/" . $file;
            } elsif($file =~ m/^fpga\//) {  
                $file =~ s/^fpga\///;
                $file = "../../fpga/" . $file;
            }

            if($file =~ m/\.vhd/) {
                #vhdl compile
                system("ncvhdl $vhdl_opt $file");
            } elsif($file =~ m/.v/) {
                #verilog compile
                #print "$file\n";
                system("ncvlog $vlog_inc $vlog_opt $file");
            }
        }
    }          

    close(IFILE);
