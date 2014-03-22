### Test Results - GCD queues for image scaling

Scaling done using GCD queues to distribute work.

I'm running a MacBookPro9,1. That's a quad core i7 running at 2.3 GHz, 16GByte of Ram, and a 500 GByte SSD drive. Not Retina. Has a discrete and an integrated GPU.

Thumbnail: 250x141 pixels
Grid of 5x5 thumbnails
CoverSheet: 1310x810 pixels. Generic Linear RGB Colorspace. 8 bits per channel.
Movie: Quicktime 960x540, 10 minutes long.

Frame grab every 3 seconds. 200 frames.
Image file type created: TIFF

Running time using gcd queues and core graphics to scale frames:
9.9 seconds creating 8 cover sheets. 20 frames per second.

Running time using gcd queues and core image to scale frames:
10.03 seconds creating 8 cover sheets. 20 frames per second.

At this point looking more closely at the profile results I realized most of the time is being spent in file read and file seek operations of the movie file. Secondly that as soon as makecoversheet was being run a service called VTDecoderXPCService was being run and typically used about 120% CPU. "makecoversheet" was using only about 40 CPU time when CoreImage was used to scale and 80% when CoreGraphics was doing the scaling. At this point I realized that the issue wasn't the image scaling it was the reading and decoding of movie data from the movie file. By reducing the time between frame grabs to 0.1 seconds there was an immediate increase in speed at which frame grabs could be processed by 10%, 22 frames a second.

Jim Crate suggested that I should create more than one AVAssetImagegenerator objects which is the approach taken in the branch generateimagesasynch and usensoperation.

