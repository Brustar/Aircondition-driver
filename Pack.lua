Pack = {}

KEYBOARD_PRESS = {"02 20 10 11 00 01 00 80 4E E3","02 20 10 12 00 01 00 80 0A E3","02 20 10 13 00 01 00 80 73 32","02 20 10 14 00 01 00 80 82 E3"}
KEY_LIGHT_ON = {"02 06 10 21 00 01 1C F3","02 06 10 22 00 01 EC F3","02 06 10 23 00 01 BD 33","02 06 10 24 00 01 0C F2"}
KEY_LIGHT_OFF = {"02 06 10 21 00 00 DD 33","02 06 10 22 00 00 2D 33","02 06 10 23 00 00 7C F3","02 06 10 24 00 00 CD 32"}

function Pack:create()
    local pack = {}
    
    function keyHex(num)
	   return tohex(KEYBOARD_PRESS[num])
    end
    
    function lightonHex(num)
	   return tohex(KEY_LIGHT_ON[num])
    end
    
    function lightoffHex(num)
	   return tohex(KEY_LIGHT_OFF[num])
    end
    
    function broadcastHex()
	   local a,b,c,d = string.match(C4:GetControllerNetworkAddress(),"(%d+).(%d+).(%d+).(%d+)")
	   local pattern = "bbbb>H"
	   local pack = string.pack(patten,tonumber(a),tonumber(b),tonumber(c),tonumber(d),SERVER_PORT)
	   return pack
    end
    
    return pack
end