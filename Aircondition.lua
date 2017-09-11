require "Pack"

Aircondition = {}

AIR = {}

AIR["ON"] = "31 01"
AIR["OFF"] = "31 02"

AIR["QUERY"] = "50 01"
AIR["SETEMP"] = "32"
AIR["HEAT"] = "33 08"
AIR["COOL"] = "33 01"

AIR["DRY"] = "33 02"
AIR["FAN"] = "33 04"

AIR["HIGH"] = "34 01"
AIR["MIDDLE"] = "34 02"
AIR["LOW"] = "34 04"
AIR["QUERY_ALL"] = "01 50 FF FF FF FF 52"
AIR["AWAY"] = "01 31 02 FF FF FF 31"


function Aircondition:create(addr)
    local aircondition = {}
    aircondition.addr = addr
    
    function aircondition:createCMD(cmd,value)
	   local ret = Properties["Gateway"]
	   if value == nil then
		  ret = ret .. " " .. cmd
	   else
		  ret = ret .. " " .. cmd .. " " .. value
	   end

	   ret = ret .. " 01 " .. self.addr
        local pack = Pack:create()
	   local sum = pack.checksum(tohex(ret))
	   local cs = string.sub(string.format("%#x",sum),3)
	   ret = ret .. " " .. cs

	   return ret
    end

    function aircondition:SETEMP(value)
        C4:SetVariable("CURRENT_TEMPRETURE", value)
	   return self:createCMD(AIR["SETEMP"],string.format("%2X",value))
    end

    function aircondition:HEAT()
        C4:SetVariable("CURRENT_MODE", 1)
	    return self:createCMD(AIR["HEAT"])
    end

    function aircondition:COOL()
        C4:SetVariable("CURRENT_MODE", 0)
	   return self:createCMD(AIR["COOL"])
    end

    function aircondition:DRY()
        C4:SetVariable("CURRENT_MODE", 3)
	   return self:createCMD(AIR["DRY"])
    end

    function aircondition:FAN()
        C4:SetVariable("CURRENT_MODE", 2)
	   return self:createCMD(AIR["FAN"])
    end

    function aircondition:HIGH()
        C4:SetVariable("CURRENT_SPEED", 2)
	   return self:createCMD(AIR["HIGH"])
    end

    function aircondition:MIDDLE()
        C4:SetVariable("CURRENT_SPEED", 1)
	   return self:createCMD(AIR["MIDDLE"])
    end

    function aircondition:LOW()
        C4:SetVariable("CURRENT_SPEED", 0)
	   return self:createCMD(AIR["LOW"])
    end

    function aircondition:QUERY()
	   return self:createCMD(AIR["QUERY"])
    end

    function aircondition:ON()
	   C4:SetVariable("IS_ON", "1", "BOOL")
	   return self:createCMD(AIR["ON"])
    end

    function aircondition:OFF()
	   C4:SetVariable("IS_ON", "0", "BOOL")
	   return self:createCMD(AIR["OFF"])
    end
    
    function aircondition:AWAY()
	   return AIR["AWAY"]
    end
    
    function aircondition:QUERY_ALL()
	   return AIR["QUERY_ALL"]
    end

    function aircondition:EIGHTEEN()
        return self:SETEMP(18)
    end

    function aircondition:TWENTY_TWO()
        return self:SETEMP(22)
    end

    function aircondition:TWENTY_SIX()
        return self:SETEMP(26)
    end

    function aircondition:THIRTY()
        return self:SETEMP(30)
    end
    
    return aircondition
end