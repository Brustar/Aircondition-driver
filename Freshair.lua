Freshair = {}

CONTROL_ADDR = "9D 07"

CONTROL_ON = "02"
CONTROL_OFF = "01"
CONTROL_AUTO = "02"
CONTROL_HIGHT = "20"
CONTROL_MIDDLE = "40"
CONTROL_LOW = "80"

READ_POWER_ADDR = "9D 00"
READ_WIND_ADDR = "9C FA"

function Freshair:create()
    local freshair = {}

    function freshair:createCMD(addr,action)
    	return addr .. " " .. action
    end
    
    function freshair:ON()
    	return self:createCMD(CONTROL_ADDR,CONTROL_ON)
    end

    function freshair:OFF()
    	return self:createCMD(CONTROL_ADDR,CONTROL_OFF)
    end

    function freshair:AUTO()
    	return self:createCMD(CONTROL_ADDR,CONTROL_AUTO)
    end

    function freshair:HIGHT()
    	return self:createCMD(CONTROL_ADDR,CONTROL_HIGHT)
    end

    function freshair:MIDDLE()
    	return self:createCMD(CONTROL_ADDR,CONTROL_MIDDLE)
    end

    function freshair:LOW()
    	return self:createCMD(CONTROL_ADDR,CONTROL_LOW)
    end
    
    return freshair
end