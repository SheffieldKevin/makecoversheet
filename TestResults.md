### Test Results - GCD queues for image scaling and for creating AVAssetImageGenerator objects.

Scaling done using GCD queues to distribute work.

I'm running a MacBookPro9,1. That's a quad core i7 running at 2.3 GHz, 16GByte of Ram, and a 500 GByte SSD drive. Not Retina. Has a discrete and an integrated GPU. The external drive is a 1Terabyte Firewire 800 drive. Platter speed 5400 rpm.

Thumbnail: 250x141 pixels
Grid of 5x5 thumbnails
CoverSheet: 1310x810 pixels. Generic Linear RGB Colorspace. 8 bits per channel.
Movie: Quicktime 960x540, 10 minutes long.

Frame grab every 1.5 seconds. 400 frames. 16 cover sheets. Image file type created: TIFF

Running time using gcd queues and core graphics to scale frames SSD:
10.7 seconds. 37.4 frames per second.

Running time using gcd queues and core image to scale frames SSD:
10.9 seconds. 36.7 frames per second.

Running time using gcd queues and core graphics to scale frames hdd:
30.1 seconds. 13.3 frames per second.

Running time using gcd queues and core image to scale frames hdd:
32.1 seconds. 12.5 frames per second.

For the hdd drive there is too many different concurrent requests for data from the same file for the disk to deal with. In this example the performance of the hdd drive is about a 1/3rd of that of the SSD drive. But performance drops further if asking for 1200 frame grabs and makecoversheet regularly doesn't  finish and is locked up with 100s of threads.

Jim Crate suggested using NSOperationQueues in which you can limit the number of running concurrent threads. See the nsuseoperation branch.
