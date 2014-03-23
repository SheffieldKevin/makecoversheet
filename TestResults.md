### Test Results - GCD queues for image scaling

Scaling done using GCD queues to distribute work.

I'm running a MacBookPro9,1. That's a quad core i7 running at 2.3 GHz, 16GByte of Ram, and a 500 GByte SSD drive. Not Retina. Has a discrete and an integrated GPU. The external drive is a 1Terabyte Firewire 800 drive. Platter speed 5400 rpm.

Thumbnail: 250x141 pixels
Grid of 5x5 thumbnails
CoverSheet: 1310x810 pixels. Generic Linear RGB Colorspace. 8 bits per channel.
Movie: Quicktime 960x540, 10 minutes long.

Frame grab every 1.5 seconds. 400 frames.
Image file type created: TIFF

Running time using gcd queues and core graphics to scale frames. SSD:
21.6 seconds. 18.5 fps.

Running time using gcd queues and core image to scale frames. SSD:
21.6 seconds. 18.5 fps.

Running time using gcd queues and core graphics to scale frames. hdd:
24 seconds. 16.7 fps.

Running time using gcd queues and core image to scale frames. hdd:
23.1 seconds. 17.3 fps.

At this point looking more closely at the profile results I realized most of the time is being spent in file read and file seek operations of the movie file. Secondly that as soon as makecoversheet was being run a service called VTDecoderXPCService was being run and typically used about 120% CPU. "makecoversheet" was using only about 40 CPU time when CoreImage was used to scale and 80% when CoreGraphics was doing the scaling. At this point I realized that the issue wasn't the image scaling it was the reading and decoding of movie data from the movie file. By reducing the time between frame grabs to 0.1 seconds there was an immediate increase in speed at which frame grabs could be processed by 10%.

Jim Crate suggested that I should create more than one AVAssetImagegenerator objects which is the approach taken in the branch generateimagesasynch and usensoperation. Though I was a bit dubious about this approach, that multiple threads accessing the same file would just be problematic, this proved true for reading the movie file from the hdd but not from the SSD.

fps: Frames per second.