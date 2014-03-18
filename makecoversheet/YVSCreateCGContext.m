//
//  YVSCreateCGContext.m
//  makecoversheet
//
//  Created by Kevin Meaney on 18/03/2014.
//  Copyright (c) 2014 Kevin Meaney. All rights reserved.
//

#import "YVSCreateCGContext.h"
@import QuartzCore;

NSString *const MIAlphaOnly8bpc8bppInteger = @"AlphaOnly8bpcInt";
NSString *const MIGray8bpc8bppInteger = @"Gray8bpcInt";
NSString *const MIGray16bpc16bppInteger = @"Gray16bpcInt";
NSString *const MIGray32bpc32bppFloat = @"Gray32bpcFloat";
NSString *const MIAlphaSkipFirstRGB8bpc32bppInteger = @"AlphaSkipFirstRGB8bpcInt";
NSString *const MIAlphaSkipLastRGB8bpc32bppInteger = @"AlphaSkipLastRGB8bpcInt";
NSString *const MIAlphaPreMulFirstRGB8bpc32bppInteger = @"AlphaPreMulFirstRGB8bpcInt";
NSString *const MIAlphaPreMulLastRGB8bpc32bppInteger = @"AlphaPreMulLastRGB8bpcInt";
NSString *const MIAlphaPreMulLastRGB16bpc64bppInteger = @"AlphaPreMulLastRGB16bpcInt";
NSString *const MIAlphaSkipLastRGB16bpc64bppInteger = @"AlphaSkipLastRGB16bpcInt";
NSString *const MIAlphaSkipLastRGB32bpc128bppFloat = @"AlphaSkipLastRGB32bpcFloat";
NSString *const MIAlphaPreMulLastRGB32bpc128bppFloat = @"AlphaPreMulLastRGB32bpcFloat";
NSString *const MICMYK8bpc32bppInteger = @"CMYK8bpcInt";
NSString *const MICMYK16bpc64bppInteger = @"CMYK16bpcInt";
NSString *const MICMYK32bpc128bppFloat = @"CMYK32bpcFloat";


static NSDictionary *GetCGBitmapContextDictionaryFromPreset(NSString *preset)
{
    NSDictionary *resultsDict = NULL;
    static NSDictionary *presetsDict = NULL;
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^
    {
        presetsDict =
        @{
            MIAlphaOnly8bpc8bppInteger :
            @{
                @"colorspace" : (NSString *)[NSNull null],
                @"bitspercomponent" : @8,
                @"bitsperpixel" : @8,
                @"alphainfo" : @(kCGImageAlphaOnly)
            },
            MIGray8bpc8bppInteger :
            @{
                @"colorspace" : (NSString *)kCGColorSpaceGenericGray,
                @"bitspercomponent" : @8,
                @"bitsperpixel" : @8,
                @"alphainfo" : @(kCGImageAlphaNone)
            },
            MIGray16bpc16bppInteger :
            @{
                @"colorspace" : (NSString *)kCGColorSpaceGenericGray,
                @"bitspercomponent" : @16,
                @"bitsperpixel" : @16,
                @"alphainfo" : @(kCGImageAlphaNone | kCGBitmapByteOrder16Little)
            },
            MIGray32bpc32bppFloat :
            @{
                @"colorspace" : (NSString *)kCGColorSpaceGenericGray,
                @"bitspercomponent" : @32,
                @"bitsperpixel" : @32,
                @"alphainfo" : @(kCGImageAlphaNone |
                                kCGBitmapFloatComponents |
                                kCGBitmapByteOrder32Little)
            },
            MIAlphaSkipFirstRGB8bpc32bppInteger :
            @{
                @"colorspace" : (NSString *)kCGColorSpaceSRGB,
                @"bitspercomponent" : @8,
                @"bitsperpixel" : @32,
                @"alphainfo" : @(kCGImageAlphaNoneSkipFirst)
            },
            MIAlphaSkipLastRGB8bpc32bppInteger :
            @{
                @"colorspace" : (NSString *)kCGColorSpaceSRGB,
                @"bitspercomponent" : @8,
                @"bitsperpixel" : @32,
                @"alphainfo" : @(kCGImageAlphaNoneSkipLast)
            },
            MIAlphaPreMulFirstRGB8bpc32bppInteger :
            @{
                @"colorspace" : (NSString *)kCGColorSpaceSRGB,
                @"bitspercomponent" : @8,
                @"bitsperpixel" : @32,
                @"alphainfo" : @(kCGImageAlphaPremultipliedFirst)
            },
            MIAlphaPreMulLastRGB8bpc32bppInteger :
            @{
                @"colorspace" : (NSString *)kCGColorSpaceSRGB,
                @"bitspercomponent" : @8,
                @"bitsperpixel" : @32,
                @"alphainfo" : @(kCGImageAlphaPremultipliedLast)
            },
            MIAlphaPreMulLastRGB16bpc64bppInteger :
            @{
                @"colorspace" : (NSString *)kCGColorSpaceSRGB,
                @"bitspercomponent" : @16,
                @"bitsperpixel" : @64,
                @"alphainfo" : @(kCGImageAlphaPremultipliedLast |
                                kCGBitmapByteOrder16Little)
            },
            MIAlphaSkipLastRGB16bpc64bppInteger :
            @{
                @"colorspace" : (NSString *)kCGColorSpaceSRGB,
                @"bitspercomponent" : @16,
                @"bitsperpixel" : @64,
                @"alphainfo" : @(kCGImageAlphaNoneSkipLast |
                                kCGBitmapByteOrder16Little)
            },
            MIAlphaSkipLastRGB32bpc128bppFloat :
            @{
                @"colorspace" : (NSString *)kCGColorSpaceSRGB,
                @"bitspercomponent" : @32,
                @"bitsperpixel" : @128,
                @"alphainfo" : @(kCGImageAlphaNoneSkipLast |
                                kCGBitmapFloatComponents |
                                kCGBitmapByteOrder32Little)
            },
            MIAlphaPreMulLastRGB32bpc128bppFloat :
            @{
                @"colorspace" : (NSString *)kCGColorSpaceSRGB,
                @"bitspercomponent" : @32,
                @"bitsperpixel" : @128,
                @"alphainfo" : @(kCGImageAlphaPremultipliedLast |
                                kCGBitmapFloatComponents |
                                kCGBitmapByteOrder32Little)
            },
            MICMYK8bpc32bppInteger :
            @{
                @"colorspace" : (NSString *)kCGColorSpaceGenericCMYK,
                @"bitspercomponent" : @8,
                @"bitsperpixel" : @32,
                @"alphainfo" : @(kCGImageAlphaNone)
            },
            MICMYK16bpc64bppInteger :
            @{
                @"colorspace" : (NSString *)kCGColorSpaceGenericCMYK,
                @"bitspercomponent" : @16,
                @"bitsperpixel" : @64,
                @"alphainfo" : @(kCGImageAlphaNone | kCGBitmapByteOrder16Little)
            },
            MICMYK32bpc128bppFloat :
            @{
                @"colorspace" : (NSString *)kCGColorSpaceGenericCMYK,
                @"bitspercomponent" : @32,
                @"bitsperpixel" : @128,
                @"alphainfo" : @(kCGImageAlphaNone |
                                kCGBitmapFloatComponents |
                                kCGBitmapByteOrder32Little)
            }
        };
    });
    
    resultsDict = presetsDict[preset];
    return resultsDict;
}

CGContextRef CreateCGBitmapContextFromPresetSize(NSString *preset,
                                                 CGSize size,
                                                 CGColorSpaceRef colorSpace)
{
    CGContextRef theContext = NULL;
    NSDictionary *theDict = GetCGBitmapContextDictionaryFromPreset(preset);
    if (theDict == NULL)
        return theContext;
    
    NSInteger bpc = [theDict[@"bitspercomponent"] integerValue];
    NSInteger bpp = [theDict[@"bitsperpixel"] integerValue];
    size_t width = size.width;
    size_t height = size.height;
    NSInteger alphaInfo = [theDict[@"alphainfo"] integerValue];
    CGBitmapInfo bitMapInfo = (CGBitmapInfo)alphaInfo;
    
    size_t bytesPerRow = width * bpp / 8;
    // For efficiency We need to make sure row bytes is a multiple of 16 bytes.
    if (bytesPerRow % 16)
        bytesPerRow += 16 - bytesPerRow % 16;
    
    CGColorSpaceRef locallyOwnedColorSpace = NULL; // (CGColorSpaceRef)kCFNull;
    if (!colorSpace)
    {
        CFStringRef profileName = (__bridge CFStringRef)theDict[@"colorspace"];
        locallyOwnedColorSpace = CGColorSpaceCreateWithName(profileName);
        colorSpace = locallyOwnedColorSpace;
    }
    
    theContext = CGBitmapContextCreate(NULL, width, height, bpc, bytesPerRow,
                                       colorSpace, bitMapInfo);
    if (alphaInfo != kCGImageAlphaNone)
        CGContextSetAlpha(theContext, 1.0);
    
    CGColorRef white = CGColorGetConstantColor(kCGColorWhite);
    CGContextSetFillColorWithColor(theContext, white);
    CGRect theRect = CGRectMake(0.0, 0.0, width, height);
    CGContextFillRect(theContext, theRect);
    CGColorSpaceRelease(locallyOwnedColorSpace);
    return theContext;
}

void AddImageToCoverSheetContextUsingCoreImage(CGImageRef image,
                                               CIFilter *scaleFilter,
                                               CIContext *context,
                                               size_t columns,
                                               size_t rows,
                                               CGFloat borderSize,
                                               CGSize scaledImageSize,
                                               size_t imageIndex)
{
    // Assumes context is big enough to draw the image into.
    // Assumes up and to the right is positive and bottom left corner is at 0,0
    size_t localIndex = imageIndex % (columns * rows);
    //    CIFilter *scaleFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
    CIImage *ciImage = [[CIImage alloc] initWithCGImage:image];
    [scaleFilter setDefaults];
    [scaleFilter setValue:ciImage forKey:@"inputImage"];
    size_t imageWidth = CGImageGetWidth(image);
    size_t imageHeight = CGImageGetHeight(image);
    CGFloat scale, scalex, scaley;
    scalex = scaledImageSize.width / imageWidth;
    scaley = scaledImageSize.height / imageHeight;
    scale = fmin(scalex, scaley);
    [scaleFilter setValue:@(scale) forKey:@"inputScale"];
    CIImage *outputImage = [scaleFilter valueForKey:@"outputImage"];
    CGRect outputExtent = [outputImage extent];
    
    CGRect destRect;
    destRect.size = scaledImageSize;
    size_t rowIndex = localIndex / columns;
    size_t columnIndex = localIndex % columns;
    destRect.origin.x = (1 + columnIndex) * borderSize +
    columnIndex * outputExtent.size.width;
    destRect.origin.y = (1 + rowIndex) * borderSize +
    rowIndex * outputExtent.size.height;
    [context drawImage:outputImage inRect:destRect fromRect:outputExtent];
}
