CON  _CLKMODE = XTAL1 + PLL16X  _XINFREQ = 5_000_000OBJ                           BS2 : "BS2_Functions"  RC4 : "RC4"PUB go | RC4_Value[255]   BS2.start (31, 30, 4800, 1)           ' Initialize BS2 Object, Rx and Tx pins for DEBUG  BS2.Debug_Str ( String(13) )      RC4_Value := RC4.Cryptography(string("Expression"), string("Password"))  BS2.Debug_Str ( String("Encoded: ") )    BS2.Debug_Str ( RC4_Value )  BS2.Debug_Str ( string(13) )    RC4_Value := RC4.Cryptography(RC4_Value, string("Password"))  BS2.Debug_Str ( String("Decoded: ") )  BS2.Debug_Str ( RC4_Value )  BS2.Debug_Str ( string(13) )    