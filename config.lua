--
-- For more information on config.lua see the Project Configuration Guide at:
-- https://docs.coronalabs.com/guide/basics/configSettings
--

application =
{
	content =
	{
		width = 720,
		height = 1280, 
		scale = "letterbox",
		fps = 60,
		
		--[[
		imageSuffix =
		{
			    ["@2x"] = 2,
			    ["@4x"] = 4,
		},
		--]]
	},
	license =
    {
        google =
        {
            key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAhcfRISDJoBAUOd4zGIMTkvZn1T65jWwd6W04I91r4xW9ujuWQFTNv8xZkRUGEaMHfvs2EpJh3M5P/pYQchBlq0J1ADhoBykRCR0RkIFDoS5RcgTb1RRJ45l2DL/Z5aSsZ57PrHCYlBfszzF5HVk0chvL0XPXm5dhZrBn6gkghUGMb+J3D5IG611MHuZttOww7D+vfVVa7k3O2kQ/k35VUntOHUtv+SKqHMWXhzNAEQTUfLPHbWWfuZ6Fb16OBZ6en9NnPJbzA9Wbr9fHOWdI8YcOyN+OzqGjlUyuTiJhQsUPIFgLKFj7WC1LKCqTRZ0KWZs5rENgVvpb3IuWBruqGwIDAQAB",
            policy = "serverManaged"
        },
    },
}
