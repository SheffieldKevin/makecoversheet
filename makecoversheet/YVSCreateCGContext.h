//
//  YVSCreateCGContext.h
//  makecoversheet
//
//  Created by Kevin Meaney on 18/03/2014.
//  Copyright (c) 2014 Kevin Meaney. All rights reserved.
//

@import Foundation;

@class CIFilter;
@class CIContext;

/*
 Define the presets for the colorspace/bit depth/alpha channel combos
 that have been specifically mentioned as being supported
*/

/**
 @brief Presets for different types of bitmap and pdf contexts to be created.
 @discussion According to the Quartz 2D Programming Guide: Graphic Contexts.
 the following presets are supported pixel formats.
*/

extern NSString *const MIAlphaOnly8bpc8bppInteger; // no colour data.
extern NSString *const MIGray8bpc8bppInteger; // single 8 bit grayscale.
extern NSString *const MIGray16bpc16bppInteger; // single 16 bit grayscale.
extern NSString *const MIGray32bpc32bppFloat; // single 32 bit float grayscale
extern NSString *const MIAlphaSkipFirstRGB8bpc32bppInteger; // XRGB
extern NSString *const MIAlphaSkipLastRGB8bpc32bppInteger; // RGBX
extern NSString *const MIAlphaPreMulFirstRGB8bpc32bppInteger; // aRGB
extern NSString *const MIAlphaPreMulLastRGB8bpc32bppInteger; // RGBa
extern NSString *const MIAlphaPreMulLastRGB16bpc64bppInteger; // RGBa
extern NSString *const MIAlphaSkipLastRGB16bpc64bppInteger; // RGBX
extern NSString *const MIAlphaSkipLastRGB32bpc128bppFloat; // RGBX float
extern NSString *const MIAlphaPreMulLastRGB32bpc128bppFloat; // RGBa
extern NSString *const MICMYK8bpc32bppInteger; // CMYK
extern NSString *const MICMYK16bpc64bppInteger; // CMYK
extern NSString *const MICMYK32bpc128bppFloat; // CMYK.

CGContextRef CreateCGBitmapContextFromPresetSize(NSString *preset,
                                                 CGSize size,
                                                 CGColorSpaceRef colorSpace);

void AddImageToCoverSheetContextUsingCoreImage(CGImageRef image,
                                              CIFilter *scaleFilter,
                                              CIContext *context,
                                              size_t columns,
                                              size_t rows,
                                              CGFloat borderSize,
                                              CGSize scaledImageSize,
                                              size_t imageIndex,
                                              size_t height);