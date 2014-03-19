makecoversheet
=========

Demonstrates using AVFoundation to grab movie frames at times and using Core Image to scale the movie frames down to thumbnail images which are then drawn to a coversheet. The cover sheets are then saved to a folder.

### Uses

Objective-C, Cocoa, OS X, CoreImage, AVFoundation.

### Produced

A command line tool "makecoversheet".

### Requirements

10.9, Xcode 5.0.1.

The following is a print usage output produced if you call the command line tool without any parameters.

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
