//
//  main.m
//  makecoversheet
// Large chunks of this source lifted from Apple's avexporter example.
//

@import Foundation;
@import AVFoundation;

#import "YVSMakeCoverSheet.h"

// ---------------------------------------------------------------------------
//		CONSTANTS
// ---------------------------------------------------------------------------

#define NUM_COLS 5
#define NUM_ROWS 5
#define BORDER_SIZE 10 // IN PIXELS.
#define THUMBNAIL_WIDTH 250
#define THUMBNAIL_HEIGHT 150
#define BACKGROUND_RED 0.2
#define BACKGROUND_GREEN 0.2
#define BACKGROUND_BLUE 0.7

#define COREIMAGE_SOFTWARERENDER __objc_no

// ---------------------------------------------------------------------------
//		P R O T O T Y P E S
// ---------------------------------------------------------------------------

static void printNSString(NSString *string);
static void printArgs(int argc, const char **argv);

typedef enum { kSpecifyTimes, kSpecifyNumber, kSpecifyPeriod } FrameGrabTimesType;

#pragma mark -
#pragma mark AVFrameGrab Interface

// ---------------------------------------------------------------------------
//		AVFrameGrab Class Interface
// ---------------------------------------------------------------------------

@interface AVFrameGrab : NSObject

@property (strong) NSString	*programName;
@property (strong) NSString	*exportImageFileType;
@property (strong) NSString	*sourcePath;
@property (strong) NSString	*destinationPath;
@property (strong) NSString *baseFileName;
@property (strong) NSString *times;
@property (strong) NSNumber	*progress;
// @property (assign) NSInteger imageNumber;
@property (assign) BOOL		verbose;
@property (assign) BOOL		showProgress;
@property (assign) BOOL		frameGrabFailed;
@property (assign) BOOL		frameGrabComplete;
@property (assign) BOOL		listTracks;
@property (assign) BOOL		listMetadata;
@property (assign) FrameGrabTimesType frameGrabTimeType;

// @property (assign) BOOL		removePreExistingFiles;

- (id)initWithArgs: (int) argc  argv: (const char **) argv environ: (const char **) environ;
- (void)printUsage;

- (NSArray *)createTimesFromSpecifiedTimes:(AVAsset *)urlAsset;
- (NSArray *)createTimesFromNumberOfTimes:(AVAsset *)urlAsset;
- (NSArray *)createTimesFromPeriod:(AVAsset *)urlAsset;
- (NSArray *)createListOfTimes:(AVAsset *)urlAsset;
- (int)run;

- (void) doListTracks:(NSString *)assetPath;
- (void) doListMetadata:(NSString *)assetPath;

@end


// ---------------------------------------------------------------------------
//		AVFrameGrab Class Implementation
// ---------------------------------------------------------------------------

@implementation AVFrameGrab

-(id) initWithArgs: (int) argc  argv: (const char **) argv environ: (const char **) environ
{
	self = [super init];
	if (self == nil)
	{
		return nil;
	}
    
	printArgs(argc,argv);
	
	BOOL gotsource = NO;
	BOOL gotout = NO;
	BOOL parseOK = NO;
	BOOL gotBaseFileName = NO;
	BOOL gotExportFileType = NO;
	BOOL gotTimes = NO;
    
	[self setProgramName:@(*argv++)];
	argc--;
	while ( argc > 0 && **argv == '-' )
	{
		const char*	args = &(*argv)[1];
		
		argc--;
		argv++;
		
		if ( ! strcmp ( args, "source" ) )
		{
			[self setSourcePath: [@(*argv++) stringByExpandingTildeInPath] ];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:self.sourcePath])
            {
                gotsource = YES;
            }
            else
            {
                printNSString([NSString stringWithFormat:
                               @"Invalid source file path: %@\n", self.sourcePath]);
            }
			argc--;
		}
		else if (( ! strcmp ( args, "dest" )) || ( ! strcmp ( args, "destination" )) )
		{
			NSString *expandedPath = [@(*argv++) stringByExpandingTildeInPath];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError * __autoreleasing error = nil;
            // Just assume creation of directories works. Don't check result.
            [fileManager createDirectoryAtPath:expandedPath
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:&error];
			[self setDestinationPath:expandedPath];
			gotout = YES;
			argc--;
		}
		else if (!strcmp(args, "filetype"))
		{
			[self setExportImageFileType:@(*argv++)];
			gotExportFileType = YES;
			argc--;
		}
		else if (!strcmp(args, "basefilename"))
		{
			[self setBaseFileName:@(*argv++)];
			gotBaseFileName = YES;
			argc--;
		}
		else if (!strcmp(args, "times"))
		{
			[self setTimes:@(*argv++)];
			[self setFrameGrabTimeType:kSpecifyTimes];
			gotTimes = YES;
			argc--;
		}
		else if (!strcmp(args, "number"))
		{
			[self setTimes:@(*argv++)];
			[self setFrameGrabTimeType:kSpecifyNumber];
			gotTimes = YES;
			argc--;
		}
		else if (!strcmp(args, "period"))
		{
			[self setTimes:@(*argv++)];
			[self setFrameGrabTimeType:kSpecifyPeriod];
			gotTimes = YES;
			argc--;
		}
		else if ( ! strcmp ( args, "verbose" ) )
		{
			[self setVerbose:YES];
		}
		else if ( ! strcmp ( args, "progress" ) )
		{
			[self setShowProgress: YES];
		}
		else if ( ! strcmp ( args, "listtracks" ) )
		{
			[self setListTracks: YES];
			parseOK = YES;
		}
		else if ( ! strcmp ( args, "listmetadata" ) )
		{
			[self setListMetadata: YES];
			parseOK = YES;
		}
		else if ( ! strcmp ( args, "help" ) )
		{
			[self printUsage];
		}
		else
		{
			printf("Invalid input parameter: %s\n", args );
			[self printUsage];
			return nil;
		}
	}
	
	if ([self verbose])
	{
		printNSString([NSString stringWithFormat:@"Running: %@\n", [self programName]]);
	}
	
	// There must be a source, times, base file name, and output (the normal case) or parseOK set for a listing
	if (! (parseOK || ((gotsource && gotout && gotBaseFileName && gotExportFileType && gotTimes))) )
	{
		[self printUsage];
		return nil;
	}
	
	return self;
}


-(void) printUsage
{
	printf("makecoversheet - usage:\n");
	printf("	./makecoversheet [-parameter <value> ...]\n");
	printf("	 parameters are all preceded by a -<parameterName>.  The order of the parameters is unimportant.\n");
	printf("	 Required parameters are -source <sourcemovieFileURL> -dest <outputFolderURL>\n");
	printf("	 Source and destination URL strings cannot contain spaces or quoted/escaped.\n");
	printf("	 Available parameters are:\n");
	printf("	 	-destination (or -dest) <outputFolderURL>\n");
	printf("	 	-source <sourceMovieURL>\n");
	printf("	 	-filetype <file type string> The file type (eg public.jpeg) for the output file.\n");
	printf("		-times <list of times> A list of times to take framegrabs (in seconds). Has dec point, no spaces, sep by ,. Ignores invalid times.\n");
	printf("		-number <number> The number of framegrabs to take, evenly spaced throughout the movie. Mutually exclusive with times.\n");
	printf("		-period <period> A framegrab will be taken ever <period> number of seconds. Mutually exclusive with -period and -times.\n");
	printf("		-basefilename The base file name which will have appended grab # and extension.\n");
	printf("	Also available are some setup options:\n");
	printf("		-verbose  Print more information about the execution.\n");
	printf("		-progress  Show progress information.\n");
	printf("		-listmetadata  Lists the metadata in the source movie before the export.  \n");
	printf("		-listtracks  Lists the tracks in the source movie before exporting.  \n");
	printf("	Sample export lines:\n");
	printf("	./makecoversheet -dest ~/Pictures/temp -listmetadata -source /path/to/myTestMovie.m4v -times 1.3,5.0,7.0,12.0 -filetype public.jpeg -basefilename Image\n");
	printf("	./makecoversheet -destination ~/Documents/temp -listtracks -source /path/to/myTestMovie.mov -period 3 -filetype public.tiff -basefilename Image\n");
}

- (NSArray *)createTimesFromSpecifiedTimes:(AVAsset *)urlAsset
{
	NSArray *timesArray = [[self times] componentsSeparatedByString:@","];
	if (!timesArray)
		return nil;
    
	if ([timesArray count] == 0)
		return nil;
	
	NSNumber *theNum = nil;
	NSNumberFormatter *theFormatter = [[NSNumberFormatter alloc] init];
	NSMutableArray *cmTimesArray = [[NSMutableArray alloc] initWithCapacity:0];
	NSValue *cmTimeValue = nil;
	
	for (NSString *theString in timesArray)
	{
		theNum = [theFormatter numberFromString:theString];
		if (theNum)
		{
			Float64 theTimeNum = (Float64)[theNum doubleValue];
			CMTime frameGrabTime = CMTimeMakeWithSeconds(theTimeNum, 600);
			cmTimeValue = [NSValue valueWithCMTime:frameGrabTime];
			[cmTimesArray addObject:cmTimeValue];
		}
	}
	if ([cmTimesArray count] == 0)
		return nil;
	
	return cmTimesArray;
}

- (NSArray *)createTimesFromNumberOfTimes:(AVAsset *)urlAsset
{
	NSNumberFormatter *theFormatter = [[NSNumberFormatter alloc] init];
	NSNumber *numberOfTimesRef = [theFormatter numberFromString:[self times]];
	if (!numberOfTimesRef || [numberOfTimesRef integerValue] == 0)
		return nil;
    
	NSInteger numberOfTimes = [numberOfTimesRef integerValue];
	CMTime movieDuration = [urlAsset duration];
	if (numberOfTimes == 1)
	{
		// Take a framegrab halfway through the movie.
		CMTime frameTime = CMTimeMultiplyByFloat64(movieDuration, 0.5L);
		NSValue *midVal = [NSValue valueWithCMTime:frameTime];
		return @[midVal];
	}
	Float64 inverseNumTimesM1 = 1.0L / (numberOfTimes - 1.0L);
	CMTime periodTime = CMTimeMultiplyByFloat64(movieDuration, inverseNumTimesM1);
	CMTime frameGrabTime = CMTimeMake(0L, movieDuration.timescale);
	NSMutableArray *cmTimesArray = [[NSMutableArray alloc] initWithCapacity:0];
	for (NSInteger i=0 ; i < numberOfTimes ; ++i)
	{
		[cmTimesArray addObject:[NSValue valueWithCMTime:frameGrabTime]];
		if (i == numberOfTimes - 2)
			periodTime.value = periodTime.value - periodTime.timescale / 100;
		frameGrabTime = CMTimeAdd(frameGrabTime, periodTime);
	}
	return [[NSArray alloc] initWithArray:cmTimesArray];
}

- (NSArray *)createTimesFromPeriod:(AVAsset *)urlAsset
{
	NSNumberFormatter *theFormatter = [[NSNumberFormatter alloc] init];
	NSNumber *periodRef = [theFormatter numberFromString:[self times]];
	Float64 periodTime = [periodRef doubleValue];
	CMTime movieDuration = [urlAsset duration];
	CMTime period = CMTimeMakeWithSeconds(periodTime, movieDuration.timescale);
	CMTime frameGrabTime = CMTimeMake(0, movieDuration.timescale);
	NSMutableArray *cmTimesArray = [[NSMutableArray alloc] initWithCapacity:0];
	while (CMTimeCompare(frameGrabTime, movieDuration) < 0)
	{
		[cmTimesArray addObject:[NSValue valueWithCMTime:frameGrabTime]];
		frameGrabTime = CMTimeAdd(frameGrabTime, period);
	}
	return [[NSArray alloc] initWithArray:cmTimesArray];
}

- (NSArray *)createListOfTimes:(AVAsset *)urlAsset
{
	if ([self frameGrabTimeType] == kSpecifyTimes)
		return [self createTimesFromSpecifiedTimes:urlAsset];
	else if ([self frameGrabTimeType] == kSpecifyNumber)
		return [self createTimesFromNumberOfTimes:urlAsset];
	else if ([self frameGrabTimeType] == kSpecifyPeriod)
		return [self createTimesFromPeriod:urlAsset];
	return nil;
}

/*
static dispatch_time_t getDispatchTimeFromSeconds(float seconds)
{
	long long milliseconds = seconds * 1000.0;
	dispatch_time_t waitTime;
	waitTime = dispatch_time(DISPATCH_TIME_NOW, 1000000LL * milliseconds);
	return waitTime;
}
*/

- (int)run
{
	NSURL   *sourceURL;
	AVAssetImageGenerator *imageGenerator;
	NSURL   *destinationURL;
	BOOL	success = YES;
	AVAsset *sourceAsset = nil;
    
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 0LL);
    
	@autoreleasepool
	{
		NSParameterAssert( [self sourcePath] != nil );
        
		if ([self listTracks] && [self sourcePath])
			[self doListTracks:[self sourcePath]];
        
		if ([self listMetadata] && [self sourcePath])
			[self doListMetadata:[self sourcePath]];
        
		if ([self destinationPath] == nil)
		{
			NSLog(@"No output path, listing tracks and/or metadata, export not performed.");
			goto bail;
		}
        
		if ([self sourcePath] != nil)
		{
			sourceURL = [NSURL fileURLWithPath: [self sourcePath] isDirectory: NO];
		}
		
		destinationURL = [NSURL fileURLWithPath: [self destinationPath] isDirectory: YES];
		NSDictionary *optionDict;
		optionDict = [[NSDictionary alloc] initWithObjectsAndKeys:@((NSInteger)YES),
                      AVURLAssetPreferPreciseDurationAndTimingKey, nil];
		sourceAsset = [[AVURLAsset alloc] initWithURL:sourceURL options:optionDict];
        
		if ([[sourceAsset tracksWithMediaType:AVMediaTypeVideo] count] == 0)
			return NO;
        
		if (!([sourceAsset isExportable] || [sourceAsset hasProtectedContent]))
		{
			int exportable = [sourceAsset isExportable];
			int hasProtectedContent = [sourceAsset hasProtectedContent];
			printNSString([NSString stringWithFormat:
						   @"Source movie exportable: %d, hasProtectedConent: %d",
						   exportable, hasProtectedContent]);
			return NO;
		}
        
		// imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:sourceAsset];
		// [imageGenerator setRequestedTimeToleranceAfter:kCMTimeZero];
		// [imageGenerator setRequestedTimeToleranceBefore:kCMTimeZero];
		if ([self verbose])
		{
			printNSString([NSString stringWithFormat:
						   @"Created AVAssetImageGenerator: %p", imageGenerator]);
			printNSString([NSString stringWithFormat:
						   @"source URL:%@", [sourceURL path]]);
			printNSString([NSString stringWithFormat:
						   @"destination URL:%@", [destinationURL path]]);
		}
	}
    
	@autoreleasepool
	{
        size_t cols = NUM_COLS;
        size_t rows = NUM_ROWS;
        size_t borderSize = BORDER_SIZE; // 10 pixel width bordersize.
        CGSize thumbnailSize = { THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT };
        NSURL *destURL = [[NSURL alloc] initFileURLWithPath:[self destinationPath]];
        CGColorRef color = CGColorCreateGenericRGB(BACKGROUND_RED,
                                                   BACKGROUND_GREEN,
                                                   BACKGROUND_BLUE, 1.0);
        NSString *baseName = [self baseFileName];
        [YVSMakeCoverSheet coverSheetInitializersWithColumns:cols
                                                        rows:rows
                                                  borderSize:borderSize
                                               thumbnailSize:thumbnailSize
                                                  destFolder:destURL
                                                    baseName:baseName
                                             backgroundColor:color
                                                     utiType:self.exportImageFileType];

        CGColorRelease(color);
		NSArray *cmTimesArray = [self createListOfTimes:sourceAsset];
		if (!cmTimesArray || [cmTimesArray count] == 0)
			return NO;
		
		NSInteger numTimes = [cmTimesArray count];
        size_t numThumbnailsPerSheet = cols * rows;
        size_t numSheets = ceil(numTimes / (1.0 * numThumbnailsPerSheet));
        dispatch_semaphore_t sessionWaitSemaphore = dispatch_semaphore_create(0);
        
        for (int sheetIdx = 0 ; sheetIdx < numSheets ; sheetIdx++)
        {
            NSRange sheetRange = NSMakeRange(sheetIdx*numThumbnailsPerSheet,
                                             numThumbnailsPerSheet);
            if (NSMaxRange(sheetRange) > numTimes)
            {
                sheetRange.length -= NSMaxRange(sheetRange) - numTimes;
            }
            NSArray *sheetTimes = [cmTimesArray subarrayWithRange:sheetRange];
            [YVSMakeCoverSheet makeCoverSheetFromSourceAsset:sourceAsset
                                             finishSemaphore:sessionWaitSemaphore
                                                     atTimes:sheetTimes
                                             coverSheetIndex:sheetIdx];
        }

        size_t currentSheet = 0;
		do
		{
			dispatch_time_t dispatchTime = DISPATCH_TIME_FOREVER;
			// if we dont want progress, we will wait until it finishes.
			if ([self showProgress])
			{
                //				dispatchTime = getDispatchTimeFromSeconds((float)1.0);
				printNSString([NSString stringWithFormat:
                @"running progress=%3.2f%% Sheet number: %ld",
                               currentSheet*100.0 / numSheets, (long)currentSheet]);
			}
            currentSheet++;
			dispatch_semaphore_wait(sessionWaitSemaphore, dispatchTime);
		}
		while( currentSheet < numSheets - 1 );
        
		if ([self showProgress])
			printNSString(@"AVAssetImageGenerator finished progress");
		
		if ([self listMetadata] && [self destinationPath])
			[self doListMetadata:[self destinationPath]];
        
		if ([self listTracks] && [self destinationPath])
			[self doListTracks:[self destinationPath]];
		
		printNSString([NSString stringWithFormat:
					   @"Finished creating images of %@ to %@ success=%s\n",
					   [self sourcePath], [self destinationPath],
					   (success ? "YES" : "NO")]);
	}
    dispatch_time_t finish = dispatch_time(DISPATCH_TIME_NOW, 0LL);
    uint64_t delta = finish - start;
    double seconds = 1.0e-09 * delta;
    printNSString([NSString stringWithFormat:
                   @"Time to process movie frames = %3.2f seconds", seconds]);
bail:
	return success;
}

- (void)doListTracks:(NSString *)assetPath
{
	//  A simple listing of the tracks in the asset provided
	NSURL *sourceURL = [NSURL fileURLWithPath: assetPath isDirectory: NO];
	if (sourceURL)
	{
		AVURLAsset *sourceAsset;
		sourceAsset = [[AVURLAsset alloc] initWithURL:sourceURL options:nil];
		printNSString([NSString stringWithFormat:@"Listing tracks for AVURLAsset:%@",
                       [sourceURL path]]);
		NSInteger index = 0;
		for (AVAssetTrack *track in [sourceAsset tracks])
		{
			printNSString([ NSString stringWithFormat:
                           @"  Track index:%ld, trackID:%d, mediaType:%@, enabled:%d, isSelfContained:%d",
                           index, [track trackID], [track mediaType], [track isEnabled],
                           [track isSelfContained] ] );
			index++;
		}
	}
}

- (void)doListFileTypes:(NSArray *)fileTypes
{
	//  A simple listing of the tracks in the asset provided
	if (fileTypes)
	{
        //		NSLog(@"file types: %@", [fileTypes description]);
		printNSString([NSString stringWithFormat:@"Listing possible file export types"]);
		for (NSString *theFileType in fileTypes)
		{
			printNSString([ NSString stringWithFormat:@"File Export type: %@",
                           theFileType] );
		}
	}
}

enum {
	kMaxMetadataValueLength = 80,
};

- (void)doListMetadata:(NSString *)assetPath
{
	//  A simple listing of the metadata in the asset provided
	NSURL *sourceURL = [NSURL fileURLWithPath: assetPath isDirectory: NO];
	if (sourceURL)
	{
		AVURLAsset *sourceAsset = [[AVURLAsset alloc] initWithURL:sourceURL options:nil];
		NSLog(@"Listing metadata for asset from url:%@", [sourceURL path]);
		for (NSString *format in [sourceAsset availableMetadataFormats])
		{
			NSLog(@"Metadata for format:%@", format);
			for (AVMetadataItem *item in [sourceAsset metadataForFormat:format])
			{
				NSObject *key = [item key];
				NSString *itemValue = [[item value] description];
				if ([itemValue length] > kMaxMetadataValueLength) {
					itemValue = [NSString stringWithFormat:@"%@ ...",
								 [itemValue substringToIndex:kMaxMetadataValueLength-4]];
				}
				if ([key isKindOfClass: [NSNumber class]])
				{
					NSInteger longValue = [(NSNumber *)key longValue];
					char *charSource = (char *)&longValue;
					char charValue[5] = {0};
					charValue[0] = charSource[3];
					charValue[1] = charSource[2];
					charValue[2] = charSource[1];
					charValue[3] = charSource[0];
					NSString *stringKey;
					stringKey = [[NSString alloc]
                                 initWithBytes:charValue
                                 length:4
                                 encoding:NSMacOSRomanStringEncoding];
					printNSString([NSString stringWithFormat:
                                   @"  metadata item key:%@ (%ld), keySpace:%@ commonKey:%@ value:%@",
                                   stringKey, longValue, [item keySpace], [item commonKey], itemValue]);
				}
				else
				{
					printNSString([NSString stringWithFormat:
                                   @"  metadata item key:%@, keySpace:%@ commonKey:%@ value:%@",
                                   [item key], [item keySpace], [item commonKey], itemValue]);
				}
			}
		}
	}
}


@end


// ---------------------------------------------------------------------------
//		main
// ---------------------------------------------------------------------------


int main (int argc, const char * argv[], const char* environ[])
{
	BOOL success = NO;
	@autoreleasepool
	{
		AVFrameGrab* frameGrabber = [[AVFrameGrab alloc] initWithArgs:argc
                                                                 argv:argv
															  environ:environ];
		if (frameGrabber)
			success = [frameGrabber run];
	}
	return ((success == YES) ? 0 : -1);
}


// ---------------------------------------------------------------------------
//		printNSString
// ---------------------------------------------------------------------------
static void printNSString(NSString *string)
{
	printf("%s\n", [string cStringUsingEncoding:NSUTF8StringEncoding]);
}

// ---------------------------------------------------------------------------
//		printArgs
// ---------------------------------------------------------------------------
static void printArgs(int argc, const char **argv)
{
	int i;
	for( i = 0; i < argc; i++ )
		printf("%s ", argv[i]);
	printf("\n");
}

