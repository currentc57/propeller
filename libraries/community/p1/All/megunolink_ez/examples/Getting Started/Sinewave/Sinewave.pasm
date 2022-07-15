con
	_clkfreq = 80000000
	_clkmode = 1032
'         _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
'         _xinfreq = 5_000_000
	_xinfreq = 5000000
' 
'         TX = 30
	TX = 30
'         RX = 31
	RX = 31
'         LED = 16
	LED = 16
'         CR = $0A
	CR = 10
pub main
  coginit(0, @entry, 0)
dat
	org	0
entry
	mov	arg01, par wz
 if_ne	jmp	#spininit
	mov	pc, $+2
	call	#LMM_CALL_FROM_COG
	long	@@@_main
cogexit
	cogid	arg01
	cogstop	arg01
spininit
	mov	sp, arg01
	rdlong	objptr, sp
	add	sp, #4
	rdlong	pc, sp
	wrlong	ptr_hubexit_, sp
	add	sp, #4
	rdlong	arg01, sp
	add	sp, #4
	rdlong	arg02, sp
	add	sp, #4
	rdlong	arg03, sp
	add	sp, #4
	rdlong	arg04, sp
	sub	sp, #12
	jmp	#LMM_LOOP
LMM_LOOP
    rdlong LMM_i1, pc
    add    pc, #4
LMM_i1
    nop
    rdlong LMM_i2, pc
    add    pc, #4
LMM_i2
    nop
    rdlong LMM_i3, pc
    add    pc, #4
LMM_i3
    nop
    rdlong LMM_i4, pc
    add    pc, #4
LMM_i4
    nop
    rdlong LMM_i5, pc
    add    pc, #4
LMM_i5
    nop
    rdlong LMM_i6, pc
    add    pc, #4
LMM_i6
    nop
    rdlong LMM_i7, pc
    add    pc, #4
LMM_i7
    nop
    rdlong LMM_i8, pc
    add    pc, #4
LMM_i8
    nop
LMM_jmptop
    jmp    #LMM_LOOP
pc
    long @@@hubentry
lr
    long 0
hubretptr
    long @@@hub_ret_to_cog
LMM_NEW_PC
    long   0
    ' fall through
LMM_CALL
    rdlong LMM_NEW_PC, pc
    add    pc, #4
LMM_CALL_PTR
    wrlong pc, sp
    add    sp, #4
LMM_JUMP_PTR
    mov    pc, LMM_NEW_PC
    jmp    #LMM_LOOP
LMM_JUMP
    rdlong pc, pc
    jmp    #LMM_LOOP
LMM_RET
    sub    sp, #4
    rdlong pc, sp
    jmp    #LMM_LOOP
LMM_CALL_FROM_COG
    wrlong  hubretptr, sp
    add     sp, #4
    jmp  #LMM_LOOP
LMM_CALL_FROM_COG_ret
    ret
    
LMM_CALL_ret
LMM_CALL_PTR_ret
LMM_JUMP_ret
LMM_JUMP_PTR_ret
LMM_RET_ret
LMM_RA
    long	0
    
LMM_FCACHE_LOAD
    rdlong FCOUNT_, pc
    add    pc, #4
    mov    ADDR_, pc
    sub    LMM_ADDR_, pc
    tjz    LMM_ADDR_, #a_fcachegoaddpc
    movd   a_fcacheldlp, #LMM_FCACHE_START
    shr    FCOUNT_, #2
a_fcacheldlp
    rdlong 0-0, pc
    add    pc, #4
    add    a_fcacheldlp,inc_dest1
    djnz   FCOUNT_,#a_fcacheldlp
    '' add in a JMP back out of LMM
    ror    a_fcacheldlp, #9
    movd   a_fcachecopyjmp, a_fcacheldlp
    rol    a_fcacheldlp, #9
a_fcachecopyjmp
    mov    0-0, LMM_jmptop
a_fcachego
    mov    LMM_ADDR_, ADDR_
    jmpret LMM_RETREG,#LMM_FCACHE_START
a_fcachegoaddpc
    add    pc, FCOUNT_
    jmp    #a_fcachego
LMM_FCACHE_LOAD_ret
    ret
inc_dest1
    long (1<<9)
LMM_LEAVE_CODE
    jmp LMM_RETREG
LMM_ADDR_
    long 0
ADDR_
    long 0
FCOUNT_
    long 0
COUNT_
    long 0
prcnt_
    long 0
pushregs_
      movd  :write, #local01
      mov   prcnt_, COUNT_ wz
  if_z jmp  #pushregs_done_
:write
      wrlong 0-0, sp
      add    :write, inc_dest1
      add    sp, #4
      djnz   prcnt_, #:write
pushregs_done_
      wrlong COUNT_, sp
      add    sp, #4
      wrlong fp, sp
      add    sp, #4
      mov    fp, sp
pushregs__ret
      ret
popregs_
      sub   sp, #4
      rdlong fp, sp
      sub   sp, #4
      rdlong COUNT_, sp wz
  if_z jmp  #popregs__ret
      add   COUNT_, #local01
      movd  :read, COUNT_
      sub   COUNT_, #local01
:loop
      sub    :read, inc_dest1
      sub    sp, #4
:read
      rdlong 0-0, sp
      djnz   COUNT_, #:loop
popregs__ret
      ret

multiply_
	mov	itmp2_, muldiva_
	xor	itmp2_, muldivb_
	abs	muldiva_, muldiva_
	abs	muldivb_, muldivb_
	jmp	#do_multiply_

unsmultiply_
	mov	itmp2_, #0
do_multiply_
	mov	result1, #0
	mov	itmp1_, #32
	shr	muldiva_, #1 wc
mul_lp_
 if_c	add	result1, muldivb_ wc
	rcr	result1, #1 wc
	rcr	muldiva_, #1 wc
	djnz	itmp1_, #mul_lp_
	shr	itmp2_, #31 wz
	negnz	muldivb_, result1
 if_nz	neg	muldiva_, muldiva_ wz
 if_nz	sub	muldivb_, #1
multiply__ret
unsmultiply__ret
	ret
' code originally from spin interpreter, modified slightly

unsdivide_
       mov     itmp2_,#0
       jmp     #udiv__

divide_
       abs     muldiva_,muldiva_     wc       'abs(x)
       muxc    itmp2_,divide_haxx_            'store sign of x (mov x,#1 has bits 0 and 31 set)
       abs     muldivb_,muldivb_     wc,wz    'abs(y)
 if_z  jmp     #divbyzero__
 if_c  xor     itmp2_,#1                      'store sign of y
udiv__
divide_haxx_
        mov     itmp1_,#1                    'unsigned divide (bit 0 is discarded)
        mov     DIVCNT,#32
mdiv__
        shr     muldivb_,#1        wc,wz
        rcr     itmp1_,#1
 if_nz   djnz    DIVCNT,#mdiv__
mdiv2__
        cmpsub  muldiva_,itmp1_        wc
        rcl     muldivb_,#1
        shr     itmp1_,#1
        djnz    DIVCNT,#mdiv2__
        shr     itmp2_,#31       wc,wz    'restore sign
        negnz   muldiva_,muldiva_         'remainder
        negc    muldivb_,muldivb_ wz      'division result
divbyzero__
divide__ret
unsdivide__ret
	ret
DIVCNT
	long	0

fp
	long	0
imm_1000000000_
	long	1000000000
imm_1000_
	long	1000
imm_1056964608_
	long	1056964608
imm_1073741824_
	long	1073741824
imm_1078527525_
	long	1078527525
imm_1120403456_
	long	1120403456
imm_1427211495_
	long	1427211495
imm_196608_
	long	196608
imm_2147483647_
	long	2147483647
imm_2147483648_
	long	-2147483648
imm_262144_
	long	262144
imm_327680_
	long	327680
imm_393216_
	long	393216
imm_4294967264_
	long	-32
imm_4294967273_
	long	-23
imm_4294967295_
	long	-1
imm_536870912_
	long	536870912
imm_65532_
	long	65532
imm_655360_
	long	655360
imm_65536_
	long	65536
imm_720896_
	long	720896
imm_8388607_
	long	8388607
imm_9600_
	long	9600
itmp1_
	long	0
itmp2_
	long	0
objptr
	long	@@@objmem
ptr_L__0073_
	long	@@@LR__0122
ptr_L__0074_
	long	@@@LR__0123
ptr_L__0075_
	long	@@@LR__0124
ptr_L__0076_
	long	@@@LR__0125
ptr_L__0077_
	long	@@@LR__0126
ptr_L__0078_
	long	@@@LR__0127
ptr_L__0079_
	long	@@@LR__0128
ptr_L__0080_
	long	@@@LR__0129
ptr_L__0083_
	long	@@@LR__0130
ptr_L__0084_
	long	@@@LR__0131
ptr_L__0085_
	long	@@@LR__0132
ptr_L__0086_
	long	@@@LR__0133
ptr_L__0087_
	long	@@@LR__0134
ptr_L__0088_
	long	@@@LR__0135
ptr_L__0089_
	long	@@@LR__0136
ptr_L__0090_
	long	@@@LR__0137
ptr__Float32_dat__
	long	@@@_Float32_dat_
ptr__FloatString_dat__
	long	@@@_FloatString_dat_
ptr__FullDuplexSerialAvail_dat__
	long	@@@_FullDuplexSerialAvail_dat_
ptr__Numbers_dat__
	long	@@@_Numbers_dat_
ptr_hubexit_
	long	@@@hubexit
result1
	long	0
sp
	long	@@@stackspace
COG_BSS_START
	fit	496
hub_ret_to_cog
	jmp	#LMM_CALL_FROM_COG_ret
hubentry

'   fstr        : "FloatString"
' 
' PUB main | ms, last_cnt, current_cnt, f_tpi, f_rot, temp
_main
	mov	COUNT_, #3
	call	#pushregs_
' 
'   meguno.start(RX, TX, 9_600)
	mov	arg01, #31
	mov	arg02, #30
	mov	arg03, imm_9600_
	add	objptr, #20
	call	#LMM_CALL
	long	@@@_megunolink_ez_start
'   f.start
	add	objptr, #228
	call	#LMM_CALL
	long	@@@_Float32_start
' 
'   ms := 0
	mov	local01, #0
' 
'   ' Create some data to send. Here, a value from sine and cosine curves.
'   f_frequency := 0.5
	mov	arg02, imm_1056964608_
	sub	objptr, #236
	wrlong	arg02, objptr
'   f_phase := f.fdiv(3.141, 2.0)
	mov	arg01, imm_1078527525_
	mov	arg02, imm_1073741824_
	add	objptr, #236
	call	#LMM_CALL
	long	@@@_Float32_FDiv
	sub	objptr, #232
	wrlong	result1, objptr
'   f_tPi := f.fMul(2.0, 3.141)
	mov	arg01, imm_1073741824_
	mov	arg02, imm_1078527525_
	add	objptr, #232
	call	#LMM_CALL
	long	@@@_Float32_FMul
	mov	arg01, result1
'   f_rot := f.fMul(f_tPi, f_frequency)
	sub	objptr, #236
	rdlong	arg02, objptr
	add	objptr, #236
	call	#LMM_CALL
	long	@@@_Float32_FMul
	mov	local02, result1
' 
'   meguno.writeTplotSet(string("title"), string("Sine and Cosine Waveforms"))
	mov	arg01, ptr_L__0073_
	mov	arg02, ptr_L__0074_
	sub	objptr, #228
	call	#LMM_CALL
	long	@@@_megunolink_ez_writeTplotSet
'   meguno.writeTplotSet(string("x-label"), string("Time"))
	mov	arg01, ptr_L__0075_
	mov	arg02, ptr_L__0076_
	call	#LMM_CALL
	long	@@@_megunolink_ez_writeTplotSet
'   meguno.writeTplotSet(string("y-label"), string("Amplitude"))
	mov	arg01, ptr_L__0077_
	mov	arg02, ptr_L__0078_
	call	#LMM_CALL
	long	@@@_megunolink_ez_writeTplotSet
' 
'   meguno.writeTplotStyle(string("Sinewave"), "b", "s", "_", 2)
	mov	arg01, ptr_L__0079_
	mov	arg02, #98
	mov	arg03, #115
	mov	arg04, #95
	mov	arg05, #2
	call	#LMM_CALL
	long	@@@_megunolink_ez_writeTplotStyle
'   meguno.writeTplotStyle(string("Cosinewave"), "r", "d", ";", 2)
	mov	arg01, ptr_L__0080_
	mov	arg02, #114
	mov	arg03, #100
	mov	arg04, #59
	mov	arg05, #2
	call	#LMM_CALL
	long	@@@_megunolink_ez_writeTplotStyle
	sub	objptr, #20
' 
'   last_cnt := cnt
	mov	local03, cnt
'   'ms := (clkfreq / 1000 )+ last_cnt                             'ms counter
' 
'   repeat
LR__0001
'     meguno.listen               ' WARNING: This function must be called repeatedly to response touch events
	add	objptr, #20
	call	#LMM_CALL
	long	@@@_megunolink_ez_listen
	sub	objptr, #20
'                                 ' from Nextion touch panel. Actually, you should place it in your loop function.
'     current_cnt := cnt
	mov	arg03, cnt
'     ms += (current_cnt - last_cnt) / (clkfreq / 1000 )
	mov	arg02, arg03
	sub	arg02, local03
	rdlong	muldiva_, #0
	mov	muldivb_, imm_1000_
	call	#divide_
	mov	muldiva_, arg02
	call	#divide_
	add	local01, muldivb_
'     last_cnt := current_cnt
	mov	local03, arg03
' 
'     f_seconds := f.fDiv(f.FFloat(ms), f.FFloat(1000))
	mov	arg01, local01
	add	objptr, #248
	call	#LMM_CALL
	long	@@@_Float32_FFloat
	mov	arg03, result1
	mov	arg01, imm_1000_
	call	#LMM_CALL
	long	@@@_Float32_FFloat
	mov	arg02, result1
	mov	arg01, arg03
	call	#LMM_CALL
	long	@@@_Float32_FDiv
	sub	objptr, #240
	wrlong	result1, objptr
' 
'     'Send Data To MegunoLink.
'     f_y :=  f.sin(f.fMul(f_rot, f_seconds))
	mov	arg02, result1
	mov	arg01, local02
	add	objptr, #240
	call	#LMM_CALL
	long	@@@_Float32_FMul
	mov	arg01, result1
	call	#LMM_CALL
	long	@@@_Float32_Sin
	sub	objptr, #248
	wrlong	result1, objptr
'             'sin(2 * 3.141 * f_frequency * f_seconds)
'     f_y2 := f.cos(f.fAdd(f.fMul(f_rot, f_seconds), f_phase))
	add	objptr, #8
	rdlong	arg02, objptr
	mov	arg01, local02
	add	objptr, #240
	call	#LMM_CALL
	long	@@@_Float32_FMul
	mov	arg01, result1
	sub	objptr, #232
	rdlong	arg02, objptr
	add	objptr, #232
	call	#LMM_CALL
	long	@@@_Float32_FAdd
	mov	arg01, result1
	call	#LMM_CALL
	long	@@@_Float32_Cos
	sub	objptr, #244
	wrlong	result1, objptr
	sub	objptr, #4
'             'cos(2 * 3.141 * f_frequency * f_seconds + f_phase)
'             
'     'values can be sent as integers, floats or fixed point
'     
'     'float has a precision argument that selects how many total digits of precision to send
'     meguno.writeTplotFloat(string("Sinewave"), f_y, 2)
	mov	arg01, ptr_L__0083_
	rdlong	arg02, objptr
	mov	arg03, #2
	add	objptr, #20
	call	#LMM_CALL
	long	@@@_megunolink_ez_writeTplotFloat
'     'meguno.writeTplotFloat(string("Cosinewave"), f_y2, 2)
'     
'     'fixed point will display send with the given number of decimal places
'     'the provided value is effetively divided by the number of decimal places
'     temp := f.ftrunc(f.fMul(f_y2, 100.0))  'first we need an integer that has the extra digits we need
	sub	objptr, #16
	rdlong	arg01, objptr
	mov	arg02, imm_1120403456_
	add	objptr, #244
	call	#LMM_CALL
	long	@@@_Float32_FMul
	mov	arg01, result1
	call	#LMM_CALL
	long	@@@_Float32_FTrunc
	mov	arg02, result1
'     meguno.writeTplotFixed(string("Cosinewave"), temp, 2) 'now we pass the int to MegunoLink
	mov	arg01, ptr_L__0084_
	mov	arg03, #2
	sub	objptr, #228
	call	#LMM_CALL
	long	@@@_megunolink_ez_writeTplotFixed
	sub	objptr, #20
' 
' 
'     waitcnt(clkfreq / 100 + cnt)                       'delay so we don't overwhelm the serial channel
	rdlong	muldiva_, #0
	mov	muldivb_, #100
	call	#divide_
	mov	arg01, muldivb_
	add	arg01, cnt
	waitcnt	arg01, #0
	sub	pc, #4*(($+1) - LR__0001)
	mov	sp, fp
	call	#popregs_
_main_ret
	call	#LMM_RET

'   fMath         : "FloatMath"
' 
' PUB start(rxPin, txPin, baud)                        'Must be run before using object
_megunolink_ez_start
' {{
' }}
'   meguno.start(rxPin, txPin, SERIAL_MODE, baud)
	mov	arg04, arg03
	mov	arg03, #0
	add	objptr, #20
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Start
	sub	objptr, #20
'   waitcnt(clkfreq / 100 + cnt)                          'wait for serial to init
	rdlong	muldiva_, #0
	mov	muldivb_, #100
	call	#divide_
	mov	arg01, muldivb_
	add	arg01, cnt
	waitcnt	arg01, #0
'   convertNum.init
	add	objptr, #92
' ''Initialize to default settings.  Init MUST be called before first object use.
' ''  ┌──────────────────────────────────────────────────┐
' ''  │             DEFAULT SPECIAL SYMBOLS              │
' ''  ├─────┬──────┬─────────────────────────────────────┤
' ''  │ ID  │ Char │ Usage                               │
' ''  ├─────┼──────┼─────────────────────────────────────┤
' ''  │  1  │  ,   │ Comma (digit group separator)       │
' ''  │  2  │  _   │ Underscore (digit group separator)  │
' ''  │  3  │  $   │ Dollar Sign (Hexadecimal indicator) │
' ''  │  4  │  %   │ Percent Sign (Binary indicator)     │
' ''  │ 5-7 │      │ Unused (User definable via Config)  │
' ''  └─────┴──────┴─────────────────────────────────────┘
'   Config(@DefaultSymbols)
	mov	arg01, ptr__Numbers_dat__
	call	#LMM_CALL
	long	@@@_Numbers_Config
	sub	objptr, #92
_megunolink_ez_start_ret
	call	#LMM_RET

' 
' PUB writeTplotSet(ptr_attrib, ptr_txt)
_megunolink_ez_writeTplotSet
	mov	COUNT_, #2
	call	#pushregs_
	mov	local01, arg01
	mov	local02, arg02
'   meguno.str(string("{TIMEPLOT|SET|"))
	mov	arg01, ptr_L__0085_
	add	objptr, #20
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Str
'   meguno.str(ptr_attrib)
	mov	arg01, local01
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Str
'   meguno.tx("=")
	mov	arg01, #61
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Tx
'   meguno.str(ptr_txt)
	mov	arg01, local02
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Str
'   meguno.tx("}")
	mov	arg01, #125
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Tx
'   meguno.tx(CR)
	mov	arg01, #10
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Tx
	sub	objptr, #20
	mov	sp, fp
	call	#popregs_
_megunolink_ez_writeTplotSet_ret
	call	#LMM_RET

' 
' PUB writeTplotStyle(ptr_channel, color, marker, style, width)
_megunolink_ez_writeTplotStyle
	mov	COUNT_, #5
	call	#pushregs_
	mov	local01, arg01
	mov	local02, arg02
	mov	local03, arg03
	mov	local04, arg04
	mov	local05, arg05
'   meguno.str(string("{TIMEPLOT|STYLE|"))
	mov	arg01, ptr_L__0086_
	add	objptr, #20
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Str
'   meguno.str(ptr_channel)
	mov	arg01, local01
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Str
'   meguno.tx(":")
	mov	arg01, #58
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Tx
'   meguno.tx(color)
	mov	arg01, local02
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Tx
'   meguno.tx(marker)
	mov	arg01, local03
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Tx
'   meguno.tx(style)
	mov	arg01, local04
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Tx
'   meguno.dec(width)
	mov	arg01, local05
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Dec
'   meguno.tx("}")
	mov	arg01, #125
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Tx
'   meguno.tx(CR)
	mov	arg01, #10
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Tx
	sub	objptr, #20
	mov	sp, fp
	call	#popregs_
_megunolink_ez_writeTplotStyle_ret
	call	#LMM_RET

' 
' PUB writeTplotFixed(ptr_channel, val, dec_places)
_megunolink_ez_writeTplotFixed
	mov	COUNT_, #1
	call	#pushregs_
	mov	local01, arg01
'   intToFixed(val, dec_places)
	mov	arg01, arg02
	mov	arg02, arg03
	call	#LMM_CALL
	long	@@@_megunolink_ez_intToFixed
'   meguno.str(string("{TIMEPLOT|DATA|"))
	mov	arg01, ptr_L__0087_
	add	objptr, #20
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Str
'   meguno.str(ptr_channel)
	mov	arg01, local01
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Str
'   meguno.str(string("|T|"))
	mov	arg01, ptr_L__0088_
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Str
'   meguno.str(@temp_string)
	sub	objptr, #17
	mov	arg01, objptr
	add	objptr, #17
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Str
'   meguno.tx("}")
	mov	arg01, #125
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Tx
'   meguno.tx(CR)
	mov	arg01, #10
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Tx
	sub	objptr, #20
	mov	sp, fp
	call	#popregs_
_megunolink_ez_writeTplotFixed_ret
	call	#LMM_RET

' 
' PUB writeTplotFloat(ptr_channel, val, precision)
_megunolink_ez_writeTplotFloat
	mov	COUNT_, #2
	call	#pushregs_
	mov	local01, arg01
	mov	local02, arg02
'   convertFloat.SetPrecision(precision)
' 
' ''Set precision to express floating-point numbers in
' ''
' ''  NumberOfDigits = Number of digits to round to, limited to 1..7 (7=default)
' ''
' ''  examples          results
' ''  -------------------------------
' ''  SetPrecision(1)   "1e+0"
' ''  SetPrecision(4)   "1.000e+0"
' ''  SetPrecision(7)   "1.000000e+0"
' 
'   precision := NumberOfDigits
	add	objptr, #188
	wrlong	arg03, objptr
'   meguno.str(string("{TIMEPLOT|DATA|"))
	mov	arg01, ptr_L__0089_
	sub	objptr, #168
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Str
'   meguno.str(ptr_channel)
	mov	arg01, local01
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Str
'   meguno.str(string("|T|"))
	mov	arg01, ptr_L__0090_
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Str
'   meguno.str(convertFloat.floatToString(val))
	mov	arg01, local02
	add	objptr, #144
	call	#LMM_CALL
	long	@@@_FloatString_FloatToString
	mov	arg01, result1
	sub	objptr, #144
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Str
'   meguno.tx("}")
	mov	arg01, #125
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Tx
'   meguno.tx(CR)
	mov	arg01, #10
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Tx
	sub	objptr, #20
	mov	sp, fp
	call	#popregs_
_megunolink_ez_writeTplotFloat_ret
	call	#LMM_RET

' 
' PUB listen | _char, _time, _ms, _len, _cmdFound, _cmd      'check for incoming serial data from nextion, must be run frequently to respond to events
_megunolink_ez_listen
	mov	COUNT_, #4
	call	#pushregs_
' {{
' }}
'   cmd_avail := false
	mov	arg01, #0
	add	objptr, #2
	wrbyte	arg01, objptr
' 
'   if meguno.available > 2                             'Read if more then 2 bytes come (we always send more than 2 <#> <len> <cmd> <id>
	add	objptr, #18
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Available
	sub	objptr, #20
	cmps	result1, #3 wc
 if_b	add	pc, #4*(LR__0008 - ($+1))
'     _char := meguno.rxTime(100)
	mov	arg01, #100
	add	objptr, #20
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_RxTime
	sub	objptr, #20
	mov	local01, result1
'     if _char == -1                                     'if timeout (-1) return error (-1)
	cmp	local01, imm_4294967295_ wz
'       return
 if_e	add	pc, #4*(LR__0009 - ($+1))
' 
'     _time := cnt
	mov	local02, cnt
'     _ms := 100
	mov	local03, #100
' 
'     repeat while _char <> "#"
LR__0002
	cmp	local01, #35 wz
 if_e	add	pc, #4*(LR__0003 - ($+1))
'       _char := meguno.rxTime(100)
	mov	arg01, #100
	add	objptr, #20
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_RxTime
	sub	objptr, #20
	mov	local01, result1
'       if _char == -1                                     'if timeout (-1) return error (-1)
	cmp	local01, imm_4294967295_ wz
'         return
 if_e	add	pc, #4*(LR__0009 - ($+1))
' 
'       if(cnt - _time) / (clkfreq / 1000) > _ms                                'time out if we don't see a start char
	mov	arg01, cnt
	sub	arg01, local02
	rdlong	muldiva_, #0
	mov	muldivb_, imm_1000_
	call	#divide_
	mov	muldiva_, arg01
	call	#divide_
	cmps	muldivb_, local03 wc,wz
'         return
 if_a	add	pc, #4*(LR__0009 - ($+1))
	sub	pc, #4*(($+1) - LR__0002)
LR__0003
' 
'     if _char == "#"
	cmp	local01, #35 wz
 if_ne	add	pc, #4*(LR__0004 - ($+1))
'       _len := meguno.rxTime(100)
	mov	arg01, #100
	add	objptr, #20
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_RxTime
	sub	objptr, #20
	mov	local04, result1
'        if _char == -1                                     'if timeout (-1) return error (-1)
	cmp	local01, imm_4294967295_ wz
'          return
 if_e	add	pc, #4*(LR__0009 - ($+1))
LR__0004
'     cmd_len := _len
	add	objptr, #1
	wrbyte	local04, objptr
	sub	objptr, #1
' 
'       _cmdFound := true
'       _time := cnt
	mov	local02, cnt
'       _ms := 100
	mov	local03, #100
' 
'       repeat while meguno.available < _len
LR__0005
	add	objptr, #20
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Available
	sub	objptr, #20
	cmps	result1, local04 wc
 if_ae	add	pc, #4*(LR__0006 - ($+1))
'         if(cnt - _time) / (clkfreq / 1000) > _ms                                'time out if we don't see a full packet soon timeout
	mov	local01, cnt
	sub	local01, local02
	rdlong	muldiva_, #0
	mov	muldivb_, imm_1000_
	call	#divide_
	mov	muldiva_, local01
	call	#divide_
	cmps	muldivb_, local03 wc,wz
'           return
 if_a	add	pc, #4*(LR__0009 - ($+1))
	sub	pc, #4*(($+1) - LR__0005)
LR__0006
' 
'     _cmd := meguno.rx
	add	objptr, #20
' {{
' }}
' 
'   repeat while (rxByte := RxCheck) < 0                  'return the byte, wait while the buffer is empty
LR__0007
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_RxCheck
	cmps	result1, #0 wc
 if_b	sub	pc, #4*(($+1) - LR__0007)
'                       'commands can be variable length, we pull just the first and leave the rest for main code to deal with
'     cmd_avail := true
	neg	local04, #1
	sub	objptr, #18
	wrbyte	local04, objptr
	sub	objptr, #2
'     cmd := _cmd
	wrbyte	result1, objptr
LR__0008
'   return
LR__0009
	mov	sp, fp
	call	#popregs_
_megunolink_ez_listen_ret
	call	#LMM_RET

' 
' PRI intToFixed(val, places) | pos, max_neg, div, ln, idx
_megunolink_ez_intToFixed
	mov	COUNT_, #6
	call	#pushregs_
	mov	local01, arg01
	mov	local02, arg02
	mov	local03, #0
' 
'   clearStr(@temp_string)
	add	objptr, #3
	mov	arg01, objptr
	sub	objptr, #3
	call	#LMM_CALL
	long	@@@_megunolink_ez_clearStr
'   pos := 1
	mov	arg02, #1
'   idx := 0
	mov	arg01, #0
'   ln := 10
' 
'   'this code adapted from FullDuplexSerial
'   max_neg := val == NEGX                                    'Check for max negative
	mov	local04, #0
	cmp	local01, imm_2147483648_ wz
 if_e	neg	local04, #1
'   if val < 0
	cmps	local01, #0 wc
 if_ae	add	pc, #4*(LR__0010 - ($+1))
'     val := ||(val+max_neg)                                'If negative, make positive; adjust for max negative
	add	local01, local04
	abs	local01, local01
'     temp_string[idx] :=("-")                                             'and output sign
	add	objptr, #3
	mov	result1, #45
	wrbyte	result1, objptr
'     idx++
	mov	arg01, #1
	sub	objptr, #3
LR__0010
' 
' 
'   div := 1_000_000_000                                    'Initialize divisor
	mov	local05, imm_1000000000_
' 
'   repeat 10                                            'Loop for 10 digits
	mov	local06, #10
	call	#LMM_FCACHE_LOAD
	long	(@@@LR__0017-@@@LR__0011)
LR__0011
'     if pos == (ln - (places))             'if we are one before the decimal location
	mov	muldivb_, #10
	sub	muldivb_, local02
	cmp	arg02, muldivb_ wz
'       result~~                                         'flag non-zero found to start adding zeros, including leading zero
 if_e	neg	local03, #1
' 
'     if val => div
	cmps	local01, local05 wc
 if_b	jmp	#LMM_FCACHE_START + (LR__0012 - LR__0011)
'       temp_string[idx] := (val / div + "0" + max_neg * (div == 1)) 'If non-zero digit, output digit; adjust for max negative
	mov	muldiva_, local01
	mov	muldivb_, local05
	call	#divide_
	mov	local03, muldivb_
	add	local03, #48
	mov	muldivb_, #0
	cmp	local05, #1 wz
 if_e	neg	muldivb_, #1
	mov	muldiva_, local04
	call	#unsmultiply_
	add	local03, muldiva_
	mov	muldivb_, arg01
	add	objptr, #3
	add	muldivb_, objptr
	wrbyte	local03, muldivb_
'       idx++
	add	arg01, #1
'       val //= div                                       'and digit from value
	mov	muldiva_, local01
	mov	muldivb_, local05
	sub	objptr, #3
	call	#divide_
	mov	local01, muldiva_
'       result~~                                          'flag non-zero found
	neg	local03, #1
	jmp	#LMM_FCACHE_START + (LR__0015 - LR__0011)
LR__0012
'     elseif result or div == 1
	cmp	local03, #0 wz
 if_ne	jmp	#LMM_FCACHE_START + (LR__0013 - LR__0011)
	cmp	local05, #1 wz
 if_ne	jmp	#LMM_FCACHE_START + (LR__0014 - LR__0011)
LR__0013
'       temp_string[idx] := ("0")                           'If zero digit (or only digit) output it
	mov	result1, arg01
	add	objptr, #3
	add	result1, objptr
	mov	muldivb_, #48
	wrbyte	muldivb_, result1
'       idx++
	add	arg01, #1
	sub	objptr, #3
LR__0014
LR__0015
'     div /= 10                                             'Update divisor
	mov	muldiva_, local05
	mov	muldivb_, #10
	call	#divide_
	mov	local05, muldivb_
' 
'     if pos == (ln - (places))                            'at the decimal location
	mov	result1, #10
	sub	result1, local02
	cmp	arg02, result1 wz
 if_ne	jmp	#LMM_FCACHE_START + (LR__0016 - LR__0011)
'       temp_string[idx] := (".")
	mov	result1, arg01
	add	objptr, #3
	add	result1, objptr
	mov	muldivb_, #46
	wrbyte	muldivb_, result1
'       idx++
	add	arg01, #1
	sub	objptr, #3
LR__0016
'     pos++
	add	arg02, #1
	djnz	local06, #LMM_FCACHE_START + (LR__0011 - LR__0011)
LR__0017
	mov	result1, local03
	mov	sp, fp
	call	#popregs_
_megunolink_ez_intToFixed_ret
	call	#LMM_RET

' 
' PRI clearStr(ptr_string) | x, y
_megunolink_ez_clearStr
	mov	COUNT_, #3
	call	#pushregs_
	mov	local01, arg01
'   y := 0
	mov	local02, #0
'   x := strsize(ptr_string)
	mov	arg01, local01
	call	#LMM_CALL
	long	@@@__system____builtin_strlen
'   repeat x
	cmp	result1, #0 wz
 if_e	add	pc, #4*(LR__0020 - ($+1))
	call	#LMM_FCACHE_LOAD
	long	(@@@LR__0019-@@@LR__0018)
LR__0018
'     byte[ptr_string][y++] := 0
	mov	arg01, local02
	add	arg01, local01
	mov	local03, #0
	wrbyte	local03, arg01
	add	local02, #1
	djnz	result1, #LMM_FCACHE_START + (LR__0018 - LR__0018)
LR__0019
LR__0020
	mov	sp, fp
	call	#popregs_
_megunolink_ez_clearStr_ret
	call	#LMM_RET

' 
' 
' PUB Start(rxPin, txPin, mode, baudrate) : okay
_FullDuplexSerialAvail_Start
	mov	COUNT_, #4
	call	#pushregs_
	mov	local01, arg01
	mov	local02, arg02
	mov	local03, arg03
	mov	local04, arg04
' {{
' }}
' 
'   Stop                                                  'make sure the driver isnt already running
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Stop
'   longfill(@rx_head, 0, 4)                              'zero out the buffer pointers
	add	objptr, #4
	mov	arg01, objptr
	sub	objptr, #4
	mov	arg02, #0
	mov	arg03, #4
	call	#LMM_FCACHE_LOAD
	long	(@@@LR__0022-@@@LR__0021)
LR__0021
	wrlong	arg02, arg01
	add	arg01, #4
	djnz	arg03, #LMM_FCACHE_START + (LR__0021 - LR__0021)
LR__0022
'   longmove(@rx_pin, @rxpin, 3)                          'copy the start parameters to this objects pin variables
	add	objptr, #20
	wrlong	local01, objptr
	add	objptr, #4
	wrlong	local02, objptr
	add	objptr, #4
	wrlong	local03, objptr
	sub	objptr, #28
'   bit_ticks := clkfreq / baudrate                       'number of clock ticks per bit for the desired baudrate
	rdlong	muldiva_, #0
	mov	muldivb_, local04
	call	#divide_
	add	objptr, #32
	wrlong	muldivb_, objptr
'   buffer_ptr := @rx_buffer                              'save the address of the receive buffer
	add	objptr, #8
	mov	local04, objptr
	sub	objptr, #4
	wrlong	local04, objptr
'   okay := cog := cognew(@entry, @rx_head) + 1           'start the new cog now, assembly cog at "entry" label.
	mov	arg02, ptr__FullDuplexSerialAvail_dat__
	sub	objptr, #32
	mov	arg03, objptr
	sub	objptr, #4
	mov	arg01, #30
	call	#LMM_CALL
	long	@@@__system___coginit
	add	result1, #1
	wrlong	result1, objptr
	mov	sp, fp
	call	#popregs_
_FullDuplexSerialAvail_Start_ret
	call	#LMM_RET

' 
' 
' PUB Stop
_FullDuplexSerialAvail_Stop
' {{
' }}
' 
'   if cog
	rdlong	arg01, objptr wz
 if_e	add	pc, #4*(LR__0023 - ($+1))
'     cogstop(cog~ - 1)                                   'if the driver is already running, stop the cog
	rdlong	arg01, objptr
	mov	arg03, #0
	wrlong	arg03, objptr
	sub	arg01, #1
	cogstop	arg01
LR__0023
'   longfill(@rx_head, 0, 9)                              'zero out configuration variables
	add	objptr, #4
	mov	arg01, objptr
	sub	objptr, #4
	mov	arg02, #0
	mov	arg03, #9
	call	#LMM_FCACHE_LOAD
	long	(@@@LR__0025-@@@LR__0024)
LR__0024
	wrlong	arg02, arg01
	add	arg01, #4
	djnz	arg03, #LMM_FCACHE_START + (LR__0024 - LR__0024)
LR__0025
_FullDuplexSerialAvail_Stop_ret
	call	#LMM_RET

' 
' PUB Available : byteCount
_FullDuplexSerialAvail_Available
' {{
' }}
'   byteCount := rx_head - rx_tail
	add	objptr, #4
	rdlong	result1, objptr
	add	objptr, #4
	rdlong	_var01, objptr
	sub	objptr, #8
	sub	result1, _var01
' 
'   if byteCount < 0
	cmps	result1, #0 wc
'     byteCount += BUFF_SIZE
 if_b	add	result1, #16
_FullDuplexSerialAvail_Available_ret
	call	#LMM_RET

' 
' 
' PUB RxCheck : rxByte
_FullDuplexSerialAvail_RxCheck
' {{
' }}
' 
' 
'   rxByte--                                              'make rxbyte = -1
	neg	_var01, #1
'   if rx_tail <> rx_head                                 'if a byte is in the buffer, then
	add	objptr, #8
	rdlong	result1, objptr
	sub	objptr, #4
	rdlong	_var02, objptr
	sub	objptr, #4
	cmp	result1, _var02 wz
 if_e	add	pc, #4*(LR__0026 - ($+1))
'     rxByte := rx_buffer[rx_tail]                        '  grab it and store in rxByte
	add	objptr, #8
	rdlong	_var02, objptr
	mov	_var01, _var02
	add	objptr, #32
	add	_var01, objptr
	rdbyte	_var01, _var01
'     rx_tail := (rx_tail + 1) & $F                       '  advance the buffer pointer
	add	_var02, #1
	and	_var02, #15
	sub	objptr, #32
	wrlong	_var02, objptr
	sub	objptr, #8
LR__0026
	mov	result1, _var01
_FullDuplexSerialAvail_RxCheck_ret
	call	#LMM_RET

' 
' 
' PUB RxTime(ms) : rxByte | t
_FullDuplexSerialAvail_RxTime
	mov	COUNT_, #3
	call	#pushregs_
' {{
' }}
' 
'   t := cnt                                              'take note of the current time
	mov	local01, cnt
'   repeat until (rxByte := RxCheck) => 0 or (cnt - t) / (clkfreq / 1000) > ms
LR__0027
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_RxCheck
	mov	local02, result1
	cmps	local02, #0 wc
 if_ae	add	pc, #4*(LR__0028 - ($+1))
	mov	local03, cnt
	sub	local03, local01
	rdlong	muldiva_, #0
	mov	muldivb_, imm_1000_
	call	#divide_
	mov	muldiva_, local03
	call	#divide_
	cmps	muldivb_, arg01 wc,wz
 if_be	sub	pc, #4*(($+1) - LR__0027)
LR__0028
	mov	result1, local02
	mov	sp, fp
	call	#popregs_
_FullDuplexSerialAvail_RxTime_ret
	call	#LMM_RET

' 
' 
' PUB Tx(txByte)
_FullDuplexSerialAvail_Tx
	mov	COUNT_, #1
	call	#pushregs_
	call	#LMM_FCACHE_LOAD
	long	(@@@LR__0030-@@@LR__0029)
' {{
' }}
' 
'   repeat until (tx_tail <> (tx_head + 1) & $F)          'wait until the buffer has room
LR__0029
	add	objptr, #12
	rdlong	result1, objptr
	add	result1, #1
	and	result1, #15
	add	objptr, #4
	rdlong	local01, objptr
	sub	objptr, #16
	cmp	local01, result1 wz
 if_e	jmp	#LMM_FCACHE_START + (LR__0029 - LR__0029)
LR__0030
'   tx_buffer[tx_head] := txByte                          'place the byte into the buffer
	add	objptr, #12
	rdlong	local01, objptr
	add	objptr, #44
	add	local01, objptr
	wrbyte	arg01, local01
'   tx_head := (tx_head + 1) & $F                         'advance the buffer's pointer
	sub	objptr, #44
	rdlong	local01, objptr
	add	local01, #1
	and	local01, #15
	wrlong	local01, objptr
' 
'   if rxtx_mode & %1000                                  'if ignoring rx echo
	add	objptr, #16
	rdlong	local01, objptr
	sub	objptr, #28
	test	local01, #8 wz
'     Rx                                                  '   receive the echoed byte and discard
 if_e	add	pc, #4*(LR__0032 - ($+1))
' {{
' }}
' 
'   repeat while (rxByte := RxCheck) < 0                  'return the byte, wait while the buffer is empty
LR__0031
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_RxCheck
	cmps	result1, #0 wc
 if_b	sub	pc, #4*(($+1) - LR__0031)
LR__0032
	mov	sp, fp
	call	#popregs_
_FullDuplexSerialAvail_Tx_ret
	call	#LMM_RET

' 
' 
' PUB Str(stringPtr)
_FullDuplexSerialAvail_Str
	mov	COUNT_, #2
	call	#pushregs_
' {{
' }}
' 
'   repeat strsize(stringPtr)
	mov	local01, arg01
	call	#LMM_CALL
	long	@@@__system____builtin_strlen
	mov	local02, result1 wz
 if_e	add	pc, #4*(LR__0034 - ($+1))
LR__0033
'     Tx(byte[stringPtr++])                                                       'Transmit each byte in the string
	rdbyte	arg01, local01
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Tx
	add	local01, #1
	djnz	local02, #LMM_JUMP
	long	@@@LR__0033
LR__0034
	mov	sp, fp
	call	#popregs_
_FullDuplexSerialAvail_Str_ret
	call	#LMM_RET

' 
' 
' PUB Dec(value) | i, x
_FullDuplexSerialAvail_Dec
	mov	COUNT_, #5
	call	#pushregs_
	mov	local01, arg01
	mov	local02, #0
' {{
' }}
' 
'   x := value == NEGX                                    'Check for max negative
	mov	local03, #0
	cmp	local01, imm_2147483648_ wz
 if_e	neg	local03, #1
'   if value < 0
	cmps	local01, #0 wc
 if_ae	add	pc, #4*(LR__0035 - ($+1))
'     value := ||(value+x)                                'If negative, make positive; adjust for max negative
	add	local01, local03
	abs	local01, local01
'     Tx("-")                                             'and output sign
	mov	arg01, #45
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Tx
LR__0035
' 
'   i := 1_000_000_000                                    'Initialize divisor
	mov	local04, imm_1000000000_
' 
'   repeat 10                                             'Loop for 10 digits
	mov	local05, #10
LR__0036
'     if value => i
	cmps	local01, local04 wc
 if_b	add	pc, #4*(LR__0037 - ($+1))
'       Tx(value / i + "0" + x*(i == 1))                  'If non-zero digit, output digit; adjust for max negative
	mov	muldiva_, local01
	mov	muldivb_, local04
	call	#divide_
	mov	arg01, muldivb_
	add	arg01, #48
	mov	muldivb_, #0
	cmp	local04, #1 wz
 if_e	neg	muldivb_, #1
	mov	muldiva_, local03
	call	#unsmultiply_
	add	arg01, muldiva_
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Tx
'       value //= i                                       'and digit from value
	mov	muldiva_, local01
	mov	muldivb_, local04
	call	#divide_
	mov	local01, muldiva_
'       result~~                                          'flag non-zero found
	neg	local02, #1
	add	pc, #4*(LR__0040 - ($+1))
LR__0037
'     elseif result or i == 1
	cmp	local02, #0 wz
 if_ne	add	pc, #4*(LR__0038 - ($+1))
	cmp	local04, #1 wz
 if_ne	add	pc, #4*(LR__0039 - ($+1))
LR__0038
'       Tx("0")                                           'If zero digit (or only digit) output it
	mov	arg01, #48
	call	#LMM_CALL
	long	@@@_FullDuplexSerialAvail_Tx
LR__0039
LR__0040
'     i /= 10                                             'Update divisor
	mov	muldiva_, local04
	mov	muldivb_, #10
	call	#divide_
	mov	local04, muldivb_
	sub	local05, #1 wz
 if_ne	sub	pc, #4*(($+1) - LR__0036)
	mov	result1, local02
	mov	sp, fp
	call	#popregs_
_FullDuplexSerialAvail_Dec_ret
	call	#LMM_RET

' 
'   
' PUB Config(SymAddr)
_Numbers_Config
' {{Configure for custom symbols.
'               (default is '%').}}  
'   bytemove(@Symbols, SymAddr, 7)        
	add	objptr, #16
	mov	arg02, arg01
	mov	arg01, objptr
	mov	arg03, #7
	sub	objptr, #16
	call	#LMM_CALL
	long	@@@__system____builtin_memmove
_Numbers_Config_ret
	call	#LMM_RET

' 
' 
' PUB FloatToString(Single) : StringPtr
_FloatString_FloatToString
	mov	COUNT_, #9
	call	#pushregs_
' 
' ''Convert floating-point number to string
' ''
' ''  entry:
' ''      Single = floating-point number
' ''
' ''  exit:
' ''      StringPtr = pointer to resultant z-string
' ''
' ''  Magnitudes below 1e+12 and within 1e-12 will be expressed directly;
' ''  otherwise, scientific notation will be used.
' ''
' ''  examples                 results
' ''  -----------------------------------------
' ''  FloatToString(0.0)       "0"
' ''  FloatToString(1.0)       "1"
' ''  FloatToString(-1.0)      "-1"
' ''  FloatToString(^^2.0)     "1.414214"
' ''  FloatToString(2.34e-3)   "0.00234"
' ''  FloatToString(-1.5e-5)   "-0.000015"
' ''  FloatToString(2.7e+6)    "2700000"
' ''  FloatToString(1e11)      "100000000000"
' ''  FloatToString(1e12)      "1.000000e+12"
' ''  FloatToString(1e-12)     "0.000000000001"
' ''  FloatToString(1e-13)     "1.000000e-13"
' 
'   'perform initial setup
'   StringPtr := Setup(Single)
	mov	local01, arg01
	call	#LMM_CALL
	long	@@@_FloatString_Setup
	mov	local02, result1
' 
'   'eliminate trailing zeros
'   if integer
	add	objptr, #12
	rdlong	result1, objptr wz
	sub	objptr, #12
 if_e	add	pc, #4*(LR__0042 - ($+1))
'     repeat until integer // 10
LR__0041
	add	objptr, #12
	rdlong	muldiva_, objptr
	sub	objptr, #12
	mov	muldivb_, #10
	call	#divide_
	cmp	muldiva_, #0 wz
 if_ne	add	pc, #4*(LR__0043 - ($+1))
'       integer /= 10
	add	objptr, #12
	rdlong	muldiva_, objptr
	sub	objptr, #12
	mov	muldivb_, #10
	call	#divide_
	add	objptr, #12
	wrlong	muldivb_, objptr
'       tens /= 10
	add	objptr, #4
	rdlong	muldiva_, objptr
	sub	objptr, #16
	mov	muldivb_, #10
	call	#divide_
	add	objptr, #16
	wrlong	muldivb_, objptr
'       digits--
	sub	objptr, #12
	rdlong	muldivb_, objptr
	sub	muldivb_, #1
	wrlong	muldivb_, objptr
	sub	objptr, #4
	sub	pc, #4*(($+1) - LR__0041)
'   else
LR__0042
'     digits~
	mov	result1, #0
	add	objptr, #4
	wrlong	result1, objptr
	sub	objptr, #4
LR__0043
' 
'   'express number according to exponent
'   case exponent
	add	objptr, #8
	rdlong	local03, objptr
	sub	objptr, #8
	cmps	local03, #0 wc
 if_b	add	pc, #4*(LR__0044 - ($+1))
	cmps	local03, #12 wc
 if_b	add	pc, #4*(LR__0045 - ($+1))
LR__0044
	add	objptr, #4
	rdlong	local04, objptr
	sub	objptr, #4
	mov	local05, local04
	sub	local05, #13
	neg	local06, #1
	neg	local07, #1
	mov	local08, local05
	mov	local09, local08
	maxs	local06, local09
	mins	local08, imm_4294967295_
	cmps	local06, local03 wc,wz
 if_be	cmps	local03, local08 wc,wz
 if_be	add	pc, #4*(LR__0046 - ($+1))
	add	pc, #4*(LR__0047 - ($+1))
LR__0045
'     'in range left of decimal
'     11..0:
'       AddDigits(exponent + 1)
	add	objptr, #8
	rdlong	arg01, objptr
	sub	objptr, #8
	add	arg01, #1
	call	#LMM_CALL
	long	@@@_FloatString_AddDigits
	add	pc, #4*(LR__0048 - ($+1))
LR__0046
'     'in range right of decimal
'     -1..digits - 13:
'       zeros := -exponent
	add	objptr, #8
	rdlong	local05, objptr
	neg	local05, local05
	add	objptr, #12
	wrlong	local05, objptr
	sub	objptr, #20
'       AddDigits(1)
	mov	arg01, #1
	call	#LMM_CALL
	long	@@@_FloatString_AddDigits
	add	pc, #4*(LR__0048 - ($+1))
LR__0047
'     'out of range, do scientific notation
'     other:
'       DoScientific
	call	#LMM_CALL
	long	@@@_FloatString_DoScientific
LR__0048
' 
'   'terminate z-string
'   byte[p]~
	rdlong	local05, objptr
	mov	local04, #0
	wrbyte	local04, local05
	mov	result1, local02
	mov	sp, fp
	call	#popregs_
_FloatString_FloatToString_ret
	call	#LMM_RET

'   
' 
' PRI Setup(single) : stringptr
_FloatString_Setup
	mov	COUNT_, #7
	call	#pushregs_
	mov	local01, arg01
	mov	local02, #0
' 
'  'limit digits to 1..7
'   if precision
	add	objptr, #24
	rdlong	result1, objptr wz
	sub	objptr, #24
 if_e	add	pc, #4*(LR__0049 - ($+1))
'     digits := precision #> 1 <# 7
	add	objptr, #24
	rdlong	result1, objptr
	mins	result1, #1
	maxs	result1, #7
	sub	objptr, #20
	wrlong	result1, objptr
	sub	objptr, #4
'   else
	add	pc, #4*(LR__0050 - ($+1))
LR__0049
'     digits := 7
	mov	result1, #7
	add	objptr, #4
	wrlong	result1, objptr
	sub	objptr, #4
LR__0050
' 
'   'initialize string pointer
'   p := @float_string
	add	objptr, #44
	mov	result1, objptr
	sub	objptr, #44
	wrlong	result1, objptr
' 
'   'add "-" if negative
'   if single & $80000000
	test	local01, imm_2147483648_ wz
 if_e	add	pc, #4*(LR__0051 - ($+1))
'     byte[p++] := "-"
	rdlong	result1, objptr
	mov	local03, result1
	add	local03, #1
	wrlong	local03, objptr
	mov	local04, #45
	wrbyte	local04, result1
	add	pc, #4*(LR__0053 - ($+1))
LR__0051
'   'otherwise, add any positive lead character
'   elseif positive_chr
	add	objptr, #28
	rdlong	result1, objptr wz
	sub	objptr, #28
 if_e	add	pc, #4*(LR__0052 - ($+1))
'     byte[p++] := positive_chr
	rdlong	result1, objptr
	mov	local03, result1
	add	local03, #1
	wrlong	local03, objptr
	add	objptr, #28
	rdlong	local04, objptr
	sub	objptr, #28
	wrbyte	local04, result1
LR__0052
LR__0053
' 
'   'clear sign and check for 0
'   if single &= $7FFFFFFF
	and	local01, imm_2147483647_
	mov	local05, local01 wz
	mov	local01, local05
 if_e	add	pc, #4*(LR__0058 - ($+1))
' 
'     'not 0, estimate exponent
'     exponent := ((single << 1 >> 24 - 127) * 77) ~> 8
	mov	muldiva_, local01
	shl	muldiva_, #1
	shr	muldiva_, #24
	sub	muldiva_, #127
	mov	muldivb_, #77
	call	#unsmultiply_
	mov	local06, muldiva_
	sar	local06, #8
	add	objptr, #8
	wrlong	local06, objptr
'     
'     'if very small, bias up
'     if exponent < -32
	sub	objptr, #8
	cmps	local06, imm_4294967264_ wc
 if_ae	add	pc, #4*(LR__0054 - ($+1))
'       single := F.FMul(single, 1e13)
	mov	arg01, local01
	mov	arg02, imm_1427211495_
	call	#LMM_CALL
	long	@@@_FloatMath_FMul
	mov	local01, result1
'       exponent += result := 13
	mov	local02, #13
	add	objptr, #8
	rdlong	local06, objptr
	add	local06, #13
	wrlong	local06, objptr
	sub	objptr, #8
LR__0054
'       
'     'determine exact exponent and integer
'     repeat
LR__0055
'       integer := F.FRound(F.FMul(single, tenf[exponent - digits + 1]))
	add	objptr, #8
	rdlong	local06, objptr
	sub	objptr, #4
	rdlong	local05, objptr
	sub	objptr, #4
	sub	local06, local05
	add	local06, #1
	shl	local06, #2
	add	ptr__FloatString_dat__, #152
	add	local06, ptr__FloatString_dat__
	rdlong	arg02, local06
	mov	arg01, local01
	sub	ptr__FloatString_dat__, #152
	call	#LMM_CALL
	long	@@@_FloatMath_FMul
	mov	arg01, result1
' 
' ''Convert float to rounded integer
' 
'   return FInteger(single, 1)    'use 1/2 to round
	mov	arg02, #1
	call	#LMM_CALL
	long	@@@_FloatMath_FInteger
	add	objptr, #12
	wrlong	result1, objptr
'       if integer < teni[digits - 1]
	sub	objptr, #8
	rdlong	local04, objptr
	sub	local04, #1
	shl	local04, #2
	add	ptr__FloatString_dat__, #308
	add	local04, ptr__FloatString_dat__
	mov	local07, result1
	sub	objptr, #4
	rdlong	local06, local04
	cmps	local07, local06 wc
	sub	ptr__FloatString_dat__, #308
 if_ae	add	pc, #4*(LR__0056 - ($+1))
'         exponent--
	add	objptr, #8
	rdlong	local04, objptr
	sub	local04, #1
	wrlong	local04, objptr
	sub	objptr, #8
	sub	pc, #4*(($+1) - LR__0055)
LR__0056
'       elseif integer => teni[digits]
	add	objptr, #4
	rdlong	local06, objptr
	shl	local06, #2
	add	ptr__FloatString_dat__, #308
	add	local06, ptr__FloatString_dat__
	add	objptr, #8
	rdlong	local04, objptr
	sub	objptr, #12
	rdlong	local07, local06
	cmps	local04, local07 wc
	sub	ptr__FloatString_dat__, #308
 if_b	add	pc, #4*(LR__0057 - ($+1))
'         exponent++
	add	objptr, #8
	rdlong	local04, objptr
	add	local04, #1
	wrlong	local04, objptr
	sub	objptr, #8
'       else
	sub	pc, #4*(($+1) - LR__0055)
LR__0057
'         exponent -= result
	add	objptr, #8
	rdlong	local06, objptr
	sub	local06, local02
	wrlong	local06, objptr
	sub	objptr, #8
'         quit
	add	pc, #4*(LR__0059 - ($+1))
' 
'   'if 0, reset exponent and integer
'   else
LR__0058
'     exponent~
	mov	local06, #0
	add	objptr, #8
	wrlong	local06, objptr
'     integer~
	add	objptr, #4
	wrlong	local06, objptr
	sub	objptr, #12
LR__0059
' 
'   'set initial tens and clear zeros
'   tens := teni[digits - 1]
	add	objptr, #4
	rdlong	local04, objptr
	sub	local04, #1
	shl	local04, #2
	add	ptr__FloatString_dat__, #308
	add	local04, ptr__FloatString_dat__
	rdlong	local07, local04
	add	objptr, #12
	wrlong	local07, objptr
'   zeros~
	mov	local06, #0
	add	objptr, #4
	wrlong	local06, objptr
' 
'   'return pointer to string
'   stringptr := @float_string
	add	objptr, #24
	mov	result1, objptr
	sub	objptr, #44
	sub	ptr__FloatString_dat__, #308
	mov	sp, fp
	call	#popregs_
_FloatString_Setup_ret
	call	#LMM_RET

' 
' 
' PRI DoScientific
_FloatString_DoScientific
' 
'   'add digits with possible decimal
'   AddDigits(1)
	mov	arg01, #1
	call	#LMM_CALL
	long	@@@_FloatString_AddDigits
'   'add exponent indicator
'   byte[p++] := "e"
	rdlong	muldivb_, objptr
	mov	muldiva_, muldivb_
	add	muldiva_, #1
	wrlong	muldiva_, objptr
	mov	muldiva_, #101
	wrbyte	muldiva_, muldivb_
'   'add exponent sign
'   if exponent => 0
	add	objptr, #8
	rdlong	muldivb_, objptr
	sub	objptr, #8
	cmps	muldivb_, #0 wc
 if_b	add	pc, #4*(LR__0060 - ($+1))
'     byte[p++] := "+"
	rdlong	muldivb_, objptr
	mov	muldiva_, muldivb_
	add	muldiva_, #1
	wrlong	muldiva_, objptr
	mov	muldiva_, #43
	wrbyte	muldiva_, muldivb_
'   else
	add	pc, #4*(LR__0061 - ($+1))
LR__0060
'     byte[p++] := "-"
	rdlong	muldivb_, objptr
	mov	muldiva_, muldivb_
	add	muldiva_, #1
	wrlong	muldiva_, objptr
	mov	muldiva_, #45
	wrbyte	muldiva_, muldivb_
'     ||exponent
	add	objptr, #8
	rdlong	muldivb_, objptr
	abs	muldivb_, muldivb_
	wrlong	muldivb_, objptr
	sub	objptr, #8
LR__0061
'   'add exponent digits
'   if exponent => 10
	add	objptr, #8
	rdlong	muldivb_, objptr
	sub	objptr, #8
	cmps	muldivb_, #10 wc
 if_b	add	pc, #4*(LR__0062 - ($+1))
'     byte[p++] := exponent / 10 + "0"
	add	objptr, #8
	rdlong	muldiva_, objptr
	sub	objptr, #8
	mov	muldivb_, #10
	call	#divide_
	add	muldivb_, #48
	rdlong	muldiva_, objptr
	mov	arg01, muldiva_
	add	arg01, #1
	wrlong	arg01, objptr
	wrbyte	muldivb_, muldiva_
'     exponent //= 10
	add	objptr, #8
	rdlong	muldiva_, objptr
	sub	objptr, #8
	mov	muldivb_, #10
	call	#divide_
	add	objptr, #8
	wrlong	muldiva_, objptr
	sub	objptr, #8
LR__0062
'   byte[p++] := exponent + "0"
	add	objptr, #8
	rdlong	muldivb_, objptr
	sub	objptr, #8
	add	muldivb_, #48
	rdlong	muldiva_, objptr
	mov	arg01, muldiva_
	add	arg01, #1
	wrlong	arg01, objptr
	wrbyte	muldivb_, muldiva_
_FloatString_DoScientific_ret
	call	#LMM_RET

' 
' 
' PRI AddDigits(leading) | i
_FloatString_AddDigits
	mov	COUNT_, #6
	call	#pushregs_
	mov	local01, arg01
' 
'   'add leading digits
'   repeat i := leading
	mov	local02, local01
	mov	local03, local01 wz
 if_e	add	pc, #4*(LR__0066 - ($+1))
LR__0063
'     AddDigit
	call	#LMM_CALL
	long	@@@_FloatString_AddDigit
'     'add any thousands separator between thousands
'     if thousands_chr
	add	objptr, #36
	rdlong	local04, objptr wz
	sub	objptr, #36
 if_e	add	pc, #4*(LR__0065 - ($+1))
'       i--
	sub	local02, #1 wz
'       if i and not i // 3
 if_e	add	pc, #4*(LR__0064 - ($+1))
	mov	muldiva_, local02
	mov	muldivb_, #3
	call	#divide_
	cmp	muldiva_, #0 wz
 if_ne	add	pc, #4*(LR__0064 - ($+1))
'         byte[p++] := thousands_chr
	rdlong	local04, objptr
	mov	local05, local04
	add	local05, #1
	wrlong	local05, objptr
	add	objptr, #36
	rdlong	local06, objptr
	sub	objptr, #36
	wrbyte	local06, local04
LR__0064
LR__0065
	djnz	local03, #LMM_JUMP
	long	@@@LR__0063
LR__0066
'   'if trailing digits, add decimal character
'   if digits
	add	objptr, #4
	rdlong	local04, objptr wz
	sub	objptr, #4
 if_e	add	pc, #4*(LR__0071 - ($+1))
'     AddDecimal
	call	#LMM_CALL
	long	@@@_FloatString_AddDecimal
'     'then add trailing digits
'     repeat while digits
LR__0067
	add	objptr, #4
	rdlong	local04, objptr wz
	sub	objptr, #4
 if_e	add	pc, #4*(LR__0070 - ($+1))
'       'add any thousandths separator between thousandths
'       if thousandths_chr
	add	objptr, #40
	rdlong	local04, objptr wz
	sub	objptr, #40
 if_e	add	pc, #4*(LR__0069 - ($+1))
'         if i and not i // 3
	cmp	local02, #0 wz
 if_e	add	pc, #4*(LR__0068 - ($+1))
	mov	muldiva_, local02
	mov	muldivb_, #3
	call	#divide_
	cmp	muldiva_, #0 wz
 if_ne	add	pc, #4*(LR__0068 - ($+1))
'           byte[p++] := thousandths_chr
	rdlong	local04, objptr
	mov	local05, local04
	add	local05, #1
	wrlong	local05, objptr
	add	objptr, #40
	rdlong	local06, objptr
	sub	objptr, #40
	wrbyte	local06, local04
LR__0068
LR__0069
'       i++
	add	local02, #1
'       AddDigit
	call	#LMM_CALL
	long	@@@_FloatString_AddDigit
	sub	pc, #4*(($+1) - LR__0067)
LR__0070
LR__0071
	mov	sp, fp
	call	#popregs_
_FloatString_AddDigits_ret
	call	#LMM_RET

' 
' 
' PRI AddDigit
_FloatString_AddDigit
' 
'   'if leading zeros, add "0"
'   if zeros
	add	objptr, #20
	rdlong	muldivb_, objptr wz
	sub	objptr, #20
 if_e	add	pc, #4*(LR__0072 - ($+1))
'     byte[p++] := "0"
	rdlong	muldivb_, objptr
	mov	muldiva_, muldivb_
	add	muldiva_, #1
	wrlong	muldiva_, objptr
	mov	muldiva_, #48
	wrbyte	muldiva_, muldivb_
'     zeros--
	add	objptr, #20
	rdlong	muldivb_, objptr
	sub	muldivb_, #1
	wrlong	muldivb_, objptr
	sub	objptr, #20
	add	pc, #4*(LR__0075 - ($+1))
LR__0072
'   'if more digits, add current digit and prepare next
'   elseif digits
	add	objptr, #4
	rdlong	muldivb_, objptr wz
	sub	objptr, #4
 if_e	add	pc, #4*(LR__0073 - ($+1))
'     byte[p++] := integer / tens + "0"
	add	objptr, #12
	rdlong	muldiva_, objptr
	add	objptr, #4
	rdlong	muldivb_, objptr
	sub	objptr, #16
	call	#divide_
	add	muldivb_, #48
	rdlong	muldiva_, objptr
	mov	_var01, muldiva_
	add	_var01, #1
	wrlong	_var01, objptr
	wrbyte	muldivb_, muldiva_
'     integer //= tens
	add	objptr, #12
	rdlong	muldiva_, objptr
	add	objptr, #4
	rdlong	muldivb_, objptr
	sub	objptr, #16
	call	#divide_
	add	objptr, #12
	wrlong	muldiva_, objptr
'     tens /= 10
	add	objptr, #4
	rdlong	muldiva_, objptr
	sub	objptr, #16
	mov	muldivb_, #10
	call	#divide_
	add	objptr, #16
	wrlong	muldivb_, objptr
'     digits--
	sub	objptr, #12
	rdlong	_var01, objptr
	sub	_var01, #1
	wrlong	_var01, objptr
	sub	objptr, #4
'   'if no more digits, add "0"
'   else
	add	pc, #4*(LR__0074 - ($+1))
LR__0073
'     byte[p++] := "0"
	rdlong	_var01, objptr
	mov	muldivb_, _var01
	add	muldivb_, #1
	wrlong	muldivb_, objptr
	mov	muldivb_, #48
	wrbyte	muldivb_, _var01
LR__0074
LR__0075
_FloatString_AddDigit_ret
	call	#LMM_RET

' 
' 
' PRI AddDecimal
_FloatString_AddDecimal
' 
'   if decimal_chr
	add	objptr, #32
	rdlong	_var01, objptr wz
	sub	objptr, #32
 if_e	add	pc, #4*(LR__0076 - ($+1))
'     byte[p++] := decimal_chr
	rdlong	_var01, objptr
	mov	_var02, _var01
	add	_var02, #1
	wrlong	_var02, objptr
	add	objptr, #32
	rdlong	_var02, objptr
	sub	objptr, #32
	wrbyte	_var02, _var01
'   else
	add	pc, #4*(LR__0077 - ($+1))
LR__0076
'     byte[p++] := "."
	rdlong	_var01, objptr
	mov	_var02, _var01
	add	_var02, #1
	wrlong	_var02, objptr
	mov	_var02, #46
	wrbyte	_var02, _var01
LR__0077
_FloatString_AddDecimal_ret
	call	#LMM_RET

' 
'              
' PUB FMul(singleA, singleB) : single | sa, xa, ma, sb, xb, mb
_FloatMath_FMul
	mov	COUNT_, #0
	call	#pushregs_
	add	sp, #36
	add	fp, #4
	wrlong	arg01, fp
	add	fp, #4
	wrlong	arg02, fp
' 
' ''Multiply singleA by singleB
' 
'   Unpack(@sa, singleA)          'unpack inputs
	add	fp, #4
	mov	arg01, fp
	sub	fp, #8
	rdlong	arg02, fp
	sub	fp, #4
	call	#LMM_CALL
	long	@@@_FloatMath_Unpack
'   Unpack(@sb, singleB)
	add	fp, #24
	mov	arg01, fp
	sub	fp, #16
	rdlong	arg02, fp
	sub	fp, #8
	call	#LMM_CALL
	long	@@@_FloatMath_Unpack
' 
'   sa ^= sb                      'xor signs
	add	fp, #12
	rdlong	muldivb_, fp
	add	fp, #12
	rdlong	muldiva_, fp
	xor	muldivb_, muldiva_
	sub	fp, #12
	wrlong	muldivb_, fp
'   xa += xb                      'add exponents
	add	fp, #4
	rdlong	muldivb_, fp
	add	fp, #12
	rdlong	muldiva_, fp
	add	muldivb_, muldiva_
	sub	fp, #12
	wrlong	muldivb_, fp
'   ma := (ma ** mb) << 3         'multiply mantissas and justify
	add	fp, #4
	rdlong	muldiva_, fp
	add	fp, #12
	rdlong	muldivb_, fp
	sub	fp, #32
	call	#multiply_
	mov	arg01, muldivb_
	shl	arg01, #3
	add	fp, #20
	wrlong	arg01, fp
' 
'   return Pack(@sa)              'pack result
	sub	fp, #8
	mov	arg01, fp
	sub	fp, #12
	call	#LMM_CALL
	long	@@@_FloatMath_Pack
	mov	sp, fp
	call	#popregs_
_FloatMath_FMul_ret
	call	#LMM_RET

' 
' 
' PRI FInteger(a, r) : integer | s, x, m
_FloatMath_FInteger
	mov	COUNT_, #0
	call	#pushregs_
	add	sp, #24
	add	fp, #4
	wrlong	arg01, fp
	add	fp, #4
	wrlong	arg02, fp
' 
' 'Convert float to rounded/truncated integer
' 
'   Unpack(@s, a)                 'unpack input
	add	fp, #4
	mov	arg01, fp
	sub	fp, #8
	rdlong	arg02, fp
	sub	fp, #4
	call	#LMM_CALL
	long	@@@_FloatMath_Unpack
' 
'   if x => -1 and x =< 30        'if exponent not -1..30, result 0
	add	fp, #16
	rdlong	result1, fp
	sub	fp, #16
	cmps	result1, imm_4294967295_ wc
 if_b	add	pc, #4*(LR__0079 - ($+1))
	add	fp, #16
	rdlong	result1, fp
	sub	fp, #16
	cmps	result1, #31 wc
 if_ae	add	pc, #4*(LR__0079 - ($+1))
'     m <<= 2                     'msb-justify mantissa
	add	fp, #20
	rdlong	result1, fp
	shl	result1, #2
	wrlong	result1, fp
'     m >>= 30 - x                'shift down to 1/2-lsb
	mov	arg02, #30
	sub	fp, #4
	rdlong	arg01, fp
	sub	arg02, arg01
	shr	result1, arg02
	add	fp, #4
	wrlong	result1, fp
'     m += r                      'round (1) or truncate (0)
	sub	fp, #12
	rdlong	arg02, fp
	add	result1, arg02
	add	fp, #12
	wrlong	result1, fp
'     m >>= 1                     'shift down to lsb
	shr	result1, #1
	wrlong	result1, fp
'     if s                        'handle negation
	sub	fp, #8
	rdlong	result1, fp wz
	sub	fp, #12
 if_e	add	pc, #4*(LR__0078 - ($+1))
'       -m
	add	fp, #20
	rdlong	result1, fp
	neg	result1, result1
	wrlong	result1, fp
	sub	fp, #20
LR__0078
'     return m                    'return integer
	add	fp, #20
	rdlong	result1, fp
	sub	fp, #20
	add	pc, #4*(LR__0080 - ($+1))
LR__0079
	mov	result1, #0
LR__0080
	mov	sp, fp
	call	#popregs_
_FloatMath_FInteger_ret
	call	#LMM_RET

' 
'       
' PRI Unpack(pointer, single) | s, x, m
_FloatMath_Unpack
	mov	COUNT_, #2
	call	#pushregs_
	add	sp, #24
	add	fp, #4
	wrlong	arg01, fp
	add	fp, #4
	wrlong	arg02, fp
	sub	fp, #8
	mov	result1, #0
	wrlong	result1, fp
' 
' 'Unpack floating-point into (sign, exponent, mantissa) at pointer
' 
'   s := single >> 31             'unpack sign
	add	fp, #8
	rdlong	result1, fp
	shr	result1, #31
	add	fp, #4
	wrlong	result1, fp
'   x := single << 1 >> 24        'unpack exponent
	sub	fp, #4
	rdlong	result1, fp
	shl	result1, #1
	shr	result1, #24
	add	fp, #8
	wrlong	result1, fp
'   m := single & $007F_FFFF      'unpack mantissa
	sub	fp, #8
	rdlong	result1, fp
	and	result1, imm_8388607_
	add	fp, #12
	wrlong	result1, fp
' 
'   if x                          'if exponent > 0,
	sub	fp, #4
	rdlong	result1, fp wz
	sub	fp, #16
 if_e	add	pc, #4*(LR__0081 - ($+1))
'     m := m << 6 | $2000_0000    '..bit29-justify mantissa with leading 1
	add	fp, #20
	rdlong	result1, fp
	shl	result1, #6
	or	result1, imm_536870912_
	wrlong	result1, fp
	sub	fp, #20
'   else
	add	pc, #4*(LR__0084 - ($+1))
LR__0081
'     result := >|m - 23          'else, determine first 1 in mantissa
	add	fp, #20
	rdlong	local01, fp
	sub	fp, #20
	mov	local02, #32
	call	#LMM_FCACHE_LOAD
	long	(@@@LR__0083-@@@LR__0082)
LR__0082
	shl	local01, #1 wc
 if_ae	djnz	local02, #LMM_FCACHE_START + (LR__0082 - LR__0082)
LR__0083
	sub	local02, #23
	wrlong	local02, fp
'     x := result                 '..adjust exponent
	add	fp, #16
	wrlong	local02, fp
'     m <<= 7 - result            '..bit29-justify mantissa
	add	fp, #4
	rdlong	local02, fp
	sub	fp, #20
	mov	local01, #7
	rdlong	result1, fp
	sub	local01, result1
	shl	local02, local01
	add	fp, #20
	wrlong	local02, fp
	sub	fp, #20
LR__0084
' 
'   x -= 127                      'unbias exponent
	add	fp, #16
	rdlong	local02, fp
	sub	local02, #127
	wrlong	local02, fp
' 
'   longmove(pointer, @s, 3)      'write (s,x,m) structure from locals
	sub	fp, #12
	rdlong	arg01, fp
	add	fp, #8
	mov	arg02, fp
	sub	fp, #12
	mov	arg03, #3
	call	#LMM_CALL
	long	@@@__system__longmove
	rdlong	result1, fp
	mov	sp, fp
	call	#popregs_
_FloatMath_Unpack_ret
	call	#LMM_RET

'   
'   
' PRI Pack(pointer) : single | s, x, m
_FloatMath_Pack
	mov	COUNT_, #2
	call	#pushregs_
	add	sp, #20
	add	fp, #4
	wrlong	arg01, fp
	sub	fp, #4
	mov	result1, #0
	wrlong	result1, fp
' 
' 'Pack floating-point from (sign, exponent, mantissa) at pointer
' 
'   longmove(@s, pointer, 3)      'get (s,x,m) structure into locals
	add	fp, #8
	mov	arg01, fp
	sub	fp, #4
	rdlong	arg02, fp
	sub	fp, #4
	mov	arg03, #3
	call	#LMM_CALL
	long	@@@__system__longmove
' 
'   if m                          'if mantissa 0, result 0
	add	fp, #16
	rdlong	result1, fp wz
	sub	fp, #16
 if_e	add	pc, #4*(LR__0089 - ($+1))
'   
'     result := 33 - >|m          'determine magnitude of mantissa
	add	fp, #16
	rdlong	local01, fp
	sub	fp, #16
	mov	local02, #32
	call	#LMM_FCACHE_LOAD
	long	(@@@LR__0086-@@@LR__0085)
LR__0085
	shl	local01, #1 wc
 if_ae	djnz	local02, #LMM_FCACHE_START + (LR__0085 - LR__0085)
LR__0086
	mov	local01, #33
	sub	local01, local02
	wrlong	local01, fp
'     m <<= result                'msb-justify mantissa without leading 1
	add	fp, #16
	rdlong	local02, fp
	shl	local02, local01
	wrlong	local02, fp
'     x += 3 - result             'adjust exponent
	sub	fp, #4
	rdlong	local02, fp
	sub	fp, #12
	mov	result1, #3
	rdlong	local01, fp
	sub	result1, local01
	add	local02, result1
	add	fp, #12
	wrlong	local02, fp
' 
'     m += $00000100              'round up mantissa by 1/2 lsb
	add	fp, #4
	rdlong	local02, fp
	add	local02, #256
	wrlong	local02, fp
'     if not m & $FFFFFF00        'if rounding overflow,
	sub	fp, #16
	andn	local02, #255 wz
 if_ne	add	pc, #4*(LR__0087 - ($+1))
'       x++                       '..increment exponent
	add	fp, #12
	rdlong	local02, fp
	add	local02, #1
	wrlong	local02, fp
	sub	fp, #12
LR__0087
'     
'     x := x + 127 #> -23 <# 255  'bias and limit exponent
	add	fp, #12
	rdlong	local02, fp
	add	local02, #127
	mins	local02, imm_4294967273_
	maxs	local02, #255
	wrlong	local02, fp
' 
'     if x < 1                    'if exponent < 1,
	sub	fp, #12
	cmps	local02, #1 wc
 if_ae	add	pc, #4*(LR__0088 - ($+1))
'       m := $8000_0000 +  m >> 1 '..replace leading 1
	add	fp, #16
	rdlong	local02, fp
	shr	local02, #1
	mov	local01, imm_2147483648_
	add	local01, local02
	wrlong	local01, fp
'       m >>= -x                  '..shift mantissa down by exponent
	sub	fp, #4
	rdlong	local02, fp
	neg	local02, local02
	shr	local01, local02
	add	fp, #4
	wrlong	local01, fp
'       x~                        '..exponent is now 0
	mov	local02, #0
	sub	fp, #4
	wrlong	local02, fp
	sub	fp, #12
LR__0088
' 
'     return s << 31 | x << 23 | m >> 9 'pack result
	add	fp, #8
	rdlong	result1, fp
	shl	result1, #31
	add	fp, #4
	rdlong	local02, fp
	shl	local02, #23
	or	result1, local02
	add	fp, #4
	rdlong	local02, fp
	sub	fp, #16
	shr	local02, #9
	or	result1, local02
	add	pc, #4*(LR__0090 - ($+1))
LR__0089
	rdlong	result1, fp
LR__0090
	mov	sp, fp
	call	#popregs_
_FloatMath_Pack_ret
	call	#LMM_RET

'   
' PUB start : okay
_Float32_start
' {{Start start floating point engine in a new cog.
'   Returns:     True (non-zero) if cog started, or False (0) if no cog is available.}}
' 
'   stop
	call	#LMM_CALL
	long	@@@_Float32_stop
'   okay := cog := cognew(@getCommand, @command) + 1
	mov	arg02, ptr__Float32_dat__
	add	objptr, #4
	mov	arg03, objptr
	sub	objptr, #4
	mov	arg01, #30
	call	#LMM_CALL
	long	@@@__system___coginit
	add	result1, #1
	wrlong	result1, objptr
_Float32_start_ret
	call	#LMM_RET

' 
' PUB stop
_Float32_stop
	mov	COUNT_, #1
	call	#pushregs_
' {{Stop floating point engine and release the cog.}}
' 
'   if cog
	rdlong	arg01, objptr wz
 if_e	add	pc, #4*(LR__0091 - ($+1))
'     cogstop(cog~ - 1)
	rdlong	arg01, objptr
	mov	local01, #0
	wrlong	local01, objptr
	sub	arg01, #1
	cogstop	arg01
LR__0091
'   command~
	mov	local01, #0
	add	objptr, #4
	wrlong	local01, objptr
	sub	objptr, #4
	mov	sp, fp
	call	#popregs_
_Float32_stop_ret
	call	#LMM_RET

'          
' PUB FAdd(a, b)
_Float32_FAdd
	mov	COUNT_, #0
	call	#pushregs_
	add	sp, #12
	add	fp, #4
	wrlong	arg01, fp
	add	fp, #4
	wrlong	arg02, fp
' {{Addition: result = a + b
'   Returns:   32-bit floating point value}}
'                         
'   command := FAddCmd + @a
	mov	arg02, imm_65536_
	sub	fp, #4
	add	arg02, fp
	add	objptr, #4
	wrlong	arg02, objptr
'   repeat while command
	sub	fp, #4
	call	#LMM_FCACHE_LOAD
	long	(@@@LR__0093-@@@LR__0092)
LR__0092
	rdlong	arg02, objptr wz
 if_ne	jmp	#LMM_FCACHE_START + (LR__0092 - LR__0092)
LR__0093
'   return cmdReturn
	add	objptr, #4
	rdlong	result1, objptr
	sub	objptr, #8
	mov	sp, fp
	call	#popregs_
_Float32_FAdd_ret
	call	#LMM_RET

'   
' PUB FMul(a, b)
_Float32_FMul
	mov	COUNT_, #0
	call	#pushregs_
	add	sp, #12
	add	fp, #4
	wrlong	arg01, fp
	add	fp, #4
	wrlong	arg02, fp
' {{Multiplication: result = a * b
'   Returns:   32-bit floating point value}}
' 
'   command := FMulCmd + @a
	mov	arg02, imm_196608_
	sub	fp, #4
	add	arg02, fp
	add	objptr, #4
	wrlong	arg02, objptr
'   repeat while command
	sub	fp, #4
	call	#LMM_FCACHE_LOAD
	long	(@@@LR__0095-@@@LR__0094)
LR__0094
	rdlong	arg02, objptr wz
 if_ne	jmp	#LMM_FCACHE_START + (LR__0094 - LR__0094)
LR__0095
'   return cmdReturn
	add	objptr, #4
	rdlong	result1, objptr
	sub	objptr, #8
	mov	sp, fp
	call	#popregs_
_Float32_FMul_ret
	call	#LMM_RET

'           
' PUB FDiv(a, b)
_Float32_FDiv
	mov	COUNT_, #0
	call	#pushregs_
	add	sp, #12
	add	fp, #4
	wrlong	arg01, fp
	add	fp, #4
	wrlong	arg02, fp
' {{Division: result = a / b
'   Returns:   32-bit floating point value}}
' 
'   command := FDivCmd + @a
	mov	arg02, imm_262144_
	sub	fp, #4
	add	arg02, fp
	add	objptr, #4
	wrlong	arg02, objptr
'   repeat while command
	sub	fp, #4
	call	#LMM_FCACHE_LOAD
	long	(@@@LR__0097-@@@LR__0096)
LR__0096
	rdlong	arg02, objptr wz
 if_ne	jmp	#LMM_FCACHE_START + (LR__0096 - LR__0096)
LR__0097
'   return cmdReturn
	add	objptr, #4
	rdlong	result1, objptr
	sub	objptr, #8
	mov	sp, fp
	call	#popregs_
_Float32_FDiv_ret
	call	#LMM_RET

' 
' PUB FFloat(n)
_Float32_FFloat
	mov	COUNT_, #0
	call	#pushregs_
	add	sp, #8
	add	fp, #4
	wrlong	arg01, fp
' {{Convert integer to floating point.
'   Returns:   32-bit floating point value}}
' 
'   command := FFloatCmd + @n
	mov	arg01, imm_327680_
	add	arg01, fp
	add	objptr, #4
	wrlong	arg01, objptr
'   repeat while command
	sub	fp, #4
	call	#LMM_FCACHE_LOAD
	long	(@@@LR__0099-@@@LR__0098)
LR__0098
	rdlong	arg01, objptr wz
 if_ne	jmp	#LMM_FCACHE_START + (LR__0098 - LR__0098)
LR__0099
'   return cmdReturn  
	add	objptr, #4
	rdlong	result1, objptr
	sub	objptr, #8
	mov	sp, fp
	call	#popregs_
_Float32_FFloat_ret
	call	#LMM_RET

' 
' PUB FTrunc(a)
_Float32_FTrunc
	mov	COUNT_, #0
	call	#pushregs_
	add	sp, #8
	add	fp, #4
	wrlong	arg01, fp
' {{Convert floating point to integer (with truncation).
'   Returns:   32-bit integer value }}
' 
'    command := FTruncCmd + @a
	mov	arg01, imm_393216_
	add	arg01, fp
	add	objptr, #4
	wrlong	arg01, objptr
'   repeat while command
	sub	fp, #4
	call	#LMM_FCACHE_LOAD
	long	(@@@LR__0101-@@@LR__0100)
LR__0100
	rdlong	arg01, objptr wz
 if_ne	jmp	#LMM_FCACHE_START + (LR__0100 - LR__0100)
LR__0101
'   return cmdReturn  
	add	objptr, #4
	rdlong	result1, objptr
	sub	objptr, #8
	mov	sp, fp
	call	#popregs_
_Float32_FTrunc_ret
	call	#LMM_RET

' 
' PUB Sin(a)
_Float32_Sin
	mov	COUNT_, #0
	call	#pushregs_
	add	sp, #8
	add	fp, #4
	wrlong	arg01, fp
' {{Sine of an angle. 
'   Returns:   32-bit floating point value}}
' 
'   command := SinCmd + @a
	mov	arg01, imm_655360_
	add	arg01, fp
	add	objptr, #4
	wrlong	arg01, objptr
'   repeat while command
	sub	fp, #4
	call	#LMM_FCACHE_LOAD
	long	(@@@LR__0103-@@@LR__0102)
LR__0102
	rdlong	arg01, objptr wz
 if_ne	jmp	#LMM_FCACHE_START + (LR__0102 - LR__0102)
LR__0103
'   return cmdReturn  
	add	objptr, #4
	rdlong	result1, objptr
	sub	objptr, #8
	mov	sp, fp
	call	#popregs_
_Float32_Sin_ret
	call	#LMM_RET

' 
' PUB Cos(a)
_Float32_Cos
	mov	COUNT_, #0
	call	#pushregs_
	add	sp, #8
	add	fp, #4
	wrlong	arg01, fp
' {{Cosine of an angle.
'   Returns:   32-bit floating point value}}
' 
'   command := CosCmd + @a
	mov	arg01, imm_720896_
	add	arg01, fp
	add	objptr, #4
	wrlong	arg01, objptr
'   repeat while command
	sub	fp, #4
	call	#LMM_FCACHE_LOAD
	long	(@@@LR__0105-@@@LR__0104)
LR__0104
	rdlong	arg01, objptr wz
 if_ne	jmp	#LMM_FCACHE_START + (LR__0104 - LR__0104)
LR__0105
'   return cmdReturn  
	add	objptr, #4
	rdlong	result1, objptr
	sub	objptr, #8
	mov	sp, fp
	call	#popregs_
_Float32_Cos_ret
	call	#LMM_RET
hubexit
	jmp	#cogexit

__system___coginit
	and	arg03, imm_65532_
	shl	arg03, #16
	and	arg02, imm_65532_
	shl	arg02, #2
	or	arg03, arg02
	and	arg01, #15
	or	arg03, arg01
	coginit	arg03 wc,wr
 if_b	neg	arg03, #1
	mov	result1, arg03
__system___coginit_ret
	call	#LMM_RET

__system____builtin_memmove
	mov	_var01, arg01
	cmps	arg01, arg02 wc
 if_ae	add	pc, #4*(LR__0108 - ($+1))
	mov	_var02, arg03 wz
 if_e	add	pc, #4*(LR__0112 - ($+1))
	call	#LMM_FCACHE_LOAD
	long	(@@@LR__0107-@@@LR__0106)
LR__0106
	rdbyte	result1, arg02
	wrbyte	result1, arg01
	add	arg01, #1
	add	arg02, #1
	djnz	_var02, #LMM_FCACHE_START + (LR__0106 - LR__0106)
LR__0107
	add	pc, #4*(LR__0112 - ($+1))
LR__0108
	add	arg01, arg03
	add	arg02, arg03
	mov	_var03, arg03 wz
 if_e	add	pc, #4*(LR__0111 - ($+1))
	call	#LMM_FCACHE_LOAD
	long	(@@@LR__0110-@@@LR__0109)
LR__0109
	sub	arg01, #1
	sub	arg02, #1
	rdbyte	_var04, arg02
	wrbyte	_var04, arg01
	djnz	_var03, #LMM_FCACHE_START + (LR__0109 - LR__0109)
LR__0110
LR__0111
LR__0112
	mov	result1, _var01
__system____builtin_memmove_ret
	call	#LMM_RET

__system__longmove
	mov	_var01, arg01
	cmps	arg01, arg02 wc
 if_ae	add	pc, #4*(LR__0115 - ($+1))
	mov	_var02, arg03 wz
 if_e	add	pc, #4*(LR__0119 - ($+1))
	call	#LMM_FCACHE_LOAD
	long	(@@@LR__0114-@@@LR__0113)
LR__0113
	rdlong	result1, arg02
	wrlong	result1, arg01
	add	arg01, #4
	add	arg02, #4
	djnz	_var02, #LMM_FCACHE_START + (LR__0113 - LR__0113)
LR__0114
	add	pc, #4*(LR__0119 - ($+1))
LR__0115
	mov	_var03, arg03
	shl	_var03, #2
	add	arg01, _var03
	mov	_var03, arg03
	shl	_var03, #2
	add	arg02, _var03
	mov	_var04, arg03 wz
 if_e	add	pc, #4*(LR__0118 - ($+1))
	call	#LMM_FCACHE_LOAD
	long	(@@@LR__0117-@@@LR__0116)
LR__0116
	sub	arg01, #4
	sub	arg02, #4
	rdlong	_var05, arg02
	wrlong	_var05, arg01
	djnz	_var04, #LMM_FCACHE_START + (LR__0116 - LR__0116)
LR__0117
LR__0118
LR__0119
	mov	result1, _var01
__system__longmove_ret
	call	#LMM_RET

__system____builtin_strlen
	mov	_var01, #0
	call	#LMM_FCACHE_LOAD
	long	(@@@LR__0121-@@@LR__0120)
LR__0120
	rdbyte	result1, arg01 wz
 if_ne	add	_var01, #1
 if_ne	add	arg01, #1
 if_ne	jmp	#LMM_FCACHE_START + (LR__0120 - LR__0120)
LR__0121
	mov	result1, _var01
__system____builtin_strlen_ret
	call	#LMM_RET

LR__0122
	byte	"title"
	byte	0
LR__0123
	byte	"Sine and Cosine Waveforms"
	byte	0
LR__0124
	byte	"x-label"
	byte	0
LR__0125
	byte	"Time"
	byte	0
LR__0126
	byte	"y-label"
	byte	0
LR__0127
	byte	"Amplitude"
	byte	0
LR__0128
	byte	"Sinewave"
	byte	0
LR__0129
	byte	"Cosinewave"
	byte	0
LR__0130
	byte	"Sinewave"
	byte	0
LR__0131
	byte	"Cosinewave"
	byte	0
LR__0132
	byte	"{TIMEPLOT|SET|"
	byte	0
LR__0133
	byte	"{TIMEPLOT|STYLE|"
	byte	0
LR__0134
	byte	"{TIMEPLOT|DATA|"
	byte	0
LR__0135
	byte	"|T|"
	byte	0
LR__0136
	byte	"{TIMEPLOT|DATA|"
	byte	0
LR__0137
	byte	"|T|"
	byte	0
	long
_FullDuplexSerialAvail_dat_
'-' 
'-' '***********************************
'-' '* Assembly language serial driver *
'-' '***********************************
'-' 
'-'                         org
'-' '
'-' '
'-' ' Entry
'-' '
'-' entry                   mov     t1,par                'get structure address
	byte	$f0, $a9, $bc, $a0
'-'                         add     t1,#4 << 2            'skip past heads and tails
	byte	$10, $a8, $fc, $80
'-' 
'-'                         rdlong  t2,t1                 'get rx_pin
	byte	$54, $aa, $bc, $08
'-'                         mov     rxmask,#1
	byte	$01, $b2, $fc, $a0
'-'                         shl     rxmask,t2
	byte	$55, $b2, $bc, $2c
'-' 
'-'                         add     t1,#4                 'get tx_pin
	byte	$04, $a8, $fc, $80
'-'                         rdlong  t2,t1
	byte	$54, $aa, $bc, $08
'-'                         mov     txmask,#1
	byte	$01, $be, $fc, $a0
'-'                         shl     txmask,t2
	byte	$55, $be, $bc, $2c
'-' 
'-'                         add     t1,#4                 'get rxtx_mode
	byte	$04, $a8, $fc, $80
'-'                         rdlong  rxtxmode,t1
	byte	$54, $ae, $bc, $08
'-' 
'-'                         add     t1,#4                 'get bit_ticks
	byte	$04, $a8, $fc, $80
'-'                         rdlong  bitticks,t1
	byte	$54, $b0, $bc, $08
'-' 
'-'                         add     t1,#4                 'get buffer_ptr
	byte	$04, $a8, $fc, $80
'-'                         rdlong  rxbuff,t1
	byte	$54, $b4, $bc, $08
'-'                         mov     txbuff,rxbuff
	byte	$5a, $c0, $bc, $a0
'-'                         add     txbuff,#16
	byte	$10, $c0, $fc, $80
'-' 
'-'                         test    rxtxmode,#%100  wz    'init tx pin according to mode
	byte	$04, $ae, $7c, $62
'-'                         test    rxtxmode,#%010  wc
	byte	$02, $ae, $7c, $61
'-'         if_z_ne_c       or      outa,txmask
	byte	$5f, $e8, $9b, $68
'-'         if_z            or      dira,txmask
	byte	$5f, $ec, $ab, $68
'-' 
'-'                         mov     txcode,#transmit      'initialize ping-pong multitasking
	byte	$33, $c8, $fc, $a0
'-' '
'-' '
'-' ' Receive
'-' '
'-' receive                 jmpret  rxcode,txcode         'run a chunk of transmit code, then return
	byte	$64, $bc, $bc, $5c
'-' 
'-'                         test    rxtxmode,#%001  wz    'wait for start bit on rx pin
	byte	$01, $ae, $7c, $62
'-'                         test    rxmask,ina      wc
	byte	$f2, $b3, $3c, $61
'-'         if_z_eq_c       jmp     #receive
	byte	$16, $00, $64, $5c
'-' 
'-'                         mov     rxbits,#9             'ready to receive byte
	byte	$09, $b8, $fc, $a0
'-'                         mov     rxcnt,bitticks
	byte	$58, $ba, $bc, $a0
'-'                         shr     rxcnt,#1
	byte	$01, $ba, $fc, $28
'-'                         add     rxcnt,cnt
	byte	$f1, $bb, $bc, $80
'-' 
'-' :bit                    add     rxcnt,bitticks        'ready next bit period
	byte	$58, $ba, $bc, $80
'-' 
'-' :wait                   jmpret  rxcode,txcode         'run a chuck of transmit code, then return
	byte	$64, $bc, $bc, $5c
'-' 
'-'                         mov     t1,rxcnt              'check if bit receive period done
	byte	$5d, $a8, $bc, $a0
'-'                         sub     t1,cnt
	byte	$f1, $a9, $bc, $84
'-'                         cmps    t1,#0           wc
	byte	$00, $a8, $7c, $c1
'-'         if_nc           jmp     #:wait
	byte	$1f, $00, $4c, $5c
'-' 
'-'                         test    rxmask,ina      wc    'receive bit on rx pin
	byte	$f2, $b3, $3c, $61
'-'                         rcr     rxdata,#1
	byte	$01, $b6, $fc, $30
'-'                         djnz    rxbits,#:bit
	byte	$1e, $b8, $fc, $e4
'-' 
'-'                         shr     rxdata,#32-9          'justify and trim received byte
	byte	$17, $b6, $fc, $28
'-'                         and     rxdata,#$FF
	byte	$ff, $b6, $fc, $60
'-'                         test    rxtxmode,#%001  wz    'if rx inverted, invert byte
	byte	$01, $ae, $7c, $62
'-'         if_nz           xor     rxdata,#$FF
	byte	$ff, $b6, $d4, $6c
'-' 
'-'                         rdlong  t2,par                'save received byte and inc head
	byte	$f0, $ab, $bc, $08
'-'                         add     t2,rxbuff
	byte	$5a, $aa, $bc, $80
'-'                         wrbyte  rxdata,t2
	byte	$55, $b6, $3c, $00
'-'                         sub     t2,rxbuff
	byte	$5a, $aa, $bc, $84
'-'                         add     t2,#1
	byte	$01, $aa, $fc, $80
'-'                         and     t2,#$0F
	byte	$0f, $aa, $fc, $60
'-'                         wrlong  t2,par
	byte	$f0, $ab, $3c, $08
'-' 
'-'                         jmp     #receive              'byte done, receive next byte
	byte	$16, $00, $7c, $5c
'-' '
'-' '
'-' ' Transmit
'-' '
'-' transmit                jmpret  txcode,rxcode         'run a chunk of receive code, then return
	byte	$5e, $c8, $bc, $5c
'-' 
'-'                         mov     t1,par                'check for head <> tail
	byte	$f0, $a9, $bc, $a0
'-'                         add     t1,#2 << 2
	byte	$08, $a8, $fc, $80
'-'                         rdlong  t2,t1
	byte	$54, $aa, $bc, $08
'-'                         add     t1,#1 << 2
	byte	$04, $a8, $fc, $80
'-'                         rdlong  t3,t1
	byte	$54, $ac, $bc, $08
'-'                         cmp     t2,t3           wz
	byte	$56, $aa, $3c, $86
'-'         if_z            jmp     #transmit
	byte	$33, $00, $68, $5c
'-' 
'-'                         add     t3,txbuff             'get byte and inc tail
	byte	$60, $ac, $bc, $80
'-'                         rdbyte  txdata,t3
	byte	$56, $c2, $bc, $00
'-'                         sub     t3,txbuff
	byte	$60, $ac, $bc, $84
'-'                         add     t3,#1
	byte	$01, $ac, $fc, $80
'-'                         and     t3,#$0F
	byte	$0f, $ac, $fc, $60
'-'                         wrlong  t3,t1
	byte	$54, $ac, $3c, $08
'-' 
'-'                         or      txdata,#$100          'ready byte to transmit
	byte	$00, $c3, $fc, $68
'-'                         shl     txdata,#2
	byte	$02, $c2, $fc, $2c
'-'                         or      txdata,#1
	byte	$01, $c2, $fc, $68
'-'                         mov     txbits,#11
	byte	$0b, $c4, $fc, $a0
'-'                         mov     txcnt,cnt
	byte	$f1, $c7, $bc, $a0
'-' 
'-' :bit                    test    rxtxmode,#%100  wz    'output bit on tx pin according to mode
	byte	$04, $ae, $7c, $62
'-'                         test    rxtxmode,#%010  wc
	byte	$02, $ae, $7c, $61
'-'         if_z_and_c      xor     txdata,#1
	byte	$01, $c2, $e0, $6c
'-'                         shr     txdata,#1       wc
	byte	$01, $c2, $fc, $29
'-'         if_z            muxc    outa,txmask
	byte	$5f, $e8, $ab, $70
'-'         if_nz           muxnc   dira,txmask
	byte	$5f, $ec, $97, $74
'-'                         add     txcnt,bitticks        'ready next cnt
	byte	$58, $c6, $bc, $80
'-' 
'-' :wait                   jmpret  txcode,rxcode         'run a chunk of receive code, then return
	byte	$5e, $c8, $bc, $5c
'-' 
'-'                         mov     t1,txcnt              'check if bit transmit period done
	byte	$63, $a8, $bc, $a0
'-'                         sub     t1,cnt
	byte	$f1, $a9, $bc, $84
'-'                         cmps    t1,#0           wc
	byte	$00, $a8, $7c, $c1
'-'         if_nc           jmp     #:wait
	byte	$4d, $00, $4c, $5c
'-' 
'-'                         djnz    txbits,#:bit          'another bit to transmit?
	byte	$46, $c4, $fc, $e4
'-' 
'-'                         jmp     #transmit             'byte done, transmit next byte
	byte	$33, $00, $7c, $5c
'-' '
'-' '
'-' ' Uninitialized data
'-' '
'-' t1                      res     1
'-' t1                      res     1
'-' t2                      res     1
'-' t2                      res     1
'-' t3                      res     1
'-' t3                      res     1
'-' 
'-' rxtxmode                res     1
'-' rxtxmode                res     1
'-' bitticks                res     1
'-' bitticks                res     1
'-' 
'-' rxmask                  res     1
'-' rxmask                  res     1
'-' rxbuff                  res     1
'-' rxbuff                  res     1
'-' rxdata                  res     1
'-' rxdata                  res     1
'-' rxbits                  res     1
'-' rxbits                  res     1
'-' rxcnt                   res     1
'-' rxcnt                   res     1
'-' rxcode                  res     1
'-' rxcode                  res     1
'-' 
'-' txmask                  res     1
'-' txmask                  res     1
'-' txbuff                  res     1
'-' txbuff                  res     1
'-' txdata                  res     1
'-' txdata                  res     1
'-' txbits                  res     1
'-' txbits                  res     1
'-' txcnt                   res     1
'-' txcnt                   res     1
'-' txcode                  res     1
'-' txcode                  res     1
	long
_Numbers_dat_
'-'   DefaultSymbols        byte    ",_$%xxx"                                                               'Special, default, symbols ("x" means unused)
	byte	$2c, $5f, $24, $25, $78, $78, $78, $00
	long
_FloatString_dat_
'-'         long                1e+38, 1e+37, 1e+36, 1e+35, 1e+34, 1e+33, 1e+32, 1e+31
	byte	$99, $76, $96, $7e, $c2, $bd, $f0, $7c, $ce, $97, $40, $7b, $0c, $13, $9a, $79
	byte	$df, $84, $f6, $77, $19, $37, $45, $76, $ae, $c5, $9d, $74, $7c, $6f, $fc, $72
'-'         long  1e+30, 1e+29, 1e+28, 1e+27, 1e+26, 1e+25, 1e+24, 1e+23, 1e+22, 1e+21
	byte	$ca, $f2, $49, $71, $08, $8f, $a1, $6f, $39, $3f, $01, $6e, $8f, $cb, $4e, $6c
	byte	$a6, $6f, $a5, $6a, $51, $59, $04, $69, $1c, $c2, $53, $67, $16, $68, $a9, $65
	byte	$78, $86, $07, $64, $27, $d7, $58, $62
'-'         long  1e+20, 1e+19, 1e+18, 1e+17, 1e+16, 1e+15, 1e+14, 1e+13, 1e+12, 1e+11
	byte	$ec, $78, $ad, $60, $23, $c7, $0a, $5f, $6b, $0b, $5e, $5d, $bc, $a2, $b1, $5b
	byte	$ca, $1b, $0e, $5a, $a9, $5f, $63, $58, $21, $e6, $b5, $56, $e7, $84, $11, $55
	byte	$a5, $d4, $68, $53, $b7, $43, $ba, $51
'-'         long  1e+10, 1e+09, 1e+08, 1e+07, 1e+06, 1e+05, 1e+04, 1e+03, 1e+02, 1e+01
	byte	$f9, $02, $15, $50, $28, $6b, $6e, $4e, $20, $bc, $be, $4c, $80, $96, $18, $4b
	byte	$00, $24, $74, $49, $00, $50, $c3, $47, $00, $40, $1c, $46, $00, $00, $7a, $44
	byte	$00, $00, $c8, $42, $00, $00, $20, $41
'-' tenf    long  1e+00, 1e-01, 1e-02, 1e-03, 1e-04, 1e-05, 1e-06, 1e-07, 1e-08, 1e-09
	byte	$00, $00, $80, $3f, $cd, $cc, $cc, $3d, $0a, $d7, $23, $3c, $6f, $12, $83, $3a
	byte	$17, $b7, $d1, $38, $ac, $c5, $27, $37, $bd, $37, $86, $35, $95, $bf, $d6, $33
	byte	$77, $cc, $2b, $32, $5f, $70, $89, $30
'-'         long  1e-10, 1e-11, 1e-12, 1e-13, 1e-14, 1e-15, 1e-16, 1e-17, 1e-18, 1e-19
	byte	$ff, $e6, $db, $2e, $ff, $eb, $2f, $2d, $cc, $bc, $8c, $2b, $13, $2e, $e1, $29
	byte	$dc, $24, $34, $28, $7d, $1d, $90, $26, $95, $95, $e6, $24, $aa, $77, $38, $23
	byte	$ef, $92, $93, $21, $4a, $1e, $ec, $1f
'-'         long  1e-20, 1e-21, 1e-22, 1e-23, 1e-24, 1e-25, 1e-26, 1e-27, 1e-28, 1e-29
	byte	$08, $e5, $3c, $1e, $a0, $1d, $97, $1c, $01, $c9, $f1, $1a, $9a, $6d, $41, $19
	byte	$15, $be, $9a, $17, $88, $96, $f7, $15, $06, $12, $46, $14, $d2, $74, $9e, $12
	byte	$b6, $87, $fd, $10, $f8, $d2, $4a, $0f
'-'         long  1e-30, 1e-31, 1e-32, 1e-33, 1e-34, 1e-35, 1e-36, 1e-37, 1e-38
	byte	$60, $42, $a2, $0d, $b3, $ce, $01, $0c, $1f, $b1, $4f, $0a, $4c, $27, $a6, $08
	byte	$3d, $ec, $04, $07, $2e, $ad, $54, $05, $25, $24, $aa, $03, $ea, $1c, $08, $02
	byte	$ee, $e3, $6c, $00
'-' 
'-' teni    long  1, 10, 100, 1_000, 10_000, 100_000, 1_000_000, 10_000_000
	byte	$01, $00, $00, $00, $0a, $00, $00, $00, $64, $00, $00, $00, $e8, $03, $00, $00
	byte	$10, $27, $00, $00, $a0, $86, $01, $00, $40, $42, $0f, $00, $80, $96, $98, $00
'-' 
'-'         byte "yzafpnum"
	byte	$79, $7a, $61, $66, $70, $6e, $75, $6d
'-' metric  byte 0
	byte	$00
'-'         byte "kMGTPEZY"
	byte	$6b, $4d, $47, $54, $50, $45, $5a, $59, $00, $00, $00
	long
_Float32_dat_
'-' 
'-' '---------------------------
'-' ' Assembly language routines
'-' '---------------------------
'-'                         org
'-' 
'-' getCommand              rdlong  t1, par wz              ' wait for command
	byte	$f0, $b3, $bf, $0a
'-'           if_z          jmp     #getCommand
	byte	$00, $00, $68, $5c
'-' 
'-'                         mov     t2, t1                  ' load fnumA
	byte	$d9, $b5, $bf, $a0
'-'                         rdlong  fnumA, t2
	byte	$da, $c5, $bf, $08
'-'                         add     t2, #4          
	byte	$04, $b4, $ff, $80
'-'                         rdlong  fnumB, t2               ' load fnumB
	byte	$da, $cd, $bf, $08
'-' 
'-'                         shr     t1, #16 wz              ' get command
	byte	$10, $b2, $ff, $2a
'-'                         cmp     t1, #(FracCmd>>16)+1 wc ' check for valid command
	byte	$13, $b2, $7f, $85
'-'           if_z_or_nc    jmp     #:exitNaN 
	byte	$30, $00, $6c, $5c
'-'                         shl     t1, #1
	byte	$01, $b2, $ff, $2c
'-'                         add     t1, #:cmdTable-2 
	byte	$0a, $b2, $ff, $80
'-'                         jmp     t1                      ' jump to command
	byte	$d9, $01, $3c, $5c
'-' 
'-' :cmdTable               call    #_FAdd                  ' command dispatch table
	byte	$41, $aa, $fc, $5c
'-'                         jmp     #endCommand
	byte	$31, $00, $7c, $5c
'-'                         call    #_FSub
	byte	$3c, $aa, $fc, $5c
'-'                         jmp     #endCommand
	byte	$31, $00, $7c, $5c
'-'                         call    #_FMul
	byte	$59, $ce, $fc, $5c
'-'                         jmp     #endCommand
	byte	$31, $00, $7c, $5c
'-'                         call    #_FDiv
	byte	$6b, $f4, $fc, $5c
'-'                         jmp     #endCommand
	byte	$31, $00, $7c, $5c
'-'                         call    #_FFloat
	byte	$7b, $0e, $fd, $5c
'-'                         jmp     #endCommand
	byte	$31, $00, $7c, $5c
'-'                         call    #_FTrunc
	byte	$88, $30, $fd, $5c
'-'                         jmp     #endCommand
	byte	$31, $00, $7c, $5c
'-'                         call    #_FRound
	byte	$8a, $30, $fd, $5c
'-'                         jmp     #endCommand
	byte	$31, $00, $7c, $5c
'-'                         call    #_FSqr
	byte	$99, $68, $fd, $5c
'-'                         jmp     #endCommand
	byte	$31, $00, $7c, $5c
'-'                         call    #cmd_FCmp
	byte	$36, $70, $fc, $5c
'-'                         jmp     #endCommand
	byte	$31, $00, $7c, $5c
'-'                         call    #_Sin
	byte	$cd, $f8, $fd, $5c
'-'                         jmp     #endCommand
	byte	$31, $00, $7c, $5c
'-'                         call    #_Cos
	byte	$cb, $f8, $fd, $5c
'-'                         jmp     #endCommand
	byte	$31, $00, $7c, $5c
'-'                         call    #_Tan
	byte	$fd, $08, $fe, $5c
'-'                         jmp     #endCommand
	byte	$31, $00, $7c, $5c
'-'                         call    #_Log
	byte	$05, $11, $fe, $5c
'-'                         jmp     #endCommand
	byte	$31, $00, $7c, $5c
'-'                         call    #_Log10
	byte	$09, $19, $fe, $5c
'-'                         jmp     #endCommand
	byte	$31, $00, $7c, $5c
'-'                         call    #_Exp
	byte	$20, $85, $fe, $5c
'-'                         jmp     #endCommand
	byte	$31, $00, $7c, $5c
'-'                         call    #_Exp10
	byte	$23, $85, $fe, $5c
'-'                         jmp     #endCommand
	byte	$31, $00, $7c, $5c
'-'                         call    #_Pow
	byte	$43, $c1, $fe, $5c
'-'                         jmp     #endCommand
	byte	$31, $00, $7c, $5c
'-'                         call    #_Frac
	byte	$61, $d5, $fe, $5c
'-'                         jmp     #endCommand
	byte	$31, $00, $7c, $5c
'-' :cmdTableEnd
'-' 
'-' :exitNaN                mov     fnumA, NaN              ' unknown command
	byte	$cb, $c5, $bf, $a0
'-' 
'-' endCommand              mov     t1, par                 ' return result
	byte	$f0, $b3, $bf, $a0
'-'                         add     t1, #4
	byte	$04, $b2, $ff, $80
'-'                         wrlong  fnumA, t1
	byte	$d9, $c5, $3f, $08
'-'                         wrlong  Zero,par                ' clear command status
	byte	$f0, $93, $3f, $08
'-'                         jmp     #getCommand             ' wait for next command
	byte	$00, $00, $7c, $5c
'-' 
'-' '------------------------------------------------------------------------------
'-' 
'-' cmd_FCmp                call    #_FCmp                  ' compare fnumA and fnumB
	byte	$b8, $94, $fd, $5c
'-'                         mov     fnumA, status           ' return compare status
	byte	$e1, $c5, $bf, $a0
'-' cmd_FCmp_ret            ret
	byte	$00, $00, $7c, $5c
'-' 
'-' '------------------------------------------------------------------------------
'-' ' _FAdd    fnumA = fnumA + fNumB
'-' ' _FAddI   fnumA = fnumA + {Float immediate}
'-' ' _FSub    fnumA = fnumA - fNumB
'-' ' _FSubI   fnumA = fnumA - {Float immediate}
'-' ' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1
'-' '------------------------------------------------------------------------------
'-' 
'-' _FSubI                  movs    :getB, _FSubI_ret       ' get immediate value
	byte	$55, $76, $bc, $50
'-'                         add     _FSubI_ret, #1
	byte	$01, $aa, $fc, $80
'-' :getB                   mov     fnumB, 0
	byte	$00, $cc, $bf, $a0
'-' 
'-' _FSub                   xor     fnumB, Bit31            ' negate B
	byte	$d2, $cd, $bf, $6c
'-'                         jmp     #_FAdd                  ' add values                                               
	byte	$41, $00, $7c, $5c
'-' 
'-' _FAddI                  movs    :getB, _FAddI_ret       ' get immediate value
	byte	$55, $80, $bc, $50
'-'                         add     _FAddI_ret, #1
	byte	$01, $aa, $fc, $80
'-' :getB                   mov     fnumB, 0
	byte	$00, $cc, $bf, $a0
'-' 
'-' _FAdd                   call    #_Unpack2               ' unpack two variables                    
	byte	$86, $23, $ff, $5c
'-'           if_c_or_z     jmp     #_FAdd_ret              ' check for NaN or B = 0
	byte	$55, $00, $78, $5c
'-' 
'-'                         test    flagA, #SignFlag wz     ' negate A mantissa if negative
	byte	$01, $c6, $7f, $62
'-'           if_nz         neg     manA, manA
	byte	$e5, $cb, $97, $a4
'-'                         test    flagB, #SignFlag wz     ' negate B mantissa if negative
	byte	$01, $ce, $7f, $62
'-'           if_nz         neg     manB, manB
	byte	$e9, $d3, $97, $a4
'-' 
'-'                         mov     t1, expA                ' align mantissas
	byte	$e4, $b3, $bf, $a0
'-'                         sub     t1, expB
	byte	$e8, $b3, $bf, $84
'-'                         abs     t1, t1
	byte	$d9, $b3, $bf, $a8
'-'                         max     t1, #31
	byte	$1f, $b2, $ff, $4c
'-'                         cmps    expA, expB wz,wc
	byte	$e8, $c9, $3f, $c3
'-'           if_nz_and_nc  sar     manB, t1
	byte	$d9, $d3, $87, $38
'-'           if_nz_and_c   sar     manA, t1
	byte	$d9, $cb, $93, $38
'-'           if_nz_and_c   mov     expA, expB        
	byte	$e8, $c9, $93, $a0
'-' 
'-'                         add     manA, manB              ' add the two mantissas
	byte	$e9, $cb, $bf, $80
'-'                         cmps    manA, #0 wc, nr         ' set sign of result
	byte	$00, $ca, $7f, $c1
'-'           if_c          or      flagA, #SignFlag
	byte	$01, $c6, $f3, $68
'-'           if_nc         andn    flagA, #SignFlag
	byte	$01, $c6, $cf, $64
'-'                         abs     manA, manA              ' pack result and exit
	byte	$e5, $cb, $bf, $a8
'-'                         call    #_Pack  
	byte	$b0, $91, $ff, $5c
'-' _FSubI_ret
'-' _FSub_ret 
'-' _FAddI_ret
'-' _FAdd_ret               ret      
	byte	$00, $00, $7c, $5c
'-' 
'-' '------------------------------------------------------------------------------
'-' ' _FMul    fnumA = fnumA * fNumB
'-' ' _FMulI   fnumA = fnumA * {Float immediate}
'-' ' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1, t2
'-' '------------------------------------------------------------------------------
'-' 
'-' _FMulI                  movs    :getB, _FMulI_ret       ' get immediate value
	byte	$67, $b0, $bc, $50
'-'                         add     _FMulI_ret, #1
	byte	$01, $ce, $fc, $80
'-' :getB                   mov     fnumB, 0
	byte	$00, $cc, $bf, $a0
'-' 
'-' _FMul                   call    #_Unpack2               ' unpack two variables
	byte	$86, $23, $ff, $5c
'-'           if_c          jmp     #_FMul_ret              ' check for NaN
	byte	$67, $00, $70, $5c
'-' 
'-'                         xor     flagA, flagB            ' get sign of result
	byte	$e7, $c7, $bf, $6c
'-'                         add     expA, expB              ' add exponents
	byte	$e8, $c9, $bf, $80
'-'                         mov     t1, #0                  ' t2 = upper 32 bits of manB
	byte	$00, $b2, $ff, $a0
'-'                         mov     t2, #32                 ' loop counter for multiply
	byte	$20, $b4, $ff, $a0
'-'                         shr     manB, #1 wc             ' get initial multiplier bit 
	byte	$01, $d2, $ff, $29
'-'                                     
'-' :multiply if_c          add     t1, manA wc             ' 32x32 bit multiply
	byte	$e5, $b3, $b3, $81
'-'                         rcr     t1, #1 wc
	byte	$01, $b2, $ff, $31
'-'                         rcr     manB, #1 wc
	byte	$01, $d2, $ff, $31
'-'                         djnz    t2, #:multiply
	byte	$60, $b4, $ff, $e4
'-' 
'-'                         shl     t1, #3                  ' justify result and exit
	byte	$03, $b2, $ff, $2c
'-'                         mov     manA, t1                        
	byte	$d9, $cb, $bf, $a0
'-'                         call    #_Pack 
	byte	$b0, $91, $ff, $5c
'-' _FMulI_ret
'-' _FMul_ret               ret
	byte	$00, $00, $7c, $5c
'-' 
'-' '------------------------------------------------------------------------------
'-' ' _FDiv    fnumA = fnumA / fNumB
'-' ' _FDivI   fnumA = fnumA / {Float immediate}
'-' ' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1, t2
'-' '------------------------------------------------------------------------------
'-' 
'-' _FDivI                  movs    :getB, _FDivI_ret       ' get immediate value
	byte	$7a, $d4, $bc, $50
'-'                         add     _FDivI_ret, #1
	byte	$01, $f4, $fc, $80
'-' :getB                   mov     fnumB, 0
	byte	$00, $cc, $bf, $a0
'-' 
'-' _FDiv                   call    #_Unpack2               ' unpack two variables
	byte	$86, $23, $ff, $5c
'-'           if_c_or_z     mov     fnumA, NaN              ' check for NaN or divide by 0
	byte	$cb, $c5, $bb, $a0
'-'           if_c_or_z     jmp     #_FDiv_ret
	byte	$7a, $00, $78, $5c
'-'         
'-'                         xor     flagA, flagB            ' get sign of result
	byte	$e7, $c7, $bf, $6c
'-'                         sub     expA, expB              ' subtract exponents
	byte	$e8, $c9, $bf, $84
'-'                         mov     t1, #0                  ' clear quotient
	byte	$00, $b2, $ff, $a0
'-'                         mov     t2, #30                 ' loop counter for divide
	byte	$1e, $b4, $ff, $a0
'-' 
'-' :divide                 shl     t1, #1                  ' divide the mantissas
	byte	$01, $b2, $ff, $2c
'-'                         cmps    manA, manB wz,wc
	byte	$e9, $cb, $3f, $c3
'-'           if_z_or_nc    sub     manA, manB
	byte	$e9, $cb, $af, $84
'-'           if_z_or_nc    add     t1, #1
	byte	$01, $b2, $ef, $80
'-'                         shl     manA, #1
	byte	$01, $ca, $ff, $2c
'-'                         djnz    t2, #:divide
	byte	$72, $b4, $ff, $e4
'-' 
'-'                         mov     manA, t1                ' get result and exit
	byte	$d9, $cb, $bf, $a0
'-'                         call    #_Pack                        
	byte	$b0, $91, $ff, $5c
'-' _FDivI_ret
'-' _FDiv_ret               ret
	byte	$00, $00, $7c, $5c
'-' 
'-' '------------------------------------------------------------------------------
'-' ' _FFloat  fnumA = float(fnumA)
'-' ' changes: fnumA, flagA, expA, manA
'-' '------------------------------------------------------------------------------
'-'          
'-' _FFloat                 mov     flagA, fnumA            ' get integer value
	byte	$e2, $c7, $bf, $a0
'-'                         mov     fnumA, #0               ' set initial result to zero
	byte	$00, $c4, $ff, $a0
'-'                         abs     manA, flagA wz          ' get absolute value of integer
	byte	$e3, $cb, $bf, $aa
'-'           if_z          jmp     #_FFloat_ret            ' if zero, exit
	byte	$87, $00, $68, $5c
'-'                         shr     flagA, #31              ' set sign flag
	byte	$1f, $c6, $ff, $28
'-'                         mov     expA, #31               ' set initial value for exponent
	byte	$1f, $c8, $ff, $a0
'-' :normalize              shl     manA, #1 wc             ' normalize the mantissa 
	byte	$01, $ca, $ff, $2d
'-'           if_nc         sub     expA, #1                ' adjust exponent
	byte	$01, $c8, $cf, $84
'-'           if_nc         jmp     #:normalize
	byte	$81, $00, $4c, $5c
'-'                         rcr     manA, #1                ' justify mantissa
	byte	$01, $ca, $ff, $30
'-'                         shr     manA, #2
	byte	$02, $ca, $ff, $28
'-'                         call    #_Pack                  ' pack and exit
	byte	$b0, $91, $ff, $5c
'-' _FFloat_ret             ret
	byte	$00, $00, $7c, $5c
'-' 
'-' '------------------------------------------------------------------------------
'-' ' _FTrunc  fnumA = fix(fnumA)
'-' ' _FRound  fnumA = fix(round(fnumA))
'-' ' changes: fnumA, flagA, expA, manA, t1 
'-' '------------------------------------------------------------------------------
'-' 
'-' _FTrunc                 mov     t1, #0                  ' set for no rounding
	byte	$00, $b2, $ff, $a0
'-'                         jmp     #fix
	byte	$8b, $00, $7c, $5c
'-' 
'-' _FRound                 mov     t1, #1                  ' set for rounding
	byte	$01, $b2, $ff, $a0
'-' 
'-' fix                     call    #_Unpack                ' unpack floating point value
	byte	$92, $5f, $ff, $5c
'-'           if_c          jmp     #_FRound_ret            ' check for NaN
	byte	$98, $00, $70, $5c
'-'                         shl     manA, #2                ' left justify mantissa 
	byte	$02, $ca, $ff, $2c
'-'                         mov     fnumA, #0               ' initialize result to zero
	byte	$00, $c4, $ff, $a0
'-'                         neg     expA, expA              ' adjust for exponent value
	byte	$e4, $c9, $bf, $a4
'-'                         add     expA, #30 wz
	byte	$1e, $c8, $ff, $82
'-'                         cmps    expA, #32 wc
	byte	$20, $c8, $7f, $c1
'-'           if_nc_or_z    jmp     #_FRound_ret
	byte	$98, $00, $6c, $5c
'-'                         shr     manA, expA
	byte	$e4, $cb, $bf, $28
'-'                                                        
'-'                         add     manA, t1                ' round up 1/2 lsb   
	byte	$d9, $cb, $bf, $80
'-'                         shr     manA, #1
	byte	$01, $ca, $ff, $28
'-'                         
'-'                         test    flagA, #signFlag wz     ' check sign and exit
	byte	$01, $c6, $7f, $62
'-'                         sumnz   fnumA, manA
	byte	$e5, $c5, $bf, $9c
'-' _FTrunc_ret
'-' _FRound_ret             ret
	byte	$00, $00, $7c, $5c
'-'                                   
'-' '------------------------------------------------------------------------------
'-' ' _FSqr    fnumA = sqrt(fnumA)
'-' ' changes: fnumA, flagA, expA, manA, t1, t2, t3, t4, t5 
'-' '------------------------------------------------------------------------------
'-' 
'-' _FSqr                   call    #_Unpack                 ' unpack floating point value
	byte	$92, $5f, $ff, $5c
'-'           if_nc         mov     fnumA, #0                ' set initial result to zero
	byte	$00, $c4, $cf, $a0
'-'           if_c_or_z     jmp     #_FSqr_ret               ' check for NaN or zero
	byte	$b4, $00, $78, $5c
'-'                         test    flagA, #signFlag wz      ' check for negative
	byte	$01, $c6, $7f, $62
'-'           if_nz         mov     fnumA, NaN               ' yes, then return NaN                       
	byte	$cb, $c5, $97, $a0
'-'           if_nz         jmp     #_FSqr_ret
	byte	$b4, $00, $54, $5c
'-'           
'-'                         test    expA, #1 wz             ' if even exponent, shift mantissa 
	byte	$01, $c8, $7f, $62
'-'           if_z          shr     manA, #1
	byte	$01, $ca, $eb, $28
'-'                         sar     expA, #1                ' get exponent of root
	byte	$01, $c8, $ff, $38
'-'                         mov     t1, Bit30               ' set root value to $4000_0000                ' 
	byte	$d1, $b3, $bf, $a0
'-'                         mov     t2, #31                 ' get loop counter
	byte	$1f, $b4, $ff, $a0
'-' 
'-' :sqrt                   or      fnumA, t1               ' blend partial root into result
	byte	$d9, $c5, $bf, $68
'-'                         mov     t3, #32                 ' loop counter for multiply
	byte	$20, $b6, $ff, $a0
'-'                         mov     t4, #0
	byte	$00, $b8, $ff, $a0
'-'                         mov     t5, fnumA
	byte	$e2, $bb, $bf, $a0
'-'                         shr     t5, #1 wc               ' get initial multiplier bit
	byte	$01, $ba, $ff, $29
'-'                         
'-' :multiply if_c          add     t4, fnumA wc            ' 32x32 bit multiply
	byte	$e2, $b9, $b3, $81
'-'                         rcr     t4, #1 wc
	byte	$01, $b8, $ff, $31
'-'                         rcr     t5, #1 wc
	byte	$01, $ba, $ff, $31
'-'                         djnz    t3, #:multiply
	byte	$a9, $b6, $ff, $e4
'-' 
'-'                         cmps    manA, t4 wc             ' if too large remove partial root
	byte	$dc, $cb, $3f, $c1
'-'           if_c          xor     fnumA, t1
	byte	$d9, $c5, $b3, $6c
'-'                         shr     t1, #1                  ' shift partial root
	byte	$01, $b2, $ff, $28
'-'                         djnz    t2, #:sqrt              ' continue for all bits
	byte	$a4, $b4, $ff, $e4
'-'                         
'-'                         mov     manA, fnumA             ' store new mantissa value and exit
	byte	$e2, $cb, $bf, $a0
'-'                         shr     manA, #1
	byte	$01, $ca, $ff, $28
'-'                         call    #_Pack
	byte	$b0, $91, $ff, $5c
'-' _FSqr_ret               ret
	byte	$00, $00, $7c, $5c
'-' 
'-' '------------------------------------------------------------------------------
'-' ' _FCmp    set Z and C flags for fnumA - fNumB
'-' ' _FCmpI   set Z and C flags for fnumA - {Float immediate}
'-' ' changes: status, t1
'-' '------------------------------------------------------------------------------
'-' 
'-' _FCmpI                  movs    :getB, _FCmpI_ret       ' get immediate value
	byte	$ca, $6e, $bd, $50
'-'                         add     _FCmpI_ret, #1
	byte	$01, $94, $fd, $80
'-' :getB                   mov     fnumB, 0
	byte	$00, $cc, $bf, $a0
'-' 
'-' _FCmp                   mov     t1, fnumA               ' compare signs
	byte	$e2, $b3, $bf, $a0
'-'                         xor     t1, fnumB
	byte	$e6, $b3, $bf, $6c
'-'                         and     t1, Bit31 wz
	byte	$d2, $b3, $bf, $62
'-'           if_z          jmp     #:cmp1                  ' same, then compare magnitude
	byte	$c2, $00, $68, $5c
'-'           
'-'                         mov     t1, fnumA               ' check for +0 or -0 
	byte	$e2, $b3, $bf, $a0
'-'                         or      t1, fnumB
	byte	$e6, $b3, $bf, $68
'-'                         andn    t1, Bit31 wz,wc         
	byte	$d2, $b3, $bf, $67
'-'           if_z          jmp     #:exit
	byte	$c7, $00, $68, $5c
'-'                     
'-'                         test    fnumA, Bit31 wc         ' compare signs
	byte	$d2, $c5, $3f, $61
'-'                         jmp     #:exit
	byte	$c7, $00, $7c, $5c
'-' 
'-' :cmp1                   test    fnumA, Bit31 wz         ' check signs
	byte	$d2, $c5, $3f, $62
'-'           if_nz         jmp     #:cmp2
	byte	$c6, $00, $54, $5c
'-'                         cmp     fnumA, fnumB wz,wc
	byte	$e6, $c5, $3f, $87
'-'                         jmp     #:exit
	byte	$c7, $00, $7c, $5c
'-' 
'-' :cmp2                   cmp     fnumB, fnumA wz,wc      ' reverse test if negative
	byte	$e2, $cd, $3f, $87
'-' 
'-' :exit                   mov     status, #1              ' if fnumA > fnumB, t1 = 1
	byte	$01, $c2, $ff, $a0
'-'           if_c          neg     status, status          ' if fnumA < fnumB, t1 = -1
	byte	$e1, $c3, $b3, $a4
'-'           if_z          mov     status, #0              ' if fnumA = fnumB, t1 = 0
	byte	$00, $c2, $eb, $a0
'-' _FCmpI_ret
'-' _FCmp_ret               ret
	byte	$00, $00, $7c, $5c
'-' 
'-' '------------------------------------------------------------------------------
'-' ' _Sin     fnumA = sin(fnumA)
'-' ' _Cos     fnumA = cos(fnumA)
'-' ' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB
'-' ' changes: t1, t2, t3, t4, t5, t6
'-' '------------------------------------------------------------------------------
'-' 
'-' _Cos                    call    #_FAddI                 ' cos(x) = sin(x + pi/2)
	byte	$3e, $aa, $fc, $5c
'-'                         long    pi / 2.0
	byte	$db, $0f, $c9, $3f
'-' 
'-' _Sin                    mov     t6, fnumA               ' save original angle
	byte	$e2, $bd, $bf, $a0
'-'                         call    #_FDivI                 ' reduce angle to 0 to 2pi
	byte	$68, $f4, $fc, $5c
'-'                         long    2.0 * pi
	byte	$db, $0f, $c9, $40
'-'                         call    #_FTrunc
	byte	$88, $30, $fd, $5c
'-'                         cmp     fnumA, NaN wz           ' check for NaN
	byte	$cb, $c5, $3f, $86
'-'           if_z          jmp     #_Sin_ret               
	byte	$fc, $00, $68, $5c
'-'                         call    #_FFloat
	byte	$7b, $0e, $fd, $5c
'-'                         call    #_FMulI
	byte	$56, $ce, $fc, $5c
'-'                         long    2.0 * pi
	byte	$db, $0f, $c9, $40
'-'                         mov     fnumB, fnumA
	byte	$e2, $cd, $bf, $a0
'-'                         mov     fnumA, t6
	byte	$de, $c5, $bf, $a0
'-'                         call    #_FSub
	byte	$3c, $aa, $fc, $5c
'-'                         test    fnumA, bit31 wz
	byte	$d2, $c5, $3f, $62
'-'           if_z          jmp     #:sin1
	byte	$dd, $00, $68, $5c
'-'                         call    #_FAddI
	byte	$3e, $aa, $fc, $5c
'-'                         long    2.0 * pi
	byte	$db, $0f, $c9, $40
'-' 
'-' :sin1                   call    #_FMulI                 ' convert to 13 bit integer plus fraction
	byte	$56, $ce, $fc, $5c
'-'                         long    8192.0 / (2.0 * pi)
	byte	$83, $f9, $a2, $44
'-'                         mov     t5, fnumA               ' get fraction
	byte	$e2, $bb, $bf, $a0
'-'                         call    #_Frac
	byte	$61, $d5, $fe, $5c
'-'                         mov     t4, fnumA
	byte	$e2, $b9, $bf, $a0
'-'                         mov     fnumA, t5               ' get integer
	byte	$dd, $c5, $bf, $a0
'-'                         call    #_FTrunc                        
	byte	$88, $30, $fd, $5c
'-' 
'-'                         test    fnumA, Sin_90 wc        ' set C flag for quandrant 2 or 4
	byte	$d7, $c5, $3f, $61
'-'                         test    fnumA, Sin_180 wz       ' set Z flag for quandrant 3 or 4
	byte	$d8, $c5, $3f, $62
'-'                         negc    fnumA, fnumA            ' if quandrant 2 or 4, negate offset
	byte	$e2, $c5, $bf, $b0
'-'                         or      fnumA, SineTable        ' blend in sine table address
	byte	$d6, $c5, $bf, $68
'-'                         shl     fnumA, #1               ' get table offset
	byte	$01, $c4, $ff, $2c
'-' 
'-'                         rdword  t2, fnumA               ' get first table value
	byte	$e2, $b5, $bf, $04
'-'                         negnz   t2, t2                  ' if quandrant 3 or 4, negate
	byte	$da, $b5, $bf, $bc
'-'           if_nc         add     fnumA, #2               ' get second table value  
	byte	$02, $c4, $cf, $80
'-'           if_c          sub     fnumA, #2
	byte	$02, $c4, $f3, $84
'-'                         rdword  t3, fnumA
	byte	$e2, $b7, $bf, $04
'-'                         negnz   t3, t3                  ' if quandrant 3 or 4, negate
	byte	$db, $b7, $bf, $bc
'-' 
'-'                         mov     fnumA, t2               ' result = float(value1)
	byte	$da, $c5, $bf, $a0
'-'                         call    #_FFloat
	byte	$7b, $0e, $fd, $5c
'-'                         mov     fnumB, t4 wz            ' exit if no fraction
	byte	$dc, $cd, $bf, $a2
'-'           if_z          jmp     #:sin2
	byte	$fa, $00, $68, $5c
'-' 
'-'                         mov     t5, fnumA               ' interpolate the fractional value 
	byte	$e2, $bb, $bf, $a0
'-'                         mov     fnumA, t3
	byte	$db, $c5, $bf, $a0
'-'                         sub     fnumA, t2
	byte	$da, $c5, $bf, $84
'-'                         call    #_FFloat 
	byte	$7b, $0e, $fd, $5c
'-'                         call    #_FMul
	byte	$59, $ce, $fc, $5c
'-'                         mov     fnumB, t5
	byte	$dd, $cd, $bf, $a0
'-'                         call    #_FAdd
	byte	$41, $aa, $fc, $5c
'-' 
'-' :sin2                   call    #_FDivI                 ' set range from -1.0 to 1.0 and exit
	byte	$68, $f4, $fc, $5c
'-'                         long    65535.0
	byte	$00, $ff, $7f, $47
'-' _Cos_ret
'-' _Sin_ret                ret
	byte	$00, $00, $7c, $5c
'-' 
'-' '------------------------------------------------------------------------------
'-' ' _Tan   fnumA = tan(fnumA)
'-' ' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB
'-' ' changes: t1, t2, t3, t4, t5, t6, t7, t8
'-' '------------------------------------------------------------------------------
'-' 
'-' _Tan                    mov     t7, fnumA               ' tan(x) = sin(x) / cos(x)
	byte	$e2, $bf, $bf, $a0
'-'                         call    #_Cos
	byte	$cb, $f8, $fd, $5c
'-'                         mov     t8, fnumA
	byte	$e2, $c1, $bf, $a0
'-'                         mov     fnumA, t7    
	byte	$df, $c5, $bf, $a0
'-'                         call    #_Sin
	byte	$cd, $f8, $fd, $5c
'-'                         mov     fnumB, t8
	byte	$e0, $cd, $bf, $a0
'-'                         call    #_FDiv
	byte	$6b, $f4, $fc, $5c
'-' _Tan_ret                ret
	byte	$00, $00, $7c, $5c
'-' 
'-' '------------------------------------------------------------------------------
'-' ' _Log     fnumA = log (base e) fnumA
'-' ' _Log10   fnumA = log (base 10) fnumA
'-' ' _Log2    fnumA = log (base 2) fnumA
'-' ' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1, t2, t3, t5
'-' '------------------------------------------------------------------------------
'-' 
'-' _Log                    call    #_Log2                  ' log base e
	byte	$0d, $3f, $fe, $5c
'-'                         call    #_FDivI
	byte	$68, $f4, $fc, $5c
'-'                         long    1.442695041
	byte	$3b, $aa, $b8, $3f
'-' _Log_ret                ret
	byte	$00, $00, $7c, $5c
'-' 
'-' _Log10                  call    #_Log2                  ' log base 10
	byte	$0d, $3f, $fe, $5c
'-'                         call    #_FDivI
	byte	$68, $f4, $fc, $5c
'-'                         long    3.321928095
	byte	$78, $9a, $54, $40
'-' _Log10_ret              ret
	byte	$00, $00, $7c, $5c
'-' 
'-' _Log2                   call    #_Unpack                ' unpack variable 
	byte	$92, $5f, $ff, $5c
'-'           if_z_or_c     jmp     #:exitNaN               ' if NaN or <= 0, return NaN   
	byte	$1e, $01, $78, $5c
'-'                         test    flagA, #SignFlag wz              
	byte	$01, $c6, $7f, $62
'-'           if_nz         jmp     #:exitNaN
	byte	$1e, $01, $54, $5c
'-'                       
'-'                         mov     t5, expA                ' save exponent                                                
	byte	$e4, $bb, $bf, $a0
'-'                         mov     t1, manA                ' get first 11 bits of fraction
	byte	$e5, $b3, $bf, $a0
'-'                         shr     t1, #17                 ' get table offset
	byte	$11, $b2, $ff, $28
'-'                         and     t1, TableMask
	byte	$d5, $b3, $bf, $60
'-'                         add     t1, LogTable            ' get table address
	byte	$d3, $b3, $bf, $80
'-'                         call    #float18Bits            ' remainder = lower 18 bits 
	byte	$7e, $0b, $ff, $5c
'-'                         mov     t2, fnumA
	byte	$e2, $b5, $bf, $a0
'-'                         call    #loadTable              ' get fraction from log table
	byte	$6b, $fb, $fe, $5c
'-'                         mov     fnumB, fnumA
	byte	$e2, $cd, $bf, $a0
'-'                         mov     fnumA, t5               ' convert exponent to float         
	byte	$dd, $c5, $bf, $a0
'-'                         call    #_FFloat
	byte	$7b, $0e, $fd, $5c
'-'                         call    #_FAdd                  ' result = exponent + fraction                               
	byte	$41, $aa, $fc, $5c
'-'                         jmp     #_Log2_ret
	byte	$1f, $01, $7c, $5c
'-' 
'-' :exitNaN                mov     fnumA, NaN              ' return NaN
	byte	$cb, $c5, $bf, $a0
'-' 
'-' _Log2_ret               ret
	byte	$00, $00, $7c, $5c
'-' 
'-' '------------------------------------------------------------------------------
'-' ' _Exp     fnumA = e ** fnumA
'-' ' _Exp10   fnumA = 10 ** fnumA
'-' ' _Exp2    fnumA = 2 ** fnumA
'-' ' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB
'-' ' changes: t1, t2, t3, t4, t5
'-' '------------------------------------------------------------------------------
'-' 
'-' _Exp                    call    #_FMulI                 ' e ** fnum
	byte	$56, $ce, $fc, $5c
'-'                         long    1.442695041
	byte	$3b, $aa, $b8, $3f
'-'                         jmp     #_Exp2
	byte	$25, $01, $7c, $5c
'-' 
'-' _Exp10                  call    #_FMulI                 ' 10 ** fnum
	byte	$56, $ce, $fc, $5c
'-'                         long    3.321928095
	byte	$78, $9a, $54, $40
'-' 
'-' _Exp2                   call    #_Unpack                ' unpack variable                    
	byte	$92, $5f, $ff, $5c
'-'           if_c          jmp     #_Exp2_ret              ' check for NaN
	byte	$42, $01, $70, $5c
'-'           if_z          mov     fnumA, One              ' if 0, return 1.0
	byte	$ca, $c5, $ab, $a0
'-'           if_z          jmp     #_Exp2_ret
	byte	$42, $01, $68, $5c
'-'                         mov     t5, fnumA               ' save sign value
	byte	$e2, $bb, $bf, $a0
'-'                         call    #_FTrunc                ' get positive integer
	byte	$88, $30, $fd, $5c
'-'                         abs     t4, fnumA
	byte	$e2, $b9, $bf, $a8
'-'                         mov     fnumA, t5
	byte	$dd, $c5, $bf, $a0
'-'                         call    #_Frac                  ' get fraction
	byte	$61, $d5, $fe, $5c
'-'                         call    #_Unpack
	byte	$92, $5f, $ff, $5c
'-'                         neg     expA, expA              ' get first 11 bits of fraction
	byte	$e4, $c9, $bf, $a4
'-'                         shr     manA, expA
	byte	$e4, $cb, $bf, $28
'-'                         mov     t1, manA                ' 
	byte	$e5, $b3, $bf, $a0
'-'                         shr     t1, #17                 ' get table offset
	byte	$11, $b2, $ff, $28
'-'                         and     t1, TableMask
	byte	$d5, $b3, $bf, $60
'-'                         add     t1, AlogTable           ' get table address
	byte	$d4, $b3, $bf, $80
'-'                         call    #float18Bits            ' remainder = lower 18 bits 
	byte	$7e, $0b, $ff, $5c
'-'                         mov     t2, fnumA
	byte	$e2, $b5, $bf, $a0
'-'                         call    #loadTable              ' get fraction from log table                  
	byte	$6b, $fb, $fe, $5c
'-'                         call    #_FAddI                 ' add 1.0
	byte	$3e, $aa, $fc, $5c
'-'                         long    1.0
	byte	$00, $00, $80, $3f
'-'                         call    #_Unpack                ' align fraction
	byte	$92, $5f, $ff, $5c
'-'                         add     expA, t4                ' add integer to exponent  
	byte	$dc, $c9, $bf, $80
'-'                         call    #_Pack
	byte	$b0, $91, $ff, $5c
'-' 
'-'                         test    t5, Bit31 wz            ' check if negative
	byte	$d2, $bb, $3f, $62
'-'           if_z          jmp     #_Exp2_ret
	byte	$42, $01, $68, $5c
'-'                         mov     fnumB, fnumA            ' yes, then invert
	byte	$e2, $cd, $bf, $a0
'-'                         mov     fnumA, One
	byte	$ca, $c5, $bf, $a0
'-'                         call    #_FDiv
	byte	$6b, $f4, $fc, $5c
'-' _Exp_ret             
'-' _Exp10_ret           
'-' _Exp2_ret               ret
	byte	$00, $00, $7c, $5c
'-' 
'-' '------------------------------------------------------------------------------
'-' ' _Pow     fnumA = fnumA raised to power fnumB
'-' ' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB
'-' '          t1, t2, t3, t5, t6, t7
'-' '------------------------------------------------------------------------------
'-' 
'-' _Pow                    test    fnumB, NaN wz           ' check exponent
	byte	$cb, $cd, $3f, $62
'-'           if_z          mov     fnumA, One              ' if exponent=0, set base to 1.0
	byte	$ca, $c5, $ab, $a0
'-'           
'-'                         mov     t7, fnumA wc            ' save sign of result
	byte	$e2, $bf, $bf, $a1
'-'           if_nc         jmp     #:pow3                  ' check sign of base
	byte	$55, $01, $4c, $5c
'-'                         
'-'                         mov     fnumA, fnumB            ' check exponent
	byte	$e6, $c5, $bf, $a0
'-'                         call    #_Unpack
	byte	$92, $5f, $ff, $5c
'-'                         mov     fnumA, t7               ' restore base
	byte	$df, $c5, $bf, $a0
'-'           if_z          jmp     #:pow2                  ' check for exponent = 0
	byte	$53, $01, $68, $5c
'-'           
'-'                         test    expA, Bit31 wz          ' if exponent < 0, return NaN
	byte	$d2, $c9, $3f, $62
'-'           if_nz         jmp     #:pow1
	byte	$51, $01, $54, $5c
'-' 
'-'                         max     expA, #23               ' check if exponent = integer
	byte	$17, $c8, $ff, $4c
'-'                         shl     manA, expA    
	byte	$e4, $cb, $bf, $2c
'-'                         and     manA, Mask29 wz, nr                         
	byte	$ce, $cb, $3f, $62
'-'           if_z          jmp     #:pow2                  ' yes, then check if odd
	byte	$53, $01, $68, $5c
'-'           
'-' :pow1                   mov     fnumA, NaN              ' return NaN
	byte	$cb, $c5, $bf, $a0
'-'                         jmp     #_Pow_ret
	byte	$60, $01, $7c, $5c
'-' 
'-' :pow2                   test    manA, Bit29 wz          ' if odd, then negate result
	byte	$d0, $cb, $3f, $62
'-'           if_z          andn    t7, Bit31
	byte	$d2, $bf, $ab, $64
'-' 
'-' :pow3                   test    fnumB, Bit31 wc         ' check sign of exponent
	byte	$d2, $cd, $3f, $61
'-'                         andn    fnumA, Bit31 wz         ' get |fnumA|
	byte	$d2, $c5, $bf, $66
'-'           if_z_and_c    jmp     #:pow1                  ' if 0^-n, return NaN
	byte	$51, $01, $60, $5c
'-'           if_z          jmp     #_Pow_ret               ' if 0^+n, return Zero
	byte	$60, $01, $68, $5c
'-' 
'-'                         mov     t6, fnumB               ' save power
	byte	$e6, $bd, $bf, $a0
'-'                         call    #_Log2                  ' get log of base
	byte	$0d, $3f, $fe, $5c
'-'                         mov     fnumB, t6               ' multiply by power
	byte	$de, $cd, $bf, $a0
'-'                         call    #_FMul
	byte	$59, $ce, $fc, $5c
'-'                         call    #_Exp2                  ' get result      
	byte	$25, $85, $fe, $5c
'-' 
'-'                         test    t7, Bit31 wz            ' check for negative
	byte	$d2, $bf, $3f, $62
'-'           if_nz         xor     fnumA, Bit31
	byte	$d2, $c5, $97, $6c
'-' _Pow_ret                ret
	byte	$00, $00, $7c, $5c
'-' 
'-' '------------------------------------------------------------------------------
'-' ' _Frac fnumA = fractional part of fnumA
'-' ' changes: fnumA, flagA, expA, manA
'-' '------------------------------------------------------------------------------
'-' 
'-' _Frac                   call    #_Unpack                ' get fraction
	byte	$92, $5f, $ff, $5c
'-'                         test    expA, Bit31 wz          ' check for exp < 0 or NaN
	byte	$d2, $c9, $3f, $62
'-'           if_c_or_nz    jmp     #:exit
	byte	$68, $01, $74, $5c
'-'                         max     expA, #23               ' remove the integer
	byte	$17, $c8, $ff, $4c
'-'                         shl     manA, expA    
	byte	$e4, $cb, $bf, $2c
'-'                         and     manA, Mask29
	byte	$ce, $cb, $bf, $60
'-'                         mov     expA, #0                ' return fraction
	byte	$00, $c8, $ff, $a0
'-' 
'-' :exit                   call    #_Pack
	byte	$b0, $91, $ff, $5c
'-'                         andn    fnumA, Bit31
	byte	$d2, $c5, $bf, $64
'-' _Frac_ret               ret
	byte	$00, $00, $7c, $5c
'-' 
'-' '------------------------------------------------------------------------------
'-' ' input:   t1           table address (long)
'-' '          t2           remainder (float) 
'-' ' output:  fnumA        interpolated table value (float)
'-' ' changes: fnumA, flagA, expA, manA, fnumB, t1, t2, t3
'-' '------------------------------------------------------------------------------
'-' 
'-' loadTable               rdword  t3, t1                  ' t3 = first table value
	byte	$d9, $b7, $bf, $04
'-'                         cmp     t2, #0 wz               ' if remainder = 0, skip interpolation
	byte	$00, $b4, $7f, $86
'-'           if_z          mov     t1, #0
	byte	$00, $b2, $eb, $a0
'-'           if_z          jmp     #:load2
	byte	$74, $01, $68, $5c
'-' 
'-'                         add     t1, #2                  ' load second table value
	byte	$02, $b2, $ff, $80
'-'                         test    t1, TableMask wz        ' check for end of table
	byte	$d5, $b3, $3f, $62
'-'           if_z          mov     t1, Bit16               ' t1 = second table value
	byte	$cf, $b3, $ab, $a0
'-'           if_nz         rdword  t1, t1
	byte	$d9, $b3, $97, $04
'-'                         sub     t1, t3                  ' t1 = t1 - t3
	byte	$db, $b3, $bf, $84
'-' 
'-' :load2                  mov     manA, t3                ' convert t3 to float
	byte	$db, $cb, $bf, $a0
'-'                         call    #float16Bits
	byte	$80, $0b, $ff, $5c
'-'                         mov     t3, fnumA           
	byte	$e2, $b7, $bf, $a0
'-'                         mov     manA, t1                ' convert t1 to float
	byte	$d9, $cb, $bf, $a0
'-'                         call    #float16Bits
	byte	$80, $0b, $ff, $5c
'-'                         mov     fnumB, t2               ' t1 = t1 * remainder
	byte	$da, $cd, $bf, $a0
'-'                         call    #_FMul
	byte	$59, $ce, $fc, $5c
'-'                         mov     fnumB, t3               ' result = t1 + t3
	byte	$db, $cd, $bf, $a0
'-'                         call    #_FAdd
	byte	$41, $aa, $fc, $5c
'-' loadTable_ret           ret
	byte	$00, $00, $7c, $5c
'-' 
'-' float18Bits             shl     manA, #14               ' float lower 18 bits
	byte	$0e, $ca, $ff, $2c
'-'                         jmp     #floatBits
	byte	$81, $01, $7c, $5c
'-' float16Bits             shl     manA, #16               ' float lower 16 bits
	byte	$10, $ca, $ff, $2c
'-' floatBits               shr     manA, #3                ' align to bit 29
	byte	$03, $ca, $ff, $28
'-'                         mov     flagA, #0               ' convert table value to float 
	byte	$00, $c6, $ff, $a0
'-'                         mov     expA, #0
	byte	$00, $c8, $ff, $a0
'-'                         call    #_Pack                  ' pack and exit
	byte	$b0, $91, $ff, $5c
'-' float18Bits_ret
'-' float16Bits_ret
'-' floatBits_ret           ret
	byte	$00, $00, $7c, $5c
'-' 
'-' '------------------------------------------------------------------------------
'-' ' input:   fnumA        32-bit floating point value
'-' '          fnumB        32-bit floating point value 
'-' ' output:  flagA        fnumA flag bits (Nan, Infinity, Zero, Sign)
'-' '          expA         fnumA exponent (no bias)
'-' '          manA         fnumA mantissa (aligned to bit 29)
'-' '          flagB        fnumB flag bits (Nan, Infinity, Zero, Sign)
'-' '          expB         fnumB exponent (no bias)
'-' '          manB         fnumB mantissa (aligned to bit 29)
'-' '          C flag       set if fnumA or fnumB is NaN
'-' '          Z flag       set if fnumB is zero
'-' ' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1
'-' '------------------------------------------------------------------------------
'-' 
'-' _Unpack2                mov     t1, fnumA               ' save A
	byte	$e2, $b3, $bf, $a0
'-'                         mov     fnumA, fnumB            ' unpack B to A
	byte	$e6, $c5, $bf, $a0
'-'                         call    #_Unpack
	byte	$92, $5f, $ff, $5c
'-'           if_c          jmp     #_Unpack2_ret           ' check for NaN
	byte	$91, $01, $70, $5c
'-' 
'-'                         mov     fnumB, fnumA            ' save B variables
	byte	$e2, $cd, $bf, $a0
'-'                         mov     flagB, flagA
	byte	$e3, $cf, $bf, $a0
'-'                         mov     expB, expA
	byte	$e4, $d1, $bf, $a0
'-'                         mov     manB, manA
	byte	$e5, $d3, $bf, $a0
'-' 
'-'                         mov     fnumA, t1               ' unpack A
	byte	$d9, $c5, $bf, $a0
'-'                         call    #_Unpack
	byte	$92, $5f, $ff, $5c
'-'                         cmp     manB, #0 wz             ' set Z flag                      
	byte	$00, $d2, $7f, $86
'-' _Unpack2_ret            ret
	byte	$00, $00, $7c, $5c
'-' 
'-' '------------------------------------------------------------------------------
'-' ' input:   fnumA        32-bit floating point value 
'-' ' output:  flagA        fnumA flag bits (Nan, Infinity, Zero, Sign)
'-' '          expA         fnumA exponent (no bias)
'-' '          manA         fnumA mantissa (aligned to bit 29)
'-' '          C flag       set if fnumA is NaN
'-' '          Z flag       set if fnumA is zero
'-' ' changes: fnumA, flagA, expA, manA
'-' '------------------------------------------------------------------------------
'-' 
'-' _Unpack                 mov     flagA, fnumA            ' get sign
	byte	$e2, $c7, $bf, $a0
'-'                         shr     flagA, #31
	byte	$1f, $c6, $ff, $28
'-'                         mov     manA, fnumA             ' get mantissa
	byte	$e2, $cb, $bf, $a0
'-'                         and     manA, Mask23
	byte	$cd, $cb, $bf, $60
'-'                         mov     expA, fnumA             ' get exponent
	byte	$e2, $c9, $bf, $a0
'-'                         shl     expA, #1
	byte	$01, $c8, $ff, $2c
'-'                         shr     expA, #24 wz
	byte	$18, $c8, $ff, $2a
'-'           if_z          jmp     #:zeroSubnormal         ' check for zero or subnormal
	byte	$9f, $01, $68, $5c
'-'                         cmp     expA, #255 wz           ' check if finite
	byte	$ff, $c8, $7f, $86
'-'           if_nz         jmp     #:finite
	byte	$aa, $01, $54, $5c
'-'                         mov     fnumA, NaN              ' no, then return NaN
	byte	$cb, $c5, $bf, $a0
'-'                         mov     flagA, #NaNFlag
	byte	$08, $c6, $ff, $a0
'-'                         jmp     #:exit2        
	byte	$ad, $01, $7c, $5c
'-' 
'-' :zeroSubnormal          or      manA, expA wz,nr        ' check for zero
	byte	$e4, $cb, $3f, $6a
'-'           if_nz         jmp     #:subnorm
	byte	$a4, $01, $54, $5c
'-'                         or      flagA, #ZeroFlag        ' yes, then set zero flag
	byte	$02, $c6, $ff, $68
'-'                         neg     expA, #150              ' set exponent and exit
	byte	$96, $c8, $ff, $a4
'-'                         jmp     #:exit2
	byte	$ad, $01, $7c, $5c
'-'                                  
'-' :subnorm                shl     manA, #7                ' fix justification for subnormals  
	byte	$07, $ca, $ff, $2c
'-' :subnorm2               test    manA, Bit29 wz
	byte	$d0, $cb, $3f, $62
'-'           if_nz         jmp     #:exit1
	byte	$ac, $01, $54, $5c
'-'                         shl     manA, #1
	byte	$01, $ca, $ff, $2c
'-'                         sub     expA, #1
	byte	$01, $c8, $ff, $84
'-'                         jmp     #:subnorm2
	byte	$a5, $01, $7c, $5c
'-' 
'-' :finite                 shl     manA, #6                ' justify mantissa to bit 29
	byte	$06, $ca, $ff, $2c
'-'                         or      manA, Bit29             ' add leading one bit
	byte	$d0, $cb, $bf, $68
'-'                         
'-' :exit1                  sub     expA, #127              ' remove bias from exponent
	byte	$7f, $c8, $ff, $84
'-' :exit2                  test    flagA, #NaNFlag wc      ' set C flag
	byte	$08, $c6, $7f, $61
'-'                         cmp     manA, #0 wz             ' set Z flag
	byte	$00, $ca, $7f, $86
'-' _Unpack_ret             ret       
	byte	$00, $00, $7c, $5c
'-' 
'-' '------------------------------------------------------------------------------
'-' ' input:   flagA        fnumA flag bits (Nan, Infinity, Zero, Sign)
'-' '          expA         fnumA exponent (no bias)
'-' '          manA         fnumA mantissa (aligned to bit 29)
'-' ' output:  fnumA        32-bit floating point value
'-' ' changes: fnumA, flagA, expA, manA 
'-' '------------------------------------------------------------------------------
'-' 
'-' _Pack                   cmp     manA, #0 wz             ' check for zero                                        
	byte	$00, $ca, $7f, $86
'-'           if_z          mov     expA, #0
	byte	$00, $c8, $eb, $a0
'-'           if_z          jmp     #:exit1
	byte	$c3, $01, $68, $5c
'-' 
'-' :normalize              shl     manA, #1 wc             ' normalize the mantissa 
	byte	$01, $ca, $ff, $2d
'-'           if_nc         sub     expA, #1                ' adjust exponent
	byte	$01, $c8, $cf, $84
'-'           if_nc         jmp     #:normalize
	byte	$b3, $01, $4c, $5c
'-'                       
'-'                         add     expA, #2                ' adjust exponent
	byte	$02, $c8, $ff, $80
'-'                         add     manA, #$100 wc          ' round up by 1/2 lsb
	byte	$00, $cb, $ff, $81
'-'           if_c          add     expA, #1
	byte	$01, $c8, $f3, $80
'-' 
'-'                         add     expA, #127              ' add bias to exponent
	byte	$7f, $c8, $ff, $80
'-'                         mins    expA, Minus23
	byte	$cc, $c9, $bf, $40
'-'                         maxs    expA, #255
	byte	$ff, $c8, $ff, $44
'-'  
'-'                         cmps    expA, #1 wc             ' check for subnormals
	byte	$01, $c8, $7f, $c1
'-'           if_nc         jmp     #:exit1
	byte	$c3, $01, $4c, $5c
'-' 
'-' :subnormal              or      manA, #1                ' adjust mantissa
	byte	$01, $ca, $ff, $68
'-'                         ror     manA, #1
	byte	$01, $ca, $ff, $20
'-' 
'-'                         neg     expA, expA
	byte	$e4, $c9, $bf, $a4
'-'                         shr     manA, expA
	byte	$e4, $cb, $bf, $28
'-'                         mov     expA, #0                ' biased exponent = 0
	byte	$00, $c8, $ff, $a0
'-' 
'-' :exit1                  mov     fnumA, manA             ' bits 22:0 mantissa
	byte	$e5, $c5, $bf, $a0
'-'                         shr     fnumA, #9
	byte	$09, $c4, $ff, $28
'-'                         movi    fnumA, expA             ' bits 23:30 exponent
	byte	$e4, $c5, $bf, $58
'-'                         shl     flagA, #31
	byte	$1f, $c6, $ff, $2c
'-'                         or      fnumA, flagA            ' bit 31 sign            
	byte	$e3, $c5, $bf, $68
'-' _Pack_ret               ret
	byte	$00, $00, $7c, $5c
'-'         
'-' '-------------------- constant values -----------------------------------------
'-' 
'-' Zero                    long    0                       ' constants
	byte	$00, $00, $00, $00
'-' One                     long    $3F80_0000
	byte	$00, $00, $80, $3f
'-' NaN                     long    $7FFF_FFFF
	byte	$ff, $ff, $ff, $7f
'-' Minus23                 long    -23
	byte	$e9, $ff, $ff, $ff
'-' Mask23                  long    $007F_FFFF
	byte	$ff, $ff, $7f, $00
'-' Mask29                  long    $1FFF_FFFF
	byte	$ff, $ff, $ff, $1f
'-' Bit16                   long    $0001_0000
	byte	$00, $00, $01, $00
'-' Bit29                   long    $2000_0000
	byte	$00, $00, $00, $20
'-' Bit30                   long    $4000_0000
	byte	$00, $00, $00, $40
'-' Bit31                   long    $8000_0000
	byte	$00, $00, $00, $80
'-' LogTable                long    $C000
	byte	$00, $c0, $00, $00
'-' ALogTable               long    $D000
	byte	$00, $d0, $00, $00
'-' TableMask               long    $0FFE
	byte	$fe, $0f, $00, $00
'-' SineTable               long    $E000 >> 1
	byte	$00, $70, $00, $00
'-' Sin_90                  long    $0800
	byte	$00, $08, $00, $00
'-' Sin_180                 long    $1000
	byte	$00, $10, $00, $00
'-' 
'-' '-------------------- local variables -----------------------------------------
'-' 
'-' t1                      res     1                       ' temporary values
'-' t1                      res     1                       ' temporary values
'-' t2                      res     1
'-' t2                      res     1
'-' t3                      res     1
'-' t3                      res     1
'-' t4                      res     1
'-' t4                      res     1
'-' t5                      res     1
'-' t5                      res     1
'-' t6                      res     1
'-' t6                      res     1
'-' t7                      res     1
'-' t7                      res     1
'-' t8                      res     1
'-' t8                      res     1
'-' 
'-' status                  res     1                       ' last compare status
'-' status                  res     1                       ' last compare status
'-' 
'-' fnumA                   res     1                       ' floating point A value
'-' fnumA                   res     1                       ' floating point A value
'-' flagA                   res     1
'-' flagA                   res     1
'-' expA                    res     1
'-' expA                    res     1
'-' manA                    res     1
'-' manA                    res     1
'-' 
'-' fnumB                   res     1                       ' floating point B value
'-' fnumB                   res     1                       ' floating point B value
'-' flagB                   res     1
'-' flagB                   res     1
'-' expB                    res     1
'-' expB                    res     1
'-' manB                    res     1
'-' manB                    res     1
objmem
	long	0[81]
stackspace
	long	0[1]
	org	COG_BSS_START
_var01
	res	1
_var02
	res	1
_var03
	res	1
_var04
	res	1
_var05
	res	1
arg01
	res	1
arg02
	res	1
arg03
	res	1
arg04
	res	1
arg05
	res	1
local01
	res	1
local02
	res	1
local03
	res	1
local04
	res	1
local05
	res	1
local06
	res	1
local07
	res	1
local08
	res	1
local09
	res	1
muldiva_
	res	1
muldivb_
	res	1
LMM_RETREG
	res	1
LMM_FCACHE_START
	res	97
LMM_FCACHE_END
	fit	496
