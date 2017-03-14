------------------------------------------
--DATA ACQUISITION AND WEB SERVICE REQUEST

DHT_Humidity = 0
DHT_Temperature = 0
DHT_Quality = 0

DHT_PIN = 4
DHT_Attempt = 0

		
	
function getTempDHT()
	local Humidity = 0
    local HumidityDec=0
    local Temperature = 0
    local TemperatureDec=0
	local status
	
	if ( DHT_Attempt < 5 ) then
		
		DHT_Attempt = DHT_Attempt + 1
				
		status, Temperature, Humidity, TemperatureDec, HumidityDec = dht.read11(DHT_PIN)
				
		if status == dht.OK then		
			DHT_Attempt = 0
		
			--for the time being this sensor doesn't have decimals
			DHT_Temperature = Temperature
			DHT_Humidity = Humidity		
			DHT_Quality = 1
								
		elseif status == dht.ERROR_CHECKSUM then
			print( "DHT Checksum error." )
			getTempDHT()
		elseif status == dht.ERROR_TIMEOUT then
			print( "DHT timed out." )
			getTempDHT()
		end	
		
	else
		DHT_Quality = 0
	end
	
	print("DHT Temperature: " .. DHT_Temperature)
	print("DHT Humidity: " .. DHT_Humidity)
	print("DHT Quality: " .. DHT_Quality)	
end




function collectData()
    
	print("-------------------")
	print("Executing Capture Data")
	print("-------------------")
		
	local timeNow = rtctime.get()	
	timeNow = 	timeNow .. "000"
	print("Time now is " .. timeNow)
		
	getTempDHT()

	callWebService(timeNow)
	
end


function callWebService(timeNow)

	print("-------------------")
	print("Executing Send Data")
	print("-------------------")
					
	print("Data from sensors retreived... sending to the cloud...")		

	local makerChannelKey = "hSLKweSBrakkaagzv80YC-2S7hnvBAl-0acMt-iB3um";
	local channelEvent = "UpBedRoomReport";

	local url = "http://maker.ifttt.com/trigger/" .. channelEvent .. "/with/key/" .. makerChannelKey;
		
	print("Url: " .. url)	

    local tm = rtctime.epoch2cal(rtctime.get())
        
		
	local bodyRequest = "{\"value1\":" ..
		"{\"DHT_Temperature\":\"".. DHT_Temperature .. "\",\"DHT_Humidity\":\""  .. DHT_Humidity ..  "\"}" ..
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


print("Setting and starting the polling Timer...")
tmr.alarm(2, 300000, tmr.ALARM_AUTO, function() collectData() end )
--and start immediately the collection of the data!
collectData()
