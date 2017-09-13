Freshair = {}

--CONTROL_ADDR = "32 06"
--CONTROL_ADDR = "01 06 9D 07 00 01 02"
CONTROL_ADDR = "01 10 9D 06 00 08 10"
--CONTROL_ON = "01"

--CONTROL_1 = "00 40"

--CONTROL_2 = "00 00 00 15 00 00 00 05 00 00 00 20"

--CONTROL_ON = "22"
CONTROL_ON = "00 08 00 22 00 00 00 15 00 00 00 05 00 00 00 20"
--CONTROL_OFF = "00"
CONTROL_OFF = "00 08 00 02 00 00 00 15 00 00 00 05 00 00 00 00"

CONTROL_WRITE = "00 03"

--CONTROL_HIGH = "22"
CONTROL_HIGH = "00 08 00 22 00 00 00 15 00 00 00 05 00 00 00 20"

--CONTROL_MIDDLE = "24"
CONTROL_MIDDLE = "00 08 00 24 00 00 00 15 00 00 00 05 00 00 00 20"
--CONTROL_LOW = "28"
CONTROL_LOW = "00 08 00 28 00 00 00 15 00 00 00 05 00 00 00 20"
--CONTROL_STOP = "00"
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
    
    return freshair
end