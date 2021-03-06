//
//  YVSMakeCoverSheet.m
//  makecoversheet
//
//  Created by Kevin Meaney on 18/03/2014.
//  Copyright (c) 2014 Kevin Meaney. All rights reserved.
//

#import "YVSCreateCGContext.h"
#import "YVSMakeCoverSheet.h"

@import QuartzCore;

@interface YVSMakeCoverSheet ()
{
    CGContextRef _context;
    CGColorRef _backColor;
}

@property (strong) CIFilter *ciFilter;
@property (readonly, strong) CIContext *ciContext;

@property (assign) size_t numColumns;
@property (assign) size_t numRows;
@property (assign) CGFloat borderSize;
@property (assign) CGSize thumbnailSize;
@property (assign) size_t imageIndex;
@property (strong) NSURL *destinationFolder;
@property (strong) NSString *baseName;
@property (assign) BOOL softwareRender;

-(void)setContext:(CGContextRef)context;
-(CGContextRef)context;

-(void)setBackgroundColor:(CGColorRef)theBackColor;
-(CGColorRef)backgroundColor;

-(void)resetCIContext;

-(size_t)calculateCoverSheetWidth;
-(size_t)calculateCoverSheetHeight;

@end

@implementation YVSMakeCoverSheet

-(instancetype)initWithColumns:(size_t)cols
                          rows:(size_t)rows
                    borderSize:(size_t)borderSize
                thumbmnailSize:(CGSize)thumbnailSize
                    destFolder:(NSURL *)destFolder
                      baseName:(NSString *)baseName
                softwareRender:(BOOL)softwareRender
                     cgContext:(CGContextRef)context
               backgroundColor:(CGColorRef)backColor
{
    self = [super init];
    if (self)
    {
        self.numColumns = cols;
        self.numRows = rows;
        self.borderSize = borderSize;
        self.thumbnailSize = thumbnailSize;
        self.destinationFolder = destFolder;
        self.baseName = baseName;
        self.softwareRender = softwareRender;
        self.context = context;
        self.backgroundColor = backColor;
        self.ciFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
    }
    return self;
}

-(void)dealloc
{
    self.context = nil;
    self.backgroundColor = nil;
}

-(BOOL)coverSheetFull
{
    return ((self.imageIndex % (self.numColumns * self.numRows)) == 0);
}

-(void)drawToCoverSheetThumbnail:(CGImageRef)image
{
    if (!self.context)
    {
        CGColorSpaceRef colorSpace = nil;
        CGContextRef cgContext = nil;

        // CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
        colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGBLinear);
        CGSize size = CGSizeMake([self calculateCoverSheetWidth],
                                 [self calculateCoverSheetHeight]);
        cgContext = CreateCGBitmapContextFromPresetSize(
//                                            MIAlphaPreMulLastRGB32bpc128bppFloat,
                                            MIAlphaPreMulFirstRGB8bpc32bppInteger,
                                            size, colorSpace);

/*
        colorSpace = CGImageGetColorSpace(image);
        CGBitmapInfo bitmapInfo = (CGBitmapInfo)CGImageGetAlphaInfo(image);
        cgContext = CGBitmapContextCreate(NULL,
                                          [self calculateCoverSheetWidth],
                                          [self calculateCoverSheetHeight],
                                          8, 0, colorSpace, bitmapInfo);
*/
        self.context = cgContext;
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(cgContext);
    }

    if ([self coverSheetFull])
    {
        // Draw background with color.
        CGContextSetFillColorWithColor(self.context, self.backgroundColor);
        CGRect fillRect = CGRectMake(0.0, 0.0,
                                     [self calculateCoverSheetWidth],
                                     [self calculateCoverSheetHeight]);
        CGContextFillRect(self.context, fillRect);
    }
    AddImageToCoverSheetContextUsingCoreImage(image,
                                              self->_ciFilter,
                                              self->_ciContext,
                                              self.numColumns,
                                              self.numRows,
                                              self.borderSize,
                                              self.thumbnailSize,
                                              self.imageIndex,
                                              [self calculateCoverSheetHeight]);
    self.imageIndex += 1;
}

-(void)setContext:(CGContextRef)theContext
{
    if (theContext == self->_context)
        return;
    
    CGContextRelease(self->_context);
    self->_context = CGContextRetain(theContext);
    [self resetCIContext];
}

-(CGContextRef)context
{
    return self->_context;
}

-(void)resetCIContext
{
    if (self.context)
    {
        NSDictionary *optsDict;
        optsDict = @{ kCIContextUseSoftwareRenderer : @(self.softwareRender) };
        self->_ciContext = [CIContext contextWithCGContext:self.context
                                                   options:optsDict];
    }
    else
    {
        self->_ciContext = nil;
    }
}

-(void)setBackgroundColor:(CGColorRef)theBackColor
{
    if (theBackColor == self->_backColor)
        return;
    
    CGColorRelease(self->_backColor);
    self->_backColor = CGColorRetain(theBackColor);
}

-(CGColorRef)backgroundColor
{
    return self->_backColor;
}

-(size_t)calculateCoverSheetWidth
{
    size_t numCols = self.numColumns;
    return (1 + numCols) * self.borderSize + numCols * self.thumbnailSize.width;
}

-(size_t)calculateCoverSheetHeight
{
    size_t numRows = self.numRows;
    return (1 + numRows) * self.borderSize + numRows * self.thumbnailSize.height;
}

-(void)saveImageFileWithUTI:(CFStringRef)uti
{
    if (self.baseName && self.destinationFolder)
    {
        CFStringRef extn;
        extn = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension);
        NSString *extension = (NSString *)CFBridgingRelease(extn);
        NSString *numString = [NSString stringWithFormat:@"%.4ld",
                               (long)(self.imageIndex/(self.numColumns * self.numRows))];
        NSString *fileName = [NSString stringWithFormat:@"%@%@.%@", self.baseName,
                              numString, extension];
        NSURL *fullURL = [self.destinationFolder URLByAppendingPathComponent:fileName
                                                                 isDirectory:NO];
        CGImageDestinationRef destination = CGImageDestinationCreateWithURL(
                                                    (__bridge CFURLRef)fullURL,
                                                    uti, 1, nil);
        CGImageRef image = CGBitmapContextCreateImage(self->_context);
        CGImageDestinationAddImage(destination, image, nil);
        CGImageDestinationFinalize(destination);
        CGImageRelease(image);
        CFRelease(destination);
    }
}

@end
