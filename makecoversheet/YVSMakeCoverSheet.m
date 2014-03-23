//
//  YVSMakeCoverSheet.m
//  makecoversheet
//
//  Created by Kevin Meaney on 18/03/2014.
//  Copyright (c) 2014 Kevin Meaney. All rights reserved.
//

#import "YVSCreateCGContext.h"
#import "YVSMakeCoverSheet.h"

@import AVFoundation;
@import QuartzCore; // Don't bother excluding if we're not using CoreImage.

#define USE_COREIMAGE 0

#pragma mark Private Interface for YVSMakeCoverSheet

@interface YVSMakeCoverSheet ()
{
    CGContextRef _context;
}

@property (assign) size_t imageIndex;
@property (assign) size_t imagesProcessed;
@property (assign) BOOL   saveOnPartialCoverSheet;
@property (readonly, assign) size_t coverSheetIndex;
@property (strong) dispatch_queue_t serialQueue;

#if USE_COREIMAGE
@property (strong) CIContext *ciContext;
@property (strong) CIFilter *ciFilter;
#endif

#pragma mark Private Class Interface

+(size_t)numColumns;
+(void)setNumColumns:(size_t)theNumColumns;

+(size_t)numRows;
+(void)setNumRows:(size_t)theNumRows;

+(CGFloat)borderSize;
+(void)setBorderSize:(CGFloat)theBorderSize;

+(CGSize)thumbnailSize;
+(void)setThumbnailSize:(CGSize)theThumbnailSize;

// synchronized with class self as the cover sheet index will be changing.
+(size_t)coverSheetIndex;
+(void)setCoverSheetIndex:(size_t)theCoverSheetIndex;

+(NSURL *)destinationFolder;
+(void)setDestinationFolder:(NSURL *)theDestFolder;

+(NSString *)baseName;
+(void)setBaseName:(NSString *)theBaseName;

+(CGColorRef)backColor;
+(void)setBackColor:(CGColorRef)theBackgroundColor;

+(NSString *)utiType;
+(void)setUtiType:(NSString *)theUtiType;

+(size_t)coverSheetWidth;
+(void)setCoverSheetWidth:(size_t)theCoverSheetWidth;

+(size_t)coverSheetHeight;
+(void)setCoverSheetHeight:(size_t)theCoverSheetHeight;

+(void)incrementSheetsProcessed;

/**
 The current cover sheet maker is the one which we are sending images to, which
 are to be added to the cover sheet. There may be others that are still processing
 the images that have been sent to them to add to their cover sheet. To stop ARC
 deallocating these cover sheets I've got a list of currently processing cover
 sheet makers where the cover sheet maker will remove itself from the list when
 it's finished working. This list may not be necessary as the blocks that are
 doing the work are probably holding onto the cover sheet maker already.
 
 synchronized with class slef as the current cover sheet will be changing.
*/
+(YVSMakeCoverSheet *)currentCoverSheetMaker;
+(void)setCurrentCoverSheetMaker:(YVSMakeCoverSheet *)theCoverSheetMaker;

#pragma mark Private Interface

-(void)setContext:(CGContextRef)context;

-(void)saveImageFile;

-(void)drawToCoverSheetThumbnail:(CGImageRef)image atIndex:(size_t)index;

@end

#pragma mark - YVSMakeCoverSheet Implementation

@implementation YVSMakeCoverSheet

#pragma mark Class members

// Do not access the following directly. Use accessors.
//====================================================================
static size_t _numColumns;
static size_t _numRows;
static CGFloat _borderSize;
static size_t _coverSheetWidth;
static size_t _coverSheetHeight;
static size_t _sheetsProcessed;
static CGSize _thumbnailSize;
static size_t _coverSheetIndex;
static NSURL *_destinationFolder;
static NSString *_baseName;
static CGColorRef _backgroundColor;
static YVSMakeCoverSheet *_currentCoverSheetMaker;
static NSString *_utiType;
//====================================================================
// Do not access the above directly. Use the accessors implemented below.

#pragma mark Private Class Methods implementation

+(size_t)numColumns
{
    return _numColumns;
}

+(void)setNumColumns:(size_t)theNumColumns
{
    _numColumns = theNumColumns;
}

+(size_t)numRows
{
    return _numRows;
}

+(void)setNumRows:(size_t)theNumRows
{
    _numRows = theNumRows;
}

+(CGFloat)borderSize
{
    return _borderSize;
}

+(void)setBorderSize:(CGFloat)theBorderSize
{
    _borderSize = theBorderSize;
}

+(CGSize)thumbnailSize
{
    return _thumbnailSize;
}

+(void)setThumbnailSize:(CGSize)theThumbnailSize
{
    _thumbnailSize = theThumbnailSize;
}

+(size_t)coverSheetIndex
{
    return _coverSheetIndex;
}

+(void)setCoverSheetIndex:(size_t)theCoverSheetIndex
{
    _coverSheetIndex = theCoverSheetIndex;
}

+(YVSMakeCoverSheet *)currentCoverSheetMaker
{
    return _currentCoverSheetMaker;
}

+(void)setCurrentCoverSheetMaker:(YVSMakeCoverSheet *)theCoverSheetMaker
{
    _currentCoverSheetMaker = theCoverSheetMaker;
}

+(NSURL *)destinationFolder
{
    return _destinationFolder;
}

+(void)setDestinationFolder:(NSURL *)theDestFolder
{
    _destinationFolder = theDestFolder;
}

+(NSString *)baseName
{
    return _baseName;
}

+(void)setBaseName:(NSString *)theBaseName
{
    _baseName = theBaseName;
}

+(CGColorRef)backColor
{
    return _backgroundColor;
}

+(void)setBackColor:(CGColorRef)theBackgroundColor
{
    if (theBackgroundColor == _backgroundColor)
        return;
    
    CGColorRelease(_backgroundColor);
    _backgroundColor = CGColorRetain(theBackgroundColor);
}

+(NSString *)utiType
{
    return _utiType;
}

+(void)setUtiType:(NSString *)theUtiType
{
    _utiType = theUtiType;
}

+(size_t)coverSheetWidth
{
    return _coverSheetWidth;
}

+(void)setCoverSheetWidth:(size_t)theCoverSheetWidth
{
    _coverSheetWidth = theCoverSheetWidth;
}

+(size_t)coverSheetHeight
{
    return _coverSheetHeight;
}

+(void)setCoverSheetHeight:(size_t)theCoverSheetHeight
{
    _coverSheetHeight = theCoverSheetHeight;
}

+(size_t)sheetsProcessed
{
    return _sheetsProcessed;
}

+(void)incrementSheetsProcessed
{
    @synchronized(self)
    {
        _sheetsProcessed++;
    }
}

#pragma mark Public Class Methods implementation

+(void)coverSheetInitializersWithColumns:(size_t)cols
                                    rows:(size_t)rows
                              borderSize:(size_t)borderSize
                           thumbnailSize:(CGSize)thumbnailSize
                              destFolder:(NSURL *)destFolder
                                baseName:(NSString *)baseName
                         backgroundColor:(CGColorRef)backColor
                                 utiType:(NSString *)theUtiType
{
    self.numColumns = cols;
    self.numRows = rows;
    self.borderSize = borderSize;
    self.thumbnailSize = thumbnailSize;
    self.coverSheetWidth = (1 + cols) * borderSize + cols * thumbnailSize.width;
    self.coverSheetHeight = (1 + rows) * borderSize + rows * thumbnailSize.height;
    self.destinationFolder = destFolder;
    self.baseName = baseName;
    self.backColor = backColor;
    self.utiType = theUtiType;
}

+(void)makeCoverSheetFromSourceAsset:(AVAsset *)sourceAsset
                     finishSemaphore:(dispatch_semaphore_t)finishSemaphore
                             atTimes:(NSArray *)times
                     coverSheetIndex:(size_t)index
{
    YVSMakeCoverSheet *coverSheet = [[self alloc] initWithCoverSheetIndex:index];
    size_t numberOfFrameTimes = [times count];
    AVAssetImageGenerator *imageGenerator;
    imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:sourceAsset];
    [imageGenerator setRequestedTimeToleranceAfter:kCMTimeZero];
    [imageGenerator setRequestedTimeToleranceBefore:kCMTimeZero];
    AVAssetImageGeneratorCompletionHandler imageCreatedCompletionHandler;
    imageCreatedCompletionHandler = ^(CMTime requestedTime, CGImageRef image,
                                      CMTime actualTime,
                                      AVAssetImageGeneratorResult result,
                                      NSError *error)
    {
        @autoreleasepool
        {
            if (result == AVAssetImageGeneratorSucceeded)
            {
                size_t thumbIndex = coverSheet.imageIndex;
                CGImageRetain(image);
                dispatch_async(coverSheet.serialQueue, ^
                {
                    [coverSheet drawToCoverSheetThumbnail:image atIndex:thumbIndex];
                    CGImageRelease(image);
                    if (coverSheet.imagesProcessed == numberOfFrameTimes)
                    {
                        [coverSheet saveImageFile];
                        [YVSMakeCoverSheet incrementSheetsProcessed];
                        dispatch_semaphore_signal(finishSemaphore);
                    }
                });
                coverSheet.imageIndex++;
            }
            if (result == AVAssetImageGeneratorCancelled)
            {
                NSLog(@"Canceled");
                dispatch_semaphore_signal(finishSemaphore);
            }
        }
    };
    
    [imageGenerator generateCGImagesAsynchronouslyForTimes:times
                            completionHandler:imageCreatedCompletionHandler];
}

#pragma mark Private class initializer.

-(instancetype)initWithCoverSheetIndex:(size_t)coverSheetIndex
{
    self = [super init];
    if (self)
    {
        self->_coverSheetIndex = coverSheetIndex;
        self.serialQueue = dispatch_queue_create("com.yvs.makecoversheet",
                                                 DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(self.serialQueue,
                    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
#if USE_COREIMAGE
        self.ciFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
#endif
    }
    return self;
}

-(void)dealloc
{
    self.context = nil;
}

-(void)drawToCoverSheetThumbnail:(CGImageRef)image atIndex:(size_t)index
{
    if (!self.context)
    {
        CGColorSpaceRef colorSpace = nil;
        CGContextRef cgContext = nil;

        // CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
        colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGBLinear);
        CGSize size = CGSizeMake(YVSMakeCoverSheet.coverSheetWidth,
                                 YVSMakeCoverSheet.coverSheetHeight);
        cgContext = CreateCGBitmapContextFromPresetSize(
                                            MIAlphaPreMulFirstRGB8bpc32bppInteger,
                                            size, colorSpace);

        self.context = cgContext;
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(cgContext);
        // Draw background with color.
        CGContextSetFillColorWithColor(self.context, YVSMakeCoverSheet.backColor);
        CGRect fillRect = CGRectMake(0.0, 0.0,
                                     YVSMakeCoverSheet.coverSheetWidth,
                                     YVSMakeCoverSheet.coverSheetHeight);
        CGContextFillRect(self.context, fillRect);
#if USE_COREIMAGE
        self.ciContext = [CIContext contextWithCGContext:cgContext options:nil];
#endif
    }

    size_t imageWidth = CGImageGetWidth(image);
    size_t imageHeight = CGImageGetHeight(image);
    CGFloat scale, scalex, scaley;
    scalex = YVSMakeCoverSheet.thumbnailSize.width / imageWidth;
    scaley = YVSMakeCoverSheet.thumbnailSize.height / imageHeight;
    scale = fmin(scalex, scaley);
    
    CGRect destRect;
    destRect.size.width = imageWidth * scale;
    destRect.size.height = imageHeight * scale;
    size_t rowIndex = index / YVSMakeCoverSheet.numColumns;
    size_t columnIndex = index % YVSMakeCoverSheet.numColumns;
    destRect.origin.x = (1 + columnIndex) * YVSMakeCoverSheet.borderSize +
                    columnIndex * YVSMakeCoverSheet.thumbnailSize.width;
    destRect.origin.y = YVSMakeCoverSheet.coverSheetHeight - ((1 + rowIndex) *
                                  (YVSMakeCoverSheet.borderSize +
                                   YVSMakeCoverSheet.thumbnailSize.height));
#if USE_COREIMAGE
    [self.ciFilter setDefaults];
    [self.ciFilter setValue:[CIImage imageWithCGImage:image] forKey:@"inputImage"];
    [self.ciFilter setValue:@(scale) forKey:@"inputScale"];
    CIImage *outImage = [self.ciFilter valueForKey:@"outputImage"];
    [self.ciContext drawImage:outImage inRect:destRect fromRect:[outImage extent]];
#else
    CGContextDrawImage(self.context, destRect, image);
#endif
    
    @synchronized(self)
    {
        self.imagesProcessed += 1;
    }
}

-(void)setContext:(CGContextRef)theContext
{
    if (theContext == self->_context)
        return;
    
    CGContextRelease(self->_context);
    self->_context = CGContextRetain(theContext);
}

-(CGContextRef)context
{
    return self->_context;
}

-(void)saveImageFile
{
    CFStringRef uti = (__bridge CFStringRef)YVSMakeCoverSheet.utiType;
    if (YVSMakeCoverSheet.baseName && YVSMakeCoverSheet.destinationFolder)
    {
        CFStringRef extn;
        extn = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension);
        NSString *extension = (NSString *)CFBridgingRelease(extn);
        NSString *numString = [NSString stringWithFormat:@"%.4ld",
                                                        self.coverSheetIndex];
        NSString *fileName = [NSString stringWithFormat:@"%@%@.%@",
                              YVSMakeCoverSheet.baseName, numString, extension];
        NSURL *fullURL = [YVSMakeCoverSheet.destinationFolder
                          URLByAppendingPathComponent:fileName
                                          isDirectory:NO];
        CGImageDestinationRef dest;
        dest = CGImageDestinationCreateWithURL((__bridge CFURLRef)fullURL, uti, 1, nil);
        CGImageRef image = CGBitmapContextCreateImage(self->_context);
        CGImageDestinationAddImage(dest, image, nil);
        CGImageDestinationFinalize(dest);
        CGImageRelease(image);
        CFRelease(dest);
    }
}

@end
