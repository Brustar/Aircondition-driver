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

    function visualintercom:lightContol(deviceID,state)
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

    function visualintercom:curtainContol(deviceID,state)
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

    function visualintercom:airControl(deviceID,power,mode,tempture,speed)
	   print(deviceID,power,mode,tempture,speed)
        if power==0 then
            C4:SendToDevice(deviceID,"OFF",{})
        end

        if power==1 then
            C4:SendToDevice(deviceID,"ON",{})
        end

        if mode==0 then
            C4:SendToDevice(deviceID,"COOL",{})
        end

        if mode==1 then
            C4:SendToDevice(deviceID,"HEAT",{})
        end

        if mode==2 then
            C4:SendToDevice(deviceID,"FAN",{})
        end

        if mode==3 then
            C4:SendToDevice(deviceID,"DRY",{})
        end

        if tempture>=20 and tempture<=60 then
            C4:SendToDevice(deviceID,"SETEMP",{degree = math.floor(tempture/2)})
        end

        if speed==0 then
            C4:SendToDevice(deviceID,"LOW",{})
        end

        if speed==1 then
            C4:SendToDevice(deviceID,"MIDDLE",{})
        end

        if speed==2 then
            C4:SendToDevice(deviceID,"HIGH",{})
        end

    end

    function visualintercom:airFB(deviceID)
    end
    
    function visualintercom:freshControl()
	   
    end

    function visualintercom:sceneControl(sceneID)
        C4:SetVariable("SCENE_ID", tostring(pack.deviceID))
        C4:FireEvent("scene event")
    end
    
    return visualintercom
end