Freshair = {}

CONTROL_NUMBER = "01"
--CONTROL_READ = "03"
CONTROL_READ = "01 03 9c f9 00 08"
CONTROL_WRITE = "10"
CONTROL_ADDR = "01 10 9D 06 00 08 10"
--CONTROL_ADDR2 = "9D 06 00 08 10"
CONTROL_JCQ = "00 08"
CONTROL_LENGTH = "10"

--CONTROL_HOT = "00 40"
--CONTROL_COOL = "00 08"
CONTROL_COOL = "00 08 00 22 00 00 00 15 00 00 00 05 00 00 00 20"
CONTROL_WIND = "00 20 00 22 00 00 00 15 00 00 00 05 00 00 00 20"
CONTROL_HOT = "00 40 00 22 00 00 00 15 00 00 00 05 00 00 00 20"

CONTROL_TEMPELATE = "00 15"


CONTROL_ON = "00 08 00 22 00 00 00 15 00 00 00 05 00 00 00 20"
CONTROL_OFF = "00 08 00 02 00 00 00 15 00 00 00 05 00 00 00 00"
CONTROL_ON1 = "00 20"
CONTROL_OFF1 = "00 00"

CONTROL_EMPTY = "00 00"

CONTROL_HIGH = "00 08 00 22 00 00 00 15 00 00 00 05 00 00 00 20"
CONTROL_MIDDLE = "00 08 00 24 00 00 00 15 00 00 00 05 00 00 00 20"
CONTROL_LOW = "00 08 00 28 00 00 00 15 00 00 00 05 00 00 00 20"
CONTROL_AUTO = "00 08 00 21 00 00 00 15 00 00 00 05 00 00 00 20"
CONTROL_STOP = "00 08 00 02 00 00 00 15 00 00 00 05 00 00 00 00"


function Freshair:create()
    local freshair = {}

    function freshair:createCMD(action)
    	--local cmd = CONTROL_ADDR .. " " .. CONTROL_WRITE .." 00 " .. action
    
	local cmd = CONTROL_ADDR .. " "..action
	local pack = Pack:create()
	cmd = cmd .. " " .. pack.crc16(tohex(cmd))

	return cmd
    end
    
    function freshair:ON()
    	return self:createCMD(CONTROL_ON)
    end

    function freshair:OFF()
    	return self:createCMD(CONTROL_OFF)
    end


    function freshair:HIGH()
    	return self:createCMD(CONTROL_HIGH)
    end

    function freshair:MIDDLE()
    	return self:createCMD(CONTROL_MIDDLE)
    end

    function freshair:LOW()
    	return self:createCMD(CONTROL_LOW)
    end
    
    function freshair:STOP()
    	return self:createCMD(CONTROL_STOP)
    end
    
    function freshair:READ()
    	 local cmd = CONTROL_READ
	 local pack = Pack:create()
	 cmd = cmd .. " " .. pack.crc16(tohex(cmd))

	 return cmd
    end
    
    function freshair:WIND()
    	 return self:createCMD(CONTROL_WIND)
    end
    
    function freshair:HOT()
    	 return self:createCMD(CONTROL_HOT)
    end
    
    function freshair:AUTO()
    	 return self:createCMD(CONTROL_AUTO)
    end
    
    function freshair:SETEMP(value)
        C4:SetVariable("CURRENT_TEMPRETURE", value)
    end
    
    return freshair
end