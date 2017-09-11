Freshair = {}

CONTROL_ADDR = "32 06"

CONTROL_ON = "01"
CONTROL_OFF = "00"

CONTROL_WRITE = "00 03"

CONTROL_HIGH = "03"
CONTROL_MIDDLE = "02"
CONTROL_LOW = "01"
CONTROL_STOP = "00"

function Freshair:create()
    local freshair = {}

    function freshair:createCMD(action)
    	local cmd = CONTROL_ADDR .. " " .. CONTROL_WRITE .." 00 " .. action
	
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
    
    return freshair
end