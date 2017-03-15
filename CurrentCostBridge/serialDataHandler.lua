function registerSerialHandling()

	uart.alt(1)

	-- configure for 57600 , 8N1, with no echo
	uart.setup(0, 57600 , 8, uart.PARITY_NONE, uart.STOPBITS_1, 0)

	uart.on("data", 200, uartDataReceived, 0)

end

function uartDataReceived(data)
	
	callWebService(data)

end



function callWebService(data)

	print("-------------------")
	print("Executing Send Data")
	print("-------------------")
					
	local makerChannelKey = "hSLKweSBrakkaagzv80YC-2S7hnvBAl-0acMt-iB3um";
	local channelEvent = "RFSwitchNotification";

	local url = "http://maker.ifttt.com/trigger/" .. channelEvent .. "/with/key/" .. makerChannelKey;
		
	print("Url: " .. url)	

    local tm = rtctime.epoch2cal(rtctime.get())
		
	local bodyRequest = "{\"value1\":" .. "\"" .. data .. "\"" ..
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


registerSerialHandling()
