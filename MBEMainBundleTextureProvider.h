//
//  MBEMainBundleTextureProvider.h
//  ImageProcessing
//
//  Created by Warren Moore on 10/8/14.
//  Copyright (c) 2014 Metal By Example. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBETextureProvider.h"

@class MBEContext;

@interface MBEMainBundleTextureProvider : NSObject<MBETextureProvider>

+ (instancetype)textureProviderWithImageNamed:(NSString *)imageName context:(MBEContext *)context;

@end
