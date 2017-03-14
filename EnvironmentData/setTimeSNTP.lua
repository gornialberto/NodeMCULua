--set timne using NTP server
print("Setting Time...")

ntpServer = 'it.pool.ntp.org'

sntp.sync(ntpServer,
  function(sec,usec,server)
    print('Time is syncronized', sec, usec, server)
	dofile("uploadData.lua")
  end,
  function()
	print('Failed to syncronize the time!')
	dofile("setTimeSNTP.lua")
  end
)
