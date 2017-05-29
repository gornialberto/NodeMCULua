GPIO = 1

function debounce (func)
    local last = 0
    local delay = 250000

    return function (...)
        local now = tmr.now()
        local delta = now - last
        if delta < 0 then delta = delta + 2147483647 end;
        if delta < delay then return end;

        last = now
        return func(...)
    end
end

    
function registerIOEvent()
	print("Registering IO Events.")
      
    gpio.mode(GPIO, gpio.INT, gpio.PULLUP)
    gpio.trig(GPIO, "both", debounce(sendData))
end




m = mqtt.Client("OutdoorSensorClient", 120);

m:lwt("/myHome/OutdoorSensor/status", "offline", 0, 1);


m:on("connect", connected(client)) );
m:on("offline", function(client) print ("offline") end);

function connected(client)
    m:publish("/myHome/OutdoorSensor/status","online",0,1, function(client) print("Updated will to online") end);
end

function sendData()

    print("-------------------")
    print("Executing Send Data")
    print("-------------------")
                    
    local level = gpio.read(GPIO)

    local tm = rtctime.epoch2cal(rtctime.get())
		
	local bodyRequest = "{\"value1\":" .. "\"" .. level .. "\"" ..
			",\"value3\":\"" .. tm["year"] .. "-" ..  tm["mon"] .. "\"}"


    m:publish("/myHome/OutdoorSensor",bodyRequest,0,1, function(client) print("Data Sent") end)

    
	print("-------------------")
	print("Data Sent")
	print("-------------------")
    
end


registerIOEvent()
