//
//  YVSMakeCoverSheet.h
//  makecoversheet
//
//  Created by Kevin Meaney on 18/03/2014.
//  Copyright (c) 2014 Kevin Meaney. All rights reserved.
//

@import Foundation;

@class CIFilter;
@class CIContext;

@interface YVSMakeCoverSheet : NSObject

@property (assign) size_t numColumns;
@property (assign) size_t numRows;
@property (assign) CGFloat borderSize;
@property (assign) CGSize thumbnailSize;
@property (assign) size_t imageIndex;
@property (strong) NSURL *destinationFolder;
@property (strong) NSString *baseName;
@property (assign) BOOL softwareRender;

-(instancetype)initWithColumns:(size_t)cols
                          rows:(size_t)rows
                    borderSize:(size_t)borderSize
                thumbmnailSize:(CGSize)thumbnailSize
                    destFolder:(NSURL *)destFolder
                      baseName:(NSString *)baseName
                softwareRender:(BOOL)softwareRender
                     cgContext:(CGContextRef)context
               backgroundColor:(CGColorRef)backColor;

-(void)dealloc;

-(size_t)calculateCoverSheetWidth;
-(size_t)calculateCoverSheetHeight;

-(void)drawToCoverSheetThumbnail:(CGImageRef)image;
-(void)saveImageFileWithUTI:(CFStringRef)uti;

-(BOOL)coverSheetFull;

@end

