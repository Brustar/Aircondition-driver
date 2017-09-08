Pack = {}

KEYBOARD_PRESS = {"02 20 10 11 00 01 00 80 4E E3","02 20 10 12 00 01 00 80 0A E3","02 20 10 13 00 01 00 80 73 32","02 20 10 14 00 01 00 80 82 E3"}
KEY_LIGHT_ON = {"02 06 10 21 00 01 1C F3","02 06 10 22 00 01 EC F3","02 06 10 23 00 01 BD 33","02 06 10 24 00 01 0C F2"}
KEY_LIGHT_OFF = {"02 06 10 21 00 00 DD 33","02 06 10 22 00 00 2D 33","02 06 10 23 00 00 7C F3","02 06 10 24 00 00 CD 32"}

function Pack:create()
    local pack = {}

    function pack.head(data)
        local _,head=string.unpack(data,"bbb>Hb")
        return head
    end

    function pack.cmd(data)
        local _,_,cmd=string.unpack(data,"bbb>Hb")
        return cmd
    end

    function pack.sceneID(data)
        local _,_,_,_,sceneID=string.unpack(data,"bbb>Hb")
        return sceneID
    end

    function pack.decode(data)
        string pattern = "bbb"
        local _,_,length=string.unpack(data,pattern)
        local devices = {}
        for i=1,length/3 do
            pattern = pattern .. ">Hb"
        end

        local params = string.unpack(data,pattern)
        for i=5,select('#', params),2 do
            local deviceID = select(i, ...)
            local state = select(i+1, ...)
            local device = {}
            device.deviceID = deviceID
            device.state = state
            table.insert(devices,device)
        end
        return devices
    end
    
    function pack.keyHex(num)
	   return tohex(KEYBOARD_PRESS[num])
    end
    
    function pack.lightonHex(num)
	   return KEY_LIGHT_ON[num]
    end
    
    function pack.lightoffHex(num)
	   return KEY_LIGHT_OFF[num]
    end
    
    function pack.broadcastHex()
	   local a,b,c,d = string.match(C4:GetControllerNetworkAddress(),"(%d+).(%d+).(%d+).(%d+)")
	   local pattern = "bbbb>H"
	   return string.pack(pattern,tonumber(a),tonumber(b),tonumber(c),tonumber(d),SERVER_PORT)
    end

    function pack.update(cmd,devices)
    	local pattern = "bbb>Hb"
    	local data = string.pack(pattern,cmd,3,deviceID,state)
    	local checksum = pack.checksum(data)
    	pattern = "bbb>Hbb"
    	return string.pack(pattern,VI_HEAD,cmd,3,deviceID,state,checksum)
    end

    function pack.updateAir(cmd,deviceID,addr)
    	local pattern = "bbbbbbbbbb"
    	local state = C4:GetVariable(deviceID, 1001)
    	local mode = C4:GetVariable(deviceID, 1002)
    	local tempture = C4:GetVariable(deviceID, 1003)
    	local speed = C4:GetVariable(deviceID, 1004)
    	local data = string.pack(pattern,VI_HEAD,cmd,addr,deviceID,1,state,mode,tempture,tempture,speed)
    	local checksum = pack.checksum(data)
    	pattern = "bbbbbbbbbbb"
    	return string.pack(pattern,VI_HEAD,cmd,addr,deviceID,1,state,mode,tempture,tempture,speed,checksum)
    end

    function pack.checksum(strPkt)
	   local cs = 0
	   string.gsub(strPkt, "(.)", function(c) cs = cs + string.byte(c) end)
	   return bit.band(cs, 0xff)
    end
    
    function pack.crc16(pmsg)
	   local crc_table = {
		   0x0000, 0xcc01, 0xd801, 0x1400,
		   0xf001, 0x3c00, 0x2800, 0xe401,
		   0xa001, 0x6c00, 0x7800, 0xb401,
		   0x5000, 0x9c01, 0x8801, 0x4400
	   }
	    local crc		= 0xffff
	    local i, temp

	    for i = 1,#pmsg do 
		    temp = string.byte(pmsg,i)
		    crc	 =  bit.bxor(crc_table[bit.band(bit.bxor(temp , crc) , 15)+1] , bit.rshift(crc , 4));
		    crc	 =  bit.bxor(crc_table[bit.band(bit.bxor(bit.rshift(temp , 4) , crc) , 15)+1] , bit.rshift(crc , 4));
	    end

	    local ret = string.format("%4x",crc):gsub("(..)(..)","%2%1")
	    return ret
    end
    
    return pack
end