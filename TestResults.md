### Test Results - GCD queues for image scaling and for creating AVAssetImageGenerator objects.

Scaling done using GCD queues to distribute work.

I'm running a MacBookPro9,1. That's a quad core i7 running at 2.3 GHz, 16GByte of Ram, and a 500 GByte SSD drive. Not Retina. Has a discrete and an integrated GPU.

Thumbnail: 250x141 pixels
Grid of 5x5 thumbnails
CoverSheet: 1310x810 pixels. Generic Linear RGB Colorspace. 8 bits per channel.
Movie: Quicktime 960x540, 10 minutes long.

Frame grab every 3 seconds. 200 frames.
Image file type created: TIFF

Running time using gcd queues and core graphics to scale frames:
5.5 seconds creating 8 cover sheets. 37 frames per second.

Running time using gcd queues and core image to scale frames:
5.8 seconds creating 8 cover sheets. 34.5 frames per second.

This does not work when the movie file is on a HDD drive. I'm also creating too many threads which I'm sure actually slows the process down. Jim Create suggested using NSOperationQueues in which you can limit the number of running concurrent threads. See the nsuseoperation branch.
