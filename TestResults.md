### Test Results - Master Branch

Scaling done using CoreImage with no queues to distribute work.

I'm running a MacBookPro9,1. That's a quad core i7 running at 2.3 GHz, 16GByte of Ram, and a 500 GByte SSD drive. Not Retina. Has a discrete and an integrated GPU. The external HDD drive is a 1Terabyte Firewire 800 drive. Platter speed 5400 rpm.

Thumbnail: 250x141 pixels
Grid of 5x5 thumbnails
CoverSheet: 1310x810 pixels. Generic Linear RGB Colorspace. 8 bits per channel.
Movie: Quicktime 960x540, 10 minutes long.

Frame grab every 1.5 seconds. 400 frames.
Image file type created: TIFF

* Running time using core image with SDD: 21.7. 20 frames per second. 18.4 fps.

* Running time using core image with external HDD: 29 seconds. 13.8 fps.

fps = frames per second.
