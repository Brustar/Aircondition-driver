require("socket")

function sleep(n)
    socket.select(nil, nil, n)
end
Visualintercom = {}

VI_HEAD = 0XAA

VI_ADDR = 0x0F

VI_CMD_AUTHOR = 0x11

VI_RES_AUTHOR = 0x12

VI_CMD_BEAT = 0x13

CMD_QUTHOR = "AA 11 01 F0 AC"
CMD_UPLOAD_STATE = "AA 13 01 F0 AE"

function Visualintercom:create()
    local visualintercom = {}

    function visualintercom:author()
        return tohex(CMD_QUTHOR)
    end

    function visualintercom:uploadState()
        return tohex(CMD_UPLOAD_STATE)
    end

    function visualintercom:lightContol(extrAddr,addr,state)
        local pack = Pack:create()
        local deviceID = pack.calcAddr(extrAddr,addr)
        print("light deviceID:",string.format("%04X",deviceID))
        if state == 0 then 
            C4:SendToDevice(deviceID,"ON",{})
        elseif state == 1 then
            C4:SendToDevice(deviceID,"OFF",{})
        elseif state>=2 and state<=11 then
            C4:SendToDevice(deviceID,"RAMP_TO_LEVEL", {LEVEL = (state-1)*10, TIME = 1000})
        end
    end 

    function visualintercom:lightFB(deviceID)

    end

    function visualintercom:curtainContol(extrAddr,addr,state)
        local pack = Pack:create()
        local deviceID = pack.calcAddr(extrAddr,addr)
        print("blind deviceID:",string.format("%04X",deviceID))
        local control = ""
        if state == 0 then 
            control = "UP"
        elseif state == 1 then
            control = "DOWN"
        elseif state == 2 then
            control = "STOP"
        end
        C4:SendToDevice(deviceID,control,{})
    end

    function visualintercom:curtainFB(deviceID)
    end

    function visualintercom:airControl(extrAddr,addr,power,mode,tempture,speed)
        local deviceID = C4:GetDeviceID()
        if power==0 then
            local m = C4:GetVariable(C4:GetDeviceID(),1001)
            if m ~= "false" then
                C4:SendToDevice(deviceID,"OFF",{addr = addr})
                C4:SetVariable("IS_ON","false")
            end
        end

        if power==1 then
            local m = C4:GetVariable(C4:GetDeviceID(),1001)
            if m ~= "true" then
                C4:SendToDevice(deviceID,"ON",{addr = addr})
                C4:SetVariable("IS_ON","true")
            end
        end

        if mode==0 then
            local m = C4:GetVariable(C4:GetDeviceID(),1002)
            if m ~= "1" then
                C4:SendToDevice(deviceID,"COOL",{addr = addr})
                C4:SetVariable("CURRENT_MODE","1")
            end
        end

        if mode==1 then
            local m = C4:GetVariable(C4:GetDeviceID(),1002)
            if m ~= "8" then
                C4:SendToDevice(deviceID,"HEAT",{addr = addr})
                C4:SetVariable("CURRENT_MODE","8")
            end
        end

        if mode==2 then
            local m = C4:GetVariable(C4:GetDeviceID(),1002)
            if m ~= "4" then
                C4:SendToDevice(deviceID,"FAN",{addr = addr})
                C4:SetVariable("CURRENT_MODE","4")
            end
        end

        if mode==3 then
            local m = C4:GetVariable(C4:GetDeviceID(),1002)
            if m ~= "2" then
                C4:SendToDevice(deviceID,"DRY",{addr = addr})
                C4:SetVariable("CURRENT_MODE","2")
            end
        end
        if tempture>=10 and tempture<=32 then
            local temp = tonumber(C4:GetVariable(C4:GetDeviceID(),1008))
            if temp ~= tempture then
                C4:SendToDevice(deviceID,"SETEMP",{addr = addr,degree = tempture})
                C4:SetVariable("SETTING_TEMPRETURE",tostring(tempture))
            end
        end

        if speed==0 then
            local m = C4:GetVariable(C4:GetDeviceID(),1004)
            if m ~= "4" then
                C4:SendToDevice(deviceID,"LOW",{addr = addr})
                C4:SetVariable("CURRENT_SPEED","4")
            end
        end

        if speed==1 then
            local m = C4:GetVariable(C4:GetDeviceID(),1004)
            if m ~= "2" then
                C4:SendToDevice(deviceID,"MIDDLE",{addr = addr})
                C4:SetVariable("CURRENT_SPEED","2")
            end
        end

        if speed==2 then
            local m = C4:GetVariable(C4:GetDeviceID(),1004)
            if m ~= "1" then
                C4:SendToDevice(deviceID,"HIGH",{addr = addr})
                C4:SetVariable("CURRENT_SPEED","1")
            end
        end

    end

    function visualintercom:airFB(deviceID)
    end
    
    function visualintercom:freshControl(extrAddr,addr,action,value)
	   local deviceID =  C4:GetDeviceID()
       if action == 0x00 then
        if value == 0x00 then
            C4:SendToDevice(deviceID,"FRESH_ON",{})
        end
        if value == 0x01 then
            C4:SendToDevice(deviceID,"FRESH_OFF",{})
        end
       end

       if action == 0x06 then
        if value == 0x01 then
            C4:SendToDevice(deviceID,"FRESH_LOW",{})
        end
        if value == 0x02 then
            C4:SendToDevice(deviceID,"FRESH_MIDDLE",{})
        end
        if value == 0x03 then
            C4:SendToDevice(deviceID,"FRESH_HIGH",{})
        end
       end


    end

    function visualintercom:sceneControl(sceneID)
	   print("scene:",sceneID)
        C4:SetVariable("SCENE_ID", tostring(sceneID))
        C4:FireEvent("scene event")
    end
    
    return visualintercom
end