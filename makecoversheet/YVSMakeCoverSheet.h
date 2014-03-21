//
//  YVSMakeCoverSheet.h
//  makecoversheet
//
//  Created by Kevin Meaney on 18/03/2014.
//  Copyright (c) 2014 Kevin Meaney. All rights reserved.
//

@import Foundation;

@interface YVSMakeCoverSheet : NSObject

/**
 @brief Constants for initialization of the YVSMAkeCoverSheet class.
 @param     cols    Number of thumbnail columns.
 @param     rows    Number of thumbnail rows.
 @param     borderSize  Border width between thumbnails. In pixels
 @param     thumbnailSize   Maximum size of thumbnail.
 @param     destFolder  The folder where the cover sheet images are saved.
 @param     baseName    The basename of the cover sheet file.
                        Sequence number and extension will be added.
 @param     backgroundColor Draw the background of the cover sheet with this color.
*/
+(void)coverSheetInitializersWithColumns:(size_t)cols
                                    rows:(size_t)rows
                              borderSize:(size_t)borderSize
                           thumbnailSize:(CGSize)thumbnailSize
                              destFolder:(NSURL *)destFolder
                                baseName:(NSString *)baseName
                         backgroundColor:(CGColorRef)backColor
                                 utiType:(NSString *)utiType;

/**
 @brief Draw the image as a thumbnail to a cover sheet.
 @discussion Create the cover sheet if necessary. If drawing this image to the
 cover sheet fills the cover sheet then after it is drawn then the cover sheet
 should save itself to disk.
*/
+(void)drawImageToCoverSheetAsThumbnail:(CGImageRef)image;

+(void)finalize;

-(void)dealloc;

@end

