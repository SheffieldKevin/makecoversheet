makecoversheet
=========

Demonstrates using AVFoundation to grab movie frames at times and the use of Core Image or CoreGraphics to scale movie frames down to thumbnail images which are then drawn to a coversheet. The cover sheets are then saved to a folder. The different branches are different attempts to use gcd and nsoperation queues to distribute work to improve performance.

### Uses

Objective-C, Cocoa, OS X, CoreImage, AVFoundation.

### Produced

A command line tool "makecoversheet".

### Requirements

10.9, Xcode 5.0.1.

### Thanks

Jim Crate who supplied ideas for things to try and approaches to take. Specifically creating more than one movie image generator object to get frame grabs from. [His modifications to my project are here](https://https://github.com/jcrate/makecoversheet).

### Speed tests - personal

I'm running a MacBookPro9,1. That's a quad core i7 running at 2.3 GHz, 16GByte of Ram, and a 500 GByte SSD drive. Not Retina. Has a discrete and an integrated GPU.

Apart from initial tests from makecoversheet built from the master branch (see below) the remaining tests were all done on a ten minute quicktime movie with dimensions 960x540. The CoreGraphics context into which all thumbnails ended up being drawn to is 1310x810 pixels, 8 bits per channel and with a Generic linear RGB colorspace. [Please see test results](TestResults.md)

The speed tests results below were done solely on makecoversheet built from the master branch (CoreImage for scaling the images, no queues). These tests were done for a quick and dirty look at the impact colorspace, and using integer or float values for each color components on speed and what was the impact when specifying that CoreImage should do a software render instead of rendering using the GPU.

None of these differences were significant in terms of execution time. The worst case was the CoreImage software render which slowed things down by about 6% compared to the fastest run and doubled CPU usage of makecoversheet.

Testing of makecoversheet was done using a 960x540 pixel, hour long Apple MPEG4 movie file.
I requested a frame grab every 3 seconds. This resulted in 1202 frames. The cover sheets are 1310x810 pixels in size with a grid of 5x5 thumbnails (250x141 pixels) drawn to each coversheet. This generated 48 full cover sheets, and one coversheet with 2 images. The cover sheets were saved as tiff files as I found especially in comparison to png files that this was significantly faster.

* With the colorspace pulled from the grame grabbed image, and using a RGB 8 bits per channel context the tool took 65.5 seconds to run.

* When I tried using a 32 bits per channel float linear Generic RGB colorspace the tool took 66.1 seconds to run.

* When I tried using a 8 bits per channel integer linear Generic RGB colorspace the tool took 67.1 seconds to run.

* When I tried using a 32 bits per channel float sRGB colorspace the tool took 68.5 seconds to run.

* When I tried using the software render 8 bits per channel linear Generic RGB colorspace the tool took 69.5 seconds to run.

At 67 seconds the command line tool is processing approximately 18 frames per second.

Running the tool without doing software render cpu usage was about 60%, with the software render cpu usage was about 120%.

### Where's the code:

The file main.m is mostly about configuring the command line tool. Much of it ripped from Apple sample code for avframegrabber. The function AddImageToCoverSheetContextUsingCoreImage in YVSCreateCGContext.m is where the scaling happens on the master branch, but setting up the preparation for doing that is done in the Objective C object of type YVSMakeCoverSheet which is defined and implemented in YVSMakeCoverSheet.h/.m. The command line tool uses CILanczosScaleTransform to do the image scaling. Branches other than the master branch have the scaling moved into a YVSMakeCoverSheet object.

Rather than adding more command line options than there already are, there are some hash defines at the beginning of the main.m file which you can use for setting some of the options for the tool.

### Usage Output: The following is a print usage output produced if you call the command line tool without any parameters.

	./makecoversheet
	makecoversheet - usage:
	./makecoversheet [-parameter <value> ...]
	parameters are all preceded by a -<parameterName>.  The order of the parameters is unimportant.
	 Required parameters are -source <sourcemovieFileURL> -dest <outputFolderURL>
	 Source and destination URL strings cannot contain spaces or quoted/escaped.
	 Available parameters are:
	 	-destination (or -dest) <outputFolderURL>
	 	-source <sourceMovieURL>
	 	-filetype <file type string> The file type (eg public.jpeg) for the output file.
		-times <list of times> A list of times to take framegrabs (in seconds). Has dec point, no spaces, sep by ,. Ignores invalid times.
		-number <number> The number of framegrabs to take, evenly spaced throughout the movie. Mutually exclusive with times.
		-period <period> A framegrab will be taken ever <period> number of seconds. Mutually exclusive with -period and -times.
		-basefilename The base file name which will have appended grab # and extension.
	Also available are some setup options:
		-verbose  Print more information about the execution.
		-progress  Show progress information.
		-listmetadata  Lists the metadata in the source movie before the export.  
		-listtracks  Lists the tracks in the source movie before exporting.  
	Sample export lines:
	./makecoversheet -dest ~/Pictures/temp -listmetadata -source /path/to/myTestMovie.m4v -times 1.3,5.0,7.0,12.0 -filetype public.jpeg -basefilename Image
	./makecoversheet -destination ~/Documents/temp -listtracks -source /path/to/myTestMovie.mov -period 3 -filetype public.tiff -basefilename Image
