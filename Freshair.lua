Freshair = {}

CONTROL_READ = "01 03 9c f9 00 08"
--CONTROL_ADDR = "01 10 9D 06 00 08 10"

--CONTROL_COOL = "00 08 00 22 00 00 00 15 00 00 00 05 00 00 00 20"
--CONTROL_WIND = "00 20 00 22 00 00 00 15 00 00 00 05 00 00 00 20"
--CONTROL_HOT = "00 40 00 22 00 00 00 15 00 00 00 05 00 00 00 20"
--CONTROL_ADDR2 = "9D 06 00 08 10"

--CONTROL_ON = "00 08 00 22 00 00 00 15 00 00 00 05 00 00 00 20"
--CONTROL_OFF = "00 08 00 02 00 00 00 15 00 00 00 05 00 00 00 00"

--CONTROL_HIGH = "00 08 00 22 00 00 00 15 00 00 00 05 00 00 00 20"
--CONTROL_MIDDLE = "00 08 00 24 00 00 00 15 00 00 00 05 00 00 00 20"
--CONTROL_LOW = "00 08 00 28 00 00 00 15 00 00 00 05 00 00 00 20"
--CONTROL_AUTO = "00 08 00 21 00 00 00 15 00 00 00 05 00 00 00 20"
CONTROL_STOP = "00 08 00 02 00 00 00 15 00 00 00 05 00 00 00 00"

CONTROL_NUMBER = "01"	--设备号
--CONTROL_READ = "03"		--读
CONTROL_WRITE = "10"	--写

CONTROL_WRITE_ADDR = "9D 06"	--写地址
CONTROL_READ_ADDR = "9C F9"	--读地址
CONTROL_REGISTER = "00 08"	--寄存器个数
CONTROL_LENGTH = "10"	--长度

CONTROL_HOT = "00 40"	--制热
CONTROL_COOL = "00 08"	--制冷
CONTROL_WIND = "00 20"	--送风


CONTROL_TEMPELATE = "00 15"	--温度


CONTROL_ON = "00 20"	--开
CONTROL_OFF = "00 00"	--关

CONTROL_EMPTY = "00 00"	--空

CONTROL_HIGH = "00 22"	--高风
CONTROL_MIDDLE = "00 24"	--中风
CONTROL_LOW = "00 28"	--低风
CONTROL_AUTO = "00 21" --自动




function Freshair:create()
    local freshair = {}

    function freshair:createCMD(action)
    local cmd = CONTROL_NUMBER ..' '.. CONTROL_WRITE ..' '.. CONTROL_WRITE_ADDR ..' ' .. CONTROL_REGISTER .. ' ' .. CONTROL_LENGTH
    if (action==CONTROL_OFF) then
	   cmd = cmd .. " " .. CONTROL_WIND .. " " .. "00 08" .. " " .. CONTROL_EMPTY .. " " .. CONTROL_TEMPELATE .. " " .. "00 00 00 05 00 00" .. CONTROL_OFF 
    elseif (action==CONTROL_WIND) then
	   cmd = cmd .. " " .. CONTROL_WIND .. " " .. CONTROL_AUTO .. " " .. CONTROL_EMPTY .. " " .. CONTROL_TEMPELATE .. " " .. "00 00 00 05 00 00" .. CONTROL_ON
    elseif (action==CONTROL_ON) then
	   cmd = cmd .. " " .. CONTROL_WIND .. " " .. CONTROL_AUTO .. " " .. CONTROL_EMPTY .. " " .. CONTROL_TEMPELATE .. " " .. "00 00 00 05 00 00" .. CONTROL_ON
    else
	   cmd = cmd .. " " .. CONTROL_WIND .. " " .. action .. " " .. CONTROL_EMPTY .. " " .. CONTROL_TEMPELATE .. " " .. "00 00 00 05 00 00" .. CONTROL_ON 
    end 
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