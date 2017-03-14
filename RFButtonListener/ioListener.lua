GPIO = 1
debounceDelay = 25
debounceAlarmId = 2

function downHandler()
     gpio.trig(GPIO, "none")
    tmr.alarm(debounceAlarmId, debounceDelay, tmr.ALARM_SINGLE, function()
        gpio.trig(GPIO, "up", upHandler)
    end)
    -- finally react to the down event

    callWebService("down")
end

function upHandler()
      gpio.trig(GPIO, "none")
    tmr.alarm(debounceAlarmId, debounceDelay, tmr.ALARM_SINGLE, function()
        gpio.trig(GPIO, "down", downHandler)
    end)
    -- finally react to the up event

    callWebService("up")
end

    
function registerIOEvent()
	print("Registering IO Events.")
      
    gpio.mode(GPIO, gpio.INT, gpio.PULLUP)
    gpio.trig(GPIO, "down", downHandler)
end






function callWebService(level)

	print("-------------------")
	print("Executing Send Data")
	print("-------------------")
					
	local makerChannelKey = "hSLKweSBrakkaagzv80YC-2S7hnvBAl-0acMt-iB3um";
	local channelEvent = "RFSwitchNotification";

	local url = "http://maker.ifttt.com/trigger/" .. channelEvent .. "/with/key/" .. makerChannelKey;
		
	print("Url: " .. url)	

    local tm = rtctime.epoch2cal(rtctime.get())
		
	local bodyRequest = "{\"value1\":" .. "\"" .. level .. "\"" ..
			",\"value3\":\"" .. tm["year"] .. "-" ..  tm["mon"] .. "\"}"


	print("Body:\r\n" .. bodyRequest)
	
	local bodyLengh = string.len(bodyRequest)
	
	local header = "Content-Type: application/json\r\n" 
    ..       "Cache-Control: no-cache" .. "\r\n"

	print("Header:\r\n" .. header)		
			
	print("-------------------")
	print("Sending Data...")
	print("-------------------")
			
	http.put(url,header,bodyRequest,
		  function(code, data)
			if (code < 0) then
				print("-------------------")
				print("HTTP request failed\r\n")
				print("-------------------")
				callWebService(timeNow)
			else
				print("-------------------")
				print("Data SENT!!")					
				print("HTTP Response Code: " .. code .. "\r\n")
				print("Response:\r\n")
				print(data)				
				print("-------------------")
			end
		  end)      
    
	print("-------------------")
	print("Web Service called... waiting for response...")
	print("-------------------")
	
end


registerIOEvent()
