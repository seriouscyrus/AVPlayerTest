# AVPlayerTest
AVPlayerItemVideoOutput never gets new data

Project consists of app that loads a test video into a AVPlayerViewController to show the video can load.

The single test sets up an AVPlayer with an AVPlayerItemVideoOutput, waits for the player item to be ready and checks to see 
if a new pixel buffer is available.  Fails if not, but carries on and checks for a further 10 seconds.
