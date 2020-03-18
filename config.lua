-- http://coronalabs.com/blog/2013/09/10/modernizing-the-config-lua/
-- calculate the aspect ratio of the device:
local aspectRatio = display.pixelHeight / display.pixelWidth

application = {
   content = {
      width = aspectRatio > 1.5 and 720 or math.ceil( 1280 / aspectRatio ),
      height = aspectRatio < 1.5 and 1280 or math.ceil( 720 * aspectRatio ),
      scale = "letterBox",
      fps = 30,
      audioPlayFrequency = 44100,
      imageSuffix = {
         ["@2x"] = 1.5,
         ["@4x"] = 3.0,
      },
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
