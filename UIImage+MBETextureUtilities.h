//
//  UIImage+MBETextureUtilities.h
//  ImageProcessing
//
//  Created by Warren Moore on 10/8/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MTLTexture;

@interface UIImage (MBETextureUtilities)

+ (UIImage *)imageWithMTLTexture:(id<MTLTexture>)texture;

@end

