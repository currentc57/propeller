'' =================================================================================================
''
''   File....... megunolink_ez_p1.spin
''   Purpose.... Provide methods and protocol similar to the Easy Nextion Arduino library for MegunoLink

''   Author..... Charles Current
''               -- based on the Easy Nextion Library for Arduino by Thanasis Seitanis

''   E-mail..... charles@charlescurrent.com
''   Started.... 16 JUN 2022
''   Updated.... 19 JUN 2022
''
'' =================================================================================================
{{
  NOTE: methods are similar to, but not identical to, those in the Arduino Easy Nextion Library
        The protocol is completely compatible with the Easy Nextion Library and will allow reuse
        of HMI code between Arduino and Propeller boards.

  NOTE: This Spin object requires the use of a custom version of FullDuplexSerial.spin called
        FullDuplexSerialAvail.spin that adds a method to return the number of bytes in
        the rx_buffer.

  Full documentation on the Arduino Easy Nextion Library and protocol, as well as examples,
        can be found at https://seithan.com/Easy-Nextion-Library/

  If you find this library useful, please consider supporting the author of the original
        Easy Nextion Library, Thanasis Seitanis at: [seithagta@gmail.com](https://paypal.me/seithan)

  Differences between the Arduino library and Spin object:
        1) The Arduino implementation automatically calls trigger functions, stored in a separate file,
           in response to Nextion commands.
                This object provides the methods cmdAvail(), getCmd(), and readByte()
                to retreave the command packets sent from the Nextion.

        2) The Arduino C++ library uses a single overloaded function writeStr() to send commands and
           update string values on the Nextion.
                This object uses separate methods sendCmd() and writeStr().

        3) A argument fifo has been added to allow a new method pushCmdArg() that can be used to
           provide a variable number of arguments to sendCmd().

        4) The the equivilent of the Arduino NextionListen() function has been named listen()
           in this implementation.

        5) This object adds a method called addWave() to create a quick and easy interface to the
           Nextion waveform add command.

        6) In this object the currentPageId and lastCurrentPageId variables can be accessed with the
           methods getCurrentPage(), getLastPage(), setCurrentPage() and setLastPage()

}}

CON
  SERIAL_MODE = %0000
  ERROR_NUM = 777777
  CR = $0A

VAR
  byte  cmd
  byte  cmd_len
  byte  cmd_avail
  byte  temp_string[16]

OBJ
  meguno        : "FullDuplexSerialAvail"               'a special version of FullDuplexSerial that provides an available method like Arduino and FullDuplexSerial
  convertNum    : "Numbers"                             'used to convert numbers to strings and back
  convertFloat  : "FloatString"
  fMath         : "FloatMath"

PUB start(rxPin, txPin, baud)                        'Must be run before using object
{{
  Must be run before using object
  Will start a new serial object in it's own cog using the pins and rate provided
}}
  meguno.start(rxPin, txPin, SERIAL_MODE, baud)
  waitcnt(clkfreq / 100 + cnt)                          'wait for serial to init
  convertNum.init

PUB writeNum(ptr_component, num)                          'send a numeric value to nextion
{{
  send a numeric value to nextion
  ptr_component should be a pointer to a string that names the object and attribute to receive the new value
  _num is the value to assign to the object.attribute

  example: nextion.writeNum(STRING("j0.val"), number)
}}
  meguno.str(STRING("{UI|SET|"))
  meguno.str(ptr_component)
  meguno.tx("=")
  meguno.dec(num)
  meguno.tx("}")
  meguno.tx(CR)


PUB writeStr(ptr_component, ptr_txt)                      'send a string value to nextion
{{
  send a string value to nextion
  ptr_component should be a pointer to a string that names the object and attribute to receive the new value
  ptr_txt should be a pointer to the string to pass to the object.attribute

  example: nextion.writeStr(STRING("t0.txt"), STRING("Text"))
}}
  meguno.str(STRING("{UI|SET|"))
  meguno.str(ptr_component)
  meguno.tx("=")
  meguno.str(ptr_txt)
  meguno.tx("}")
  meguno.tx(CR)


PUB sendCmd(ptr_command)                               'send a command to nextion
{{
  send a command to nextion
  ptr_command should be a pointer to a string containing the command to be sent

  example: nextion.sendCmd(STRING("page 0"))
}}
  meguno.str(STRING("{UI|CMD|"))
  meguno.str(ptr_command)
  meguno.tx("}")
  meguno.tx(CR)



PUB readStr(ptr_component, ptr_return) : status   'Read a string value from nextion, will return a 1 if successful or -1 on error
{{
  Read a string value from nextion, will return a 1 if successful or -1 on error
  ptr_component should be a pointer to a string naming the object and string attribute to retrieve
  ptr_return should be a pointer to a string to recieve the string

  example: nextion.readStr(STRING("t0.txt"), @txt)

  Nextion data should have the following format:
  0x70 ... (each character of the String is represented in HEX) ... 0xFF 0xFF 0xFF

  Example: For the String ab123, we will receive: 0x70 0x61 0x62 0x31 0x32 0x33 0xFF 0xFF 0xFF
}}
  status := -1
  if meguno.available
    listen                                       'make sure the incoming buffer is empty

  meguno.str(STRING("{UI|GET|"))                        'send the request
  meguno.str(ptr_component)
  meguno.tx("}")

  status := recvStr(ptr_component, ptr_return)   'revieve the string

  return

PUB readInt(ptr_component) : num | _test, _numBuff[16]   'read a numeric value from nextion, returns number value or 777777 on error
{{
  Read a numeric value from nextion, returns number value or 777777 on error
  ptr_component should be a pointer to a string naming the component and attribute containing the number to receive

  example: nextion.readNum(STRING("x0.val"))

  Nextion data should have the following format:
 '0x71 0x01 0x02 0x03 0x04 0xFF 0xFF 0xFF
 '0x01 0x02 0x03 0x04 is 4 byte 32-bit value in little endian order
 }}
  num := ERROR_NUM

  if meguno.available
    listen                                       'make sure the incoming buffer is empty

  meguno.str(STRING("{UI|GET|"))                        'send the request
  meguno.str(ptr_component)
  meguno.tx("}")

   'And now we are waiting

  _test := recvStr(ptr_component, @_numBuff)
  if (_test == -1)
    return

  'convert string to DEC
  num := convertNum.fromStr(@_numBuff, convertNum#DEC)

  return

PUB writePtDesc(ptr_component, ptr_txt)
  meguno.str(string("{PT|D|"))
  meguno.str(ptr_component)
  meguno.tx("|")
  meguno.str(ptr_txt)
  meguno.tx("}")
  meguno.tx(CR)

PUB writePtNum(ptr_component, val)
  meguno.str(string("{PT|S|"))
  meguno.str(ptr_component)
  meguno.tx("|")
  meguno.dec(val)
  meguno.tx("}")
  meguno.tx(CR)

PUB clearTplot
  meguno.str(string("{TIMEPLOT|CLEAR|}"))

PUB writeTplotSet(ptr_attrib, ptr_txt)
  meguno.str(string("{TIMEPLOT|SET|"))
  meguno.str(ptr_attrib)
  meguno.tx("=")
  meguno.str(ptr_txt)
  meguno.tx("}")
  meguno.tx(CR)

PUB writeTplotStyle(ptr_channel, color, marker, style, width)
  meguno.str(string("{TIMEPLOT|STYLE|"))
  meguno.str(ptr_channel)
  meguno.tx(":")
  meguno.tx(color)
  meguno.tx(marker)
  meguno.tx(style)
  meguno.dec(width)
  meguno.tx("}")
  meguno.tx(CR)

PUB writeTplotInt(ptr_channel, val)
  meguno.str(string("{TIMEPLOT|DATA|"))
  meguno.str(ptr_channel)
  meguno.str(string("|T|"))
  meguno.dec(val)
  meguno.tx("}")
  meguno.tx(CR)

PUB writeTplotFixed(ptr_channel, val, dec_places)
  intToFixed(val, dec_places)
  meguno.str(string("{TIMEPLOT|DATA|"))
  meguno.str(ptr_channel)
  meguno.str(string("|T|"))
  meguno.str(@temp_string)
  meguno.tx("}")
  meguno.tx(CR)

PUB writeTplotFloat(ptr_channel, val, precision)
  convertFloat.SetPrecision(precision)
  meguno.str(string("{TIMEPLOT|DATA|"))
  meguno.str(ptr_channel)
  meguno.str(string("|T|"))
  meguno.str(convertFloat.floatToString(val))
  meguno.tx("}")
  meguno.tx(CR)

PUB clearXYplot
  meguno.str(string("{XYPLOT|CLEAR|}"))

PUB writeXYplotSet(ptr_attrib, ptr_txt)
  meguno.str(string("{XYPLOT|SET|"))
  meguno.str(ptr_attrib)
  meguno.tx("=")
  meguno.str(ptr_txt)
  meguno.tx("}")
  meguno.tx(CR)

PUB writeXYplotStyle(ptr_channel, color, marker, style, width)
  meguno.str(string("{XYPLOT|STYLE|"))
  meguno.str(ptr_channel)
  meguno.tx(":")
  meguno.tx(color)
  meguno.tx(marker)
  meguno.tx(style)
  meguno.dec(width)
  meguno.tx("}")
  meguno.tx(CR)

PUB writeXYplotInt(ptr_channel, pos, val)
  meguno.str(string("{XYPLOT|DATA|"))
  meguno.str(ptr_channel)
  meguno.str(string("|T|"))
  meguno.dec(val)
  meguno.tx("}")
  meguno.tx(CR)
PUB writeXYplotFixed(ptr_channel, pos, val, places)
  intToFixed(val, places)
  meguno.str(string("{XYPLOT|DATA|"))
  meguno.str(ptr_channel)
  meguno.str(string("|T|"))
  meguno.str(@temp_string)
  meguno.tx("}")
  meguno.tx(CR)

PUB writeXYplotFloat(ptr_channel, val, precision)
  convertFloat.SetPrecision(precision)
  temp_string := convertFloat.floatToString(val)
  meguno.str(string("{XYPLOT|DATA|"))
  meguno.str(ptr_channel)
  meguno.str(string("|T|"))
  meguno.str(temp_string)
  meguno.tx("}")
  meguno.tx(CR)

PUB readByte : _char                                    'read a byte from serial buffer (for use in custom commannds)
  _char := meguno.rxTime(100)                         'if timeout (-1) return error (-1)
  return

PUB listen | _char, _time, _ms, _len, _cmdFound, _cmd      'check for incoming serial data from nextion, must be run frequently to respond to events
{{
  Check for incoming serial data from nextion, must be run frequently to respond to events

  example nextion.listen

  Uses the Easy Nextion protocol to identify commands from Nextion Events
  Advanced users can modify the custom protocol to add new group commands.
  More info on custom protocol: https://seithan.com/Easy-Nextion-Library/Custom-Protocol/ and on the documentation of the library

  ! WARNING: This method must be called repeatedly to response touch events from the Nextion.
  You can place it in the main loop of a Cog
}}
  cmd_avail := false

  if meguno.available > 2                             'Read if more then 2 bytes come (we always send more than 2 <#> <len> <cmd> <id>
    _char := meguno.rxTime(100)
    if _char == -1                                     'if timeout (-1) return error (-1)
      return

    _time := cnt
    _ms := 100

    repeat while _char <> "#"
      _char := meguno.rxTime(100)
      if _char == -1                                     'if timeout (-1) return error (-1)
        return

      if(cnt - _time) / (clkfreq / 1000) > _ms                                'time out if we don't see a start char
        return

    if _char == "#"
      _len := meguno.rxTime(100)
       if _char == -1                                     'if timeout (-1) return error (-1)
         return
    cmd_len := _len

      _cmdFound := true
      _time := cnt
      _ms := 100

      repeat while meguno.available < _len
        if(cnt - _time) / (clkfreq / 1000) > _ms                                'time out if we don't see a full packet soon timeout
          return

    _cmd := meguno.rx
                      'commands can be variable length, we pull just the first and leave the rest for main code to deal with
    cmd_avail := true
    cmd := _cmd
  return

PUB cmdAvail : _avail                                   'returns true if commands in the buffer
  _avail := cmd_avail
  cmd_avail := false
  return

PUB getCmd : _cmd                                       'returns the 1st command byte
  return cmd

PUB getCmdLen : _len                                  'returns the number of command bytes (for use in custom commands)
  return cmd_len


'' pass through to the full duplex serial object to allow transmitting messages or completely custom commands
PUB Tx(txByte)
  meguno.Tx(txByte)

PUB Str(stringPtr)
  meguno.Str(stringPtr)

PUB Dec(value)
  meguno.Dec(value)

PUB Hex(value, digits)
  meguno.Hex(value, digits)

PUB Bin(value, digits)
  meguno.Bin(value, digits)

PRI recvStr(ptr_component, ptr_return) : status | _char, _pos, _time, _ms, _end  'Read a string value from nextion, will return a 1 if successful or -1 on error
{{
  Read a string value from nextion, will return a 1 if successful or -1 on error
  ptr_component should be a pointer to a string naming the object and string attribute to retrieve

  example: nextion.recvStr(STRING("t0.txt"))

  Nextion data should have the following format:
  0x21 ... the name of the component ... (each character of the String is represented in HEX) ... 0x0A 0x0D

  Example: For the String ab123, we will receive: 0x21 0x61 0x62 0x31 0x32 0x33 0x0A 0x0D
}}
  status := -1
  _char := 0

  _time := cnt
  _ms := 400
  repeat while  meguno.available < 8                  'wait for a response (valid response has min 8 chars)
    if(cnt - _time) / (clkfreq / 1000) > _ms                                    'but not forever
      return

    ' Wait for return data

  _char := meguno.rx

  repeat while _char <> $21                         'look for the $21 signals the beginning of a valid response
    _char := meguno.rxTime(100)

    if _char == -1                                     'if timeout (-1) return error (-1)
      return

  'must have a $21 reponse code now so we setup for receiving the command
  repeat strsize(ptr_component) + 1                     'we the discard the object name and the space following
    _char := meguno.rxTime(100)
    if _char == -1                                     'if timeout (-1) return error (-1)
      return

  _pos := 0
  repeat strsize(ptr_return)                                   'clear the buffer
    byte[ptr_return + _pos] := 0
  _pos := 0
  _end := false
  _time := cnt
  _ms := 1000

  repeat until _end == true                          'start receiving the string
    _char := meguno.rxTime(100)
    if _char == -1                                     'if timeout (-1) return error (-1)
      return
    if _char == $0A                                 'end char ($0A)?
      _end := true
      _char := meguno.rxTime(100)                  'dump the $0D that follows
    else
      byte[ptr_return + _pos++] := _char
      'if _pos == strsize(ptr_return)                 'buffer full error
        'return
    if (cnt - _time) / (clkfreq / 1000) > _ms                                'time out if we don't see a end packet
      return
  return 1

PRI intToFixed(val, places) | pos, max_neg, div, ln, idx

  clearStr(@temp_string)
  pos := 1
  idx := 0
  ln := 10

  'this code adapted from FullDuplexSerial
  max_neg := val == NEGX                                    'Check for max negative
  if val < 0
    val := ||(val+max_neg)                                'If negative, make positive; adjust for max negative
    temp_string[idx] :=("-")                                             'and output sign
    idx++


  div := 1_000_000_000                                    'Initialize divisor

  repeat 10                                            'Loop for 10 digits
    if pos == (ln - (places))             'if we are one before the decimal location
      result~~                                         'flag non-zero found to start adding zeros, including leading zero

    if val => div
      temp_string[idx] := (val / div + "0" + max_neg * (div == 1)) 'If non-zero digit, output digit; adjust for max negative
      idx++
      val //= div                                       'and digit from value
      result~~                                          'flag non-zero found
    elseif result or div == 1
      temp_string[idx] := ("0")                           'If zero digit (or only digit) output it
      idx++
    div /= 10                                             'Update divisor

    if pos == (ln - (places))                            'at the decimal location
      temp_string[idx] := (".")
      idx++
    pos++

PRI clearStr(ptr_string) | x, y
  y := 0
  x := strsize(ptr_string)
  repeat x
    byte[ptr_string][y++] := 0

con { license }

{{

  Terms of Use: MIT License

  Permission is hereby granted, free of charge, to any person obtaining a copy of this
  software and associated documentation files (the "Software"), to deal in the Software
  without restriction, including without limitation the rights to use, copy, modify,
  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be included in all copies
  or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
  PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}}