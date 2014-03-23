### Test Results - GCD queues for image scaling and NSOperationQueues for creating AVAssetImageGenerator objects.
The max number of NSOperationQueues concurrent queues allowed to operate at the same time is set to the number of processors as returned by NSProcessInfo process count.

Scaling done using GCD queues to distribute work.

I'm running a MacBookPro9,1. That's a quad core i7 running at 2.3 GHz, 16GByte of Ram, and a 500 GByte SSD drive. Not Retina. Has a discrete and an integrated GPU. The external drive is a 1Terabyte Firewire 800 drive. Platter speed 5400 rpm.

Thumbnail: 250x141 pixels
Grid of 5x5 thumbnails
CoverSheet: 1310x810 pixels. Generic Linear RGB Colorspace. 8 bits per channel.
Movie: Quicktime 960x540, 10 minutes long.

Frame grab every 1.5 seconds. 400 frames. 16 cover sheets. Image file type created: TIFF

Running time using gcd queues and core graphics to scale frames SSD:
10.9 seconds. 36.7 frames per second.

Running time using gcd queues and core image to scale frames SSD:
10.9 seconds. 36.7 frames per second.

Running time using gcd queues and core graphics to scale frames hdd:
46.8 seconds. 8.5 frames per second.†

Running time using gcd queues and core image to scale frames hdd:
31.3 seconds. 12.8 frames per second.

For the hdd drive there is too many different concurrent requests for data from the same file for the disk to deal with. In this example the performance of the hdd drive is about a 1/3rd of that of the SSD drive. But performance drops further if asking for 1200 frame grabs and makecoversheet regularly doesn't  finish and is locked up with 100s of threads.


† The situation is worse than the numbers show. The tool makecoversheet gets stuck, only by pausing the tool and then continuing does the tool actually run to completion.
