{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        TX = 30
        RX = 31
        LED = 16
        CR = $0A

VAR
  long  f_y
  long  f_y2
  long  f_seconds
  long  f_frequency
  long  f_phase

OBJ
  meguno      : "megunolink_ez"
  f           : "Float32"
  fstr        : "FloatString"

PUB main | ms, last_cnt, current_cnt, f_tpi, f_rot, temp

  meguno.start(RX, TX, 115_200)
  f.start

  ms := 0

  ' Create some data to send. Here, a value from sine and cosine curves.
  f_frequency := 0.5
  f_phase := f.fdiv(3.141, 2.0)
  f_tPi := f.fMul(2.0, 3.141)
  f_rot := f.fMul(f_tPi, f_frequency)

  meguno.TimePlotSet(string("title"), string("Sine and Cosine Waveforms"))
  meguno.timePlotSet(string("x-label"), string("Time"))
  meguno.timePlotSet(string("y-label"), string("Amplitude"))

  meguno.timePlotStyle(string("Sinewave"), "b", "s", "_", 2)
  meguno.timePlotStyle(string("Cosinewave"), "r", "d", ";", 2)

  last_cnt := cnt
  'ms := (clkfreq / 1000 )+ last_cnt                             'ms counter

  repeat
    meguno.listen               ' WARNING: This function must be called repeatedly to response touch events
                                ' from Nextion touch panel. Actually, you should place it in your loop function.
    current_cnt := cnt
    ms += (current_cnt - last_cnt) / (clkfreq / 1000 )
    last_cnt := current_cnt

    f_seconds := f.fDiv(f.FFloat(ms), f.FFloat(1000))

    'Send Data To MegunoLink.
    f_y :=  f.sin(f.fMul(f_rot, f_seconds))
            'sin(2 * 3.141 * f_frequency * f_seconds)
    f_y2 := f.cos(f.fAdd(f.fMul(f_rot, f_seconds), f_phase))
            'cos(2 * 3.141 * f_frequency * f_seconds + f_phase)

    'data can be sent as integers
      'temp := f.ftrunc(f_y)
      'meguno.timePlotInt(string("Sinewave"), temp)
    'or fixed point
    temp := f.ftrunc(f.fMul(f_y, 100.0))
    meguno.timePlotFixed(string("Sinewave"), temp, 2)
    'or floating point
    meguno.timePlotFloat(string("Cosinewave"), f_y2, 2)


    waitcnt(clkfreq / 100 + cnt)                       'delay so we don't overwhelm the serial channel

