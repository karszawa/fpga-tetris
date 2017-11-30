-64bit
//-covfile covfile.cf
-V200X
-access +rwc
-messages
-neg_tchk
-nosource
-update
-ntcnotchk
//-NOASSERT
-NEG_TCHK
//-NOTIMINGCHECKS
-DELAY_MODE zero
//-NOWARN CUVWSP
//-timescale 100ps/10ps
//-timescale 1ps/1ps
//-timescale 1ns/10ps
-timescale 1ps/1ps
-NOWARN MRSTAR
-NOWARN CUVWSB
-NOWARN STARMT
//default binding
-NOWARN CUDEFB
-NOWARN MEMODR
//Bit-select or part-select index out of declared bounds
-NOWARN BNDWRN
//Zero multiple concatenation multiplier
-NOWARN ZROMCV

