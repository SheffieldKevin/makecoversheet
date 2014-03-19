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

/**
 @brief Designated initializer.
 @param     cols    Number of thumbnail columns.
 @param     rows    Number of thumbnail rows.
 @param     borderSize  Border width between thumbnails. In pixels
 @param     thumbnailSize   Maximum size of thumbnail.
 @param     destFolder  The folder where the cover sheet images are saved.
 @param     baseName    The basename of the cover sheet file. Sequence number and extension will be added.
 @param     softwareRender  Render the CoreImage filter in software, not on the GPU.
 @param     cgContext   Provide a CGContext for the cover sheet. Can be nil.
 @param     backgroundColor Draw the background of the cover sheet with this color.
*/
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

-(void)drawToCoverSheetThumbnail:(CGImageRef)image;
-(void)saveImageFileWithUTI:(CFStringRef)uti;

/**
 @brief Have all positions in the cover sheet have thumbnails drawn.
 @discussion Check this after calling drawToCoverSheetThumbnail and if true
 then you can call the method saveImageFileWithUTI to save the thumbnail.
*/
-(BOOL)coverSheetFull;

@end

