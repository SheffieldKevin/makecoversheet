### Test Results - GCD queues for image scaling and block operations on a NSOperationQueue for creating AVAssetImageGenerator objects.

The significant detail about this version is that block operation are added to a NSOperationQueue and that the maximum number of block operations that can be added to the NSOperationQueue at any time is 4. Each block operation will create a AVAssetImageGenerator object which generates all the images for a single coversheet and then has those images drawn to the cover sheet on gcd queues. The limit of 4 added to the NSOperationQueue seems to get near maximum performance out of the SSD drive whilst not reducing performance for HDD drives when getting frames from the movie file.

I'm running a MacBookPro9,1. That's a quad core i7 running at 2.3 GHz, 16GByte of Ram, and a 500 GByte SSD drive. Not Retina. Has a discrete and an integrated GPU. The external drive is a 1Terabyte Firewire 800 drive. Platter speed 5400 rpm.

Thumbnail: 250x141 pixels
Grid of 5x5 thumbnails
CoverSheet: 1310x810 pixels. Generic Linear RGB Colorspace. 8 bits per channel.
Movie: Quicktime 960x540, 10 minutes long.

Frame grab every 1.5 seconds. 400 frames. 16 Cover sheets.
Image file type created: TIFF

Running time using core graphics to scale frames:
10.5 seconds. 38 frames per second.

Running time using core image to scale frames:
10.53 seconds. 38 frames per second.

Running time using core graphics when reading file from external HDD drive:
25.8 seconds. 15.5 frames per second.

Running time using core image when reading file from external HDD drive:
19.4 seconds. 20.6 frames per second.

